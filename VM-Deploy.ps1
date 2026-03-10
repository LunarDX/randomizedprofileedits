Param(
    # 2. Virtual machine name
    [Parameter(Mandatory = $true)]
    [string]$VmName,

    # 3. Subscription (name or GUID)
    [string]$SubscriptionId,

    # 4. Azure region
    [string]$Location = 'westus',

    # 5. Resource group name
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    # 6. Availability set (optional – existing or will be created)
    [string]$AvailabilitySetName,

    # 7. OS image (default: Windows Server 2022 Datacenter)
    [string]$ImageUrn = 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest',

    # 8. VM size
    [string]$VmSize = 'Standard_B12ms',

    # 9/10. Disk settings (simplified)
    [int]$OsDiskSizeGB = 128,

    # Single optional data disk
    [int]$DataDiskSizeGB,

    # 11. VNet
    [string]$VirtualNetworkName,
    [string]$VirtualNetworkResourceGroup,

    # 12. Subnet
    [string]$SubnetName = 'default',

    # 13. IP configuration
    [string]$PrivateIpAddress,          # e.g. 10.2.2.141 for static
    [switch]$AllocatePublicIp,         # create a public IP if set

    # 14. Start/Stop automation – informational flag only
    [string]$StartStopSchedule,

    # 15. Patch group tag
    [string]$PatchGroup,

    # 16. Backup flag – informational
    [switch]$EnableBackup,

    # 17. Inbound ports on NSG (e.g. 3389,80,443)
    [int[]]$InboundPorts = @(3389),

    # 18. Domain join – informational for now
    [string]$DomainToJoin,

    # Diagnostics
    [switch]$EnableDiagnosticLogs
)

Import-Module Az.Accounts -ErrorAction Stop
Import-Module Az.Compute  -ErrorAction Stop
Import-Module Az.Network  -ErrorAction Stop
Import-Module Az.Resources -ErrorAction Stop

Write-Host "=== VM deployment starting for '$VmName' ===" -ForegroundColor Cyan

if ($SubscriptionId) {
    Write-Host "Setting Azure context to subscription '$SubscriptionId'..." -ForegroundColor Cyan
    Set-AzContext -Subscription $SubscriptionId -ErrorAction Stop | Out-Null
}

if (-not (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating resource group '$ResourceGroupName' in '$Location'..." -ForegroundColor Cyan
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
}

$vnetRg = if ($VirtualNetworkResourceGroup) { $VirtualNetworkResourceGroup } else { $ResourceGroupName }

if ($VirtualNetworkName) {
    $vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $vnetRg -ErrorAction SilentlyContinue
    if (-not $vnet) {
        throw "Virtual network '$VirtualNetworkName' not found in resource group '$vnetRg'."
    }
    $subnet = $vnet.Subnets | Where-Object { $_.Name -eq $SubnetName }
    if (-not $subnet) {
        throw "Subnet '$SubnetName' not found in virtual network '$VirtualNetworkName'."
    }
} else {
    Write-Host "No VNet specified – creating a simple VNet '$VmName-vnet' and subnet 'default' (10.0.0.0/16, 10.0.0.0/24)." -ForegroundColor Yellow
    $vnet = New-AzVirtualNetwork `
        -Name "$VmName-vnet" `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -AddressPrefix '10.0.0.0/16' `
        -Subnet @(New-AzVirtualNetworkSubnetConfig -Name 'default' -AddressPrefix '10.0.0.0/24')
    $subnet = $vnet.Subnets[0]
}

$nsgName = "$VmName-nsg"
$nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $nsg) {
    Write-Host "Creating NSG '$nsgName' with inbound rules: $($InboundPorts -join ', ')" -ForegroundColor Cyan
    $nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $ResourceGroupName -Location $Location
}

$priority = 1000
foreach ($port in $InboundPorts) {
    $ruleName = "Allow-$port-Inbound"
    if (-not ($nsg.SecurityRules | Where-Object { $_.Name -eq $ruleName })) {
        $nsg | Add-AzNetworkSecurityRuleConfig `
            -Name $ruleName `
            -Description "Allow inbound on port $port" `
            -Access Allow `
            -Protocol Tcp `
            -Direction Inbound `
            -Priority $priority `
            -SourceAddressPrefix '*' `
            -SourcePortRange '*' `
            -DestinationAddressPrefix '*' `
            -DestinationPortRange $port | Out-Null
        $priority++
    }
}
$nsg | Set-AzNetworkSecurityGroup | Out-Null

$publicIp = $null
if ($AllocatePublicIp.IsPresent) {
    $publicIpName = "$VmName-pip"
    Write-Host "Creating public IP '$publicIpName'..." -ForegroundColor Cyan
    $publicIp = New-AzPublicIpAddress `
        -Name $publicIpName `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -AllocationMethod Static `
        -Sku Standard
}

$ipConfigParams = @{
    Name                       = "$VmName-ipconfig"
    Subnet                     = $subnet
    NetworkSecurityGroup       = $nsg
    PrivateIpAddressVersion    = 'IPv4'
}

if ($PrivateIpAddress) {
    $ipConfigParams['PrivateIpAddress'] = $PrivateIpAddress
    $ipConfigParams['PrivateIpAllocationMethod'] = 'Static'
} else {
    $ipConfigParams['PrivateIpAllocationMethod'] = 'Dynamic'
}

if ($publicIp) {
    $ipConfigParams['PublicIpAddress'] = $publicIp
}

$ipConfig = New-AzNetworkInterfaceIpConfig @ipConfigParams

Write-Host "Creating NIC '$VmName-nic'..." -ForegroundColor Cyan
$nic = New-AzNetworkInterface `
    -Name "$VmName-nic" `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -IpConfiguration $ipConfig

$cred = Get-Credential -Message 'Enter VM local admin credentials'

$tags = @{}
if ($PatchGroup) { $tags['PatchGroup'] = $PatchGroup }
if ($EnableBackup.IsPresent) { $tags['BackupEnabled'] = 'True' }
if ($StartStopSchedule) { $tags['StartStopSchedule'] = $StartStopSchedule }
if ($DomainToJoin) { $tags['DomainRequested'] = $DomainToJoin }

Write-Host "Deploying VM '$VmName' in '$ResourceGroupName' ($Location)..." -ForegroundColor Cyan

$vmParams = @{
    Name              = $VmName
    ResourceGroupName = $ResourceGroupName
    Location          = $Location
    Credential        = $cred
    Image             = $ImageUrn
    Size              = $VmSize
    NetworkInterfaceId = $nic.Id
    Tag               = $tags
    Verbose           = $true
}

if ($AvailabilitySetName) {
    $avSet = Get-AzAvailabilitySet -Name $AvailabilitySetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $avSet) {
        Write-Host "Creating availability set '$AvailabilitySetName'..." -ForegroundColor Cyan
        $avSet = New-AzAvailabilitySet `
            -Name $AvailabilitySetName `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -Sku Aligned `
            -PlatformFaultDomainCount 2 `
            -PlatformUpdateDomainCount 5
    }
    $vmParams['AvailabilitySetId'] = $avSet.Id
}

if ($OsDiskSizeGB -gt 0) {
    $vmParams['OsDiskSizeInGB'] = $OsDiskSizeGB
}

$vm = New-AzVm @vmParams

if ($DataDiskSizeGB -gt 0) {
    Write-Host "Adding data disk of size $DataDiskSizeGB GB..." -ForegroundColor Cyan
    $vmName = $VmName
    $vmRG = $ResourceGroupName
    $vmObj = Get-AzVM -Name $vmName -ResourceGroupName $vmRG
    $vmObj = Add-AzVMDataDisk -VM $vmObj -Name "$VmName-data1" -CreateOption Empty -DiskSizeInGB $DataDiskSizeGB -Lun 0
    Update-AzVM -VM $vmObj -ResourceGroupName $vmRG | Out-Null
}

if ($EnableDiagnosticLogs) {
    Write-Host "Enabling Boot Diagnostics (managed storage)..." -ForegroundColor Cyan
    Set-AzVMBootDiagnostic -ResourceGroupName $ResourceGroupName -VMName $VmName -Enable -ErrorAction SilentlyContinue | Out-Null
}

Write-Host "=== VM '$VmName' successfully created in resource group '$ResourceGroupName'. ===" -ForegroundColor Green
Write-Host "Note: Backup, Start/Stop automation, and domain join may still need to be wired into your standard Atmosera processes." -ForegroundColor Yellow

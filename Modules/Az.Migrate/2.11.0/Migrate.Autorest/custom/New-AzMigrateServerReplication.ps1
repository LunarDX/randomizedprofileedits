
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.Synopsis
Starts replication for the specified server.
.Description
The New-AzMigrateServerReplication cmdlet starts the replication for a particular discovered server in the Azure Migrate project.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/new-azmigrateserverreplication
#>
function New-AzMigrateServerReplication {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.IJob])]
    [CmdletBinding(DefaultParameterSetName = 'ByIdDefaultUser', PositionalBinding = $false)]
    param(
        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the machine ID of the discovered server to be migrated.
        ${MachineId},

        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202001.IVMwareMachine]
        # Specifies the discovered server to be migrated. The server object can be retrieved using the Get-AzMigrateServer cmdlet.
        ${InputObject},

        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.IVMwareCbtDiskInput[]]
        # Specifies the disks on the source server to be included for replication.
        ${DiskToInclude},

        [Parameter(Mandatory)]
        [ValidateSet("NoLicenseType" , "WindowsServer")]
        [ArgumentCompleter( { "NoLicenseType" , "WindowsServer" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit is applicable for the source server to be migrated.
        ${LicenseType},

        [Parameter()]
        [ValidateSet("NoLicenseType" , "PAYG" , "AHUB")]
        [ArgumentCompleter( { "NoLicenseType" , "PAYG" , "AHUB" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit for SQL Server is applicable for the server to be migrated.
        ${SqlServerLicenseType},

        [Parameter()]
        [ValidateSet( "NotSpecified", "NoLicenseType", "LinuxServer")]
        [ArgumentCompleter( { "NotSpecified", "NoLicenseType", "LinuxServer" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit is applicable for the source linux server to be migrated.
        ${LinuxLicenseType},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group id within the destination Azure subscription to which the server needs to be migrated.
        ${TargetResourceGroupId},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Virtual Network id within the destination Azure subscription to which the server needs to be migrated.
        ${TargetNetworkId},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Subnet name within the destination Virtual Network to which the server needs to be migrated.
        ${TargetSubnetName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Virtual Network id within the destination Azure subscription to which the server needs to be test migrated.
        ${TestNetworkId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Subnet name within the destination Virtual Network to which the server needs to be test migrated.
        ${TestSubnetName},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Mapping.
        ${ReplicationContainerMapping},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Account id.
        ${VMWarerunasaccountID},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the Azure VM to be created.
        ${TargetVMName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the SKU of the Azure VM to be created.
        ${TargetVMSize},

        [Parameter(ParameterSetName = 'ByIdDefaultUser')]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser')]
        [Parameter(ParameterSetName = 'ByIdPowerUser')]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser')]
        [ValidateSet("true" , "false")]
        [ArgumentCompleter( { "true" , "false" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if replication be auto-repaired in case change tracking is lost for the source server under replication.
        ${PerformAutoResync},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Availability Set to be used for VM creationSpecifies the Availability Set to be used for VM creation.
        ${TargetAvailabilitySet},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Availability Zone to be used for VM creation.
        ${TargetAvailabilityZone},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.IVMwareCbtEnableMigrationInputTargetVmtags]
        # Specifies the tag to be used for VM creation.
        ${VMTag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.IVMwareCbtEnableMigrationInputTargetNicTags]
        # Specifies the tag to be used for NIC creation.
        ${NicTag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.IVMwareCbtEnableMigrationInputTargetDiskTags]
        # Specifies the tag to be used for disk creation.
        ${DiskTag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Collections.Hashtable]
        # Specifies the tag to be used for Resource creation.
        ${Tag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the storage account to be used for boot diagnostics.
        ${TargetBootDiagnosticsStorageAccount},

        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [ValidateSet("Standard_LRS" , "Premium_LRS", "StandardSSD_LRS")]
        [ArgumentCompleter( { "Standard_LRS" , "Premium_LRS", "StandardSSD_LRS" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the type of disks to be used for the Azure VM.
        ${DiskType},
        
        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Operating System disk for the source server to be migrated.
        ${OSDiskID},

        [Parameter(ParameterSetName = 'ByIdDefaultUser')]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the disk encryption set to be used.
        ${DiskEncryptionSetID},
    
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # Azure Subscription ID.
        ${SubscriptionId},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Target Capacity Reservation Group Id within the destination Azure subscription.
        ${TargetCapacityReservationGroupId},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )
    
    process {
        $parameterSet = $PSCmdlet.ParameterSetName
        $HasRunAsAccountId = $PSBoundParameters.ContainsKey('VMWarerunasaccountID')
        $HasTargetAVSet = $PSBoundParameters.ContainsKey('TargetAvailabilitySet')
        $HasTargetAVZone = $PSBoundParameters.ContainsKey('TargetAvailabilityZone')
        $HasVMTag = $PSBoundParameters.ContainsKey('VMTag')
        $HasNicTag = $PSBoundParameters.ContainsKey('NicTag')
        $HasDiskTag = $PSBoundParameters.ContainsKey('DiskTag')
        $HasTag = $PSBoundParameters.ContainsKey('Tag')
        $HasSqlServerLicenseType = $PSBoundParameters.ContainsKey('SqlServerLicenseType')
        $HasLinuxLicenseType = $PSBoundParameters.ContainsKey('LinuxLicenseType')
        $HasTargetBDStorage = $PSBoundParameters.ContainsKey('TargetBootDiagnosticsStorageAccount')
        $HasResync = $PSBoundParameters.ContainsKey('PerformAutoResync')
        $HasDiskEncryptionSetID = $PSBoundParameters.ContainsKey('DiskEncryptionSetID')
        $HasTargetVMSize = $PSBoundParameters.ContainsKey('TargetVMSize')

        $null = $PSBoundParameters.Remove('ReplicationContainerMapping')
        $null = $PSBoundParameters.Remove('VMWarerunasaccountID')
        $null = $PSBoundParameters.Remove('TargetAvailabilitySet')
        $null = $PSBoundParameters.Remove('TargetAvailabilityZone')
        $null = $PSBoundParameters.Remove('VMTag')
        $null = $PSBoundParameters.Remove('NicTag')
        $null = $PSBoundParameters.Remove('DiskTag')
        $null = $PSBoundParameters.Remove('Tag')
        $null = $PSBoundParameters.Remove('TargetBootDiagnosticsStorageAccount')
        $null = $PSBoundParameters.Remove('MachineId')
        $null = $PSBoundParameters.Remove('DiskToInclude')
        $null = $PSBoundParameters.Remove('TargetResourceGroupId')
        $null = $PSBoundParameters.Remove('TargetNetworkId')
        $null = $PSBoundParameters.Remove('TargetSubnetName')
        $null = $PSBoundParameters.Remove('TestNetworkId')
        $null = $PSBoundParameters.Remove('TestSubnetName')
        $null = $PSBoundParameters.Remove('TargetVMName')
        $null = $PSBoundParameters.Remove('TargetVMSize')
        $null = $PSBoundParameters.Remove('TargetCapacityReservationGroupId')
        $null = $PSBoundParameters.Remove('PerformAutoResync')
        $null = $PSBoundParameters.Remove('DiskType')
        $null = $PSBoundParameters.Remove('OSDiskID')
        $null = $PSBoundParameters.Remove('SqlServerLicenseType')
        $null = $PSBoundParameters.Remove('LinuxLicenseType')
        $null = $PSBoundParameters.Remove('LicenseType')
        $null = $PSBoundParameters.Remove('DiskEncryptionSetID')

        $null = $PSBoundParameters.Remove('MachineId')
        $null = $PSBoundParameters.Remove('InputObject')

        $validLicenseSpellings = @{ 
            NoLicenseType = "NoLicenseType";
            WindowsServer = "WindowsServer"
        }
        $LicenseType = $validLicenseSpellings[$LicenseType]

        if ($parameterSet -match "DefaultUser") {
            $validDiskTypeSpellings = @{ 
                Standard_LRS    = "Standard_LRS";
                Premium_LRS     = "Premium_LRS";
                StandardSSD_LRS = "StandardSSD_LRS"
            }
            $DiskType = $validDiskTypeSpellings[$DiskType]
            
            if ($parameterSet -eq "ByInputObjectDefaultUser") {
                foreach ($onPremDisk in $InputObject.Disk) {
                    if ($onPremDisk.Uuid -eq $OSDiskID) {
                        $OSDiskID = $onPremDisk.Uuid
                        break
                    }
                }
            }
        }

        # Get the discovered machine Id.
        if (($parameterSet -match 'InputObject')) {
            $MachineId = $InputObject.Id
        }

        # Get the discovered machine object.
        $MachineIdArray = $MachineId.Split("/")
        $SiteType = $MachineIdArray[7]
        $SiteName = $MachineIdArray[8]
        $ResourceGroupName = $MachineIdArray[4]
        $MachineName = $MachineIdArray[10]

        $null = $PSBoundParameters.Add("Name", $MachineName)
        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("SiteName", $SiteName)
        $InputObject = Get-AzMigrateMachine @PSBoundParameters

        $null = $PSBoundParameters.Remove('Name')
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('SiteName')
        
        # Get the site to get project name.
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('SiteName', $SiteName)
        $siteObject = Az.Migrate\Get-AzMigrateSite @PSBoundParameters
        if ($siteObject -and ($siteObject.Count -ge 1)) {
            $ProjectName = $siteObject.DiscoverySolutionId.Split("/")[8]
        }
        else {
            throw "Site not found"
        }
            
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('SiteName')

        # Get the solution to get vault name.
        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("Name", "Servers-Migration-ServerMigration")
        $null = $PSBoundParameters.Add("MigrateProjectName", $ProjectName)
            
        $solution = Az.Migrate\Get-AzMigrateSolution @PSBoundParameters
        $VaultName = $solution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]
            
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove("Name")
        $null = $PSBoundParameters.Remove("MigrateProjectName")

        if ($SiteType -ne "VMwareSites") {
            throw "Provider not supported"
        }
           
        # This supports Multi-Vcenter feature.
        if (!$HasRunAsAccountId) {

            # Get the VCenter object.
            $vcenterId = $InputObject.VCenterId
            if ($null -eq $vcenterId){
                throw "Cannot find Vcenter ID in discovered machine."
            }

            $vCenterIdArray = $vcenterId.Split("/")
            $vCenterName = $vCenterIdArray[10] 
            $vCenterSite = $vCenterIdArray[8]
            $vCenterResourceGroupName = $vCenterIdArray[4]

            $null = $PSBoundParameters.Add("Name", $vCenterName)
            $null = $PSBoundParameters.Add("ResourceGroupName", $vCenterResourceGroupName)
            $null = $PSBoundParameters.Add("SiteName", $vCenterSite)

            $vCenter = Get-AzMigrateVCenter @PSBoundParameters

            $null = $PSBoundParameters.Remove('Name')
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('SiteName')

            # Get the run as account Id.
            $VMWarerunasaccountID = $vCenter.RunAsAccountId
            if ($VMWarerunasaccountID -eq "") {
                throw "Run As Account missing."
            } 
        }

        $policyName = "migrate" + $SiteName + "policy"
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $null = $PSBoundParameters.Add('PolicyName', $policyName)
        $policyObj = Az.Migrate\Get-AzMigrateReplicationPolicy @PSBoundParameters -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($policyObj -and ($policyObj.Count -ge 1)) {
            $PolicyId = $policyObj.Id
        }
        else {
            throw "The replication infrastructure is not initialized. Run the initialize-azmigratereplicationinfrastructure script again."
        }
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('ResourceName')
        $null = $PSBoundParameters.Remove('PolicyName')

        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $allFabrics = Az.Migrate\Get-AzMigrateReplicationFabric @PSBoundParameters
        $FabricName = ""
        if ($allFabrics -and ($allFabrics.length -gt 0)) {
            foreach ($fabric in $allFabrics) {
                if (($fabric.Property.CustomDetail.InstanceType -ceq "VMwareV2") -and ($fabric.Property.CustomDetail.VmwareSiteId.Split("/")[8] -ceq $SiteName)) {
                    $FabricName = $fabric.Name
                    break
                }
            }
        }
        if ($FabricName -eq "") {
            throw "Fabric not found for given resource group."
        }
                
        $null = $PSBoundParameters.Add('FabricName', $FabricName)
        $peContainers = Az.Migrate\Get-AzMigrateReplicationProtectionContainer @PSBoundParameters
        $ProtectionContainerName = ""
        if ($peContainers -and ($peContainers.length -gt 0)) {
            $ProtectionContainerName = $peContainers[0].Name
        }

        if ($ProtectionContainerName -eq "") {
            throw "Container not found for given resource group."
        }

        $mappingName = "containermapping"
        $null = $PSBoundParameters.Add('MappingName', $mappingName)
        $null = $PSBoundParameters.Add("ProtectionContainerName", $ProtectionContainerName)

        $mappingObject = Az.Migrate\Get-AzMigrateReplicationProtectionContainerMapping @PSBoundParameters -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($mappingObject -and ($mappingObject.Count -ge 1)) {
            $TargetRegion = $mappingObject.ProviderSpecificDetail.TargetLocation
        }
        else {
            throw "The replication infrastructure is not initialized. Run the initialize-azmigratereplicationinfrastructure script again."
        }
        $null = $PSBoundParameters.Remove('MappingName')

        # Validate sku size
        $hasAzComputeModule = $true
        try { Import-Module Az.Compute }catch { $hasAzComputeModule = $false }
        if ($hasAzComputeModule -and $HasTargetVMSize) {
            $null = $PSBoundParameters.Remove("ProtectionContainerName")
            $null = $PSBoundParameters.Remove("FabricName")
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('ResourceName')
            $null = $PSBoundParameters.Remove('SubscriptionId')
            $null = $PSBoundParameters.Add('Location', $TargetRegion)
            #Get-AzVMSku -Location is deprecated, replicate using Get-AzComputeResourceSKU and a where clause
            $allAvailableSkus = Get-AzComputeResourceSKU @PSBoundParameters| Where-Object { $_.ResourceType.Contains("virtualMachines") }
            if ($null -ne $allAvailableSkus) {
                $matchingComputeSku = $allAvailableSkus | Where-Object { $_.Name -eq $TargetVMSize }
                if ($null -ne $matchingComputeSku) {
                    $TargetVMSize = $matchingComputeSku.Name
                }
            }

            $null = $PSBoundParameters.Remove('Location')
            $null = $PSBoundParameters.Add("ProtectionContainerName", $ProtectionContainerName)
            $null = $PSBoundParameters.Add('FabricName', $FabricName)
            $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
            $null = $PSBoundParameters.Add('ResourceName', $VaultName)
            $null = $PSBoundParameters.Add('SubscriptionId', $SubscriptionId)
        }

        $HashCodeInput = $SiteName + $TargetRegion
        $Source = @"
using System;
public class HashFunctions
{
public static int hashForArtifact(String artifact)
{
        int hash = 0;
        int al = artifact.Length;
        int tl = 0;
        char[] ac = artifact.ToCharArray();
        while (tl < al)
        {
            hash = ((hash << 5) - hash) + ac[tl++] | 0;
        }
        return Math.Abs(hash);
}
}
"@
        Add-Type -TypeDefinition $Source -Language CSharp
        if ([string]::IsNullOrEmpty($mappingObject.ProviderSpecificDetail.KeyVaultUri)) {
             $LogStorageAccountID = $mappingObject.ProviderSpecificDetail.StorageAccountId
             $LogStorageAccountSas = $LogStorageAccountID.Split('/')[-1] + '-cacheSas'
        }
        else {
            $hash = [HashFunctions]::hashForArtifact($HashCodeInput)
            $LogStorageAccountID = "/subscriptions/" + $SubscriptionId + "/resourceGroups/" +
            $ResourceGroupName + "/providers/Microsoft.Storage/storageAccounts/migratelsa" + $hash
            $LogStorageAccountSas = "migratelsa" + $hash + '-cacheSas'
        }

        if (!$HasTargetBDStorage) {
            $TargetBootDiagnosticsStorageAccount = $LogStorageAccountID
        }

        # Storage accounts need to be in the same subscription as that of the VM.
        if (($null -ne $TargetBootDiagnosticsStorageAccount) -and ($TargetBootDiagnosticsStorageAccount.length -gt 1)) {
            $TargetBDSASubscriptionId = $TargetBootDiagnosticsStorageAccount.Split('/')[2]
            $TargetSubscriptionId = $TargetResourceGroupId.Split('/')[2]
            if ($TargetBDSASubscriptionId -ne $TargetSubscriptionId) {
                $TargetBootDiagnosticsStorageAccount = $null
            }
        }
            
        if (!$HasResync) {
            $PerformAutoResync = "true"
        }
        $validBooleanSpellings = @{ 
            true  = "true";
            false = "false"
        }
        $PerformAutoResync = $validBooleanSpellings[$PerformAutoResync]

        $null = $PSBoundParameters.Add("MigrationItemName", $MachineName)
        $null = $PSBoundParameters.Add("PolicyId", $PolicyId)

        $ProviderSpecificDetails = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.VMwareCbtEnableMigrationInput]::new()
        $ProviderSpecificDetails.DataMoverRunAsAccountId = $VMWarerunasaccountID
        $ProviderSpecificDetails.SnapshotRunAsAccountId = $VMWarerunasaccountID
        $ProviderSpecificDetails.InstanceType = 'VMwareCbt'
        $ProviderSpecificDetails.LicenseType = $LicenseType
        $ProviderSpecificDetails.PerformAutoResync = $PerformAutoResync
        if ($HasTargetAVSet) {
            $ProviderSpecificDetails.TargetAvailabilitySetId = $TargetAvailabilitySet
        }
        if ($HasTargetAVZone) {
            $ProviderSpecificDetails.TargetAvailabilityZone = $TargetAvailabilityZone
        }

        if ($HasSqlServerLicenseType) {
            $validSqlLicenseSpellings = @{ 
                NoLicenseType = "NoLicenseType";
                PAYG          = "PAYG";
                AHUB          = "AHUB"
            }
            $SqlServerLicenseType = $validSqlLicenseSpellings[$SqlServerLicenseType]
            $ProviderSpecificDetails.SqlServerLicenseType = $SqlServerLicenseType
        }

        if ($HasLinuxLicenseType) {
            $validLinuxLicenseSpellings = @{ 
                NotSpecified  = "NotSpecified";
                NoLicenseType = "NoLicenseType";
                LinuxServer   = "LinuxServer";
            }
            $LinuxLicenseType = $validLinuxLicenseSpellings[$LinuxLicenseType]
            $ProviderSpecificDetails.LinuxLicenseType = $LinuxLicenseType
        }

        $UserProvidedTags = $null
        if ($HasTag -And $Tag) {
            $UserProvidedTags += @{"Tag" = $Tag }
        }

        if ($HasVMTag -And $VMTag) {
            $UserProvidedTags += @{"VMTag" = $VMTag }
        }

        if ($HasNicTag -And $NicTag) {
            $UserProvidedTags += @{"NicTag" = $NicTag }
        }

        if ($HasDiskTag -And $DiskTag) {
            $UserProvidedTags += @{"DiskTag" = $DiskTag }
        }

        foreach ($tagtype in $UserProvidedTags.Keys) {
            $IllegalCharKey = New-Object Collections.Generic.List[String]
            $ExceededLengthKey = New-Object Collections.Generic.List[String]
            $ExceededLengthValue = New-Object Collections.Generic.List[String]
            $ResourceTag = $($UserProvidedTags.Item($tagtype))

            if ($ResourceTag.Count -gt 50) {
                throw "InvalidTags : Too many tags specified. Requested tag count - '$($ResourceTag.Count)'. Maximum number of tags allowed - '50'."
            }

            foreach ($key in $ResourceTag.Keys) {
                if ($key.length -eq 0) {
                    throw "InvalidTagName : The tag name must be non-null, non-empty and non-whitespace only. Please provide an actual value."
                }

                if ($key.length -gt 512) {
                    $ExceededLengthKey.add($key)
                }

                if ($key -match "[<>%&\?/.]") {
                    $IllegalCharKey.add($key)
                }

                if ($($ResourceTag.Item($key)).length -gt 256) {
                    $ExceededLengthValue.add($($ResourceTag.Item($key)))
                }
            }

            if ($IllegalCharKey.Count -gt 0) {
                throw "InvalidTagNameCharacters : The tag names '$($IllegalCharKey -join ', ')' have reserved characters '<,>,%,&,\,?,/' or control characters."
            }

            if ($ExceededLengthKey.Count -gt 0) {
                throw "InvalidTagName : Tag key too large. Following tag name '$($ExceededLengthKey -join ', ')' exceeded the maximum length. Maximum allowed length for tag name - '512' characters."
            }

            if ($ExceededLengthValue.Count -gt 0) {
                throw "InvalidTagValueLength : Tag value too large. Following tag value '$($ExceededLengthValue -join ', ')' exceeded the maximum length. Maximum allowed length for tag value - '256' characters."
            }

            if ($tagtype -eq "Tag" -or $tagtype -eq "DiskTag") {
                $ProviderSpecificDetails.SeedDiskTag = $ResourceTag
                $ProviderSpecificDetails.TargetDiskTag = $ResourceTag
            }

            if ($tagtype -eq "Tag" -or $tagtype -eq "NicTag") {
                $ProviderSpecificDetails.TargetNicTag = $ResourceTag
            }

            if ($tagtype -eq "Tag" -or $tagtype -eq "VMTag") {
                $ProviderSpecificDetails.TargetVmTag = $ResourceTag
            }
        }

        $ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId = $TargetBootDiagnosticsStorageAccount
        $ProviderSpecificDetails.TargetNetworkId = $TargetNetworkId
        $ProviderSpecificDetails.TargetResourceGroupId = $TargetResourceGroupId
        $ProviderSpecificDetails.TargetSubnetName = $TargetSubnetName
        $ProviderSpecificDetails.TestNetworkId = $TestNetworkId
        $ProviderSpecificDetails.TestSubnetName = $TestSubnetName
        $ProviderSpecificDetails.TargetCapacityReservationGroupId = $TargetCapacityReservationGroupId

        if ($TargetVMName.length -gt 64 -or $TargetVMName.length -eq 0) {
            throw "The target virtual machine name must be between 1 and 64 characters long."
        }

        Import-Module Az.Resources
        $vmId = $ProviderSpecificDetails.TargetResourceGroupId + "/providers/Microsoft.Compute/virtualMachines/" + $TargetVMName
        $VMNamePresentinRg = Get-AzResource -ResourceId $vmId -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($VMNamePresentinRg) {
            throw "The target virtual machine name must be unique in the target resource group."
        }

        if ($TargetVMName -notmatch "^[^_\W][a-zA-Z0-9\-]{0,63}(?<![-._])$") {
            throw "The target virtual machine name must begin with a letter or number, and can contain only letters, numbers, or hyphens(-). The names cannot contain special characters \/""[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'."
        }

        $ProviderSpecificDetails.TargetVMName = $TargetVMName
        if ($HasTargetVMSize) { $ProviderSpecificDetails.TargetVMSize = $TargetVMSize }
        $ProviderSpecificDetails.VmwareMachineId = $MachineId
        $uniqueDiskUuids = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::InvariantCultureIgnoreCase)

        if ($parameterSet -match 'DefaultUser') {
            [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.IVMwareCbtDiskInput[]]$DiskToInclude = @()
            foreach ($onPremDisk in $InputObject.Disk) {
                if ($onPremDisk.Uuid -ne $OSDiskID) {
                    $DiskObject = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.VMwareCbtDiskInput]::new()
                    $DiskObject.DiskId = $onPremDisk.Uuid
                    $DiskObject.DiskType = "Standard_LRS"
                    $DiskObject.IsOSDisk = "false"
                    $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
                    $DiskObject.LogStorageAccountId = $LogStorageAccountID
                    if ($HasDiskEncryptionSetID) {
                        $DiskObject.DiskEncryptionSetId = $DiskEncryptionSetID
                    }
                    $DiskToInclude += $DiskObject
                }
            }
            $DiskObject = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.VMwareCbtDiskInput]::new()
            $DiskObject.DiskId = $OSDiskID
            $DiskObject.DiskType = $DiskType
            $DiskObject.IsOSDisk = "true"
            $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
            $DiskObject.LogStorageAccountId = $LogStorageAccountID
            if ($HasDiskEncryptionSetID) {
                $DiskObject.DiskEncryptionSetId = $DiskEncryptionSetID
            }

            $DiskToInclude += $DiskObject
            $ProviderSpecificDetails.DisksToInclude = $DiskToInclude
        }
        else {
            foreach ($DiskObject in $DiskToInclude) {
                $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
                $DiskObject.LogStorageAccountId = $LogStorageAccountID
            }
            $ProviderSpecificDetails.DisksToInclude = $DiskToInclude
        }


        # Check for duplicate disk UUID in user input/discovered VM and Premium V2 disk validations.
        foreach ($disk in $ProviderSpecificDetails.DisksToInclude)
        {
            if ($uniqueDiskUuids.Contains($disk.DiskId)) {
                throw "The disk uuid '$($disk.DiskId)' is already taken."
            }

            if (-not $HasTargetAVZone -and $disk.DiskType -eq "PremiumV2_LRS") {
                throw "The Availability zone has not been provided for the Premium SSD V2 disk."
            }

            $res = $uniqueDiskUuids.Add($disk.DiskId)
        }

        $null = $PSBoundParameters.add('ProviderSpecificDetail', $ProviderSpecificDetails)
        $null = $PSBoundParameters.Add('NoWait', $true)
        $output = Az.Migrate.internal\New-AzMigrateReplicationMigrationItem @PSBoundParameters
        $JobName = $output.Target.Split("/")[12].Split("?")[0]
        $null = $PSBoundParameters.Remove('NoWait')
        $null = $PSBoundParameters.Remove('ProviderSpecificDetail')
        $null = $PSBoundParameters.Remove("ResourceGroupName")
        $null = $PSBoundParameters.Remove("ResourceName")
        $null = $PSBoundParameters.Remove("FabricName")
        $null = $PSBoundParameters.Remove("MigrationItemName")
        $null = $PSBoundParameters.Remove("ProtectionContainerName")
        $null = $PSBoundParameters.Remove("PolicyId")

        $null = $PSBoundParameters.Add('JobName', $JobName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        
        return Az.Migrate.internal\Get-AzMigrateReplicationJob @PSBoundParameters
        
    }

}   

# SIG # Begin signature block
# MIIoVAYJKoZIhvcNAQcCoIIoRTCCKEECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCABhlfRn+aLF+Q7
# OHH0Pkor1UHMeFzQx4Cx0aLJLm4QBaCCDYUwggYDMIID66ADAgECAhMzAAAEhJji
# EuB4ozFdAAAAAASEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjUwNjE5MTgyMTM1WhcNMjYwNjE3MTgyMTM1WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDtekqMKDnzfsyc1T1QpHfFtr+rkir8ldzLPKmMXbRDouVXAsvBfd6E82tPj4Yz
# aSluGDQoX3NpMKooKeVFjjNRq37yyT/h1QTLMB8dpmsZ/70UM+U/sYxvt1PWWxLj
# MNIXqzB8PjG6i7H2YFgk4YOhfGSekvnzW13dLAtfjD0wiwREPvCNlilRz7XoFde5
# KO01eFiWeteh48qUOqUaAkIznC4XB3sFd1LWUmupXHK05QfJSmnei9qZJBYTt8Zh
# ArGDh7nQn+Y1jOA3oBiCUJ4n1CMaWdDhrgdMuu026oWAbfC3prqkUn8LWp28H+2S
# LetNG5KQZZwvy3Zcn7+PQGl5AgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUBN/0b6Fh6nMdE4FAxYG9kWCpbYUw
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwNTM2MjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AGLQps1XU4RTcoDIDLP6QG3NnRE3p/WSMp61Cs8Z+JUv3xJWGtBzYmCINmHVFv6i
# 8pYF/e79FNK6P1oKjduxqHSicBdg8Mj0k8kDFA/0eU26bPBRQUIaiWrhsDOrXWdL
# m7Zmu516oQoUWcINs4jBfjDEVV4bmgQYfe+4/MUJwQJ9h6mfE+kcCP4HlP4ChIQB
# UHoSymakcTBvZw+Qst7sbdt5KnQKkSEN01CzPG1awClCI6zLKf/vKIwnqHw/+Wvc
# Ar7gwKlWNmLwTNi807r9rWsXQep1Q8YMkIuGmZ0a1qCd3GuOkSRznz2/0ojeZVYh
# ZyohCQi1Bs+xfRkv/fy0HfV3mNyO22dFUvHzBZgqE5FbGjmUnrSr1x8lCrK+s4A+
# bOGp2IejOphWoZEPGOco/HEznZ5Lk6w6W+E2Jy3PHoFE0Y8TtkSE4/80Y2lBJhLj
# 27d8ueJ8IdQhSpL/WzTjjnuYH7Dx5o9pWdIGSaFNYuSqOYxrVW7N4AEQVRDZeqDc
# fqPG3O6r5SNsxXbd71DCIQURtUKss53ON+vrlV0rjiKBIdwvMNLQ9zK0jy77owDy
# XXoYkQxakN2uFIBO1UNAvCYXjs4rw3SRmBX9qiZ5ENxcn/pLMkiyb68QdwHUXz+1
# fI6ea3/jjpNPz6Dlc/RMcXIWeMMkhup/XEbwu73U+uz/MIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGiUwghohAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAASEmOIS4HijMV0AAAAA
# BIQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIGvy
# OJtNzL67YpIjS8oNjKpDAPoO3DIWbfnb6sJC8dWEMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAODLKdG/lOIjClSgVJ7Ba2a8xuah4FEEgkiDT
# k+tfmoXl+qMEMYMloSIBhjwGbyLB4FghDsCd3xRi/TpP2zeBtMyAiT5B2z28fkyb
# mPIhIN9kbSzVe6y+6tQkXm2kFDoYytoj3RnG8YFi/iE1kN2b+dQZLJgsf3ioj2jv
# FmRkUFbDtHbAi5E+N3gDJI6rcXd5Zw9lPIqSHtQ/R2XQb/uTon4zRz4GSiFNn4eE
# 8Fn082VKQApHW5U4dNNGsW87aJwI9PxMuBpXcqUkqiEkUEWCEFdZ+osnxjBTEw4W
# gia4NX+antg4PdCtuJQb8WPRkx5EdhOxaYwf7AZir2Lfo0XFYKGCF68wgherBgor
# BgEEAYI3AwMBMYIXmzCCF5cGCSqGSIb3DQEHAqCCF4gwgheEAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCBvHGTsKbk8a95LaejSf7P0n1iBgkqt+Mnc
# nGfrOor5mwIGaULoFOwRGBMyMDI2MDExMDAxMTUxMy4yODRaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjoyRDFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEf0wggcoMIIFEKADAgECAhMzAAACEtEI
# BjzKGE+qAAEAAAISMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI1MDgxNDE4NDgxNVoXDTI2MTExMzE4NDgxNVowgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjJEMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# r0zToDkpWQtsZekS0cV0quDdKSTGkovvBaZH0OAIEi0O3CcO77JiX8c4Epq9uibH
# VZZ1W/LoufE172vkRXO+QYNtWWorECJ2AcZQ10bpAltkhZNiXlVJ8L3QzhKgrXrm
# Mkm2J+/g81U23JPcO4wXHEftonT3wpd//936rjmwxMm7NkbsygbJf+4AVBMNr4aM
# PQhBd76od0KMB6WrvyEGOOU0893OFufS5EDey4n44WgaxJE0Vnv3/OOvuOw5Kp1K
# PqjjYJ+L9ywLuBMtcDfLpNQO/h1eFEoMrbiEM67TOfNlXfxbDz4MlsYvLioxgd2X
# zey1QxrV1+i+JyVDJMiSe9gKOuzpiQQFE19DUPgsidyjLTzXEhSVLBlRor0eCVf7
# gC6Rfk8NY3rO2sggOL79vU5FuDKTh/sIOtcUHeHC42jBGB+tfdKC1KOBR+UlN9aO
# zg8mpUNI2FgqQvirVP9ppbeMUfvp2wA9voyTiRWvDgzCxo8xlJ1nscYTHIQrmkF9
# j/Ca0IDmt8fvOn64nnlJOGUYZYHMC1l0xtgkYTE1ESUqqkawKk7iqbxdnLyycS+d
# R+zaxPudMDLrQFz8lgfy9obk0D8HC2dzhWpYNn5hdkoPEzgCqQUOp8v3Qj/sd4an
# yupe5KoCkjABOP3yhSQ4W9Z+DrJnhM/rbsXC7oTv26cCAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBRSBblSxb5cYKYOwvd/VfoXOfu33jAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAXnSAkmX79Rc7lxS1wOozXJ7V0ou5DntVcOJplIkDjvEN8BIQph4U+gSO
# LZuVReP/z9YdUiUkcPwL1PM245/kEX1EegpxNc8HDA6hKCHg0ALNEcuxnGOlgKLo
# kXfUer1D5hiW8PABM9R+neiteTgPaaRlJFvGTYvotc0uqGiES5hMQhL8RNFhpS9R
# cIWHtnQGEnrdOUvCAhs4FeViawcmLTKv+1870c/MeTHi0QDdeR+7/Wg4qhkJ2k1i
# EHJdmYf8rIV0NRBZcdRTTdHee35SXP5neNCfAkjDIuZycRud6jzPLCNLiNYzGXBs
# wzJygj4EeSORT7wMvaFuKeRAXoXC3wwYvgIsI1zn3DGY625Y+yZSi8UNSNHuri36
# Zv9a+Q4vJwDpYK36S0TB2pf7xLiiH32nk7YK73Rg98W6fZ2INuzYzZ7Ghgvfffkj
# 4EUXg1E0EffY1pEqkbpDTP7h/DBqtzoPXsyw2MUh+7yvWcq2BGZSuca6CY6X4ioM
# uc5PWpsmvOOli7ARNA7Ab8kKdCc2gNDLacglsweZEc9/VQB6hls/b6Kk32nkwuHE
# xKlaeoSVrKB5U9xlp1+c8J/7GJj4Rw7AiQ8tcp+WmfyD8KxX2QlKbDi4SUjnglv4
# 617R8+a/cDWJyaMt8279Wn7f2yMedN7kfGIQ5SZj66RdhdlZOq8wggdxMIIFWaAD
# AgECAhMzAAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3Nv
# ZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIy
# MjVaFw0zMDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5
# vQ7VgtP97pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64
# NmeFRiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhu
# je3XD9gmU3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl
# 3GoPz130/o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPg
# yY9+tVSP3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I
# 5JasAUq7vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2
# ci/bfV+AutuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/
# TNuvXsLz1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy
# 16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y
# 1BzFa/ZcUlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6H
# XtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMB
# AAEwIwYJKwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQW
# BBSfpxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30B
# ATBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
# L0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYB
# BAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMB
# Af8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBL
# oEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggr
# BgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNS
# b29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1Vffwq
# reEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27
# DzHkwo/7bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pv
# vinLbtg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9Ak
# vUCgvxm2EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWK
# NsIdw2FzLixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2
# kQH2zsZ0/fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+
# c23Kjgm9swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep
# 8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+Dvk
# txW/tM4+pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1Zyvg
# DbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/
# 2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIDWDCCAkACAQEwggEBoYHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjoyRDFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUA5VHBr4h00EN7
# jUdQ33SE+qbk/8CggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAO0Lt+0wIhgPMjAyNjAxMDkxNzIyNTNaGA8yMDI2
# MDExMDE3MjI1M1owdjA8BgorBgEEAYRZCgQBMS4wLDAKAgUA7Qu37QIBADAJAgEA
# AgFWAgH/MAcCAQACAhM2MAoCBQDtDQltAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwG
# CisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEL
# BQADggEBAE/fArI71KN3TjdFfiRuyV9uyZv4ncclkbP4yhBABU2/o97v3f6yqyrU
# v8jik/WMU5FXRdHxTmN5Kx3zuhD25idmjyF1ByYm+nhh5jYKAG0+CqQfvL6P2922
# of1XwXlxhduDZ8XeYpIOVADittZMjGfYQdWH+lLK0brvPqmxn8TY2BjR/rOomDtY
# 1q7h50YJs1OnZ02y3sJZ8G1nlLFdfPvKzVswz49AmgZ70YRDOeK6sEti9VSZDQU8
# 0XpkqVNpjMpHcLiDDVeS4/i45ZFfr9+bsQNVgprbnGqxI3baYcJ0XaPZafVmREvM
# SLqpMTWQZL+b+8c88I4yUdJ46LS5J/8xggQNMIIECQIBATCBkzB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAhLRCAY8yhhPqgABAAACEjANBglghkgB
# ZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3
# DQEJBDEiBCA+Vu/WB4igkVSbR8Y9oDA37XiazuneOLsg44LxH5EtqzCB+gYLKoZI
# hvcNAQkQAi8xgeowgecwgeQwgb0EIHP5fka87taeCScfgFl5hT4HMEvUnLmgnzBW
# VM0jF9iDMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMA
# AAIS0QgGPMoYT6oAAQAAAhIwIgQgf2cVNij3tWGz0yRR+NHPR9l4ldINKNC6tXk6
# KVXuGm4wDQYJKoZIhvcNAQELBQAEggIAJV9GbrMVe7l0YYSV7SxaBJxea99/YIwB
# dWYAWqPjMBJz/ZfntlNOV3qpbP7qvKTqo4jyKCwE72wJ/pyq8bCbhDX7+EMcFaU5
# j6jhyKxniuUykWKZvui7iiUrUjDqjLE3PhJQXyWIikk2k7vrs+5zey+io2ariiGZ
# V+7I3+5mkT0gvZaBnMsdTIeCKL3BwKA4GsRxYmVmA/2x9t8Q4fe6CkOA5XDGwWRV
# yWGCMjdvyAd0JqmOS8/GHaWrUD7+Q6MtmtMHJOWuoDd8HzR8qexvauUMD566cFkr
# 9kjGunpZ1r9MAwe8uc3RbK8oqBkPmTawq3X6WZ0ksP15sU+lFs+8utll+2sqThIA
# KJoDpQN1oAvzFZ+o4RdgYFOxOabVnNSVDC8xPr7oAu+UZMxpdkBiKk9qwarGQQ5f
# DFiidK6dqT5sdhwQxTU2Ls2L4keUh22Hc8TB8s45T9IIaXXiSRW8mFmKCakrLa7L
# o79nouCZV60p0hM6jvAlDLw/dhV7ivVR/8jpLutBuono9Ydyc/WuqVSZrgsbsgNB
# NgAtcqTCNWDsLBh/HxUk4oPTddt0zQaFsSKWAiQgLavQdggq6AOJOhNtSTB4vIRM
# 3KktTGlhalJWYq3e7M0Ho8cPSgM8BnddhC3US02r/dTRpVe10UtBGK1iBeN8jfL4
# 7xQi6RtozBQ=
# SIG # End signature block

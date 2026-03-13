
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
The New-AzMigrateLocalServerReplication cmdlet starts the replication for a particular discovered server in the Azure Migrate project.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/new-azmigratelocalserverreplication
#>
function New-AzMigrateLocalServerReplication {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.PreviewMessageAttribute("This cmdlet is based on a preview API version and may experience breaking changes in future releases.")]
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.IJobModel])]
    [CmdletBinding(DefaultParameterSetName = 'ByIdDefaultUser', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the machine ARM ID of the discovered server to be migrated.
        ${MachineId}, 

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the storage path ARM ID where the VMs will be stored.
        ${TargetStoragePathId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Int32]
        # Specifies the number of CPU cores.
        ${TargetVMCPUCore},

        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the logical network ARM ID that the VMs will use. 
        ${TargetVirtualSwitchId},

        [Parameter(ParameterSetName = 'ByIdDefaultUser')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the test logical network ARM ID that the VMs will use. 
        ${TargetTestVirtualSwitchId},

        [Parameter()]
        [ValidateSet("true" , "false")]
        [ArgumentCompleter( { "true" , "false" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if RAM is dynamic or not. 
        ${IsDynamicMemoryEnabled},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Int64]
        # Specifies the target RAM size in MB. 
        ${TargetVMRam},

        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.AzLocalDiskInput[]]
        # Specifies the disks on the source server to be included for replication.
        ${DiskToInclude},

        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.AzLocalNicInput[]]
        # Specifies the NICs on the source server to be included for replication.
        ${NicToInclude},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the target resource group ARM ID where the migrated VM resources will reside.
        ${TargetResourceGroupId},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the VM to be created.
        ${TargetVMName},

        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the operating system disk for the source server to be migrated.
        ${OSDiskID},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the source appliance name for the AzLocal scenario.
        ${SourceApplianceName},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the target appliance name for the AzLocal scenario.
        ${TargetApplianceName},
    
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
        $helperPath = [System.IO.Path]::Combine($PSScriptRoot, "Helper", "AzLocalCommonSettings.ps1")
        Import-Module $helperPath
        $helperPath = [System.IO.Path]::Combine($PSScriptRoot, "Helper", "AzLocalCommonHelper.ps1")
        Import-Module $helperPath

        CheckResourceGraphModuleDependency
        CheckResourcesModuleDependency

        $HasMachineId = $PSBoundParameters.ContainsKey('MachineId')
        $HasTargetStoragePathId = $PSBoundParameters.ContainsKey('TargetStoragePathId')
        $HasTargetResourceGroupId = $PSBoundParameters.ContainsKey('TargetResourceGroupId')
        $HasTargetVMCPUCore = $PSBoundParameters.ContainsKey('TargetVMCPUCore')
        $HasIsDynamicMemoryEnabled = $PSBoundParameters.ContainsKey('IsDynamicMemoryEnabled')
        if ($HasIsDynamicMemoryEnabled) {
            $isDynamicRamEnabled = [System.Convert]::ToBoolean($IsDynamicMemoryEnabled)
        }
        $HasTargetVMRam = $PSBoundParameters.ContainsKey('TargetVMRam')
        $HasTargetVirtualSwitchId = $PSBoundParameters.ContainsKey('TargetVirtualSwitchId')
        $HasTargetTestVirtualSwitchId = $PSBoundParameters.ContainsKey('TargetTestVirtualSwitchId')

        $parameterSet = $PSCmdlet.ParameterSetName

        # Remove initial command parameters
        $null = $PSBoundParameters.Remove('MachineId')
        $null = $PSBoundParameters.Remove('TargetStoragePathId')
        $null = $PSBoundParameters.Remove('TargetVMCPUCore')
        $null = $PSBoundParameters.Remove('TargetVirtualSwitchId')
        $null = $PSBoundParameters.Remove('TargetTestVirtualSwitchId')
        $null = $PSBoundParameters.Remove('IsDynamicMemoryEnabled')
        $null = $PSBoundParameters.Remove('TargetVMRam')
        $null = $PSBoundParameters.Remove('DiskToInclude')
        $null = $PSBoundParameters.Remove('NicToInclude')
        $null = $PSBoundParameters.Remove('TargetResourceGroupId')
        $null = $PSBoundParameters.Remove('TargetVMName')
        $null = $PSBoundParameters.Remove('OSDiskID')
        $null = $PSBoundParameters.Remove('SourceApplianceName')
        $null = $PSBoundParameters.Remove('TargetApplianceName')

        # Set common ErrorVariable and ErrorAction for get behaviors
        $null = $PSBoundParameters.Add('ErrorVariable', 'notPresent')
        $null = $PSBoundParameters.Add('ErrorAction', 'SilentlyContinue')

        # Validate ARM ID format from inputs
        if ($HasMachineId -and !(Test-AzureResourceIdFormat -Data $MachineId -Format $IdFormats.MachineArmIdTemplate))
        {
            throw New-InvalidResourceIdProvidedException `
                -ResourceId $MachineId `
                -ResourceType "DiscoveredMachine" `
                -Format $IdFormats.MachineArmIdTemplate
        }

        if ($HasTargetStoragePathId -and !(Test-AzureResourceIdFormat -Data $TargetStoragePathId -Format $IdFormats.StoragePathArmIdTemplate)) {
            throw New-InvalidResourceIdProvidedException `
                -ResourceId $TargetStoragePathId `
                -ResourceType "StorageContainer" `
                -Format $IdFormats.StoragePathArmIdTemplate
        }

        if ($HasTargetResourceGroupId -and !(Test-AzureResourceIdFormat -Data $TargetResourceGroupId -Format $IdFormats.ResourceGroupArmIdTemplate)) {
            throw New-InvalidResourceIdProvidedException `
                -ResourceId $TargetResourceGroupId `
                -ResourceType "ResourceGroup" `
                -Format $IdFormats.ResourceGroupArmIdTemplate
        }

        if ($HasTargetVirtualSwitchId -and !(Test-AzureResourceIdFormat -Data $TargetVirtualSwitchId -Format $IdFormats.LogicalNetworkArmIdTemplate)) {
            throw New-InvalidResourceIdProvidedException `
                -ResourceId $TargetVirtualSwitchId `
                -ResourceType "LogicalNetwork" `
                -Format $IdFormats.LogicalNetworkArmIdTemplate
        }

        if ($HasTargetTestVirtualSwitchId -and !(Test-AzureResourceIdFormat -Data $TargetTestVirtualSwitchId -Format $IdFormats.LogicalNetworkArmIdTemplate)) {
            throw New-InvalidResourceIdProvidedException `
                -ResourceId $TargetTestVirtualSwitchId `
                -ResourceType "LogicalNetwork" `
                -Format $IdFormats.LogicalNetworkArmIdTemplate
        }

        # $MachineId is in the format of
        # "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.OffAzure/{2}/{3}/machines/{4}"
        $MachineIdArray = $MachineId.Split("/")
        $ResourceGroupName = $MachineIdArray[4] # {1}
        $SiteType = $MachineIdArray[7] # {2}
        $SiteName = $MachineIdArray[8] # {3}
        $MachineName = $MachineIdArray[10] # {4}

        # Get the source site and the discovered machine
        if ($SiteType -eq $SiteTypes.HyperVSites) {
            $instanceType = $AzLocalInstanceTypes.HyperVToAzLocal

            # Get Hyper-V site with ResourceGroupName, SiteName
            $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
            $null = $PSBoundParameters.Add('SiteName', $SiteName)
            $siteObject = Az.Migrate.Internal\Get-AzMigrateHyperVSite @PSBoundParameters
            if ($null -eq $siteObject)
            {
                throw New-AzMigrateSiteNotFoundException `
                    -Name $SiteName `
                    -ResourceGroupName $ResourceGroupName `
                    -SiteType $SiteType
            }

            # Get Hyper-V machine with ResourceGroupName, SiteName, MachineName
            $null = $PSBoundParameters.Add('MachineName', $MachineName)
            $machine = Az.Migrate.Internal\Get-AzMigrateHyperVMachine @PSBoundParameters
            if ($null -eq $machine)
            {
                throw New-AzMigrateDiscoveredMachineNotFoundException `
                    -Name $MachineName `
                    -ResourceGroupName $ResourceGroupName `
                    -SiteName $SiteName
            }
            $null = $PSBoundParameters.Remove('MachineName')

            # Get RunAsAccount
            if (![string]::IsNullOrEmpty($machine.HostId))
            {
                # machine is on a single Hyper-V host
                $hostIdArray = $machine.HostId.Split("/")
                if ($hostIdArray.Length -lt 11) {
                    throw "Invalid Hyper-V Host ARM ID '$($machine.HostId)'"
                }

                $hostResourceGroupName = $hostIdArray[4]
                $hostSiteName = $hostIdArray[8]
                $hostName = $hostIdArray[10]

                # Get Hyper-V host with ResourceGroupName, SiteName, HostName
                $null = $PSBoundParameters.Add('HostName', $hostName)
                $hyperVHost = Az.Migrate.Internal\Get-AzMigrateHyperVHost @PSBoundParameters
                if ($null -eq $hyperVHost)
                {
                    throw New-OffAzureResourceNotFoundException `
                        -Scenario "HyperV" `
                        -Type "Host" `
                        -Name $hostName `
                        -ResourceGroupName $hostResourceGroupName `
                        -SiteName $hostSiteName
                }
                $null = $PSBoundParameters.Remove('HostName')
                
                $runAsAccountId = $hyperVHost.RunAsAccountId
            }
            elseif(![string]::IsNullOrEmpty($machine.ClusterId))
            {
                # machine is on a Hyper-V cluster
                $clusterIdArray = $machine.ClusterId.Split("/")
                if ($clusterIdArray.Length -lt 11) {
                    throw "Invalid Hyper-V Cluster ARM ID '$($machine.ClusterId)'"
                }

                $clusterResourceGroupName = $clusterIdArray[4]
                $clusterSiteName = $clusterIdArray[8]
                $clusterName = $clusterIdArray[10]

                # Get Hyper-V cluster with ResourceGroupName, SiteName, ClusterName
                $null = $PSBoundParameters.Add('ClusterName', $clusterName)
                $hyperVCluster = Az.Migrate.Internal\Get-AzMigrateHyperVCluster @PSBoundParameters
                if ($null -eq $hyperVCluster)
                {
                    throw throw New-OffAzureResourceNotFoundException `
                        -Scenario "HyperV" `
                        -Type "Cluster" `
                        -Name $clusterName `
                        -ResourceGroupName $clusterResourceGroupName `
                        -SiteName $clusterSiteName
                }
                $null = $PSBoundParameters.Remove('ClusterName')

                $runAsAccountId = $hyperVCluster.RunAsAccountId
            }
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites)
        {
            $instanceType = $AzLocalInstanceTypes.VMwareToAzLocal

            # Get VMware site with ResourceGroupName, SiteName
            $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
            $null = $PSBoundParameters.Add('SiteName', $SiteName)
            $siteObject = Az.Migrate.private\Get-AzMigrateSite_Get @PSBoundParameters
            if ($null -eq $siteObject)
            {
                throw New-AzMigrateSiteNotFoundException `
                    -Name $SiteName `
                    -ResourceGroupName $ResourceGroupName `
                    -SiteType $SiteType
            }

            # Get VMware machine with ResourceGroupName, SiteName, MachineName
            $null = $PSBoundParameters.Add('MachineName', $MachineName)
            $machine = Az.Migrate.Internal\Get-AzMigrateMachine @PSBoundParameters
            if ($null -eq $machine)
            {
                throw New-AzMigrateDiscoveredMachineNotFoundException `
                    -Name $MachineName `
                    -ResourceGroupName $ResourceGroupName `
                    -SiteName $SiteName
            }
            $null = $PSBoundParameters.Remove('MachineName')

            # Get RunAsAccount
            if (![string]::IsNullOrEmpty($machine.VCenterId))
            {
                # machine is on a single vCenter
                $vCenterIdArray = $machine.VCenterId.Split("/")
                if ($vCenterIdArray.Length -lt 11) {
                    throw "Invalid VMware vCenter ARM ID '$($machine.VCenterId)'"
                }

                $vCenterResourceGroupName = $vCenterIdArray[4]
                $vCenterSiteName = $vCenterIdArray[8]
                $vCenterName = $vCenterIdArray[10]

                # Get VMware vCenter with ResourceGroupName, SiteName, Name
                $null = $PSBoundParameters.Add('Name', $vCenterName)
                $vmwareVCenter = Az.Migrate.Internal\Get-AzMigrateVCenter @PSBoundParameters
                if ($null -eq $vmwareVCenter)
                {
                    throw New-OffAzureResourceNotFoundException `
                        -Scenario "VMware" `
                        -Type "VCenter" `
                        -Name $vCenterName `
                        -ResourceGroupName $vCenterResourceGroupName `
                        -SiteName $vCenterSiteName
                }
                $null = $PSBoundParameters.Remove('Name')
                
                $runAsAccountId = $vmwareVCenter.RunAsAccountId
            }
        }
        else
        {
            throw "Site type of '$SiteType' in -MachineId is not supported. Only '$($SiteTypes.HyperVSites)' and '$($SiteTypes.VMwareSites)' are supported."
        }
        if ([string]::IsNullOrEmpty($runAsAccountId)) {
            throw "Unable to determine RunAsAccount for site '$SiteName' from machine '$MachineName'. Please verify your appliance setup and provided -MachineId."
        }
        $null = $PSBoundParameters.Remove('SiteName')
        
        # $siteObject is not null or exception would have been thrown
        $ProjectName = $siteObject.DiscoverySolutionId.Split("/")[8]

        # Get Data Replication Service (AMH solution) with ResourceGroupName, Name, MigrateProjectName
        $amhSolutionName = $AzMigrateSolutions.DataReplicationSolution
        $null = $PSBoundParameters.Add('MigrateProjectName', $ProjectName)
        $null = $PSBoundParameters.Add('Name', $amhSolutionName)
        $amhSolution = Az.Migrate.private\Get-AzMigrateSolution_Get @PSBoundParameters
        if ($null -eq $amhSolution)
        {
            throw New-AzMigrateSolutionNotFoundException `
                -Name $amhSolutionName `
                -ResourceGroupName $ResourceGroupName `
                -ProjectName $ProjectName
        }
        $null = $PSBoundParameters.Remove('Name')
        $null = $PSBoundParameters.Remove('MigrateProjectName')
        
        # Validate replication vault
        $vaultId = $amhSolution.DetailExtendedDetail["vaultId"]
        $vaultIdArray = $vaultId.Split("/")
        if ($vaultIdArray.Length -lt 9)
        {
            throw New-ReplicationVaultNotFoundInAMHSolutionException -VaultId $vaultId
        }
        $replicationVaultName = $vaultIdArray[8]

        # Get replication vault with ResourceGroupName, Name
        $null = $PSBoundParameters.Add('Name', $replicationVaultName)
        $replicationVault = Az.Migrate.Internal\Get-AzMigrateVault @PSBoundParameters
        if ($null -eq $replicationVault) 
        {
            throw "No Replication Vault '$replicationVaultName' found in Resource Group '$ResourceGroupName'. Please verify your Azure Migrate project setup."
        }
        elseif ($replicationVault.Property.ProvisioningState -ne [ProvisioningState]::Succeeded)
        {
            throw "The Replication Vault '$replicationVaultName' is not in a valid state. The provisioning state is '$($replicationVault.Property.ProvisioningState)'. Please verify your Azure Migrate project setup."
        }
        $null = $PSBoundParameters.Remove('Name')

        # Validate replication prequisites
        Test-ReplicationPrequisites `
            -ResourceGroupName $ResourceGroupName `
            -VaultName $replicationVaultName `
            -ProtectedItemName $MachineName `
            -MigrationType $instanceType

        # Access Discovery Service
        $discoverySolutionName = $AzMigrateSolutions.DiscoverySolution
        # Get Discovery Solution with ResourceGroupName, Name, MigrateProjectName
        $null = $PSBoundParameters.Add('Name', $discoverySolutionName)
        $null = $PSBoundParameters.Add('MigrateProjectName', $ProjectName)
        $discoverySolution = Az.Migrate.private\Get-AzMigrateSolution_Get @PSBoundParameters
        if ($null -eq $discoverySolution)
        {
            throw  New-AzMigrateSolutionNotFoundException `
                -Name $discoverySolutionName `
                -ResourceGroupName $ResourceGroupName `
                -ProjectName $ProjectName
        }
        $null = $PSBoundParameters.Remove('MigrateProjectName')
        $null = $PSBoundParameters.Remove('Name')

        # Get Appliances Mapping
        $appMap = @{}
        if ($null -ne $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"]) {
            $appMapV2 = $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] | ConvertFrom-Json
            # Fetch all appliance from V2 map first. Then these can be updated if found again in V3 map.
            foreach ($item in $appMapV2) {
                $appMap[$item.ApplianceName.ToLower()] = $item.SiteId
            }
        }
    
        if ($null -ne $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"]) {
            $appMapV3 = $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] | ConvertFrom-Json
            foreach ($item in $appMapV3) {
                $t = $item.psobject.properties
                $appMap[$t.Name.ToLower()] = $t.Value.SiteId
            }
        }

        if ($null -eq $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] -And
            $null -eq $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] ) {
            throw "Server Discovery Solution missing Appliance Details. Invalid Solution."           
        }

        $hyperVSiteTypeRegex = "(?<=/Microsoft.OffAzure/HyperVSites/).*$"
        $vmwareSiteTypeRegex = "(?<=/Microsoft.OffAzure/VMwareSites/).*$"

        # Validate SourceApplianceName & TargetApplianceName
        $sourceSiteId = $appMap[$SourceApplianceName.ToLower()]
        $targetSiteId = $appMap[$TargetApplianceName.ToLower()]
        if (-not ($sourceSiteId -match $hyperVSiteTypeRegex -and $targetSiteId -match $hyperVSiteTypeRegex) -and
            -not ($sourceSiteId -match $vmwareSiteTypeRegex -and $targetSiteId -match $hyperVSiteTypeRegex)) {
            throw "Error encountered in matching the given source appliance name '$SourceApplianceName' and target appliance name '$TargetApplianceName'. Please verify the VM site type to be either for HyperV or VMware for both source and target appliances, and the appliance names are correct."
        }
        
        # Get healthy asrv2 fabrics in the resource group
        # Get all fabrics with ResourceGroupName
        $allFabrics = Az.Migrate.private\Get-AzMigrateLocalReplicationFabric_List1 @PSBoundParameters `
            | Where-Object {
                $_.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -and
                $_.Property.CustomProperty.MigrationSolutionId -eq $amhSolution.Id
            }

        # Filter for source fabric
        if ($instanceType -eq $AzLocalInstanceTypes.HyperVToAzLocal)
        {
            $fabricInstanceType = $FabricInstanceTypes.HyperVInstance
        }
        else { # $instanceType -eq $AzLocalInstanceTypes.VMwareToAzLocal
            $fabricInstanceType = $FabricInstanceTypes.VmwareInstance
        }

        $sourceFabric = $allFabrics | Where-Object {
            $_.Property.CustomProperty.InstanceType -ceq $fabricInstanceType -and
            $_.Name.StartsWith($SourceApplianceName, [System.StringComparison]::InvariantCultureIgnoreCase)
        }

        if ($null -eq $sourceFabric)
        {
            throw "Couldn't find connected source appliance with the name '$SourceApplianceName'. Deploy a source appliance by completing the Discover step of migration for your on-premises environment."
        }

        # Get source fabric agent (dra) with ResourceGroupName, FabricName
        $null = $PSBoundParameters.Add('FabricName', $sourceFabric.Name)
        $sourceDras = Az.Migrate.Internal\Get-AzMigrateFabricAgent @PSBoundParameters
        $sourceDra = $sourceDras | Where-Object {
            $_.Property.MachineName -eq $SourceApplianceName -and
            $_.Property.CustomProperty.InstanceType -eq $fabricInstanceType -and
            $_.Property.IsResponsive -eq $true
        }
        if ($null -eq $sourceDra)
        {
            throw "The source appliance '$SourceApplianceName' is in a disconnected state. Ensure that the source appliance is running and has connectivity before proceeding."
        }
        $null = $PSBoundParameters.Remove('FabricName')

        $sourceDra = $sourceDra[0]

        # Filter for target fabric
        $fabricInstanceType = $FabricInstanceTypes.AzLocalInstance
        $targetFabric = $allFabrics | Where-Object {
            $_.Property.CustomProperty.InstanceType -ceq $fabricInstanceType -and
            $_.Name.StartsWith($TargetApplianceName, [System.StringComparison]::InvariantCultureIgnoreCase)
        }

        if ($null -eq $targetFabric)
        {
            throw "Couldn't find connected target appliance with the name '$TargetApplianceName'. Deploy a target appliance by completing the Configuration step of migration for your Azure Local environment."
        }

        # Get target fabric agent (dra) with ResourceGroupName, FabricName
        $null = $PSBoundParameters.Add('FabricName', $targetFabric.Name)
        $targetDras = Az.Migrate.Internal\Get-AzMigrateFabricAgent @PSBoundParameters
        $targetDra = $targetDras | Where-Object {
            $_.Property.MachineName -eq $TargetApplianceName -and
            $_.Property.CustomProperty.InstanceType -eq $fabricInstanceType -and
            $_.Property.IsResponsive -eq $true
        }
        if ($null -eq $targetDra)
        {
            "The target appliance '$TargetApplianceName' is in a disconnected state. Ensure that the target appliance is running and has connectivity before proceeding."
        }
        $null = $PSBoundParameters.Remove('FabricName')

        $targetDra = $targetDras[0]

        # Validate Policy
        $policyName = $replicationVaultName + $instanceType + "policy"
        # Get replication policy with ResourceGroupName, Name, VaultName
        $null = $PSBoundParameters.Add('Name', $policyName)
        $null = $PSBoundParameters.Add('VaultName', $replicationVaultName)
        $policy = Az.Migrate.Internal\Get-AzMigratePolicy @PSBoundParameters
        if ($null -eq $policy)
        {
            throw "The replication policy '$policyName' not found. The replication infrastructure is not initialized. Run the Initialize-AzMigrateLocalReplicationInfrastructure command."
        }
        elseif ($policy.Property.ProvisioningState -ne [ProvisioningState]::Succeeded)
        {
            throw "The replication policy '$policyName' is not in a valid state. The provisioning state is '$($policy.Property.ProvisioningState)'. Re-run the Initialize-AzMigrateLocalReplicationInfrastructure command."
        }
        $null = $PSBoundParameters.Remove('Name')

        # Validate Replication Extension
        $replicationExtensionName = ($sourceFabric.Id -split '/')[-1] + "-" + ($targetFabric.Id -split '/')[-1] + "-MigReplicationExtn"
        # Get replication extension with ResourceGroupName, Name, VaultName
        $null = $PSBoundParameters.Add('Name', $replicationExtensionName)
        $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension @PSBoundParameters
        if ($null -eq $replicationExtension)
        {
            throw "The replication extension '$replicationExtensionName' not found. The replication infrastructure is not initialized. Run the Initialize-AzMigrateLocalReplicationInfrastructure command."
        }
        elseif ($replicationExtension.Property.ProvisioningState -ne [ProvisioningState]::Succeeded)
        {
            throw "The replication extension '$replicationExtensionName' is not in a valid state. The provisioning state is '$($replicationExtension.Property.ProvisioningState)'. Re-run the Initialize-AzMigrateLocalReplicationInfrastructure command."
        }
        $null = $PSBoundParameters.Remove('Name')
        
        # Get ARC Resource Bridge info
        $targetClusterId = $targetFabric.Property.CustomProperty.Cluster.ResourceName
        $targetClusterIdArray = $targetClusterId.Split("/")
        $targetSubscription = $targetClusterIdArray[2]
        $arbArgQuery = GetARGQueryForArcResourceBridge -HCIClusterID $targetClusterId
        $arbArgResult = Az.ResourceGraph\Search-AzGraph -Query $arbArgQuery -Subscription $targetSubscription
        if ($null -eq $arbArgResult) {
            throw "$($ArcResourceBridgeValidationMessages.NoClusters). Validate target cluster with id '$targetClusterId' exists."
        }
        elseif ($arbArgResult.statusOfTheBridge -ne "Running") {
            throw "$($ArcResourceBridgeValidationMessages.NotRunning). Make sure the Arc Resource Bridge is online before retrying."
        }

        # Validate TargetVMName
        if ($TargetVMName.length -gt 64 -or $TargetVMName.length -eq 0) {
            throw "The target virtual machine name must be between 1 and 64 characters long."
        }
        elseif ($TargetVMName -notmatch "^[^_\W][a-zA-Z0-9\-]{0,63}(?<![-._])$") {
            throw "The target virtual machine name must begin with a letter or number, and can contain only letters, numbers, or hyphens(-). The names cannot contain special characters \/""[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'."
        }
        elseif (IsReservedOrTrademarked($TargetVMName)) {
            throw "The target virtual machine name '$TargetVMName' or part of the name is a trademarked or reserved word."
        }

        # Construct create protected item request object
        $protectedItemProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemModelProperties]::new()
        $protectedItemProperties.PolicyName = $policyName
        $protectedItemProperties.ReplicationExtensionName = $replicationExtensionName

        if ($SiteType -eq $SiteTypes.HyperVSites) {     
            $customProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCIProtectedItemModelCustomProperties]::new()
            $isSourceDynamicMemoryEnabled = $machine.IsDynamicMemoryEnabled
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
            $customProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCIProtectedItemModelCustomProperties]::new()
            $isSourceDynamicMemoryEnabled = $false
        }

        $customProperties.InstanceType = $instanceType
        $customProperties.CustomLocationRegion = $arbArgResult.CustomLocationRegion
        $customProperties.FabricDiscoveryMachineId = $machine.Id
        $customProperties.RunAsAccountId = $runAsAccountId
        $customProperties.SourceFabricAgentName = $sourceDra.Name
        $customProperties.StorageContainerId = $TargetStoragePathId
        $customProperties.TargetArcClusterCustomLocationId = $arbArgResult.CustomLocation
        $customProperties.TargetFabricAgentName = $targetDra.Name
        $customProperties.TargetHciClusterId = $targetClusterId
        $customProperties.TargetResourceGroupId = $TargetResourceGroupId
        $customProperties.TargetVMName = $TargetVMName
        $customProperties.IsDynamicRam = if ($HasIsDynamicMemoryEnabled) { $isDynamicRamEnabled } else {  $isSourceDynamicMemoryEnabled }
    
        # Determine target VM Hyper-V Generation
        if ($SiteType -eq $SiteTypes.HyperVSites) { 
            # Hyper-V source
            $customProperties.HyperVGeneration = $machine.Generation
        }
        else { 
            #Vmware source, non-BOIS VMs will be migrated to Gen2
            $customProperties.HyperVGeneration = if ($machine.Firmware -ieq "BIOS") { "1" } else { "2" }
        }

        # Validate TargetVMCPUCore
        if ($HasTargetVMCPUCore)
        {
            if ($TargetVMCPUCore -lt $TargetVMCPUCores.Min -or $TargetVMCPUCore -gt $TargetVMCPUCores.Max)
            {
                throw "Specify -TargetVMCPUCore between $($TargetVMCPUCores.Min) and $($TargetVMCPUCores.Max)."
            }
            $customProperties.TargetCpuCore = $TargetVMCPUCore
        }
        else
        {
            $customProperties.TargetCpuCore = $machine.NumberOfProcessorCore
        }

        # Validate TargetVMRam
        if ($HasTargetVMRam)
        {
            if ($customProperties.HyperVGeneration -eq "1") {
                # Between 512 MB and 1 TB
                if ($TargetVMRam -lt $TargetVMRamInMB.Gen1Min -or $TargetVMRam -gt $TargetVMRamInMB.Gen1Max)
                {
                    throw "Specify -TargetVMRAM between $($TargetVMRamInMB.Gen1Min) and $($TargetVMRamInMB.Gen1Max) MB (i.e., 1 TB) for Hyper-V Generation 1 VM."
                }
            }
            else # Hyper-V Generation 2
            {
                # Between 32 MB and 12 TB
                if ($TargetVMRam -lt $TargetVMRamInMB.Gen2Min -or $TargetVMRam -gt $TargetVMRamInMB.Gen2Max)
                {
                    throw "Specify -TargetVMRAM between $($TargetVMRamInMB.Gen2Min) and $($TargetVMRamInMB.Gen2Max) MB (i.e., 12 TB) for Hyper-V Generation 2 VM."
                }
            }

            $customProperties.TargetMemoryInMegaByte = $TargetVMRam 
        }
        else
        {
            $customProperties.TargetMemoryInMegaByte = [System.Math]::Max($machine.AllocatedMemoryInMB, $RAMConfig.MinTargetMemoryInMB)
        }

        # Construct default dynamic memory config
        $memoryConfig = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemDynamicMemoryConfig]::new()
        $memoryConfig.MinimumMemoryInMegaByte = [System.Math]::Min($customProperties.TargetMemoryInMegaByte, $RAMConfig.DefaultMinDynamicMemoryInMB)
        $memoryConfig.MaximumMemoryInMegaByte = [System.Math]::Max($customProperties.TargetMemoryInMegaByte, $RAMConfig.DefaultMaxDynamicMemoryInMB)
        $memoryConfig.TargetMemoryBufferPercentage = $RAMConfig.DefaultTargetMemoryBufferPercentage

        $customProperties.DynamicMemoryConfig = $memoryConfig
        
        # Disks and Nics
        [PSCustomObject[]]$disks = @()
        [PSCustomObject[]]$nics = @()
        if ($parameterSet -match 'DefaultUser') {
            if ($SiteType -eq $SiteTypes.HyperVSites) {
                $osDisk = $machine.Disk | Where-Object { $_.InstanceId -eq $OSDiskID }
                if ($null -eq $osDisk) {
                    throw "No Disk found with InstanceId $OSDiskID from discovered machine disks."
                }
            }
            elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
                $osDisk = $machine.Disk | Where-Object { $_.Uuid -eq $OSDiskID }
                if ($null -eq $osDisk) {
                    throw "No Disk found with Uuid $OSDiskID from discovered machine disks."
                }
            }

            foreach ($sourceDisk in $machine.Disk) {
                $diskId = if ($SiteType -eq $SiteTypes.HyperVSites) { $sourceDisk.InstanceId } else { $sourceDisk.Uuid }
                $diskSize = if ($SiteType -eq $SiteTypes.HyperVSites) { $sourceDisk.MaxSizeInByte } else { $sourceDisk.MaxSizeInBytes }

                $DiskObject = [PSCustomObject]@{
                    DiskId         = $diskId
                    DiskSizeGb     = [long] [Math]::Ceiling($diskSize / 1GB)
                    DiskFileFormat = "VHDX"
                    IsDynamic      = $true
                    IsOSDisk       = $diskId -eq $OSDiskID
                }
                
                $disks += $DiskObject
            }
            
            foreach ($sourceNic in $machine.NetworkAdapter) {
                $NicObject = [PSCustomObject]@{
                    NicId                    = $sourceNic.NicId
                    TargetNetworkId          = $TargetVirtualSwitchId
                    TestNetworkId            = if ($HasTargetTestVirtualSwitchId) { $TargetTestVirtualSwitchId } else { $TargetVirtualSwitchId }
                    SelectionTypeForFailover = $VMNicSelection.SelectedByUser
                }
                $nics += $NicObject
            }
        }
        else
        {
            # PowerUser
            if ($null -eq $DiskToInclude -or $DiskToInclude.length -eq 0) {
                throw "Invalid DiskToInclude. At least one disk is required."
            }

            # Validate OSDisk is set.
            $osDisk = $DiskToInclude | Where-Object { $_.IsOSDisk }
            if (($null -eq $osDisk) -or ($osDisk.length -ne 1)) {
                throw "Invalid DiskToInclude. One disk must be designated as the OS disk."
            }
            
            # Validate DiskToInclude
            [PSCustomObject[]]$uniqueDisks = @()
            foreach ($disk in $DiskToInclude) {
                # Enforce VHDX for Gen2 VMs
                if ($customProperties.HyperVGeneration -eq "2" -and $disk.DiskFileFormat -eq "VHD") {
                    throw "Please specify 'VHDX' as Format for the disk with id '$($disk.DiskId)' in -DiskToInclude by re-running New-AzMigrateLocalDiskMappingObject."
                }

                # PhysicalSectorSize must be 512 for VHD format if it is set
                if ($disk.DiskFileFormat -eq "VHD" -and $null -ne $disk.DiskPhysicalSectorSize -and $disk.DiskPhysicalSectorSize -ne 512) {
                    throw "Invalid Physical sector size of $($disk.DiskPhysicalSectorSize) is found for VHD format. Please replace disk with id '$($disk.DiskId)' in -DiskToInclude by re-running New-AzMigrateLocalDiskMappingObject with 512 as -PhysicalSectorSize."
                }

                if ($SiteType -eq $SiteTypes.HyperVSites) {
                    $discoveredDisk = $machine.Disk | Where-Object { $_.InstanceId -eq $disk.DiskId }
                    if ($null -eq $discoveredDisk) {
                        throw "No Disk found with InstanceId '$($disk.DiskId)' from discovered machine disks."
                    }
                }
                elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
                    $discoveredDisk = $machine.Disk | Where-Object { $_.Uuid -eq $disk.DiskId }
                    if ($null -eq $discoveredDisk) {
                        throw "No Disk found with Uuid '$($disk.DiskId)' from discovered machine disks."
                    }
                }

                if ($uniqueDisks.Contains($disk.DiskId)) {
                    throw "The disk id '$($disk.DiskId)' is already taken."
                }
                $uniqueDisks += $disk.DiskId

                $htDisk = @{}
                $disk.PSObject.Properties | ForEach-Object { $htDisk[$_.Name] = $_.Value }
                $disks += [PSCustomObject]$htDisk
            }

            # Validate NicToInclude
            [PSCustomObject[]]$uniqueNics = @()
            foreach ($nic in $NicToInclude) {
                $discoveredNic = $machine.NetworkAdapter | Where-Object { $_.NicId -eq $nic.NicId }
                if ($null -eq $discoveredNic) {
                    throw "The Nic id '$($nic.NicId)' is not found."
                }

                if ($uniqueNics.Contains($nic.NicId)) {
                    throw "The Nic id '$($nic.NicId)' is already included. Please remove the duplicate entry and try again."
                }

                $uniqueNics += $nic.NicId
                
                $htNic = @{}
                $nic.PSObject.Properties | ForEach-Object { $htNic[$_.Name] = $_.Value }

                if ($htNic.SelectionTypeForFailover -eq $VMNicSelection.SelectedByUser -and
                    [string]::IsNullOrEmpty($htNic.TargetNetworkId)) {
                    throw throw "The TargetVirtualSwitchId parameter is required when the CreateAtTarget flag is set to 'true'. NIC '$($htNic.NicId)'. Please utilize the New-AzMigrateLocalNicMappingObject command to properly create a Nic mapping object."
                }

                $nics += [PSCustomObject]$htNic
            }
        }

        if ($SiteType -eq $SiteTypes.HyperVSites) {     
            $customProperties.DisksToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCIDiskInput[]]$disks
            $customProperties.NicsToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCINicInput[]]$nics
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites) {     
            $customProperties.DisksToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCIDiskInput[]]$disks
            $customProperties.NicsToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCINicInput[]]$nics
        }
        
        $protectedItemProperties.CustomProperty = $customProperties

        # Remove common ErrorVariable and ErrorAction for get behaviors
        $null = $PSBoundParameters.Remove('ErrorVariable')
        $null = $PSBoundParameters.Remove('ErrorAction')

        if ($PSCmdlet.ShouldProcess($MachineId, "Replicate VM.")) {
            # Create protected item with ResourceGroupName, VaultName, Name, Property
            $null = $PSBoundParameters.Add('Name', $MachineName)
            $null = $PSBoundParameters.Add('Property', $protectedItemProperties)
            $null = $PSBoundParameters.Add('NoWait', $true)
            $operation = Az.Migrate.Internal\New-AzMigrateProtectedItem @PSBoundParameters
            $null = $PSBoundParameters.Remove('NoWait')
            $null = $PSBoundParameters.Remove('Property')
            $null = $PSBoundParameters.Remove('Name')

            # Get job with ResourceGroupName, VaultName, Name
            $jobName = $operation.Target.Split("/")[-1].Split("?")[0].Split("_")[0]
            $null = $PSBoundParameters.Add('Name', $jobName)
            return Az.Migrate.Internal\Get-AzMigrateLocalReplicationJob @PSBoundParameters
        }
    }
}
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBM9w+wNHnBZZSu
# zI90w04Hf454x5+wIJ6CF46RD35G0qCCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
# 7A5ZL83XAAAAAASFMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjUwNjE5MTgyMTM3WhcNMjYwNjE3MTgyMTM3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDASkh1cpvuUqfbqxele7LCSHEamVNBfFE4uY1FkGsAdUF/vnjpE1dnAD9vMOqy
# 5ZO49ILhP4jiP/P2Pn9ao+5TDtKmcQ+pZdzbG7t43yRXJC3nXvTGQroodPi9USQi
# 9rI+0gwuXRKBII7L+k3kMkKLmFrsWUjzgXVCLYa6ZH7BCALAcJWZTwWPoiT4HpqQ
# hJcYLB7pfetAVCeBEVZD8itKQ6QA5/LQR+9X6dlSj4Vxta4JnpxvgSrkjXCz+tlJ
# 67ABZ551lw23RWU1uyfgCfEFhBfiyPR2WSjskPl9ap6qrf8fNQ1sGYun2p4JdXxe
# UAKf1hVa/3TQXjvPTiRXCnJPAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUuCZyGiCuLYE0aU7j5TFqY05kko0w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwNTM1OTAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBACjmqAp2Ci4sTHZci+qk
# tEAKsFk5HNVGKyWR2rFGXsd7cggZ04H5U4SV0fAL6fOE9dLvt4I7HBHLhpGdE5Uj
# Ly4NxLTG2bDAkeAVmxmd2uKWVGKym1aarDxXfv3GCN4mRX+Pn4c+py3S/6Kkt5eS
# DAIIsrzKw3Kh2SW1hCwXX/k1v4b+NH1Fjl+i/xPJspXCFuZB4aC5FLT5fgbRKqns
# WeAdn8DsrYQhT3QXLt6Nv3/dMzv7G/Cdpbdcoul8FYl+t3dmXM+SIClC3l2ae0wO
# lNrQ42yQEycuPU5OoqLT85jsZ7+4CaScfFINlO7l7Y7r/xauqHbSPQ1r3oIC+e71
# 5s2G3ClZa3y99aYx2lnXYe1srcrIx8NAXTViiypXVn9ZGmEkfNcfDiqGQwkml5z9
# nm3pWiBZ69adaBBbAFEjyJG4y0a76bel/4sDCVvaZzLM3TFbxVO9BQrjZRtbJZbk
# C3XArpLqZSfx53SuYdddxPX8pvcqFuEu8wcUeD05t9xNbJ4TtdAECJlEi0vvBxlm
# M5tzFXy2qZeqPMXHSQYqPgZ9jvScZ6NwznFD0+33kbzyhOSz/WuGbAu4cHZG8gKn
# lQVT4uA2Diex9DMs2WHiokNknYlLoUeWXW1QrJLpqO82TLyKTbBM/oZHAdIc0kzo
# STro9b3+vjn2809D0+SOOCVZMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIDnSPRI9xiLWFlbvgcsP8QjC
# dHAqAZNSjpPlzoH3qOooMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAGO6eHF33xN7VDNZ5g01PNj5wv0K/s0O2HysehErFN5cxscYhsHoXKpah
# nh/L6KoLMoqzoFSimp0UVEzZYzSwIdpMMAlrG7iIo8A3G1/i+oVqQ1I93mCGMe25
# O5mpOpdC3CP3DHNHHV5kSNZglAo74mUalRF0CJjUPCSMPQ7oLkNVXp3C4BvzWG3R
# olHY+gGKF5zy+HxMgI4qmBHvN9ax0bAMZMOOFkBxWzetfqfNcTH3KJqtRVerSiZS
# r8zzsgi2OyM8MAPkKFJU5eCzBiETzxL0QrAGOgN4IkYzre2EdhFOkIUt6qk7rBQ3
# o9VM5KUPXyearpNOfCT1LbEwqTYBbKGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDXWYVkVo1KB+VQFQ40DBO9K6rhHDgCdaJIT/EAncTiNAIGaTsKZWIB
# GBMyMDI2MDExMDAxMTUxMi44NjFaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046REMwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAgO7HlwAOGx0ygABAAACAzANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NDZaFw0yNjA0MjIxOTQyNDZaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046REMwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQChl0MH5wAnOx8Uh8RtidF0J0yaFDHJYHTpPvRR16X1
# KxGDYfT8PrcGjCLCiaOu3K1DmUIU4Rc5olndjappNuOgzwUoj43VbbJx5PFTY/a1
# Z80tpqVP0OoKJlUkfDPSBLFgXWj6VgayRCINtLsUasy0w5gysD7ILPZuiQjace5K
# xASjKf2MVX1qfEzYBbTGNEijSQCKwwyc0eavr4Fo3X/+sCuuAtkTWissU64k8rK6
# 0jsGRApiESdfuHr0yWAmc7jTOPNeGAx6KCL2ktpnGegLDd1IlE6Bu6BSwAIFHr7z
# OwIlFqyQuCe0SQALCbJhsT9y9iy61RJAXsU0u0TC5YYmTSbEI7g10dYx8Uj+vh9I
# nLoKYC5DpKb311bYVd0bytbzlfTRslRTJgotnfCAIGMLqEqk9/2VRGu9klJi1j9n
# VfqyYHYrMPOBXcrQYW0jmKNjOL47CaEArNzhDBia1wXdJANKqMvJ8pQe2m8/ciby
# DM+1BVZquNAov9N4tJF4ACtjX0jjXNDUMtSZoVFQH+FkWdfPWx1uBIkc97R+xRLu
# PjUypHZ5A3AALSke4TaRBvbvTBYyW2HenOT7nYLKTO4jw5Qq6cw3Z9zTKSPQ6D5l
# yiYpes5RR2MdMvJS4fCcPJFeaVOvuWFSQ/EGtVBShhmLB+5ewzFzdpf1UuJmuOQT
# TwIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFLIpWUB+EeeQ29sWe0VdzxWQGJJ9MB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCQEMbesD6TC08R0oYCdSC452AQrGf/O89G
# Q54CtgEsbxzwGDVUcmjXFcnaJSTNedBKVXkBgawRonP1LgxH4bzzVj2eWNmzGIwO
# 1FlhldAPOHAzLBEHRoSZ4pddFtaQxoabU/N1vWyICiN60It85gnF5JD4MMXyd6pS
# 8eADIi6TtjfgKPoumWa0BFQ/aEzjUrfPN1r7crK+qkmLztw/ENS7zemfyx4kGRgw
# Y1WBfFqm/nFlJDPQBicqeU3dOp9hj7WqD0Rc+/4VZ6wQjesIyCkv5uhUNy2LhNDi
# 2leYtAiIFpmjfNk4GngLvC2Tj9IrOMv20Srym5J/Fh7yWAiPeGs3yA3QapjZTtfr
# 7NfzpBIJQ4xT/ic4WGWqhGlRlVBI5u6Ojw3ZxSZCLg3vRC4KYypkh8FdIWoKirji
# dEGlXsNOo+UP/YG5KhebiudTBxGecfJCuuUspIdRhStHAQsjv/dAqWBLlhorq2OC
# aP+wFhE3WPgnnx5pflvlujocPgsN24++ddHrl3O1FFabW8m0UkDHSKCh8QTwTkYO
# wu99iExBVWlbYZRz2qOIBjL/ozEhtCB0auKhfTLLeuNGBUaBz+oZZ+X9UAECoMhk
# ETjb6YfNaI1T7vVAaiuhBoV/JCOQT+RYZrgykyPpzpmwMNFBD1vdW/29q9nkTWoE
# hcEOO0L9NzCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
# hvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAy
# MDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25Phdg
# M/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPF
# dvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6
# GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBp
# Dco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
# yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3E
# XzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0
# lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
# GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
# +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PA
# PBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
# EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxG
# NSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARV
# MFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAK
# BggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG
# 9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
# M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmC
# VgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449
# xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wM
# nosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDS
# PeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
# Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxn
# GSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+Crvs
# QWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
# jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNN
# MIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkRDMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDN
# rxRX/iz6ss1lBCXG8P1LFxD0e6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7QvBUjAiGA8yMDI2MDEwOTE4MDI1
# OFoYDzIwMjYwMTEwMTgwMjU4WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDtC8FS
# AgEAMAcCAQACAg9LMAcCAQACAhMVMAoCBQDtDRLSAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAG6PquX4lIZx6sQAK3Zrv7CeAMl+OwJwEkHfPn86aID/zo7X
# 18wH9p1CV8+s3z3PyBBhY27AMUJfxUkyG6l6+9qDw4I//QeSHBtxJum2YvjPkoBZ
# X8HnH5tSh37MnHwAkcYwLh4fydw86x3U4DP33z6vOZYGGlf3gSnhQMVJa95n+FrL
# 0FVRimR1X56vELM5fOckcQ5F3X6A4g972HYuSkAl/lnW2vp5vuvrSr/O+BM0XKAf
# q55CHSEssSoqbNYzW9242oHjALsfL0ynop1A+hPeTxkUwW+Hry3XLMiXUDMe/StZ
# AxVA8BbBZ+Q3mcwTu2+bzpDCr8WTMOVJoJttZlQxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgO7HlwAOGx0ygABAAACAzAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCCVTJ2lXBD0Ub/FVoIX5pJOfA2XBishlhuttc42CXmOpTCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIEsD3RtxlvaTxFOZZnpQw0DksPmV
# duo5SyK9h9w++hMtMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAIDux5cADhsdMoAAQAAAgMwIgQg6AYcH5jCKphyDr+N879itZp1RtUv
# VgKpybxYS3PdD0wwDQYJKoZIhvcNAQELBQAEggIAh+jmQnEmtSwcybuN8ypawo9P
# zlKDlq6KNHr3TIcfuZN7ngxsNfnHXh5BvYeqlKplgkThl94HryJw3rhoN73+Lm6b
# kqsZv4pExupZ76ciqe0bfqC9SjddKqINnCREaEHM6JtMF221xy3XLE+pdwAJNsfy
# OuZs2/HwqarE6ti7KVXnfhANGRDYpqO+pT58MM9c93w39YiqSDXjrpHVCOf8ZvyY
# NPQify8HNncHQ6Gl89h7gIM4y7WJCJVw4OupRdF1dE+lvAHhFzASn5UMIJTxvtb6
# k21xiRCEy5AZSfh0Z3UIeZkjSiSSVB/c9r+0qe9ZrHMhVH3gjFz5YrEptXRqdWfN
# M9F+41zQphddh2eJ4IrYASztKS2vSAn5tESuO9nWMFjWsHquLbw/FIB3pw7RJmvf
# 0wpJdSTC6wzDwrW58tFWaehmWPxaO1+ZTt4K4tNF50oKbIXRmdBnUQlf28sYyJLO
# PhXT3jL7YX3w5/K64l0HHx5Q6xrbshYsZxR3RCPScvZhm5Vyjv6D8hAGtBkz22zB
# NxlbRu1MULvysSL8xpOxUYPN6t6Zoys9mENzJBw2X9MebGyxLzKv1TOJB29ATnW/
# RB1GesLN5B6dlHWFQbaJXKxqlhiF5kIsoXVfwvQkYvUQtUXH4LgnFtv5SAPq2pBM
# S5sp5Lt6U+muHZlR2b4=
# SIG # End signature block

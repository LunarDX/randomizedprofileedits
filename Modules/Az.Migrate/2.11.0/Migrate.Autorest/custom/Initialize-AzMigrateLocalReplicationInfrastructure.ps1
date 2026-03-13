
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
Initializes the infrastructure for the migrate project.
.Description
The Initialize-AzMigrateLocalReplicationInfrastructure cmdlet initializes the infrastructure for the migrate project in AzLocal scenario.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/initialize-azmigratelocalreplicationinfrastructure
#>

function Initialize-AzMigrateLocalReplicationInfrastructure {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.PreviewMessageAttribute("This cmdlet is based on a preview API version and may experience breaking changes in future releases.")]
    [OutputType([System.Boolean], ParameterSetName = 'AzLocal')]
    [CmdletBinding(DefaultParameterSetName = 'AzLocal', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group of the Azure Migrate Project in the current subscription.
        ${ResourceGroupName},

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the Azure Migrate project to be used for server migration.
        ${ProjectName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Storage Account ARM Id to be used for private endpoint scenario.
        ${CacheStorageAccountId},

        [Parameter()]
        [System.String]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        # Azure Subscription ID.
        ${SubscriptionId},

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

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Returns true when the command succeeds
        ${PassThru},
    
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

        CheckResourcesModuleDependency
        CheckStorageModuleDependency
        Import-Module Az.Resources
        Import-Module Az.Storage

        $hasCacheStorageAccountId = $PSBoundParameters.ContainsKey('CacheStorageAccountId')

        $parameterSetName = $PSCmdlet.ParameterSetName
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('ProjectName')
        $null = $PSBoundParameters.Remove('CacheStorageAccountId')
        $null = $PSBoundParameters.Remove('SourceApplianceName')
        $null = $PSBoundParameters.Remove('TargetApplianceName')

        # Set common ErrorVariable and ErrorAction for get behaviors
        $null = $PSBoundParameters.Add('ErrorVariable', 'notPresent')
        $null = $PSBoundParameters.Add('ErrorAction', 'SilentlyContinue')

        # Get subscription Id
        $context = Get-AzContext
        if ([string]::IsNullOrEmpty($SubscriptionId)) {
            Write-Host "No -SubscriptionId provided. Using the one from Get-AzContext."

            $SubscriptionId = $context.Subscription.Id
            if ([string]::IsNullOrEmpty($SubscriptionId)) {
                throw "Please login to Azure to select a subscription."
            }
        }
        Write-Host "*Selected Subscription Id: '$($SubscriptionId)'"
    
        # Get resource group with Name
        $resourceGroup = Get-AzResourceGroup `
            -Name $ResourceGroupName `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $resourceGroup) {
            throw "Resource group '$($ResourceGroupName)' does not exist in the subscription. Please create the resource group and try again."
        }
        Write-Host "*Selected Resource Group: '$($ResourceGroupName)'"

        # Verify user validity
        $userObject = Get-AzADUser -UserPrincipalName $context.Subscription.ExtendedProperties.Account

        if (-not $userObject) {
            $userObject = Get-AzADUser -Mail $context.Subscription.ExtendedProperties.Account
        }

        if (-not $userObject) {
            $mailNickname = "{0}#EXT#" -f $($context.Account.Id -replace '@', '_')

            $userObject = Get-AzADUser | 
            Where-Object { $_.MailNickname -eq $mailNickname }
        }

        if (-not $userObject) {
            if ($context.Account.Id.StartsWith("MSI@")) {
                $hostname = $env:COMPUTERNAME
                $userObject = Get-AzADServicePrincipal -DisplayName $hostname
            }
            else {
                $userObject = Get-AzADServicePrincipal -ApplicationID $context.Account.Id
            }
        }

        if (-not $userObject) {
            throw 'User Object Id Not Found!'
        }

        # Get Migrate Project with ResourceGroupName, Name
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('Name', $ProjectName)
        $migrateProject = Get-AzMigrateProject @PSBoundParameters
        if ($null -eq $migrateProject)
        {
            throw "Migrate project '$ProjectName' not found."
        }
        elseif ($migrateProject.Property.ProvisioningState -ne [ProvisioningState]::Succeeded)
        {
            throw "Migrate project '$ProjectName' is not in a valid state. The provisioning state is '$($migrateProject.Property.ProvisioningState)'. Please verify your Azure Migrate project setup."
        }
        $null = $PSBoundParameters.Remove('Name')

        # Get Data Replication Service (AMH solution) with ResourceGroupName, MigrateProjectName, Name
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

        # Validate Replication Vault
        $replicationVaultName = $amhSolution.DetailExtendedDetail["vaultId"].Split("/")[8]
        if ([string]::IsNullOrEmpty($replicationVaultName)) {
            throw "No Replication Vault found. Please verify your Azure Migrate project setup."
        }

        # Get replication vault with ResourceGroupName, Name
        $null = $PSBoundParameters.Add('Name', $replicationVaultName)
        $replicationVault = Az.Migrate.Internal\Get-AzMigrateVault @PSBoundParameters
        if ($null -eq $replicationVault)
        {
            throw "No Replication Vault '$replicationVaultName' found in Resource Group '$ResourceGroupName'. Please verify your Azure Migrate project setup."
        }
        $null = $PSBoundParameters.Remove('Name')

        # Access Discovery Service
        # Get Discovery Solution with ResourceGroupName, MigrateProjectName, Name
        $discoverySolutionName = $AzMigrateSolutions.DiscoverySolution
        $null = $PSBoundParameters.Add('MigrateProjectName', $ProjectName)
        $null = $PSBoundParameters.Add('Name', $discoverySolutionName)
        $discoverySolution = Az.Migrate.private\Get-AzMigrateSolution_Get @PSBoundParameters
        if ($null -eq $discoverySolution)
        {
            throw throw New-AzMigrateSolutionNotFoundException `
                -Name $discoverySolutionName `
                -ResourceGroupName $ResourceGroupName `
                -ProjectName $ProjectName
        }
        $null = $PSBoundParameters.Remove('Name')
        $null = $PSBoundParameters.Remove('MigrateProjectName')

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
        if ($sourceSiteId -match $hyperVSiteTypeRegex -and $targetSiteId -match $hyperVSiteTypeRegex) {
            $instanceType = $AzLocalInstanceTypes.HyperVToAzLocal
            $fabricInstanceType = $FabricInstanceTypes.HyperVInstance
        }
        elseif ($sourceSiteId -match $vmwareSiteTypeRegex -and $targetSiteId -match $hyperVSiteTypeRegex) {
            $instanceType = $AzLocalInstanceTypes.VMwareToAzLocal
            $fabricInstanceType = $FabricInstanceTypes.VmwareInstance
        }
        else {
            throw "Error encountered in matching the given source appliance name '$SourceApplianceName' and target appliance name '$TargetApplianceName'. Please verify the VM site type to be either for HyperV or VMware for both source and target appliances, and the appliance names are correct."
        }

        # Get healthy asrv2 fabrics with ResourceGroupName
        $allFabrics = Az.Migrate.private\Get-AzMigrateLocalReplicationFabric_List1 @PSBoundParameters `
            | Where-Object {
                $_.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -and
                $_.Property.CustomProperty.MigrationSolutionId -eq $amhSolution.Id
            }

        # Filter for source fabric
        $sourceFabric = $allFabrics | Where-Object {
            $_.Property.CustomProperty.InstanceType -ceq $fabricInstanceType -and
            $_.Name.StartsWith($SourceApplianceName, [System.StringComparison]::InvariantCultureIgnoreCase)
        }

        if ($null -eq $sourceFabric)
        {
            throw "Couldn't find connected source appliance with the name '$SourceApplianceName'. Deploy a source appliance by completing the Discover step of migration for your on-premises environment."
        }
        Write-Host "*Selected Source Fabric: '$($sourceFabric.Name)'"

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
        Write-Host "*Selected Source Fabric Agent: '$($sourceDra.Name)'"

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
        "*Selected Target Fabric: '$($targetFabric.Name)'"

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
            throw "The target appliance '$TargetApplianceName' is in a disconnected state. Ensure that the target appliance is running and has connectivity before proceeding."
        }
        $null = $PSBoundParameters.Remove('FabricName')
        $targetDra = $targetDras[0]
        Write-Host "*Selected Target Fabric Agent: '$($targetDra.Name)'"

        # Put Policy
        # Get replication policy with ResourceGroupName, Name, VaultName
        $policyName = $replicationVault.Name + $instanceType + "policy"
        $null = $PSBoundParameters.Add('Name', $policyName)
        $null = $PSBoundParameters.Add('VaultName', $replicationVault.Name)
        $policy = Az.Migrate.Internal\Get-AzMigratePolicy @PSBoundParameters
        
        # Default policy is found
        if ($null -ne $policy) {
            # Give time for create/update to reach a terminal state. Timeout after 10min
            if ($policy.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                $policy.Property.ProvisioningState -eq [ProvisioningState]::Updating) {
                Write-Host "Policy '$($policyName)' found in Provisioning State '$($policy.Property.ProvisioningState)'."

                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $policy = Az.Migrate.Internal\Get-AzMigratePolicy -InputObject $policy

                    if (-not (
                            $policy.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                            $policy.Property.ProvisioningState -eq [ProvisioningState]::Updating)) {
                        break
                    }
                }

                # Make sure Policy is no longer in Creating or Updating state
                if ($policy.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Updating) {
                    throw "Policy '$($policyName)' times out with Provisioning State: '$($policy.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
                }
            }

            # Check and remove if policy is in a bad terminal state
            if ($policy.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                $policy.Property.ProvisioningState -eq [ProvisioningState]::Failed) {
                Write-Host "Policy '$($policyName)' found but in an unusable terminal Provisioning State '$($policy.Property.ProvisioningState)'.`nRemoving policy..."
                    
                # Remove policy
                try {
                    Az.Migrate.Internal\Remove-AzMigratePolicy -InputObject $policy | Out-Null
                }
                catch {
                    if ($_.Exception.Message -notmatch "Status: OK") {
                        throw $_.Exception.Message
                    }
                }

                Start-Sleep -Seconds 30
                $policy = Az.Migrate.Internal\Get-AzMigratePolicy `
                    -InputObject $policy `
                    -ErrorVariable notPresent `
                    -ErrorAction SilentlyContinue

                # Make sure Policy is no longer in Canceled or Failed state
                if ($null -ne $policy -and
                    ($policy.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Failed)) {
                    throw "Failed to change the Provisioning State of policy '$($policyName)'by removing. Please re-run this command or contact support if help needed."
                }
            }

            # Give time to remove policy. Timeout after 10min
            if ($null -eq $policy -and $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                Write-Host "Policy '$($policyName)' found in Provisioning State '$($policy.Property.ProvisioningState)'."

                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $policy = Az.Migrate.Internal\Get-AzMigratePolicy `
                        -InputObject $policy `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue
                    
                    if ($null -eq $policy -or $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
                        break
                    }
                    elseif ($policy.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                        continue
                    }

                    throw "Policy '$($policyName)' has an unexpected Provisioning State of '$($policy.Property.ProvisioningState)' during removal process. Please re-run this command or contact support if help needed."
                }

                # Make sure Policy is no longer in Deleting state
                if ($null -ne $policy -and $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                    throw "Policy '$($policyName)' times out with Provisioning State: '$($policy.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
                }
            }

            # Indicate policy was removed
            if ($null -eq $policy -or $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
                Write-Host "Policy '$($policyName)' was removed."
            }
        }

        # Refresh local policy object if exists
        if ($null -ne $policy) {
            $policy = Az.Migrate.Internal\Get-AzMigratePolicy -InputObject $policy
        }

        # Create policy if not found or previously deleted
        if ($null -eq $policy -or $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
            Write-Host "Creating Policy..."

            $params = @{
                InstanceType                     = $instanceType;
                RecoveryPointHistoryInMinute     = $ReplicationDetails.PolicyDetails.DefaultRecoveryPointHistoryInMinutes;
                CrashConsistentFrequencyInMinute = $ReplicationDetails.PolicyDetails.DefaultCrashConsistentFrequencyInMinutes;
                AppConsistentFrequencyInMinute   = $ReplicationDetails.PolicyDetails.DefaultAppConsistentFrequencyInMinutes;
            }

            # Setup Policy deployment parameters
            $policyProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.PolicyModelProperties]::new()
            if ($instanceType -eq $AzLocalInstanceTypes.HyperVToAzLocal) {
                $policyCustomProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHcipolicyModelCustomProperties]::new()
            }
            elseif ($instanceType -eq $AzLocalInstanceTypes.VMwareToAzLocal) {
                $policyCustomProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHcipolicyModelCustomProperties]::new()
            }
            else {
                throw "Instance type '$($instanceType)' is not supported. Currently, for AzLocal scenario, only HyperV and VMware as the source is supported."
            }
            $policyCustomProperties.InstanceType = $params.InstanceType
            $policyCustomProperties.RecoveryPointHistoryInMinute = $params.RecoveryPointHistoryInMinute
            $policyCustomProperties.CrashConsistentFrequencyInMinute = $params.CrashConsistentFrequencyInMinute
            $policyCustomProperties.AppConsistentFrequencyInMinute = $params.AppConsistentFrequencyInMinute
            $policyProperties.CustomProperty = $policyCustomProperties
        
            try {
                Az.Migrate.Internal\New-AzMigratePolicy `
                    -Name $policyName `
                    -ResourceGroupName $ResourceGroupName `
                    -VaultName $replicationVaultName `
                    -Property $policyProperties `
                    -SubscriptionId $SubscriptionId `
                    -NoWait | Out-Null
            }
            catch {
                if ($_.Exception.Message -notmatch "Status: OK") {
                    throw $_.Exception.Message
                }
            }

            # Check Policy creation status every 30s. Timeout after 10min
            for ($i = 0; $i -lt 20; $i++) {
                Start-Sleep -Seconds 30
                $policy = Az.Migrate.Internal\Get-AzMigratePolicy @PSBoundParameters
                if ($null -eq $policy)
                {
                    continue
                }
                
                # Stop if policy reaches a terminal state
                if ($policy.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Failed) {
                    break
                }
            }

            # Make sure Policy is in a terminal state
            if (-not (
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Failed)) {
                throw "Policy '$($policyName)' times out with Provisioning State: '$($policy.Property.ProvisioningState)' during creation process. Please re-run this command or contact support if help needed."
            }
        }
        
        if ($policy.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "Policy '$($policyName)' has an unexpected Provisioning State of '$($policy.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
        }

        $policy = Az.Migrate.Internal\Get-AzMigratePolicy @PSBoundParameters
        if ($null -eq $policy)
        {
            throw "Unexpected error occurred during policy creation. Please re-run this command or contact support if help needed."
        }
        elseif ($policy.Property.ProvisioningState -ne [ProvisioningState]::Succeeded)
        {
            throw "Policy '$($policyName)' has an unexpected Provisioning State of '$($policy.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
        }
        else
        {
            Write-Host "*Selected Policy: '$($policyName)'"
        }
        $null = $PSBoundParameters.Remove('Name')
        $null = $PSBoundParameters.Remove('VaultName')

        # Put Cache Storage Account
        # Get AMH solution with ResourceGroupName, MigrateProjectName, Name
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

        $amhStoredStorageAccountId = $amhSolution.DetailExtendedDetail["replicationStorageAccountId"]
        
        # Record of rsa found in AMH solution
        if (![string]::IsNullOrEmpty($amhStoredStorageAccountId)) {
            # Get amhStoredStorageAccount with ResourceGroupName, Name
            $amhStoredStorageAccountName = $amhStoredStorageAccountId.Split("/")[8]
            $amhStoredStorageAccount = Get-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $amhStoredStorageAccountName `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue

            # Wait for amhStoredStorageAccount to reach a terminal state
            if ($null -ne $amhStoredStorageAccount -and
                $null -ne $amhStoredStorageAccount.ProvisioningState -and
                $amhStoredStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
                # Check rsa state every 30s if not Succeeded already. Timeout after 10min
                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $amhStoredStorageAccount =  Get-AzStorageAccount `
                        -ResourceGroupName $ResourceGroupName `
                        -Name $amhStoredStorageAccountName `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue
                        # Stop if amhStoredStorageAccount is not found or in a terminal state
                    if ($null -eq $amhStoredStorageAccount -or
                        $null -eq $amhStoredStorageAccount.ProvisioningState -or
                        $amhStoredStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                        break
                    }
                }
            }
            
            # amhStoredStorageAccount exists and in Succeeded state
            if ($null -ne $amhStoredStorageAccount -and
                $amhStoredStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded)
            {
                # Use amhStoredStorageAccount and ignore user provided Cache Storage Account Id
                if (![string]::IsNullOrEmpty($CacheStorageAccountId) -and $amhStoredStorageAccount.Id -ne $CacheStorageAccountId)
                {
                    Write-Host "A Cache Storage Account '$($amhStoredStorageAccountName)' has been linked already. The given -CacheStorageAccountId '$($CacheStorageAccountId)' will be ignored."
                }

                $cacheStorageAccount = $amhStoredStorageAccount

                # This will fix brownfield issue where AMH solution tool is set incorrectly that causes UX bifurcation to go to the wrong experience;
                # for new projects that are set correctly from the start, this will essentially be a no-op.
                Az.Migrate.Internal\Set-AzMigrateSolution `
                    -MigrateProjectName $ProjectName `
                    -Name $amhSolution.Name `
                    -ResourceGroupName $ResourceGroupName `
                    -DetailExtendedDetail $amhSolution.DetailExtendedDetail.AdditionalProperties `
                    -Tool $DataReplicationSolutionSettings.Tool `
                    -Purpose $DataReplicationSolutionSettings.Purpose | Out-Null
            }
            elseif ($null -eq $amhStoredStorageAccount -or $null -eq $amhStoredStorageAccount.ProvisioningState)
            {
                # amhStoredStorageAccount is found but in a bad state, so log to ask user to remove
                if ($null -ne $amhStoredStorageAccount -and $null -eq $amhStoredStorageAccount.ProvisioningState)
                {
                    Write-Host "A previously linked Cache Storage Account with Id '$($amhStoredStorageAccountId)' is found but in a unusable state. Please remove it manually and re-run this command."
                }

                # amhStoredStorageAccount is not found or in a bad state but AMH has a record of it, so remove the record
                if ($amhSolution.DetailExtendedDetail.ContainsKey("replicationStorageAccountId"))
                {
                    $amhSolution.DetailExtendedDetail.Remove("replicationStorageAccountId") | Out-Null
                    $amhSolution.DetailExtendedDetail.Add("replicationStorageAccountId", $null) | Out-Null

                    Az.Migrate.Internal\Set-AzMigrateSolution `
                        -MigrateProjectName $ProjectName `
                        -Name $amhSolution.Name `
                        -ResourceGroupName $ResourceGroupName `
                        -DetailExtendedDetail $amhSolution.DetailExtendedDetail.AdditionalProperties `
                        -Tool $DataReplicationSolutionSettings.Tool `
                        -Purpose $DataReplicationSolutionSettings.Purpose | Out-Null
                }
            }
            else
            {
                throw "A linked Cache Storage Account with Id '$($amhStoredStorageAccountId)' times out with Provisioning State: '$($amhStoredStorageAccount.ProvisioningState)'. Please re-run this command or contact support if help needed."
            }

            # Refresh AMH solution with ResourceGroupName, MigrateProjectName, Name
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
            
            # Check if AMH record is removed
            if (($null -eq $amhStoredStorageAccount -or $null -eq $amhStoredStorageAccount.ProvisioningState) -and
                ![string]::IsNullOrEmpty($amhSolution.DetailExtendedDetail["replicationStorageAccountId"])) {
                throw "Unexpected error occurred in unlinking Cache Storage Account with Id '$($amhSolution.DetailExtendedDetail["replicationStorageAccountId"])'. Please re-run this command or contact support if help needed."
            }
            $null = $PSBoundParameters.Remove('Name')
            $null = $PSBoundParameters.Remove('MigrateProjectName')
        }

        # No linked Cache Storage Account found in AMH solution but user provides a Cache Storage Account Id
        if ($null -eq $cacheStorageAccount -and ![string]::IsNullOrEmpty($CacheStorageAccountId)) {
            $userProvidedStorageAccountIdSegs = $CacheStorageAccountId.Split("/")
            if ($userProvidedStorageAccountIdSegs.Count -ne 9) {
                throw "Invalid Cache Storage Account Id '$($CacheStorageAccountId)' provided. Please provide a valid one."
            }

            $userProvidedStorageAccountName = ($userProvidedStorageAccountIdSegs[8]).ToLower()

            # Check if user provided Cache Storage Account exists
            # Get userProvidedStorageAccount with ResourceGroupName, Name
            $userProvidedStorageAccount = Get-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $userProvidedStorageAccountName `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue

            # Wait for userProvidedStorageAccount to reach a terminal state
            if ($null -ne $userProvidedStorageAccount -and
                $null -ne $userProvidedStorageAccount.ProvisioningState -and
                $userProvidedStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
                # Check rsa state every 30s if not Succeeded already. Timeout after 10min
                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $userProvidedStorageAccount = Get-AzStorageAccount `
                        -ResourceGroupName $ResourceGroupName `
                        -Name $userProvidedStorageAccountName `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue
                    # Stop if userProvidedStorageAccount is not found or in a terminal state
                    if ($null -eq $userProvidedStorageAccount -or
                        $null -eq $userProvidedStorageAccount.ProvisioningState -or
                        $userProvidedStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                        break
                    }
                }
            }

            if ($null -ne $userProvidedStorageAccount -and
                $userProvidedStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                $cacheStorageAccount = $userProvidedStorageAccount
            }
            elseif ($null -eq $userProvidedStorageAccount) {
                throw "Cache Storage Account with Id '$($CacheStorageAccountId)' is not found. Please re-run this command without -CacheStorageAccountId to create one automatically or re-create the Cache Storage Account yourself and try again."
            }
            elseif ($null -eq $userProvidedStorageAccount.ProvisioningState) {
                throw "Cache Storage Account with Id '$($CacheStorageAccountId)' is found but in an unusable state. Please re-run this command without -CacheStorageAccountId to create one automatically or re-create the Cache Storage Account yourself and try again."
            }
            else {
                throw "Cache Storage Account with Id '$($CacheStorageAccountId)' is found but times out with Provisioning State: '$($userProvidedStorageAccount.ProvisioningState)'. Please re-run this command or contact support if help needed."
            }
        }

        # No Cache Storage Account found or provided, so create one
        if ($null -eq $cacheStorageAccount) {
            $suffix = (GenerateHashForArtifact -Artifact "$($sourceSiteId)/$($SourceApplianceName)").ToString()
            if ($suffixHash.Length -gt 14) {
                $suffix = $suffixHash.Substring(0, 14)
            }
            $cacheStorageAccountName = "migratersa" + $suffix
            $cacheStorageAccountId = "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.Storage/storageAccounts/$($cacheStorageAccountName)"

            # Check if default Cache Storage Account already exists, which it shouldn't
            # Get cacheStorageAccount with ResourceGroupName, Name
            $cacheStorageAccount = Get-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $cacheStorageAccountName `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            if ($null -ne $cacheStorageAccount) {
                throw "Unexpected error encountered: Cache Storage Account '$($cacheStorageAccountName)' already exists. Please re-run this command to create a different one or contact support if help needed."
            }

            Write-Host "Creating Cache Storage Account with default name '$($cacheStorageAccountName)'..."

            $params = @{
                name                                = $cacheStorageAccountName;
                location                            = $migrateProject.Location;
                migrateProjectName                  = $migrateProject.Name;
                skuName                             = "Standard_LRS";
                tags                                = @{ "Migrate Project" = $migrateProject.Name };
                kind                                = "StorageV2";
                encryption                          = @{ services = @{blob = @{ enabled = $true }; file = @{ enabled = $true } } };
            }

            # Create Cache Storage Account
            $cacheStorageAccount = New-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $params.name `
                -SkuName $params.skuName `
                -Location $params.location `
                -Kind $params.kind `
                -Tags $params.tags `
                -AllowBlobPublicAccess $true

            if ($null -ne $cacheStorageAccount -and
                $null -ne $cacheStorageAccount.ProvisioningState -and
                $cacheStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
                # Check rsa state every 30s if not Succeeded already. Timeout after 10min
                # Get cacheStorageAccount with ResourceGroupName, Name
                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30

                    $cacheStorageAccount = Get-AzStorageAccount `
                        -ResourceGroupName $ResourceGroupName `
                        -Name $cacheStorageAccountName `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue
                    # Stop if cacheStorageAccount is not found or in a terminal state
                    if ($null -eq $cacheStorageAccount -or
                        $null -eq $cacheStorageAccount.ProvisioningState -or
                        $cacheStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                        break
                    }
                }
            }

            if ($null -eq $cacheStorageAccount -or $null -eq $cacheStorageAccount.ProvisioningState) {
                throw "Unexpected error occurs during Cache Storage Account creation process. Please re-run this command or provide -CacheStorageAccountId of the one created own your own."
            }
            elseif ($cacheStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
                throw "Cache Storage Account with Id '$($cacheStorageAccount.Id)' times out with Provisioning State: '$($cacheStorageAccount.ProvisioningState)' during creation process. Please remove it manually and re-run this command or contact support if help needed."
            }
        }

        # Sanity check
        if ($null -eq $cacheStorageAccount -or
            $null -eq $cacheStorageAccount.ProvisioningState -or
            $cacheStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
            throw "Unexpected error occurs during Cache Storage Account selection process. Please re-run this command or contact support if help needed."
        }

        $params = @{
            contributorRoleDefId                = [System.Guid]::parse($RoleDefinitionIds.ContributorId);
            storageBlobDataContributorRoleDefId = [System.Guid]::parse($RoleDefinitionIds.StorageBlobDataContributorId);
            sourceAppAadId                      = $sourceDra.Property.ResourceAccessIdentity.ObjectId;
            targetAppAadId                      = $targetDra.Property.ResourceAccessIdentity.ObjectId;
        }

        # Grant vault Identity Aad access to Cache Storage Account
        if (![string]::IsNullOrEmpty($replicationVault.IdentityPrincipalId))
        {
            $params.vaultIdentityAadId = $replicationVault.IdentityPrincipalId

            # Grant vault Identity Aad access to Cache Storage Account as "Contributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.vaultIdentityAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            if ($null -eq $hasAadAppAccess) {
                New-AzRoleAssignment `
                    -ObjectId $params.vaultIdentityAadId `
                    -RoleDefinitionId $params.contributorRoleDefId `
                    -Scope $cacheStorageAccount.Id | Out-Null
            }
    
            # Grant vault Identity Aad access to Cache Storage Account as "StorageBlobDataContributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.vaultIdentityAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            if ($null -eq $hasAadAppAccess) {
                New-AzRoleAssignment `
                    -ObjectId $params.vaultIdentityAadId `
                    -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                    -Scope $cacheStorageAccount.Id | Out-Null
            }
        }

        # Grant Source Dra AAD App access to Cache Storage Account as "Contributor"
        $hasAadAppAccess = Get-AzRoleAssignment `
            -ObjectId $params.sourceAppAadId `
            -RoleDefinitionId $params.contributorRoleDefId `
            -Scope $cacheStorageAccount.Id `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $hasAadAppAccess) {
            New-AzRoleAssignment `
                -ObjectId $params.sourceAppAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id | Out-Null
        }

        # Grant Source Dra AAD App access to Cache Storage Account as "StorageBlobDataContributor"
        $hasAadAppAccess = Get-AzRoleAssignment `
            -ObjectId $params.sourceAppAadId `
            -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
            -Scope $cacheStorageAccount.Id `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $hasAadAppAccess) {
            New-AzRoleAssignment `
                -ObjectId $params.sourceAppAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id | Out-Null
        }

        # Grant Target Dra AAD App access to Cache Storage Account as "Contributor"
        $hasAadAppAccess = Get-AzRoleAssignment `
            -ObjectId $params.targetAppAadId `
            -RoleDefinitionId $params.contributorRoleDefId `
            -Scope $cacheStorageAccount.Id `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $hasAadAppAccess) {
            New-AzRoleAssignment `
                -ObjectId $params.targetAppAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id | Out-Null
        }

        # Grant Target Dra AAD App access to Cache Storage Account as "StorageBlobDataContributor"
        $hasAadAppAccess = Get-AzRoleAssignment `
            -ObjectId $params.targetAppAadId `
            -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
            -Scope $cacheStorageAccount.Id `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $hasAadAppAccess) {
            New-AzRoleAssignment `
                -ObjectId $params.targetAppAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id | Out-Null
        }

        # Give time for role assignments to be created. Times out after 2min
        $rsaPermissionGranted = $false
        for ($i = 0; $i -lt 3; $i++) {
            # Check Source Dra AAD App access to Cache Storage Account as "Contributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.sourceAppAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            $rsaPermissionGranted = $null -ne $hasAadAppAccess

            # Check Source Dra AAD App access to Cache Storage Account as "StorageBlobDataContributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.sourceAppAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            $rsaPermissionGranted = $rsaPermissionGranted -and ($null -ne $hasAadAppAccess)

            # Check Target Dra AAD App access to Cache Storage Account as "Contributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.targetAppAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            $rsaPermissionGranted = $rsaPermissionGranted -and ($null -ne $hasAadAppAccess)

            # Check Target Dra AAD App access to Cache Storage Account as "StorageBlobDataContributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.targetAppAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            $rsaPermissionGranted = $rsaPermissionGranted -and ($null -ne $hasAadAppAccess)

            if ($rsaPermissionGranted) {
                break
            }

            Start-Sleep -Seconds 30
        }

        if (!$rsaPermissionGranted) {
            throw "Failed to grant Cache Storage Account permissions. Please re-run this command or contact support if help needed."
        }

        # Refresh AMH solution with ResourceGroupName, MigrateProjectName, Name
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

        if ($amhSolution.DetailExtendedDetail.ContainsKey("replicationStorageAccountId")) {
            $amhStoredStorageAccountId = $amhSolution.DetailExtendedDetail["replicationStorageAccountId"]
            if ([string]::IsNullOrEmpty($amhStoredStorageAccountId)) {
                # Remove "replicationStorageAccountId" key
                $amhSolution.DetailExtendedDetail.Remove("replicationStorageAccountId")  | Out-Null
            }
            elseif ($amhStoredStorageAccountId -ne $cacheStorageAccount.Id) {
                # Record of rsa mismatch
                throw "Unexpected error occurred in linking Cache Storage Account with Id '$($cacheStorageAccount.Id)'. Please re-run this command or contact support if help needed."
            }
        }

        # Update AMH record with chosen Cache Storage Account
        if (!$amhSolution.DetailExtendedDetail.ContainsKey("replicationStorageAccountId"))
        {
            $amhSolution.DetailExtendedDetail.Add("replicationStorageAccountId", $cacheStorageAccount.Id)

            Az.Migrate.Internal\Set-AzMigrateSolution `
                -MigrateProjectName $ProjectName `
                -Name $amhSolution.Name `
                -ResourceGroupName $ResourceGroupName `
                -DetailExtendedDetail $amhSolution.DetailExtendedDetail.AdditionalProperties `
                -Tool $DataReplicationSolutionSettings.Tool `
                -Purpose $DataReplicationSolutionSettings.Purpose | Out-Null
        }

        Write-Host "*Selected Cache Storage Account: '$($cacheStorageAccount.StorageAccountName)' in Resource Group '$($ResourceGroupName)' at Location '$($cacheStorageAccount.Location)' for Migrate Project '$($migrateProject.Name)'"

        # Put replication extension
        $replicationExtensionName = ($sourceFabric.Id -split '/')[-1] + "-" + ($targetFabric.Id -split '/')[-1] + "-MigReplicationExtn"
        # Get replicationExtension with ResourceGroupName, VaultName, Name
        $null = $PSBoundParameters.Add('Name', $replicationExtensionName)
        $null = $PSBoundParameters.Add('VaultName', $replicationVaultName)
        $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension @PSBoundParameters
        $null = $PSBoundParameters.Remove('Name')
        $null = $PSBoundParameters.Remove('VaultName')

        # Remove replication extension if does not match the selected Cache Storage Account
        if ($null -ne $replicationExtension -and $replicationExtension.Property.CustomProperty.StorageAccountId -ne $cacheStorageAccount.Id) {
            Write-Host "Replication Extension '$($replicationExtensionName)' found but linked to a different Cache Storage Account '$($replicationExtension.Property.CustomProperty.StorageAccountId)'."
        
            try {
                Az.Migrate.Internal\Remove-AzMigrateReplicationExtension -InputObject $replicationExtension | Out-Null
            }
            catch {
                if ($_.Exception.Message -notmatch "Status: OK") {
                    throw $_.Exception.Message
                }
            }

            Write-Host "Removing Replication Extension and waiting for 2 minutes..."
            Start-Sleep -Seconds 120
            $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                -InputObject $replicationExtension `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue

            if ($null -eq $replicationExtension) {
                Write-Host "Replication Extension '$($replicationExtensionName)' was removed."
            }
        }

        # Replication extension exists
        if ($null -ne $replicationExtension) {
            # Give time for create/update to reach a terminal state. Timeout after 10min
            if ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Updating) {
                Write-Host "Replication Extension '$($replicationExtensionName)' found in Provisioning State '$($replicationExtension.Property.ProvisioningState)'."

                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                        -InputObject $replicationExtension `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue

                    if (-not (
                            $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                            $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Updating)) {
                        break
                    }
                }

                # Make sure replication extension is no longer in Creating or Updating state
                if ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Updating) {
                    throw "Replication Extension '$($replicationExtensionName)' times out with Provisioning State: '$($replicationExtension.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
                }
            }

            # Check and remove if replication extension is in a bad terminal state
            if ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Failed) {
                Write-Host "Replication Extension '$($replicationExtensionName)' found but in an unusable terminal Provisioning State '$($replicationExtension.Property.ProvisioningState)'.`nRemoving Replication Extension..."
                    
                # Remove replication extension
                try {
                    Az.Migrate.Internal\Remove-AzMigrateReplicationExtension -InputObject $replicationExtension | Out-Null
                }
                catch {
                    if ($_.Exception.Message -notmatch "Status: OK") {
                        throw $_.Exception.Message
                    }
                }

                Start-Sleep -Seconds 30
                $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                    -InputObject $replicationExtension `
                    -ErrorVariable notPresent `
                    -ErrorAction SilentlyContinue

                # Make sure replication extension is no longer in Canceled or Failed state
                if ($null -ne $replicationExtension -and
                    ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Failed)) {
                    throw "Failed to change the Provisioning State of Replication Extension '$($replicationExtensionName)'by removing. Please re-run this command or contact support if help needed."
                }
            }

            # Give time to remove replication extension. Timeout after 10min
            if ($null -ne $replicationExtension -and
                $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                Write-Host "Replication Extension '$($replicationExtensionName)' found in Provisioning State '$($replicationExtension.Property.ProvisioningState)'."

                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                        -InputObject $replicationExtension `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue

                    if ($null -eq $replicationExtension -or $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
                        break
                    }
                    elseif ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                        continue
                    }

                    throw "Replication Extension '$($replicationExtensionName)' has an unexpected Provisioning State of '$($replicationExtension.Property.ProvisioningState)' during removal process. Please re-run this command or contact support if help needed."
                }

                # Make sure replication extension is no longer in Deleting state
                if ($null -ne $replicationExtension -and $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                    throw "Replication Extension '$($replicationExtensionName)' times out with Provisioning State: '$($replicationExtension.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
                }
            }

            # Indicate replication extension was removed
            if ($null -eq $replicationExtension -or $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
                Write-Host "Replication Extension '$($replicationExtensionName)' was removed."
            }
        }

        # Refresh local replication extension object if exists
        if ($null -ne $replicationExtension) {
            $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension -InputObject $replicationExtension
        }

        # Create replication extension if not found or previously deleted
        if ($null -eq $replicationExtension -or $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
            Write-Host "Waiting 2 minutes for permissions to sync before creating Replication Extension..."
            Start-Sleep -Seconds 120

            Write-Host "Creating Replication Extension..."
            $params = @{
                InstanceType                = $instanceType;
                SourceFabricArmId           = $sourceFabric.Id;
                TargetFabricArmId           = $targetFabric.Id;
                StorageAccountId            = $cacheStorageAccount.Id;
                StorageAccountSasSecretName = $null;
            }

            # Setup Replication Extension deployment parameters
            $replicationExtensionProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ReplicationExtensionModelProperties]::new()
        
            if ($instanceType -eq $AzLocalInstanceTypes.HyperVToAzLocal) {
                $replicationExtensionCustomProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHcireplicationExtensionModelCustomProperties]::new()
                $replicationExtensionCustomProperties.HyperVFabricArmId = $params.SourceFabricArmId
                
            }
            elseif ($instanceType -eq $AzLocalInstanceTypes.VMwareToAzLocal) {
                $replicationExtensionCustomProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHcireplicationExtensionModelCustomProperties]::new()
                $replicationExtensionCustomProperties.VMwareFabricArmId = $params.SourceFabricArmId
            }
            else {
                throw "Currently, for AzLocal scenario, only HyperV and VMware as the source is supported."
            }
            $replicationExtensionCustomProperties.InstanceType = $params.InstanceType
            $replicationExtensionCustomProperties.AzStackHCIFabricArmId = $params.TargetFabricArmId
            $replicationExtensionCustomProperties.StorageAccountId = $params.StorageAccountId
            $replicationExtensionCustomProperties.StorageAccountSasSecretName = $params.StorageAccountSasSecretName
            $replicationExtensionProperties.CustomProperty = $replicationExtensionCustomProperties

            try {
                Az.Migrate.Internal\New-AzMigrateReplicationExtension `
                    -Name $replicationExtensionName `
                    -ResourceGroupName $ResourceGroupName `
                    -VaultName $replicationVaultName `
                    -Property $replicationExtensionProperties `
                    -SubscriptionId $SubscriptionId `
                    -NoWait | Out-Null
            }
            catch {
                if ($_.Exception.Message -notmatch "Status: OK") {
                    throw $_.Exception.Message
                }
            }

            # Check replication extension creation status every 30s. Timeout after 10min
            # Get replicationExtension with ResourceGroupName, VaultName, Name
            $null = $PSBoundParameters.Add('Name', $replicationExtensionName)
            $null = $PSBoundParameters.Add('VaultName', $replicationVaultName)
            for ($i = 0; $i -lt 20; $i++) {
                Start-Sleep -Seconds 30

                $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension @PSBoundParameters

                if ($null -eq $replicationExtension) {
                   continue
                }
                
                # Stop if replication extension reaches a terminal state
                if ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Failed) {
                    break
                }
            }
            $null = $PSBoundParameters.Remove('Name')
            $null = $PSBoundParameters.Remove('VaultName')

            # Make sure replicationExtension is in a terminal state
            if (-not (
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Failed)) {
                throw "Replication Extension '$($replicationExtensionName)' times out with Provisioning State: '$($replicationExtension.Property.ProvisioningState)' during creation process. Please re-run this command or contact support if help needed."
            }
        }
        
        if ($replicationExtension.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "Replication Extension '$($replicationExtensionName)' has an unexpected Provisioning State of '$($replicationExtension.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
        }

        # Get replicationExtension with ResourceGroupName, VaultName, Name
        $null = $PSBoundParameters.Add('Name', $replicationExtensionName)
        $null = $PSBoundParameters.Add('VaultName', $replicationVaultName)
        $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension @PSBoundParameters
        if ($null -eq $replicationExtension) {
            throw "Unexpected error occurred during Replication Extension creation. Please re-run this command or contact support if help needed."
        }
        elseif ($replicationExtension.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "Replication Extension '$($replicationExtensionName)' has an unexpected Provisioning State of '$($replicationExtension.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
        }
        else {
            Write-Host "*Selected Replication Extension: '$($replicationExtensionName)'"
        }
        $null = $PSBoundParameters.Remove('Name')
        $null = $PSBoundParameters.Remove('VaultName')
        $null = $PSBoundParameters.Remove('ResourceGroupName')

        if ($PassThru) {
            return $true
        }
    }
}
# SIG # Begin signature block
# MIIoVQYJKoZIhvcNAQcCoIIoRjCCKEICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAV9k727n3fqXqn
# 2n39ohq21xxM1kayYAkNkZfb42IEn6CCDYUwggYDMIID66ADAgECAhMzAAAEhJji
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGiYwghoiAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAASEmOIS4HijMV0AAAAA
# BIQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEJb
# +0+il0Rchl+t0UYp8MNxjBc6Mj01YcwYs5U3GPxGMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAP9Bd4Fc0/P8ElpVoH77tsiU4UMnL21V/gGrr
# G/h0rNbLc2iH5RJUXUDG9KL6ko5Xfmuu4NAug/JnIV+veTej8tEda0qikwosHnf6
# VkSJtnFrbMdDwPSJmu73lxFYAP11d1+TtxHX4ncFuoXyajLYBkO8zrFYU3H4Owyl
# FoNZMdD947WRq4eode09SlJu3C1hNp440M0YnCm2vQLbYo166f+QNxyvJqfZ1tHh
# 3SsGd75PxJHEZIZ7t47JTZTDDyFfgFA2EMkZTN3dTNeZ+x29loimPdPXKVUhA/lW
# EX64TMcwnO4Z8CTC0BoFKntVy9K85DjRnTKctXoxs8NHMYPmyqGCF7AwghesBgor
# BgEEAYI3AwMBMYIXnDCCF5gGCSqGSIb3DQEHAqCCF4kwgheFAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCC9+KJk4N1c0rLwanKvqni7Kk76xcy4RJgy
# xldbO8HxKAIGaUMuaxsMGBMyMDI2MDExMDAxMTUxMC40NzlaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo0QzFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEf4wggcoMIIFEKADAgECAhMzAAACGCXZ
# kgXi5+XkAAEAAAIYMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI1MDgxNDE4NDgyNVoXDTI2MTExMzE4NDgyNVowgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjRDMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# sdzo6uuQJqAfxLnvEBfIvj6knK+p6bnMXEFZ/QjPOFywlcjDfzI8Dg1nzDlxm7/p
# qbvjWhyvazKmFyO6qbPwClfRnI57h5OCixgpOOCGJJQIZSTiMgui3B8DPiFtJPcf
# zRt3FsnxjLXwBIjGgnjGfmQl7zejA1WoYL/qBmQhw/FDFTWebxfo4m0RCCOxf2qw
# j31aOjc2aYUePtLMXHsXKPFH0tp5SKIF/9tJxRSg0NYEvQqVilje8aQkPd3qzAux
# 2Mc5HMSK4NMTtVVCYAWDUZ4p+6iDI9t5BNCBIsf5ooFNUWtxCqnpFYiLYkHfFfxh
# VUBZ8LGGxYsA36snD65s2Hf4t86k0e8WelH/usfhYqOM3z2yaI8rg08631IkwqUz
# yQoEPqMsHgBem1xpmOGSIUnVvTsAv+lmECL2RqrcOZlZax8K0aiij8h6UkWBN2IA
# /ikackTSGVRBQmWWZuLFWV/T4xuNzscC0X7xo4fetgpsqaEA0jY/QevkTvLv4OlN
# N9eOL8LNh7Vm0R65P7oabOQDqtUFAwCgjgPJ0iV/jQCaMAcO3SYpG5wSAYiJkk4X
# LjNSlNxU2Idjs1sORhl7s7LC6hOb7bVAHVwON74GxfFNiEIA6BfudANjpQJ0nUc/
# ppEXpT4pgDBHsYtV8OyKSjKsIxOdFR7fIJIjDc8DvUkCAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBQkLqHEXDobY7dHuoQCBa4sX7aL0TAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAnkjRhjwPgdoIpvt4YioT/j0LWuBxF3ARBKXDENggraKvC0oRPwbjAmsX
# nPEmtuo5MD8uJ9Xw9eYrxqqkK4DF9snZMrHMfooxCa++1irLz8YoozC4tci+a4N3
# 7Sbke1pt1xs9qZtvkPgZGWn5BcwVfmAwSZLHi2CuZ06Y0/X+t6fNBnrbMVovNaDX
# 4WPdyI9GEzxfIggDsck2Ipo4VXL/Arcz7p2F7bEZGRuyxjgMC+woCkDJaH/yk/wc
# ZpAsixe4POdN0DW6Zb35O3Dg3+a6prANMc3WIdvfKDl75P0aqcQbQAR7b0f4gH4N
# MkUct0Wm4GN5KhsE1YK7V/wAqDKmK4jx3zLz3a8Hsxa9HB3GyitlmC5sDhOl4QTG
# N5kRi6oCoV4hK+kIFgnkWjHhSRNomz36QnbCSG/BHLEm2GRU9u3/I4zUd9E1AC97
# IJEGfwb+0NWb3QEcrkypdGdWwl0LEObhrQR9B1V7+edcyNmsX0p2BX0rFpd1PkXJ
# Sbxf8IcEiw/bkNgagZE+VlDtxXeruLdo5k3lGOv7rPYuOEaoZYxDvZtpHP9P36wm
# W4INjR6NInn2UM+krP/xeLnRbDBkm9RslnoDhVraliKDH62BxhcgL9tiRgOHlcI0
# wqvVWLdv8yW8rxkawOlhCRqT3EKECW8ktUAPwNbBULkT+oWcvBcwggdxMIIFWaAD
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
# 2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIDWTCCAkECAQEwggEBoYHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo0QzFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAnWtGrXWiuNE8
# QrKfm4CtGr57z+mggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAO0L/kgwIhgPMjAyNjAxMDkyMjIzMDRaGA8yMDI2
# MDExMDIyMjMwNFowdzA9BgorBgEEAYRZCgQBMS8wLTAKAgUA7Qv+SAIBADAKAgEA
# AgIj/gIB/zAHAgEAAgITRzAKAgUA7Q1PyAIBADA2BgorBgEEAYRZCgQCMSgwJjAM
# BgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEB
# CwUAA4IBAQDEWmu40fPwK97d5toMXNERz3czWIQCYfn06esmb3CMjJZovkAPcst1
# g5WTRxNRfKFgP4RyHoxc+FneNS0CTbhxLgEPoUW+orGPcTYw3zuucSBCuhiT32X9
# G6IxpSM5G4IJrh/QkVCgIBIkvXOk7WL0u9sv0rrg3M+kld4assUwsRulVBiWF4+M
# aM0FArQpaIRT8u7Hq2++dDd4hxLHUvAdyOJ0IyhFNzdOZ3SwV3xSN7C/RSdqtwjA
# G9N2ouuTmQ3gnqsC8s2+9wHnPBLLCwwuw3mVyNey0DoOmE7OVts1ohoGWfnYVPWL
# nL5acDon4ngu1ocs9tVZFn0swBxh4qXfMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAIYJdmSBeLn5eQAAQAAAhgwDQYJYIZI
# AWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG
# 9w0BCQQxIgQgVE5esSfRyfOtNGnqEdy1igbmkta6RZaILz80ik/jQSswgfoGCyqG
# SIb3DQEJEAIvMYHqMIHnMIHkMIG9BCCZE9yJuOTItIwWaES6lzGKK1XcSoz1ynRz
# aOVzx9eFajCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMz
# AAACGCXZkgXi5+XkAAEAAAIYMCIEIGqOkVDYm7kSjyXTrUlgQjA48aQ7dd/9BFdm
# R4u6bTJgMA0GCSqGSIb3DQEBCwUABIICABEY/KZsCLicgXfIyioRG7zoLrJn+n3S
# 2qY1tyQlT6eGgpzF8+g15Woyq7S5esGvgisIpTW5wqdHdJ8k71FCop3fojt0CkUf
# LffWCArgHOhA9ZznxWwkg4iGAOMul8Hh+IoOrg0P00sQGW/ulYXK78581BbbI2oL
# 2o+cyesJ7by9xv/f9DfJppTpVA22yWFXFztYfy7W71eXQ7P8OnCaKJ8Ucaxufnnd
# UIpSNNTjDx2Xjx7hIiYesHLfk0P0O4gHHVzhGszY7P4nKI6SfVuc5D4LAEvRuwpW
# 1Cn/FV188P3qNvsx2LzTJUniSxKYhUQv0Urg9Eenms6PKScxg+HSWyTWBBVxGZAH
# u4UtnG4Pb8cCNWRBtbK53jv8VSKSn5u7jjsrKnihdxWe2x43UCmTDWAfh+q3V/fN
# 5bai4DRevPC8Ew0Ym8prHbgIHQyVRSQ9+yOTz1o89mCOQgeq9MlIuSjmYk8O1Qha
# IZGps4bS9B9Ol2zOHq8R3QLEbrNca24xKmdumhGFrUrAEDUGoGTSTGacJSfKA38y
# 8bcOLQu04ZYoLzV5tS1VAqy3wbOenKK9xsmISopXhn/WKyj+5Fary0T5xnUmZviG
# Xej51JIJQ1a4gYviTHPBAs4DRH/XhnKCcK3yC1CUBXomITx+qjgcml0kClHK5ufG
# M9rboZyyjDdz
# SIG # End signature block

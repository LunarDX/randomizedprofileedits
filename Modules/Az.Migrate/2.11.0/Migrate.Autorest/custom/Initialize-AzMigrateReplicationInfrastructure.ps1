
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

function Create-RoleAssignments(
    [string]$objectId,
    [string]$saId) {

    $storageBlobDataContributorRoleDefinitionId = [System.Guid]::parse($RoleDefinitionIds.StorageBlobDataContributorId)
    $contributorRoleDefinitionId = [System.Guid]::parse($RoleDefinitionIds.ContributorId)
    $existingRoleAssignments = Get-AzRoleAssignment -ObjectId $objectId -Scope $saId -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if (-not $existingRoleAssignments) {
        Write-Host "Creating role assignments for object" $objectId
        $output = New-AzRoleAssignment -ObjectId $objectId -Scope $saId -RoleDefinitionId $storageBlobDataContributorRoleDefinitionId
        $output = New-AzRoleAssignment -ObjectId $objectId -Scope $saId -RoleDefinitionId $contributorRoleDefinitionId
    }
}

<#
.Synopsis
Initialises the infrastructure for the migrate project.
.Description
The Initialize-AzMigrateReplicationInfrastructure cmdlet initialises the infrastructure for the migrate project.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/initialize-azmigratereplicationinfrastructure
#>
function Initialize-AzMigrateReplicationInfrastructure {
    [OutputType([System.Boolean])]
    [CmdletBinding(DefaultParameterSetName = 'agentlessVMware', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    
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

        [Parameter(Mandatory)]
        [ValidateSet("agentlessVMware")]
        [ArgumentCompleter( { "agentlessVMware" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the server migration scenario for which the replication infrastructure needs to be initialized.
        ${Scenario},

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the target Azure region for server migrations.
        ${TargetRegion},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Storage Account Id to be used for private endpoint scenario.
        ${CacheStorageAccountId},

        [Parameter()]
        [System.String]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
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
        Import-Module Az.Resources
        Import-Module Az.Storage
        Import-Module Az.RecoveryServices
        $helperPath = [System.IO.Path]::Combine($PSScriptRoot, "Helper", "AzLocalCommonSettings.ps1")
        Import-Module $helperPath
        
        # Validate user specified target region
        $TargetRegion = $TargetRegion.ToLower()
        $allAvailableAzureLocations = Get-AzLocation
        $matchingLocationByLocationName = $allAvailableAzureLocations | Where-Object { $_.Location -eq $TargetRegion }
        $matchingLocationByDisplayName = $allAvailableAzureLocations | Where-Object { $_.DisplayName -eq $TargetRegion }
       
        if ($matchingLocationByLocationName) {
            $TargetRegion = $matchingLocationByLocationName.Location
        }
        elseif ($matchingLocationByDisplayName) {
            $TargetRegion = $matchingLocationByDisplayName.Location
        }
        elseif ($TargetRegion -match "euap") {
        }
        else {
            throw "Creation of resources required for replication failed due to invalid location. Run Get-AzLocation to verify the validity of the location and retry this step."
        }
       
        # Get/Set SubscriptionId
        if (($null -eq $SubscriptionId) -or ($SubscriptionId -eq "")) {
            $context = Get-AzContext
            $SubscriptionId = $context.Subscription.Id
            if (($null -eq $SubscriptionId) -or ($SubscriptionId -eq "")) {
                throw "Please login to Azure to select a subscription."
            }
        }
        else {
            Select-AzSubscription -SubscriptionId $SubscriptionId
        }
        $context = Get-AzContext
        Write-Host "Using Subscription Id: ", $SubscriptionId
        Write-Host "Selected Target Region: ", $TargetRegion
        
        $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if (!$rg) {
            Write-Host "Creating Resource Group ", $ResourceGroupName
            $output = New-AzResourceGroup -Name $ResourceGroupName -Location $TargetRegion
            Write-Host $ResourceGroupName, " created."
        }
        Write-Host "Selected resource group : ", $ResourceGroupName

        $LogStringCreated = "Created : "
        $LogStringSkipping = " already exists."

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
            $userObject = Get-AzADServicePrincipal -ApplicationID $context.Account.Id
        }

        if (-not $userObject) {
            throw 'User Object Id Not Found!'
        }

        # Hash code source code
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

        #Get vault name from SMS solution.
        $smsSolution = Get-AzMigrateSolution -MigrateProjectName $ProjectName -ResourceGroupName $ResourceGroupName -Name "Servers-Migration-ServerMigration"
        if (-not $smsSolution.DetailExtendedDetail.AdditionalProperties.vaultId) {
            throw 'Azure Migrate appliance not configured. Setup Azure Migrate appliance before proceeding.'
        }
        $VaultName = $smsSolution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]
        $VaultDetails = Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName
        $isPublicScenario = $VaultDetails.Properties.PrivateEndpointStateForSiteRecovery -eq "None"


        # Get all appliances and sites in the project from SDS solution.
        $sdsSolution = Get-AzMigrateSolution -MigrateProjectName $ProjectName -ResourceGroupName $ResourceGroupName -Name "Servers-Discovery-ServerDiscovery"
        $appMap = @{}

        if ($null -ne $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"]) {
            $appMapV2 = $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] | ConvertFrom-Json
            # Fetch all appliance from V2 map first. Then these can be updated if found again in V3 map.
            foreach ($item in $appMapV2) {
                $appMap[$item.ApplianceName] = $item.SiteId
            }
        }

        if ($null -ne $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"]) {
            $appMapV3 = $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] | ConvertFrom-Json
            foreach ($item in $appMapV3) {
                $t = $item.psobject.properties
                $appMap[$t.Name] = $t.Value.SiteId
            }
        }

        if ($null -eq $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] -And
            $null -eq $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] ) {
            throw "Server Discovery Solution missing Appliance Details. Invalid Solution."           
        }

        foreach ($eachApp in $appMap.GetEnumerator()) {
            $SiteName = $eachApp.Value.Split("/")[8]
            $applianceName = $eachApp.Key

            # User cannot change location if it's already set in mapping.
            $mappingName = "containermapping"
            $allFabrics = Get-AzMigrateReplicationFabric -ResourceGroupName $ResourceGroupName -ResourceName $VaultName

            foreach ($fabric in $allFabrics) {
                if (($fabric.Property.CustomDetail.InstanceType -eq "VMwareV2") -and ($fabric.Property.CustomDetail.VmwareSiteId.Split("/")[8] -eq $SiteName)) {
                    $fabricName = $fabric.Name
                    $HashCodeInput = $fabric.Id
                    $peContainers = Get-AzMigrateReplicationProtectionContainer -FabricName $fabric.Name -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
                    $peContainer = $peContainers[0]
                    $existingMapping = Get-AzMigrateReplicationProtectionContainerMapping -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -FabricName $fabric.Name -ProtectionContainerName $peContainer.Name -MappingName $mappingName -ErrorVariable notPresent -ErrorAction SilentlyContinue
                    if (($existingMapping) -and ($existingMapping.ProviderSpecificDetail.TargetLocation -ne $TargetRegion)) {
                        $targetRegionMismatchExceptionMsg = $ProjectName + " is already configured for migrating servers to " + $TargetRegion + ". Target Region cannot be modified once configured."
                        throw $targetRegionMismatchExceptionMsg
                    }

                    if (($isPublicScenario) -and ($CacheStorageAccountId) -and ($existingMapping) -and ($existingMapping.ProviderSpecificDetail.StorageAccountId -ne $CacheStorageAccountId)) {
                        $saMismatchExceptionMsg = $applianceName + " is already configured for migrating servers with storage account " + $existingMapping.ProviderSpecificDetail.StorageAccountId + ". Storage account cannot be modified once configured."
                        throw $saMismatchExceptionMsg
                    }
                }
            }

            $job = Start-Job -ScriptBlock {
                Add-Type -TypeDefinition $args[0] -Language CSharp 
                $hash = [HashFunctions]::hashForArtifact($args[1]) 
                $hash
            } -ArgumentList $Source, $HashCodeInput
            Wait-Job $job
            $hash = Receive-Job $job

            Write-Host "Initiating Artifact Creation for Appliance: ", $applianceName
            $MigratePrefix = "migrate"
            
            if ($isPublicScenario) {
                # Phase 1
                # Storage account
                if ([string]::IsNullOrEmpty($CacheStorageAccountId)) {
                    if (!$existingMapping) {
                        $ReplicationStorageAcName = $MigratePrefix + "rsa" + $hash
                        $StorageType = "Microsoft.Storage/storageAccounts"
                        $StorageApiVersion = "2017-10-01" 
                        $ReplicationStorageProperties = @{
                            encryption               = @{
                                services  = @{
                                    blob  = @{enabled = $true };
                                    file  = @{enabled = $true };
                                    table = @{enabled = $true };
                                    queue = @{enabled = $true }
                                };
                                keySource = "Microsoft.Storage"
                            };
                            supportsHttpsTrafficOnly = $true
                        }
                        $ResourceTag = @{"Migrate Project" = $ProjectName }
                        $StorageSku = @{name = "Standard_LRS" }
                        $ResourceKind = "Storage"

                        $replicationStorageAccount = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $ReplicationStorageAcName -ErrorVariable notPresent -ErrorAction SilentlyContinue
                        if (!$replicationStorageAccount) {
                            $output = New-AzResource -ResourceGroupName $ResourceGroupName -Location $TargetRegion -Properties  $ReplicationStorageProperties -ResourceName $ReplicationStorageAcName -ResourceType  $StorageType -ApiVersion $StorageApiVersion -Kind  $ResourceKind -Sku  $StorageSku -Tag $ResourceTag -Force
                            Write-Host $LogStringCreated, $ReplicationStorageAcName
                        }
                        elseif ($replicationStorageAccount.Location -ne $TargetRegion){
                            throw "Storage account with name '$($ReplicationStorageAcName)' already exists in '$($replicationStorageAccount.Location)'. You can either migrate to '$($replicationStorageAccount.Location)' or delete the existing storage account."
                        }
                        else {
                             Write-Host $ReplicationStorageAcName, $LogStringSkipping
                        }

                        # Locks
                        $CommonLockName = $ProjectName + "lock"
                        $lockNotes = "This is in use by Azure Migrate project"
                        $rsaLock = Get-AzResourceLock -LockName $CommonLockName -ResourceName $ReplicationStorageAcName -ResourceType $StorageType -ResourceGroupName $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
                        if (!$rsaLock) {
                            $output = New-AzResourceLock -LockLevel CanNotDelete -LockName $CommonLockName -ResourceName $ReplicationStorageAcName -ResourceType $StorageType -ResourceGroupName $ResourceGroupName -LockNotes $lockNotes -Force
                            Write-Host $LogStringCreated, $CommonLockName, " for ", $ReplicationStorageAcName
                        }
                        else {
                            Write-Host $CommonLockName, " for ", $ReplicationStorageAcName, $LogStringSkipping
                        }
                    }
                }
                else {
                    $ReplicationStorageAcName = $CacheStorageAccountId.Split("/")[-1]
                    $response = Get-AzResource -ResourceId $CacheStorageAccountId -ErrorVariable notPresent -ErrorAction SilentlyContinue
                    if ($response -eq $null) {
                        throw "Storage account '$($CacheStorageAccountId)' does not exist."
                    }
                }

                # Intermediate phase
                # RoleAssignments
                $applianceDetails = Get-AzMigrateReplicationRecoveryServicesProvider -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
                if ($applianceDetails.length -eq 1){
                    $applianceSpnId = $applianceDetails.ResourceAccessIdentityDetailObjectId
                }
                else {
                    foreach ($appliance in $applianceDetails){
                        if ($appliance.FabricFriendlyName -eq $fabricName){
                            $applianceSpnId = $appliance.ResourceAccessIdentityDetailObjectId
                        }
                    }
                }

                $vaultMsiPrincipalId = $VaultDetails.Identity.PrincipalId

                if ($applianceSpnId -eq $null) {
                    Write-Host "The appliance '$($applianceName)' does not have SPN enabled. Please enable and retry the operation."
                    continue
                }

                if ($vaultMsiPrincipalId -eq $null) {
                    Write-Host "The vault '$($VaultName)' does not have MSI enabled. Please enable system assigned MSI and retry the operation."
                    continue
                }

                $rsaStorageAccount = Get-AzResource -ResourceName $ReplicationStorageAcName -ResourceGroupName $ResourceGroupName
                for ($i = 1; $i -le 18; $i++) {
                    Write-Host "Waiting for" $ReplicationStorageAcName "to be available... $( $i * 10 ) seconds" -InformationAction Continue
                    Start-Sleep -Seconds 10
                    $rsaStorageAccount = Get-AzResource -ResourceName $ReplicationStorageAcName -ResourceGroupName $ResourceGroupName
                    if ($rsaStorageAccount) {
                        break
                    }
                }

                Create-RoleAssignments $applianceSpnId $rsaStorageAccount.Id
                Create-RoleAssignments $vaultMsiPrincipalId $rsaStorageAccount.Id

                for ($i = 1; $i -le 18; $i++) {
                    Write-Information "Waiting for Role Assignments to be available... $( $i * 10 ) seconds" -InformationAction Continue
                    Start-Sleep -Seconds 10

                    $applianceRoleAssignment = Get-AzRoleAssignment -ObjectId $applianceSpnId -Scope $rsaStorageAccount.Id -ErrorVariable notPresent -ErrorAction SilentlyContinue
                    $vaultRoleAssignments = Get-AzRoleAssignment -ObjectId $vaultMsiPrincipalId -Scope $rsaStorageAccount.Id -ErrorVariable notPresent -ErrorAction SilentlyContinue

                    if ($applianceRoleAssignment -and $vaultRoleAssignments) {
                        break
                    }
                }
           }
           else {
               $rsaStorageAccount = Get-AzResource -ResourceId $CacheStorageAccountId -ErrorVariable notPresent -ErrorAction SilentlyContinue
               if ($rsaStorageAccount -eq $null) {
                   throw "Storage account '$($CacheStorageAccountId)' does not exist."
               }

               Import-Module Az.Network
               $res = Get-AzPrivateEndpointConnection -privatelinkresourceid $CacheStorageAccountId -ErrorVariable notPresent -ErrorAction SilentlyContinue
               if (($res -eq $null) -or ($res.PrivateEndpoint -eq $null) -or ($res.PrivateEndpoint.Count -eq 0)) {
                   throw "Storage account '$($CacheStorageAccountId)' is not private endpoint enabled."
               }
           }

            # Policy
            $policyName = $MigratePrefix + $SiteName + "policy"
            $existingPolicyObject = Get-AzMigrateReplicationPolicy -PolicyName $policyName -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$existingPolicyObject) {
                $providerSpecificPolicy = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.VMwareCbtPolicyCreationInput]::new()
                $providerSpecificPolicy.AppConsistentFrequencyInMinute = 240
                $providerSpecificPolicy.InstanceType = "VMwareCbt"
                $providerSpecificPolicy.RecoveryPointHistoryInMinute = 360
                $providerSpecificPolicy.CrashConsistentFrequencyInMinute = 60
                $existingPolicyObject = New-AzMigrateReplicationPolicy -PolicyName $policyName -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -ProviderSpecificInput $providerSpecificPolicy
                Write-Host $LogStringCreated, $policyName
            }
            else {
                Write-Host $policyName, $LogStringSkipping
            }

            # Policy-container mapping
            $mappingName = "containermapping"
            $allFabrics = Get-AzMigrateReplicationFabric -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
            foreach ($fabric in $allFabrics) {
                if (($fabric.Property.CustomDetail.InstanceType -eq "VMwareV2") -and ($fabric.Property.CustomDetail.VmwareSiteId.Split("/")[8] -eq $SiteName)) {
                    $peContainers = Get-AzMigrateReplicationProtectionContainer -FabricName $fabric.Name -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
                    $peContainer = $peContainers[0]
                    $existingMapping = Get-AzMigrateReplicationProtectionContainerMapping -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -FabricName $fabric.Name -ProtectionContainerName $peContainer.Name -MappingName $mappingName -ErrorVariable notPresent -ErrorAction SilentlyContinue
                    if ($existingMapping) {
                        Write-Host $mappingName, " for ", $applianceName, $LogStringSkipping
                    }
                    else {
                        $providerSpecificInput = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20250801.VMwareCbtContainerMappingInput]::new()
                        $providerSpecificInput.InstanceType = "VMwareCbt"
                        $providerSpecificInput.TargetLocation = $TargetRegion
                        
                        # If mapping does not exist, it means green field scenario. Hence, no service bus/KV required.
                        $providerSpecificInput.StorageAccountId = $rsaStorageAccount.Id

                        $output = New-AzMigrateReplicationProtectionContainerMapping -FabricName $fabric.Name -MappingName $mappingName -ProtectionContainerName $peContainer.Name -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -PolicyId $existingPolicyObject.Id -ProviderSpecificInput $providerSpecificInput -TargetProtectionContainerId  "Microsoft Azure"
                        Write-Host $LogStringCreated, $mappingName, " for ", $applianceName
                    }
                }
            }
        }
        Write-Host "Finished successfully."
        return $true
    }
}
# SIG # Begin signature block
# MIIoLAYJKoZIhvcNAQcCoIIoHTCCKBkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDajuE6/ejs7jKu
# Fs6SmL6dKoXXW5R0tfVW7lzX3t9VUqCCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgwwghoIAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEICEJbTzdVBXIwRA/oSICJ/MN
# xdeWckb0WJoABYaJmfiDMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAi1KwQi/sT8SROWLXddx/hBF/tqHml4HFnAArdqUrFiHby5b0f0Cok63D
# d/ZlBL6NvHOvwrbOS+jh+gOQaUq0xIQvWulRFh7DsKQlhET2gSAMLL6spGbxwXfP
# VXDDKp8oY7K1UVdX3umKoiySxnsF6Pqbq0Ipq+dXwued6vHomlPP+z5z8euUOdsk
# zqgOLBhQ6BKtIgdmKndhfUe8P2TWZNKonFfRmQmAU+4ntdVsbMe1Cb5Yt/A8yn4Q
# FRW+ZVzDSNgefx5H3AbvmMZQQMvV4cciiOVMCIq8MozADS8tQ6xPefhzCDjeQOoW
# c3l5ctuRdy+ID7VA1eft8CfcSVnpEaGCF5YwgheSBgorBgEEAYI3AwMBMYIXgjCC
# F34GCSqGSIb3DQEHAqCCF28wghdrAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFRBgsq
# hkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCB7eWmAU4psmU13fBEWMftx1HjghfQTSUFuNLhdOg8apwIGaTtZcL51
# GBIyMDI2MDExMDAxMTYwMC4wNVowBIACAfSggdGkgc4wgcsxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjpGMDAyLTA1
# RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaCC
# Ee0wggcgMIIFCKADAgECAhMzAAACBTx1bIJEh83+AAEAAAIFMA0GCSqGSIb3DQEB
# CwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTI1MDEzMDE5NDI0
# OVoXDTI2MDQyMjE5NDI0OVowgcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMx
# JzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjpGMDAyLTA1RTAtRDk0NzElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAJKS8t93uAXWvbAZ3LzkIVhcdQLzLATIPgtEu/RZgRd5
# 5nS7li4runZxdXNCZk84dM3xNaobZI+VRv7s+V3MUMMCVHe9TymI6OaG72sdbjcz
# Z1uiv2OX2CW6HPBR3ZJyJUZrt/23ru0zcoUpFIxcW0coXcrAEHtpWj5vWrLmn0Na
# WjY3kUasGocwRWU3LOt4digMsv6bx9Kyoy7+JhSrHMrkXhLshjk16YAHwH4DdCDB
# UiLrgokh94plR6JYoJN/ih1SA/cBCKXGHjw/rPsBPggDR0wS0qFgsWzhb8o0Myxi
# vsqlA8pUJwLkTy4Md0p7C5vLN6eRPHLh9/U3eDzKGjk+L0F+NHRXK2uSakN96nwk
# /BxvgE04hc6jWl90dnwS+dHskVkVCKqkxkWU7kIC5Ngfy6Nzk9QeVowAnw0Rr1MU
# lM5IGsHs9GB6H/o0nbG73LE+H+RU30Eayz3cwLpSOmjF4zjHvRvBvCIrxI0cg7wP
# xyqXtVJ69RhuM3g2iAUXCEEKWGh0T/N4Y+rrLqLEPjPrkgdjfPAVBsFVf/D4v9Uc
# 2f8EwazY8YeeVGM78qTw0ik3iyGQVCoDV8zTx+usNI0Rj1UoO2mxSkAXnVjWhDq0
# mFYzV3ed4JeHpv/o35d4c5ELCdjzcr6kUwyGDyKxdBvopGXrmSDxdgF3gnCRsqhV
# AgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUdHpauzbtvr7IndsRn2jk10vVsvAwHwYD
# VR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZO
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIw
# VGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
# BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0
# cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMC
# B4AwDQYJKoZIhvcNAQELBQADggIBAA67GTjtvWLvlXzVPHrGjXTE0ivjNnFhV+QX
# lMWraSd08eDNXIueyzD8cqQRlEKBlWmQoQnpjiO8bm26AyL5aO3uFQxKKmT5GkHm
# AVC+HXGYAQvZ+V6DNNYSyePTCsRKmUjlne+B/Z4ZcCv9FyoaNKmi4dsPYdj1jcXQ
# 6XoVEMJX8cQYpEfOfYzmtCkUZKNpxPgOSpViZ6b8Cs59K9WiOcoQhb3XhTEa26El
# Kv2M6jlGpNfsYipu283vOFaV36LdfF2F01x+VDP1iGgWpB7EF6eghGAA8C3AfrzF
# zOv0swLeX0AsSmey87RGIo9cXiXbb859wV99qmGeX9MPCSIl/E7IAx9QXfEj37eL
# NPVZfYIWzZFo4Crd1yiHInD7FEbQTzCQIeqRXnsFtQETMtfwv2UYnUOjFg2mgNfu
# JDMn1B2TKmLl+/vvcTcKHwD62jF4WnoWJ9BnIJzwhwgGUfJqToxtPphNVA2BD+Hw
# UX5Lk6o/sIQIW8gfYq3Y/QaU670LQF9qyGdOOh2a1kVmym1S+KuT/Yc4suMGIyMP
# AmxAAUDMm7Phm1PKiuu8RHXQaX+ZuZWIeqG80AJ9PM+It+MODK+n2zv9se78JqUq
# Z6IlQsaOH+XACPnfX2mCCwYmpuEngVsVz6hTnN99ub+sqNVnyTE0PeKbXRCnjWfa
# 3+qnI/oRMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG
# 9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEy
# MDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIw
# MTAwHhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AOThpkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az
# /1xPx2b3lVNxWuJ+Slr+uDZnhUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V2
# 9YZQ3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oa
# ezOtgFt+jBAcnVL+tuhiJdxqD89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkN
# yjYtcI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7K
# MtXAhjBcTyziYrLNueKNiOSWrAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRf
# NN0Sidb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SU
# HDSCD/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoY
# WmEBc8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5
# C4lh8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8
# FdsaN8cIFRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TAS
# BgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1
# Kc8Q/y8E7jAdBgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUw
# UzBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fO
# mhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9w
# a2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggr
# BgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3
# DQEBCwUAA4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEz
# tTnXwnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJW
# AAOwBb6J6Gngugnue99qb74py27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G
# 82jfZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/Aye
# ixmJ5/ALaoHCgRlCGVJ1ijbCHcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI9
# 5ko+ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1j
# dEgssU5HLcEUBHG/ZPkkvnNtyo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZ
# KCS6OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xB
# Zj1p/cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuP
# Ntq6TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvp
# e784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCA1Aw
# ggI4AgEBMIH5oYHRpIHOMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScw
# JQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RjAwMi0wNUUwLUQ5NDcxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVANWw
# f2nW0mf6SvAIy+o6FW9ett60oIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQELBQACBQDtDBBoMCIYDzIwMjYwMTA5MjM0MDI0
# WhgPMjAyNjAxMTAyMzQwMjRaMHcwPQYKKwYBBAGEWQoEATEvMC0wCgIFAO0MEGgC
# AQAwCgIBAAICEB8CAf8wBwIBAAICEr4wCgIFAO0NYegCAQAwNgYKKwYBBAGEWQoE
# AjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkq
# hkiG9w0BAQsFAAOCAQEALFZlah/lYDn48hWgZiBeGc09Lbym1UMqOirPq0neVF65
# KS9z1kF8iE0A4h7Y0bcYjWK2zJrbTFQINWjkCyVRwNiQw8Heh7/gQX8O4I616XvU
# mt7SnlYCQuq3hKifCAUHNounl0/9CDyBz8HXeqcp8PGLrPiHaFuELst+O1TXlfdR
# ARplXpjzWZKdx8YeOpndDXwVT9nOtV0mQJgCZt9pWr4LWcH0gvZDD1DuBKif/5Sg
# U/8g62cNDQ0pyWNqAM1Wbjjxfxp7Sm3tbxeq8XdKYPvQoJatjC31CMoAm4LG/sWE
# uRA3+5jp3uxdH7MatP/L2luMM6HDacEgtgf0w6aFBDGCBA0wggQJAgEBMIGTMHwx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAACBTx1bIJEh83+AAEAAAIF
# MA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQw
# LwYJKoZIhvcNAQkEMSIEIB3PtbrvLYhwRstmlaJMpPwC6FIL+qWJYOvmXopOaAeH
# MIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQggA0DPdx5jS6aF1YtHawmmrQ4
# +q0kNMBhGaMdWTARb0gwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMAITMwAAAgU8dWyCRIfN/gABAAACBTAiBCCKbKDQplhjN6dFjoTYiMPxGns/
# kn5JIozhHtNSQ4lUBzANBgkqhkiG9w0BAQsFAASCAgAW4+Gg1kj+k7nlKFpgLpY0
# nHpS7l2KfGK0Szx8kKoEmZ1IJH5kIy59V+HxZVo7QwB5wi9NNnYD87zpiMst2sjm
# lNnKza2inH0S/vgdHAdsI/3YEO/1FW2IoTqb+IaBEmYnHc3gJ+5V+tt9p3ZUdeCd
# logpC95f1tJJzdgWQ94c5Eq+htZpGO9MrLOxNsxttyraqwqZ0WWZ7rXjtcFflVZy
# o3bNJLoI5gygfdROVxNr6sTBe+syjw4rq1aKfn5x+ct31wrBmC9lXIBU8V7Pn4zL
# TSi6gErb9wWaCjk/fuoNfflfm5MHxoxmXn+P9IYFNn6iOy0lZCQxkXYhaZPmHyf1
# Dby88zDBRSfDfO04BhV+73KPNqGhixmZVAibWZdDcDF8o7nceqZF0zUG/psEuTa+
# 3nb0vGI/tbrTPgquyMOP8IbCs8WYT2CAGL3ZKR2a3EojzcCD84WnFBfANt6SqHoo
# 3f+72XyIl8DGj9V9hZcF6/BE4mhMN0E5LzFqPtTBeUt8q2k9o4vNKg9tlEJkcD6/
# wOCOnKukNxC8v8cGs6G77oZoaf2BvflJt3q16cOsK0bpVZ/IBPPNBDFz7ceOjGfl
# hHCdtt7IwGZ9yTBD+QeG8Kv7QNQGucYJioESgDUoQs2JLDg/cGwPA2wXryiu85iM
# /w5gUeB0MILzCzYoJtmceg==
# SIG # End signature block

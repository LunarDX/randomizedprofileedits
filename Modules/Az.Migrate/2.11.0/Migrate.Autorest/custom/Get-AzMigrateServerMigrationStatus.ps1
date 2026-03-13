
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
Retrieves the details of the replicating server status.
.Description
The Get-AzMigrateServerMigrationStatus cmdlet retrieves the replication status for the replicating server.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/get-azmigrateservermigrationstatus
#>
function Get-AzMigrateServerMigrationStatus {
    [OutputType([PSCustomObject[]])]
    [CmdletBinding(DefaultParameterSetName = 'ListByName', PositionalBinding = $false)]
    param(
        [Parameter(ParameterSetName = 'ListByName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group of the Azure Migrate Project in the current subscription.
        ${ResourceGroupName},

        [Parameter(ParameterSetName = 'ListByName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Azure Migrate project  in the current subscription.
        ${ProjectName},

        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the display name of the replicating machine.
        ${MachineName},

        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the appliance.
        ${ApplianceName},

        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Management.Automation.SwitchParameter]
        # Specifies whether the health issues to show for replicating server.
        ${Health},

        [Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Management.Automation.SwitchParameter]
        # Specifies whether to expedite the operation of a replicating server.
        ${Expedite},

        [Parameter(ParameterSetName = 'ListByName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Query')]
        [System.String]
        # OData filter options.
        ${Filter},
    
        [Parameter(ParameterSetName = 'ListByName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Query')]
        [System.String]
        # The pagination token.
        ${SkipToken},
    
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
        Function MakeTable ($TableName, $ColumnArray) {
            foreach($Col in $ColumnArray) {
                $MCol = New-Object System.Data.DataColumn $Col;
                $TableName.Columns.Add($MCol)
            }
        }

        $appMap = @{}

        Function PopulateApplianceDetails ($projName, $rgName) {
            # Get vault name from SMS solution.
            $smsSolution = Get-AzMigrateSolution -MigrateProjectName $projName -ResourceGroupName $rgName -Name "Servers-Migration-ServerMigration"

            if (-not $smsSolution.DetailExtendedDetail.AdditionalProperties.vaultId) {
                throw 'Azure Migrate appliance not configured. Setup Azure Migrate appliance before proceeding.'
            }

            $VaultName = $smsSolution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]

            # Get all appliances and sites in the project from SDS solution.
            $sdsSolution = Get-AzMigrateSolution -MigrateProjectName $projName -ResourceGroupName $rgName -Name "Servers-Discovery-ServerDiscovery"

            if ($null -ne $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"]) {
                $appMapV2 = $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] | ConvertFrom-Json
                # Fetch all appliances from V2 map first. Then these can be updated if found again in V3 map.
                foreach ($item in $appMapV2) {
                    $appMap[$item.SiteId.Split('/')[-1]] = $item.ApplianceName
                }
            }

            if ($null -ne $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"]) {
                $appMapV3 = $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] | ConvertFrom-Json
                foreach ($item in $appMapV3) {
                    $t = $item.psobject.properties
                    $appMap[$t.Value.SiteId.Split('/')[-1]] = $t.Name
                }
            }
        }

        Function GetApplianceName ($site) {
            if (!$appMap.ContainsKey($site)) {
                return "No appliance found for site name: $site"
            }
            return $appMap[$site]
        }

        Function GetState {
            param(
                [string]$State,
                [object]$ReplicationMigrationItem
            )
            if ($ReplicationMigrationItem.MigrationState -eq "MigrationFailed") {
                return "Migration Failed"
            }
            elseif ($ReplicationMigrationItem.MigrationState -match "InitialSeedingFailed") {
                return "InitialReplication Failed"
            }

            if ([string]::IsNullOrEmpty($State)) {
                return $ReplicationMigrationItem.MigrationState
            }

            $State = $State -replace "PlannedFailoverOverDeltaReplication", "FinalDeltaReplication"
            return $State
        }

        function Convert-MillisecondsToTime {
            param (
                [int]$Milliseconds
            )

            if ($Milliseconds -eq $null) {
                return $null
            }

            $TotalMinutes = [math]::Floor($Milliseconds / 60000)
            $Hours = [math]::Floor($TotalMinutes / 60)
            $Minutes = $TotalMinutes % 60

            if ($Hours -eq 0) {
                if ($Minutes -eq 0)
                {
                    return "-"
                }
                return "$Minutes min"
            } else {
                return "$Hours hr $Minutes min"
            }
        }

        function Convert-ToMbps {
            param (
                [double]$UploadSpeedInBytesPerSecond
            )

            if ($UploadSpeedInBytesPerSecond -eq $null -or $UploadSpeedInBytesPerSecond -eq 0) {
                return "-"
            }

            # Conversion factor: 1 byte = 8 bits
            $UploadSpeedInBitsPerSecond = $UploadSpeedInBytesPerSecond * 8

            # Conversion factor: 1 megabit = 1,000,000 bits
            $UploadSpeedInMbps = [math]::Round($UploadSpeedInBitsPerSecond / 1e6)

            return "$UploadSpeedInMbps Mbps"
        }

        function Add-Percent {
            param (
                [double]$Value
            )

            if ($null -ne $Value) {
                return "$Value %"
            } else {
                return "-"
            }
        }

        function Add-MBps {
            param (
                [double]$Value
            )
            if ($null -ne $Value) {
                return "$Value MBps"
            } else {
                return "-"
            }
        }

        function Add-MB {
            param (
                [double]$Value
            )
            if ($null -ne $Value) {
                return "$Value MB"
            } else {
                return "-"
            }
        }

        function ConvertToCustomTimeFormat {
            param (
                [string]$LocalTimeString
            )
            
            if ([string]::IsNullOrEmpty($LocalTimeString)) {
                return "-"
            }

            # Parse the input string
            $localTime = [datetime]::ParseExact($LocalTimeString, "MM/dd/yyyy HH:mm:ss", $null)

            # Format the local time as desired
            $formattedTime = Get-Date $localTime -Format "M/d/yyyy, h:mm:ss tt"

            return $formattedTime
        }

        # Helper function to determine status
        function Get-ResourceStatus {
            param (
                [double]$Capacity,
                [double]$Utilization,
                [string]$ResourceType
            )
            if ($Capacity -eq 0 -or $null -eq $Capacity) {
                return "-"
            }
            if ($null -eq $Utilization) {
                return "-"
            }
            if ($ResourceType -match "CPU Sum" -and $Utilization -eq 0) {
                return "-"
            }

            $thresholds = @{
                "ApplianceRam"      = @{ AtCapacity = 95; Throttled = 85; Underutilized = 60 }
                "ApplianceCpu"      = @{ AtCapacity = 99; Throttled = 95; Underutilized = 60 }
                "NetworkBandwidth"  = @{ AtCapacity = 95; Throttled = 90; Underutilized = 50 }
                "EsxiNfcBuffer"     = @{ AtCapacity = 100; Throttled = 90; Underutilized = 70 }
                "ParallelDisks"     = @{ AtCapacity = 100; Throttled = 95; Underutilized = 70 }
                "Datastore"         = @{ AtCapacity = 100; Throttled = 95; Underutilized = 70 }
                "Default"           = @{ AtCapacity = 100; Throttled = 90; Underutilized = 70 }
            }

            # Map resource type to threshold set
            $typeKey = switch -Regex ($ResourceType) {
                "RAM"         { "ApplianceRam" }
                "CPU"         { "ApplianceCpu" }
                "Network"     { "NetworkBandwidth" }
                "NFC"         { "EsxiNfcBuffer" }
                "Disk"        { "ParallelDisks" }
                "Datastore"   { "Datastore" }
                default       { "Default" }
            }

            $t = $thresholds[$typeKey]
            $percent = ($Utilization / $Capacity) * 100

            if ($percent -ge $t.AtCapacity) {
                return "At capacity"
            } elseif ($percent -ge $t.Throttled) {
                return "Throttled"
            } elseif ($percent -le $t.Underutilized) {
                return "Underutilized"
            } else {
                return "Normal"
            }
        }

        $parameterSet = $PSCmdlet.ParameterSetName
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('ProjectName')
        $HasFilter = $PSBoundParameters.ContainsKey('Filter')
        $HasSkipToken = $PSBoundParameters.ContainsKey('SkipToken')
        $null = $PSBoundParameters.Remove('Filter')
        $null = $PSBoundParameters.Remove('SkipToken')
        $null = $PSBoundParameters.Remove('MachineName')
        $null = $PSBoundParameters.Remove('ApplianceName')
        $null = $PSBoundParameters.Remove('Health')
        $null = $PSBoundParameters.Remove('Expedite')

        $output = New-Object System.Collections.ArrayList  # Create a hashtable to store the output.

        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("Name", "Servers-Migration-ServerMigration")
        $null = $PSBoundParameters.Add("MigrateProjectName", $ProjectName)

        $solution = Az.Migrate\Get-AzMigrateSolution @PSBoundParameters
        if ($solution -and ($solution.Count -ge 1)) {
            $VaultName = $solution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]
        }
        else {
            throw "Solution not found."
        }


        $null = $PSBoundParameters.Remove("Name")
        $null = $PSBoundParameters.Remove("MigrateProjectName")
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)

        if ($HasFilter) {
            $null = $PSBoundParameters.Add("Filter", $Filter)
        }
        if ($HasSkipToken) {
            $null = $PSBoundParameters.Add("SkipToken", $SkipToken)
        }

        PopulateApplianceDetails $ProjectName $ResourceGroupName

        if ($parameterSet -eq "GetByApplianceName" -and !$appMap.ContainsValue($ApplianceName))
        {
            throw "No appliance found with name $ApplianceName"
        }

        if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
            $ReplicationMigrationItems = Get-AzMigrateServerReplication -ProjectName $ProjectName -ResourceGroupName $ResourceGroupName -MachineName $MachineName
        }
        else {
            $ReplicationMigrationItems = Get-AzMigrateServerReplication -ProjectName $ProjectName -ResourceGroupName $ResourceGroupName
        }

        if ($ReplicationMigrationItems -eq $null) {
            if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName") {
                Write-Host "No replicating machine found with name $MachineName."
            }
            else {
                Write-Host "No replicating machine found."
            }
            return;
        }

        $vmMigrationStatusTable = New-Object System.Data.DataTable("")

        if ($parameterSet -eq "GetByApplianceName") {
            $column = @("Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Health", "LastSync",  "ESXiHost", "Datastore")
        }
        elseif ($parameterSet -eq "ListByName") {
            $column = @("Appliance", "Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Health", "LastSync", "ESXiHost", "Datastore")
        }
        else {
            $column = @("Appliance", "Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "LastSync", "ESXiHost", "Datastore")
        }

        MakeTable $vmMigrationStatusTable $column

        foreach ($ReplicationMigrationItem in $ReplicationMigrationItems) {
            if ($parameterSet -eq "GetByMachineName") {
                if ($ReplicationMigrationItem.health -eq "Normal") {
                    $op = $output.Add("`nServer $MachineName is currently healthy.")
                }
                elseif ($ReplicationMigrationItem.health -eq "None") {
                    $op = $output.Add("`nServer $MachineName is in $($ReplicationMigrationItems.ReplicationStatus) state.")
                }
                else {
                    $op = $output.Add("`nServer $MachineName is currently facing critical error/ warning. Please run the command given below to know about the errors and resolutions.`n`nGet-AzMigrateServerMigrationStatus -ProjectName <String> -ResourceGroupName <String> -Appliance <String> -MachineName <String> -Health")
                }
            }

            if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                $ReplicationMigrationItem = Get-AzMigrateServerReplication -TargetObjectID $ReplicationMigrationItem.Id
            }

            $site = $ReplicationMigrationItem.ProviderSpecificDetail.vmwareMachineId.Split('/')[-3]
            $appName = GetApplianceName $site
            $row1 = $vmMigrationStatusTable.NewRow()
            if ($parameterSet -eq "GetByApplianceName" -and $appName -ne $ApplianceName) {
                continue;
            }
            if ($parameterSet -ne "GetByApplianceName") {
                $row1["Appliance"] = $appName
            }

            $row1["Server"] = $ReplicationMigrationItem.MachineName
            $row1["State"] = GetState -State $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailState -ReplicationMigrationItem $ReplicationMigrationItem
            if ($ReplicationMigrationItem.ReplicationStatus -match "Pause" -and $ReplicationMigrationItem.MigrationState -notmatch "migration") {
                $row1["State"] = $ReplicationMigrationItem.ReplicationStatus
                $row1["TimeRemaining"] = "-"
                $row1["UploadSpeed"] = "-"
                $row1["Progress"] = "-"
                $row1["TimeElapsed"] = "-"
            }
            elseif ($ReplicationMigrationItem.ReplicationStatus -match "Resum") {
                $row1["State"] = $ReplicationMigrationItem.ReplicationStatus
                $row1["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                $row1["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailUploadSpeed
                $row1["Progress"] = Add-Percent -Value $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailProgressPercentage
                $row1["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeElapsed
            }
            elseif ($ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailState -match "Completed") {
                $row1["TimeRemaining"] = "-"
                $row1["UploadSpeed"] = "-"
                $row1["Progress"] = "-"
                $row1["TimeElapsed"] = "-"
            }
            else {
                $row1["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                $row1["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailUploadSpeed
                $row1["Progress"] = Add-Percent -Value $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailProgressPercentage
                $row1["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeElapsed
            }

            if ($parameterSet -eq "ListByName" -or $parameterSet -eq "GetByApplianceName") {
                if ([string]::IsNullOrEmpty($ReplicationMigrationItem.health) -or $ReplicationMigrationItem.health -eq "None") {
                    $row1["Health"] = "-"
                }
                else {
                    $row1["Health"] = $ReplicationMigrationItem.health
                }
            }
            $row1["LastSync"] = ConvertToCustomTimeFormat -LocalTimeString $ReplicationMigrationItem.ProviderSpecificDetail.lastRecoveryPointReceived

            $row1["ESXiHost"] = $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailHostName
            if (-not [string]::IsNullOrEmpty($ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore)) {
                $row1["Datastore"] = $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore -join ', '
            }
            else {
                $row1["Datastore"] = "-"
            }

            $vmMigrationStatusTable.Rows.Add($row1)

            if( $parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                if ($parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                    $op = $output.Add("`nServer Information:")
                }

                $vmMigrationStatusTable = $vmMigrationStatusTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($vmMigrationStatusTable)  # Store the table in the output hashtable

                $diskStatusTable = New-Object System.Data.DataTable("")
                $diskcolumn = @("Disk", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Datastore")

                MakeTable $diskStatusTable $diskcolumn

                foreach($disk in $ReplicationMigrationItem.ProviderSpecificDetail.ProtectedDisk) {
                    $row = $diskStatusTable.NewRow()
                    $row["Disk"] = $disk.DiskName
                    $row["State"] = GetState -State $disk.GatewayOperationDetailState -ReplicationMigrationItem $ReplicationMigrationItem

                    if ($ReplicationMigrationItem.ReplicationStatus -match "Pause" -and $ReplicationMigrationItem.MigrationState -notmatch "migration") {
                        $row["State"] = $ReplicationMigrationItem.ReplicationStatus
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                    }
                    elseif ($ReplicationMigrationItem.ReplicationStatus -match "Resum") {
                        $row["State"] = $ReplicationMigrationItem.ReplicationStatus
                        #$row["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeRemaining
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                        #$row["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $disk.GatewayOperationDetailUploadSpeed
                        #$row["Progress"] = Add-Percent -Value $disk.GatewayOperationDetailProgressPercentage
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                        #$row["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeElapsed
                    }
                    elseif ($disk.GatewayOperationDetailState -match "Completed") {
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                    }
                    else {
                        $row["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeRemaining
                        $row["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $disk.GatewayOperationDetailUploadSpeed
                        $row["Progress"] = Add-Percent -Value $disk.GatewayOperationDetailProgressPercentage
                        $row["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeElapsed
                    }

                    if (-not [string]::IsNullOrEmpty($disk.GatewayOperationDetailDataStore)) {
                        $row["Datastore"] = $disk.GatewayOperationDetailDataStore -join ', '
                    }
                    else {
                        $row["Datastore"] = "-"
                    }
                    $diskStatusTable.Rows.Add($row)
                }

                if ($parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                    $op = $output.Add("`nDisk Level Operation Status:")
                }

                $diskStatusTable = $diskStatusTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($diskStatusTable)  # Store the table in the output hashtable
            }

            if ($parameterSet -eq "GetHealthByMachineName") {
                if ($ReplicationMigrationItem.health -eq "Normal") {
                    $op = $output.Add("No warnings or critical errors for this server.")
                }
                else {
                    $op = $output.Add("List of warning or critical errors for this server with their resolutions: `n")
                    $healthError = $ReplicationMigrationItem.HealthError
                    foreach ($error in $healthError) {
                        $op = $output.Add("Error Message: $($error.ErrorMessage)`nPossible Causes: $($error.PossibleCaus)`nRecommended Actions: $($error.RecommendedAction)`n`n")
                    }
                }
            }
        }

        if( $parameterSet -eq "GetByPrioritiseServer") {

            $replicationState = GetState -State $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailState -ReplicationMigrationItem $ReplicationMigrationItem
            if ($replicationState -match "Failed" -or $replicationState -match "Completed" -or ($replicationState -notmatch "InProgress" -and $replicationState -notmatch "Queued")) {
                $op = $output.Add("Replication for server '$($ReplicationMigrationItem.MachineName)' is in state '$replicationState'. Expedite recommendations are only applicable for servers in 'Queued' or 'InProgress' state.`n")
                return $output;
            }

            # Build a table of VMs sharing resources (appliance, datastore, ESXi host) with the reference VM.
            $vmMigrationTable = New-Object System.Data.DataTable("")
            $column = @("Appliance", "Server", "SharedResourceType", "State", "TimeRemaining", "ESXiHost", "Datastore")
            MakeTable $vmMigrationTable $column

            # Get reference VM's ESXi host and datastores
            $refESXiHost = $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailHostName
            $refDatastores = @()
            if ($ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore) {
                $refDatastores = @($ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore)
            }

            $MigrationItems = Get-AzMigrateServerReplication -ProjectName $ProjectName -ResourceGroupName $ResourceGroupName
            $addedMachines = @{}  # Hashtable to track added machines
            foreach($MigrationItem in $MigrationItems) {
                # Skip the reference VM itself
                if ($MigrationItem.MachineName -eq $ReplicationMigrationItem.MachineName) {
                    continue
                }

                # Skip if this machine has already been added
                if ($addedMachines.ContainsKey($MigrationItem.MachineName)) {
                    continue
                }

                $site = $MigrationItem.ProviderSpecificDetail.vmwareMachineId.Split('/')[-3]
                $appName1 = GetApplianceName $site

                # Check for shared resources
                $sharedTypes = @()

                if ($appName1 -eq $appName) {
                    $sharedTypes += "Appliance"
                }

                $esxiHost = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailHostName
                if ($refESXiHost -and $esxiHost -and ($esxiHost -eq $refESXiHost)) {
                    $sharedTypes += "ESXiHost"
                }

                $datastores = @()
                if ($MigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore) {
                    $datastores = @($MigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore)
                }
                $commonDatastores = $refDatastores | Where-Object { $datastores -contains $_ }
                foreach ($ds in $commonDatastores) {
                    $sharedTypes += "Datastore"
                }

                if ($sharedTypes.Count -gt 0) {
                    $row1 = $vmMigrationTable.NewRow()
                    $row1["Appliance"] = $appName1
                    $row1["Server"] = $MigrationItem.MachineName
                    $row1["SharedResourceType"] = $sharedTypes -join ', '
                    $row1["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                    $row1["State"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailState
                    $row1["ESXiHost"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailHostName
                    if ($datastores -and $datastores.Count -gt 0) {
                        $row1["Datastore"] = $datastores -join ', '
                    } else {
                        $row1["Datastore"] = "-"
                    }
                    $vmMigrationTable.Rows.Add($row1)
                    # Mark this machine as added to avoid duplicates
                    $addedMachines[$MigrationItem.MachineName] = $true
                }
            }

            if ($vmMigrationTable.Rows.Count -gt 0) {
                $op = $output.Add("Resource Sharing:`n`nThe following VMs share at least one resource (Appliance, ESXi Host, or Datastore) with VM " + `
                    "'$($ReplicationMigrationItem.MachineName)'. The 'SharedResourceType' and 'SharedResourceName' columns indicate which resource is shared.")
                
                $vmMigrationTable = $vmMigrationTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($vmMigrationTable)
            } 
            else {
                $op = $output.Add("No other VMs found sharing Appliance, ESXi Host, or Datastore with VM '$($ReplicationMigrationItem.MachineName)'.")
            }
            $resourceUtilizationTable = New-Object System.Data.DataTable("")
            $column = @("Resource", "Capacity", "Utilization for server migrations", "Total utilization", "Status")
            MakeTable $resourceUtilizationTable $column
            
            # RAM
            $row1 = $resourceUtilizationTable.NewRow()
            $ramCapacity = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailCapacity
            $ramTotalUtil = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailTotalUtilization
            $row1["Resource"] = "Appliance RAM Sum : Primary and scale out appliances"
            $row1["Capacity"] = Add-MB -Value $ramCapacity
            $row1["Utilization for server migrations"] = Add-MB -Value ($ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailProcessUtilization)
            $row1["Total utilization"] = Add-MB -Value $ramTotalUtil
            $row1["Status"] = Get-ResourceStatus -Capacity $ramCapacity -Utilization $ramTotalUtil -ResourceType $row1["Resource"]
            $resourceUtilizationTable.Rows.Add($row1)

            # CPU
            $row2 = $resourceUtilizationTable.NewRow()
            $cpuCapacity = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailCapacity
            $cpuProcessUtil = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailProcessUtilization
            $cpuTotalUtil = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailTotalUtilization
            $row2["Resource"] = "Appliance CPU Sum : Primary and scale out appliances"
            if ($null -ne $cpuCapacity -and $cpuCapacity -ne 0) {
                $row2["Capacity"] = "$($cpuCapacity) Cores"
            } else {
                $row2["Capacity"] = "-"
            }
            $row2["Utilization for server migrations"] = Add-Percent -Value $cpuProcessUtil
            $row2["Total utilization"] = Add-Percent -Value $cpuTotalUtil
            $row2["Status"] = Get-ResourceStatus -Capacity 100 -Utilization $cpuTotalUtil -ResourceType $row2["Resource"]
            $resourceUtilizationTable.Rows.Add($row2)

            # Network Bandwidth
            $row3 = $resourceUtilizationTable.NewRow()
            $netCapacity = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthCapacity
            $netTotalUtil = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthTotalUtilization
            $row3["Resource"] = "Network bandwidth Sum : Primary and scale out appliances"
            $row3["Capacity"] = Add-MBps -Value $netCapacity
            $row3["Utilization for server migrations"] = Add-MBps -Value $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthProcessUtilization
            $row3["Total utilization"] = Add-MBps -Value $netTotalUtil
            $row3["Status"] = Get-ResourceStatus -Capacity $netCapacity -Utilization $netTotalUtil -ResourceType $row3["Resource"]
            $resourceUtilizationTable.Rows.Add($row3)

            # ESXi NFC Buffer
            $row4 = $resourceUtilizationTable.NewRow()
            $nfcCapacity = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferCapacity
            $nfcProcessUtil = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferProcessUtilization
            $row4["Resource"] = "ESXi host NFC buffer"
            $row4["Capacity"] = Add-MB -Value $nfcCapacity
            $row4["Utilization for server migrations"] = Add-MB -Value $nfcProcessUtil
            $row4["Total utilization"] = "-"
            $row4["Status"] = Get-ResourceStatus -Capacity $nfcCapacity -Utilization $nfcProcessUtil -ResourceType $row4["Resource"]
            $resourceUtilizationTable.Rows.Add($row4)

            # Parallel Disks Replicated
            $row5 = $resourceUtilizationTable.NewRow()
            $diskCapacity = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailCapacity
            $diskProcessUtil = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailProcessUtilization
            $row5["Resource"] = "Parallel Disks Replicated Sum : Primary and scale out appliances"
            if ($null -ne $diskCapacity) {
                $row5["Capacity"] = $diskCapacity
            }
            else {
                $row5["Capacity"] = "-"
            }
            if ($null -ne $diskProcessUtil) {
                $row5["Utilization for server migrations"] = $diskProcessUtil
            }
            else {
                $row5["Utilization for server migrations"] = "-"
            }
            $row5["Total utilization"] = "-"
            $row5["Status"] = Get-ResourceStatus -Capacity $diskCapacity -Utilization $diskProcessUtil -ResourceType $row5["Resource"]
            $resourceUtilizationTable.Rows.Add($row5)

            # Datastore Snapshots (list)
            $datastoreList = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.datastoreSnapshot
            if ($datastoreList) {
                foreach ($ds in $datastoreList) {
                    $row = $resourceUtilizationTable.NewRow()
                    if ($null -ne $ds.datastoreName) {
                        $datastoreName = $ds.datastoreName
                    }
                    else {
                        $datastoreName = "-"
                    }
                    $row["Resource"] = "Datastore '$datastoreName' Snapshot Count"
                    if ($null -ne $ds.totalSnapshotsSupported) {
                        $row["Capacity"] = $ds.totalSnapshotsSupported
                    }
                    else {
                        $row["Capacity"] = "-"
                    }
                    if ($null -ne $ds.totalSnapshotsCreated) {
                        $row["Utilization for server migrations"] = $ds.totalSnapshotsCreated
                    }
                    else {
                        $row["Utilization for server migrations"] = "-"
                    }
                    $row["Total utilization"] = "-"
                    $row["Status"] = Get-ResourceStatus -Capacity $ds.totalSnapshotsSupported -Utilization  $ds.totalSnapshotsCreated -ResourceType $row["Resource"]
                    $resourceUtilizationTable.Rows.Add($row)
                }
            }

            $op = $output.Add("Resource utilization information for migration operations:")
            $resourceUtilizationTableString = $resourceUtilizationTable | Format-Table -AutoSize | Out-String
            $op = $output.Add($resourceUtilizationTableString)

            # Recommendations
            $recommendations = @()
            foreach ($row in $resourceUtilizationTable.Rows) {
                $resource = $row["Resource"]

                # Normalize resource string for matching
                $resourceNorm = $resource.ToLower()
                $status = $row["Status"].ToLower()
                $isQueued = $replicationState -match "Queued"

                if ($status -eq "Throttled" -or $status -eq "At capacity") {
                    if ($resourceNorm -like "*ram*") {
                            $recommendations += "`nResource `"$resource`" is $status. Recommendations:"
                            $recommendations += "Stop other processes running on the appliance that are consuming RAM."
                            $recommendations += "Stop initial replication (IR) or pause delta replication (DR) for other low-priority VMs migrating under this appliance to free up RAM."
                            $recommendations += "Decrease the number of workers (parallel disk replications)."
                            $ramCapacityVal = 0
                            if ($row["Capacity"] -match "(\d+(\.\d+)?)") { $ramCapacityVal = [double]$matches[1] }
                            if ($ramCapacityVal -lt 32768 -and $ramCapacityVal -gt 0) {
                                $recommendations += "Consider increasing the appliance RAM to improve migration performance and support higher workloads."
                            }
                            $recommendations += "If only the primary appliance is present, consider adding or increasing the number of scale-out appliances.`n"
                    }
                    elseif ($resourceNorm -like "*cpu*") {
                            $recommendations += "`nResource `"$resource`" is $status. Recommendations:"
                            $recommendations += "Stop other processes running on the appliance that are consuming CPU."
                            $recommendations += "Stop initial replication (IR) or pause delta replication (DR) for other low-priority VMs migrating under this appliance to free up CPU."
                            $recommendations += "Decrease the number of workers (parallel disk replications)."
                            $recommendations += "If only the primary appliance is present, consider adding or increasing the number of scale-out appliances.`n"
                    }
                    elseif ($resourceNorm -like "*network bandwidth*") {
                            $recommendations += "`nResource `"$resource`" is $status. Recommendations:"
                            $recommendations += "Pause or stop other processes utilizing the network."
                            $recommendations += "Stop initial replication (IR) or pause delta replication (DR) for other low-priority VMs migrating under this appliance to free up network bandwidth."
                            $recommendations += "Decrease the number of workers (parallel disk replications)."
                            $recommendations += "Review and adjust Quality of Service (QoS) limits per process if applicable."
                            $recommendations += "Increase the network bandwidth available to the appliance.`n"
                    }
                    elseif ($resourceNorm -like "*nfc buffer*") {
                        if ($isQueued) {
                            $recommendations += "`nResource `"$resource`" is $status. Recommendations:"
                            $recommendations += "Stop initial replication (IR) or pause delta replication (DR) for other low-priority VMs migrating under this appliance to free up NFC buffer on the ESXi host."
                            $recommendations += "Perform vMotion for other low-priority virtual machines."
                            $recommendations += "Increase the size of the NFC buffer on the ESXi host."
                            $recommendations += "Stop or schedule blackout windows for other backup providers running on the ESXi host.`n"
                        }
                    }
                    elseif ($resourceNorm -like "*parallel disk replicated*") {
                            if ($isQueued) {
                                $recommendations += "`nResource `"$resource`" is $status. Recommendations:"
                                $recommendations += "Add a scale-out appliance to distribute the migration workload more effectively."
                                $recommendations += "Stop initial replication (IR) or pause delta replication (DR) for other low-priority VMs migrating under this appliance to free up parallel disk replication capacity."
                                $recommendations += "If this is the only bottleneck and all other resources are available, increase the number of workers (parallel disk replications)."
                            }
                    }
                    elseif ($resourceNorm -like "*datastore*" -and $resourceNorm -like "*snapshot*") {
                            if ($isQueued) {
                                $recommendations += "`nResource `"$resource`" is $status. Recommendations:"
                                $recommendations += "Pause or stop replications for other VMs migrating under this appliance to free up snapshot capacity."
                                $recommendations += "Increase the snapshot count supported by the datastore."
                                $recommendations += "Perform storage vMotion for other low-priority replicating VMs.`n"
                            }
                    }
                }
            }

            if ($recommendations.Count -gt 0) {
                $op = $output.Add("Based on the resource utilization seen above, here are suggestions to expedite server $($ReplicationMigrationItem.MachineName) migration:")
                foreach ($rec in $recommendations) {
                    $op = $output.Add("$rec")
                }
            }
        }

        if ($parameterSet -eq "GetByApplianceName" -or $parameterSet -eq "ListByName") {
            if ($parameterSet -eq "ListByName") {
                $desiredCols = @("Appliance","Server","State","Progress","TimeElapsed","TimeRemaining","UploadSpeed","Health","LastSync", "ESXiHost", "Datastore")
            }
            elseif ($parameterSet -eq "GetByApplianceName") {
                $desiredCols = @("Server","State","Progress","TimeElapsed","TimeRemaining","UploadSpeed","Health","LastSync","ESXiHost","Datastore")
            }
            else {
                $desiredCols = $vmMigrationStatusTable.Columns | ForEach-Object { $_.ColumnName }
            }

            $existingCols = $vmMigrationStatusTable.Columns | ForEach-Object { $_.ColumnName }
            $cols = $desiredCols | Where-Object { $existingCols -contains $_ }

            if (-not $cols -or $cols.Count -eq 0) { $cols = $existingCols }

            # Select columns explicitly and force Format-Table to render all of them (no truncation)
            $vmMigrationStatusTable = $vmMigrationStatusTable | Select-Object -Property $cols | Format-Table -Property $cols -AutoSize -Wrap -Force | Out-String -Width 4096
            $op = $output.Add($vmMigrationStatusTable)

            $op = $output.Add("To check expedite the operation of a server use the command")
            $op = $output.Add("Get-AzMigrateServerMigrationStatus  -ProjectName <String> -ResourceGroupName <String> -MachineName <String> -Expedite`n")
            $op = $output.Add("To resolve the health issue use the command")
            $op = $output.Add("Get-AzMigrateServerMigrationStatus -ProjectName <String> -ResourceGroupName <String> -MachineName <String> -Health`n")
        }

        return $output;
    }
}
# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAK71smzg4xHitV
# xGHhouLeTrCgIZU0mT8rOym0onp456CCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHMp16k95r576oWfTwAYYHLz
# k4Kn4tqz30MA0lfkvNcBMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAj8KJxev2RzZbkSk/D81jOLMuLdO4Uo8LWRnzzs5wosPnCES6iueVbAgd
# 1Hz0id3+PI8cEgaWHkLVpyF9zGpHdny+76PPa/o0fdNZMPmWKcxvaPS+zd0TSIP+
# 4dfilELA2lTasg6s19CNoUnD424RUddF695x6IofT7LLoWmfGgZe2obvpNfv7kLf
# ze2/rYmwjahSWp6m0xX+1DVSh6g/jSke/NI1i+XKfeJdUuQ8lv0htDt8TBa0pRO1
# 0698tsOU2DrKu4nRo3+Qi/in+4aJJ7Wp8cREVguet4sJ6cBEMdfeN7dARFPYcJt3
# ym3M8KJwgnWmnNk4HIXxoM7hIeaehqGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCA/rTTkox7ZHKPU0wGaWltWB4Bc8trHBSeOk5OjKQ4t2AIGaTsoc+J/
# GBMyMDI2MDExMDAxMTUwOS45NzdaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODkwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAg4syyh9lSB1YwABAAACDjANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQz
# MDNaFw0yNjA0MjIxOTQzMDNaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODkwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCs5t7iRtXt0hbeo9ME78ZYjIo3saQuWMBFQ7X4s9vo
# oYRABTOf2poTHatx+EwnBUGB1V2t/E6MwsQNmY5XpM/75aCrZdxAnrV9o4Tu5sBe
# pbbfehsrOWRBIGoJE6PtWod1CrFehm1diz3jY3H8iFrh7nqefniZ1SnbcWPMyNIx
# uGFzpQiDA+E5YS33meMqaXwhdb01Cluymh/3EKvknj4dIpQZEWOPM3jxbRVAYN5J
# 2tOrYkJcdDx0l02V/NYd1qkvUBgPxrKviq5kz7E6AbOifCDSMBgcn/X7RQw630Qk
# zqhp0kDU2qei/ao9IHmuuReXEjnjpgTsr4Ab33ICAKMYxOQe+n5wqEVcE9OTyhmW
# ZJS5AnWUTniok4mgwONBWQ1DLOGFkZwXT334IPCqd4/3/Ld/ItizistyUZYsml/C
# 4ZhdALbvfYwzv31Oxf8NTmV5IGxWdHnk2Hhh4bnzTKosEaDrJvQMiQ+loojM7f5b
# gdyBBnYQBm5+/iJsxw8k227zF2jbNI+Ows8HLeZGt8t6uJ2eVjND1B0YtgsBP0cs
# BlnnI+4+dvLYRt0cAqw6PiYSz5FSZcbpi0xdAH/jd3dzyGArbyLuo69HugfGEEb/
# sM07rcoP1o3cZ8eWMb4+MIB8euOb5DVPDnEcFi4NDukYM91g1Dt/qIek+rtE88VS
# 8QIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFIVxRGlSEZE+1ESK6UGI7YNcEIjbMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQB14L2TL+L8OXLxnGSal2h30mZ7FsBFooiY
# kUVOY05F9pnwPTVufEDGWEpNNy2OfaUHWIOoQ/9/rjwO0hS2SpB0BzMAk2gyz92N
# GWOpWbpBdMvrrRDpiWZi/uLS4ZGdRn3P2DccYmlkNP+vaRAXvnv+mp27KgI79mJ9
# hGyCQbvtMIjkbYoLqK7sF7Wahn9rLjX1y5QJL4lvEy3QmA9KRBj56cEv/lAvzDq7
# eSiqRq/pCyqyc8uzmQ8SeKWyWu6DjUA9vi84QsmLjqPGCnH4cPyg+t95RpW+73sn
# hew1iCV+wXu2RxMnWg7EsD5eLkJHLszUIPd+XClD+FTvV03GfrDDfk+45flH/eKR
# Zc3MUZtnhLJjPwv3KoKDScW4iV6SbCRycYPkqoWBrHf7SvDA7GrH2UOtz1Wa1k27
# sdZgpG6/c9CqKI8CX5vgaa+A7oYHb4ZBj7S8u8sgxwWK7HgWDRByOH3CiJu4LJ8h
# 3TiRkRArmHRp0lbNf1iAKuL886IKE912v0yq55t8jMxjBU7uoLsrYVIoKkzh+sAk
# gkpGOoZL14+dlxVM91Bavza4kODTUlwzb+SpXsSqVx8nuB6qhUy7pqpgww1q4SNh
# AxFnFxsxiTlaoL75GNxPR605lJ2WXehtEi7/+YfJqvH+vnqcpqCjyQ9hNaVzuOEH
# X4MyuqcjwjCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNQ
# MIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg5MDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQBK
# 6HY/ZWLnOcMEQsjkDAoB/JZWCKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7QvfYjAiGA8yMDI2MDEwOTIwMTEx
# NFoYDzIwMjYwMTEwMjAxMTE0WjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDtC99i
# AgEAMAoCAQACAglxAgH/MAcCAQACAhKSMAoCBQDtDTDiAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBALtQRyXtJeLZFBmr0UNipM172kjEzQ2GY4tNXimmEJMt
# 1F+OjI/IobHGWiEXfjN1ZyYmGvbG0C/2gRIgv4Ew+zLblJqy2o9lA/oUGn/oWSuL
# dIeJeGapG0aAJwKwpOpamvyVbkcj277330TGlYNb8zwnErWlax5zNJle4FNSUVQW
# qm/vJP1DKP9c6RgdU1wFjR4k48T/G4YCKD1ADrWrAZlUifLe9lKgAXfqfzG7X9ob
# CMdGkDbDO0CZXLKLLkwLlCO46nZaq5M1i6ePpr2arcOPEbpXczyvxo3TGsy1W2QJ
# MV9Ie5pZumgg7Oqp2UTcUpdJKDRnK44tUsIGKzVGb7MxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAg4syyh9lSB1YwABAAAC
# DjANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCD3qdjIF1c1zwnS3cc+9ITPJfV/IvZttmA4Y/z7QrWQ
# cTCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIAF0HXMl8OmBkK267mxobKSi
# hwOdP0eUNXQMypPzTxKGMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIOLMsofZUgdWMAAQAAAg4wIgQgRyRxkHVWjRpkMcjiCD/rnr35
# T6/vBa2C0nQL/WLXgJUwDQYJKoZIhvcNAQELBQAEggIAXF/GsNbY5lixS3XvSKp5
# Ju00SQpfLtZQhGNxNZrHYNjvKXG7n7anN5Bv3p91e1eHRD+wkcc+rvUdIQUngM+c
# LM9vWpu/Vu8A1Rg7+nof9RN1hJM6rEUDWmuLLprC4+gDqkNJYasgl03+5pVu7cTF
# 9PH26NJDUaWSE035BQq3AZOm7VWAv09eJhIsYn1PHWj5ObwNSgOq53unNCSnp7Zq
# 2MXJ+cON3L/d2wqqS/5ZbmVh7MFf2G6nINS/8au3Rog1WnfRilTSF3rriUtvoniV
# TxJ7SsHZMfUv8slyMN4qbakA2EfPFrLVec2C09fwAsO137RNCRm53mPCeK5qfnvd
# E6RzBML0aBzzw4EcN9HrW5Jn1jYfMFZoojwZFVAL3JoFmDTMTtkCVtn/AS9KH3k6
# q9yadOKQeNY3erIpC1RCXPR/OqAb11JaWtkKZQvMraRXj8JNrUI4MSYVHdlhMXK3
# 1/kyCjtyApSx24lwuCQDWjqSj3T4Ysf3exYAPbQy7kgQlY5vWzbOsEoyNvE9y4tC
# dOp6y2rasJXPilp9bOt4tHC/G/PFfVbwPi20u+f2nhqfxOoyLUvqjgZEFMVZgm22
# Nd33sEdnk6wlnKVbwTy0GjPNi99PvHQgzFQlJ1pHrpDR9ULRmyDEXYhCyLN2Obxd
# 4uVQvUaQr/KuwHfe2si8aK4=
# SIG # End signature block

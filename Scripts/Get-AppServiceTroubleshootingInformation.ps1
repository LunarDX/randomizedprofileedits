<#
.SYNOPSIS
    Queries Application Insights for App Service 500 Errors & Paths and/or Response Time for the last 1,2,3, or 4 hours of data. Defaults to 1 hour.
.DESCRIPTION
    Queries Application Insights for App Service 500 Errors & Paths and/or Response Time for the last 1,2,3, or 4 hours of data. Defaults to 1 hour.
.EXAMPLE
    PS C:\> .\Get-AppServiceServerSideErrorInformation.ps1 -AppServiceName 'SomeAppServiceNameExample' -SubscriptionId '2f1d55cf-80ef-4dfd-9592-2e16bdd1d994' -GetResponseTime
.EXAMPLE
    PS C:\> .\Get-AppServiceServerSideErrorInformation.ps1 -AppServiceName 'SomeAppServiceNameExample' -SubscriptionId '2f1d55cf-80ef-4dfd-9592-2e16bdd1d994' -HourLookBack 2 -GetErrors
.EXAMPLE
    PS C:\> .\Get-AppServiceServerSideErrorInformation.ps1 -AppServiceName 'SomeAppServiceNameExample' -SubscriptionId '2f1d55cf-80ef-4dfd-9592-2e16bdd1d994' -HourLookBack 2 -GetErrors -GetResponseTime
.INPUTS
    Mandatory Params:
    AppServiceName       App Service Name [String], copied from ticket
    SubscriptionId       Azure SubscriptionId [String], copied from ticket
    Optional Params:
    HourLookBack         Number of hours to look back [String], default is 1
    TenantId             Required only if not using default tenant (no lighthouse access), copied from ticket
.OUTPUTS
    Returns a message with a markdown table containing the following columns (GetErrors):
    app_service_name
    operation_Name
    total_operation_requests
    resultCode
    count_operations_by_resultcode
    percentage_of_requests_fail_to_endpoint
    Sets clipboard with markdown table output
    Returns a message with a markdown table containing the following columns (GetResponseTime):
    app_service_name
    avg_respsonse_time_ms
    max_response_time_ms
    min_response_time_ms
    Sets clipboard with markdown table output
.NOTES
    This script is intended to be used by Support Team to troubleshoot Site Down For App Service Alerts and provide insights to clients.
#>
[CmdletBinding()]
param (  
    [Parameter(Mandatory)]
    [ValidatePattern("^[a-z0-9](?!.*--)[a-z0-9-]{0,58}[a-z0-9]$")]
    [string]
    $AppServiceName,
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}$")]
    [string]
    $SubscriptionId,
    [Parameter()]
    [ValidateSet('1','2','3','4')]
    [string]
    $HourLookBack = '1',
    [Parameter()]
    [ValidatePattern("^[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}$")]
    [string]
    $TenantId = '5ea0ee02-63f2-4351-9be8-17586a8089d8',
    [Parameter()]
    [switch]
    $GetResponseTime,
    [Parameter()]
    [switch]
    $GetErrors
)
Function ConvertTo-MarkdownTable {
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [PSObject[]]$collection,
        [Parameter(Mandatory = $false)]
        [boolean]$IncludeHeader = $true
    )

    Begin {
        $items = @()
        $columns = [ordered]@{}
    }

    Process {
        ForEach($item in $collection) {
            $items += $item
            $item.PSObject.Properties | ForEach-Object {
                if ($_.Value) {
                    if(-not $columns.Contains($_.Name) -or $columns[$_.Name] -lt $_.Value.ToString().Length) {
                        $columns[$_.Name] = $_.Value.ToString().Length
                    }
                }
            }
        }
    }

    End {
        ForEach($key in $($columns.Keys)) {
            $columns[$key] = [Math]::Max($columns[$key], $key.Length)
        }

        if ($IncludeHeader) {
            $header = @()
            ForEach($key in $columns.Keys) {
                $header += ('{0,-' + $columns[$key] + '}') -f $key
            }
            $header -join ' | '

            $separator = @()
            ForEach($key in $columns.Keys) {
                $separator += '-' * $columns[$key]
            }
            $separator -join ' | '
        }

        ForEach($item in $items) {
            $values = @()
            ForEach($key in $columns.Keys) {
                $values += ('{0,-' + $columns[$key] + '}') -f $item.($key)
            }
            $values -join ' | '
        }
    }
}
Function Get-AppServiceServerSideErrorInformation {
    [CmdletBinding()]
    param (  
        [Parameter(Mandatory)]
        [ValidatePattern("^[a-z0-9](?!.*--)[a-z0-9-]{0,58}[a-z0-9]$")]
        [string]
        $AppServiceName,
        [Parameter(Mandatory)]
        [securestring]
        $AccessToken,
        [Parameter(Mandatory)]
        [string]
        $AppInsightsAppId,
        [Parameter()]
        [ValidateSet('1','2','3','4')]
        [string]
        $HourLookBack = '1'
    )
    try{
        # Set App Insights Access Url
        $appInsightsAccessUrl = 'api.applicationinsights.io'
        # Get Access Token
        $accessTokenBearer = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccessToken))
        # Set Headers with Access Token Authorization
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Bearer $accessTokenBearer")
    
        # Set Query Body
        $body = @{
            query = "requests
            | where cloud_RoleName =~ '$($appServiceName)'
            | where timestamp >= ago($($HourLookBack)h)
            | summarize total_operation_requests = count() by app_service_name = cloud_RoleName, operation_Name
            | join
            (
                requests
                | where timestamp >= ago($($HourLookBack)h)
                | where cloud_RoleName =~ '$($appServiceName)'
                | summarize count_operations_by_resultcode = count() by resultCode, app_service_name = cloud_RoleName, operation_Name
            )
            on app_service_name, operation_Name
            | join(
            requests
            | where timestamp  >= ago($($HourLookBack)h)
            | where cloud_RoleName =~ '$($appServiceName)'
            | summarize average_operation_response_time_ms = round(avg(duration)) by app_service_name = cloud_RoleName, operation_Name
            ) on app_service_name, operation_Name
            | where toint(resultCode) >= 500
            | project-away  app_service_name1, operation_Name1, app_service_name2, operation_Name2
            | extend percentage_of_requests_failed_to_endpoint  = (count_operations_by_resultcode*100/total_operation_requests)
            | sort by operation_Name"
        } | ConvertTo-Json
    
        # Invoke Rest Method to get search results
        Write-Verbose "Getting App Insights data for $appServiceName"
            $searchResults = Invoke-RestMethod  -Method POST -Headers $headers -Body $body -Uri "https://${appInsightsAccessUrl}/v1/apps/$appInsightsAppId/query"
            # Check if search results have tables
            if($searchResults.tables) {
                # Loop through tables and display rows
                foreach($table in $searchResults.tables) {
                    if($table.rows) {
                        $rows = New-Object System.Collections.Generic.List[System.Object]
                        foreach ($row in $table.rows) {
                            $rowData = [ordered]@{}
                            for ($i = 0; $i -lt $table.columns.Count; $i++) {
                                $columnName = $table.columns[$i].name
                                $columnValue = $row[$i]
                                $rowData[$columnName] = $columnValue
                            }
                            $rows.Add((New-Object PSObject -Property $rowData))
                        }
                        $rows
                    } else{
                        Write-Warning "No 500 error data returned for $($AppServiceName) in table $($table.name) in the last $($HourLookBack) hour(s) `nTry increasing the lookback period."
                    }
                }
            }
    } catch {
        throw "Failed to get App Insights data - $($_.Exception.Message)"
    }  
}
Function Get-AppServicePlatformStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        #[ValidatePattern("^[a-z0-9](?!.*--)[a-z0-9-]{0,58}[a-z0-9]$")]
        [Microsoft.Azure.Management.WebSites.Models.Site]
        $AppService
    )
    try{
            $defaultHostName = $appService.DefaultHostName
            try{
                $response = Invoke-WebRequest -Uri "https://$defaultHostName" -UseBasicParsing -ErrorAction Stop
            } catch {
                $response = @{
                    StatusCode = $($_.Exception.StatusCode)
                }
            }
            $defaultDeny = [array]($appService.Siteconfig.IpSecurityRestrictions | Where-Object Action -eq Deny).Description -contains 'Deny all access'
            [PSCustomObject]@{
                Name = $appService.Name
                ResponseCode = $response.StatusCode
                DefaultDeny = $defaultDeny
                State = $appService.State
                DefaultHostName = $defaultHostName
            }
  
    } catch {
        Write-Error "Failed to get App Service data - $($_.Exception.Message)"
    }
}
Function Get-AppAssociatedInsights {
    param(
        [Parameter(Mandatory)]
        [ValidatePattern("^[a-z0-9](?!.*--)[a-z0-9-]{0,58}[a-z0-9]$")]
        [string]
        $AppServiceName
    )
    try{
        # Get App Service and App Insights Instrumentation Key
        Write-Verbose "Getting App Service and App Insights Instrumentation Key for $appServiceName"
        $appService = Get-AzResource -ResourceType 'microsoft.web/sites' -Name $appServiceName | Get-AzWebApp #| Select-Object Name, @{Name='InstrumentationKey';Expression={($_.SiteConfig.AppSettings | where {$_.Name -eq 'APPINSIGHTS_INSTRUMENTATIONKEY'}).Value}}
        if($null -ne $appService){
            # Gett App Insights from Instrumentation Key
            Write-Verbose "Getting App Insights App Id from Instrumentation Key"
            $appInsights = (Get-AzApplicationInsights | Where-Object {$_.InstrumentationKey -eq ($appService.SiteConfig.AppSettings | Where-Object {$_.Name -eq 'APPINSIGHTS_INSTRUMENTATIONKEY'}).Value})
            [PSCustomObject]@{
                AppService = $appService
                ApplicationInsights = $appInsights
            }
        } else {
            throw "App Service $AppServiceName not found"
        }
    } catch {
        throw "$($_.Exception.Message)"
    }
}
Function Get-AppServiceResponseTimeInformation {
    [CmdletBinding()]
    param (  
        [Parameter(Mandatory)]
        [ValidatePattern("^[a-z0-9](?!.*--)[a-z0-9-]{0,58}[a-z0-9]$")]
        [string]
        $AppServiceName,
        [Parameter(Mandatory)]
        [securestring]
        $AccessToken,
        [Parameter(Mandatory)]
        [string]
        $AppInsightsAppId,
        [Parameter()]
        [ValidateSet('1','2','3','4')]
        [string]
        $HourLookBack = '1'
    )
    try{
        # Set App Insights Access Url
        $appInsightsAccessUrl = 'api.applicationinsights.io'
        # Get Access Token
        $accessTokenBearer = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccessToken))
        # Set Headers with Access Token Authorization
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Bearer $accessTokenBearer")
    
        # Set Query Body
        $body = @{
            query = "requests
            | where cloud_RoleName =~ '$($appServiceName)'
            | where timestamp >= ago($($HourLookBack)h)
            | summarize avg_respsonse_time_ms = round(avg(duration)), max_response_time_ms = round(max(duration)), min_response_time_ms = round(min(duration)) by app_service_name = cloud_RoleName"
        } | ConvertTo-Json
    
        # Invoke Rest Method to get search results
        Write-Verbose "Getting App Insights data for $appServiceName"
            $searchResults = Invoke-RestMethod  -Method POST -Headers $headers -Body $body -Uri "https://${appInsightsAccessUrl}/v1/apps/$appInsightsAppId/query"
            # Check if search results have tables
            if($searchResults.tables) {
                # Loop through tables and display rows
                foreach($table in $searchResults.tables) {
                    if($table.rows) {
                        $rows = New-Object System.Collections.Generic.List[System.Object]
                        foreach ($row in $table.rows) {
                            $rowData = [ordered]@{}
                            for ($i = 0; $i -lt $table.columns.Count; $i++) {
                                $columnName = $table.columns[$i].name
                                $columnValue = $row[$i]
                                $rowData[$columnName] = $columnValue
                            }
                            $rows.Add((New-Object PSObject -Property $rowData))
                        }
                        $rows
                    } else{
                        Write-Warning "No response time data returned for $($AppServiceName) in table $($table.name) for the last $($HourLookBack) hour(s) `nTry increasing the lookback period."
                    }
                }
            }
    } catch {
        throw "Failed to get App Insights data - $($_.Exception.Message)"
    }  
}
try{
    Connect-AzAccount -Tenant $TenantId -WarningAction SilentlyContinue | Out-Null
    Select-AzSubscription -SubscriptionId $SubscriptionId | Out-Null
} catch {
    throw "Failed to connect to Azure - $($_.Exception.Message)"
}
try {
    # Ensure null vars
    $slowDiagUrl = $null
    $errorDiagUrl = $null
    $responseTimeMarkdown = $null
    $errorsMarkdown = $null
    # Get app service and app insights data/objects
    $appInfo = Get-AppAssociatedInsights -AppServiceName $AppServiceName
    if($null -ne $appInfo){
        try{
            # Get Diagnostics Links
            $availabilityPeformanceBlade = (($appInfo.AppService.Kind.Contains("functionapp")) ? 'AvailabilityAndPerformanceFunctionApp' : ($appInfo.AppService.Kind.Contains("linux")) ? 'AvailabilityAndPerformanceLinux' : 'AvailabilityAndPerformanceWindows')
            $errorDetectorBlade = (($appInfo.AppService.Kind.Contains("functionapp")) ? 'functionappdownanderrors' : ($appInfo.AppService.Kind.Contains("linux")) ? 'httpservererrorslinux' : 'httpservererrors')
            $errorWorkflowId = (($appInfo.AppService.Kind.Contains("functionapp")) ? '60eab745-5c95-4b59-bf5c-f0a16f38166f' : ($appInfo.AppService.Kind.Contains("linux")) ? '0d8f8781-f87b-486c-8990-a3f89430ab9e' : '98a7cabb-dc69-43e8-8a4e-9e5424bbc427')
            $slowDetectorId = (($appInfo.AppService.Kind.Contains("functionapp")) ? 'functionPerformance' : ($appInfo.AppService.Kind.Contains("linux")) ? 'LinuxAppSlow' : 'perfAnalysis')
            $slowDetectorType = (($appInfo.AppService.Kind.Contains("functionapp")) ? 'Detector' : 'Analysis')
            $slowDetectorWorflowId = (($appInfo.AppService.Kind.Contains("functionapp")) ? '42314242-3165-4f9f-b1c4-eff29b518b2c' : ($appInfo.AppService.Kind.Contains("linux")) ? '764d6797-3658-46a7-89dd-3b2e393cef2f' : '20ab9b59-fb7f-41b6-91ca-9f5d64fbbdd8')
            $errorDiagUrl = "https://portal.azure.com/#view/WebsitesExtension/SCIFrameBlade/id/{0}/categoryId/{1}/optionalParameters~/%5B%7B%22key%22%3A%22categoryId%22%2C%22value%22%3A%22{1}%22%7D%2C%7B%22key%22%3A%22detectorId%22%2C%22value%22%3A%22{2}%22%7D%2C%7B%22key%22%3A%22detectorType%22%2C%22value%22%3A%22Detector%22%7D%2C%7B%22key%22%3A%22startTime%22%7D%2C%7B%22key%22%3A%22endTime%22%7D%2C%7B%22key%22%3A%22diagnoseAndSolveWorkflowId%22%2C%22value%22%3A%22{3}%22%7D%5D" `
            -f ([System.Web.HttpUtility]::UrlEncode($appInfo.AppService.Id)), $availabilityPeformanceBlade, $errorDetectorBlade, $errorWorkflowId
            $slowDiagUrl = "https://portal.azure.com/#view/WebsitesExtension/SCIFrameBlade/id/{0}/categoryId/{1}/optionalParameters~/%5B%7B%22key%22%3A%22categoryId%22%2C%22value%22%3A%22{1}%22%7D%2C%7B%22key%22%3A%22detectorId%22%2C%22value%22%3A%22{2}%22%7D%2C%7B%22key%22%3A%22detectorType%22%2C%22value%22%3A%22{3}%22%7D%2C%7B%22key%22%3A%22startTime%22%7D%2C%7B%22key%22%3A%22endTime%22%7D%2C%7B%22key%22%3A%22diagnoseAndSolveWorkflowId%22%2C%22value%22%3A%22{4}%22%7D%5D" `
            -f ([System.Web.HttpUtility]::UrlEncode($appInfo.AppService.Id)), $availabilityPeformanceBlade, $slowDetectorId, $slowDetectorType, $slowDetectorWorflowId
            # Get App Service Platform Status
            $platformStatus = Get-AppServicePlatformStatus -AppService $appInfo.AppService
            if($platformStatus.ResponseCode -eq 200) {
                Write-Information "$($platformStatus.Name) is running `n$($platformStatus.DefaultHostName) responded with $($platformStatus.ResponseCode)" -InformationAction Continue
            } else {
                if($platformStatus.State -ne 'Running') {
                    Write-Information "$($platformStatus.Name) is $($platformStatus.State) `n$($platformStatus.DefaultHostName) responded with $($platformStatus.ResponseCode)" -InformationAction Continue
                }
                elseif($platformStatus.DefaultDeny) {
                    Write-Information "$($platformStatus.Name) is set to deny public access `n$($platformStatus.DefaultHostName) responded with $($platformStatus.ResponseCode)" -InformationAction Continue
                }
                else {
                    Write-Warning "$($platformStatus.Name) is not responding as expected `n$($platformStatus.DefaultHostName) responded with $($platformStatus.ResponseCode)" -WarningAction Continue
                }
            }
            $secureToken = (Get-AzAccessToken -ResourceUrl 'https://api.applicationinsights.io').Token | ConvertTo-SecureString -AsPlainText -Force
            if($GetResponseTime){
                $responseTimeInfo = Get-AppServiceResponseTimeInformation -AppServiceName $AppInfo.AppService.Name `
                -AccessToken $secureToken `
                -AppInsightsAppId $AppInfo.ApplicationInsights.AppId `
                -HourLookBack $HourLookBack -WarningAction Continue
                if($null -ne $responseTimeInfo){
                    $responseTimeMarkdown = $responseTimeInfo | ConvertTo-MarkdownTable
                }
                $responseTimeAppInsightsUrl = "https://portal.azure.com/#@/resource{0}/performance" -f $AppInfo.ApplicationInsights.Id
            }
            if($GetErrors){
                $errorInfo = Get-AppServiceServerSideErrorInformation -AppServiceName $AppInfo.AppService.Name `
                -AccessToken $secureToken `
                -AppInsightsAppId $AppInfo.ApplicationInsights.AppId `
                -HourLookBack $HourLookBack -WarningAction Continue
                if($null -ne $errorInfo){
                    $errorsMarkdown = $errorInfo | ConvertTo-MarkdownTable
                }
                $errorsAppInsightsUrl = "https://portal.azure.com/#@/resource{0}/failures" -f $AppInfo.ApplicationInsights.Id
            }
            $output = New-Object System.Text.StringBuilder
            $output.Append("Greetings,`n`n") | Out-Null
            $output.Append("Atmosera has been alerted to an abnormal {0} from the App $($AppServiceName).`n" `
            -f ((($GetResponseTime) -and ($GetErrors)) ? 'average response time and number of 500 errors' : ($GetResponseTime) ? 'average response time' : 'number of 500 errors')) | Out-Null
            $output.Append("Please find the Application Insights data below:`n`n") | Out-Null
            if($null -ne $platformStatus){
                $platformMarkdown = $platformStatus | ConvertTo-MarkdownTable
                $output.Append("### App Service Info`n") | Out-Null
                foreach($line in $platformMarkdown){
                    $output.Append("$line `n") | Out-Null
                }
                $output.Append("`n`n") | Out-Null
            }
            if($null -ne $responseTimeMarkdown){
                $output.Append("### Response Time Information`n") | Out-Null
                foreach($line in $responseTimeMarkdown){
                    $output.Append("$line `n") | Out-Null
                }
                $output.Append("`n`n") | Out-Null
            }
            if($null -ne $errorsMarkdown){
                $output.Append("### 500 Errors & Paths Information`n") | Out-Null
                foreach($line in $errorsMarkdown){
                    $output.Append("$line `n") | Out-Null
                }
                $output.Append("`n`n") | Out-Null
            }
            if($GetResponseTime) {
                $output.Append("For more response time information, please visit the following link(s): [Web App Slow Diagnostics]($slowDiagUrl)`n") | Out-Null
                $output.Append("[Application Insights Performance]($responseTimeAppInsightsUrl)`n`n") | Out-Null
            }
            if($GetErrors) {
                $output.Append("For more 500 errors information, please visit the following link(s): [HTTP Server Errors Diagnostics]($errorDiagUrl)`n ") | Out-Null
                $output.Append("[Application Insights Failures]($errorsAppInsightsUrl)`n`n") | Out-Null
            }
            $output.ToString()
            Set-Clipboard -Value $output.ToString()
        } catch {
            $e = "Failed to get App Service Platform Status - $($_.Exception.Message)"
            $e += "`nPlease check the App Service status manually in the Azure Portal utilizing the following links(s):"
            if($GetResponseTime){
                $e += "`nFor response time information, please visit the following link: $slowDiagUrl"
            } 
            if($GetErrors){
                $e += "`nFor 500 errors information, please visit the following link: $errorDiagUrl"
            }
            Write-Error $e
        }
    } else {
        throw "Unable to get info for $($AppServiceName) in the last $($HourLookBack) hour(s)"
    }
} catch {
    throw "Failed to get App Service data - $($_.Exception.Message)"
}
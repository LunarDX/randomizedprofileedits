
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
Update vNet Peering for workspace.
.Description
Update vNet Peering for workspace.
.Example
Update-AzDatabricksVNetPeering -Name vnet-peering-t1 -WorkspaceName azps-databricks-workspace-t1 -ResourceGroupName azps_test_gp_db -AllowForwardedTraffic $True
.Example
Get-AzDatabricksVNetPeering -WorkspaceName azps-databricks-workspace-t1 -ResourceGroupName azps_test_gp_db -Name vnet-peering-t1 | Update-AzDatabricksVNetPeering -AllowGatewayTransit $true

.Outputs
Microsoft.Azure.PowerShell.Cmdlets.Databricks.Models.Api20240501.IVirtualNetworkPeering
.Link
https://learn.microsoft.com/powershell/module/az.databricks/update-azdatabricksvnetpeering
#>
function Update-AzDatabricksVNetPeering {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Databricks.Models.Api20240501.IVirtualNetworkPeering])]
    [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Runtime.OutputBreakingChangeAttribute("Microsoft.Azure.PowerShell.Cmdlets.Databricks.Models.Api20240501.IVirtualNetworkPeering", "15.0.0", "2.0.0", "2025/11/03", ReplacementCmdletOutputType = "Microsoft.Azure.PowerShell.Cmdlets.Databricks.Models.IVirtualNetworkPeering", DeprecatedOutputProperties = ("DatabrickAddressSpaceAddressPrefix, RemoteAddressSpaceAddressPrefix 'System.String[]'"), NewOutputProperties = ("DatabrickAddressSpaceAddressPrefix, RemoteAddressSpaceAddressPrefix 'System.Collections.Generic.List`1[System.String]'"))]
    [CmdletBinding(DefaultParameterSetName = 'UpdateExpanded', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ParameterSetName = 'UpdateExpanded', Mandatory, HelpMessage = "The name of the VNetPeering.")]
        [Alias('PeeringName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Path')]
        [System.String]
        # The name of the workspace vNet peering.
        ${Name},
    
        [Parameter(ParameterSetName = 'UpdateExpanded', Mandatory, HelpMessage = "The name of the resource group. The name is case insensitive.")]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Path')]
        [System.String]
        # The name of the resource group.
        # The name is case insensitive.
        ${ResourceGroupName},
    
        [Parameter(ParameterSetName = 'UpdateExpanded', Mandatory, HelpMessage = "The name of the workspace.")]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Path')]
        [System.String]
        # The name of the workspace.
        ${WorkspaceName},

        [Parameter(ParameterSetName = 'UpdateExpanded', HelpMessage = "The ID of the target subscription.")]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # The ID of the target subscription.
        ${SubscriptionId},

        [Parameter(ParameterSetName = 'UpdateViaIdentityExpanded', Mandatory, ValueFromPipeline, HelpMessage = "Identity parameter. To construct, see NOTES section for INPUTOBJECT properties and create a hash table.")]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Models.IDatabricksIdentity]
        # Identity Parameter
        # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
        ${InputObject},
    
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Body')]
        # [System.Management.Automation.SwitchParameter]
        [System.Boolean]
        # Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network.
        ${AllowForwardedTraffic},
    
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Body')]
        [System.Boolean]
        # [System.Management.Automation.SwitchParameter]
        # If gateway links can be used in remote virtual networking to link to this virtual network.
        ${AllowGatewayTransit},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Body')]
        [System.Boolean]
        # [System.Management.Automation.SwitchParameter]
        # Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space.
        ${AllowVirtualNetworkAccess},

        [Parameter()]
        [AllowEmptyCollection()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Body')]
        [System.String[]]
        # A list of address blocks reserved for this virtual network in CIDR notation.
        ${DatabricksAddressSpacePrefix},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Body')]
        [System.String]
        # The Id of the databricks virtual network.
        ${DatabricksVirtualNetworkId},

        [Parameter()]
        [AllowEmptyCollection()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Body')]
        [System.String[]]
        # A list of address blocks reserved for this virtual network in CIDR notation.
        ${RemoteAddressSpacePrefix},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Body')]
        [System.String]
        # The Id of the remote virtual network.
        ${RemoteVirtualNetworkId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Body')]
        [System.Boolean]
        # [System.Management.Automation.SwitchParameter]
        # If remote gateways can be used on this virtual network.
        # If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit.
        # Only one peering can have this flag set to true.
        # This flag cannot be set if virtual network already has a gateway.
        ${UseRemoteGateway},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The DefaultProfile parameter is not functional.
        # Use the SubscriptionId parameter when available if executing the cmdlet against a different subscription.
        ${DefaultProfile},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Databricks.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {
        try {
            # 1.Get
            $hasAllowForwardedTraffic = $PSBoundParameters.Remove('AllowForwardedTraffic')
            $hasAllowGatewayTransit = $PSBoundParameters.Remove('AllowGatewayTransit')
            $hasAllowVirtualNetworkAccess = $PSBoundParameters.Remove('AllowVirtualNetworkAccess')
            $hasDatabricksAddressSpacePrefix = $PSBoundParameters.Remove('DatabricksAddressSpacePrefix')
            $hasDatabricksVirtualNetworkId = $PSBoundParameters.Remove('DatabricksVirtualNetworkId')
            $hasRemoteAddressSpacePrefix = $PSBoundParameters.Remove('RemoteAddressSpacePrefix')
            $hasRemoteVirtualNetworkId = $PSBoundParameters.Remove('RemoteVirtualNetworkId')
            $hasUseRemoteGateway = $PSBoundParameters.Remove('UseRemoteGateway')
            $hasAsJob = $PSBoundParameters.Remove('AsJob')
            $null = $PSBoundParameters.Remove('WhatIf')
            $null = $PSBoundParameters.Remove('Confirm')

            $vnetPeering = Get-AzDatabricksVNetPeering @PSBoundParameters

            # 2. PUT
            $null = $PSBoundParameters.Remove('InputObject')
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('Name')
            $null = $PSBoundParameters.Remove('WorkspaceName')
            $null = $PSBoundParameters.Remove('SubscriptionId')

            if ($hasAllowForwardedTraffic) {
                $vnetPeering.AllowForwardedTraffic = $AllowForwardedTraffic
            }
            if ($hasAllowGatewayTransit) {
                $vnetPeering.AllowGatewayTransit = $AllowGatewayTransit
            }
            if ($hasAllowVirtualNetworkAccess) {
                $vnetPeering.AllowVirtualNetworkAccess = $AllowVirtualNetworkAccess
            }
            if ($hasDatabricksAddressSpacePrefix) {
                $vnetPeering.DatabrickAddressSpaceAddressPrefix = $DatabricksAddressSpacePrefix
            }
            if ($hasDatabricksVirtualNetworkId) {
                $vnetPeering.DatabrickVirtualNetworkId = $DatabricksVirtualNetworkId
            }
            if ($hasRemoteAddressSpacePrefix) {
                $vnetPeering.RemoteAddressSpaceAddressPrefix = $RemoteAddressSpacePrefix
            }
            if ($hasRemoteVirtualNetworkId) {
                $vnetPeering.RemoteVirtualNetworkId = $RemoteVirtualNetworkId
            }
            if ($hasUseRemoteGateway) {
                $vnetPeering.UseRemoteGateway = $UseRemoteGateway
            }
            if ($hasAsJob) {
                $PSBoundParameters.Add('AsJob', $true)
            }

            if ($PSCmdlet.ShouldProcess("Databricks vnet peering $($vnetPeering.Name)", "Update")) {
                Az.Databricks.private\New-AzDatabricksVNetPeering_CreateViaIdentity -InputObject $vnetPeering -VirtualNetworkPeeringParameter $vnetPeering @PSBoundParameters
            }
        }
        catch {
            throw
        }
    }
}
# SIG # Begin signature block
# MIIoOQYJKoZIhvcNAQcCoIIoKjCCKCYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCB+jChOU3HJH7q
# C87HdLRpwhcQLEnmm8BMAn/aRSm80qCCDYUwggYDMIID66ADAgECAhMzAAAEhJji
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAASEmOIS4HijMV0AAAAA
# BIQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMfI
# ws3cB6qQvuWRFJqQAdTFDFcO+CEcVzP+1EZe4I4eMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAF0R92L8QY0zHUeSNiGABKH2iM3MJ6/allQpf
# IjdOOx9mKcRc2in/Lyd4HxEW10/2EGatrccIhuceRnSrdTkWIKceks6EFCiVUMBb
# mqtDqqQKAv7pT1FM02k7BtCQBxqYgo8whTlkMwpbgO71nLl3QTAKf4PAK5fWeOJT
# GFehjAjebkty+3Zw3QMvhqyvRtq2lBcSby0d8sFVC001/mKeSREvZwkC2PLYyLIc
# cOnO1AZpnEn/vZfU7amgOixu4M8CT4tC+9uM4naKglJhH56rg53EdKFqjCYLv5n/
# Fi0AO9VkFSvKXP0hmWcHjwczjN6Qf9G0fpScCUDvS9Y7RdeO+qGCF5QwgheQBgor
# BgEEAYI3AwMBMYIXgDCCF3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCCDU4Ws6ZFiDbJ5Q3I/oNPoQvvRiet406kE
# 4uphsAkskQIGaMmElR5tGBMyMDI1MTAwOTEyNDUxMS4xMTZaMASAAgH0oIHRpIHO
# MIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046QTAwMC0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WgghHqMIIHIDCCBQigAwIBAgITMwAAAgh4nVhdksfZUgAB
# AAACCDANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDAeFw0yNTAxMzAxOTQyNTNaFw0yNjA0MjIxOTQyNTNaMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC1y3AI5lIz3Ip1nK5BMUUb
# GRsjSnCz/VGs33zvY0NeshsPgfld3/Z3/3dS8WKBLlDlosmXJOZlFSiNXUd6DTJx
# A9ik/ZbCdWJ78LKjbN3tFkX2c6RRpRMpA8sq/oBbRryP3c8Q/gxpJAKHHz8cuSn7
# ewfCLznNmxqliTk3Q5LHqz2PjeYKD/dbKMBT2TAAWAvum4z/HXIJ6tFdGoNV4WUR
# ZswCSt6ROwaqQ1oAYGvEndH+DXZq1+bHsgvcPNCdTSIpWobQiJS/UKLiR02KNCqB
# 4I9yajFTSlnMIEMz/Ni538oGI64phcvNpUe2+qaKWHZ8d4T1KghvRmSSF4YF5DNE
# JbxaCUwsy7nULmsFnTaOjVOoTFWWfWXvBuOKkBcQKWGKvrki976j4x+5ezAP36fq
# 3u6dHRJTLZAu4dEuOooU3+kMZr+RBYWjTHQCKV+yZ1ST0eGkbHXoA2lyyRDlNjBQ
# coeZIxWCZts/d3+nf1jiSLN6f6wdHaUz0ADwOTQ/aEo1IC85eFePvyIKaxFJkGU2
# Mqa6Xzq3qCq5tokIHtjhogsrEgfDKTeFXTtdhl1IPtLcCfMcWOGGAXosVUU7G948
# F6W96424f2VHD8L3FoyAI9+r4zyIQUmqiESzuQWeWpTTjFYwCmgXaGOuSDV8cNOV
# QB6IPzPneZhVTjwxbAZlaQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFKMx4vfOqcUT
# gYOVB9f18/mhegFNMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBRszKJKwAfswqd
# aQPFiaYB/ZNAYWDa040XTcQsCaCua5nsG1IslYaSpH7miTLr6eQEqXczZoqeOa/x
# vDnMGifGNda0CHbQwtpnIhsutrKO2jhjEaGwlJgOMql21r7Ik6XnBza0e3hBOu4U
# BkMl/LEX+AURt7i7+RTNsGN0cXPwPSbTFE+9z7WagGbY9pwUo/NxkGJseqGCQ/9K
# 2VMU74bw5e7+8IGUhM2xspJPqnSeHPhYmcB0WclOxcVIfj/ZuQvworPbTEEYDVCz
# SN37c0yChPMY7FJ+HGFBNJxwd5lKIr7GYfq8a0gOiC2ljGYlc4rt4cCed1XKg83f
# 0l9aUVimWBYXtfNebhpfr6Lc3jD8NgsrDhzt0WgnIdnTZCi7jxjsIBilH99pY5/h
# 6bQcLKK/E6KCP9E1YN78fLaOXkXMyO6xLrvQZ+uCSi1hdTufFC7oSB/CU5RbfIVH
# XG0j1o2n1tne4eCbNfKqUPTE31tNbWBR23Yiy0r3kQmHeYE1GLbL4pwknqaip1BR
# n6WIUMJtgncawEN33f8AYGZ4a3NnHopzGVV6neffGVag4Tduy+oy1YF+shChoXdM
# qfhPWFpHe3uJGT4GJEiNs4+28a/wHUuF+aRaR0cN5P7XlOwU1360iUCJtQdvKQaN
# AwGI29KOwS3QGriR9F2jOGPUAlpeEzCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
# SZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIy
# NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXI
# yjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjo
# YH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1y
# aa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v
# 3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pG
# ve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viS
# kR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYr
# bqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlM
# jgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSL
# W6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AF
# emzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIu
# rQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIE
# FgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEW
# M2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5
# Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
# AEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
# 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2
# LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv
# 6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZn
# OlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1
# bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4
# rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU
# 6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDF
# NLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/
# HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdU
# CbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKi
# excdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTm
# dHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZq
# ELQdVTNYs6FwZvKhggNNMIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJp
# Y2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkEwMDAtMDVF
# MC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMK
# AQEwBwYFKw4DAhoDFQCNkvu0NKcSjdYKyrhJZcsyXOUTNKCBgzCBgKR+MHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7JGpDDAi
# GA8yMDI1MTAwOTAzMjI1MloYDzIwMjUxMDEwMDMyMjUyWjB0MDoGCisGAQQBhFkK
# BAExLDAqMAoCBQDskakMAgEAMAcCAQACAgRVMAcCAQACAhH7MAoCBQDskvqMAgEA
# MDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAI
# AgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBADAOn7Aqfe+Z86ETavNEtFnBpe7U
# TkhPta09QQTxIGX1PkytvXMmhpXedfZkumnH07SL1/Hg5F/MQh3ZQq8W4XX3OYbp
# hSGRxfrmykWjw3kETBM1hVfbT/PNRbwHgsps+PXbJZZjPqdiBqQdhnd2bATx0oXw
# +vSComG5KNyB6CvyFkM3ImdF99mkdFHKZe6RwOGhXgOU9kuIE7Ltn5D+mg06UpBu
# VIc8yXCIBmkv+UfM1losWMqAGAbIvkynbb1v5FnW5+f2CWzz4SBsGyF/T8HuQPB/
# 4OaKT2opkStwLxigKLS9sYqI2Hx7A5G7DS6HvggvjbJV2N+fe2csEog1nL4xggQN
# MIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgh4
# nVhdksfZUgABAAACCDANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0G
# CyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCATAHTuzoZ0iVxf0HsDOUaH4joY
# 64GOTNR8Ky6FZC0nvjCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EII//jm8J
# Ha2W1O9778t9+Ft2Z5NmKqttPk6Q+9RRpmepMIGYMIGApH4wfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAIIeJ1YXZLH2VIAAQAAAggwIgQgx4OWsziI
# K3y7PD3rsDtYb9dq3N90dUaIPq4/z8N8hDIwDQYJKoZIhvcNAQELBQAEggIAOA7O
# uolsnncGilGIhsxnqh8P2AUvClfdNGnYsALh19ow3nLY2BAJk0F7FifacJ/kgecu
# /m1UcA656YWNpVrPZykQoUKXbzRpNKwyD34L7RgQzPHuWNsc1YaW6ewTl8tfQB13
# v4zipE47dmI4WnKuLEUTyWy9MZQglsvcKtzZHe/RNfZX9t8k52cBfVtBWnasyAuI
# 6f+cnJ/jOPp4LQmOtDtgFyJAQn6Rl+i/Aw8kz1nP7oeqKAnDJ2CpIqM0c2q9myYk
# fEb6S23vrQ5ONCoQKfJlFg3MYNBcgIQC1s95RV1XGNl8BE6/SkfZj8233vBuL2aN
# C2TDHVhBP3auA9HOmfO0TW6tDj1VHysLfECPn6Y4aatN5Vzw3SseIBr031hbh222
# qeye9NCHHLU/18Xg0lND6UxaLb4A4zV4E3DfIUUZ/tv5qf982tQpUCT/gkcjR0+g
# rMN++Fazdope6Rew1nU+Gbhowk/r/62i1L4IE2j2L5zjCtpSalWrixqAhPobj86k
# XMHy2Zts3ZH8GSv3c46uJToP0eW7Ka3r8v8/k8FvmkHXG/RFesrCaqtwR6MPGAE8
# ebXyW97PJSsWMZyCi4y4rSf9C5CJ+Effv96SNwmFb2jdOHenNyDUN6y4b1E8frXh
# 6AgN2G8yWwwTyzcNdqssL6ZhY+4VH5YSujuhAcg=
# SIG # End signature block

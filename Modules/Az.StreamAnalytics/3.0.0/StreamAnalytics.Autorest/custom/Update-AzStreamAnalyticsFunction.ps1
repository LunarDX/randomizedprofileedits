
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
Updates an existing function under an existing streaming job.
This can be used to partially update (ie.
update one or two properties) a function without affecting the rest the job or function definition.
.Description
Updates an existing function under an existing streaming job.
This can be used to partially update (ie.
update one or two properties) a function without affecting the rest the job or function definition.
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}

.Inputs
Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Models.IFunction
.Inputs
Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Models.IStreamAnalyticsIdentity
.Outputs
Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Models.IFunction
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

FUNCTION <IFunction>: A function object, containing all information associated with the named function. All functions are contained under a streaming job.
  [ConfigurationProperty <IFunctionConfiguration>]: 
    [Binding <IFunctionBinding>]: The physical binding of the function. For example, in the Azure Machine Learning web service’s case, this describes the endpoint.
      Type <String>: Indicates the function binding type.
    [Input <IFunctionInput[]>]: 
      [DataType <String>]: The (Azure Stream Analytics supported) data type of the function input parameter. A list of valid Azure Stream Analytics data types are described at https://msdn.microsoft.com/en-us/library/azure/dn835065.aspx
      [IsConfigurationParameter <Boolean?>]: A flag indicating if the parameter is a configuration parameter. True if this input parameter is expected to be a constant. Default is false.
    [Output <IFunctionOutput>]: Describes the output of a function.
      [DataType <String>]: The (Azure Stream Analytics supported) data type of the function output. A list of valid Azure Stream Analytics data types are described at https://msdn.microsoft.com/en-us/library/azure/dn835065.aspx
  [ETag <String>]: 
  [PropertiesType <String>]: Indicates the type of function.

FUNCTIONCONFIGURATIONPROPERTY <IFunctionConfiguration>: .
  [Binding <IFunctionBinding>]: The physical binding of the function. For example, in the Azure Machine Learning web service’s case, this describes the endpoint.
    Type <String>: Indicates the function binding type.
  [Input <IFunctionInput[]>]: 
    [DataType <String>]: The (Azure Stream Analytics supported) data type of the function input parameter. A list of valid Azure Stream Analytics data types are described at https://msdn.microsoft.com/en-us/library/azure/dn835065.aspx
    [IsConfigurationParameter <Boolean?>]: A flag indicating if the parameter is a configuration parameter. True if this input parameter is expected to be a constant. Default is false.
  [Output <IFunctionOutput>]: Describes the output of a function.
    [DataType <String>]: The (Azure Stream Analytics supported) data type of the function output. A list of valid Azure Stream Analytics data types are described at https://msdn.microsoft.com/en-us/library/azure/dn835065.aspx

INPUTOBJECT <IStreamAnalyticsIdentity>: Identity Parameter
  [ClusterName <String>]: The name of the cluster.
  [FunctionName <String>]: The name of the function.
  [Id <String>]: Resource identity path
  [InputName <String>]: The name of the input.
  [JobName <String>]: The name of the streaming job.
  [Location <String>]: The region in which to retrieve the subscription's quota information. You can find out which regions Azure Stream Analytics is supported in here: https://azure.microsoft.com/en-us/regions/
  [OutputName <String>]: The name of the output.
  [ResourceGroupName <String>]: The name of the resource group. The name is case insensitive.
  [SubscriptionId <String>]: The ID of the target subscription.
  [TransformationName <String>]: The name of the transformation.
.Link
https://learn.microsoft.com/powershell/module/az.streamanalytics/update-azstreamanalyticsfunction
#>
function Update-AzStreamAnalyticsFunction {
[OutputType([Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Models.IFunction])]
[CmdletBinding(DefaultParameterSetName='Update', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [Parameter(ParameterSetName='Update', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Path')]
    [System.String]
    # The name of the streaming job.
    ${JobName},

    [Parameter(ParameterSetName='Update', Mandatory)]
    [Alias('FunctionName')]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Path')]
    [System.String]
    # The name of the function.
    ${Name},

    [Parameter(ParameterSetName='Update', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Path')]
    [System.String]
    # The name of the resource group.
    # The name is case insensitive.
    ${ResourceGroupName},

    [Parameter(ParameterSetName='Update')]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Path')]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
    [System.String]
    # The ID of the target subscription.
    ${SubscriptionId},

    [Parameter(ParameterSetName='UpdateViaIdentity', Mandatory, ValueFromPipeline)]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Path')]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Models.IStreamAnalyticsIdentity]
    # Identity Parameter
    # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
    ${InputObject},

    [Parameter(ParameterSetName='Update', Mandatory)]
    [Parameter(ParameterSetName='UpdateViaIdentity', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Path')]
    [System.String]
    # The name of the resource group.
    # The name is case insensitive.
    ${File},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Header')]
    [System.String]
    # The ETag of the function.
    # Omit this value to always overwrite the current function.
    # Specify the last-seen ETag value to prevent accidentally overwriting concurrent changes.
    ${IfMatch},

    [Parameter()]
    [Alias('AzureRMContext', 'AzureCredential')]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Azure')]
    [System.Management.Automation.PSObject]
    # The credentials, account, tenant, and subscription used for communication with Azure.
    ${DefaultProfile},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}
)

begin {
    try {
        $functionParameters = Get-Content -Path $File | Out-String
          
        if ([Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Models.FunctionTypeConverter]::CanConvertFrom($functionParameters))
        {
          $function = [Microsoft.Azure.PowerShell.Cmdlets.StreamAnalytics.Models.FunctionTypeConverter]::ConvertFrom($functionParameters)
        } else {
          throw "The json format is invalid"
        }
        
        $PSBoundParameters.Add("Function", $function)
        $null = $PSBoundParameters.Remove("File");

        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $parameterSet = $PSCmdlet.ParameterSetName
        $mapping = @{
            Update = 'Az.StreamAnalytics.private\Update-AzStreamAnalyticsFunction_Update';
            UpdateViaIdentity = 'Az.StreamAnalytics.private\Update-AzStreamAnalyticsFunction_UpdateViaIdentity';
        }
        if (('Update') -contains $parameterSet -and -not $PSBoundParameters.ContainsKey('SubscriptionId')) {
            $PSBoundParameters['SubscriptionId'] = (Get-AzContext).Subscription.Id
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(($mapping[$parameterSet]), [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters}
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($MyInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process {
    try {
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end {
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
}

# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAI4b5DrKC0suzC
# w2YgF3qJmv0CQ36SgIVB+Mn/01XcAqCCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEID054voGTS/m8erUUZ0+KMVW
# 0BfFAfKvp0xdZndD0XsmMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAYfnz0rYSuQxvZJM75G5kECwFY92ngjoWaXpcUfgRWxRP1rhAfZ/OtUPI
# VV4fWhshaJAsCl15ohUnjqvKDgWhqEF+2AWijn4vKvoyBcc6jMJY9s0/KDs6nOAs
# VcuqT7zTY+Lga2Amb6aCecfE8KnJ8V8x8N/ZHYF9JkraFVVdPAIG+ZIrnz2eNf8c
# 8pe8gRTnLJwoyCcIybltIQGLZ1+VfqfzPkZO+o55qL736e28mGFMmLH/x6BW/TO3
# He8KSCw2JRdqfuCT3GdS3R03YqCeXpbAZjSIjbDcomSsHkUicLj/PLHNtcul0v28
# 0zYXrkSnSD98ectYXlU37g8SmDEgiaGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCAGoGsXu4K6V5N5+5ipoKNv/y+NC3bYSlL0wYQJYxcfoQIGaPC4D1kA
# GBMyMDI1MTExMTAyNTg0NC4yNDJaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MzMwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAg9XmkcUQOZG5gABAAACDzANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQz
# MDRaFw0yNjA0MjIxOTQzMDRaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MzMwMy0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCl6DTurxf66o73G0A2yKo1/nYvITBQsd50F52SQzo2
# cSrt+EDEFCDlSxZzWJD7ujQ1Z1dMbMT6YhK7JUvwxQ+LkQXv2k/3v3xw8xJ2mhXu
# wbT+s1WOL0+9g9AOEAAM6WGjCzI/LZq3/tzHr56in/Z++o/2soGhyGhKMDwWl4J4
# L1Fn8ndtoM1SBibPdqmwmPXpB9QtaP+TCOC1vAaGQOdsqXQ8AdlK6Vuk9yW9ty7S
# 0kRP1nXkFseM33NzBu//ubaoJHb1ceYPZ4U4EOXBHi/2g09WRL9QWItHjPGJYjuJ
# 0ckyrOG1ksfAZWP+Bu8PXAq4s1Ba/h/nXhXAwuxThpvaFb4T0bOjYO/h2LPRbdDM
# cMfS9Zbhq10hXP6ZFHR0RRJ+rr5A8ID9l0UgoUu/gNvCqHCMowz97udo7eWODA7L
# aVv81FHHYw3X5DSTUqJ6pwP+/0lxatxajbSGsm267zqVNsuzUoF2FzPM+YUIwiOp
# gQvvjYIBkB+KUwZf2vRIPWmhAEzWZAGTox/0vj4eHgxwER9fpThcsbZGSxx0nL54
# Hz+L36KJyEVio+oJVvUxm75YEESaTh1RnL0Dls91sBw6mvKrO2O+NCbUtfx+cQXY
# S0JcWZef810BW9Bn/eIvow3Kcx0dVuqDfIWfW7imeTLAK9QAEk+oZCJzUUTvhh2h
# YQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFJnUMQ2OtyAhLR/MD2qtJ9lKRP9ZMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBTowbo1bUE7fXTy+uW9m58qGEXRBGVMEQi
# FEfSui1fhN7jS+kSiN0SR5Kl3AuV49xOxgHo9+GIne5Mpg5n4NS5PW8nWIWGj/8j
# kE3pdJZSvAZarXD4l43iMNxDhdBZqVCkAYcdFVZnxdy+25MRY6RfaGwkinjnYNFA
# 6DYL/1cxw6Ya4sXyV7FgPdMmxVpffnPEDFv4mcVx3jvPZod7gqiDcUHbyV1gaND3
# PejyJ1MGfBYbAQxsynLX1FUsWLwKsNPRJjynwlzBT/OQbxnzkjLibi4h4dOwcN+H
# 4myDtUSnYq9Xf4YvFlZ+mJs5Ytx4U9JVCyW/WERtIEieTvTRgvAYj/4Mh1F2Elf8
# cdILgzi9ezqYefxdsBD8Vix35yMC5LTnDUoyVVulUeeDAJY8+6YBbtXIty4phIki
# hiIHsyWVxW2YGG6A6UWenuwY6z9oBONvMHlqtD37ZyLn0h1kCkkp5kcIIhMtpzEc
# PkfqlkbDVogMoWy80xulxt64P4+1YIzkRht3zTO+jLONu1pmBt+8EUh7DVct/33t
# uW5NOSx56jXQ1TdOdFBpgcW8HvJii8smQ1TQP42HNIKIJY5aiMkK9M2HoxYrQy2M
# oHNOPySsOzr3le/4SDdX67uobGkUNerlJKzKpTR5ZU0SeNAu5oCyDb6gdtTiaN50
# lCC6m44sXjCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjMzMDMtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQBe
# tIzj2C/MkdiI03EyNsCtSOMdWqCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7LzRhTAiGA8yMDI1MTExMDIxMDMw
# MVoYDzIwMjUxMTExMjEwMzAxWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDsvNGF
# AgEAMAoCAQACAhNjAgH/MAcCAQACAhSBMAoCBQDsviMFAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBALUOvvOBuxstBZjk3DIfRXjd94BQ9aBX12ZE+NAUGQRv
# 2tGJoqBpd0xRG88zt15ZGy8IyLcw/pAHcxyWHGh1BonUpqMFU2Ugk37aZKfjjaMp
# 9f+HQIgYhDmAJlEdZBe0Du9V0BM60DNLLmiDxezKO5pge4wJa1x5sUYbjcxIXAJU
# 1d+9AoqDt88dnLCzRAeryIBGqHgsbohVWuk+ND+oLvhCwN3DF7gnBQpJcnotcZ+d
# fEfxsVBTNiIfrEMayW0iG4UjA39FfxXwd8diJTxbyprkjb0Z2NC8O9sKSx3Kl+n4
# 4GFHf7g/T3JmLTgT0I9s/n/a5PQX0L3mrmxEPTV92QAxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAg9XmkcUQOZG5gABAAAC
# DzANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCD58EeCAsngTETnwpiPn+iMLOpOj+Y7OQhhzuiIDQ5V
# OzCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIN1Hd5UmKnm7FW7xP3niGsfH
# Jt4xR8Xu+MxgXXc0iqn4MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIPV5pHFEDmRuYAAQAAAg8wIgQg4dPOx8F+p4KpWTVc9zNwg6/R
# 46qYThMoqztsxH9EybEwDQYJKoZIhvcNAQELBQAEggIAeuicAeacl34ldA4aP3U7
# /8w6s61YLkii5X6SpaK97x/cZWygtFESkY3b3gTwjdvCV0BbnMRQeRoOJvfvoDl+
# nVw+g+Z9X17m4d8PA6iTei5/iWbEDc33u+Xuqj0d/Vj4ZzoySVoqUCY3ibBfdj8e
# ae9weWTTt79xH+z6OuhglNPbEAQwBRXv/223g5XMb0a3H3YBvY7vC1mBDI7rdyOp
# /t3GmILW1daXW4nFfCmol6b+yjhxKYOk9nAKi21ZYcDfKQGDzmMIz2z+dSegCJvy
# NetCvxOg/JQwTZLGcaa4y6bGdDKYLbO80Md3vAwtjjV0ICkubRJnPaEYzHCmp2kS
# 4/W0trSsVqynkElOUzxPxTt3dQ3TMz4OHYv/kottpyCAUX0nGKRBVLSjg+RcHkuv
# /IulUTXF+eenwoxYr7jdzRAC1xLSDTR7oCHtXSXOQFUEVALLhqZuV76Rbnwe7wOI
# MHkGq9gxAqZ8/pvBZCnQDdeDj7oKV5O83Usx4nZTG0Vor+w4qMnC0Tinv+hHB65n
# K1n9hpTjaLFjyn8hXxqCQDPWkgHVqgtU9nqn7LDC0glnzVmudGeuzhHnON7TgZJm
# UYGTgZ236VKEKc+RmM71hGTug2chkAp+6EFQVbkEXAnsF4/f/JnZTvLpR01nnqpt
# cF9VyIKcwumy4fu5G0NTE6c=
# SIG # End signature block

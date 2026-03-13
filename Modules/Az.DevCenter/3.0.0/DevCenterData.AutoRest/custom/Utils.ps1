function GetEndpointFromResourceGraph {
    [Microsoft.Azure.PowerShell.Cmdlets.DevCenterdata.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory, HelpMessage = 'Name of the dev center')]
        [System.String]
        ${DevCenterName},

        [Parameter(HelpMessage = 'Name of the project')]
        [System.String]
        ${Project}


    ) 

    process {
        $module = Get-Module -ListAvailable | Where-Object { $_.Name -eq "Az.ResourceGraph" }
        if (!$module) {
            $noModuleFoundMessage = "Az.ResourceGraph Module must be installed to run this command. " `
                + "Please run 'Install-Module -Name Az.ResourceGraph' to install and continue."
            Write-Error $noModuleFoundMessage -ErrorAction Stop
        }

        $query = "Resources |where type =~'Microsoft.devcenter/projects' "
        if ($Project) {
            $query += "| where name =~ '$Project' "
        }
        $query += "| extend devCenterArr = split(properties.devCenterId, '/') " `
            + "| extend devCenterName = devCenterArr[array_length(devCenterArr) -1]  "`
            + "| where devCenterName =~ '$DevCenterName' | take 1 "`
            + "| extend devCenterUri = properties.devCenterUri | project devCenterUri"
        $argResponse = Az.ResourceGraph\Search-AzGraph -Query $query
        $devCenterUri = $argResponse.devCenterUri
        if (!$devCenterUri) {
            $azContext = Get-AzContext
            $tenantId = $azContext.Tenant.Id
            $errorHelp = "under the current tenant '$tenantId'. Please contact your admin to gain access to specific projects or " +
            "use a different tenant where you have access to projects."
            if (!$Project) {
                $noProjectFound = "No projects were found in the dev center '$DevCenterName' " + $errorHelp
                Write-Error $noProjectFound -ErrorAction Stop
            }
            else {
                $noProjectFound = "No project '$Project' was found in the dev center '$DevCenterName' " + $errorHelp
                Write-Error $noProjectFound -ErrorAction Stop
            }
        }
        return $devCenterUri.Substring(0, $devCenterUri.Length - 1)
    }
}

function GetDelayedActionTimeFromAllActions {
    [Microsoft.Azure.PowerShell.Cmdlets.DevCenterdata.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Endpoint URL')]
        [System.String]
        ${Endpoint},

        [Parameter(Mandatory = $true, HelpMessage = 'Name of the project')]
        [System.String]
        ${Project},

        [Parameter(Mandatory = $true, HelpMessage = 'Name of the dev box')]
        [System.String]
        ${DevBoxName},

        [Parameter(Mandatory)]
        [System.TimeSpan]
        ${DelayTime},

        [Parameter(HelpMessage = 'User id')]
        [System.String]
        ${UserId}

    ) 

    process {
        $action = Az.DevCenterdata.internal\Get-AzDevCenterUserDevBoxAction -Endpoint $Endpoint -ProjectName `
            $Project -DevBoxName $DevBoxName -UserId $UserId | ConvertTo-Json | ConvertFrom-Json

        if (!$action) {
            $action = "No actions were found."
            Write-Error $action -ErrorAction Stop
        }
        
        $excludedDate = [DateTime]::ParseExact("0001-01-01T00:00:00.0000000", "yyyy-MM-ddTHH:mm:ss.fffffff", $null)
        $actionWithEarliestScheduledTime = $action |
        Where-Object { $null -ne $_.NextScheduledTime -and $_.NextScheduledTime -ne $excludedDate } |
        Sort-Object NextScheduledTime | Select-Object -First 1



        $newScheduledTime = $actionWithEarliestScheduledTime.NextScheduledTime + $DelayTime

        return $newScheduledTime
    }
}
function GetDelayedActionTimeFromActionName {
    [Microsoft.Azure.PowerShell.Cmdlets.DevCenterdata.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Name of the action')]
        [System.String]
        ${Name},

        [Parameter(Mandatory = $true, HelpMessage = 'Endpoint URL')]
        [System.String]
        ${Endpoint},

        [Parameter(Mandatory = $true, HelpMessage = 'Name of the project')]
        [System.String]
        ${Project},

        [Parameter(Mandatory = $true, HelpMessage = 'Name of the dev box')]
        [System.String]
        ${DevBoxName},

        [Parameter(Mandatory)]
        [System.TimeSpan]
        ${DelayTime},

        [Parameter(HelpMessage = 'User id')]
        [System.String]
        ${UserId}
        
    ) 

    process {
        $action = Az.DevCenterdata.internal\Get-AzDevCenterUserDevBoxAction -Endpoint $Endpoint -Name $Name `
            -ProjectName $Project -DevBoxName $DevBoxName -UserId $UserId | ConvertTo-Json | ConvertFrom-Json
        
        $newScheduledTime = $action.NextScheduledTime + $DelayTime

        return $newScheduledTime
    }
}

function GetDelayedEnvironmentActionTimeFromActionName {
    [Microsoft.Azure.PowerShell.Cmdlets.DevCenterdata.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Name of the action')]
        [System.String]
        ${Name},

        [Parameter(Mandatory = $true, HelpMessage = 'Endpoint URL')]
        [System.String]
        ${Endpoint},

        [Parameter(Mandatory = $true, HelpMessage = 'Name of the project')]
        [System.String]
        ${Project},

        [Parameter(Mandatory = $true, HelpMessage = 'Name of the environment')]
        [System.String]
        ${EnvironmentName},

        [Parameter(Mandatory)]
        [System.TimeSpan]
        ${DelayTime},

        [Parameter(HelpMessage = 'User id')]
        [System.String]
        ${UserId}
        
    ) 

    process {
        $action = Az.DevCenterdata.internal\Get-AzDevCenterUserEnvironmentAction -Endpoint $Endpoint -Name $Name `
            -ProjectName $Project -EnvironmentName $EnvironmentName -UserId $UserId | ConvertTo-Json | ConvertFrom-Json
        
        $newScheduledTime = $action.NextScheduledTime + $DelayTime

        return $newScheduledTime
    }
}

function ValidateAndProcessEndpoint {
    [Microsoft.Azure.PowerShell.Cmdlets.DevCenterdata.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Endpoint URL')]
        [System.String]
        ${Endpoint}     
    ) 

    process {
        $regex = "(https)://.+.*\.(devcenter.azure-test.net|devcenter.azure.com)[/]?$"
        if ($Endpoint -notmatch $regex) {
            $incorrectEndpoint = "The endpoint $Endpoint is invalid. Please ensure that the " `
                + "endpoint starts with 'https' and is properly formatted. Use " +
            "'Get-AzDevCenterAdminProject' to view the endpoint of a specific project. " +
            "Contact your admin for further assistance."

            Write-Error $incorrectEndpoint -ErrorAction Stop
        }

        if ($Endpoint.EndsWith("/")) {
            return $Endpoint.Substring(0, $Endpoint.Length - 1)
        }

        return $Endpoint

    }
}
# SIG # Begin signature block
# MIIoKQYJKoZIhvcNAQcCoIIoGjCCKBYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDuOav8KtFU3ZEv
# H7I3bMW60Dinzg/7XXHxNO6V+HWK3qCCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgkwghoFAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIG+0v7tnzD+/FSq+jODsfE55
# lQj3qOLPbnno3pr0eCIiMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAn/pXzzpygR+Xp7sez8v0jzk+DcFardFNcbctYZCylGLq7RfVDjDxIRdn
# RAtVjQYsKIEfphSaU27i72ulOkRY82Cl4skhW/e7TjQ8iw3We7U9WUglWYG01Jq1
# RUAYEUK48ip+j7kF4elxlfBnzH2687M9RPYrdM2lU6OIThZDLriK155I7vNedj/I
# OMNdWtfGPsKOBFIpBX3Cupvi4RO6v7VSFnZow8X0GG6aDne32sCC2lZ135PudRqX
# vpcwTNn1S72TieuCGaPsIOmevEZhYagkeXBjBq/moawoe3xIAK8+Ji9eo2K8EWN/
# 7xiME2un/wluSEfV5dMzP1fclLgHQKGCF5MwghePBgorBgEEAYI3AwMBMYIXfzCC
# F3sGCSqGSIb3DQEHAqCCF2wwghdoAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFRBgsq
# hkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCA8NmgMWQ9+5Id71ZhrnLZw7PzHJGJg4cZtrZSyHG3LYgIGaPBH2NUi
# GBIyMDI1MTExMTAyNTg0NS43MlowBIACAfSggdGkgc4wgcsxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo3RjAwLTA1
# RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaCC
# EeowggcgMIIFCKADAgECAhMzAAACBte8UTiYI+wsAAEAAAIGMA0GCSqGSIb3DQEB
# CwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTI1MDEzMDE5NDI1
# MFoXDTI2MDQyMjE5NDI1MFowgcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMx
# JzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo3RjAwLTA1RTAtRDk0NzElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAOlEhZsgzdGWvf3tyMdpjHzmXsj5lVYYwIEIz3XUGlTr
# 4gZYKqSyqCp59kUSMrM1UNgL1hyAhMDPbvo0aC8QKbhl82/8U/BxpIPPvFsNuw6j
# FvBCgdQ1Guj7Hm5tmFPpYl5T3sXTr68OMDD9i3W9Y6BFOqY/902v2iohsTmgIth0
# ffAj+ehiawlVzv3rqf4HtQAYBZTax7cvP7F3Gc2w1fgJHrMgxUlNJ7M//ZJM1zEl
# O72TayXv+/M6HEmEJDfyt1oSiqEYeteuZWQSFK/5LTQMwlzU4hfGp9vA+MyoRWns
# reSZzMKRu6bUE4gnbC4MBsq4l6Wm141mP9Lnw1JDDqSF+4kCW6ocreKCRL867Hj2
# pM/6tT49B424P4a2sKikW5xGZqdC/EhIY2jGcGrdR4NOqmGbpojsYwe0UPoM6MmW
# WUfWBVZc9PKK9/7i03xOY7rIiAHi4/TRsf2Of93LLFKPE9Daca9m2C2qe+reHdNG
# NGeRz57VcHW5q0NrXNRxLuveKh1OnIBN7aGCRVfebgOFHMjoDhInp9skz2KwsfwA
# YpzKaKwrNi6kB4VJMnXQkQVroyMdBhiiGgIXvtHQILAw2O8Thd8se76oo9jwZB+x
# l2KBD1yVQCLJ0WZW3rWHK2jFk/suZdvOMPRV5zLNmgvgSq7VezMGy6UCvkt3YrBz
# AgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQU7TCwsp0MalP3tzHcjKbKj9IGbhIwHwYD
# VR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZO
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIw
# VGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
# BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0
# cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMC
# B4AwDQYJKoZIhvcNAQELBQADggIBAHbcZk5971OFNS8Pb2Li3qUOnEmGlVEyZ75R
# vJmEEUJmGgZO2MN2mEACtTZDrVZiDdhVyXZF0mbk9RtnZsDvvOT6q0vEL7d03FWx
# Nx23E8NJJaDAEfFOPqkKagM1eiUBixam8dAUIcOoR8CIHFfV2ZpduJM/V3Rd9++B
# Hp2yFRypof+YV+MNkDEtTWzodxWAK8FAmUnvEQbmMUp22pqkpZxtQfBNWpdAZsiU
# dUKU0nfKpbpndQkf8IVxiItX97ry6tOYa2JnEZJhvhIFI8CtOtNh4c6VAiP/uWhV
# aZ9ZfbLgAZX8P4zPJkzK8XDhXIvRWCr3oTNArK16JV4FpUSPFAqjcBw9QtEXhTPP
# 3w/a0IzldsVndCiP08uDeuAVevSgkSF+Ha2pSuFMl3Xf6Lj996T3NaJyiyGXBeAW
# 7TTZlYFXMBIQW6oQPjyrK6Vn/aMYkFy1r4V2TaWg/YrehKPg9BB7UzPNVk7nYBc7
# jYweWGbdIejf9GFD4jUDQ3L724B6GRAfouvGStU29kbh/Q8AoxupRxcbvHOconTH
# QdivlrJYZscplFw5tT7/fhmkv02tc551UNeZJ3bKUpKX+++LVDA0mpcmX/6AmRAR
# 62qYcBQVCQW16aLwxRdAbbD9EMddfBYCMT6ogNktD+TjPZnbXq1ZpHpEMocaTB4K
# gO1C3OQdMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG
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
# e784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCA00w
# ggI1AgEBMIH5oYHRpIHOMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScw
# JQYDVQQLEx5uU2hpZWxkIFRTUyBFU046N0YwMC0wNUUwLUQ5NDcxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAARr
# R/XXxccz9U12ooGzhBfE2c33oIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQELBQACBQDsvQoFMCIYDzIwMjUxMTExMDEwNDA1
# WhgPMjAyNTExMTIwMTA0MDVaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOy9CgUC
# AQAwBwIBAAICC1wwBwIBAAICEgQwCgIFAOy+W4UCAQAwNgYKKwYBBAGEWQoEAjEo
# MCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG
# 9w0BAQsFAAOCAQEAV9EQ1t2r4CTlUp0MZ51gKW+QN7SZdmthYlpEkJX+aMVzmwG/
# vT+tO6pdyit2KYagfn7KZsbgsYOqAyRfnWFvTN5MXfDg1gyOGMytb92YzTdI4oGZ
# KFwSEpAn5IsmCSJlkhbq033oRPbSLpPc8ipBenyr/1yUxJFCMSv0kEqbPDBxgeTJ
# UI/LSqs3HRYSM24SWiIT7YStqkUMIQojc1uI2jIT+xbDncKUXkIcAG281dLy/5Qr
# sVBLMTgBoycuwnzpnlavmtnnvgIjI67D79J9UoCj9TE30b90fDArfEtjpC+8yoGR
# CPxvuN9qm4ISBCXbhxYWUvWrWgaX9qQT4EJZqDGCBA0wggQJAgEBMIGTMHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAACBte8UTiYI+wsAAEAAAIGMA0G
# CWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
# KoZIhvcNAQkEMSIEIBEbLf2GKV4r0sRG8Yp17EcuSEL+q1D86fRQ8IxJY0IfMIH6
# BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQg4Oj1lIiRnp1W0pP4T+5nHZYDLsqJ
# czlHUkg6E0l/S9IwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MAITMwAAAgbXvFE4mCPsLAABAAACBjAiBCANvLEB4Bdq8/UyttwDb9YIrmw8FSrP
# 7TNAaFtALGmXHTANBgkqhkiG9w0BAQsFAASCAgDbmM9IY8CFQIZqUWY8J8W6wFe3
# pCQeLdHbToqUPPLtX5v637WZLCyB7F2gXZHnedtCubD1s7DxY9MwppMB27nHDX3I
# +a3rTfTLghY8dugo/W/sq2BoLt2nnNfOKUud3D/tHO9JCPFmI5XVy7FbAFDNd3/k
# E8gglPG4fOVl8Dichp0U7XEB7qoYJ4w5/wvjQw1+tGmAOioSGHR6c1LIdjb7S1TB
# yMKDBEBqk9JH4fIJO3+ttjYujf5m1rCcidsMRz+hf4P6JZONKdR4ueAL0qQtBCIe
# Vxj0JXVgaD9nNxQPC79SZ1vvQtov9vUh0TCP1ZqhBn0qtN/wXCxS2CRUMobAgUE9
# LOi1kMAIj4rFTWkibY0seq5mhlXG8r6p5UiLQc3JzMihzMtBZQo0OCcyb7+1qJmj
# YaRSIAoCMbpd+RHdXWFPGmhX90Z63CEYidxfGz7x8b1149v6gyIsr+n4emG3f2Fx
# GPQO4dO1IUFdx/sF4ngOHCEougN3GJUQ79HryNQzJRZ9CvDHvYM+TxgtrAzlmL/r
# zbJ3q2N/weoP0h3Y0FqJreoYwXT8ZGByAYxUmvpmFeeQ/E8bTBCAxxClGFk8u8F0
# lzGlOz3+37vkJP/ENPoUaxu7XxxXPOFiUcgwTSPWQfmMH0yEt4BiUdrkt0WBXwVc
# L1+473TdYiNeOisyyQ==
# SIG # End signature block

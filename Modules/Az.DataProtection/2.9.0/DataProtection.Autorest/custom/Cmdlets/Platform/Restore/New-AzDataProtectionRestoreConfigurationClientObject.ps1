
function New-AzDataProtectionRestoreConfigurationClientObject{
	[OutputType('PSObject')]
    [CmdletBinding(PositionalBinding=$false)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Creates new restore configuration object')]

    param(
        [Parameter(Mandatory, HelpMessage='Datasource Type')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.DatasourceTypes]
        [ValidateSet('AzureKubernetesService')]
        ${DatasourceType},
        
        [Parameter(Mandatory=$false, HelpMessage='List of resource types to be excluded for restore')]
        [System.String[]]
        ${ExcludedResourceType},

        [Parameter(Mandatory=$false, HelpMessage='List of resource types to be included for restore')]
        [System.String[]]
        ${IncludedResourceType},

        [Parameter(Mandatory=$false, HelpMessage='List of namespaces to be excluded for restore')]
        [System.String[]]
        ${ExcludedNamespace},

        [Parameter(Mandatory=$false, HelpMessage='List of namespaces to be included for restore')]
        [System.String[]]
        ${IncludedNamespace},

        [Parameter(Mandatory=$false, HelpMessage='List of labels for internal filtering for restore')]
        [System.String[]]
        ${LabelSelector},

        [Parameter(Mandatory=$false, HelpMessage='Boolean parameter to decide whether cluster scope resources are included for restore. By default this is taken as true.')]
        [Nullable[System.Boolean]]
        ${IncludeClusterScopeResource},

        [Parameter(Mandatory=$false, HelpMessage='Conflict policy for restore. Allowed values are Skip, Patch. Default value is Skip')]        
        [System.String]
        [ValidateSet('Skip','Patch')]
        ${ConflictPolicy},

        [Parameter(Mandatory=$false, HelpMessage='Namespaces mapping from source namespaces to target namespaces to resolve namespace naming conflicts in the target cluster.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.KubernetesClusterRestoreCriteriaNamespaceMappings]
        ${NamespaceMapping},

        [Parameter(Mandatory=$false, HelpMessage='Restore mode for persistent volumes. Allowed values are RestoreWithVolumeData, RestoreWithoutVolumeData. Default value is RestoreWithVolumeData')]
        [System.String]
        [ValidateSet('RestoreWithVolumeData','RestoreWithoutVolumeData')]
        ${PersistentVolumeRestoreMode},
        
        [Parameter(Mandatory=$false, HelpMessage='Hook reference to be executed during restore.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.NamespacedNameResource[]]
        ${RestoreHookReference},

        [Parameter(Mandatory=$false, HelpMessage='Resource modifier reference to be executed during restore.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.NamespacedNameResource]
        ${ResourceModifierReference},

        [Parameter(Mandatory=$false, HelpMessage='Staging resource group Id for restore.')]
        [System.String]
        [ValidatePattern("/subscriptions/([A-z0-9\-]+)/resourceGroups/(?<rg>.+)")]
        ${StagingResourceGroupId},

        [Parameter(Mandatory=$false, HelpMessage='Staging storage account Id for restore.')]
        [System.String]
        [ValidatePattern("/subscriptions/([A-z0-9\-]+)/resourceGroups/([A-z0-9\-]+)/providers/Microsoft.Storage/storageAccounts/([A-z0-9\-]+)")]
        ${StagingStorageAccountId}
    )

    process {

        $hasStagingResourceGroupId = $PSBoundParameters.Remove("StagingResourceGroupId")
        $hasStagingStorageAccountId = $PSBoundParameters.Remove("StagingStorageAccountId")

        $restoreCriteria = $null
        if($hasStagingResourceGroupId -and $hasStagingStorageAccountId){
            $restoreCriteria =  [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.KubernetesClusterVaultTierRestoreCriteria]::new()
            $restoreCriteria.ObjectType = "KubernetesClusterVaultTierRestoreCriteria"

            $restoreCriteria.StagingResourceGroupId = $StagingResourceGroupId
            $restoreCriteria.StagingStorageAccountId = $StagingStorageAccountId        
        }
        elseif($hasStagingResourceGroupId -or $hasStagingStorageAccountId) {
            throw "Both StagingResourceGroupId and StagingStorageAccountId are mandatory for vaulted tier restore for AzureKubernetesService. Please either provide or remove both of them."
        }
        else {
            $restoreCriteria =  [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.KubernetesClusterRestoreCriteria]::new()
            $restoreCriteria.ObjectType = "KubernetesClusterRestoreCriteria"
        }        

        $restoreCriteria.ExcludedResourceType = $ExcludedResourceType
        $restoreCriteria.IncludedResourceType = $IncludedResourceType
        $restoreCriteria.ExcludedNamespace = $ExcludedNamespace
        $restoreCriteria.IncludedNamespace = $IncludedNamespace
        $restoreCriteria.LabelSelector = $LabelSelector
        $restoreCriteria.NamespaceMapping = $NamespaceMapping
        $restoreCriteria.RestoreHookReference = $RestoreHookReference
        $restoreCriteria.ResourceModifierReference = $ResourceModifierReference        

        
                
        if($IncludeClusterScopeResource -ne $null) {
            $restoreCriteria.IncludeClusterScopeResource =  $IncludeClusterScopeResource
        }
        else {
            $restoreCriteria.IncludeClusterScopeResource = $true
        } 

        if($ConflictPolicy -ne "") {
            $restoreCriteria.ConflictPolicy =  $ConflictPolicy
        }
        else {
            $restoreCriteria.ConflictPolicy = "Skip" 
        }

        if($PersistentVolumeRestoreMode -ne "") {
            $restoreCriteria.PersistentVolumeRestoreMode =  $PersistentVolumeRestoreMode
        }
        else {
            $restoreCriteria.PersistentVolumeRestoreMode = "RestoreWithVolumeData" 
        }

        $restoreCriteria
    }
}
# SIG # Begin signature block
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBiT0H2LW46cTfM
# P+kxOEMLoI+2SjZJQCnoqF82DrV9KqCCDYUwggYDMIID66ADAgECAhMzAAAEhJji
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGiMwghofAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAASEmOIS4HijMV0AAAAA
# BIQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIKua
# KvLT+HcGsNGNDWEkLdzTU1YYcvW6wQM1jLFbSq94MEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAKHm+mKy7RDQidvA1kD7o7btKSHOkbogh5C0N
# 7ib0QSrGYze276CcBAFnbhCtu5pVgW59p114q3gQpcOYhMAYHrfh3GAvgtXa0VRl
# 2FJ4vT5RFYUs+pcn6cQSuEE92mwp4uU+wG2+Wkxs40clqkaT2pgK2Sbf0MGAPBlV
# WzjGf0TlPVbkaMG0pe76PxcBruzEVCqTlrWMUUsY4rUBGAh70sWW5HMtPNHZBED4
# glvJyAQsL0P65lSxaW2h+Tnp+Wr+qOtAN/50YBAq3eN5KFsSfz3R06Z/QmahPZqM
# E5UBxWVwiaol5OR2VnUxhPPY0WCVw2nbu+WRCgBhyvXeQvzrhaGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCA6+UnfBqfoVt7b06o/p9vTBd17IoSghYyP
# PZxI3KO/AAIGaXP1uBR+GBMyMDI2MDEyNzA3NDAwMC41NTdaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo0MzFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAACHUvA
# koc4hX45AAEAAAIdMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI1MDgxNDE4NDgzM1oXDTI2MTExMzE4NDgzM1owgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjQzMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# orSgaAA8oOl4ph574zw29egUN8DDepRHLX8FM1zHNJmXG6KrSqUKwzcKafopuYdP
# TETTCvb9aJfESuAU0iGNUFI/D6R0kvdfpe2oPX+E3sbTQvGi4JPH5qdIYUaJ45V/
# 4bqe8eNvbWzpC+ZKjH193DeiI1XAI918JoQmBhlEXo/Ton1721luZJgincsf5LjM
# Y3jX84WyXUSX3dsS7h/7xVI+w1yjg7pa+0y3o/me2Tsv6UJUdSTQap5ORGSfCncl
# nP1z3IiiWIWr3Vo7aIPWsgJzq3m5GxpxUHCQk8qzUhk50y/uB+LGE3WIK2C77iy9
# iFsSfSLUnyMEzGRDW9mXHT4PH7Ozz6CHqQEiNvwcHqlvlCh1pHQh1NXQSAqOoVBs
# 5mi6easf6yxWTfe5DrR79503r8pU6VqC2Y9XMRU4wH9QbYXYsIUZ33Jmndy22W1L
# BDAbxBPQHCBlncGDU3BgdhVUVLe80mggFO98FdkWho67w4kPdCTRkvdvkY8PrQYE
# /nQjHXCa0g7LcMttZb6ejMHfQ+tUWXv6+nZ4Ynkr2OkaxclFCw4RIYNMWD26AWbQ
# j/WEdzga18fKtw66L5gzXPza6jFBfPJeKE3H8QAuwpirmH4ms+5nUjNNQOmNgqJn
# 0U1+3Yn7ClswD79YN0r3fdbYBMDApBZJpNlK7q7HXRsCAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBSEWfBxNEamZtXm8gl92Yq80jfxXTAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAkdweB4yxvLspLKq0D+miyD4Q0EcxVFpNZuJxiR54gWRkeTDDuymNeB03
# JhlsBpbwSYJ5uZSgDBCvwHED2VL8lJpFlOprJzxsXWC2NTfA+O+PO5Fk5jw6LHh6
# jeBADDEdQAx3Hqi7Zm0JwvQ93z5f6dtxkm29WqOcHYXRXfAQwy1hSrLXyfeblqR6
# 6jpP/9n0fCkWU4ggsUjQpQ2Ngj1DV09J4Y3y7p9Nd81+Xs6qYo++7RKm8qiB/5ND
# eigOLjlAeFgiEXIRUJW+mJyqpQw+OORlaqcFjR8Hu0G+/7bMdek68YX+kPpDBk7U
# e+I/xgiYJ1xcDRBn/vczLtN72+RIlD4UgXYLuBSCk//pDEPX5z39Cr+rkc6E4Y28
# FPk4BhloAyvp628P4xfElQY8TcxraUbZShypocE6ny95D1K1BkltZmrHVKCxmgln
# uOlM15NKIrXFlXCzdqpCtIwQ417wNAVF/QDPvzzbumPdTi6fb0tLbScYobV6zvbB
# sMsKEME4Tj1b9oIXC8dybJq4nbboEXYpRwi1QAbpSNrn+PxGW9uf1q63FnMJu4gm
# 3Oh63njW/iVf723quzyHrSijWMgY0HiRiHQi0Jyu0h8MdhRUp7mxbmLQckPiOFwA
# lIaUN/k725y/aLWpkRU6fqmLlEOyH5WpyLd23AYy9r8v+Qoba6swggdxMIIFWaAD
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
# 2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIDVjCCAj4CAQEwggEBoYHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo0MzFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAuoO+BKbfXzqy
# fi9GLEdWHkCLeT+ggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAO0iaJEwIhgPMjAyNjAxMjYyMjI2MjVaGA8yMDI2
# MDEyNzIyMjYyNVowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA7SJokQIBADAHAgEA
# AgIhFjAHAgEAAgISYDAKAgUA7SO6EQIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUA
# A4IBAQA8T6F+y1WLEOax9vWQiAJCh3YxjIT337z72jEk47/gvs5C1kQ8srFZpfvL
# 053aO8KP/jRVrt5MWR92kws4G7XbLbqRV4d3TyfuZ2CBrSuE0TqvGymW6wD4lCQv
# GtPFcZ+hkxPsj2SJa1URMSfaPw4NcDaRopU3++ts4WZrwvcwwoa6UhrIu/w83BFM
# VJlanQ5SsLYFqcbIDwB8tq3zlaANYdjkj3rHOOYmlSQ5aK1Ga+ytLjHN35F+xgU9
# Uuw/bxb2ituA7+65njsab/UUaZeUbzFT8tGFNLx/ozA3E3pNnQBDPE3QvA9GfCa3
# a4O7XprZPCr6ESDp45nlIO2yV9BbMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAIdS8CShziFfjkAAQAAAh0wDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgSUPMHXleYlI95Fdes6031z1PHHEiO4/Kh3dIx4GoGN4wgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCCxtpXMXEiLJzrqM77ep4rTNwrMOj6gpWN9hZvp
# j5QFUTCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAC
# HUvAkoc4hX45AAEAAAIdMCIEIDEgcItQgyLsTlsCOfIimlSq0dj1/ZhdfaWHiE8K
# n/DEMA0GCSqGSIb3DQEBCwUABIICAFpJZ+QlF8dt6mQlmL9kmDC1+ZCiOCcpaUms
# Cg/8VPf69yHXBu59lRkxSnaDtXc4E6GRy1i3iloaz3EHr8xbPe5GCEqgfMPher2S
# LdmCwE4dTBBCcEdePhcn6fgJEoyvYtbgPu1s04lTtIBjF1PV7etE9GxpC+R8nD69
# fVOdF+LWAOrKNQKc9OUAEOZZJEB3G4it/TnZCNdJiI4adqIulqqpnVtQ4psdr8UG
# jQmmgOM4ww3qipWC0X1pVVurUvOI/aioLSSq+fiOAPzMrECdqDVG2T+g3/DSC74a
# tAp8Dq4Cku0atV+3IWbwbcF2ivn+KrTJ2RZmiIFEHVoTLkAR7YIGaSBUHBqSDeo9
# KlWplog4KXUWF9IclUbott5eUILzDnYXh7zt+UH5fxg+udYTMGtD+Hn2XksTb+hH
# TO7F2tWTAjJmksLWKwu1oV8ifYcj9wLFmW0YuGyr37Wc83CIMKTZA7rLBC39vXHT
# 04YgK3ivHXglSlA0cxbpScUK1Pkb2gj+cI5PzrVWbzxQ0RHJsAebC7CMRlM+qQK0
# vTDrmutKxr9E1rznaoAgKgry96n/4iI9l//Hn2RjPStixQ33XQTsfwviLqRKNeA0
# 5Aumbv3cIgbIA3OuiaoMH+mm3BcgBw9758jTODXlk4HKXli7fC7r0KmkF4AG57Dn
# tt88QtSr
# SIG # End signature block


function New-AzDataProtectionBackupConfigurationClientObject{
	[OutputType('PSObject')]
    [CmdletBinding(PositionalBinding=$false)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Creates new backup configuration object')]

    param(
        [Parameter(Mandatory, HelpMessage='Datasource Type')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.DatasourceTypes]
        [ValidateSet('AzureKubernetesService', 'AzureBlob', 'AzureDataLakeStorage')]
        ${DatasourceType},
        
        [Parameter(Mandatory=$false, HelpMessage='List of resource types to be excluded from backup')]
        [System.String[]]
        ${ExcludedResourceType},

        [Parameter(Mandatory=$false, HelpMessage='List of resource types to be included for backup')]
        [System.String[]]
        ${IncludedResourceType},

        [Parameter(Mandatory=$false, HelpMessage='List of namespaces to be excluded from backup')]
        [System.String[]]
        ${ExcludedNamespace},

        [Parameter(Mandatory=$false, HelpMessage='List of namespaces to be included for backup')]
        [System.String[]]
        ${IncludedNamespace},

        [Parameter(Mandatory=$false, HelpMessage='List of labels for internal filtering for backup')]
        [System.String[]]
        ${LabelSelector},

        [Parameter(Mandatory=$false, HelpMessage='Boolean parameter to decide whether snapshot volumes are included for backup. By default this is taken as true.')]        
        [Nullable[System.Boolean]]
        ${SnapshotVolume},

        [Parameter(Mandatory=$false, HelpMessage='Boolean parameter to decide whether cluster scope resources are included for backup. By default this is taken as true.')]        
        [Nullable[System.Boolean]]
        ${IncludeClusterScopeResource},

        [Parameter(Mandatory=$false, HelpMessage='Hook reference to be executed during backup.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.NamespacedNameResource[]]
        ${BackupHookReference},
        
        [Parameter(Mandatory=$false, HelpMessage='List of containers to be backed up inside the VaultStore. Use this parameter for DatasourceType AzureBlob.')]
        [System.String[]]
        ${VaultedBackupContainer},
        
        [Parameter(Mandatory=$false, HelpMessage='Switch parameter to include all containers to be backed up inside the VaultStore. Use this parameter for DatasourceType AzureBlob.')]
        [Switch]
        ${IncludeAllContainer},
        
        [Parameter(Mandatory=$false, HelpMessage='Storage account where the Datasource is present. Use this parameter for DatasourceType AzureBlob.')]
        [System.String]
        ${StorageAccountName},
        
        [Parameter(Mandatory=$false, HelpMessage='Storage account resource group name where the Datasource is present. Use this parameter for DatasourceType AzureBlob.')]
        [System.String]
        ${StorageAccountResourceGroupName}
    )

    process {        
        # need to have parameter validation when this command supports another DatasourceType           
        $dataSourceParam = $null

        if($DatasourceType.ToString() -eq "AzureKubernetesService"){

            # parameter validation
            if($VaultedBackupContainer -ne $null -or $IncludeAllContainer){
                $message = "Invalid parameter VaultedBackupContainer or IncludeAllContainer for given DatasourceType."
                throw $message
            }

            $dataSourceParam = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.KubernetesClusterBackupDatasourceParameters]::new()
            $dataSourceParam.ObjectType = "KubernetesClusterBackupDatasourceParameters"
        
            $dataSourceParam.ExcludedResourceType = $ExcludedResourceType
            $dataSourceParam.IncludedResourceType = $IncludedResourceType
            $dataSourceParam.ExcludedNamespace = $ExcludedNamespace
            $dataSourceParam.IncludedNamespace = $IncludedNamespace
            $dataSourceParam.LabelSelector = $LabelSelector
            $dataSourceParam.BackupHookReference = $BackupHookReference

            if ($SnapshotVolume -ne $null) {
                $dataSourceParam.SnapshotVolume = $SnapshotVolume
            }
            else{
                $dataSourceParam.SnapshotVolume = $true
            }

            if($IncludeClusterScopeResource -ne $null){
                $dataSourceParam.IncludeClusterScopeResource = $IncludeClusterScopeResource
            }
            else{
                $dataSourceParam.IncludeClusterScopeResource = $true        
            }
        }

        if($DatasourceType.ToString() -eq "AzureBlob" -or $DatasourceType.ToString() -eq "AzureDataLakeStorage"){
            $dataSourceParam = $null
            if($DatasourceType.ToString() -eq "AzureBlob"){ 
                $dataSourceParam = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.BlobBackupDatasourceParameters]::new()
                $dataSourceParam.ObjectType = "BlobBackupDatasourceParameters"
            } 
            elseif($DatasourceType.ToString() -eq "AzureDataLakeStorage"){
                $dataSourceParam = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.AdlsBlobBackupDatasourceParameters]::new()
                $dataSourceParam.ObjectType = "AdlsBlobBackupDatasourceParameters"
            }
            
            if($VaultedBackupContainer -ne $null){
                # exclude containers which start with $ except $web, $root
                $unsupportedContainers = $VaultedBackupContainer | Where-Object { $_ -like '$*' -and $_ -ne "`$root" -and $_ -ne "`$web"}
                if($unsupportedContainers.Count -gt 0){
                    $message = "Following containers are not allowed for configure protection with $($DatasourceType.ToString()) - $unsupportedContainers. Please remove them and proceed."
                    throw $message
                }

                $dataSourceParam.ContainersList = $VaultedBackupContainer
            }
            elseif($IncludeAllContainer){
                if($StorageAccountName -eq $null -or $StorageAccountResourceGroupName -eq $null){
                    $message = "Please input StorageAccountName and StorageAccountResourceGroupName parameters for fetching all vaulted containers."
                    throw $message
                }

                CheckStorageModuleDependency
                $storageAccount = Get-AzStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -Name $StorageAccountName 
                $containers = Get-AzStorageContainer -Context $storageAccount.Context

                # exclude containers which start with $ except $web, $root
                $allContainers = $containers.Name | Where-Object { -not($_ -like '$*' -and $_ -ne "`$root" -and $_ -ne "`$web")}
                $dataSourceParam.ContainersList = $allContainers
            }
            elseif($ExcludedResourceType -ne $null -or $IncludedResourceType -ne $null -or $ExcludedNamespace -ne $null -or $IncludedNamespace -ne $null -or $LabelSelector -ne $null -or $SnapshotVolume -ne $null -or $IncludeClusterScopeResource -ne $null){
                $message = "Invalid parameters ExcludedResourceType, IncludedResourceType, ExcludedNamespace, IncludedNamespace, LabelSelector, SnapshotVolume, IncludeClusterScopeResource for given DatasourceType."
                throw $message
            }
            else {
                 $message = "Please input VaultedBackupContainer or IncludeAllContainer parameters for given workload type."
                 throw $message
            }
        }

        $dataSourceParam
    }
}
# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBT0ugcbyexAjlt
# 89PCyjXuUYpvrjwHSCJYbMNmW3+x86CCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIME25I5rORXLahh6OLGXk2np
# MQ9Opj3y2DBUVzzicwLPMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAWZaYPsHhuutBWB1UqLvPXboYlw0l3TEnDQr9wOi42PnelpBO+mBL8S9V
# AGwpvpaPQHzLlBfv0eVLz35dAVkHX1ZPq4+qHG+XwntvhT7Hq56BWgwXBxiHj7+d
# z76L0bLnxXF0h4cciAeR2tHo1cwN4FmVbWYTfsVgybNoYr1I09+5nLwsZkEbAFVg
# RoyXfbU/9N6K/FYXyuxZGsQLuBugVW5m+0AAREJscudfYZdZ7+t3HyHNxqqjGbdu
# Oc6e6AqU8l2MuAAFIhIIbdgpBKC37k+l2rvv4HNn9+kHSgpH+QyxD6T6DA6ERxjh
# rzBmBv9n4J9MlFfsf/cclFy/vAKsqqGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBKAzGpxPTEePwAjcHT9CABjmN2knGQkJZLFw+m7/AZWQIGaWjhyC54
# GBMyMDI2MDEyNzA3NDAwMC4wMDJaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgcsETmJzYX7xQABAAACBzANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTJaFw0yNjA0MjIxOTQyNTJaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDFP/96dPmcfgODe3/nuFveuBst/JmSxSkOn89ZFytH
# Qm344iLoPqkVws+CiUejQabKf+/c7KU1nqwAmmtiPnG8zm4Sl9+RJZaQ4Dx3qtA9
# mdQdS7Chf6YUbP4Z++8laNbTQigJoXCmzlV34vmC4zpFrET4KAATjXSPK0sQuFhK
# r7ltNaMFGclXSnIhcnScj9QUDVLQpAsJtsKHyHN7cN74aEXLpFGc1I+WYFRxaTgq
# SPqGRfEfuQ2yGrAbWjJYOXueeTA1MVKhW8zzSEpfjKeK/t2XuKykpCUaKn5s8sqN
# bI3bHt/rE/pNzwWnAKz+POBRbJxIkmL+n/EMVir5u8uyWPl1t88MK551AGVh+2H4
# ziR14YDxzyCG924gaonKjicYnWUBOtXrnPK6AS/LN6Y+8Kxh26a6vKbFbzaqWXAj
# zEiQ8EY9K9pYI/KCygixjDwHfUgVSWCyT8Kw7mGByUZmRPPxXONluMe/P8CtBJMp
# uh8CBWyjvFfFmOSNRK8ETkUmlTUAR1CIOaeBqLGwscShFfyvDQrbChmhXib4nRMX
# 5U9Yr9d7VcYHn6eZJsgyzh5QKlIbCQC/YvhFK42ceCBDMbc+Ot5R6T/Mwce5jVyV
# CmqXVxWOaQc4rA2nV7onMOZC6UvCG8LGFSZBnj1loDDLWo/I+RuRok2j/Q4zcMnw
# kQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHK1UmLCvXrQCvR98JBq18/4zo0eMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQDju0quPbnix0slEjD7j2224pYOPGTmdDvO
# 0+bNRCNkZqUv07P04nf1If3Y/iJEmUaU7w12Fm582ImpD/Kw2ClXrNKLPTBO6nfx
# vOPGtalpAl4wqoGgZxvpxb2yEunG4yZQ6EQOpg1dE9uOXoze3gD4Hjtcc75kca8y
# ivowEI+rhXuVUWB7vog4TGUxKdnDvpk5GSGXnOhPDhdId+g6hRyXdZiwgEa+q9M9
# Xctz4TGhDgOKFsYxFhXNJZo9KRuGq6evhtyNduYrkzjDtWS6gW8akR59UhuLGsVq
# +4AgqEY8WlXjQGM2OTkyBnlQLpB8qD7x9jRpY2Cq0OWWlK0wfH/1zefrWN5+be87
# Sw2TPcIudIJn39bbDG7awKMVYDHfsPJ8ZvxgWkZuf6ZZAkph0eYGh3IV845taLkd
# LOCvw49Wxqha5Dmi2Ojh8Gja5v9kyY3KTFyX3T4C2scxfgp/6xRd+DGOhNVPvVPa
# /3yRUqY5s5UYpy8DnbppV7nQO2se3HvCSbrb+yPyeob1kUfMYa9fE2bEsoMbOaHR
# gGji8ZPt/Jd2bPfdQoBHcUOqPwjHBUIcSc7xdJZYjRb4m81qxjma3DLjuOFljMZT
# YovRiGvEML9xZj2pHRUyv+s5v7VGwcM6rjNYM4qzZQM6A2RGYJGU780GQG0QO98w
# +sucuTVrfTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg2MDMtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDT
# vVU/Yj9lUSyeDCaiJ2Da5hUiS6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7SKHajAiGA8yMDI2MDEyNzAwMzgw
# MloYDzIwMjYwMTI4MDAzODAyWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDtIodq
# AgEAMAoCAQACAiIjAgH/MAcCAQACAhHLMAoCBQDtI9jqAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBACXYPO0+36jeSCagAbjlul5OqfKXLBLE5Zj+SZqpAhyo
# rWECp7oiM4PURPNg6z4ACUYK0150yp8BeYVu8uGR8EA3S0o9ipo8V88lmC10cfMx
# eUoBa1Mt7tNFEXO9275MJSaGf6VsUF8k6Mgrs99bSfbGp3C1qZLsqi6VirHp62TE
# NreCCV5XEKLAkB+qgNIbla4zZE+y6eowvBeMmh99F7dY9V14a8eekZmegAqEun6m
# rfYQ38aukezdsrTsEvKd6MsdqyBEj3HyuM8Z3fUAj404MqXk55WGkcrZFwUaBDYC
# iXkNKzALfHDtzqfuGya650lx/v1Y92QUyJy1iLhNsJ4xggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgcsETmJzYX7xQABAAAC
# BzANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCC8yxmMxQW/vhKkhnuCHutZc+DwV16JXih7qZkcHU5D
# sjCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIC/31NHQds1IZ5sPnv59p+v6
# BjBDgoDPIwiAmn0PHqezMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIHLBE5ic2F+8UAAQAAAgcwIgQgqTy9Yqm/Su3JRF3JH2YWIu+T
# iDMXmXuDHPh/CNE4m84wDQYJKoZIhvcNAQELBQAEggIAU8M2wBFopNXu7C0lGIBJ
# KPqmK5engoj1C6v4H5Ygsjn8didWKB8qIpRM5ObjNH6ede01jdrunEThgOUXlZfE
# Ad0B93L/dTeN23nQsA5wc2JPWmlmKYiJxWQkrxdLueGY+/PnxmERdS3qusbKhV8K
# pLHMC84vE6cDVkGWPKs1+3L5Qxx3JzCVOV3H4rSURa/5qLvd10Uq6jwyA4g4aB9a
# ekmXH9O/TLtEExKFEp6m+m6/08JBDokjXDZVDUF72MQnwNi+/iTaZssY8c2fyVuh
# Ltod0aFzQHRxCEPXmhyIfEQs7LTL8pt9m6PC5Vwm84QSVf0rDbNU4t+4tky/wEwA
# yDjofwP6IE1CqUVa70RI4RlkczCqJFD35wg6vZB+OvsijeLtvM6mjFOCIKEQAfCq
# +acasQf+IMMzjsbCQNn2OlBjOMzELpfmhjw6S2UgfRd7RAFtilp5qkdWFauXby68
# ukpRm2jlz7e6cjENW5T45tDYKewGrIh8NTEJhAnZPOF+8vBRMm7NspaG1rEHE3M9
# GJk738K3kxzo9EV9Mjx7iEaki31Tc6mVVwA9+sycOCu3mz5vLIq1dReljx3g0v0Y
# TZyfEFCgkuqZW0IkD7JDJc87G9HerUtKj0dWD3VLQ+KAayZUVHzBcg5c0MZvJdzD
# lcZ+u952KtBuMl1TWzw9MOM=
# SIG # End signature block

function New-AzDataProtectionBackupVault
{
	[OutputType('PSObject')]
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Creates or updates a BackupVault resource belonging to a resource group.')]

    param(
        [Parameter(Mandatory=$false, HelpMessage='Subscription Id of the vault')]
        [System.String]
        ${SubscriptionId},

        [Parameter(Mandatory, HelpMessage='Resource Group Name of the backup vault')]
        [System.String]
        ${ResourceGroupName},

        [Parameter(Mandatory, HelpMessage='Name of the backup vault')]
        [System.String]
        ${VaultName},

        [Parameter(HelpMessage='Optional ETag.')]
        [System.String]
        ${ETag},

        [Parameter(HelpMessage='The identityType can take values - "SystemAssigned", "UserAssigned", "SystemAssigned,UserAssigned", "None".')]
        [System.String]
        ${IdentityType},

        [Parameter(Mandatory, HelpMessage='Resource location.')]
        [System.String]
        ${Location},

        [Parameter(Mandatory, HelpMessage='Storage Settings of the vault. Use New-AzDataProtectionBackupVaultStorageSetting Cmdlet to Create.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.IStorageSetting[]]
        ${StorageSetting},

        [Parameter(Mandatory=$false, HelpMessage='Parameter to Enable or Disable built-in azure monitor alerts for job failures. Security alerts cannot be disabled.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.AlertsState]
        [ValidateSet('Enabled','Disabled')]
        ${AzureMonitorAlertsForAllJobFailure},

        [Parameter(Mandatory=$false, HelpMessage='Immutability state of the vault. Allowed values are Disabled, Unlocked, Locked.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.ImmutabilityState]
        [ValidateSet('Disabled','Unlocked', 'Locked')]
        ${ImmutabilityState},

        [Parameter(Mandatory=$false, HelpMessage='Cross region restore state of the vault. Allowed values are Disabled, Enabled.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.CrossRegionRestoreState]
        [ValidateSet('Disabled','Enabled')]
        ${CrossRegionRestoreState},
        
        [Parameter(Mandatory=$false, HelpMessage='Cross subscription restore state of the vault. Allowed values are Disabled, Enabled, PermanentlyDisabled.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.CrossSubscriptionRestoreState]
        [ValidateSet('Disabled','Enabled', 'PermanentlyDisabled')]
        ${CrossSubscriptionRestoreState},
        
        [Parameter(Mandatory=$false, HelpMessage='Soft delete retention duration in days')]
        [System.Double]
        ${SoftDeleteRetentionDurationInDay},

        [Parameter(Mandatory=$false, HelpMessage='Soft delete state of the vault. Allowed values are Off, On, AlwaysOn')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.SoftDeleteState]
        [ValidateSet('Off','On', 'AlwaysOn')]  
        ${SoftDeleteState},

        [Parameter(HelpMessage='Resource tags.')]
        [System.Collections.Hashtable]
        ${Tag},

        [Parameter(Mandatory=$false, HelpMessage='Gets or sets the user assigned identities.')]
        [Alias('UserAssignedIdentity', 'AssignUserIdentity')]
        [System.Collections.Hashtable]
        ${IdentityUserAssignedIdentity},

        [Parameter(Mandatory=$false, HelpMessage='Enable CMK encryption state for a Backup Vault.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.EncryptionState]
        ${CmkEncryptionState},

        [Parameter(Mandatory=$false, HelpMessage='Enable infrastructure encryption with CMK on this vault. Infrastructure encryption must be configured only when creating the vault.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.InfrastructureEncryptionState]
        ${CmkInfrastructureEncryption},

        [Parameter(Mandatory=$false, HelpMessage='The identity type to be used for CMK encryption - SystemAssigned or UserAssigned Identity.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.IdentityType]
        ${CmkIdentityType},

        [Parameter(Mandatory=$false, HelpMessage='This parameter is required if the identity type is UserAssigned. Add the user assigned managed identity id to be used which has access permissions to the Key Vault.')]
        [System.String]
        ${CmkUserAssignedIdentityId},

        [Parameter(Mandatory=$false, HelpMessage='The Key URI of the CMK key to be used for encryption. To enable auto-rotation of keys, exclude the version component from the Key URI. ')]
        [System.String]
        ${CmkEncryptionKeyUri},
        
        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},
            
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},
    
        [Parameter(DontShow)]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},
    
        [Parameter(DontShow)]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},
    
        [Parameter(DontShow)]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process
    {
        if($PSBoundParameters.ContainsKey("IdentityType") -eq $false)
        {
            $null = $PSBoundParameters.Add("IdentityType", "SystemAssigned")
        }

        $hasCmkEncryptionState = $PSBoundParameters.Remove("CmkEncryptionState")
        $hasCmkIdentityType = $PSBoundParameters.Remove("CmkIdentityType")
        $hasCmkUserAssignedIdentityId = $PSBoundParameters.Remove("CmkUserAssignedIdentityId")
        $hasCmkEncryptionKeyUri = $PSBoundParameters.Remove("CmkEncryptionKeyUri")
        $hasCmkInfrastructureEncryption = $PSBoundParameters.Remove("CmkInfrastructureEncryption")

        if (-not $hasCmkEncryptionState -and -not $hasCmkIdentityType -and -not $hasCmkUserAssignedIdentityId -and -not $hasCmkEncryptionKeyUri) {
            Az.DataProtection.Internal\New-AzDataProtectionBackupVault @PSBoundParameters
            return
        }

        $encryptionSettings = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.EncryptionSettings]::new()
        $encryptionSettings.State = $CmkEncryptionState
        $encryptionSettings.CmkInfrastructureEncryption = $CmkInfrastructureEncryption
        $encryptionSettings.CmkIdentity = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.CmkKekIdentity]::new()
        $encryptionSettings.CmkIdentity.IdentityType = $CmkIdentityType
        $encryptionSettings.CmkIdentity.IdentityId = $CmkUserAssignedIdentityId
        $encryptionSettings.CmkKeyVaultProperty = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20250901.CmkKeyVaultProperties]::new()
        $encryptionSettings.CmkKeyVaultProperty.KeyUri = $CmkEncryptionKeyUri

        $PSBoundParameters.Add("EncryptionSetting", $encryptionSettings)

        Az.DataProtection.Internal\New-AzDataProtectionBackupVault @PSBoundParameters
    }
}
# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA10NR5/EvYFuQD
# NEGGCqPPkNkGO7888wlz9+Zif1huL6CCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIIxRcnVagptYe1HQPxhTwQho
# 0fvNMPUyLidcX7wKAp/8MEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAtPbGCeALhboJ4oC3ZJsXIGSCLkblVgzVJ6fQant76e0Ah5pkH+Fjl0rB
# wTZ9gyHT2DzEUlyFK0pXXX4+JYqTRybDs3ZHGe+zS0tZ7FUjGe5NaPB2Raz5No47
# 1uNh0HGs5HqV1c+sXNw5Pl/EvZYMGt1dt1S4P9ixjypKcOTocBh1il6E03f1Ngn3
# PGbZG9LTlXuGAR/vAxFbU7ch1yEq2NNAEDZY1hDiwS10VGF4juZo4uQpB2LGrAen
# lhE+wVQ5o7ndiv0Hy2GTAz8ovrlSAF2Awv4z5a9oT2YmXI9GWnCn2rfatij9h8Gj
# SVYJGRYpst5df4OadMz58E324KyMZqGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCAL1TecLh0+GIkBcLbUcNiTHRtG3aFOhKxI9bYCXaerQAIGaW+9JVjR
# GBMyMDI2MDEyNzA3NDAwMC40ODZaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RjAwMi0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgU8dWyCRIfN/gABAAACBTANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NDlaFw0yNjA0MjIxOTQyNDlaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RjAwMi0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCSkvLfd7gF1r2wGdy85CFYXHUC8ywEyD4LRLv0WYEX
# eeZ0u5YuK7p2cXVzQmZPOHTN8TWqG2SPlUb+7PldzFDDAlR3vU8piOjmhu9rHW43
# M2dbor9jl9gluhzwUd2SciVGa7f9t67tM3KFKRSMXFtHKF3KwBB7aVo+b1qy5p9D
# Wlo2N5FGrBqHMEVlNyzreHYoDLL+m8fSsqMu/iYUqxzK5F4S7IY5NemAB8B+A3Qg
# wVIi64KJIfeKZUeiWKCTf4odUgP3AQilxh48P6z7AT4IA0dMEtKhYLFs4W/KNDMs
# Yr7KpQPKVCcC5E8uDHdKewubyzenkTxy4ff1N3g8yho5Pi9BfjR0VytrkmpDfep8
# JPwcb4BNOIXOo1pfdHZ8EvnR7JFZFQiqpMZFlO5CAuTYH8ujc5PUHlaMAJ8NEa9T
# FJTOSBrB7PRgeh/6NJ2xu9yxPh/kVN9BGss93MC6UjpoxeM4x70bwbwiK8SNHIO8
# D8cql7VSevUYbjN4NogFFwhBClhodE/zeGPq6y6ixD4z65IHY3zwFQbBVX/w+L/V
# HNn/BMGs2PGHnlRjO/Kk8NIpN4shkFQqA1fM08frrDSNEY9VKDtpsUpAF51Y1oQ6
# tJhWM1d3neCXh6b/6N+XeHORCwnY83K+pFMMhg8isXQb6KRl65kg8XYBd4JwkbKo
# VQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHR6Wrs27b6+yJ3bEZ9o5NdL1bLwMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQAOuxk47b1i75V81Tx6xo10xNIr4zZxYVfk
# F5TFq2kndPHgzVyLnssw/HKkEZRCgZVpkKEJ6Y4jvG5tugMi+Wjt7hUMSipk+RpB
# 5gFQvh1xmAEL2flegzTWEsnj0wrESplI5Z3vgf2eGXAr/RcqGjSpouHbD2HY9Y3F
# 0Ol6FRDCV/HEGKRHzn2M5rQpFGSjacT4DkqVYmem/ArOfSvVojnKEIW914UxGtuh
# JSr9jOo5RqTX7GIqbtvN7zhWld+i3XxdhdNcflQz9YhoFqQexBenoIRgAPAtwH68
# xczr9LMC3l9ALEpnsvO0RiKPXF4l22/OfcFffaphnl/TDwkiJfxOyAMfUF3xI9+3
# izT1WX2CFs2RaOAq3dcohyJw+xRG0E8wkCHqkV57BbUBEzLX8L9lGJ1DoxYNpoDX
# 7iQzJ9Qdkypi5fv773E3Ch8A+toxeFp6FifQZyCc8IcIBlHyak6MbT6YTVQNgQ/h
# 8FF+S5OqP7CECFvIH2Kt2P0GlOu9C0BfashnTjodmtZFZsptUvirk/2HOLLjBiMj
# DwJsQAFAzJuz4ZtTyorrvER10Gl/mbmViHqhvNACfTzPiLfjDgyvp9s7/bHu/Cal
# KmeiJULGjh/lwAj5319pggsGJqbhJ4FbFc+oU5zffbm/rKjVZ8kxND3im10Qp41n
# 2t/qpyP6ETCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkYwMDItMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDV
# sH9p1tJn+krwCMvqOhVvXrbetKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7SLMSDAiGA8yMDI2MDEyNzA1MzE1
# MloYDzIwMjYwMTI4MDUzMTUyWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDtIsxI
# AgEAMAoCAQACAg4vAgH/MAcCAQACAhIuMAoCBQDtJB3IAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBACulT70TlCxCJrF8t6tSJH7Hqx4UJbknHS8v4b9gu8qy
# TzuCtViSYzYTtdIP2tFwYHH64A7sVcMKg1WZyuxe6OVXW4ZHmv20lzlWmZxEE3YB
# lj8/2kiLVEQwf06QKSPINgdurCUASzGUMtQjZ+u+XOqPx7i8gzuNZMowaKnFCFFW
# vaqlzams2dxx+g4+IiKbsig0LsMyp1x56UTkV88odAUXB8N9tRYHJkJAgMq6Bp9K
# kIQ+5ouQfe2Jd3a45ct6VMCZKvnzQ+KDW9yyHHDgiqUtF+51Fm9NSMy6niz8EyP5
# rKr8iq4B0Bo5YaeNNX91Z2YWyIra13YjZ3TzKz4fT2sxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgU8dWyCRIfN/gABAAAC
# BTANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCDrihSTBkmuRXiLiA8UCQyhPTX9vTplccBd+9HlktQO
# XjCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIIANAz3ceY0umhdWLR2sJpq0
# OPqtJDTAYRmjHVkwEW9IMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIFPHVsgkSHzf4AAQAAAgUwIgQg4P8N/effKfAdfL1PN7hW92yj
# xxwmLsykb3qEj1c8zU8wDQYJKoZIhvcNAQELBQAEggIAITj8tXr91w2ph+jOTcKy
# 5VHN8gXtH4hSOA+OdN+FoHF+DZdh/mjay8RYC3Cj6SN0b7bES2qr2MR1lNrrC9Rr
# PuxBhqaGkcl2nf0T++hTtlEXT6NfuqYRFB7WV0sOO099tRXhTTChetOG74u9R/X0
# +3DfF80wQvOVtYkZTJ4Kqb9EV8la9BADUz/5PCyMxtqJc2Xv1tddNVxidqM6bxh5
# /qNzzRm9bI2bcOLQ8LSXsoK953Almgb3SKRNYRpI5UvTpC7BYFJf/VbQqBEVzDQR
# Ss3CsjtG2oNgLg3Pa1JfjESA1twiHs1albFjDDaBH6DEKVdILl+AJ8aGng5WmODe
# LNYpUuocQ9kHnQjY6pYtxcWqtNO27xPJpOhRbAROOlmXVlg9cUgCb5ZSB9UCCVX4
# vgb9yhCvcAqfpAw7nNXW8JZOJhr+TWi6eapu6NHQBKsWp4NPrrgo3BbOAZ8+4d2J
# ZeGW5W6r7o/ZySf7gMvpqvxDTj/OddyeLv3hVPjaS1AN/XXqNKpOX0Jnfs0yw1DY
# BPFBnbMXbe28kaN4R0r1xNLNlW25avYfu1mpKKq+ddkTxJjLL2Q9HmjgA+9jozFA
# ITaW9hGKHeRJTOGD0wlRwuE9DYJWQZy57rhlVDngEjwip8lwdZ0+rAfywcr44FPb
# H+oUtrYjdfcs3HYIub95Qcg=
# SIG # End signature block

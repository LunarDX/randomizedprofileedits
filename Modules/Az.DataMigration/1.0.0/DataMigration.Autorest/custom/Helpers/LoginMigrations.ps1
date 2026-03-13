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


# Function Definitions

function Test-LoginMigrationsConfigFile{
    [Microsoft.Azure.PowerShell.Cmdlets.DataMigration.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory=$true)]
        [System.String]
        $path
    )

    process {
        if (!(Test-Path -Path $path))
        {
            throw "Invalid Config File path: $path"
        } 
    }
}

function  Get-DefaultLoginMigrationsOutputFolder {
    [Microsoft.Azure.PowerShell.Cmdlets.DataMigration.DoNotExportAttribute()]
    param(
    )

    process {
        $OSPlatform = Get-OSName

        if($OSPlatform.Contains("Linux"))
        {
            $DefualtPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\Microsoft\SqlLoginMigrations";

        }
        elseif ($OSPlatform.Contains("Darwin"))
        {
            $DefualtPath = Join-Path -Path $env:USERPROFILE -ChildPath "Library\Application Support\Microsoft\SqlLoginMigrations";
        }
        else
        {
            $DefualtPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\SqlLoginMigrations";
        }

        return $DefualtPath

    }
}

function Delete-OldLoginConsoleApp {
    [Microsoft.Azure.PowerShell.Cmdlets.DataMigration.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [System.String]
        $DownloadsFolder
    )

    process {
        #Remove old Login console app files
        #Old console app download address
        $ZipDestination = Join-Path -Path $DownloadsFolder -ChildPath "LoginsMigration.zip";

        # Remove old zip file
        if(Test-Path $ZipDestination)
        {
            Remove-Item -Path $ZipDestination;
        }

        # Remove existing folder and contents
        $ConsoleAppDestination = Join-Path -Path $DownloadsFolder -ChildPath "Logins.Console.csproj";
        if(Test-Path $ConsoleAppDestination)
        {
            Remove-Item -Path $ConsoleAppDestination -Recurse;
        }

        # Remove version file
        $VersionFileDestination = Join-Path -Path $DownloadsFolder -ChildPath "loginconsoleappversion.json";
        if(Test-Path $VersionFileDestination)
        {
            Remove-Item -Path $VersionFileDestination;
        }
    }
}


function Get-LatestConsoleAppVersionFromNugetOrg {
    [Microsoft.Azure.PowerShell.Cmdlets.DataMigration.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [System.String]
        $PackageId
    )

    process {
        $AvailablePackagesOnNugetOrg = ""

        try {
            $AvailablePackagesOnNugetOrg = Find-Package -Source "https://api.nuget.org/v3/index.json" -Name $PackageId -AllowPrereleaseVersions -AllVersions
            $AvailablePackagesOnNugetOrg = $AvailablePackagesOnNugetOrg | Sort-Object -Property Version -Descending
        } catch {
            Write-Host "Unable to connect to NuGet.org to check for updates."
        }

        $LatestNugetOrgName  = $AvailablePackagesOnNugetOrg[0].Name
        $LatestNugetOrgVersion = $AvailablePackagesOnNugetOrg[0].Version
        $LatestNugetOrgNameAndVersion = "$LatestNugetOrgName.$LatestNugetOrgVersion";

        return @{Name=$LatestNugetOrgName; Version=$LatestNugetOrgVersion; NameAndVersion=$LatestNugetOrgNameAndVersion}
    }
}

function CheckAndDownloadConsoleAppFromNugetOrg {
    [Microsoft.Azure.PowerShell.Cmdlets.DataMigration.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [AllowEmptyString()]
        [System.String]
        $LatestLocalNameAndVersion,

        [Parameter(Mandatory=$true, Position=1)]
        [HashTable]
        $LatestNugetOrgDetails,

        [Parameter(Mandatory=$true, Position=2)]
        [System.String]
        $ExePath,

        [Parameter(Mandatory=$true, Position=3)]
        [ref]
        [System.String]
        $LatestNugetFolder
    )

    process {
        #User consent for Login migration console app update. By default it is set to yes.
        $userUpdateConsent = "yes";

        # Prompt for user consent on Login migration console app update
        if($LatestLocalNameAndVersion -ne "" -and $LatestNugetOrgDetails.NameAndVersion -gt $LatestLocalNameAndVersion)
        {
            Write-Host "Newer Login migration console app nupkg version is available in Nuget.org...";
            while($true) {
                $userUpdateConsent = Read-Host -Prompt "Do you want to upgrade to the latest version? (yes/no)"

                if ($userUpdateConsent -eq "yes")
                {
                    Write-Host "You chose to upgrade. Proceeding..."
                    break;
                }
                elseif ($userUpdateConsent -eq "no")
                {
                    Write-Host "You chose not to upgrade."
                    $LatestNugetFolder.Value = Join-Path -Path $DownloadsFolder -ChildPath $LatestLocalNameAndVersion;
                    break;
                }
                else
                {
                    Write-Host "Invalid input. Please enter 'yes' or 'no'."
                }
            }
        }

        if ($LatestNugetOrgDetails.NameAndVersion -gt $LatestLocalNameAndVersion -and $userUpdateConsent -eq "yes")
        {
            #Update is available
            $DownloadUrl = "https://www.nuget.org/api/v2/package/$PackageId/$($LatestNugetOrgDetails.Version)"

            #Checking if LatestNugetFolder Path is valid or not
            if(-Not (Test-Path $LatestNugetFolder.Value))
            {
                $null = New-Item -Path $LatestNugetFolder.Value -ItemType "directory";
            }

            Write-Host "Downloading the latest Login migration console app nupkg: $($LatestNugetOrgDetails.NameAndVersion) ..."
            Invoke-WebRequest $DownloadUrl -OutFile "$($LatestNugetFolder.Value)\\$($LatestNugetOrgDetails.NameAndVersion).nupkg"

            $ToolsPathExists = Test-Path -Path (Join-Path -Path $LatestNugetFolder.Value -ChildPath "tools");

            if ($ToolsPathExists -eq $False)
            {
                $Nugets = Get-ChildItem -Path $LatestNugetFolder.Value -Filter "$PackageId.*.nupkg";

                if ($Nugets.Length -gt 0)
                {
                    Write-Host "Extracting the latest Login migration console app nupkg: $($LatestNugetOrgDetails.NameAndVersion) ..."
                    $Nugets = $Nugets | Sort-Object -Property Name -Descending;
                    $LatestNugetPath = $Nugets[0].FullName;
                    Expand-Archive -Path $LatestNugetPath -DestinationPath $LatestNugetFolder.Value;
                }
            }

            #Check if update was successful
            $TestPathResult = Test-Path -Path "$($LatestNugetFolder.Value)\$ExePath"

            $NugetVersions = Get-ChildItem -Path $DownloadsFolder -Filter "$PackageId.*";
            $NugetVersions = $NugetVersions | Sort-Object -Property Name -Descending

            if($TestPathResult)
            {
                Write-Host "Removing all older Login migration console apps..."
                #Remove all other NuGet versions except for the version just downloaded
                for ($NugetIndex = 0; $NugetIndex -lt $NugetVersions.Length; $NugetIndex = $NugetIndex + 1)
                {
                    if($NugetVersions[$NugetIndex].Name -ne $LatestNugetOrgDetails.NameAndVersion)
                    {
                        Remove-Item -Path $NugetVersions[$NugetIndex].FullName -Recurse -Force
                    }
                }
            }
            else
            {
                if($NugetVersions.Length -gt 0)
                {
                    $LatestNugetFolder.Value = $NugetVersions[0].Name;
                }
            }
        }
    }
}
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBObiIWKov93ahB
# NKGaPk8NMBee8k6wbE2KOCkXTwcEO6CCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIM7Xy7VfMaQ6KOKck7NVy1+V
# rFIbfDkLZ3++29ZqPVZaMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAANu48VL1W/q+3vbG3Zs90OWfwM/lrGa91Lp2eMsLVpEoaldiH6r//wpO
# rzPGN+91kT/gIjN3cOocaqsMfc0PW+ryhm0NhwMoi6kj1gTNnHYjhqqy1JQjbGTd
# h2dB0NidSbhQfLU6G5CzfUH7HtDof6O6avTAD4vMhbc5Sf0nhmbM4+pRCPFgD3lZ
# BSE+lF2HEs0pvU1N4wZfk0Q62mfupBDGWYua+oGF/Tw9TsmmxSc7bg9TWLcpKeIh
# KEU9gSzNCaVz9V5d7ceb1Sl62W1uiF7GCuzufzHRsxFc7HR8Hm9ycxdTqN4c471d
# pDjQUB/kb0OuVPyw3XGvAeTdR9e65KGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCD4gvVWYRtk+AH0tUAv4KR4b9LRea8cjkBiXEMj7l6DggIGaKOk7iwX
# GBMyMDI1MTAwOTEyNDUxNC4xNThaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046N0YwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAgbXvFE4mCPsLAABAAACBjANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTBaFw0yNjA0MjIxOTQyNTBaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046N0YwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDpRIWbIM3Rlr397cjHaYx85l7I+ZVWGMCBCM911BpU
# 6+IGWCqksqgqefZFEjKzNVDYC9YcgITAz276NGgvECm4ZfNv/FPwcaSDz7xbDbsO
# oxbwQoHUNRro+x5ubZhT6WJeU97F06+vDjAw/Yt1vWOgRTqmP/dNr9oqIbE5oCLY
# dH3wI/noYmsJVc7966n+B7UAGAWU2se3Lz+xdxnNsNX4CR6zIMVJTSezP/2STNcx
# JTu9k2sl7/vzOhxJhCQ38rdaEoqhGHrXrmVkEhSv+S00DMJc1OIXxqfbwPjMqEVp
# 7K3kmczCkbum1BOIJ2wuDAbKuJelpteNZj/S58NSQw6khfuJAluqHK3igkS/Oux4
# 9qTP+rU+PQeNuD+GtrCopFucRmanQvxISGNoxnBq3UeDTqphm6aI7GMHtFD6DOjJ
# lllH1gVWXPTyivf+4tN8TmO6yIgB4uP00bH9jn/dyyxSjxPQ2nGvZtgtqnvq3h3T
# RjRnkc+e1XB1uatDa1zUcS7r3iodTpyATe2hgkVX3m4DhRzI6A4SJ6fbJM9isLH8
# AGKcymisKzYupAeFSTJ10JEFa6MjHQYYohoCF77R0CCwMNjvE4XfLHu+qKPY8GQf
# sZdigQ9clUAiydFmVt61hytoxZP7LmXbzjD0VecyzZoL4Equ1XszBsulAr5Ld2Kw
# cwIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFO0wsLKdDGpT97cx3Iymyo/SBm4SMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQB23GZOfe9ThTUvD29i4t6lDpxJhpVRMme+
# UbyZhBFCZhoGTtjDdphAArU2Q61WYg3YVcl2RdJm5PUbZ2bA77zk+qtLxC+3dNxV
# sTcdtxPDSSWgwBHxTj6pCmoDNXolAYsWpvHQFCHDqEfAiBxX1dmaXbiTP1d0Xffv
# gR6dshUcqaH/mFfjDZAxLU1s6HcVgCvBQJlJ7xEG5jFKdtqapKWcbUHwTVqXQGbI
# lHVClNJ3yqW6Z3UJH/CFcYiLV/e68urTmGtiZxGSYb4SBSPArTrTYeHOlQIj/7lo
# VWmfWX2y4AGV/D+MzyZMyvFw4VyL0Vgq96EzQKyteiVeBaVEjxQKo3AcPULRF4Uz
# z98P2tCM5XbFZ3Qoj9PLg3rgFXr0oJEhfh2tqUrhTJd13+i4/fek9zWicoshlwXg
# Fu002ZWBVzASEFuqED48qyulZ/2jGJBcta+Fdk2loP2K3oSj4PQQe1MzzVZO52AX
# O42MHlhm3SHo3/RhQ+I1A0Ny+9uAehkQH6LrxkrVNvZG4f0PAKMbqUcXG7xznKJ0
# x0HYr5ayWGbHKZRcObU+/34ZpL9NrXOedVDXmSd2ylKSl/vvi1QwNJqXJl/+gJkQ
# EetqmHAUFQkFtemi8MUXQG2w/RDHXXwWAjE+qIDZLQ/k4z2Z216tWaR6RDKHGkwe
# CoDtQtzkHTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNN
# MIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjdGMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQAE
# a0f118XHM/VNdqKBs4QXxNnN96CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7JIB7TAiGA8yMDI1MTAwOTA5NDIw
# NVoYDzIwMjUxMDEwMDk0MjA1WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDskgHt
# AgEAMAcCAQACAjrJMAcCAQACAhRdMAoCBQDsk1NtAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAJQU+WssQ/DhxrtT/BF18/0SPPe3KI2fpBll5eKNipHSGAPb
# fyfRRcJzuv2AI5FzUohnhPLJ0Y7cRivLyjVmeOzNjZMtTyshTzect5OELc6eGckz
# vWqVmRavXRYbckbvuguz3eP5zSX0mBvH+C5P9WIeQ7uTjGCJToBhDrAdTjWyLf/O
# J7C4yEwh6Ea68pcBgpTCq4YK0XH4lVaz5KN5aDIbkJdsYjbH/8PLAIlDdLzgPQII
# zZqcvh+tTuweDuKazPLzu9T75VrB8+7Q1NDkKQ4aX5ouy77i6Ue9Moi0KFXoddKN
# NCHzMX3D+MsFBNNDIEi8NFU2fbZEK9OS88OmNRwxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgbXvFE4mCPsLAABAAACBjAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCDDQXcOFXPav47lXe4wNS7+XvDCT4j8EQ4I19RmumONFDCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIODo9ZSIkZ6dVtKT+E/uZx2WAy7K
# iXM5R1JIOhNJf0vSMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAIG17xROJgj7CwAAQAAAgYwIgQgZkWvTcszxJVyVpdthZfV/cz05Hlj
# 4407SX6E7R2TWoEwDQYJKoZIhvcNAQELBQAEggIAJ5wCTvmUgAe7dg3acSpIXPNv
# qHAVQjlUxxV93qln/Zu8EZ736Od7efMfEJAbiFutSIlLdeTT0FEZYoQ3NNASyHDF
# e8GVg3Q+ssgRcNbrdZe2CRqOXrvJ0MSug3tLp5jTs2G0QiH6dn2Xj5MmMeiVrh8f
# HYOvKifA37/5YmXzxcfhifnsFizZVsx6o6iCLOOKzO4DKfAtihT+C/ppbd7BmEbc
# OEzYW+scjiRL3DXzK0ERWVxYUb8+ItKSr1Y4hMbHdht1/95hjYz3xbCG8qsQnHT2
# alunHisKu+aLOohZVvd7O4GZ+nyBO+y+BNXVPqEu632xqQhiee9yF2D/HaSqf3aE
# LLKgyGERgqqYVAOhuMFOVoG1E7JYEXSObpP+F6P/XjMg0GWowynHj4N+2zcMonMe
# myeG4nYGoGpoprfTA8GzzImb3G9MGk/UC+vL41mikk44W45yuNcyJeWSaG/Cu1zX
# Mp0M4n9JIJl2fO2s6V/kUTlhaHJ7wHIn5hWmQHkeuNS9OiCZmGo9yb13ud19YWZg
# qUlcytIbnZiRRrwR9CVC+b3f75EyefT8NR6Yc5mEGxd4Z5FMz10keAUY+GSgmlyJ
# T2V7LDYrAPpDXnazN2wnqVBeeA2G+Ypi7EQtPYP1N8acud1fExd/vUMqeDtGZ9Yk
# hkB0rQv6jTxrNgD0zJY=
# SIG # End signature block

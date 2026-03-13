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
Creates a Redis Enterprise cache.
.Description
Creates or updates an existing (overwrite/recreate, with potential downtime) cache cluster with an associated database.
.Example
PS C:\> New-AzRedisEnterpriseCache -Name "MyCache" -ResourceGroupName "MyGroup" -Location "West US" -Sku "Enterprise_E10"

Location Name    Type                            Zone Database
-------- ----    ----                            ---- --------
West US  MyCache Microsoft.Cache/redisEnterprise      {default}

.Example
PS C:\> New-AzRedisEnterpriseCache -Name "MyCache" -ResourceGroupName "MyGroup" -Location "East US" -Sku "Enterprise_E20" -Capacity 4 -MinimumTlsVersion "1.2" -Zone "1","2","3" -Tag @{"tag1" = "value1"} -Module "{name:RedisBloom, args:`"ERROR_RATE 0.00 INITIAL_SIZE 400`"}","{name:RedisTimeSeries, args:`"RETENTION_POLICY 20`"}","{name:RediSearch}" -ClientProtocol "Plaintext" -EvictionPolicy "NoEviction" -ClusteringPolicy "EnterpriseCluster" -AofPersistenceEnabled -AofPersistenceFrequency "1s"

Location Name    Type                            Zone      Database
-------- ----    ----                            ----      --------
East US  MyCache Microsoft.Cache/redisEnterprise {1, 2, 3} {default}

.Example
PS C:\> New-AzRedisEnterpriseCache -Name "MyCache" -ResourceGroupName "MyGroup" -Location "East US" -Sku "EnterpriseFlash_F300" -NoDatabase

Location Name    Type                            Zone Database
-------- ----    ----                            ---- --------
East US  MyCache Microsoft.Cache/redisEnterprise      {}

.Outputs
Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Models.Api20250701.ICluster
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

MODULE <IModule[]>: Optional set of redis modules to enable in this database - modules can only be added at creation time.
  Name <String>: The name of the module, e.g. 'RedisBloom', 'RediSearch', 'RedisTimeSeries'
  [Arg <String>]: Configuration options for the module, e.g. 'ERROR_RATE 0.00 INITIAL_SIZE 400'.

.Link
https://learn.microsoft.com/powershell/module/az.redisenterprisecache/new-azredisenterprisecache
#>
function New-AzRedisEnterpriseCache {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Models.Api20250701.ICluster])]
    [CmdletBinding(DefaultParameterSetName='CreateClusterWithDatabase', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory)]
        [Alias('Name')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Path')]
        [System.String]
        # The name of the Redis Enterprise cluster.
        ${ClusterName},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Path')]
        [System.String]
        # The name of the resource group.
        # The name is case insensitive.
        ${ResourceGroupName},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.String]
        # The geo-location where the resource lives.
        ${Location},

        [Parameter(Mandatory)]
        [Alias('SkuName')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.SkuName])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.SkuName]
        # The type of RedisEnterprise cluster to deploy.
        # Accepted values: Balanced_B0, Balanced_B1, Balanced_B10, Balanced_B100, Balanced_B1000, Balanced_B150, Balanced_B20, Balanced_B250, Balanced_B3, Balanced_B350, Balanced_B5, Balanced_B50, Balanced_B500, Balanced_B700, ComputeOptimized_X10, ComputeOptimized_X100, ComputeOptimized_X150, ComputeOptimized_X20, ComputeOptimized_X250, ComputeOptimized_X3, ComputeOptimized_X350, ComputeOptimized_X5, ComputeOptimized_X50, ComputeOptimized_X500, ComputeOptimized_X700, EnterpriseFlash_F1500, EnterpriseFlash_F300, EnterpriseFlash_F700, Enterprise_E1, Enterprise_E10, Enterprise_E100, Enterprise_E20, Enterprise_E200, Enterprise_E400, Enterprise_E5, Enterprise_E50, FlashOptimized_A1000, FlashOptimized_A1500, FlashOptimized_A2000, FlashOptimized_A250, FlashOptimized_A4500, FlashOptimized_A500, FlashOptimized_A700, MemoryOptimized_M10, MemoryOptimized_M100, MemoryOptimized_M1000, MemoryOptimized_M150, MemoryOptimized_M1500, MemoryOptimized_M20, MemoryOptimized_M2000, MemoryOptimized_M250, MemoryOptimized_M350, MemoryOptimized_M50, MemoryOptimized_M500, MemoryOptimized_M700
        ${Sku},

        [Parameter()]
        [Alias('SkuCapacity')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.Int32]
        # The size of the RedisEnterprise cluster.
        # Defaults to 2 or 3 or not applicable depending on SKU.Valid values are (2, 4, 6, ...) for Enterprise_* SKUs and (3, 9, 15, ...) for EnterpriseFlash_* SKUs.
        # For other SKUs capacity argument is not supported.
        ${Capacity},

        [Parameter()]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.TlsVersion])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.TlsVersion]
        # The minimum TLS version for the cluster to support - default is 1.2
        # Allowed values: 1.0, 1.1, 1.2
        ${MinimumTlsVersion},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.String[]]
        # The Availability Zones where this cluster will be deployed.
        ${Zone},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Models.Api20.ITrackedResourceTags]))]
        [System.Collections.Hashtable]
        # Cluster resource tags.
        ${Tag},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Models.Api20250701.IModule[]]
        # Optional set of redis modules to enable in this database - modules can only be added at create time.
        # To construct, see NOTES section for MODULE properties and create a hash table.
        ${Module},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.Protocol])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.Protocol]
        # Specifies whether redis clients can connect using TLS-encrypted or plaintext redis protocols - default is Encrypted
        # Allowed values: Encrypted, Plaintext
        ${ClientProtocol},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.Int32]
        # TCP port of the database endpoint - defaults to an available port
        # Specified at create time.
        ${Port},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.EvictionPolicy])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.EvictionPolicy]
        # Redis eviction policy - default is VolatileLRU
        # Allowed values: AllKeysLFU, AllKeysLRU, AllKeysRandom, VolatileLRU, VolatileLFU, VolatileTTL, VolatileRandom, NoEviction
        ${EvictionPolicy},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.String]
        # Name for the group of linked database resources
        ${GroupNickname},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [AllowEmptyCollection()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Models.Api20250701.ILinkedDatabase[]]
        # List of database resources to link with this database
        # To construct, see NOTES section for GEOREPLICATIONLINKEDDATABASE properties and create a hash table.
        ${LinkedDatabase},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.ClusteringPolicy])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.ClusteringPolicy]
        # Clustering policy - default is OSSCluster
        # Specified at create time.
        # Allowed values: EnterpriseCluster, OSSCluster
        ${ClusteringPolicy},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.AccessKeysAuthentication])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.AccessKeysAuthentication]
        # This property can be Enabled/Disabled to allow or deny access with the current access keys.
        # Can be updated even after database is created.
        ${AccessKeysAuthentication},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.String]
        # Key encryption key Url versioned only. Ex: https://contosovault.vault.azure.net/keys/contosokek/562a4bb76b524a1493a6afe8e536ee78"
        ${CustomerManagedKeyEncryptionKeyUrl},

        [Parameter()]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.HighAvailability])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.HighAvailability]
        # Enabled by default. Can only be updated from disabled to enabled.
        # If highAvailability is disabled, the data set is not replicated.
        # This affects the availability SLA, and increases the risk of data loss.
        ${HighAvailability},

        [Parameter()]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.PublicNetworkAccess])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.PublicNetworkAccess]
        # Whether or not public network traffic can access the Redis cluster.
        # Only 'Enabled' or 'Disabled' can be set.
        ${PublicNetworkAccess},

        [Parameter()]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.ManagedServiceIdentityType])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.ManagedServiceIdentityType]
        # Type of managed service identity (where both SystemAssigned and UserAssigned types are allowed).
        ${IdentityType},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Models.Api40.IUserAssignedIdentities]))]
        [System.Collections.Hashtable]
        # The set of user assigned identities associated with the resource. The userAssignedIdentities dictionary keys will be ARM resource ids in the form: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}. The dictionary values can be empty objects ({}) in requests.
        ${IdentityUserAssignedIdentity},

        [Parameter()]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.CmkIdentityType])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.CmkIdentityType]
        # Only userAssignedIdentity is supported in this API version; other types may be supported in the future
        ${KeyEncryptionKeyIdentityType},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.String]
        # User assigned identity to use for accessing key encryption key Url. Ex: /subscriptions/<sub uuid>/resourceGroups/<resource group>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myId.
        ${KeyEncryptionKeyIdentityUserAssignedIdentityResourceId},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.Management.Automation.SwitchParameter]
        # [Preview] Sets whether AOF persistence is enabled.
        # After enabling AOF persistence, you will be unable to disable it.
        # Support for disabling AOF persistence after enabling will be added at a later date.
        ${AofPersistenceEnabled},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.AofFrequency])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.AofFrequency]
        # [Preview] Sets the frequency at which data is written to disk if AOF persistence is enabled.
        # Allowed values: 1s, always
        ${AofPersistenceFrequency},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [System.Management.Automation.SwitchParameter]
        # [Preview] Sets whether RDB persistence is enabled.
        # After enabling RDB persistence, you will be unable to disable it.
        # Support for disabling RDB persistence after enabling will be added at a later date.
        ${RdbPersistenceEnabled},

        [Parameter(ParameterSetName='CreateClusterWithDatabase')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.RdbFrequency])]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Support.RdbFrequency]
        # [Preview] Sets the frequency at which a snapshot of the database is created if RDB persistence is enabled.
        # Allowed values: 1h, 6h, 12h
        ${RdbPersistenceFrequency},

        [Parameter(ParameterSetName='CreateClusterOnly', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Advanced - Do not automatically create a default database.
        # Warning: The cache will not be usable until you create a database.
        ${NoDatabase},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
        [System.String]
        # The ID of the target subscription.
        ${SubscriptionId},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.RedisEnterpriseCache.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {
        $GetPSBoundParameters = @{} + $PSBoundParameters
        $null = $GetPSBoundParameters.Remove("NoDatabase")
        $null = $GetPSBoundParameters.Remove("Module")
        $null = $GetPSBoundParameters.Remove("ClientProtocol")
        $null = $GetPSBoundParameters.Remove("Port")
        $null = $GetPSBoundParameters.Remove("EvictionPolicy")
        $null = $GetPSBoundParameters.Remove("ClusteringPolicy")
        $null = $GetPSBoundParameters.Remove("AofPersistenceEnabled")
        $null = $GetPSBoundParameters.Remove("AofPersistenceFrequency")
        $null = $GetPSBoundParameters.Remove("RdbPersistenceEnabled")
        $null = $GetPSBoundParameters.Remove("RdbPersistenceFrequency")
        $null = $GetPSBoundParameters.Remove("GroupNickname")
        $null = $GetPSBoundParameters.Remove("LinkedDatabase")
        $null = $GetPSBoundParameters.Remove("AccessKeysAuthentication")
        $cluster = Az.RedisEnterpriseCache.internal\New-AzRedisEnterpriseCache @GetPSBoundParameters

        if (('CreateClusterOnly') -contains $PSCmdlet.ParameterSetName)
        {
            $cluster.Database = @{}
            return $cluster
        }

        $null = $PSBoundParameters.Remove("NoDatabase")
        $null = $PSBoundParameters.Remove("Location")
        $null = $PSBoundParameters.Remove("Sku")
        $null = $PSBoundParameters.Remove("Capacity")
        $null = $PSBoundParameters.Remove("MinimumTlsVersion")
        $null = $PSBoundParameters.Remove("Zone")
        $null = $PSBoundParameters.Remove("Tag")
        $null = $PSBoundParameters.Remove("IdentityType")
        $null = $PSBoundParameters.Remove("IdentityUserAssignedIdentity")
        $null = $PSBoundParameters.Remove("CustomerManagedKeyEncryptionKeyUrl")
        $null = $PSBoundParameters.Remove("KeyEncryptionKeyIdentityType")
        $null = $PSBoundParameters.Remove("KeyEncryptionKeyIdentityUserAssignedIdentityResourceId")
        $null = $PSBoundParameters.Remove("HighAvailability")
        $null = $PSBoundParameters.Remove("PublicNetworkAccess")  # Remove for database creation
        $null = $PSBoundParameters.Add("DatabaseName", "default")
        $database = Az.RedisEnterpriseCache.internal\New-AzRedisEnterpriseCacheDatabase @PSBoundParameters
        $cluster.Database = @{$database.Name = $database}

        return $cluster
    }
}

# SIG # Begin signature block
# MIIoVQYJKoZIhvcNAQcCoIIoRjCCKEICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDbmTLNCQJd0/Tu
# 8P/GccLpNOwC6GXq5pQwrDSGzLKnkKCCDYUwggYDMIID66ADAgECAhMzAAAEhJji
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGiYwghoiAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAASEmOIS4HijMV0AAAAA
# BIQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIBcL
# /jZzxJS+CshkAMtAd06juhcxwMUFbJXIyYhmqL+8MEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAhYg0ysb3ChsUjLBnyhbA32uGZ9o4HIoyZCcU
# cz2JE/kLOl+iqSmeUN4Mqa4Q8WZNNvRtNFdhOzGPCOTPOwtXIeehsXaCutf/2R78
# MRoQfiVYB4mco3NUicD5wNq/j+HK+fmovdCqz5C2cOIqDmduDbAQwXhlT5DYI0jN
# SW32y8/c0DethbmW3xHnhBmxagzEdkHLW2yi/rrwuqsldism8SIxqxrrYjjaOJ6I
# msN9dooewAdBrQeimTFd0UY1v7w6driz/oIF3ZNNxCqtOB4CQWtVHHTa3EUEAB/U
# 0mqprk+M1UA4ICQpEjEJSXVn78VoVIY/o2u4e7loJdOcP2VULKGCF7AwghesBgor
# BgEEAYI3AwMBMYIXnDCCF5gGCSqGSIb3DQEHAqCCF4kwgheFAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCAaZhb/funAPa5jbT9zkVsEv9Y9MlncYKrX
# xPoJzYwgaAIGaPGRz99cGBMyMDI1MTAyOTEyMDMwMS41NTJaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjozNjA1LTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEf4wggcoMIIFEKADAgECAhMzAAACE7BD
# NWbPr5XoAAEAAAITMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI1MDgxNDE4NDgxN1oXDTI2MTExMzE4NDgxN1owgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjM2MDUtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# 9Jl64LoZxDINSFgz+9KS5Ozv5m548ePVzc9RXWe4T4/Mplfga4eq12RGdp5cVvnj
# de5vxfq2ax/jnu7vUW4rZN4mOUm5vh+kcYsQlYQ53FwgIB3nEjcQHomrG3mZe/oz
# jFSAr6JbglKtIeAySPzAcFzyAer5lLNUHBEvQMM8BOjMyapCvh0xsg4xKFcVEJQL
# KEfCGBffMZI/amutHFb3CUTZ7aVpG2KHEFUNlZ1vwMKvxXTPRDnbwPGzyyqJJznf
# sLNHQ4vXt2ttS1PeCoGI0hN1Peq8yGsIXM9oocwC06DGNSM/4LAx2uKvwmUn6NwL
# c0+tmvny6w28rZLejskRfnVWofEv1mWY0jHUnHrwSGBS8gVP9gcBs6P5g0OpJPMf
# xdUkHXRkcMPPW0hIP8NbW8W5Sup8HuwnSKbjpyAlGBUdM/V5rZb0sZmkn714r6UL
# GK+cLLAN6R3FhX6N0nj64F27LTK2BbS0pJZaXjo0eDNz1QcxeIFLUgF+RBsLYDn8
# E8cCkexK8Nlt3Gi9zJf55w6UfTZ+kwTMxMqFxh7+Tfx7+aBObZ+nx961AtiqAy7z
# VV69o/LWRdKPZdvZn9ESyGbTnPfjkBERv22prSlETlRwzP6bmEVOKWLWVwxuwh7b
# UWUuUb1cj93zvttQYGQat5E9ALLJNmlvLKCskB7raLsCAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBQTnhBKx+FryphQWMRipH49sMFAOjAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAgmxaJrGqQ2D6UJhZ6Ql2SZFOaNuGbW3LzB+ES+l2BB1MJtBRSFdi/hVY
# 33NpxsJQhQ5TLVp0DXYOkIoPQc17rH+IVhemO8jCt+U6I1TIw6cR7c+tEo/Jjp6E
# qEU1c4/mraMjgHhQ+raC/OUAm98A1r4bIPHtsBmLROGmeE5XLIFaBIZWHvh2COXI
# TKObXVd5wGtJ1dZZdwaHACXF506jta+uoUdyzAeuNlTPLTrZ8nyhxGwk9Vh6eiDQ
# 7CQMWSSa8DJS9PUXjeoi9vTdS7ZMXqu+tv6Qz3xtoBF5+YFK4uE+miGs90Fxm0VK
# 2lWrmFhjkRl5zyoHOdwG7spNYkDomCPNWIudUQmQYKpt/Hsspfcb+xpnWIDQdMzg
# E8pj1vpwLgWEnH7LtT4dZCeoDo9PK40RxBD8kKJ769ngkEwfwCD2EX/MQk79eIvO
# hpnH12GuVByvaKZk5XZvqtPONNwr8q/qA3877IuWwWgnaeX+prpw0dZ/QLtbGGVr
# gP+TRQjt+2dcZA5P3X4LwANhiPsy0Ol4XCdj7OxBLFvOzsCPDPaVnkp+dfDFG+NO
# Bir7aqTJ68622pymg1V+6gc/1RvxC/wgvYyG033ecJqv0On0ZRNYr+i/OkwgA3HP
# 1aLD0aHrEpw6lt0263iRkCvrcdcOW8w3jC8TJuaGWyC2S9jEjzgwggdxMIIFWaAD
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
# 2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIDWTCCAkECAQEwggEBoYHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjozNjA1LTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAmBE8SCjxgjac
# my8/VEdk7NxpR6aggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAOyr4ScwIhgPMjAyNTEwMjkwMDQxMTFaGA8yMDI1
# MTAzMDAwNDExMVowdzA9BgorBgEEAYRZCgQBMS8wLTAKAgUA7KvhJwIBADAKAgEA
# AgIIKQIB/zAHAgEAAgISnTAKAgUA7K0ypwIBADA2BgorBgEEAYRZCgQCMSgwJjAM
# BgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEB
# CwUAA4IBAQDUQYEeM2Wl9pWITi3jiWrJQPXMoDgbrYJd2OTKylIblhqy7tA7iffS
# Vf8igE10smVyQab6qC85CSwU4bWIXr9+3HlYPBo5/SDZikP4eYX3celrHHkmywYl
# CmtScRr1BjhAkX+akP1ddDZVH4ZDRSE4vWCKoKjItvRmdfKkeR85zJ8Z+BxIqnQ/
# DdIjgPC1n5E5naTsKbDtOhnZVIcV93WAztWv4owCrpgRP4lZy5+GsygXmtRHtddH
# /ozcxMnvrG+sUo0Ek7EKACmVJ1r2yRU+WTUvWxl6wRJdJsrdzFivtJKDL946ajqC
# 2vNWEs/AxtMDueK4QafWQqQo8yaEVgkBMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAITsEM1Zs+vlegAAQAAAhMwDQYJYIZI
# AWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG
# 9w0BCQQxIgQg9HiwdqLt544a41wca8FNIOvtdzTqMGd1Tr4Gxcm8hXQwgfoGCyqG
# SIb3DQEJEAIvMYHqMIHnMIHkMIG9BCDM4QltFIUz8J4DjAzP4nVodZvQxYGleUIf
# p86Oa5xYaDCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMz
# AAACE7BDNWbPr5XoAAEAAAITMCIEIM4j7+4fNpkQL/zZfQxlwjZjrW0cJ+6yp2cp
# CLk5oYDNMA0GCSqGSIb3DQEBCwUABIICAMZrF1u4dJiPBJe0kN3jCHjz8B3LG+/6
# tFkku9ojK0mXFQ/VLgX/cdob7v/yYsVGsKUNMZZbYVdXcl+vJRjGPNIHI7+TeDK7
# 9H1GvK6LVGekkOkdH6gcMv/DAkGqK7UVJSVpQcFVtpkTmE6pbRlwG9M/Gh84vMm9
# Z8sv8v0PPzIBYLK8IGRPUeX4w1pksH0Z6BMi8T7epRxY57OxjLhY+M7ZaY6MyA1d
# 7aAOwciXDAE120pc+k+4cXSxQsOyNiT/GpnMskI0VCSvVFNWY+tziFwW4KoZFtOr
# p/voIVXMhveuhmB0nd/INaLh8H8Qr2DytfyfbEJa/fO4rUxxDIh9tQQBZfabWLSb
# 1jnCMaZzpqVC1QZ1x+XUcd9GJMehaT64qiPW+gD8XOYAfx09I3hNcmf0BsPbzpwt
# Y3RNrFkNuL5bOLaL9x0QPRtrIa0SQn7lYVU+n5rK1IF57EjT78q1Rz48ZTIeaumj
# R2ANXjMeZEGhqFEwAkuzNTxDA9SmHVXTbxBiFWvAbLhPizWbxUyb8qjEewWOrH0q
# PQeJ3FTDKk3uYxfQcribxS/pYFjD2qVQzihH0iYnLByZhg1bgCmXPPlLaswaLrVo
# aAFlH7WxGCAXNVm6fncju5f/jirb+fn6foxkCJPCHzyShK6qBv8PhfV+IvhPiQ9m
# NzVMtSz2Ohja
# SIG # End signature block

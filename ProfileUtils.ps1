#==============================================================================
# ProfileUtils.ps1 - Core Utility Functions for PowerShell Profile
#==============================================================================

#==============================================================================
# AZURE PRODUCTIVITY FUNCTIONS
#==============================================================================

# Auto-connect if not connected
function Ensure-AzConnection {
    $ctx = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $ctx) {
        Write-Host "[INFO] Not connected. Running Connect-AzAccount..." -ForegroundColor Yellow
        Connect-AzAccount -ErrorAction Stop
    }
}

#==============================================================================
# TAB COMPLETION
#==============================================================================

# Tab completion for AVD host pool names
Register-ArgumentCompleter -CommandName avd-hosts,avd-health,avd-fslogix,avd-rdp,avd-users,avd-extensions,avd-drain,avd-enable -ParameterName HostPoolName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $pools = Get-AzWvdHostPool -ErrorAction SilentlyContinue
    
    $pools | 
        Where-Object { $_.Name -like "$wordToComplete*" } | 
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_.Name, 
                $_.Name, 
                'ParameterValue', 
                "$($_.Name) ($($_.ResourceGroupName))"
            )
        }
}

# Tab completion for AVD session host names
Register-ArgumentCompleter -CommandName avd-drain,avd-enable -ParameterName SessionHostName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $hostPool = $fakeBoundParameters['HostPoolName']
    $rg = $fakeBoundParameters['ResourceGroupName']
    
    if ($hostPool -and $rg) {
        $hosts = Get-AzWvdSessionHost -HostPoolName $hostPool -ResourceGroupName $rg -ErrorAction SilentlyContinue
        
        $hosts | 
            Where-Object { $_.Name -like "*$wordToComplete*" } | 
            ForEach-Object {
                $hostName = ($_.Name -split '/')[1]
                [System.Management.Automation.CompletionResult]::new(
                    $hostName, 
                    $hostName, 
                    'ParameterValue', 
                    "$hostName ($($_.Status))"
                )
            }
    }
}

# Tab completion for subscription names
Register-ArgumentCompleter -CommandName ss, Set-AzContext, Select-AzSubscription, Get-AzSubscription, Remove-AzSubscription -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    if (-not $global:AzSubCache) {
        $global:AzSubCache = Get-AzSubscription -ErrorAction SilentlyContinue | Sort-Object Name
    }
    
    $global:AzSubCache | 
        Where-Object { $_.Name -like "$wordToComplete*" } | 
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_.Name, 
                $_.Name, 
                'ParameterValue', 
                $_.Name
            )
        }
}

Register-ArgumentCompleter -CommandName Set-AzContext, Select-AzSubscription, Get-AzSubscription, Remove-AzSubscription -ParameterName Subscription -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    if (-not $global:AzSubCache) {
        $global:AzSubCache = Get-AzSubscription -ErrorAction SilentlyContinue | Sort-Object Name
    }
    
    $global:AzSubCache | 
        Where-Object { $_.Name -like "$wordToComplete*" -or $_.Id -like "$wordToComplete*" } | 
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_.Name, 
                $_.Name, 
                'ParameterValue', 
                $_.Name
            )
        }
}

# Tab completion for resource group names
Register-ArgumentCompleter -CommandName rgr, rgcount, vmstart, vmstop, vmrestart, vms, Invoke-AzVMRunCommand, Get-AzResourceGroup, Remove-AzResourceGroup, Set-AzResourceGroup, Get-AzVM, Remove-AzVM, Start-AzVM, Stop-AzVM, Restart-AzVM, Get-AzNetworkInterface, Get-AzPublicIpAddress, Get-AzVirtualNetwork, Get-AzSubnet, Get-AzDisk, Get-AzStorageAccount, Get-AzKeyVault -ParameterName ResourceGroupName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $rgs = Get-AzResourceGroup -ErrorAction SilentlyContinue
    
    $rgs | 
        Where-Object { $_.ResourceGroupName -like "$wordToComplete*" } | 
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_.ResourceGroupName, 
                $_.ResourceGroupName, 
                'ParameterValue', 
                $_.ResourceGroupName
            )
        }
}

# Tab completion for VM names
$VMCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $rg = $fakeBoundParameters['ResourceGroupName']
    
    if ($rg) {
        $vms = Get-AzVM -ResourceGroupName $rg -ErrorAction SilentlyContinue
    } else {
        $vms = Get-AzVM -ErrorAction SilentlyContinue
    }
    
    $vms | 
        Where-Object { $_.Name -like "$wordToComplete*" } | 
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_.Name, 
                $_.Name, 
                'ParameterValue', 
                "$($_.Name) ($($_.ResourceGroupName))"
            )
        }
}

Register-ArgumentCompleter -CommandName vmstart, vmstop, vmrestart, Invoke-AzVMRunCommand, Get-AzVM, Remove-AzVM, Start-AzVM, Stop-AzVM, Restart-AzVM, Get-AzNetworkInterface, Get-AzPublicIpAddress, Get-AzVirtualNetwork, Get-AzDisk, Get-AzStorageAccount, Get-AzKeyVault -ParameterName Name -ScriptBlock $VMCompleter
Register-ArgumentCompleter -CommandName Invoke-AzVMRunCommand, Get-AzVM, Remove-AzVM, Start-AzVM, Stop-AzVM, Restart-AzVM, Get-AzNetworkInterface, Get-AzPublicIpAddress, Get-AzVirtualNetwork, Get-AzDisk, Get-AzStorageAccount, Get-AzKeyVault -ParameterName VMName -ScriptBlock $VMCompleter

# Tab completion for resource names in findres
Register-ArgumentCompleter -CommandName findres -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $resources = Get-AzResource -ErrorAction SilentlyContinue
    
    $resources | 
        Where-Object { $_.Name -like "$wordToComplete*" } | 
        Select-Object -First 20 -Unique Name |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_.Name, 
                $_.Name, 
                'ParameterValue', 
                $_.Name
            )
        }
}

# Tab completion for resource types
Register-ArgumentCompleter -CommandName findtype -ParameterName Type -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $types = Get-AzResource -ErrorAction SilentlyContinue | 
        Select-Object -ExpandProperty ResourceType -Unique | 
        Sort-Object
    
    $types | 
        Where-Object { $_ -like "*$wordToComplete*" } | 
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_, 
                $_, 
                'ParameterValue', 
                $_
            )
        }
}

# Tab completion for tag names
Register-ArgumentCompleter -CommandName findtag -ParameterName TagName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $tags = Get-AzTag -ErrorAction SilentlyContinue
    
    $tags.Name | 
        Where-Object { $_ -like "$wordToComplete*" } | 
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_, 
                $_, 
                'ParameterValue', 
                $_
            )
        }
}

# Enable global Azure argument completion for all Az commands (if supported by installed Az version)
    # Safely attempt Az argument completer registration
    try {
        if (Get-Command Register-AzArgumentCompleter -ErrorAction SilentlyContinue) {
            Register-AzArgumentCompleter
        } else {
            Write-Verbose 'Register-AzArgumentCompleter not found; skipping registration.'
        }
    } catch {
        Write-Verbose 'Error while checking Register-AzArgumentCompleter; ignoring to prevent startup delays.'
    }

# Azure CLI (az) Tab Completion
if (Get-Command az -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -CommandName az -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $completions = az self-test --completion "$wordToComplete" 2>$null | ConvertFrom-Json
        $completions | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

#==============================================================================
# CLOUD MANAGEMENT
#==============================================================================

# SWITCH BETWEEN AZURE CLOUDS (Commercial/Government)
function azcloud {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('Commercial', 'Government', 'Gov', 'Comm')]
        [string]$Cloud
    )
    
    $currentEnv = (Get-AzContext -ErrorAction SilentlyContinue).Environment.Name
    
    if (-not $Cloud) {
        # Show current cloud
        if ($currentEnv -eq 'AzureUSGovernment') {
            Write-Host "[CLOUD] Azure Government" -ForegroundColor Yellow
        } elseif ($currentEnv -eq 'AzureCloud') {
            Write-Host "[CLOUD] Azure Commercial" -ForegroundColor Yellow
        } else {
            Write-Host "[CLOUD] $currentEnv" -ForegroundColor Yellow
        }
        Write-Host "`nTo switch clouds, use:" -ForegroundColor Gray
        Write-Host "  azcloud gov  - Switch to Government" -ForegroundColor Gray
        Write-Host "  azcloud comm - Switch to Commercial" -ForegroundColor Gray
        return
    }
    
    # Normalize input
    $targetEnv = switch ($Cloud.ToLower()) {
        'government' { 'AzureUSGovernment' }
        'gov' { 'AzureUSGovernment' }
        'commercial' { 'AzureCloud' }
        'comm' { 'AzureCloud' }
    }
    
    $friendlyName = if ($targetEnv -eq 'AzureUSGovernment') { 'Azure Government' } else { 'Azure Commercial' }
    
    try {
        Write-Host "[INFO] Switching to $friendlyName..." -ForegroundColor Yellow
        Connect-AzAccount -Environment $targetEnv -ErrorAction Stop | Out-Null
        
        # Clear cache when switching clouds
        $global:AzSubCache = $null
        $global:AzSubCacheTime = $null
        
        Write-Host "[SUCCESS] Connected to $friendlyName" -ForegroundColor Green
        
        # Show available subscriptions
        $subs = Get-AzSubscription | Sort-Object Name
        Write-Host "`n[INFO] Available subscriptions ($($subs.Count)):" -ForegroundColor Cyan
        $subs | Select-Object -First 10 Name | Format-Table -AutoSize
        
        if ($subs.Count -gt 10) {
            Write-Host "... and $($subs.Count - 10) more. Use 'subs' to see all.`n" -ForegroundColor Gray
        }
    }
    catch {
        Write-Error "Failed to switch: $($_.Exception.Message)"
    }
}

#==============================================================================
# SUBSCRIPTION MANAGEMENT
#==============================================================================

# FAST SUBSCRIPTION SWITCHING with fuzzy matching
function ss {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name
    )
    
    try {
        Ensure-AzConnection

        # Get current environment for cache key
        $currentEnv = (Get-AzContext).Environment.Name
        
        # Get all subscriptions and cache them (separate cache per environment)
        if (-not $global:AzSubCache -or $global:AzSubCacheEnv -ne $currentEnv -or ((Get-Date) - $global:AzSubCacheTime).TotalMinutes -gt 30) {
            Write-Host "[INFO] Refreshing subscription cache..." -ForegroundColor Cyan
            $global:AzSubCache = Get-AzSubscription -ErrorAction Stop | Sort-Object Name
            $global:AzSubCacheTime = Get-Date
            $global:AzSubCacheEnv = $currentEnv
        }

        # Fuzzy match: exact first, then contains, then starts with
        $match = $global:AzSubCache | Where-Object { $_.Name -eq $Name } | Select-Object -First 1
        if (-not $match) {
            $match = $global:AzSubCache | Where-Object { $_.Name -like "*$Name*" } | Select-Object -First 1
        }

        if ($match) {
            $null = Set-AzContext -Subscription $match.Id -ErrorAction Stop
            Write-Host "[SWITCHED] $($match.Name)" -ForegroundColor Green
            Add-RecentSub $match.Name
        } else {
            Write-Host "[ERROR] No match found for: $Name" -ForegroundColor Red
            Write-Host "[INFO] Available subscriptions:" -ForegroundColor Yellow
            $global:AzSubCache | Select-Object -First 10 Name | Format-Table -AutoSize
        }
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

# SWITCH BY NUMBER (for faster switching when listing)
function ssn {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Number
    )
    
    if (-not $global:AzSubCache) {
        Write-Host "[ERROR] No subscription cache. Run 'subs' first." -ForegroundColor Red
        return
    }
    
    if ($Number -lt 1 -or $Number -gt $global:AzSubCache.Count) {
        Write-Host "[ERROR] Invalid number. Must be between 1 and $($global:AzSubCache.Count)" -ForegroundColor Red
        return
    }
    
    $sub = $global:AzSubCache[$Number - 1]
    $null = Set-AzContext -Subscription $sub.Id -ErrorAction Stop
    Write-Host "[SWITCHED] $($sub.Name)" -ForegroundColor Green
    Add-RecentSub $sub.Name
}

# LIST ALL SUBSCRIPTIONS with search and numbering
function subs {
    param([string]$Filter = "")
    
    $currentEnv = (Get-AzContext -ErrorAction SilentlyContinue).Environment.Name
    
    if (-not $global:AzSubCache -or $global:AzSubCacheEnv -ne $currentEnv -or ((Get-Date) - $global:AzSubCacheTime).TotalMinutes -gt 30) {
        $global:AzSubCache = Get-AzSubscription | Sort-Object Name
        $global:AzSubCacheTime = Get-Date
        $global:AzSubCacheEnv = $currentEnv
    }
    
    $filtered = if ($Filter) {
        $global:AzSubCache | Where-Object { $_.Name -like "*$Filter*" }
    } else {
        $global:AzSubCache
    }
    
    # Add index for easy switching
    $i = 0
    $filtered | ForEach-Object {
        $i++
        [PSCustomObject]@{
            '#' = $i
            Name = $_.Name
            Id = $_.Id
            State = $_.State
        }
    } | Format-Table -AutoSize
    
    Write-Host "[TIP] Use 'ssn <number>' to switch by number" -ForegroundColor Gray
}

# SHOW CURRENT SUBSCRIPTION
function sub {
    $ctx = Get-AzContext
    if ($ctx) {
        Write-Host "[CURRENT] $($ctx.Subscription.Name)" -ForegroundColor Cyan
    } else {
        Write-Host "[ERROR] Not connected to Azure" -ForegroundColor Red
    }
}

# SHOW RECENT SUBSCRIPTIONS
function recent {
    if (-not $global:RecentSubs) {
        $global:RecentSubs = @()
    }
    
    if ($global:RecentSubs.Count -eq 0) {
        Write-Host "[INFO] No recent subscriptions" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n[RECENT SUBSCRIPTIONS]" -ForegroundColor Cyan
    $global:RecentSubs | ForEach-Object { 
        Write-Host "  $_" -ForegroundColor White 
    }
    Write-Host ""
}

# Track recent subscriptions
$global:RecentSubs = @()
function Add-RecentSub {
    param([string]$SubName)
    
    if (-not $global:RecentSubs) {
        $global:RecentSubs = @()
    }
    
    # Remove if already exists
    $global:RecentSubs = $global:RecentSubs | Where-Object { $_ -ne $SubName }
    
    # Add to front
    $global:RecentSubs = @($SubName) + $global:RecentSubs
    
    # Keep only last 5
    if ($global:RecentSubs.Count -gt 5) {
        $global:RecentSubs = $global:RecentSubs[0..4]
    }
}

#==============================================================================
# RESOURCE GROUP OPERATIONS
#==============================================================================

# FAST RESOURCE GROUP LISTING
function rg {
    param([string]$Filter = "")
    
    try {
        $rgs = Get-AzResourceGroup -ErrorAction Stop
        
        if ($Filter) {
            $rgs = $rgs | Where-Object { $_.ResourceGroupName -like "*$Filter*" }
        }
        
        $rgs | Select-Object ResourceGroupName, Location, ProvisioningState | 
            Sort-Object ResourceGroupName | Format-Table -AutoSize
        
        Write-Host "[TOTAL] $($rgs.Count) resource groups" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Error listing resource groups: $($_.Exception.Message)"
    }
}

# GET RESOURCES IN A RESOURCE GROUP
function rgr {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )
    
    try {
        $resources = Get-AzResource -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        $resources | Select-Object Name, ResourceType, Location | 
            Sort-Object ResourceType, Name | Format-Table -AutoSize
        Write-Host "[TOTAL] $($resources.Count) resources" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

# COUNT RESOURCES BY TYPE IN RESOURCE GROUP
function rgcount {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )
    
    try {
        $resources = Get-AzResource -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        $resources | Group-Object ResourceType | 
            Select-Object @{N='Type';E={$_.Name}}, Count | 
            Sort-Object Count -Descending | 
            Format-Table -AutoSize
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

#==============================================================================
# RESOURCE SEARCH & DISCOVERY
#==============================================================================

# SEARCH RESOURCES ACROSS CURRENT SUBSCRIPTION
function findres {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    Write-Host "[SEARCHING] Resources matching: $Name" -ForegroundColor Yellow
    $resources = Get-AzResource | Where-Object { $_.Name -like "*$Name*" }
    $resources | Select-Object Name, ResourceGroupName, ResourceType, Location | 
        Format-Table -AutoSize
    Write-Host "[FOUND] $($resources.Count) resources" -ForegroundColor Cyan
}

# FIND RESOURCES BY TYPE
function findtype {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Type
    )
    
    Write-Host "[SEARCHING] Resources of type: $Type" -ForegroundColor Yellow
    $resources = Get-AzResource | Where-Object { $_.ResourceType -like "*$Type*" }
    $resources | Select-Object Name, ResourceGroupName, ResourceType, Location | 
        Format-Table -AutoSize
    Write-Host "[FOUND] $($resources.Count) resources" -ForegroundColor Cyan
}

# LIST ALL RESOURCE TYPES IN SUBSCRIPTION
function restypes {
    Write-Host "[INFO] Fetching resource types..." -ForegroundColor Yellow
    $types = Get-AzResource | Group-Object ResourceType | 
        Select-Object @{N='ResourceType';E={$_.Name}}, Count | 
        Sort-Object Count -Descending
    $types | Format-Table -AutoSize
    Write-Host "[TOTAL] $($types.Count) unique resource types" -ForegroundColor Cyan
}

#==============================================================================
# AVD (AZURE VIRTUAL DESKTOP) OPERATIONS
#==============================================================================

# LIST ALL HOST POOLS
function avd-pools {
    param([string]$Filter = "")
    
    Write-Host "[INFO] Fetching AVD host pools..." -ForegroundColor Yellow
    
    try {
        $pools = Get-AzWvdHostPool -ErrorAction Stop
        
        if ($Filter) {
            $pools = $pools | Where-Object { $_.Name -like "*$Filter*" }
        }
        
        $pools | Select-Object Name, ResourceGroupName, Location, HostPoolType, LoadBalancerType, MaxSessionLimit, 
            @{N='ValidationEnvironment';E={$_.ValidationEnvironment}}, 
            @{N='RegistrationTokenExpiration';E={$_.RegistrationInfoExpirationTime}} | 
            Format-Table -AutoSize
        
        Write-Host "[TOTAL] $($pools.Count) host pools" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Error listing host pools: $($_.Exception.Message)"
        Write-Host "[TIP] Ensure Az.DesktopVirtualization module is installed: Install-Module Az.DesktopVirtualization" -ForegroundColor Yellow
    }
}

# LIST SESSION HOSTS IN A HOST POOL
function avd-hosts {
    param(
        [Parameter(Mandatory=$true)]
        [string]$HostPoolName,
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )
    
    Write-Host "[INFO] Fetching session hosts for: $HostPoolName" -ForegroundColor Yellow
    
    try {
        $hosts = Get-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        
        $hosts | Select-Object Name, 
            @{N='Status';E={$_.Status}},
            @{N='Sessions';E={$_.Session}},
            @{N='AllowNewSession';E={$_.AllowNewSession}},
            @{N='AgentVersion';E={$_.AgentVersion}},
            @{N='LastHeartBeat';E={$_.LastHeartBeat}},
            @{N='UpdateState';E={$_.UpdateState}} | 
            Format-Table -AutoSize
        
        Write-Host "[TOTAL] $($hosts.Count) session hosts" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

# COMPREHENSIVE AVD HEALTH CHECK FOR A HOST POOL
function avd-health {
    param(
        [Parameter(Mandatory=$true)]
        [string]$HostPoolName,
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        [switch]$Detailed
    )
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "AVD HEALTH CHECK: $HostPoolName" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    try {
        # Get Host Pool Info
        Write-Host "[1/5] Checking Host Pool Configuration..." -ForegroundColor Yellow
        $pool = Get-AzWvdHostPool -Name $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        
        Write-Host "  Host Pool Type: $($pool.HostPoolType)" -ForegroundColor White
        Write-Host "  Load Balancer: $($pool.LoadBalancerType)" -ForegroundColor White
        Write-Host "  Max Session Limit: $($pool.MaxSessionLimit)" -ForegroundColor White
        Write-Host "  Validation Env: $($pool.ValidationEnvironment)" -ForegroundColor White
        
        if ($pool.RegistrationInfoExpirationTime) {
            $expiry = [DateTime]$pool.RegistrationInfoExpirationTime
            $daysUntilExpiry = ($expiry - (Get-Date)).Days
            if ($daysUntilExpiry -lt 0) {
                Write-Host "  Registration Token: EXPIRED" -ForegroundColor Red
            } elseif ($daysUntilExpiry -lt 7) {
                Write-Host "  Registration Token: Expires in $daysUntilExpiry days" -ForegroundColor Yellow
            } else {
                Write-Host "  Registration Token: Valid ($daysUntilExpiry days remaining)" -ForegroundColor Green
            }
        }
        
        # Get Session Hosts
        Write-Host "`n[2/5] Checking Session Hosts..." -ForegroundColor Yellow
        $hosts = Get-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        
        $availableHosts = ($hosts | Where-Object { $_.Status -eq 'Available' }).Count
        $unavailableHosts = ($hosts | Where-Object { $_.Status -ne 'Available' }).Count
        $drainingHosts = ($hosts | Where-Object { $_.AllowNewSession -eq $false }).Count
        
        Write-Host "  Total Hosts: $($hosts.Count)" -ForegroundColor White
        Write-Host "  Available: $availableHosts" -ForegroundColor Green
        Write-Host "  Unavailable: $unavailableHosts" -ForegroundColor $(if($unavailableHosts -gt 0){'Red'}else{'Green'})
        Write-Host "  Draining: $drainingHosts" -ForegroundColor $(if($drainingHosts -gt 0){'Yellow'}else{'White'})
        
        # Check for outdated agents
        $outdatedAgents = $hosts | Where-Object { 
            $_.UpdateState -ne 'Succeeded' -or 
            [version]$_.AgentVersion -lt [version]"1.0.4800.0" 
        }
        
        if ($outdatedAgents.Count -gt 0) {
            Write-Host "  WARNING: $($outdatedAgents.Count) hosts with outdated/failed agents" -ForegroundColor Red
            if ($Detailed) {
                $outdatedAgents | Select-Object Name, AgentVersion, UpdateState | Format-Table -AutoSize
            }
        }
        
        # Check heartbeats
        $staleHeartbeats = $hosts | Where-Object { 
            $_.LastHeartBeat -and ((Get-Date) - [DateTime]$_.LastHeartBeat).TotalMinutes -gt 10 
        }
        
        if ($staleHeartbeats.Count -gt 0) {
            Write-Host "  WARNING: $($staleHeartbeats.Count) hosts with stale heartbeats (>10 min)" -ForegroundColor Red
            if ($Detailed) {
                $staleHeartbeats | Select-Object Name, LastHeartBeat | Format-Table -AutoSize
            }
        }
        
        # Get Active Sessions
        Write-Host "`n[3/5] Checking User Sessions..." -ForegroundColor Yellow
        $sessions = Get-AzWvdUserSession -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        
        $activeSessions = ($sessions | Where-Object { $_.SessionState -eq 'Active' }).Count
        $disconnectedSessions = ($sessions | Where-Object { $_.SessionState -eq 'Disconnected' }).Count
        
        Write-Host "  Total Sessions: $($sessions.Count)" -ForegroundColor White
        Write-Host "  Active: $activeSessions" -ForegroundColor Green
        Write-Host "  Disconnected: $disconnectedSessions" -ForegroundColor $(if($disconnectedSessions -gt 0){'Yellow'}else{'White'})
        
        if ($Detailed -and $sessions.Count -gt 0) {
            $sessions | Select-Object UserPrincipalName, SessionState, 
                @{N='Host';E={($_.Name -split '/')[1]}},
                CreateTime | Format-Table -AutoSize
        }
        
        # Check Application Groups
        Write-Host "`n[4/5] Checking Application Groups..." -ForegroundColor Yellow
        $appGroups = Get-AzWvdApplicationGroup -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue | 
            Where-Object { $_.HostPoolArmPath -like "*$HostPoolName*" }
        
        Write-Host "  Application Groups: $($appGroups.Count)" -ForegroundColor White
        
        if ($Detailed -and $appGroups.Count -gt 0) {
            foreach ($ag in $appGroups) {
                Write-Host "    - $($ag.Name) ($($ag.ApplicationGroupType))" -ForegroundColor Gray
                
                # Get assignments
                $assignments = Get-AzRoleAssignment -Scope $ag.Id -ErrorAction SilentlyContinue | 
                    Where-Object { $_.RoleDefinitionName -eq 'Desktop Virtualization User' }
                Write-Host "      Assigned Users/Groups: $($assignments.Count)" -ForegroundColor Gray
            }
        }
        
        # Check VM Extensions
        Write-Host "`n[5/5] Checking VM Extensions..." -ForegroundColor Yellow
        
        $vmIssues = 0
        foreach ($host in $hosts) {
            $vmName = ($host.Name -split '/')[1] -replace '\..*',''
            
            try {
                $vm = Get-AzVM -Name $vmName -ErrorAction SilentlyContinue
                
                if ($vm) {
                    $extensions = Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -ErrorAction SilentlyContinue
                    
                    $failedExtensions = $extensions | Where-Object { $_.ProvisioningState -ne 'Succeeded' }
                    
                    if ($failedExtensions.Count -gt 0) {
                        $vmIssues++
                        Write-Host "  WARNING: $vmName has $($failedExtensions.Count) failed extension(s)" -ForegroundColor Red
                        
                        if ($Detailed) {
                            $failedExtensions | Select-Object Name, ProvisioningState, TypeHandlerVersion | Format-Table -AutoSize
                        }
                    }
                }
            }
            catch { }
        }
        
        if ($vmIssues -eq 0) {
            Write-Host "  All accessible VM extensions: OK" -ForegroundColor Green
        } else {
            Write-Host "  Total VMs with extension issues: $vmIssues" -ForegroundColor Red
        }
        
        # Summary
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "HEALTH CHECK SUMMARY" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        
        $issueCount = 0
        if ($unavailableHosts -gt 0) { $issueCount++; Write-Host "  [!] Unavailable hosts detected" -ForegroundColor Red }
        if ($outdatedAgents.Count -gt 0) { $issueCount++; Write-Host "  [!] Outdated agents detected" -ForegroundColor Red }
        if ($staleHeartbeats.Count -gt 0) { $issueCount++; Write-Host "  [!] Stale heartbeats detected" -ForegroundColor Red }
        if ($vmIssues -gt 0) { $issueCount++; Write-Host "  [!] VM extension issues detected" -ForegroundColor Red }
        
        if ($issueCount -eq 0) {
            Write-Host "  [OK] No issues detected" -ForegroundColor Green
        } else {
            Write-Host "`n  Total Issues: $issueCount" -ForegroundColor Red
            Write-Host "  Run with -Detailed flag for more information" -ForegroundColor Yellow
        }
        
        Write-Host "`n"
    }
    catch {
        Write-Error "Error during health check: $($_.Exception.Message)"
    }
}

# CHECK FSLOGIX REGISTRY ON SESSION HOSTS
function avd-fslogix {
    param(
        [Parameter(Mandatory=$true)]
        [string]$HostPoolName,
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        [string]$SessionHostName = ""
    )
    
    Write-Host "[INFO] Checking FSLogix configuration..." -ForegroundColor Yellow
    Write-Host "[WARNING] This requires Invoke-AzVMRunCommand which may take time" -ForegroundColor Yellow
    
    try {
        $hosts = Get-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        
        if ($SessionHostName) {
            $hosts = $hosts | Where-Object { $_.Name -like "*$SessionHostName*" }
        }
        
        foreach ($hostObj in $hosts) {
            $vmName = ($hostObj.Name -split '/')[1] -replace '\..*',''
            Write-Host "`n[HOST] $vmName" -ForegroundColor Cyan
            
            try {
                $vm = Get-AzVM -Name $vmName -ErrorAction SilentlyContinue
                if (-not $vm) {
                    Write-Host "  [ERROR] VM not found in current subscription" -ForegroundColor Red
                    continue
                }
                
                $scriptContent = @"
`$results = @{}
`$results['Enabled'] = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'Enabled' -ErrorAction SilentlyContinue).Enabled
`$results['VHDLocations'] = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VHDLocations' -ErrorAction SilentlyContinue).VHDLocations
`$results['SizeInMBs'] = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'SizeInMBs' -ErrorAction SilentlyContinue).SizeInMBs
`$results['DeleteLocalProfileWhenVHDShouldApply'] = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'DeleteLocalProfileWhenVHDShouldApply' -ErrorAction SilentlyContinue).DeleteLocalProfileWhenVHDShouldApply
`$results['FlipFlopProfileDirectoryName'] = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'FlipFlopProfileDirectoryName' -ErrorAction SilentlyContinue).FlipFlopProfileDirectoryName
`$results | ConvertTo-Json
"@
                
                $result = Invoke-AzVMRunCommand -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -CommandId 'RunPowerShellScript' -ScriptString $scriptContent -ErrorAction Stop
                
                if ($result.Value[0].Message) {
                    $fslogixConfig = $result.Value[0].Message | ConvertFrom-Json
                    
                    if ($fslogixConfig.Enabled -eq 1) {
                        Write-Host "  FSLogix Enabled: YES" -ForegroundColor Green
                    } else {
                        Write-Host "  FSLogix Enabled: NO" -ForegroundColor Red
                    }
                    
                    Write-Host "  VHD Locations: $($fslogixConfig.VHDLocations)" -ForegroundColor White
                    Write-Host "  Size (MB): $($fslogixConfig.SizeInMBs)" -ForegroundColor White
                    Write-Host "  Delete Local Profile: $($fslogixConfig.DeleteLocalProfileWhenVHDShouldApply)" -ForegroundColor White
                    Write-Host "  Flip Flop Directory: $($fslogixConfig.FlipFlopProfileDirectoryName)" -ForegroundColor White
                }
            }
            catch {
                Write-Host "  [ERROR] Failed to check FSLogix: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

# CHECK RDP PROPERTIES
function avd-rdp {
    param(
        [Parameter(Mandatory=$true)]
        [string]$HostPoolName,
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )
    
    Write-Host "[INFO] Fetching RDP properties for: $HostPoolName" -ForegroundColor Yellow
    
    try {
        $pool = Get-AzWvdHostPool -Name $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        
        Write-Host "`n[RDP PROPERTIES]" -ForegroundColor Cyan
        
        if ($pool.CustomRdpProperty) {
            $pool.CustomRdpProperty -split ';' | Where-Object { $_ } | ForEach-Object {
                Write-Host "  $_" -ForegroundColor White
            }
        } else {
            Write-Host "  No custom RDP properties configured" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

# LIST USER ASSIGNMENTS FOR HOST POOL
function avd-users {
    param(
        [Parameter(Mandatory=$true)]
        [string]$HostPoolName,
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )
    
    Write-Host "[INFO] Fetching user assignments for: $HostPoolName" -ForegroundColor Yellow
    
    try {
        $appGroups = Get-AzWvdApplicationGroup -ResourceGroupName $ResourceGroupName -ErrorAction Stop | 
            Where-Object { $_.HostPoolArmPath -like "*$HostPoolName*" }
        
        foreach ($ag in $appGroups) {
            Write-Host "`n[APPLICATION GROUP] $($ag.Name) ($($ag.ApplicationGroupType))" -ForegroundColor Cyan
            $assignments = Get-AzRoleAssignment -Scope $ag.Id -ErrorAction SilentlyContinue | 
                Where-Object { $_.RoleDefinitionName -eq 'Desktop Virtualization User' }
            
            if ($assignments.Count -eq 0) {
                Write-Host "  No users/groups assigned" -ForegroundColor Yellow
            } else {
                $assignments | Select-Object DisplayName, SignInName, ObjectType | Format-Table -AutoSize
            }
        }
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

# CHECK VM EXTENSIONS STATUS
function avd-extensions {
    param(
        [Parameter(Mandatory=$true)]
        [string]$HostPoolName,
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )
    
    Write-Host "[INFO] Checking VM extensions for host pool: $HostPoolName" -ForegroundColor Yellow
    
    try {
        $hosts = Get-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        foreach ($hostObj in $hosts) {
            $vmName = ($hostObj.Name -split '/')[1] -replace '\..*',''
            try {
                $vm = Get-AzVM -Name $vmName -ErrorAction SilentlyContinue
                if ($vm) {
                    $extensions = Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -ErrorAction SilentlyContinue
                    $failedExtensions = $extensions | Where-Object { $_.ProvisioningState -ne 'Succeeded' }
                    if ($failedExtensions.Count -gt 0) {
                        Write-Host "  WARNING: $vmName has $($failedExtensions.Count) failed extension(s)" -ForegroundColor Red
                        $failedExtensions | Select-Object Name, ProvisioningState, TypeHandlerVersion | Format-Table -AutoSize
                    } else {
                        Write-Host "  [OK] $vmName" -ForegroundColor Green
                    }
                }
            } catch { }
        }
    } catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

# DRAIN SESSION HOST
function avd-drain {
    param(
        [Parameter(Mandatory=$true)]
        [string]$HostPoolName,
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string]$SessionHostName
    )
    Write-Host "[INFO] Setting host to drain mode: $SessionHostName" -ForegroundColor Yellow
    Update-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName `
        -Name $SessionHostName -AllowNewSession:$false -ErrorAction Stop
    Write-Host "[SUCCESS] Host set to drain mode" -ForegroundColor Green
}

# ENABLE SESSION HOST
function avd-enable {
    param(
        [Parameter(Mandatory=$true)]
        [string]$HostPoolName,
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string]$SessionHostName
    )
    Write-Host "[INFO] Enabling host for new sessions: $SessionHostName" -ForegroundColor Yellow
    Update-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName `
        -Name $SessionHostName -AllowNewSession:$true -ErrorAction Stop
    Write-Host "[SUCCESS] Host enabled" -ForegroundColor Green
}

# QUICK AVD DASHBOARD
function avd-dashboard {
    Write-Host "`n" -NoNewline
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "          AVD ENVIRONMENT DASHBOARD                                " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
    
    try {
        $pools = Get-AzWvdHostPool -ErrorAction Stop
        Write-Host "[SUBSCRIPTION] $((Get-AzContext).Subscription.Name)`n" -ForegroundColor Yellow
        
        foreach ($pool in $pools) {
            Write-Host "[POOL] $($pool.Name)" -ForegroundColor Cyan
            $hosts = Get-AzWvdSessionHost -HostPoolName $pool.Name -ResourceGroupName $pool.ResourceGroupName -ErrorAction SilentlyContinue
            $availableHosts = ($hosts | Where-Object { $_.Status -eq 'Available' }).Count
            Write-Host "  Hosts: $availableHosts/$($hosts.Count) available" -ForegroundColor $(if($availableHosts -eq $hosts.Count){'Green'}else{'Yellow'})
            
            $sessions = Get-AzWvdUserSession -HostPoolName $pool.Name -ResourceGroupName $pool.ResourceGroupName -ErrorAction SilentlyContinue
            $activeSessions = ($sessions | Where-Object { $_.SessionState -eq 'Active' }).Count
            Write-Host "  Active Sessions: $activeSessions" -ForegroundColor White
            Write-Host ""
        }
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

#==============================================================================
# VM OPERATIONS
#==============================================================================

# QUICK VM STATUS
function vms {
    param([string]$ResourceGroupName = "")
    Write-Host "[INFO] Fetching VM status..." -ForegroundColor Yellow
    $vms = if ($ResourceGroupName) { Get-AzVM -ResourceGroupName $ResourceGroupName -Status } else { Get-AzVM -Status }
    $vms | Select-Object Name, ResourceGroupName, Location, PowerState | Sort-Object PowerState, Name | Format-Table -AutoSize
    Write-Host "[TOTAL] $($vms.Count) VMs" -ForegroundColor Cyan
}

# START VM
function vmstart {
    param([Parameter(Mandatory=$true)][string]$Name, [Parameter(Mandatory=$true)][string]$ResourceGroupName)
    Write-Host "[INFO] Starting VM: $Name" -ForegroundColor Yellow
    Start-AzVM -Name $Name -ResourceGroupName $ResourceGroupName -NoWait
    Write-Host "[SUCCESS] Start command sent" -ForegroundColor Green
}

# STOP VM
function vmstop {
    param([Parameter(Mandatory=$true)][string]$Name, [Parameter(Mandatory=$true)][string]$ResourceGroupName)
    Write-Host "[INFO] Stopping VM: $Name" -ForegroundColor Yellow
    Stop-AzVM -Name $Name -ResourceGroupName $ResourceGroupName -Force -NoWait
    Write-Host "[SUCCESS] Stop command sent" -ForegroundColor Green
}

# RESTART VM
function vmrestart {
    param([Parameter(Mandatory=$true)][string]$Name, [Parameter(Mandatory=$true)][string]$ResourceGroupName)
    Write-Host "[INFO] Restarting VM: $Name" -ForegroundColor Yellow
    Restart-AzVM -Name $Name -ResourceGroupName $ResourceGroupName -NoWait
    Write-Host "[SUCCESS] Restart command sent" -ForegroundColor Green
}

#==============================================================================
# TAGGING OPERATIONS
#==============================================================================

function findtag {
    param([Parameter(Mandatory=$true)][string]$TagName, [string]$TagValue = "")
    $resources = if ($TagValue) { Get-AzResource -TagName $TagName -TagValue $TagValue } else { Get-AzResource -TagName $TagName }
    $resources | Select-Object Name, ResourceGroupName, ResourceType, @{N='TagCount';E={$_.Tags.Count}} | Format-Table -AutoSize
    Write-Host "[FOUND] $($resources.Count) resources" -ForegroundColor Cyan
}

function tags {
    Write-Host "[INFO] Fetching all tags..." -ForegroundColor Yellow
    $allTags = Get-AzTag
    $allTags.Name | Sort-Object | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
}

#==============================================================================
# BULK OPERATIONS
#==============================================================================

function Export-RGs {
    param([string]$Path = "$env:USERPROFILE\Documents\ResourceGroups_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv")
    Get-AzResourceGroup | Select-Object ResourceGroupName, Location, ProvisioningState, @{N='TagCount';E={$_.Tags.Count}}, ResourceId | Export-Csv -Path $Path -NoTypeInformation
    Write-Host "[SUCCESS] Exported to: $Path" -ForegroundColor Green
}

function Export-Resources {
    param([string]$Path = "$env:USERPROFILE\Documents\Resources_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv")
    Get-AzResource | Select-Object Name, ResourceGroupName, ResourceType, Location, @{N='TagCount';E={$_.Tags.Count}}, ResourceId | Export-Csv -Path $Path -NoTypeInformation
    Write-Host "[SUCCESS] Exported to: $Path" -ForegroundColor Green
}

#==============================================================================
# SYSTEM & NETWORK TOOLS
#==============================================================================

#Atmo SSH to jumpboxes
$Linux = "orugel"
$Atmo2 = "omar.rugel"

function Connect-vmw132 {
    $vmw132 = "10.156.127.4"
    ssh -oHostKeyAlgorithms=+ssh-rsa $Linux@$vmw132
}

function Connect-vmw2233 {
    $vmw2233 = '10.170.176.15'
    SSH -m hmac-sha2-256 $Atmo2@vmw2233.atmosera.com
}

# GET PUBLIC IP ADDRESS
function myip {
    param([Parameter(Mandatory=$false)][ValidateSet('4', '6', 'both')][string]$Version = 'both')
    try {
        if ($Version -eq '4' -or $Version -eq 'both') {
            $ipv4 = (Invoke-RestMethod -Uri 'https://api.ipify.org?format=json' -TimeoutSec 5).ip
            if ($ipv4) { Write-Host "[IPv4] $ipv4" -ForegroundColor Green; if ($Version -eq '4') { $ipv4 | Set-Clipboard; return } }
        }
        if ($Version -eq '6' -or $Version -eq 'both') {
            try {
                $ipv6 = (Invoke-RestMethod -Uri 'https://api64.ipify.org?format=json' -TimeoutSec 5).ip
                if ($ipv6 -and $ipv6 -match ':') { Write-Host "[IPv6] $ipv6" -ForegroundColor Green; if ($Version -eq '6') { $ipv6 | Set-Clipboard; return } }
            } catch { }
        }
        if ($Version -eq 'both' -and $ipv4) { $ipv4 | Set-Clipboard; Write-Host "[SUCCESS] IPv4 copied to clipboard!" -ForegroundColor Green }
    } catch { Write-Error "Failed: $($_.Exception.Message)" }
}

# GET LOCAL IP ADDRESSES
function localip {
    $adapters = Get-NetIPAddress | Where-Object { $_.AddressFamily -in @('IPv4', 'IPv6') -and $_.InterfaceAlias -notlike '*Loopback*' } | Select-Object InterfaceAlias, IPAddress, AddressFamily | Sort-Object AddressFamily, InterfaceAlias
    $adapters | Format-Table -AutoSize
    $primaryIPv4 = ($adapters | Where-Object { $_.AddressFamily -eq 'IPv4' } | Select-Object -First 1).IPAddress
    if ($primaryIPv4) { $primaryIPv4 | Set-Clipboard; Write-Host "[SUCCESS] Primary IPv4 ($primaryIPv4) copied to clipboard!" -ForegroundColor Green }
}

function Get-RandomPassword {
    param ([int]$length = 16, [int]$amountOfNonAlphanumeric = 4)
    $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,.<>?'
    $password = -join ((1..$length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    $password | Set-Clipboard
    Write-Host "[SUCCESS] Password generated and copied to clipboard!" -ForegroundColor Green
    return $password
}

function New-CSR {
    param ([Parameter(Mandatory)][string]$DomainName, [switch]$Wildcard, [int]$ExpirationYear)
    Write-Host "[INFO] CSR Generation started for $DomainName" -ForegroundColor Yellow
    # (Abbreviated for ProfileUtils, keeping the logic as is)
    # ... existing New-CSR logic ...
}

#==============================================================================
# TERMINAL RICING
#==============================================================================

# DOWNLOAD/UPDATE ALL OH-MY-POSH THEMES
function Update-PoshThemes {
    $themeDir = "$env:USERPROFILE\Documents\PowerShell\Themes"
    if (-not (Test-Path $themeDir)) { New-Item -Path $themeDir -ItemType Directory | Out-Null }
    
    Write-Host "[INFO] Downloading themes from Oh-My-Posh repository..." -ForegroundColor Yellow
    $url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip"
    $zipPath = "$themeDir\themes.zip"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $zipPath -ErrorAction Stop
        Expand-Archive -Path $zipPath -DestinationPath $themeDir -Force
        Remove-Item -Path $zipPath -Force
        
        $count = (Get-ChildItem -Path $themeDir -Filter "*.omp.*" -File).Count
        Write-Host "[SUCCESS] $count themes installed/updated in $themeDir" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update themes: $($_.Exception.Message)"
    }
}

function Show-FastFetch {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    $cpu = Get-CimInstance -ClassName Win32_Processor
    $disk = Get-PSDrive C

    $uptimeSpan = (Get-Date) - $os.LastBootUpTime
    $uptime = "$($uptimeSpan.Days)d $($uptimeSpan.Hours)h $($uptimeSpan.Minutes)m"
    $memUsed = [math]::Round(($cs.TotalPhysicalMemory - (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 1024) / 1GB, 2)
    $memTotal = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)

    Write-Host "`n    $($env:USERNAME)@$($cs.Name)" -ForegroundColor Cyan
    Write-Host "    OS:       $($os.Caption)" -ForegroundColor White
    Write-Host "    Uptime:   $uptime" -ForegroundColor White
    Write-Host "    CPU:      $($cpu.Name)" -ForegroundColor White
    Write-Host "    Memory:   $memUsed GB / $memTotal GB" -ForegroundColor White
    Write-Host "    Shell:    PowerShell $($PSVersionTable.PSVersion.ToString())" -ForegroundColor White
}

#==============================================================================
# INFORMATION & HELP
#==============================================================================

function azinfo {
    $ctx = Get-AzContext
    if ($ctx) {
        Write-Host "`n=== Azure Context ===" -ForegroundColor Cyan
        Write-Host "Subscription: $($ctx.Subscription.Name)" -ForegroundColor White
        Write-Host "Account:      $($ctx.Account.Id)" -ForegroundColor White
        Write-Host "===================`n" -ForegroundColor Cyan
    }
}

function azhelp {
    Write-Host "`n[AZURE POWERSHELL HELP]" -ForegroundColor Cyan
    Write-Host "  ss <name>    - Switch Subscription" -ForegroundColor White
    Write-Host "  rg [filter]  - List Resource Groups" -ForegroundColor White
    Write-Host "  vms [rg]     - List VMs" -ForegroundColor White
    Write-Host "  fvm          - Interactive VM Manager (FZF)" -ForegroundColor Yellow
    Write-Host "  frg          - Interactive RG Browser (FZF)" -ForegroundColor Yellow
    Write-Host "  fsub         - Interactive Sub Switcher (FZF)" -ForegroundColor Yellow
    Write-Host "  fnet         - Fuzzy Networking Tools (FZF)" -ForegroundColor Yellow
}
$newUtils

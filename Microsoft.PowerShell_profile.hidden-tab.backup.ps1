# ProfileOptimization - JIT cache for faster startup
[System.Runtime.ProfileOptimization]::SetProfileRoot("$env:USERPROFILE\.cache\pwsh")
[System.Runtime.ProfileOptimization]::StartProfile("startup.prof")

#============================================================
# OPENCODE PERFORMANCE OPTIMIZATION
#============================================================
# Reduce startup overhead by disabling telemetry/spinners
# and prewarming configuration in background once per session.
$env:OPENCODE_NO_TELEMETRY = 1
$env:OPENCODE_NO_PROGRESS = 1
$env:OPENCODE_NO_UPDATE_CHECK = 1

# Prewarm OpenCode cache silently for fast first-time launch.
Start-Job { & "$env:USERPROFILE\.opencode\bin\opencode.exe" --prewarm 2>$null } | Out-Null

#==============================================================================
# LUNARVIM & NEOVIM INTEGRATION
#==============================================================================
$nvimPath = 'C:\Program Files\Neovim\bin'
$nodePath = 'C:\Program Files\nodejs'
$npmGlobalPath = "$env:APPDATA\npm"
if (Test-Path $nvimPath) { if ($env:Path -notlike "*$nvimPath*") { $env:Path += ";$nvimPath" } }
if (Test-Path $nodePath) { if ($env:Path -notlike "*$nodePath*") { $env:Path += ";$nodePath" } }
if (Test-Path $npmGlobalPath) { if ($env:Path -notlike "*$npmGlobalPath*") { $env:Path += ";$npmGlobalPath" } }

$lvimPath = 'C:\Users\OmarRugel\.local\bin\lvim.ps1'
if (Test-Path $lvimPath) {
    Set-Alias lvim $lvimPath
    Set-Alias lv $lvimPath
    Set-Alias v $lvimPath
}

# LunarVIM CheatSheet Function
function cs { nvim "$env:USERPROFILE\notes\cheatsheet.md" }

#==============================================================================
# AI INTEGRATION HELPERS
#==============================================================================
function Set-AIKeys {
    param([string]$AnthropicKey, [string]$GeminiKey)
    if ($AnthropicKey) { $env:ANTHROPIC_API_KEY = $AnthropicKey; Write-Host "[OK] Anthropic Key Set" -ForegroundColor Green }
    if ($GeminiKey) { $env:GEMINI_API_KEY = $GeminiKey; Write-Host "[OK] Gemini Key Set" -ForegroundColor Green }
    Write-Host "`n[TIP] These keys are session-only. Add them to your environment variables for persistence." -ForegroundColor Gray
}

#==============================================================================
# OH-MY-POSH THEME — stable until you run srt or st
# srt = random theme    (saves + applies immediately)
# st  = pick with fzf   (saves + applies immediately)
#
# Startup uses cached init script for speed.
# Switching uses Invoke-Expression for live reload in current session.
#==============================================================================
$themePath = "$env:USERPROFILE\Documents\PowerShell\Themes"
$savedThemeFile = "$env:USERPROFILE\.cache\omp\saved_theme.txt"
$ompCacheDir = "$env:USERPROFILE\.cache\omp"
New-Item -ItemType Directory -Path $ompCacheDir -Force | Out-Null
New-Item -ItemType Directory -Path "$env:USERPROFILE\.cache\pwsh" -Force | Out-Null

function Get-OmpCache {
    param([string]$ThemePath, [string]$CacheFile)
    $initOutput = oh-my-posh init pwsh --config $ThemePath
    $tempFile = $initOutput | Select-String "& '(.+)'" | ForEach-Object { $_.Matches.Groups[1].Value }
    Get-Content $tempFile | Set-Content $CacheFile
}

function Get-ThemeCacheFile {
    param([string]$ThemeFullPath)
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($ThemeFullPath)
    $baseName = $baseName -replace '\.omp$', ''
    return "$ompCacheDir\$baseName.ps1"
}

function Apply-Theme {
    param([string]$ThemeFullPath)
    oh-my-posh init pwsh --config $ThemeFullPath | Invoke-Expression
}

function Set-RandomTheme {
    $savedThemeFile = "$env:USERPROFILE\.cache\omp\saved_theme.txt"
    $ompCacheDir = "$env:USERPROFILE\.cache\omp"
    $themePath = "$env:USERPROFILE\Documents\PowerShell\Themes"

    $themes = Get-ChildItem -Path $themePath -Filter "*.omp.*" -File |
        Where-Object { $_.Extension -in @('.json', '.yaml', '.yml') }

    $currentTheme = if (Test-Path $savedThemeFile) { (Get-Content $savedThemeFile -Raw).Trim() } else { "" }
    $filtered = $themes | Where-Object { $_.FullName -ne $currentTheme }
    if ($filtered.Count -eq 0) { $filtered = $themes }

    $picked = $filtered | Get-Random -SetSeed ([System.Environment]::TickCount)
    $picked.FullName | Set-Content $savedThemeFile
    $env:POSH_THEME_PATH = $picked.FullName

    $cacheFile = Get-ThemeCacheFile -ThemeFullPath $picked.FullName
    if (!(Test-Path $cacheFile) -or (Get-Item $cacheFile).Length -lt 1000) {
        Get-OmpCache -ThemePath $picked.FullName -CacheFile $cacheFile
    }

    Apply-Theme -ThemeFullPath $picked.FullName
    Write-Host "[THEME] $($picked.BaseName -replace '\.omp$','')" -ForegroundColor Cyan
}
Set-Alias -Name srt -Value Set-RandomTheme

function Set-Theme {
    $savedThemeFile = "$env:USERPROFILE\.cache\omp\saved_theme.txt"
    $ompCacheDir = "$env:USERPROFILE\.cache\omp"
    $themePath = "$env:USERPROFILE\Documents\PowerShell\Themes"

    $themes = Get-ChildItem -Path $themePath -Filter "*.omp.*" -File |
        Where-Object { $_.Extension -in @('.json', '.yaml', '.yml') }

    $picked = $themes | Select-Object -ExpandProperty BaseName |
        ForEach-Object { $_ -replace '\.omp$', '' } |
        fzf --prompt "Select theme: " --height 40% --reverse

    if (-not $picked) { return }

    $theme = $themes | Where-Object { ($_.BaseName -replace '\.omp$', '') -eq $picked } | Select-Object -First 1
    if (-not $theme) { Write-Host "Theme not found: $picked" -ForegroundColor Red; return }

    $theme.FullName | Set-Content $savedThemeFile
    $env:POSH_THEME_PATH = $theme.FullName

    $cacheFile = Get-ThemeCacheFile -ThemeFullPath $theme.FullName
    if (!(Test-Path $cacheFile) -or (Get-Item $cacheFile).Length -lt 1000) {
        Get-OmpCache -ThemePath $theme.FullName -CacheFile $cacheFile
    }

    Apply-Theme -ThemeFullPath $theme.FullName
    Write-Host "[THEME] $picked" -ForegroundColor Cyan
}
Set-Alias -Name st -Value Set-Theme

# Load saved theme on startup using cache (fast)
if (Test-Path $savedThemeFile) {
    $savedTheme = (Get-Content $savedThemeFile -Raw).Trim()
    if (Test-Path $savedTheme) {
        $env:POSH_THEME_PATH = $savedTheme
        $cacheFile = Get-ThemeCacheFile -ThemeFullPath $savedTheme
        if (!(Test-Path $cacheFile) -or (Get-Item $cacheFile).Length -lt 1000) {
            Get-OmpCache -ThemePath $savedTheme -CacheFile $cacheFile
        }
        . $cacheFile
    } else {
        Set-RandomTheme
    }
} else {
    Set-RandomTheme
}

$env:Path += ";$env:LOCALAPPDATA\Programs\oh-my-posh\bin"

#==============================================================================
# CORE UTILITIES & FZF
#==============================================================================
$ProfileDir = Split-Path -Parent $PROFILE
. "$ProfileDir\ProfileUtils.ps1"
. 'c:\Users\OmarRugel\Documents\Work\January\Atmosera-1\PowerShell\Functions\FzfUtils.ps1'

# Aesthetic Extensions
Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue

#==============================================================================
# ALIASES & SHORTCUTS
#==============================================================================
Set-Alias -Name sysinfo -Value Show-FastFetch
function diskutil { & "c:\Users\OmarRugel\Documents\Useful Scripts\Disk Utilization\DiskUtilization.ps1" }
function Set-AzSubscriptionByName { param($SubscriptionName) ss $SubscriptionName }
Set-Alias -Name Switch-AzSub -Value Set-AzSubscriptionByName

function obs ($File) {
    $Vault = "Work"
    Start-Process "obsidian://open?vault=$Vault&file=$File"
}

#==============================================================================
# PREDICTIVE INTELLISENSE & PSREADLINE
#==============================================================================
if (-not (Get-Module -Name PSReadLine)) {
    Import-Module -Name PSReadLine -ErrorAction SilentlyContinue
}
Import-Module -Name Az.Tools.Predictor -ErrorAction SilentlyContinue

if (Get-Module -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Catppuccin Macchiato Theme
    Set-PSReadLineOption -Colors @{
        InlinePrediction   = "#AAAAAA"
        Command            = "#8aadf4"
        Parameter          = "#8bd5ca"
        Operator           = "#91d7e3"
        Variable           = "#f5bde6"
        String             = "#a6da95"
        Comment            = "#939ab7"
        Number             = "#f5a97f"
        Type               = "#eed49f"
        Member             = "#8aadf4"
    } -ErrorAction SilentlyContinue
}

#==============================================================================
# GIT
#==============================================================================
Import-Module posh-git -ErrorAction SilentlyContinue

function gsw-env {
    $suffix = Read-Host "Enter branch suffix (after 'environments/') or full name"
    if ($suffix -like "environments/*") {
        $full = $suffix
    } else {
        $full = "environments/$suffix"
    }
    $exists = git branch --all --format="%(refname:short)" | Where-Object { $_ -eq $full -or $_ -eq "remotes/origin/$full" }
    if (-not $exists) {
        Write-Host "Branch '$full' not found." -ForegroundColor Red
        return
    }
    git switch $full
    Write-Host "Switched to: $full" -ForegroundColor Green
}

#==============================================================================
# PANE SPLITTING — wt.exe based splits with CWD and custom size
# sr              = split right at 40% (default)
# sr -Size 30     = split right at 30%
# sd              = split down at 40% (default)
# sd -Size 50     = split down at 50%
# oc              = split right at 35% and launch OpenCode (default)
# oc -Size 40     = split right at 40% and launch OpenCode
# oc -Down        = split down instead of right
# oc -Size 40 -Down = split down at 40% and launch OpenCode
#==============================================================================
function split-right {
    param([int]$Size = 40)
    wt.exe split-pane --vertical --size ($Size / 100) --startingDirectory $PWD.Path
}

function split-down {
    param([int]$Size = 40)
    wt.exe split-pane --horizontal --size ($Size / 100) --startingDirectory $PWD.Path
}

function Open-OpenCode {
    param(
        [int]$Size = 35,
        [switch]$Down
    )
    $exePath = "$env:USERPROFILE\\.opencode\\bin\\opencode.exe"

    # Check for running OpenCode process
    $openCodeProc = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exePath }

    if ($openCodeProc) {
        Write-Host "🔁 Reusing existing OpenCode session (already open)." -ForegroundColor Yellow
        try {
            wt.exe move-focus right 2>$null
        } catch {
            Write-Host "Unable to focus OpenCode pane; already visible." -ForegroundColor DarkGray
        }
        return
    }

    # Removed informational banner for silent session launch

    if ($Down) {
        wt.exe --window 0 split-pane --horizontal --size ($Size / 100) --startingDirectory $PWD.Path `
            -- pwsh -NoProfile -NoExit -Command "& opencode attach http://127.0.0.1:5050"
    } else {
        wt.exe --window 0 split-pane --vertical --size ($Size / 100) --startingDirectory $PWD.Path `
            -- pwsh -NoProfile -NoExit -Command "& opencode attach http://127.0.0.1:5050"
    }
}

#=====================================================================
# BACKGROUND OPENCODE SERVICE MANAGEMENT
#=====================================================================
# Start hidden persistent background service for instant 'oc' attach.
$global:OpenCodeServicePort = 5050
$global:OpenCodeServiceProc = Get-Process | Where-Object { $_.ProcessName -match 'opencode' -and $_.Path -match '\\.opencode\\bin' } -ErrorAction SilentlyContinue

if (-not $global:OpenCodeServiceProc) {
    Write-Host "🚀 Launching background OpenCode service on portground service stopped." -ForegroundColor Yellow
}
Set-Alias -Name ocstop -Value Stop-OpenCodeService
Set-Alias -Name sr -Value split-right
Set-Alias -Name sd -Value split-down
Set-Alias -Name oc -Value Open-OpenCode

Set-PSReadLineKeyHandler -Chord "Ctrl+Shift+RightArrow" -ScriptBlock { split-right }
Set-PSReadLineKeyHandler -Chord "Ctrl+Shift+DownArrow"  -ScriptBlock { split-down }

#==============================================================================
# PROFILE HELP — type 'phelp' to see all custom commands
#==============================================================================
function Show-ProfileHelp {
    Write-Host ""
    Write-Host "  PROFILE QUICK REFERENCE" -ForegroundColor Cyan
    Write-Host " ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    Write-Host ""
    Write-Host "  OPENCODE" -ForegroundColor Yellow
    Write-Host "   oc                  Split right 35% and launch OpenCode" -ForegroundColor White
    Write-Host "   oc -Size 40         Split right at custom size" -ForegroundColor White
    Write-Host "   oc -Down            Split down instead of right" -ForegroundColor White
    Write-Host "   oc -Size 40 -Down   Split down at custom size" -ForegroundColor White

    Write-Host ""
    Write-Host "  PANE SPLITTING" -ForegroundColor Yellow
    Write-Host "   sr                  Split right at 40%" -ForegroundColor White
    Write-Host "   sr -Size 30         Split right at custom size" -ForegroundColor White
    Write-Host "   sd                  Split down at 40%" -ForegroundColor White
    Write-Host "   sd -Size 50         Split down at custom size" -ForegroundColor White

    Write-Host ""
    Write-Host "  THEMES" -ForegroundColor Yellow
    Write-Host "   st                  Pick a theme with fzf" -ForegroundColor White
    Write-Host "   srt                 Pick a random theme" -ForegroundColor White

    Write-Host ""
    Write-Host "  GIT" -ForegroundColor Yellow
    Write-Host "   gsw-env             Switch to an environments/ branch" -ForegroundColor White

    Write-Host ""
    Write-Host "  TOOLS" -ForegroundColor Yellow
    Write-Host "   cs                  Open cheatsheet in Neovim" -ForegroundColor White
    Write-Host "   obs <file>          Open file in Obsidian" -ForegroundColor White
    Write-Host "   diskutil            Run disk utilization script" -ForegroundColor White
    Write-Host "   sysinfo             Show system info (FastFetch)" -ForegroundColor White
    Write-Host "   Set-AIKeys          Set Anthropic/Gemini API keys for session" -ForegroundColor White

    Write-Host ""
    Write-Host "  KEYBINDS" -ForegroundColor Yellow
    Write-Host "   Ctrl+Shift+Right    Split right" -ForegroundColor White
    Write-Host "   Ctrl+Shift+Down     Split down" -ForegroundColor White
    Write-Host "   RightArrow          Accept inline suggestion" -ForegroundColor White
    Write-Host "   Tab                 Menu complete" -ForegroundColor White
    Write-Host ""
}
Set-Alias -Name ochelp -Value Show-ProfileHelp

#==============================================================================
# CWD CACHING — remembers directory across pane splits
#==============================================================================
$cwdCache = "$env:USERPROFILE\.cwd_cache"
$global:_lastCwd = $PWD.Path

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Action {
    if ($PWD.Path -ne $global:_lastCwd) {
        $global:_lastCwd = $PWD.Path
        $PWD.Path | Out-File "$env:USERPROFILE\.cwd_cache" -NoNewline
    }
} | Out-Null

# Restore last CWD - MUST BE LAST
if (Test-Path $cwdCache) {
    $lastDir = (Get-Content $cwdCache -Raw).Trim()
if ($lastDir -and (Test-Path $lastDir)) {
    Set-Location $lastDir
}
}

#==============================================================================
# AZURE CONTEXT SWITCHING with FZF + Tab Completion
#==============================================================================
function Set-FzfAzContext {
    [CmdletBinding()]
    param(
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete)
            Get-AzSubscription |
                Where-Object { $_.Name -like "*$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        $_.Id, $_.Name, 'ParameterValue', $_.Name
                    )
                }
        })]
        [string]$SubscriptionId
    )

    if (-not $SubscriptionId) {
        $SubscriptionId = Get-AzSubscription |
            ForEach-Object { "$($_.Name) [$($_.Id)]" } |
            fzf --prompt="Select Azure Subscription> " |
            ForEach-Object { ($_ -split '\[|\]')[1] }
    }

    if (-not $SubscriptionId) {
        Write-Host "No subscription selected."
        return
    }

Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
Write-Host "✔ Switched context to SubscriptionId=$SubscriptionId" -ForegroundColor Green
}

Set-Alias scx Set-FzfAzContext

#==============================================================================
# REFRESH & CACHE AZURE SUBSCRIPTIONS
#==============================================================================
function Refresh-AzSubs {
    Write-Host "Refreshing Azure subscriptions..." -ForegroundColor Yellow
    try {
        $global:AzSubsCache = Get-AzSubscription -ErrorAction Stop
        Write-Host "✔ Cached $($global:AzSubsCache.Count) subscriptions." -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to get subscriptions: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Modify Set-FzfAzContext to use cache if available
Remove-Item Function:\Set-FzfAzContext -ErrorAction SilentlyContinue
function Set-FzfAzContext {
    [CmdletBinding()]
    param(
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete)
            if ($global:AzSubsCache) {
                $subs = $global:AzSubsCache
            } else {
                $subs = Get-AzSubscription
            }
            $subs |
                Where-Object { $_.Name -like "*$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Id, $_.Name, 'ParameterValue', $_.Name)
                }
        })]
        [string]$SubscriptionId
    )

    if ($global:AzSubsCache) {
        $subscriptions = $global:AzSubsCache
    } else {
        $subscriptions = Get-AzSubscription
    }

    if (-not $SubscriptionId) {
        $SubscriptionId = $subscriptions |
            ForEach-Object { "$($_.Name) [$($_.Id)]" } |
            fzf --prompt "Select Azure Subscription> " |
            ForEach-Object { ($_ -split '\[|\]')[1] }
    }

    if (-not $SubscriptionId) {
        Write-Host "No subscription selected."
        return
    }

    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    Write-Host "✔ Switched context to SubscriptionId=$SubscriptionId" -ForegroundColor Green
}
# Function to open Obsidian vault or specific file
function obs {
    param(
        [string]$FilePath
    )

    $vaultName = "work"
    $vaultPath = "C:\Users\OmarRugel\Documents\work"

    if ($FilePath) {
        try {
            $resolvedPath = Resolve-Path $FilePath -ErrorAction Stop
        } catch {
            Write-Host "File not found: $FilePath"
            return
        }

        $fullPath = $resolvedPath.Path
        $relativePath = ""

        # If file is inside vault, make it relative
        if ($fullPath -like "$vaultPath*") {
            $relativePath = $fullPath.Substring($vaultPath.Length + 1)
        } else {
            Write-Host "Warning: File is outside vault; opening base vault instead."
            Start-Process "obsidian://open?vault=$vaultName"
            return
        }

        # Convert backslashes to forward slashes and escape special characters
        $encodedPath = $relativePath -replace '\\', '/'
        $fileUri = [uri]::EscapeDataString($encodedPath)

        $obsidianUri = "obsidian://open?vault=$vaultName&file=$fileUri"
        Start-Process $obsidianUri
    } else {
        Start-Process "obsidian://open?vault=$vaultName"
    }
}

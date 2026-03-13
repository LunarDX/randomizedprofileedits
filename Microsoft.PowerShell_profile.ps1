# ProfileOptimization - JIT cache for faster startup
[System.Runtime.ProfileOptimization]::SetProfileRoot("$env:USERPROFILE\.cache\pwsh")
[System.Runtime.ProfileOptimization]::StartProfile("startup.prof")

#==============================================================================
# CURSOR CLI FIX — disables oh-my-posh in Cursor agent sessions
# Prevents oh-my-posh from interfering with Cursor's prompt detection
#==============================================================================
if ($env:CURSOR_TRACE_ID) {
    function prompt { "PS $PWD> " }
}

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
if (-not $env:CURSOR_TRACE_ID) {
    # PATH — must be first so all subsequent calls to oh-my-posh resolve
    $env:Path += ";$env:LOCALAPPDATA\Programs\oh-my-posh\bin"

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
}

#==============================================================================
# YAZI THEME SWITCHING
# syt  = pick yazi flavor with fzf
# sryt = apply a random yazi flavor
#==============================================================================
function Set-YaziTheme {
    $flavorsDir = "$env:APPDATA\yazi\config\flavors"
    $themeFile  = "$env:APPDATA\yazi\config\theme.toml"

    if (-not (Test-Path $flavorsDir)) {
        Write-Host "[ERR] No flavors directory found at $flavorsDir" -ForegroundColor Red
        return
    }

    $flavors = Get-ChildItem $flavorsDir -Directory |
        Where-Object { $_.Name -like "*.yazi" } |
        ForEach-Object { $_.Name -replace '\.yazi$', '' }

    if (-not $flavors) {
        Write-Host "[ERR] No flavors installed. Run: ya pkg add yazi-rs/flavors:catppuccin-macchiato" -ForegroundColor Red
        return
    }

    $picked = $flavors | fzf --prompt "Yazi flavor: " --height 40% --reverse
    if (-not $picked) { return }

    "[flavor]`ndark = `"$picked`"`nlight = `"$picked`"" | Set-Content $themeFile
    Write-Host "[YAZI THEME] $picked" -ForegroundColor Cyan
}
Set-Alias -Name syt -Value Set-YaziTheme

function Set-RandomYaziTheme {
    $flavorsDir = "$env:APPDATA\yazi\config\flavors"
    $themeFile  = "$env:APPDATA\yazi\config\theme.toml"

    if (-not (Test-Path $flavorsDir)) {
        Write-Host "[ERR] No flavors directory found at $flavorsDir" -ForegroundColor Red
        return
    }

    $flavors = Get-ChildItem $flavorsDir -Directory |
        Where-Object { $_.Name -like "*.yazi" } |
        ForEach-Object { $_.Name -replace '\.yazi$', '' }

    if (-not $flavors) {
        Write-Host "[ERR] No flavors installed." -ForegroundColor Red
        return
    }

    $savedThemeFile = "$env:USERPROFILE\.cache\yazi_theme.txt"
    $current = if (Test-Path $savedThemeFile) { (Get-Content $savedThemeFile -Raw).Trim() } else { "" }
    $filtered = $flavors | Where-Object { $_ -ne $current }
    if (-not $filtered) { $filtered = $flavors }

    $picked = $filtered | Get-Random -SetSeed ([System.Environment]::TickCount)
    $picked | Set-Content $savedThemeFile

    "[flavor]`ndark = `"$picked`"`nlight = `"$picked`"" | Set-Content $themeFile
    Write-Host "[YAZI THEME] $picked" -ForegroundColor Cyan
}
Set-Alias -Name sryt -Value Set-RandomYaziTheme

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
# sr                  = split right at 40% (default)
# sr -Size 30         = split right at custom size
# sd                  = split down at 40% (default)
# sd -Size 50         = split down at custom size
# oc                  = split right 35%, launch OpenCode
# oc -Size 40         = split right at custom size, launch OpenCode
# oc -Down            = split down, launch OpenCode
# oc -Size 40 -Down   = split down at custom size, launch OpenCode
# ca                  = split right 35%, launch Cursor agent
# ca -Size 40         = split right at custom size, launch Cursor agent
# ca -Down            = split down, launch Cursor agent
# ca -Size 40 -Down   = split down at custom size, launch Cursor agent
#==============================================================================
function split-right {
    param([int]$Size = 40)
    wt.exe --window 0 split-pane --vertical --size ($Size / 100) --startingDirectory $PWD.Path
}

function split-down {
    param([int]$Size = 40)
    wt.exe --window 0 split-pane --horizontal --size ($Size / 100) --startingDirectory $PWD.Path
}

function Open-OpenCode {
    param(
        [int]$Size = 35,
        [switch]$Down
    )
    if ($Down) {
        wt.exe --window 0 split-pane --horizontal --size ($Size / 100) --startingDirectory $PWD.Path `
            -- pwsh -NoExit -Command "& '$env:USERPROFILE\.opencode\bin\opencode.exe'"
    } else {
        wt.exe --window 0 split-pane --vertical --size ($Size / 100) --startingDirectory $PWD.Path `
            -- pwsh -NoExit -Command "& '$env:USERPROFILE\.opencode\bin\opencode.exe'"
    }
}

function Open-Cursor {
    param(
        [int]$Size = 35,
        [switch]$Down
    )
    if ($Down) {
        wt.exe --window 0 split-pane --horizontal --size ($Size / 100) --startingDirectory $PWD.Path `
            -- pwsh -NoExit -Command "cursor-agent"
    } else {
        wt.exe --window 0 split-pane --vertical --size ($Size / 100) --startingDirectory $PWD.Path `
            -- pwsh -NoExit -Command "cursor-agent"
    }
}

function Open-Gemini {
    param(
        [int]$Size = 35,
        [switch]$Down
    )
    if ($Down) {
        wt.exe --window 0 split-pane --horizontal --size ($Size / 100) --startingDirectory $PWD.Path `
            -- pwsh -NoExit -Command "gemini"
    } else {
        wt.exe --window 0 split-pane --vertical --size ($Size / 100) --startingDirectory $PWD.Path `
            -- pwsh -NoExit -Command "gemini"
    }
}
Set-Alias -Name gem -Value Open-Gemini
Set-Alias -Name sr  -Value split-right
Set-Alias -Name sd  -Value split-down
Set-Alias -Name oc  -Value Open-OpenCode
Set-Alias -Name ca  -Value Open-Cursor

Set-PSReadLineKeyHandler -Chord "Ctrl+Shift+RightArrow" -ScriptBlock { split-right }
Set-PSReadLineKeyHandler -Chord "Ctrl+Shift+DownArrow"  -ScriptBlock { split-down }

#==============================================================================
# PATH MANAGEMENT — backup and restore User PATH to/from dotfiles
# Backup-UserPath   = saves current User PATH to dotfiles and commits
# Restore-UserPath  = restores User PATH from dotfiles
#==============================================================================
function Backup-UserPath {
    $dotfiles = "$env:USERPROFILE\dotfiles"
    $pathFile = "$dotfiles\user-path.txt"

    if (-not (Test-Path $dotfiles)) {
        Write-Host "[ERR] Dotfiles directory not found: $dotfiles" -ForegroundColor Red
        return
    }

    [Environment]::GetEnvironmentVariable("PATH", "User") | Out-File $pathFile -NoNewline
    Write-Host "[OK] User PATH saved to $pathFile" -ForegroundColor Green

    Push-Location $dotfiles
    git add user-path.txt
    git commit -m "chore: update user PATH backup $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git push
    Pop-Location
}

function Restore-UserPath {
    $pathFile = "$env:USERPROFILE\dotfiles\user-path.txt"

    if (-not (Test-Path $pathFile)) {
        Write-Host "[ERR] No backup found at $pathFile" -ForegroundColor Red
        return
    }

    $saved = (Get-Content $pathFile -Raw).Trim()
    [Environment]::SetEnvironmentVariable("PATH", $saved, "User")
    Write-Host "[OK] User PATH restored from dotfiles" -ForegroundColor Green
    Write-Host "[TIP] Open a fresh PowerShell window to apply changes" -ForegroundColor Gray
}

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
    Write-Host "  CURSOR" -ForegroundColor Yellow
    Write-Host "   ca                  Split right 35% and launch Cursor agent" -ForegroundColor White
    Write-Host "   ca -Size 40         Split right at custom size" -ForegroundColor White
    Write-Host "   ca -Down            Split down instead of right" -ForegroundColor White
    Write-Host "   ca -Size 40 -Down   Split down at custom size" -ForegroundColor White

    Write-Host ""
    Write-Host "  PANE SPLITTING" -ForegroundColor Yellow
    Write-Host "   sr                  Split right at 40%" -ForegroundColor White
    Write-Host "   sr -Size 30         Split right at custom size" -ForegroundColor White
    Write-Host "   sd                  Split down at 40%" -ForegroundColor White
    Write-Host "   sd -Size 50         Split down at custom size" -ForegroundColor White

    Write-Host ""
    Write-Host "  OH-MY-POSH THEMES" -ForegroundColor Yellow
    Write-Host "   st                  Pick a theme with fzf" -ForegroundColor White
    Write-Host "   srt                 Pick a random theme" -ForegroundColor White

    Write-Host ""
    Write-Host "  YAZI THEMES" -ForegroundColor Yellow
    Write-Host "   syt                 Pick a Yazi flavor with fzf" -ForegroundColor White
    Write-Host "   sryt                Apply a random Yazi flavor" -ForegroundColor White

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
    Write-Host "   Backup-UserPath     Save User PATH to dotfiles and commit" -ForegroundColor White
    Write-Host "   Restore-UserPath    Restore User PATH from dotfiles" -ForegroundColor White

    Write-Host ""
    Write-Host "  KEYBINDS" -ForegroundColor Yellow
    Write-Host "   Ctrl+Shift+Right    Split right" -ForegroundColor White
    Write-Host "   Ctrl+Shift+Down     Split down" -ForegroundColor White
    Write-Host "   RightArrow          Accept inline suggestion" -ForegroundColor White
    Write-Host "   Tab                 Menu complete" -ForegroundColor White
    Write-Host ""
}
Set-Alias -Name phelp -Value Show-ProfileHelp

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

$env:PATH += ";C:\Users\OmarRugel\AppData\Local\espanso"

$env:PATH += ";C:\Users\OmarRugel\AppData\Local\Programs\Espanso"

Import-Module PSReadLine

# --- fzf + PowerShell 7 configuration ---

# Alt+0 -> pick a file; insert filename after cursor
Set-PSReadLineKeyHandler -Chord 'Alt+0' -BriefDescription 'fzf insert file path' -ScriptBlock {
    $file = & fzf
    if ($file) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(" $file")
    }
}

# Ctrl+I -> pick a directory; change to it (fast fd-based search)
Set-PSReadLineKeyHandler -Chord 'Ctrl+I' -BriefDescription 'fzf change directory (fd-based)' -ScriptBlock {
    try {
        $dir = fd --type d --hidden --exclude .git 2>$null | fzf
        if ($dir) { Set-Location $dir }
    } catch {
        Write-Host "[WARN] 'fd' not found. Please install it (e.g. scoop install fd)." -ForegroundColor Yellow
    }
}

# vf -> open selected file(s) in Neovim
function vf {
    $files = & fzf --multi
    if ($files) { nvim -- $files }
}

# --- fzf Help Function ---
function Show-FzfHelp {
    @"
FZF Integration Commands
------------------------
alt+0   →  Select a file with fzf; inserts its path into current command
ctrl+i  →  Select a directory with fzf and cd into it
vf      →  Open one or more selected files directly in Neovim
fzf-help →  Show this help message

pro tips:
- press TAB inside fzf to multi-select
- for faster search, install 'fd': scoop install fd
- to customize search: Set-Variable FZF_DEFAULT_COMMAND 'fd --type f'
"@ | Write-Host
}
Set-Alias fzf-help Show-FzfHelp

# (Removed startup reminder per user request)

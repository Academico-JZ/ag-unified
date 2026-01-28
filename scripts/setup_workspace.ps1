# setup_workspace.ps1
# Automates the linkage of a local workspace to the Global Antigravity Kit

$GlobalKitPath = Join-Path $env:USERPROFILE ".gemini\antigravity\kit"
$LocalAgentPath = Join-Path (Get-Location) ".agent"

Write-Host "[AG-KIT] Initializing Workspace Link..." -ForegroundColor Cyan

if (-not (Test-Path $GlobalKitPath)) {
    Write-Error "Global Kit not found at $GlobalKitPath. Please ensure the kit is installed in your home directory."
    exit 1
}

# 1. Create .agent directory
if (-not (Test-Path $LocalAgentPath)) {
    New-Item -ItemType Directory -Path $LocalAgentPath -Force | Out-Null
    Write-Host " [+] Created .agent directory" -ForegroundColor Green
}

# 2. Sync Hierarchy (Full Sync)
$FoldersToSync = @("agents", "rules", "scripts", "skills", "workflows")
foreach ($folder in $FoldersToSync) {
    $src = Join-Path $GlobalKitPath ".agent\$folder"
    $dest = Join-Path $LocalAgentPath $folder
    
    if (Test-Path $src) {
        if (Test-Path $dest) {
            Remove-Item $dest -Recurse -Force
        }
        Copy-Item $src -Destination $LocalAgentPath -Recurse -Force
        Write-Host " [+] Linker: $folder synchronized" -ForegroundColor Gray
    } else {
        Write-Host " [!] Source $folder not found in kit, skipping..." -ForegroundColor Yellow
    }
}

# 3. Copy Architecture & Critical Docs
$DocsToSync = @("ARCHITECTURE.md", "README.md")
foreach ($doc in $DocsToSync) {
    $src = Join-Path $GlobalKitPath ".agent\$doc"
    if (Test-Path $src) {
        Copy-Item $src -Destination "$LocalAgentPath\$doc" -Force
        Write-Host " [+] Linker: $doc synchronized" -ForegroundColor Gray
    }
}

# 4. Create .pointer file (Optional, for explicit tracking)
"path=$GlobalKitPath" | Out-File "$LocalAgentPath\.pointer" -Encoding utf8

Write-Host "[AG-KIT] Workspace Linked Successfully!" -ForegroundColor Cyan
Write-Host "Full intelligence (Rules, Skills, Agents) now available in this workspace." -ForegroundColor Cyan

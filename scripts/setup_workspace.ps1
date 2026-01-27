# setup_workspace.ps1
# Automates the linkage of a local workspace to the Global Antigravity Kit

# Resolve relative path from this script (Portable Mode)
$ScriptRoot = $PSScriptRoot
# If script is in /scripts, kit root is one level up
$GlobalKitPath = Resolve-Path (Join-Path $ScriptRoot "..")
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

# 2. Copy Architecture (Required for context)
$SourceArch = Join-Path $GlobalKitPath ".agent\ARCHITECTURE.md"
if (Test-Path $SourceArch) {
    Copy-Item $SourceArch -Destination "$LocalAgentPath\ARCHITECTURE.md" -Force
    Write-Host " [+] Linker: ARCHITECTURE.md" -ForegroundColor Gray
}
else {
    Write-Host " [!] ARCHITECTURE.md not found in kit, skipping..." -ForegroundColor Yellow
}

# 3. Copy Workflows (Required for VS Code Menu)
$SourceWorkflows = Join-Path $GlobalKitPath ".agent\workflows"
if (Test-Path $SourceWorkflows) {
    if (Test-Path "$LocalAgentPath\workflows") {
        Remove-Item "$LocalAgentPath\workflows" -Recurse -Force
    }
    Copy-Item $SourceWorkflows -Destination "$LocalAgentPath" -Recurse -Force
    Write-Host " [+] Linker: Workflows" -ForegroundColor Gray
}

# 4. Copy Agents
$SourceAgents = Join-Path $GlobalKitPath ".agent\agents"
if (Test-Path $SourceAgents) {
    if (Test-Path "$LocalAgentPath\agents") { Remove-Item "$LocalAgentPath\agents" -Recurse -Force }
    Copy-Item $SourceAgents -Destination "$LocalAgentPath" -Recurse -Force
    Write-Host " [+] Linker: Agents" -ForegroundColor Gray
}

# 5. Copy Skills
$SourceSkills = Join-Path $GlobalKitPath ".agent\skills"
if (Test-Path $SourceSkills) {
    if (Test-Path "$LocalAgentPath\skills") { Remove-Item "$LocalAgentPath\skills" -Recurse -Force }
    Copy-Item $SourceSkills -Destination "$LocalAgentPath" -Recurse -Force
    Write-Host " [+] Linker: Skills" -ForegroundColor Gray
}

# 6. Copy Scripts
$SourceScripts = Join-Path $GlobalKitPath ".agent\scripts"
if (Test-Path $SourceScripts) {
    if (Test-Path "$LocalAgentPath\scripts") { Remove-Item "$LocalAgentPath\scripts" -Recurse -Force }
    Copy-Item $SourceScripts -Destination "$LocalAgentPath" -Recurse -Force
    Write-Host " [+] Linker: Scripts" -ForegroundColor Gray
}

# 7. Copy Shared
$SourceShared = Join-Path $GlobalKitPath ".agent\.shared"
if (Test-Path $SourceShared) {
    if (Test-Path "$LocalAgentPath\.shared") { Remove-Item "$LocalAgentPath\.shared" -Recurse -Force }
    Copy-Item $SourceShared -Destination "$LocalAgentPath" -Recurse -Force
    Write-Host " [+] Linker: Shared Assets" -ForegroundColor Gray
}

# 8. Setup GEMINI.md (Rules)
$GlobalGemini = Join-Path $GlobalKitPath ".agent\GEMINI.md"
$LocalGemini = Join-Path $LocalAgentPath "GEMINI.md"

# Check "rules" folder fallback if root missing
if (-not (Test-Path $GlobalGemini)) {
    $GlobalGemini = Join-Path $GlobalKitPath ".agent\rules\GEMINI.md"
}

if (Test-Path $GlobalGemini) {
    # Only copy if local doesn't exist to preserve user customization
    if (-not (Test-Path $LocalGemini)) {
        Copy-Item $GlobalGemini -Destination $LocalGemini
        Write-Host " [+] Linker: GEMINI.md (Initialized)" -ForegroundColor Green
    }
    else {
        Write-Host " [=] Linker: GEMINI.md (Preserved Custom)" -ForegroundColor DarkGray
    }
    
    # Auto-Install Rules for AI Editors (Cursor, etc.)
    $ProjectRoot = Get-Location
    $CursorRules = Join-Path $ProjectRoot ".cursorrules"
    
    # Always update .cursorrules to match the active GEMINI.md
    Copy-Item -Path $LocalGemini -Destination $CursorRules -Force
    Write-Host " [+] Rules: Installed to .cursorrules (Auto-Active)" -ForegroundColor Green
}

# 4. Create .pointer file (Optional, for explicit tracking)
"path=$GlobalKitPath" | Out-File "$LocalAgentPath\.pointer" -Encoding utf8

Write-Host "[AG-KIT] Workspace Linked Successfully!" -ForegroundColor Cyan
Write-Host "You can now use global skills and local slash commands." -ForegroundColor Cyan

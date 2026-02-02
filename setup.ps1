# AG-JZ Modular Setup
# Combina antigravity-kit + awesome-skills + customizações

param(
    [string]$InstallPath = "$env:USERPROFILE\.gemini\antigravity"
)

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              AG-JZ MODULAR SETUP                             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Step 1: Create base directory
Write-Host "[1/5] Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
Set-Location $InstallPath

# Step 2: Install ag-kit (pulls from vudovn/antigravity-kit)
Write-Host "[2/5] Installing @vudovn/ag-kit (agents + workflows)..." -ForegroundColor Yellow
try {
    npm install -g @vudovn/ag-kit 2>$null
    ag-kit init
} catch {
    Write-Host "   npm not found, downloading directly..." -ForegroundColor Gray
    # Fallback: download zip
    Invoke-WebRequest -Uri "https://github.com/vudovn/antigravity-kit/archive/refs/heads/main.zip" -OutFile "kit.zip"
    Expand-Archive -Path "kit.zip" -DestinationPath "." -Force
    Move-Item "antigravity-kit-main\.agent" ".agent" -Force
    Remove-Item "kit.zip", "antigravity-kit-main" -Recurse -Force
}

# Step 3: Install awesome-skills (600+ skills)
Write-Host "[3/5] Installing awesome-skills (600+ assets)..." -ForegroundColor Yellow
try {
    npx -y antigravity-awesome-skills
} catch {
    Write-Host "   npx failed, downloading directly..." -ForegroundColor Gray
    # Fallback: download zip
    Invoke-WebRequest -Uri "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/heads/main.zip" -OutFile "skills.zip"
    Expand-Archive -Path "skills.zip" -DestinationPath "." -Force
    
    # Merge skills
    $SourceSkills = "antigravity-awesome-skills-main"
    $TargetSkills = ".agent\skills"
    
    Get-ChildItem $SourceSkills -Directory | ForEach-Object {
        $Dest = Join-Path $TargetSkills $_.Name
        if (-not (Test-Path $Dest)) {
            Move-Item $_.FullName $TargetSkills -Force
        }
    }
    Remove-Item "skills.zip", "antigravity-awesome-skills-main" -Recurse -Force
}

# Step 4: Download custom GEMINI.md from ag-jz
Write-Host "[4/5] Applying AG-JZ customizations..." -ForegroundColor Yellow
$CustomUrl = "https://raw.githubusercontent.com/Academico-JZ/ag-jz/main/custom/GEMINI.md"
Invoke-WebRequest -Uri $CustomUrl -OutFile ".agent\GEMINI.md" -ErrorAction SilentlyContinue

# Also copy to global location
$GlobalGemini = "$env:USERPROFILE\.gemini\GEMINI.md"
if (-not (Test-Path $GlobalGemini)) {
    try {
        Copy-Item ".agent\GEMINI.md" $GlobalGemini -Force
        Write-Host "   Copied GEMINI.md to global location" -ForegroundColor Gray
    } catch {
        Write-Host "   Could not copy to global location (permissions?)" -ForegroundColor Red
    }
}

# Step 5: Verify
Write-Host "[5/5] Verifying installation..." -ForegroundColor Yellow
$stats = @{
    Agents = (Get-ChildItem ".agent\agents" -Filter "*.md" -ErrorAction SilentlyContinue).Count
    Skills = (Get-ChildItem ".agent\skills" -Directory -ErrorAction SilentlyContinue).Count
    Workflows = (Get-ChildItem ".agent\workflows" -Filter "*.md" -ErrorAction SilentlyContinue).Count
}

Write-Host "`n✅ Installation Complete!" -ForegroundColor Green
Write-Host "────────────────────────────────────────" -ForegroundColor Gray
Write-Host "   📁 Location:  $InstallPath\.agent" -ForegroundColor White
Write-Host "   🤖 Agents:    $($stats.Agents)" -ForegroundColor White
Write-Host "   🧩 Skills:    $($stats.Skills)" -ForegroundColor White
Write-Host "   🔄 Workflows: $($stats.Workflows)" -ForegroundColor White
Write-Host "────────────────────────────────────────`n" -ForegroundColor Gray

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  For each workspace, run:" -ForegroundColor Gray
Write-Host "  & '$InstallPath\.agent\scripts\init-workspace.ps1' 'C:\path\to\workspace'" -ForegroundColor Cyan
Write-Host ""

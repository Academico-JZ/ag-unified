# Updates from upstream repos
# Run periodically to get latest agents/skills

param(
    [string]$AgentPath = "$env:USERPROFILE\.gemini\antigravity\.agent"
)

Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        AG-JZ UPDATE                  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝`n" -ForegroundColor Cyan

# Backup custom GEMINI.md
$GeminiBackup = "$AgentPath\GEMINI.md.backup"
if (Test-Path "$AgentPath\GEMINI.md") {
    Copy-Item "$AgentPath\GEMINI.md" $GeminiBackup -Force
    Write-Host "📦 Backed up GEMINI.md" -ForegroundColor Gray
}

# Update ag-kit
Write-Host "[1/2] Updating ag-kit..." -ForegroundColor Yellow
try {
    npm update -g @vudovn/ag-kit
    Set-Location (Split-Path $AgentPath -Parent)
    ag-kit init
} catch {
    Write-Host "   ⚠️ npm update failed, using existing" -ForegroundColor Yellow
}

# Restore custom GEMINI.md
if (Test-Path $GeminiBackup) {
    Copy-Item $GeminiBackup "$AgentPath\GEMINI.md" -Force
    Remove-Item $GeminiBackup -Force
    Write-Host "📦 Restored custom GEMINI.md" -ForegroundColor Gray
}

# Pull latest customizations from ag-jz
Write-Host "[2/2] Updating AG-JZ customizations..." -ForegroundColor Yellow
$CustomUrl = "https://raw.githubusercontent.com/Academico-JZ/ag-jz/main/custom/GEMINI.md"
Invoke-WebRequest -Uri $CustomUrl -OutFile "$AgentPath\GEMINI.md" -ErrorAction SilentlyContinue

Write-Host "`n✅ Update complete!" -ForegroundColor Green

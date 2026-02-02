# Updates the environment by fetching and running the latest setup.ps1
# Usage: .\scripts\update.ps1

$ErrorActionPreference = "Stop"
Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        AG-UNIFIED UPDATE SYSTEM      ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝`n" -ForegroundColor Cyan

# Determine root
$RepoRoot = Resolve-Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path
Set-Location $RepoRoot

Write-Host "🔄 Fetching latest setup.ps1..." -ForegroundColor Yellow
$SetupUrl = "https://raw.githubusercontent.com/Academico-JZ/ag-unified/main/setup.ps1"
try {
    Invoke-WebRequest -Uri $SetupUrl -OutFile "setup.ps1"
    Write-Host "✅ Setup script updated via ag-unified." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download setup.ps1. Check internet." -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Running setup..." -ForegroundColor Cyan
& ".\setup.ps1"

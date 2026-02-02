# Setup Antigravity Unified (LOCAL Standalone)
# Usage: .\setup-local.ps1 [-Force]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$CurrentPath = $PSScriptRoot
$RepoOwner = "Academico-JZ"
$RepoName = "ag-unified"
$Branch = "main"

# LOCALIZACAO DEFINIDA COMO O DIRETORIO ATUAL
$LocalAgent = Join-Path $CurrentPath ".agent"

Write-Host ""
Write-Host ">>> AG-UNIFIED: LOCAL STANDALONE SETUP <<<" -ForegroundColor Cyan
Write-Host ""

# --- LOGICA DE INSTALACAO LOCAL ---

if (Test-Path $LocalAgent) {
    if ((Get-Item $LocalAgent).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Write-Host "WARN: Detectado link para a central. Removendo para instalacao local..." -ForegroundColor Yellow
        Remove-Item $LocalAgent -Force
    }
}

if (-not (Test-Path $LocalAgent)) { New-Item -ItemType Directory -Path $LocalAgent -Force | Out-Null }

# 1. Instalar ag-kit (Base) LOCALMENTE
if (-not (Test-Path "$LocalAgent\agents") -or $Force) {
    Write-Host "Installing: Base (ag-kit) locally..." -ForegroundColor Yellow
    try {
        npm install -g @vudovn/ag-kit 2>$null
        ag-kit init # Isso criara a estrutura base na pasta atual
    } catch {
        Write-Host "Wait: npm falhou. Baixando via Zip..." -ForegroundColor Gray
        Invoke-WebRequest "https://github.com/vudovn/antigravity-kit/archive/refs/heads/main.zip" -OutFile "kit.zip"
        Expand-Archive "kit.zip" -DestinationPath "." -Force
        Copy-Item "antigravity-kit-main\.agent\*" ".agent" -Recurse -Force
        Remove-Item "kit.zip", "antigravity-kit-main" -Recurse -Force
    }
}

# 2. Instalar Skills LOCALMENTE
$SkillsDest = "$LocalAgent\skills"
if (-not (Test-Path $SkillsDest) -or (Get-ChildItem $SkillsDest).Count -lt 50 -or $Force) {
    Write-Host "Downloading: 600+ Skills locally..." -ForegroundColor Yellow
    $SkillsZip = "$CurrentPath\local-skills.zip"
    $SkillsUrl = "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/tags/v4.6.0.zip"
    Invoke-WebRequest -Uri $SkillsUrl -OutFile $SkillsZip
    try { tar -xf $SkillsZip 2>$null } catch { Expand-Archive $SkillsZip -DestinationPath "." -Force }
    
    if (-not (Test-Path $SkillsDest)) { New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null }
    $SourceSkills = "$CurrentPath\antigravity-awesome-skills-4.6.0\skills"
    if (Test-Path $SourceSkills) {
        Get-ChildItem $SourceSkills | ForEach-Object {
            $Dest = Join-Path $SkillsDest $_.Name
            if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force -ErrorAction SilentlyContinue }
            Move-Item $_.FullName $SkillsDest -Force
        }
    }
    Remove-Item $SkillsZip, "$CurrentPath\antigravity-awesome-skills-4.6.0" -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. GEMINI.md Sync (Local correto: .agent/rules/GEMINI.md)
Write-Host "Syncing: GEMINI.md locally..." -ForegroundColor Yellow
$RuleFile = "$LocalAgent\rules\GEMINI.md"
if (-not (Test-Path (Split-Path $RuleFile))) { New-Item -ItemType Directory -Path (Split-Path $RuleFile) -Force | Out-Null }

$CustomUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/custom/GEMINI.md"
try {
    Invoke-WebRequest -Uri $CustomUrl -OutFile $RuleFile
    Copy-Item $RuleFile "$LocalAgent\GEMINI.md" -Force
    Write-Host "OK: Regras locais configuradas." -ForegroundColor Green
} catch {
    Write-Host "WARN: Falha ao baixar GEMINI.md remoto." -ForegroundColor Gray
}

Write-Host ""
Write-Host "SUCCESS: Workspace isolado configurado com sucesso!" -ForegroundColor Green
Write-Host "Este projeto NAO depende da pasta central." -ForegroundColor Gray

# AUTO-DELECAO: Remover este script apos o uso para limpar o workspace
Remove-Item $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue

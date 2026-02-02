# Setup Antigravity Unified (LOCAL Standalone)
# Usage: .\setup-local.ps1 [-Force]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$RepoOwner = "Academico-JZ"
$RepoName = "ag-unified"
$Branch = "main"

# DETECTAR DIRETORIO ATUAL (Fallback para PWD se PSScriptRoot vazio)
$CurrentPath = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$ScriptFile = Join-Path $CurrentPath "setup-local.ps1"
$LocalAgent = Join-Path $CurrentPath ".agent"

Write-Host ""
Write-Host ">>> AG-UNIFIED: LOCAL STANDALONE SETUP <<<" -ForegroundColor Cyan
Write-Host ""

# --- LOGICA DE INSTALACAO LOCAL ---

if (Test-Path $LocalAgent) {
    if ((Get-Item $LocalAgent).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Write-Host "WARN: Detectado link para a central. Removendo para instalacao local..." -ForegroundColor Yellow
        cmd /c rmdir "$LocalAgent"
    }
}

if (-not (Test-Path $LocalAgent)) { New-Item -ItemType Directory -Path $LocalAgent -Force | Out-Null }

# 1. Instalar ag-kit (Base) LOCALMENTE
if (-not (Test-Path "$LocalAgent\agents") -or $Force) {
    Write-Host "Installing: Base (ag-kit) locally..." -ForegroundColor Yellow
    try {
        npm install -g @vudovn/ag-kit 2>$null
        ag-kit init
    } catch {
        Write-Host "Wait: npm falhou. Baixando via Zip..." -ForegroundColor Gray
        $kitZip = Join-Path $CurrentPath "kit.zip"
        Invoke-WebRequest "https://github.com/vudovn/antigravity-kit/archive/refs/heads/main.zip" -OutFile $kitZip
        Expand-Archive $kitZip -DestinationPath $CurrentPath -Force
        Copy-Item "$CurrentPath\antigravity-kit-main\.agent\*" $LocalAgent -Recurse -Force
        Remove-Item $kitZip, "$CurrentPath\antigravity-kit-main" -Recurse -Force
    }
}

# 2. Instalar Skills LOCALMENTE
$SkillsDest = "$LocalAgent\skills"
if (-not (Test-Path $SkillsDest) -or (Get-ChildItem $SkillsDest -ErrorAction SilentlyContinue).Count -lt 50 -or $Force) {
    Write-Host "Downloading: 600+ Skills locally..." -ForegroundColor Yellow
    $SkillsZip = Join-Path $CurrentPath "local-skills.zip"
    $SkillsUrl = "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/tags/v4.6.0.zip"
    Invoke-WebRequest -Uri $SkillsUrl -OutFile $SkillsZip
    Expand-Archive $SkillsZip -DestinationPath $CurrentPath -Force
    
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
    
    # Cleanup: remover arquivos indesejados do ag-kit
    Remove-Item "$LocalAgent\mcp_config.json" -Force -ErrorAction SilentlyContinue
    Remove-Item "$LocalAgent\GEMINI.md" -Force -ErrorAction SilentlyContinue
}

# 3. GEMINI.md Sync (Local correto: .agent/rules/GEMINI.md)
Write-Host "Syncing: GEMINI.md locally..." -ForegroundColor Yellow
$RuleFile = "$LocalAgent\rules\GEMINI.md"
if (-not (Test-Path (Split-Path $RuleFile))) { New-Item -ItemType Directory -Path (Split-Path $RuleFile) -Force | Out-Null }

$CustomUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/custom/GEMINI.md"
try {
    Invoke-WebRequest -Uri $CustomUrl -OutFile $RuleFile
    Write-Host "OK: Regras locais configuradas." -ForegroundColor Green
} catch {
    Write-Host "WARN: Falha ao baixar GEMINI.md remoto." -ForegroundColor Gray
}

Write-Host ""
Write-Host "SUCCESS: Workspace isolado configurado com sucesso!" -ForegroundColor Green
Write-Host "Este projeto NAO depende da pasta central." -ForegroundColor Gray

# AUTO-DELECAO: Remover este script apos o uso para limpar o workspace
if (Test-Path $ScriptFile) { Remove-Item $ScriptFile -Force -ErrorAction SilentlyContinue }

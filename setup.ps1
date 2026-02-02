# Setup Antigravity Unified (Universal & Automatic)
# Usage: .\setup.ps1 [-Force]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$RepoOwner = "Academico-JZ"
$RepoName = "ag-unified"
$Branch = "main"

# DETECTAR DIRETORIO ATUAL (Fallback para PWD se PSScriptRoot vazio)
$CurrentPath = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$ScriptFile = Join-Path $CurrentPath "setup.ps1"

# LOCALIZACAO CENTRAL PADRAO
$CentralPath = "$env:USERPROFILE\.gemini\antigravity"
$CentralAgent = "$CentralPath\.agent"

Write-Host ""
Write-Host ">>> AG-UNIFIED: AUTOMATIC SETUP <<<" -ForegroundColor Cyan
Write-Host ""

# --- LOGICA DE INSTALACAO AUTOMATICA DA CENTRAL ---

if (-not (Test-Path $CentralAgent) -or $Force) {
    if ($CurrentPath -eq $CentralPath) {
        Write-Host "[Action] Instalando Central no local padrao..." -ForegroundColor Yellow
    } else {
        Write-Host "[Action] Central nao encontrada. Instalando automaticamente em $CentralPath..." -ForegroundColor Yellow
        if (-not (Test-Path $CentralPath)) { New-Item -ItemType Directory -Path $CentralPath -Force | Out-Null }
    }

    # 1. Instalar ag-kit (Base) na Central
    Write-Host "Installing: Base (ag-kit)..." -ForegroundColor Yellow
    try {
        npm install -g @vudovn/ag-kit 2>$null
        $oldDir = Get-Location
        Set-Location $CentralPath
        ag-kit init
        Set-Location $oldDir
    } catch {
        Write-Host "Wait: npm falhou. Baixando via Zip..." -ForegroundColor Gray
        Invoke-WebRequest "https://github.com/vudovn/antigravity-kit/archive/refs/heads/main.zip" -OutFile "$CentralPath\kit.zip"
        Expand-Archive "$CentralPath\kit.zip" -DestinationPath "$CentralPath" -Force
        if (-not (Test-Path $CentralAgent)) { New-Item -ItemType Directory -Path $CentralAgent | Out-Null }
        Copy-Item "$CentralPath\antigravity-kit-main\.agent\*" "$CentralAgent" -Recurse -Force
        Remove-Item "$CentralPath\kit.zip", "$CentralPath\antigravity-kit-main" -Recurse -Force
    }

    # 2. Instalar Skills na Central
    $SkillsDest = "$CentralAgent\skills"
    Write-Host "Downloading: 600+ Skills..." -ForegroundColor Yellow
    $SkillsZip = "$CentralPath\skills.zip"
    $SkillsUrl = "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/tags/v4.6.0.zip"
    Invoke-WebRequest -Uri $SkillsUrl -OutFile $SkillsZip
    try { tar -xf $SkillsZip -C $CentralPath 2>$null } catch { Expand-Archive $SkillsZip -DestinationPath "$CentralPath" -Force }
    
    if (-not (Test-Path $SkillsDest)) { New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null }
    $SourceSkills = "$CentralPath\antigravity-awesome-skills-4.6.0\skills"
    if (Test-Path $SourceSkills) {
        Get-ChildItem $SourceSkills | ForEach-Object {
            $Dest = Join-Path $SkillsDest $_.Name
            if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force -ErrorAction SilentlyContinue }
            Move-Item $_.FullName $SkillsDest -Force
        }
    }
    Remove-Item $SkillsZip, "$CentralPath\antigravity-awesome-skills-4.6.0" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Cleanup: remover arquivos indesejados do ag-kit
    Remove-Item "$CentralAgent\mcp_config.json" -Force -ErrorAction SilentlyContinue
    Remove-Item "$CentralAgent\GEMINI.md" -Force -ErrorAction SilentlyContinue
}

# 3. GEMINI.md Sync (Local correto: .agent/rules/GEMINI.md)
Write-Host "Syncing: GEMINI.md..." -ForegroundColor Yellow
$RuleFile = "$CentralAgent\rules\GEMINI.md"
if (-not (Test-Path (Split-Path $RuleFile))) { New-Item -ItemType Directory -Path (Split-Path $RuleFile) -Force | Out-Null }

$CustomUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/custom/GEMINI.md"
try {
    Invoke-WebRequest -Uri $CustomUrl -OutFile $RuleFile
    if (-not (Test-Path "$env:USERPROFILE\.gemini")) { New-Item -ItemType Directory -Path "$env:USERPROFILE\.gemini" -Force | Out-Null }
    Copy-Item $RuleFile "$env:USERPROFILE\.gemini\GEMINI.md" -Force
    Write-Host "OK: Regras ativas em .agent/rules e globalmente." -ForegroundColor Green
} catch {
    Write-Host "WARN: Falha ao atualizar GEMINI.md remoto." -ForegroundColor Gray
}

# --- LOGICA DE VINCULACAO (WORKSPACE) ---

if ($CurrentPath -ne $CentralPath) {
    Write-Host "[Action] Vinculando esta pasta a Central..." -ForegroundColor Yellow
    $TargetAgent = Join-Path $CurrentPath ".agent"
    
    if (Test-Path $TargetAgent) {
        if ((Get-Item $TargetAgent).Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host "OK: Link ja existe." -ForegroundColor Green
        } else {
            Remove-Item $TargetAgent -Recurse -Force
        }
    }
    
    if (-not (Test-Path $TargetAgent)) {
        cmd /c mklink /J "$TargetAgent" "$CentralAgent" | Out-Null
        if (Test-Path $TargetAgent) { Write-Host "SUCCESS: Workspace pronto!" -ForegroundColor Green }
        else { Write-Host "ERR: Falha ao criar link. Tente como Admin." -ForegroundColor Red }
    }
} else {
    Write-Host ""
    Write-Host "!!! CENTRAL BRAIN CONFIGURADA !!!" -ForegroundColor Green
}

# AUTO-DELECAO: Remover este script apos o uso para limpar o workspace
if (Test-Path $ScriptFile) { Remove-Item $ScriptFile -Force -ErrorAction SilentlyContinue }

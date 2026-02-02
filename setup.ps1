# Setup Antigravity Unified (Universal & Automatic)
# Usage: .\setup.ps1 [-Force]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$CurrentPath = $PSScriptRoot
$RepoOwner = "Academico-JZ"
$RepoName = "ag-unified"
$Branch = "main"

# LOCALIZACAO CENTRAL DEFINIDA
$CentralPath = "$env:USERPROFILE\.gemini\antigravity"
$CentralAgent = "$CentralPath\.agent"

Write-Host ""
Write-Host ">>> AG-UNIFIED: AUTOMATIC SETUP <<<" -ForegroundColor Cyan
Write-Host ""

# --- LOGICA DE ROTEAMENTO AUTOMATICO ---

# 1. Verificar se estamos rodando fora da central (MODO WORKSPACE)
if ($CurrentPath -ne $CentralPath) {
    Write-Host "[Mode] Workspace Detectado (Linking)..." -ForegroundColor Yellow
    
    # Verificar se a central existe
    if (-not (Test-Path $CentralAgent)) {
        Write-Host "ERR: Central nao encontrada em $CentralPath" -ForegroundColor Red
        Write-Host "Por favor, instale primeiro na central usando o comando Quick Start." -ForegroundColor Gray
        exit 1
    }

    $TargetAgent = Join-Path $CurrentPath ".agent"
    
    # Tratar link existente
    if (Test-Path $TargetAgent) {
        if ((Get-Item $TargetAgent).Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host "OK: Link (Junction) ja existe neste workspace." -ForegroundColor Green
            exit 0
        }
        Write-Host "WARN: Havia uma pasta .agent real. Removendo para criar o link..." -ForegroundColor Gray
        Remove-Item $TargetAgent -Recurse -Force
    }

    # Criar Junction AUTOMATICO
    Write-Host "Linking: Criando link automatico para a central..." -ForegroundColor Cyan
    cmd /c mklink /J "$TargetAgent" "$CentralAgent" | Out-Null
    
    if (Test-Path $TargetAgent) {
        Write-Host "OK: Workspace vinculado com sucesso! Acesso a 600+ skills ativo." -ForegroundColor Green
    } else {
        Write-Host "ERR: Falha ao criar link. Tente rodar como Administrador." -ForegroundColor Red
    }
    exit 0
}

# --- MODO INSTALACAO CENTRAL (Apenas se estiver em $CentralPath) ---

Write-Host "[Mode] Central (Brain Center) Detectado..." -ForegroundColor Yellow

# 1. Instalar ag-kit
if (-not (Test-Path "$CentralAgent\agents") -or $Force) {
    Write-Host "Installing: Base (ag-kit)..." -ForegroundColor Yellow
    try {
        npm install -g @vudovn/ag-kit 2>$null
        ag-kit init
    } catch {
        Write-Host "Wait: npm falhou. Baixando via Zip..." -ForegroundColor Gray
        Invoke-WebRequest "https://github.com/vudovn/antigravity-kit/archive/refs/heads/main.zip" -OutFile "kit.zip"
        Expand-Archive "kit.zip" -DestinationPath "." -Force
        if (-not (Test-Path ".agent")) { New-Item -ItemType Directory -Path ".agent" | Out-Null }
        Copy-Item "antigravity-kit-main\.agent\*" ".agent" -Recurse -Force
        Remove-Item "kit.zip", "antigravity-kit-main" -Recurse -Force
    }
}

# 2. Instalar Skills
$SkillsDest = "$CentralAgent\skills"
if (-not (Test-Path $SkillsDest) -or (Get-ChildItem $SkillsDest).Count -lt 50 -or $Force) {
    Write-Host "Downloading: 600+ Skills..." -ForegroundColor Yellow
    $SkillsZip = "$CurrentPath\skills.zip"
    $SkillsUrl = "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/tags/v4.6.0.zip"
    Invoke-WebRequest -Uri $SkillsUrl -OutFile $SkillsZip
    try { tar -xf $SkillsZip 2>$null } catch { Expand-Archive $SkillsZip -DestinationPath "." -Force }
    
    if (-not (Test-Path $SkillsDest)) { New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null }
    # Fix: Corrected Move-Item command logic
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

# 3. GEMINI.md Sync
Write-Host "Syncing: GEMINI.md..." -ForegroundColor Yellow
$CustomUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/custom/GEMINI.md"
try {
    Invoke-WebRequest -Uri $CustomUrl -OutFile "$CentralAgent\GEMINI.md"
    Copy-Item "$CentralAgent\GEMINI.md" "$env:USERPROFILE\.gemini\GEMINI.md" -Force
    Write-Host "OK: Configuracoes globais aplicadas." -ForegroundColor Green
} catch {
    Write-Host "WARN: Falha ao baixar GEMINI.md remoto. Usando local." -ForegroundColor Gray
}

Write-Host ""
Write-Host "!!! CENTRAL BRAIN PRONTA !!!" -ForegroundColor Green
Write-Host "Agora rode este script dentro de qualquer projeto para vincula-lo." -ForegroundColor Gray

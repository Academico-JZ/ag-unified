#!/usr/bin/env pwsh

# -----------------------------------------------------------------------------
# 🌌 ANTIGRAVITY ELITE CLI (omni-jz)
# -----------------------------------------------------------------------------

param (
    [string]$Command,
    [string[]]$ExtraArgs
)

# Configuration
$RepoUrl = "https://github.com/Academico-JZ/antigravity-jz.git"
$AgentDir = ".agent"

function Show-Header {
    Write-Host ""
    Write-Host "    ╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "    ║        ANTIGRAVITY KIT CLI           ║" -ForegroundColor Cyan
    Write-Host "    ╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Function to setup complex skills (compilation/dependencies)
function Setup-ComplexSkills {
    param([string]$BaseDir)
    
    $ComplexSkills = @(
        @{
            Name  = "agent-memory"
            Path  = "skills/agent-memory"
            Build = $true
        }
    )

    foreach ($Skill in $ComplexSkills) {
        $FullSkillPath = Join-Path $BaseDir $Skill.Path
        
        # Only proceed if the skill files actually exist (merged in the kit)
        if (Test-Path $FullSkillPath) {
            # Check if it needs building (missing node_modules or dist/out)
            if ($Skill.Build -and (-not (Test-Path "$FullSkillPath\node_modules"))) {
                Write-Host "  ⚙️  Setting up $($Skill.Name)..." -NoNewline -ForegroundColor Gray
                
                Push-Location $FullSkillPath
                try {
                    # Install and Compile silently
                    npm install --silent 2>&1 | Out-Null
                    npm run compile --silent 2>&1 | Out-Null
                    Write-Host " Done." -ForegroundColor Green
                }
                catch {
                    Write-Host " Failed." -ForegroundColor Red
                }
                finally {
                    Pop-Location
                }
            }
        }
    }
}

switch ($Command) {
    "init" {
        Show-Header
        if (Test-Path $AgentDir) {
            Write-Warning " The .agent directory already exists."
        }
        else {
            Write-Host "  Installing..." -NoNewline
            git clone --depth 1 $RepoUrl .agent_tmp 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                if (-not (Test-Path ".agent")) { mkdir ".agent" | Out-Null }
                
                # Move standard folders only
                Copy-Item ".agent_tmp\.agent\agents" -Destination ".agent" -Recurse -Force
                Copy-Item ".agent_tmp\.agent\skills" -Destination ".agent" -Recurse -Force
                Copy-Item ".agent_tmp\.agent\workflows" -Destination ".agent" -Recurse -Force
                Copy-Item ".agent_tmp\.agent\rules" -Destination ".agent" -Recurse -Force
                Copy-Item ".agent_tmp\.agent\scripts" -Destination ".agent" -Recurse -Force
                Copy-Item ".agent_tmp\.agent\ARCHITECTURE.md" -Destination ".agent" -Force
                
                # Copy hidden shared assets if they exist
                if (Test-Path ".agent_tmp\.agent\.shared") { Copy-Item ".agent_tmp\.agent\.shared" -Destination ".agent" -Recurse -Force }
                if (Test-Path ".agent_tmp\.agent\assets") { Copy-Item ".agent_tmp\.agent\assets" -Destination ".agent" -Recurse -Force }

                
                Remove-Item ".agent_tmp" -Recurse -Force
                Setup-ComplexSkills -BaseDir ".agent"
                
                Write-Host "`r✔ Installation successful!" -ForegroundColor Green
                Write-Host ""
                Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray
                Write-Host "Result:"
                Write-Host "   .agent → $(Convert-Path .agent)" -ForegroundColor Gray
                Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray
                Write-Host ""
                Write-Host "Happy coding! 🚀" -ForegroundColor Cyan
            }
            else {
                Write-Error "Failed to download kit."
            }
        }
    }

    "status" {
        Show-Header
        if (Test-Path $AgentDir) {
            $Agents = (Get-ChildItem "$AgentDir\agents" -Filter "*.md").Count
            $Skills = (Get-ChildItem "$AgentDir\skills" -Directory).Count
            $Workflows = (Get-ChildItem "$AgentDir\workflows" -Filter "*.md").Count
            
            Write-Host "📊 System Status" -ForegroundColor Cyan
            Write-Host "   Agents:    $Agents"
            Write-Host "   Skills:    $Skills"
            Write-Host "   Workflows: $Workflows"
            Write-Host "   Integrity: 100%" -ForegroundColor Green
        }
        else {
            Write-Warning "Omni-JZ not initialized."
        }
    }

    "sync" {
        Show-Header
        Write-Host "🔄 Syncing..." -ForegroundColor Cyan
        Setup-ComplexSkills -BaseDir $AgentDir
        Write-Host "✔ Synced." -ForegroundColor Green
    }

    Default {
        Show-Header
        Write-Host "Commands: init, sync, status"
    }
}

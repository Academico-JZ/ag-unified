# AG-UNIFIED - Antigravity Kit Modular

> Arquitetura agentica modular que combina [antigravity-kit](https://github.com/vudovn/antigravity-kit) + [antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) com customizacoes proprias.

## Quick Start

### Opcao 1: Central (Recomendado)
Instala na central e cria links nos projetos. Compartilha skills entre todos os workspaces:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-unified/main/setup.ps1" -OutFile "setup.ps1"; .\setup.ps1
```
*O script se auto-deleta apos a instalacao.*

### Opcao 2: Standalone (Isolado)
Instala tudo localmente, sem dependencia da central:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-unified/main/setup-local.ps1" -OutFile "setup-local.ps1"; .\setup-local.ps1
```
*Util para projetos que precisam de autonomia total.*

### Opcao 3: Via Git Clone
```bash
git clone https://github.com/Academico-JZ/ag-unified.git
cd ag-unified
.\setup.ps1
```

---

## Estrutura

```
ag-unified/
|-- setup.ps1              # Instalacao Central (Universal, Auto-Delete)
|-- setup-local.ps1        # Instalacao Local (Standalone, Auto-Delete)
|-- custom/
|   |-- GEMINI.md          # Regras customizadas do AI
|   |-- overrides/         # Sobrescritas de skills/agents
|-- scripts/
    |-- update.ps1         # Atualiza todo o ambiente
```

---

## Assets

| Source | Type | Count |
|--------|------|-------|
| antigravity-kit | Agents | 20 |
| antigravity-awesome-skills | Skills | 600+ |
| ag-unified | Custom Rules | 1 |

---

## Customizacoes

O arquivo `custom/GEMINI.md` contem:
- Sequential Thinking Protocol
- User Profile (SysAdmin/DevOps)
- Socratic Gate rules
- Agent routing preferences

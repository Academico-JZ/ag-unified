# AG-UNIFIED - Antigravity Kit Modular

> Arquitetura agentica modular que combina [antigravity-kit](https://github.com/vudovn/antigravity-kit) + [antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) com customizacoes proprias.

## Quick Start (Recomendado)

### Opcao 1: Via PowerShell (One-line)
Basta rodar este bloco. Ele instala tudo (Agents + 600 Skills + Config) e cria links automaticamente em novos workspaces:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-unified/main/setup.ps1" -OutFile "setup.ps1"; .\setup.ps1
```

### Opcao 2: Via Git Clone
Se voce prefere clonar o repositorio para ter controle de versao:
```bash
git clone https://github.com/Academico-JZ/ag-unified.git
cd ag-unified
.\setup.ps1
```
*O script detecta automaticamente se deve instalar o nucleo central ou apenas vincular a pasta atual.*

---

## Estrutura

```
ag-unified/
├── setup.ps1              # Script principal (Universal, Idempotente, Sem Emojis)
├── custom/
│   ├── GEMINI.md          # Regras customizadas do AI
│   └── overrides/         # Sobrescritas de skills/agents
└── scripts/
    ├── init-workspace.ps1 # Legado (O setup.ps1 ja faz isso agora)
    └── update.ps1         # Atualiza todo o ambiente
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

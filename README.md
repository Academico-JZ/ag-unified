# AG-UNIFIED - Antigravity Kit Modular

> Arquitetura agentica modular que combina [antigravity-kit](https://github.com/vudovn/antigravity-kit) + [antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) com customizacoes proprias.

---

## Modos de Instalacao

### Global (Recomendado)

Instala o "cerebro central" em `%USERPROFILE%\.gemini\antigravity\.agent` e cria **links simbolicos** nos workspaces. Todos os projetos compartilham a mesma instalacao, economizando espaco e facilitando atualizacoes.

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-unified/main/setup.ps1" -OutFile "setup.ps1"; .\setup.ps1
```

**Como funciona:**
- Primeira execucao: instala tudo na pasta central
- Execucoes seguintes (em outros projetos): cria apenas o link `.agent` -> central
- O script se auto-deleta apos uso

**Vantagens:**
- Atualize uma vez, todos os projetos recebem
- Menos espaco em disco
- Consistencia entre workspaces

---

### Local (Standalone)

Instala tudo **diretamente no workspace atual**. A pasta `.agent` do projeto e completamente independente, sem links para a central.

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-unified/main/setup-local.ps1" -OutFile "setup-local.ps1"; .\setup-local.ps1
```

**Quando usar:**
- Projetos que precisam de isolamento total
- Ambientes onde links simbolicos nao funcionam bem
- Experimentacao sem afetar outros projetos

---

### Via Git Clone

Se voce prefere clonar o repositorio para ter controle de versao:

```bash
git clone https://github.com/Academico-JZ/ag-unified.git
cd ag-unified
.\setup.ps1
```

---

## Estrutura

```
ag-unified/
|-- setup.ps1              # Instalacao Global (cria central + links)
|-- setup-local.ps1        # Instalacao Local (standalone)
|-- custom/
|   |-- GEMINI.md          # Regras customizadas do AI
|   |-- overrides/         # Sobrescritas de skills/agents
|-- scripts/
    |-- update.ps1         # Atualiza todo o ambiente
```

---

## Assets Incluidos

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

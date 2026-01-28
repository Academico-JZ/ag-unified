# 🌌 ag-jz-rm (Quantum Edition)

<p align="center">
  <img src="assets/logo.jpg" width="400" alt="JZ-RM Logo">
</p>

> **A fusão definitiva entre o `Awesome Skills` e o `Antigravity Kit`. 258+ Skills, 20 Agentes e 11+ Workflows em um único ambiente de alta performance.**

---

## 🐣 O que é este Kit?

Este repositório é uma versão consolidada, otimizada e **totalmente autônoma** do ecossistema Antigravity. Ele transforma seu assistente de IA em uma agência digital completa capaz de gerenciar múltiplos projetos simultaneamente com zero esforço de configuração.

**Diferenciais desta versão:**
- ✅ **Comandos Curtos:** Instalação e execução minimalista via CLI.
- ✅ **Orquestração Modular:** Setup único que se replica para infinitos projetos.
- ✅ **Zero-Touch Automation:** Linkagem automática de novos workspaces no playground.
- ✅ **Híbrido (PowerShell + Node):** Compatibilidade total com Windows, macOS e Linux.

---

## 🚀 Quick Install

Escolha o modo que melhor se adapta ao seu fluxo de trabalho:

### 🌍 Opção A: Instalação Global (Recomendado)
Ideal para ter o poder do JZ-RM em qualquer terminal e automação total no playground.

```bash
# 1. Instale o core
npm i -g Academico-JZ/ag-jz-rm

# 2. Inicialize o motor central
ag-jz-rm init
```

### 📦 Opção B: Instalação Local (Portátil)
Ideal para criar projetos auto-contidos que podem ser compartilhados via Git.

```bash
npx Academico-JZ/ag-jz-rm init --local
```

---

## 🏗️ Como vincular a um novo projeto (Cluster Mode)

Com o Kit instalado globalmente, você tem duas formas de ativar o poder em um novo workspace:

1.  **Automático (Zero-Touch):** Basta criar uma pasta no seu playground e me dar um "oi". Eu detectarei a ausência do controlador e farei o link modular em background.
2.  **Manual:** Se precisar forçar a linkagem em uma pasta fora do playground padrão:
    ```bash
    ag-jz-rm link
    ```

---

## 🛠️ Comandos Slash (Workflows Master)

| Comando | Descrição |
| :--- | :--- |
| `/plan` | Cria um plano técnico detalhado sem escrever código. |
| `/brainstorm` | Processo de discovery socrático para validar ideias. |
| `/create` | Orquestra a criação de uma nova aplicação do zero. |
| `/debug` | Modo de depuração sistemática com análise de causa raiz. |
| `/ui-ux-pro-max` | Foco em estética premium, animações e craft visual. |

---

## 🧪 Estrutura do Projeto

```plaintext
ag-jz-rm/
├── bin/cli.js           # Orquestrador Node.js (init/link)
├── install.ps1          # Instalador nativo para Windows
├── assets/              # Identidade visual e logos
└── .agent/              # O "Cérebro" do sistema
    ├── agents/          # 20 Personas especializadas
    ├── skills/          # 258+ Habilidades injetáveis
    ├── workflows/       # Automação de comandos slash
    ├── scripts/         # Scripts de validação e manutenção
    └── rules/           # GEMINI.md (Protocolos de Identidade)
```

---

## 🔄 Manutenção e Sincronização

Mantenha seu motor sempre atualizado com as últimas skills da comunidade:
```bash
python .agent/scripts/sync_kits.py
```

---

## 🤝 Créditos

Inspirado pelos trabalhos pioneiros de **[sickn33](https://github.com/sickn33)** e **[vudovn](https://github.com/vudovn)**.  
Refatorado, automatizado e documentado por **[Academico-JZ](https://github.com/Academico-JZ)** e **[RMMeurer](https://github.com/rmmeurer)**.

> **Edition: JZ-RM v1.4 "Quantum"** — Built for speed, logic, and visual excellence.

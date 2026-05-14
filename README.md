# ConnectorX LSP

Extensão de editor para a **Linguagem Senior de Programação (LSP)** — dialeto Sapiens (Gestão Empresarial ERP) e dialeto Rubi (Gestão de Pessoas HCM). Funciona em **VS Code** e **Google Antigravity** (vscode-based).

> **Autor:** Adriano Azevedo · **Licença:** MIT · **Origem:** fork estendido de [`killer.lsp`](https://github.com/rodrigokiller/vscode-language-lsp) (Rodrigo Sanguanini), enriquecido a partir do skill `/senior-lsp` mantido em `~/.claude/skills/senior-lsp/`.

## O que ela faz

| Recurso | Detalhe |
|---|---|
| **Syntax highlighting** | Palavras-chave de controle (`SE`, `ENQUANTO`, `PARA`, `DEFINIR`, `FUNCAO`, `INICIO`/`FIM`), operadores (`E`, `OU`, `<>`), 400+ funções catalogadas (LSP, Sapiens, HCM, segurança, HTTP, FTP, AD, ICal, etc.), comentários `@` (linha) e `/* */` (bloco), strings, números. |
| **SQL embutido nos cursores** | O conteúdo das strings passadas a `SQL_DefinirComando(...)`, `EXECSQLEX(...)`, `EXECSQL "..."`, `<cursor>.SQL "..."`, e atribuições `xQuery = "SELECT/UPDATE/INSERT/DELETE/WITH/MERGE ..."` é colorido como **SQL** — `SELECT`/`FROM`/`WHERE` em destaque, funções SQL Server (`JSON_VALUE`, `DATEPART`, `GETDATE`, etc.) reconhecidas. |
| **Snippets canônicos** | 60+ snippets cobrindo: skeleton completo de SSF, JSON_VALUE/`json-value-extract`, padrão NOK, escape de JSON, retorno OK/erro, `ssf-skeleton`, EXECSQLEX com tratamento de erro, cursor OO (Rubi) e procedural (Sapiens), ConverteMascara para data/CPF/CNPJ/dinheiro, eventos SGI (`AntesAlterar`, `AntesInserir`, `Inicializacao`), HHMMSS decimal, cálculo de cruzamento de meia-noite, auditoria padrão. |
| **Language configuration** | Auto-closing para `{ }`, `[ ]`, `( )`, `/* */`, `@ @`, `" "`. Comentário de linha = `@`. Comentário de bloco = `/* */`. |
| **Associação de arquivos** | `.lsp` e `.ssf` (Senior Services File — webservices customizados). |

## Como instalar (manual)

A extensão **não está publicada** no Marketplace ainda — instale como pasta local:

### VS Code

```bash
cp -r ~/.claude/skills/senior-lsp/extension ~/.vscode/extensions/adrianoazevedo.connectorx-lsp-2.0.0
```

Reabra o VS Code. A linguagem aparece como **"Linguagem Senior de Programação"** no seletor de linguagem.

### Antigravity

```bash
cp -r ~/.claude/skills/senior-lsp/extension ~/.antigravity/extensions/adrianoazevedo.connectorx-lsp-2.0.0
```

Edite `~/.antigravity/extensions/extensions.json` e adicione a entrada (use o agente Claude com a skill `/senior-lsp` invocada — ele tem o procedimento canônico em `extension-bootstrap.md`).

Reabra o Antigravity.

## Atalho: pedir ao Claude

Se você usa o Claude Code com a skill `/senior-lsp` ativa, é só pedir:

> *"recria a extensão connectorx-lsp no meu Antigravity"*  
> *"reinstala a connectorx-lsp no VSCode com a versão mais nova dos snippets"*

O agente consulta `extension-bootstrap.md` na skill, copia os arquivos canônicos para o destino correto e atualiza o `extensions.json` automaticamente.

## Quais snippets existem

Digite o prefix e pressione **Tab**. Lista completa em `snippets/lsp.json` — destaques:

| Prefix | Gera |
|---|---|
| `ssf-skeleton` | SSF inteiro: DEFINIR + ENTER + NOK + JSON_VALUE + validação + lógica + jsonOut |
| `json-value-extract` | Cursor com `SQL_UsarSQLSenior2(0)` + JSON_VALUE para extrair 4 campos do payload |
| `execsqlex-update` | UPDATE via EXECSQLEX já com tratamento `NERRSQL`/`AMSGERROSQL` |
| `cursor-oo-loop` | Cursor estilo OO (`cCur.SQL` + `AbrirCursor` + `Achou` + `Proximo`) — padrão Rubi/HCM |
| `nok-guard` | Bloco `SE (NOK = 1) { … }` para fluxo sem early-return |
| `enter-crlf` | Define `AQUEBRA1`, `AQUEBRA2`, `ENTER` (CRLF) — necessário pra montar JSON em SSF |
| `escape-json` | Escapa string LSP para colar dentro de JSON (`SubstAlfa` na ordem correta) |
| `codope` (3 variantes) | Bloco para evento SGI `AntesAlterar` / `AntesInserir` / `Inicializacao` |
| `hhmmss` | Calcula hora atual em HHMMSS decimal (padrão `USU_HorAlt`) |
| `cruza-meia-noite` | Bloco `SE (NDIFMIN < 0) { NDIFMIN = NDIFMIN + 1440; }` |
| `transacao` | `IniciarTransacao` + DML + commit/rollback baseado em `NERRSQL` |
| `auditoria` | INSERT em `USU_LOG` com variáveis de sistema (CodUsu/NomUsu/DatSis/...) |
| `cabecalho-doc` | Cabeçalho de doc com `@ … @` interno (evita armadilha do `/* */` aninhado) |

E os snippets clássicos do `killer.lsp` original (`inicio`, `se`, `para`, `definir funcao`, `SQL_*`, `ExecSQL`) — todos preservados.

## SQL embutido — como ver

Abra um `.ssf` com um cursor:

```lsp
xQuery = "SELECT CodEmp, NomCli FROM E085CLI WHERE CodEmp = :xCodEmp";
SQL_Criar(xCur);
SQL_DefinirComando(xCur, xQuery);
```

Ou direto na chamada:

```lsp
SQL_DefinirComando(xCur, "UPDATE USU_T200CON SET USU_OBSCAB = 'ok' WHERE USU_CODEMP = :NCODEMP");
```

A string passa a ser **colorida como SQL** — `SELECT`/`UPDATE`/`FROM`/`WHERE` ganham destaque, e funções como `JSON_VALUE`, `CAST`, `TRY_CAST`, `ISNULL` ficam reconhecíveis. Funciona também para cursor OO:

```lsp
cCli.SQL "SELECT NomCli, CgcCli FROM E085CLI WHERE CodCli = :vCodCli";
```

## Roadmap

- [ ] Publicar no Marketplace VS Code (precisa `vsce`).
- [ ] Snippets para HCM/Rubi específicos (cálculo de folha, ronda).
- [ ] Hover provider com link pra documentação Senior de cada função.
- [ ] Linter básico: detectar `EXECSQLEX` com subquery (gotcha #1 do skill).
- [ ] Auditor de `/* */` aninhado integrado (gotcha #25).

## Créditos

- **Trabalho original:** [Rodrigo Sanguanini](https://github.com/rodrigokiller) — extensão `killer.lsp` (gramática TextMate, snippets básicos, language-configuration). Licença MIT preservada.
- **Fork estendido (versão 2.0):** Adriano Azevedo — gramática SQL embutida, dobro de snippets, suporte a `.ssf`, alinhamento com a skill `/senior-lsp` da Claude Code, snippets para padrões reais de produção (NOK, JSON_VALUE, escape JSON, eventos SGI, HHMMSS, cruzamento meia-noite, auditoria).

## Licença

MIT — ver `LICENSE.md`.

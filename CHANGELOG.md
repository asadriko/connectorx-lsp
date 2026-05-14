# Changelog

Todas as mudanças notáveis ficam aqui. Segue [Keep a Changelog](http://keepachangelog.com/).

## [2.0.0] — 2026-05-14 — Fork ConnectorX (Adriano Azevedo)

Reescrita do projeto a partir de `killer.lsp` 1.0.5, alinhada à skill `/senior-lsp` da Claude Code.

### Adicionado
- **Gramática SQL embutida** dentro das strings de cursor (`SQL_DefinirComando`, `EXECSQLEX`, `EXECSQL`, `<cursor>.SQL "..."`) e em atribuições do tipo `xQuery = "SELECT|UPDATE|INSERT|DELETE|WITH|MERGE ..."`. SQL passa a ser colorido como SQL nativo.
- **Associação de arquivo `.ssf`** (Senior Services File — webservices customizados). Antes só `.lsp` e `.txt` (este último removido — causava falso-positivo em arquivos texto comuns).
- **60+ snippets novos**, derivados de padrões reais de produção catalogados na skill:
  - `ssf-skeleton`: SSF completo (DEFINIR + ENTER + NOK + JSON_VALUE + validação + lógica + jsonOut).
  - `json-value-extract`: cursor com `SQL_UsarSQLSenior2(0)` + JSON_VALUE multi-tipo.
  - `nok-guard`: bloco `SE (NOK = 1)` para fluxo sem early-return.
  - `enter-crlf`, `escape-json`, `return-json-ok`, `return-json-erro`.
  - `execsqlex-update/insert/delete` com tratamento `NERRSQL`/`AMSGERROSQL`.
  - `cursor-oo`, `cursor-oo-loop` (estilo Rubi/HCM).
  - `definir-alfa`, `definir-numero`, `definir-data`, `definir-cursor`, `definir-tabela`, `definir-grid`.
  - `mensagem-erro`, `mensagem-aviso`, `mensagem-pergunta`.
  - `convertemascara-data/dinheiro/cpf/cnpj`.
  - `codope` (3 variantes: `AntesAlterar`, `AntesInserir`, `Inicializacao`).
  - `hhmmss`, `cruza-meia-noite`, `auditoria`, `cabecalho-doc`, `transacao`.
- **`embeddedLanguages`** no `contributes.grammars` (`meta.embedded.block.sql` → `sql`), permitindo IntelliSense SQL dentro do range embutido (quando o editor instala uma extensão de SQL).
- **README enriquecido**, com lista de snippets, instruções de instalação manual e atalho via Claude Code.

### Alterado
- **Nome:** `killer.lsp` → `connectorx-lsp`.
- **Publisher:** `Killer` → `AdrianoAzevedo`.
- **Display name:** `lsp` → `ConnectorX LSP`.
- **Aliases:** `lsp`, `Linguagem Senior de Programação`, `Senior` → adiciona `Senior LSP`, `Rubi`, `ConnectorX LSP`.
- Snippet `para` agora usa `Inicio`/`Fim` em vez de `{ }` (mais idiomático em Sapiens — chaves só em `Se`).
- Snippet `SQL_Criar` completo agora inicia já com `SQL_UsarAbrangencia(xCur, 0)` + `SQL_UsarSQLSenior2(xCur, 0)` (canônico para SSF — desliga abrangência e permite JSON_VALUE/DATEPART/etc.).
- Snippets `ExecSQLEx` adicionam tratamento de erro automático (`Se (NERRSQL <> 0)`).
- Snippet `Mensagem` separa 3 variantes claras (Erro / Aviso / Pergunta com `ValRet`).
- `SQL_FecharCursor` agora também emite `SQL_Destruir` em sequência (sempre vêm em par).

### Removido
- Associação automática a `.txt` (causava falso-positivo em qualquer arquivo de texto).

### Créditos
- Trabalho original: Rodrigo Sanguanini (`killer.lsp` 1.0.5, gramática base + snippets básicos + language-config). MIT preservada.
- Fork e estensões: Adriano Azevedo.

---

## Histórico do `killer.lsp` (preservado)

### [1.0.3]
- Funções LSP e de Tecnologia (SGI, relatório, cubo) adicionadas.

### [1.0.2]
- Pequenos ajustes.

### [1.0.1]
- Suporte ao RH (HCM/Rubi).
- Mais funções.
- Atualizado para JSON o arquivo de sintaxes.
- Mais snippets.
- Ajustado bugs de snippets e comentários com `@`.
- Suporte aos números.

### [0.0.1]
- Initial release.

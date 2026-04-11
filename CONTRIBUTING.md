# Contribuindo

Obrigado por ajudar a traduzir e revisar o Rust Book para PT-BR.

Este repositório existe para manter uma tradução comunitária, pública e não
oficial de `rust-lang/book`, com o mínimo possível de divergência estrutural em
relação ao projeto-fonte.

## Onde editar

Edite normalmente apenas:

- `src-pt-br`
- documentação do projeto, como `README.md`, `CONTRIBUTING.md` e `GOVERNANCE.md`
- scripts e workflows locais relacionados ao fork PT-BR

Não envie traduções manuais para `src`. Esse diretório deve continuar espelhando
o upstream em inglês.

## Fluxo recomendado

1. Verifique se já existe uma issue relacionada.
2. Abra uma issue se a mudança envolver terminologia, revisão ampla ou dúvida de
   interpretação.
3. Envie um PR pequeno e objetivo sempre que possível.
4. Explique no PR se o texto foi revisado do zero ou se partiu da tradução
   inicial assistida por IA.

## Regras para a trilha traduzida

- Preserve links, âncoras HTML e comentários necessários para compatibilidade
  com mdBook.
- Preserve `{{#include ...}}`, `{{#rustdoc_include ...}}`, blocos de código e
  referências a listings.
- Não mude exemplos Rust ou saídas de compilação só para "soar melhor" em
  português; qualquer ajuste técnico precisa continuar coerente com o livro.
- Prefira consistência terminológica entre capítulos.
- Ao revisar texto gerado por IA, trate-o como rascunho inicial. Revisão humana
  é obrigatória.

## Issues x Pull Requests

Abra issue quando:

- encontrar erro de tradução, referência quebrada ou inconsistências
- quiser propor padrão de glossário ou terminologia
- quiser coordenar a revisão de um capítulo inteiro

Abra pull request quando:

- já tiver uma correção concreta pronta
- estiver atualizando a infraestrutura do fork PT-BR
- estiver ajustando o conteúdo em `src-pt-br` sem mudar o escopo editorial do
  projeto

## Build e validação

Build da versão em inglês:

```bash
mdbook build
```

Build da versão PT-BR:

```bash
bash scripts/build-pt-br.sh
```

Validação de referências PT-BR:

```bash
bash scripts/validate-pt-br.sh
```

Lint de caminhos locais:

```bash
cargo run --bin lfp src-pt-br
```

## Licenciamento das contribuições

Para manter compatibilidade com o projeto-fonte, salvo indicação explícita em
contrário, contribuições submetidas para este repositório são aceitas sob os
termos `MIT OR Apache-2.0`.

## Mudanças em inglês

Se você encontrar um problema em `src`, prefira abrir issue ou PR no
`rust-lang/book`. O fork PT-BR não deve manter correções editoriais locais em
inglês que possam se perder no próximo sync com o upstream.

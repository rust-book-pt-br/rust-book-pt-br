# Rust Book PT-BR

Tradução comunitária não oficial, em português do Brasil, do livro mantido em
[`rust-lang/book`](https://github.com/rust-lang/book).

Este repositório distribui uma tradução derivada do texto original do livro e
mantém a estrutura do projeto-fonte para facilitar sincronização com o
upstream, revisão comunitária e publicação via mdBook.

## Estado do projeto

- Tradução inicial gerada com apoio de IA
- Revisão humana obrigatória antes de considerar qualquer trecho como estável
- Capítulos ainda podem conter inconsistências terminológicas ou trechos em
  revisão

## Organização do repositório

- `src` espelha o conteúdo em inglês vindo do upstream
- `src-pt-br` contém a trilha traduzida para PT-BR
- `scripts/build-pt-br.sh` gera a versão HTML em português
- `scripts/sync.sh` e `scripts/diff.sh` ajudam a acompanhar mudanças vindas de
  `rust-lang/book`

O fluxo normal de contribuição para tradução acontece em `src-pt-br`. Mudanças
editoriais em inglês devem ser encaminhadas ao projeto de origem.

## Como buildar localmente

Para a versão em inglês:

```bash
mdbook build
```

Para a versão PT-BR:

```bash
bash scripts/build-pt-br.sh
```

O build em português gera o site em `book-pt-br/`.

## Como contribuir

- Abra uma issue para erro de tradução, revisão de capítulo ou discussão de
  terminologia
- Envie PRs para `src-pt-br`, documentação do projeto e scripts locais
- Preserve links, âncoras, includes do mdBook e blocos de código
- Trate a tradução automática como base inicial, não como texto final

As instruções completas estão em [CONTRIBUTING.md](CONTRIBUTING.md).

## Sync com upstream

Este fork acompanha `rust-lang/book` e tenta manter `src` sincronizado com o
upstream. O fluxo esperado e:

1. sincronizar o conteúdo em inglês com `bash scripts/sync.sh`
2. inspecionar o que mudou com `bash scripts/diff.sh`
3. ajustar os capítulos correspondentes em `src-pt-br`

## Licença

Este repositório preserva o licenciamento dual do projeto-fonte:

- `MIT`
- `Apache-2.0`

Salvo indicação explícita em contrário, contribuições enviadas para este
repositório são aceitas sob os termos `MIT OR Apache-2.0`, para manter
compatibilidade com `rust-lang/book`.

Os arquivos [COPYRIGHT](COPYRIGHT), [LICENSE-MIT](LICENSE-MIT) e
[LICENSE-APACHE](LICENSE-APACHE) são mantidos na raiz sem alteração de
licenciamento do projeto original.

## Publicação

- Site PT-BR: <https://rust-book-pt-br.github.io/rust-book-pt-br/>
- Projeto-fonte: <https://github.com/rust-lang/book>
- Repositório PT-BR: <https://github.com/rust-book-pt-br/rust-book-pt-br>

## Aviso de não afiliação

Este projeto não é afiliado, endossado ou mantido oficialmente pela Rust
Foundation nem pelo Rust Project. O nome Rust é usado apenas para descrever a
origem da obra traduzida.

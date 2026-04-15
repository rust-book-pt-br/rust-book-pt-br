## Apêndice D: Ferramentas úteis de desenvolvimento

Neste apêndice, vamos ver algumas ferramentas úteis de desenvolvimento
fornecidas pelo projeto Rust. Vamos falar sobre formatação automática,
maneiras rápidas de aplicar correções sugeridas para avisos, um linter e
integração com IDEs.

### Formatação automática com `rustfmt`

A ferramenta `rustfmt` reformata seu código de acordo com o estilo de código
da comunidade. Muitos projetos colaborativos usam `rustfmt` para evitar
discussões sobre qual estilo usar ao escrever Rust: todo mundo formata o
código com a mesma ferramenta.

As instalações do Rust incluem `rustfmt` por padrão, então você já deve ter os
programas `rustfmt` e `cargo-fmt` no seu sistema. Esses dois comandos são
análogos a `rustc` e `cargo`, no sentido de que `rustfmt` permite um controle
mais refinado e `cargo-fmt` entende as convenções de um projeto que usa Cargo.
Para formatar qualquer projeto Cargo, execute o seguinte:

```console
$ cargo fmt
```

Executar esse comando reformata todo o código Rust na crate atual. Isso deve
alterar apenas o estilo do código, não sua semântica. Para mais informações
sobre `rustfmt`, consulte [sua documentação][rustfmt].

### Corrija seu código com `rustfix`

A ferramenta `rustfix` está incluída nas instalações do Rust e pode corrigir
automaticamente avisos do compilador para os quais haja uma maneira clara de
resolver o problema, e essa solução provavelmente será a que você quer. Você
provavelmente já viu avisos do compilador antes. Por exemplo, considere este
código:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
fn main() {
    let mut x = 42;
    println!("{x}");
}
```

Aqui, estamos definindo a variável `x` como mutável, mas na prática nunca a
mutamos. Rust nos avisa sobre isso:

```console
$ cargo build
   Compiling myprogram v0.1.0 (file:///projects/myprogram)
warning: variable does not need to be mutable
 --> src/main.rs:2:9
  |
2 |     let mut x = 0;
  |         ----^
  |         |
  |         help: remove this `mut`
  |
  = note: `#[warn(unused_mut)]` on by default
```

O aviso sugere que removamos a palavra-chave `mut`. Podemos aplicar essa
sugestão automaticamente com a ferramenta `rustfix` executando o comando
`cargo fix`:

```console
$ cargo fix
    Checking myprogram v0.1.0 (file:///projects/myprogram)
      Fixing src/main.rs (1 fix)
    Finished dev [unoptimized + debuginfo] target(s) in 0.59s
```

Quando olharmos _src/main.rs_ novamente, veremos que `cargo fix` alterou o
código:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
fn main() {
    let x = 42;
    println!("{x}");
}
```

A variável `x` agora é imutável, e o aviso não aparece mais.

Você também pode usar o comando `cargo fix` para migrar seu código entre
diferentes edições do Rust. As edições são abordadas no [Apêndice E][editions]<!--
ignore -->.

### Mais lints com Clippy

A ferramenta Clippy é uma coleção de lints para analisar seu código, de modo
que você possa detectar erros comuns e melhorar seu código Rust. Clippy está
incluído nas instalações padrão do Rust.

Para executar os lints do Clippy em qualquer projeto Cargo, digite o seguinte:

```console
$ cargo clippy
```

Por exemplo, suponha que você escreva um programa que usa uma aproximação de
uma constante matemática, como pi, assim:

<Listing file-name="src/main.rs">

```rust
fn main() {
    let x = 3.1415;
    let r = 8.0;
    println!("the area of the circle is {}", x * r * r);
}
```

</Listing>

Executar `cargo clippy` nesse projeto resulta neste erro:

```text
error: approximate value of `f{32, 64}::consts::PI` found
 --> src/main.rs:2:13
  |
2 |     let x = 3.1415;
  |             ^^^^^^
  |
  = note: `#[deny(clippy::approx_constant)]` on by default
  = help: consider using the constant directly
  = help: for further information visit https://rust-lang.github.io/rust-clippy/master/index.html#approx_constant
```

Esse erro informa que Rust já possui uma constante `PI` mais precisa definida e
que seu programa seria mais correto se usasse essa constante. Você então
alteraria seu código para usar `PI`.

O código a seguir não resulta em erros nem avisos do Clippy:

<Listing file-name="src/main.rs">

```rust
fn main() {
    let x = std::f64::consts::PI;
    let r = 8.0;
    println!("the area of the circle is {}", x * r * r);
}
```

</Listing>

Para mais informações sobre Clippy, consulte [sua documentação][clippy].

### Integração com IDEs usando `rust-analyzer`

Para ajudar na integração com IDEs, a comunidade Rust recomenda usar
[`rust-analyzer`][rust-analyzer]<!-- ignore -->. Essa ferramenta é um conjunto
de utilitários centrados no compilador que falam o [Language Server
Protocol][lsp]<!-- ignore -->, que é uma especificação para IDEs e linguagens
de programação se comunicarem entre si. Diferentes clientes podem usar
`rust-analyzer`, como [o plug-in Rust Analyzer para Visual Studio Code][vscode].

Visite a [página inicial][rust-analyzer]<!-- ignore --> do projeto
`rust-analyzer` para obter instruções de instalação e, em seguida, instale o
suporte ao servidor de linguagem na IDE que você usa. Sua IDE ganhará
recursos como autocompletar, ir para a definição e erros inline.

[rustfmt]: https://github.com/rust-lang/rustfmt
[editions]: appendix-05-editions.md
[clippy]: https://github.com/rust-lang/rust-clippy
[rust-analyzer]: https://rust-analyzer.github.io
[lsp]: http://langserver.org/
[vscode]: https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer

## Olá, Cargo!

Cargo é o sistema de build e gerenciador de pacotes do Rust. A maioria dos
rustaceanos usa essa ferramenta para gerenciar seus projetos Rust, porque Cargo
cuida de muitas tarefas para você, como compilar seu código, baixar as
bibliotecas das quais ele depende e compilar essas bibliotecas. Chamamos as
bibliotecas de que seu código precisa de _dependências_.

Os programas mais simples em Rust, como o que escrevemos até agora, não têm
dependências. Se tivéssemos criado o projeto “Hello, world!” com o Cargo, ele
usaria apenas a parte do Cargo responsável por compilar seu código. Conforme
você escrever programas Rust mais complexos, adicionará dependências e, se
iniciar o projeto com Cargo, isso será muito mais fácil.

Como a vasta maioria dos projetos Rust usa Cargo, o restante deste livro
pressupõe que você também o está usando. Cargo vem instalado com Rust se você
usou os instaladores oficiais discutidos na seção
[“Instalação”][installation]<!-- ignore -->. Se instalou o Rust de outra forma,
verifique se o Cargo está instalado digitando o seguinte no terminal:

```console
$ cargo --version
```

Se você vir um número de versão, então está tudo certo! Se vir um erro, como
`command not found`, consulte a documentação do seu método de instalação para
descobrir como instalar Cargo separadamente.

### Criando um projeto com Cargo

Vamos criar um novo projeto usando Cargo e observar como ele difere do nosso
projeto original “Hello, world!”. Volte para o diretório _projects_ ou para o
local onde decidiu guardar seu código. Em qualquer sistema operacional, execute
o seguinte:

```console
$ cargo new hello_cargo
$ cd hello_cargo
```

O primeiro comando cria um novo diretório e projeto chamados _hello_cargo_.
Demos ao projeto o nome _hello_cargo_, e o Cargo cria seus arquivos em um
diretório com esse mesmo nome.

Entre no diretório _hello_cargo_ e liste os arquivos. Você verá que o Cargo
gerou dois arquivos e um diretório para nós: um arquivo _Cargo.toml_ e um
diretório _src_ com um arquivo _main.rs_ dentro dele.

Ele também inicializou um novo repositório Git junto com um arquivo
_.gitignore_. Os arquivos do Git não serão gerados se você executar
`cargo new` dentro de um repositório Git já existente; você pode mudar esse
comportamento usando `cargo new --vcs=git`.

> Nota: Git é um sistema de controle de versão bastante comum. Você pode mudar
> `cargo new` para usar outro sistema de controle de versão ou nenhum, usando
> a flag `--vcs`. Execute `cargo new --help` para ver as opções disponíveis.

Abra _Cargo.toml_ no editor de texto de sua preferência. Ele deve se parecer
com o código da Listagem 1-2.

<Listing number="1-2" file-name="Cargo.toml" caption="Conteúdo de *Cargo.toml* gerado por `cargo new`">

```toml
[package]
name = "hello_cargo"
version = "0.1.0"
edition = "2024"

[dependencies]
```

</Listing>

Esse arquivo está no formato [_TOML_][toml]<!-- ignore --> (_Tom’s Obvious,
Minimal Language_), que é o formato de configuração do Cargo.

A primeira linha, `[package]`, é um cabeçalho de seção que indica que as
declarações seguintes configuram um package. À medida que adicionarmos mais
informações a esse arquivo, acrescentaremos outras seções.

As três linhas seguintes definem as informações de configuração de que o Cargo
precisa para compilar seu programa: o nome, a versão e a edição do Rust a ser
usada. Falaremos sobre a chave `edition` no [Apêndice E][appendix-e]<!-- ignore -->.

A última linha, `[dependencies]`, marca o começo de uma seção na qual você
listará as dependências do projeto. Em Rust, pacotes de código são chamados de
_crates_. Não precisaremos de outros crates para este projeto, mas
precisaremos no primeiro projeto do Capítulo 2, então usaremos essa seção
naquela ocasião.

Agora abra _src/main.rs_ e dê uma olhada:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
fn main() {
    println!("Hello, world!");
}
```

O Cargo gerou para você um programa “Hello, world!”, exatamente como o que
escrevemos na Listagem 1-1! Até aqui, as diferenças entre o nosso projeto e o
projeto gerado pelo Cargo são que o Cargo colocou o código dentro do diretório
_src_ e criou um arquivo de configuração _Cargo.toml_ no diretório superior.

O Cargo espera que seus arquivos-fonte fiquem dentro do diretório _src_. O
diretório de topo do projeto deve conter apenas arquivos README, informações de
licença, arquivos de configuração e qualquer outra coisa que não esteja
diretamente relacionada ao código. Usar Cargo ajuda a organizar seus projetos.
Há um lugar para cada coisa, e cada coisa fica em seu lugar.

Se você iniciou um projeto sem usar Cargo, como fizemos com o projeto “Hello,
world!”, pode convertê-lo para um projeto que use Cargo. Mova o código do
projeto para o diretório _src_ e crie um arquivo _Cargo.toml_ adequado. Uma
forma simples de obter esse arquivo _Cargo.toml_ é executar `cargo init`, que o
criará automaticamente para você.

### Compilando e executando um projeto Cargo

Agora vamos ver o que muda quando compilamos e executamos o programa “Hello,
world!” com Cargo! No diretório _hello_cargo_, compile o projeto digitando:

```console
$ cargo build
   Compiling hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 2.85 secs
```

Esse comando cria um executável em _target/debug/hello_cargo_ ou
_target\debug\hello_cargo.exe_ no Windows, em vez de gerá-lo no diretório
atual. Como o build padrão é de depuração, o Cargo coloca o binário em um
diretório chamado _debug_. Você pode executar o executável com este comando:

```console
$ ./target/debug/hello_cargo # ou .\target\debug\hello_cargo.exe no Windows
Hello, world!
```

Se tudo correr bem, `Hello, world!` deve ser impresso no terminal. Executar
`cargo build` pela primeira vez também faz o Cargo criar um novo arquivo no
nível superior do projeto: _Cargo.lock_. Esse arquivo mantém registro das
versões exatas das dependências do projeto. Como este projeto não tem
dependências, o arquivo é bem enxuto. Você nunca precisará alterá-lo
manualmente; o Cargo gerencia seu conteúdo para você.

Acabamos de compilar um projeto com `cargo build` e executá-lo com
`./target/debug/hello_cargo`, mas também podemos usar `cargo run` para compilar
o código e depois executar o binário resultante em um único comando:

```console
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.0 secs
     Running `target/debug/hello_cargo`
Hello, world!
```

Usar `cargo run` é mais conveniente do que lembrar de executar `cargo build` e
depois usar o caminho completo até o binário, então a maioria dos
desenvolvedores prefere `cargo run`.

Observe que, desta vez, não vimos a saída indicando que o Cargo estava
compilando `hello_cargo`. O Cargo percebeu que os arquivos não haviam mudado,
então ele não recompilou nada; apenas executou o binário. Se você tivesse
modificado o código-fonte, o Cargo recompilaria o projeto antes de executá-lo,
e você veria esta saída:

```console
$ cargo run
   Compiling hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.33 secs
     Running `target/debug/hello_cargo`
Hello, world!
```

O Cargo também oferece um comando chamado `cargo check`. Esse comando verifica
rapidamente se seu código compila, mas não produz um executável:

```console
$ cargo check
   Checking hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.32 secs
```

Por que você não iria querer um executável? Muitas vezes, `cargo check` é bem
mais rápido do que `cargo build`, porque pula a etapa de gerar o executável. Se
você estiver checando seu trabalho continuamente enquanto escreve código, usar
`cargo check` acelera o processo de descobrir se o projeto ainda está
compilando! Por isso, muitos rustaceanos executam `cargo check`
periodicamente enquanto escrevem seus programas, para garantir que tudo
continua compilando. Depois, quando estão prontos para usar o executável,
executam `cargo build`.

Vamos recapitular o que aprendemos até aqui sobre Cargo:

- Podemos criar um projeto usando `cargo new`.
- Podemos compilar um projeto usando `cargo build`.
- Podemos compilar e executar um projeto em uma única etapa usando `cargo run`.
- Podemos verificar se há erros em um projeto sem produzir um binário usando
  `cargo check`.
- Em vez de salvar o resultado do build no mesmo diretório do código, o Cargo
  o armazena no diretório _target/debug_.

Uma vantagem adicional do Cargo é que os comandos são os mesmos
independentemente do sistema operacional em que você está trabalhando. Por
isso, a partir deste ponto, deixaremos de fornecer instruções separadas para
Linux e macOS versus Windows.

### Compilando para release

Quando o projeto finalmente estiver pronto para release, você pode usar
`cargo build --release` para compilá-lo com otimizações. Esse comando criará um
executável em _target/release_ em vez de _target/debug_. As otimizações fazem o
código Rust rodar mais rápido, mas ativá-las aumenta o tempo de compilação.
Por isso há dois perfis diferentes: um para desenvolvimento, quando você quer
recompilar rapidamente e com frequência, e outro para gerar o programa final
que será entregue ao usuário, que não será recompilado repetidamente e deverá
executar o mais rápido possível. Se você estiver medindo o tempo de execução do
seu código, lembre-se de rodar `cargo build --release` e fazer o benchmark com
o executável em _target/release_.

<!-- Old headings. Do not remove or links may break. -->
<a id="cargo-as-convention"></a>

### Aproveitando as convenções do Cargo

Em projetos simples, o Cargo não oferece muito mais valor do que usar `rustc`
diretamente, mas ele mostra seu valor à medida que os programas ficam mais
complexos. Quando um programa cresce para múltiplos arquivos ou passa a precisar
de dependências, é muito mais fácil deixar o Cargo coordenar o build.

Mesmo sendo simples, o projeto `hello_cargo` já usa grande parte do ferramental
real que você vai utilizar no restante da sua carreira com Rust. Na prática,
para trabalhar em qualquer projeto existente, você pode usar os comandos a
seguir para baixar o código com Git, entrar no diretório do projeto e compilar:

```console
$ git clone example.org/someproject
$ cd someproject
$ cargo build
```

Para mais informações sobre Cargo, consulte [sua documentação][cargo].

## Resumo

Você já começou muito bem sua jornada com Rust! Neste capítulo, você aprendeu
a:

- Instalar a versão estável mais recente do Rust usando `rustup`.
- Atualizar para uma versão mais nova do Rust.
- Abrir a documentação instalada localmente.
- Escrever e executar um programa “Hello, world!” usando `rustc` diretamente.
- Criar e executar um novo projeto usando as convenções do Cargo.

Este é um ótimo momento para construir um programa mais substancial e se
acostumar a ler e escrever código Rust. Então, no Capítulo 2, construiremos um
programa de jogo de adivinhação. Se preferir começar entendendo como conceitos
comuns de programação funcionam em Rust, veja o Capítulo 3 e depois volte ao
Capítulo 2.

[installation]: ch01-01-installation.html#instalação
[toml]: https://toml.io
[appendix-e]: appendix-05-editions.html
[cargo]: https://doc.rust-lang.org/cargo/

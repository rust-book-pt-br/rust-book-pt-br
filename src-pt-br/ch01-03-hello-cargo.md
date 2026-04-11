# Olá, Cargo!

Cargo é o sistema de build e gerenciador de pacotes do Rust. A maioria dos
*Rustáceos* usa essa ferramenta para gerenciar seus projetos porque o Cargo
cuida de muitas tarefas para você, como compilar seu código, fazer o download
das bibliotecas das quais ele depende e compilar essas bibliotecas. Chamamos de
*dependências* as bibliotecas de que seu código precisa.

Os programas Rust mais simples, como o que escrevemos até agora, não têm
dependências; portanto, se tivéssemos criado o projeto Hello World com o Cargo,
ele usaria apenas a parte do Cargo que cuida da compilação do seu código. Ao
escrever programas Rust mais complexos, você vai querer adicionar
dependências, e, se iniciar o projeto usando o Cargo, isso será muito mais
fácil.

Como a grande maioria dos projetos Rust usa Cargo, o restante deste livro pressupõe que você também esteja usando Cargo. Cargo vem instalado com o próprio Rust, se você usou os instaladores oficiais, conforme descrito na seção “Instalação”. Se você instalou Rust por outros meios, poderá verificar se possui o Cargo instalado inserindo o seguinte em seu terminal:

```text
$ cargo --version
```

Se você vir um número de versão, ótimo! Se você vir um erro como `command not found`, consulte a documentação do seu método de instalação para determinar como instalar o Cargo separadamente.

### Criando Projetos com Cargo

Vamos criar um novo projeto usando Cargo e ver como ele difere do nosso projeto original Hello World. Navegue de volta para o diretório *projects* (ou onde quer que você tenha decidido colocar seu código) e, em seguida, em qualquer sistema operacional:

```text
$ cargo new hello_cargo --bin
$ cd hello_cargo
```

Isso cria um novo executável binário chamado `hello_cargo`. O argumento `--bin`
passado para `cargo new` cria um aplicativo executável, geralmente chamado
apenas de *binário*, em vez de uma biblioteca. Atribuímos `hello_cargo` como o
nome do nosso projeto, e o Cargo cria seus arquivos em um diretório com o mesmo
nome.

Vá para o diretório *hello_cargo* e liste os arquivos. Você verá que o Cargo
gerou dois arquivos e um diretório para nós: *Cargo.toml* e o diretório *src*,
com um arquivo *main.rs* dentro. Ele também inicializou um novo repositório
git, junto com um arquivo *.gitignore*.

> Nota: Git é um sistema de controle de versão comum. Você pode alterar `cargo new` para usar um sistema de controle de versão diferente, ou nenhum sistema de controle de versão, usando o sinalizador `--vcs`. Execute `cargo new --help` para ver as opções disponíveis.

Abra *Cargo.toml* no seu editor de texto de sua escolha. Deve ser semelhante ao código na Listagem 1-2:

<span class="filename">Nome do arquivo: Cargo.toml</span>

```toml
[package]
name = "hello_cargo"
version = "0.1.0"
authors = ["Your Name <you@example.com>"]

[dependencies]
```

<span class="caption">Listagem 1-2: Conteúdo de *Cargo.toml* gerado por `cargo new`</span>

Esse arquivo está no formato [*TOML*][toml]<!-- ignore -->, que é o formato de
configuração usado pelo Cargo.

[toml]: https://github.com/toml-lang/toml

A primeira linha, `[package]`, é um cabeçalho de seção que indica que as seguintes instruções estão configurando um pacote. À medida que adicionamos mais informações a este arquivo, adicionaremos outras seções.

As próximas três linhas definem as informações de configuração de que o Cargo
precisa para compilar seu programa: nome, versão e autor. O Cargo obtém seu
nome e e-mail do ambiente; portanto, se isso não estiver correto, corrija e
salve o arquivo.

A última linha, `[dependencies]`, marca o início da seção em que você listará
as dependências do seu projeto. Em Rust, pacotes de código são chamados de
*crates*. Não precisaremos de outras crates para este projeto, mas
precisaremos no primeiro projeto do Capítulo 2, então usaremos essa seção mais
adiante.

Agora abra *src/main.rs* e olhe:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
fn main() {
    println!("Hello, world!");
}
```

O Cargo gerou um “Hello, world!” para você, exatamente como o que escrevemos na
Listagem 1-1. Até agora, as diferenças entre o projeto anterior e o projeto
gerado pelo Cargo são que, com o Cargo, nosso código fica no diretório *src* e
temos um arquivo de configuração *Cargo.toml* no diretório superior.

O Cargo espera que seus arquivos-fonte fiquem dentro do diretório *src*, para
que o diretório superior do projeto seja usado apenas para READMEs, informações
de licença, arquivos de configuração e qualquer outra coisa não relacionada ao
seu código. Dessa forma, o uso do Cargo ajuda a manter seus projetos
organizados. Há um lugar para tudo, e tudo fica em seu devido lugar.

Se você iniciou um projeto que não usa o Cargo, como fizemos com nosso projeto
no diretório *hello_world*, pode convertê-lo em um projeto que usa o Cargo
movendo o código para o diretório *src* e criando um *Cargo.toml* apropriado.

### Construindo e Executando um projeto Cargo

Agora, vamos ver o que há de diferente na criação e execução do seu programa Hello World através do Cargo! No diretório do projeto, construa seu projeto digitando os seguintes comandos:

```text
$ cargo build
   Compiling hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 2.85 secs
```

Isso cria um arquivo executável em *target/debug/hello_cargo* (ou 
*target\\debug\\hello_cargo.exe* no Windows), que você pode executar com 
este comando:

```text
$ ./target/debug/hello_cargo # or .\target\debug\hello_cargo.exe on Windows
Hello, world!
```

Bam! Se tudo correr bem, `Hello, world!` deve ser impresso no terminal mais uma vez. A execução do `cargo build` pela primeira vez também faz com que o Cargo crie um novo arquivo no nível superior chamado *Cargo.lock*, que é usado para acompanhar as versões exatas das dependências do seu projeto. Este projeto não tem dependências, portanto o arquivo é um pouco esparso. Você nunca precisará tocar nesse arquivo; Cargo gerenciará seu conteúdo para você.

Nós apenas construímos um projeto com `cargo build` e o executamos com 
`./target/debug/hello_cargo`, mas também podemos usar o `cargo run` para compilar e então executar tudo de uma só vez:

```text
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.0 secs
     Running `target/debug/hello_cargo`
Hello, world!
```

Observe que, desta vez, não vimos a saída nos dizendo que Cargo estava compilando `hello_cargo`. Cargo descobriu que os arquivos não foram alterados; portanto, apenas executou o binário. Se você tivesse modificado seu código-fonte, Cargo reconstruiria o projeto antes de executá-lo e você teria visto resultados como este:

```text
$ cargo run
   Compiling hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.33 secs
     Running `target/debug/hello_cargo`
Hello, world!
```

Finalmente, há `cargo check`. Este comando verificará rapidamente seu código para garantir que ele seja compilado, mas não se incomode em produzir um executável:

```text
$ cargo check
   Compiling hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.32 secs
```

Por que você não gostaria de um executável? O `cargo check` geralmente é muito
mais rápido que o `cargo build`, porque pula toda a etapa de produção do
executável. Se você estiver verificando seu trabalho ao longo de todo o
processo de escrita do código, usar `cargo check` vai acelerar as coisas.
Assim, muitos *Rustáceos* executam `cargo check` periodicamente enquanto
escrevem seus programas para garantir que tudo continue compilando e, em
seguida, executam `cargo build` quando estão prontos para rodar.


Então, para recapitular, usando Cargo:

- Podemos construir um projeto usando `cargo build` ou `cargo check`
- Podemos construir e executar o projeto em uma única etapa com `cargo run`
- Em vez de o resultado da compilação ser colocado no mesmo diretório que o nosso código, Cargo o colocará no diretório *target/debug*.

Uma vantagem final do uso do Cargo é que os comandos são os mesmos, independentemente do sistema operacional em que você esteja; portanto, neste momento, não forneceremos mais instruções específicas para Linux e Mac versus Windows.

### Criando para Liberação

Quando seu projeto estiver finalmente pronto para lançamento, você poderá usar
`cargo build --release` para compilá-lo com otimizações. Isso criará um
executável em *target/release* em vez de *target/debug*. Essas otimizações
tornam seu código Rust mais rápido, mas ativá-las faz a compilação levar mais
tempo. É por isso que existem dois perfis diferentes: um para desenvolvimento,
quando você quer reconstruir de forma rápida e frequente, e outro para a
versão final do programa, que será distribuída a um usuário, não será
recompilada repetidamente e deverá executar o mais rápido possível. Se você
estiver comparando o tempo de execução do seu código, lembre-se de executar
`cargo build --release` e fazer a comparação com o executável em
*target/release*.


### Cargo como Convenção

Em projetos simples, Cargo não fornece muito valor ao usar apenas `rustc`, mas provará seu valor à medida que você continua. Com projetos complexos compostos por várias *crates*, é muito mais fácil deixar Cargo coordenar a construção.

Embora o projeto `hello_cargo` seja simples, agora ele usa grande parte das ferramentas reais que você usará para o resto de sua carreira em Rust. De fato, para trabalhar em qualquer projeto existente, você pode usar os seguintes comandos para verificar o código usando o Git, mudar para o diretório do projeto e criar:

```text
$ git clone someurl.com/someproject
$ cd someproject
$ cargo build
```

Para mais informações sobre o Cargo, consulte a [documentação] (em inglês).

[documentação]: https://doc.rust-lang.org/cargo/

## Resumo

Você já começou bem a sua jornada Rust! Neste capítulo, você:

* Instalou a versão estável do Rust usando `rustup`
* Atualizou para uma versão mais recente
* Acessou a documentação instalada localmente
* Escreveu um programa “Hello, world!” usando diretamente o `rustc`
* Criou e executou um novo projeto usando as convenções do Cargo

Este é um ótimo momento para criar um programa mais substancial, para se
acostumar a ler e escrever código em Rust. No Capítulo 2, criaremos um jogo de
adivinhação. Se você preferir começar aprendendo como conceitos comuns de
programação funcionam em Rust, consulte o Capítulo 3 e, em seguida, retorne ao
Capítulo 2.

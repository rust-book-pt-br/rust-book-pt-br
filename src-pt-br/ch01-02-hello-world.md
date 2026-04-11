## Olá, Mundo!

Agora que você instalou o Rust, chegou a hora de escrever seu primeiro
programa em Rust. É tradicional, ao aprender uma nova linguagem, escrever um
pequeno programa que imprima `Hello, world!` na tela, então faremos o mesmo
aqui.

> Nota: Este livro presume familiaridade básica com a linha de comando. Rust
> não faz exigências específicas sobre edição, tooling ou o local onde seu
> código vive, então, se você preferir usar uma IDE em vez da linha de
> comando, fique à vontade para usar a sua favorita. Muitas IDEs já têm algum
> grau de suporte a Rust; consulte a documentação da sua IDE para detalhes. A
> equipe do Rust tem investido bastante em viabilizar um ótimo suporte a IDEs
> por meio do `rust-analyzer`. Veja o [Apêndice D][devtools]<!-- ignore --> para
> mais detalhes.

<!-- Old headings. Do not remove or links may break. -->
<a id="creating-a-project-directory"></a>

### Configuração do diretório do projeto

Você começará criando um diretório para guardar seu código Rust. Para o Rust,
não importa onde seu código fica, mas, para os exercícios e projetos deste
livro, sugerimos criar um diretório _projects_ dentro do seu diretório pessoal
e manter todos os seus projetos lá.

Abra um terminal e digite os comandos a seguir para criar o diretório
_projects_ e, dentro dele, um diretório para o projeto “Hello, world!”.

No Linux, no macOS e no PowerShell do Windows, digite isto:

```console
$ mkdir ~/projects
$ cd ~/projects
$ mkdir hello_world
$ cd hello_world
```

No CMD do Windows, digite isto:

```cmd
> mkdir "%USERPROFILE%\projects"
> cd /d "%USERPROFILE%\projects"
> mkdir hello_world
> cd hello_world
```

<!-- Old headings. Do not remove or links may break. -->
<a id="writing-and-running-a-rust-program"></a>

### Fundamentos de um programa Rust

Em seguida, crie um novo arquivo-fonte e chame-o de _main.rs_. Arquivos Rust
sempre terminam com a extensão _.rs_. Se você estiver usando mais de uma
palavra no nome do arquivo, a convenção é separá-las com underscore. Por
exemplo, use _hello_world.rs_ em vez de _helloworld.rs_.

Agora abra o arquivo _main.rs_ que acabou de criar e digite o código da
Listagem 1-1.

<Listing number="1-1" file-name="main.rs" caption="Um programa que imprime `Hello, world!`">

```rust
fn main() {
    println!("Hello, world!");
}
```

</Listing>

Salve o arquivo e volte para a janela do terminal no diretório
_~/projects/hello_world_. No Linux ou no macOS, digite os seguintes comandos
para compilar e executar o arquivo:

```console
$ rustc main.rs
$ ./main
Hello, world!
```

No Windows, use o comando `.\main` em vez de `./main`:

```powershell
> rustc main.rs
> .\main
Hello, world!
```

Independentemente do sistema operacional, a string `Hello, world!` deve ser
impressa no terminal. Se isso não acontecer, volte à parte
[“Solucionando problemas”][troubleshooting]<!-- ignore --> da seção de
instalação para ver formas de conseguir ajuda.

Se `Hello, world!` apareceu, parabéns! Você escreveu oficialmente um programa
em Rust. Isso faz de você um programador Rust: boas-vindas!

<!-- Old headings. Do not remove or links may break. -->

<a id="anatomy-of-a-rust-program"></a>

### Anatomia de um programa Rust

Vamos revisar esse programa “Hello, world!” em detalhes. Aqui está a primeira
peça do quebra-cabeça:

```rust
fn main() {

}
```

Essas linhas definem uma função chamada `main`. A função `main` é especial:
ela é sempre o primeiro código executado em todo programa Rust executável.
Aqui, a primeira linha declara uma função chamada `main` que não recebe
parâmetros e não retorna nada. Se houvesse parâmetros, eles apareceriam dentro
dos parênteses (`()`).

O corpo da função fica entre `{}`. Rust exige chaves ao redor do corpo de todas
as funções. É considerado bom estilo colocar a chave de abertura na mesma linha
da declaração da função, com um espaço entre elas.

> Nota: Se você quiser manter um estilo padrão entre projetos Rust, pode usar
> uma ferramenta de formatação automática chamada `rustfmt` para formatar seu
> código de um jeito específico. Falaremos mais sobre `rustfmt` no
> [Apêndice D][devtools]<!-- ignore -->. A equipe do Rust inclui essa ferramenta
> na distribuição padrão do Rust, assim como `rustc`, então ela provavelmente
> já está instalada no seu computador!

O corpo da função `main` contém o seguinte código:

```rust
println!("Hello, world!");
```

Essa linha faz todo o trabalho deste pequeno programa: ela imprime texto na
tela. Há três detalhes importantes aqui.

Primeiro, `println!` chama uma macro do Rust. Se estivesse chamando uma função,
seria escrito como `println` sem o `!`. Macros em Rust são uma forma de
escrever código que gera código para estender a sintaxe da linguagem, e vamos
discuti-las com mais detalhes no [Capítulo 20][ch20-macros]<!-- ignore -->. Por
enquanto, basta saber que usar `!` significa que você está chamando uma macro,
não uma função comum, e que macros nem sempre seguem as mesmas regras das
funções.

Segundo, você vê a string `"Hello, world!"`. Passamos essa string como
argumento para `println!`, e ela é impressa na tela.

Terceiro, terminamos a linha com ponto e vírgula (`;`), o que indica que essa
expressão acabou e a próxima já pode começar. A maioria das linhas de código
Rust termina com ponto e vírgula.

<!-- Old headings. Do not remove or links may break. -->
<a id="compiling-and-running-are-separate-steps"></a>

### Compilação e execução

Você acabou de executar um programa recém-criado, então vamos examinar cada
etapa do processo.

Antes de executar um programa Rust, você precisa compilá-lo usando o compilador
Rust, digitando o comando `rustc` e passando o nome do arquivo-fonte, assim:

```console
$ rustc main.rs
```

Se você tem experiência com C ou C++, perceberá que isso se parece com `gcc`
ou `clang`. Após uma compilação bem-sucedida, Rust gera um executável binário.

No Linux, no macOS e no PowerShell do Windows, você pode ver o executável
digitando o comando `ls` no shell:

```console
$ ls
main  main.rs
```

No Linux e no macOS, você verá dois arquivos. No PowerShell do Windows, verá
os mesmos três arquivos que veria usando o CMD. No CMD do Windows, você
digitaria o seguinte:

```cmd
> dir /B %= a opção /B diz para mostrar apenas os nomes dos arquivos =%
main.exe
main.pdb
main.rs
```

Isso mostra o arquivo-fonte com a extensão _.rs_, o arquivo executável
(_main.exe_ no Windows, mas _main_ nas demais plataformas) e, no Windows, um
arquivo com informações de depuração com a extensão _.pdb_. A partir daí, você
executa o arquivo _main_ ou _main.exe_, assim:

```console
$ ./main # ou .\main no Windows
```

Se o seu _main.rs_ é o programa “Hello, world!”, essa linha imprimirá
`Hello, world!` no terminal.

Se você estiver mais acostumado a uma linguagem dinâmica, como Ruby, Python ou
JavaScript, talvez não esteja acostumado a compilar e executar um programa como
etapas separadas. Rust é uma linguagem _compilada antecipadamente_ (_ahead of
time_), o que significa que você pode compilar um programa e entregar o
executável para outra pessoa, e ela poderá executá-lo mesmo sem ter Rust
instalado. Se você entregar um arquivo _.rb_, _.py_ ou _.js_, a pessoa
precisará ter, respectivamente, uma implementação de Ruby, Python ou
JavaScript instalada. Mas, nessas linguagens, normalmente basta um único
comando para compilar e executar o programa. Tudo envolve trade-offs no design
de linguagens.

Compilar apenas com `rustc` funciona bem para programas simples, mas, à medida
que o projeto cresce, você vai querer gerenciar todas as opções e facilitar o
compartilhamento do código. Em seguida, apresentaremos a ferramenta Cargo, que
ajudará você a escrever programas Rust do mundo real.

[troubleshooting]: ch01-01-installation.html#troubleshooting
[devtools]: appendix-04-useful-development-tools.html
[ch20-macros]: ch20-05-macros.html

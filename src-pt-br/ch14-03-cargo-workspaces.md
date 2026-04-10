## Workspaces do Cargo

No Capítulo 12, construímos um pacote que incluía um binário crate e uma biblioteca
crate. À medida que seu projeto se desenvolve, você poderá descobrir que a biblioteca crate
continua a crescer e você deseja dividir ainda mais seu pacote em
biblioteca múltipla crates. Cargo oferece um recurso chamado _workspaces_ que pode
ajudar a gerenciar vários pacotes relacionados desenvolvidos em conjunto.

### Criando um workspace

Um _workspace_ é um conjunto de pacotes que compartilham o mesmo _Cargo.lock_ e saída
diretório. Vamos fazer um projeto usando um workspace – usaremos código trivial então
que podemos nos concentrar na estrutura do workspace. Existem vários
maneiras de estruturar um workspace, então mostraremos apenas uma maneira comum. Teremos um
workspace contendo um binário e duas bibliotecas. O binário, que fornecerá
a funcionalidade principal dependerá das duas bibliotecas. Uma biblioteca irá
forneça uma função `add_one` e a outra biblioteca uma função `add_two`.
Esses três crates farão parte do mesmo workspace. Começaremos criando
um novo diretório para o workspace:

```console
$ mkdir add
$ cd add
```

A seguir, no diretório _add_, criamos o arquivo _Cargo.toml_ que irá
configure todo o workspace. Este arquivo não terá uma seção `[package]`.
Em vez disso, começará com uma seção ` [workspace]`que nos permitirá adicionar
membros para o workspace. Também fazemos questão de usar os melhores e mais recentes
versão do algoritmo de resolução do Cargo em nosso workspace definindo o
Valor ` resolver`para ` "3"`:

<span class="filename">Filename: Cargo.toml</span>

```toml
{{#include ../listings/ch14-more-about-cargo/no-listing-01-workspace/add/Cargo.toml}}
```

A seguir, criaremos o binário `adder` crate executando `cargo new` dentro do
_adicionar_ diretório:

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/output-only-01-adder-crate/add
remove `members = ["adder"]` from Cargo.toml
rm -rf adder
cargo new adder
copy output below
-->

```console
$ cargo new adder
     Created binary (application) `adder` package
      Adding `adder` as member of workspace at `file:///projects/add`
```

Executar `cargo new` dentro de um workspace também adiciona automaticamente o arquivo recém-criado
pacote para a chave `members` na definição `[workspace]` no workspace
_Cargo.toml_, assim:

```toml
{{#include ../listings/ch14-more-about-cargo/output-only-01-adder-crate/add/Cargo.toml}}
```

Neste ponto, podemos construir o workspace executando `cargo build`. Os arquivos
em seu diretório _add_ deve ficar assim:

```text
├── Cargo.lock
├── Cargo.toml
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

O workspace possui um diretório _target_ no nível superior onde o compilado
artefatos serão colocados; o pacote `adder` não possui seu próprio
diretório _destino_. Mesmo se executássemos `cargo build` de dentro do
diretório _adder_, os artefatos compilados ainda terminariam em _add/target_
em vez de _adicionar/adicionar/destino_. Cargo estrutura o diretório _target_ em um
workspace assim porque o crates em um workspace deve depender de
um ao outro. Se cada crate tivesse seu próprio diretório _target_, cada crate teria
para recompilar cada um dos outros crates no workspace para colocar os artefatos
em seu próprio diretório _target_. Ao compartilhar um diretório _target_, o crates
pode evitar reconstruções desnecessárias.

### Criando o segundo pacote no workspace

A seguir, vamos criar outro pacote membro no workspace e chamá-lo
`add_one `. Gere uma nova biblioteca crate chamada` add_one`:

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/output-only-02-add-one/add
remove `"add_one"` from `members` list in Cargo.toml
rm -rf add_one
cargo new add_one --lib
copy output below
-->

```console
$ cargo new add_one --lib
     Created library `add_one` package
      Adding `add_one` as member of workspace at `file:///projects/add`
```

O _Cargo.toml_ de nível superior agora incluirá o caminho _add_one_ no `members`
lista:

<span class="filename">Filename: Cargo.toml</span>

```toml
{{#include ../listings/ch14-more-about-cargo/no-listing-02-workspace-with-two-crates/add/Cargo.toml}}
```

Seu diretório _add_ agora deve ter estes diretórios e arquivos:

```text
├── Cargo.lock
├── Cargo.toml
├── add_one
│   ├── Cargo.toml
│   └── src
│       └── lib.rs
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

In the _add_one/src/lib.rs_ file, let’s add an `add_one` function:

<span class="filename">Filename: add_one/src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch14-more-about-cargo/no-listing-02-workspace-with-two-crates/add/add_one/src/lib.rs}}
```

Agora podemos ter o pacote `adder` com nosso binário dependente do `add_one`
pacote que contém nossa biblioteca. Primeiro, precisaremos adicionar uma dependência de caminho em
` add_one`para _adder/Cargo.toml_.

<span class="filename">Filename: adder/Cargo.toml</span>

```toml
{{#include ../listings/ch14-more-about-cargo/no-listing-02-workspace-with-two-crates/add/adder/Cargo.toml:6:7}}
```

Cargo não assume que crates em um workspace dependerá um do outro, então
precisamos ser explícitos sobre as relações de dependência.

A seguir, vamos usar a função `add_one` (do `add_one` crate) no
`adder ` crate. Abra o arquivo _adder/src/main.rs_ e altere o`main `
função para chamar a função` add_one`, como na Listagem 14-7.

<Listing number="14-7" file-name="adder/src/main.rs" caption="Usando o crate de biblioteca `add_one` a partir do crate `adder`">

```rust,ignore
{{#rustdoc_include ../listings/ch14-more-about-cargo/listing-14-07/add/adder/src/main.rs}}
```

</Listing>

Vamos construir o workspace executando `cargo build` no _add_ de nível superior
diretório!

<!-- manual-regeneration
listagens de cd/ch14-more-about-cargo/listing-14-07/add
Construção cargo
copie a saída abaixo; o script de atualização de saída não manipula subdiretórios em caminhos corretamente
-->

```console
$ cargo build
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.22s
```

Para executar o binário crate do diretório _add_, podemos especificar qual pacote
no workspace queremos executar usando o argumento `-p` e o nome do pacote
com `cargo run`:

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/listing-14-07/add
cargo run -p adder
copy output below; the output updating script doesn't handle subdirectories in paths properly
-->

```console
$ cargo run -p adder
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/adder`
Hello, world! 10 plus one is 11!
```

Isso executa o código em _adder/src/main.rs_, que depende do `add_one` crate.

<!-- Old headings. Do not remove or links may break. -->

<a id="depending-on-an-external-package-in-a-workspace"></a>

### Dependendo de um pacote externo

Observe que o workspace possui apenas um arquivo _Cargo.lock_ no nível superior,
em vez de ter um _Cargo.lock_ no diretório de cada crate. Isso garante que
todos os crates estão usando a mesma versão de todas as dependências. Se adicionarmos o `rand`
pacote para os arquivos _adder/Cargo.toml_ e _add_one/Cargo.toml_, Cargo irá
resolva ambos para uma versão do ` rand`e registre isso em um
_Carga.lock_. Fazendo com que todos os crates no workspace usem as mesmas dependências
significa que o crates sempre será compatível entre si. Vamos adicionar o
` rand `crate para a seção` [dependencies] `no arquivo _add_one/Cargo.toml_
para que possamos usar o` rand `crate no` add_one`crate:

<!-- When updating the version of `rand` used, also update the version of
`rand` used in these files so they all match:
* ch02-00-guessing-game-tutorial.md
* ch07-04-bringing-paths-into-scope-with-the-use-keyword.md
-->

<span class="filename">Filename: add_one/Cargo.toml</span>

```toml
{{#include ../listings/ch14-more-about-cargo/no-listing-03-workspace-with-external-dependency/add/add_one/Cargo.toml:6:7}}
```

Agora podemos adicionar `use rand;` ao arquivo _add_one/src/lib.rs_ e construir o
todo o workspace executando `cargo build` no diretório _add_ trará
e compile o `rand` crate. Receberemos um aviso porque não estamos
referindo-se ao `rand` que trouxemos para o escopo:

<!-- manual-regeneration
listagens de cd/ch14-mais-sobre-cargo/no-listing-03-workspace-with-external-dependency/add
Construção cargo
copie a saída abaixo; o script de atualização de saída não manipula subdiretórios em caminhos corretamente
-->

```console
$ cargo build
    Updating crates.io index
  Downloaded rand v0.8.5
   --snip--
   Compiling rand v0.8.5
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
warning: unused import: `rand`
 --> add_one/src/lib.rs:1:5
  |
1 | use rand;
  |     ^^^^
  |
  = note: `#[warn(unused_imports)]` on by default

warning: `add_one` (lib) generated 1 warning (run `cargo fix --lib -p add_one` to apply 1 suggestion)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.95s
```

O _Cargo.lock_ de nível superior agora contém informações sobre a dependência de
`add_one ` em`rand `. No entanto, embora` rand `seja usado em algum lugar do
workspace, não podemos usá-lo em outro crates no workspace, a menos que adicionemos
` rand `para seus arquivos _Cargo.toml_ também. Por exemplo, se adicionarmos` use rand; `
ao arquivo _adder/src/main.rs_ do pacote` adder`, obteremos um erro:

<!-- manual-regeneration
listagens de cd/ch14-more-about-cargo/output-only-03-use-rand/add
Construção cargo
copie a saída abaixo; o script de atualização de saída não manipula subdiretórios em caminhos corretamente
-->

```console
$ cargo build
  --snip--
   Compiling adder v0.1.0 (file:///projects/add/adder)
error[E0432]: unresolved import `rand`
 --> adder/src/main.rs:2:5
  |
2 | use rand;
  |     ^^^^ no external crate `rand`
```

Para corrigir isso, edite o arquivo _Cargo.toml_ do pacote `adder` e indique
que `rand` também é uma dependência dele. Construir o pacote `adder` irá
adicione `rand` à lista de dependências para `adder` em _Cargo.lock_, mas não
cópias adicionais de `rand` serão baixadas. Cargo garantirá que cada
crate em cada pacote no workspace usando o pacote `rand` usará o
mesma versão, desde que especifiquem versões compatíveis do `rand`, poupando-nos
espaço e garantindo que o crates no workspace será compatível com
um ao outro.

Se crates no workspace especificar versões incompatíveis do mesmo
dependência, Cargo resolverá cada um deles, mas ainda tentará resolver como
poucas versões possíveis.

### Adding a Test to a Workspace

Para outra melhoria, vamos adicionar um teste da função `add_one::add_one`
dentro do ` add_one`crate:

<span class="filename">Filename: add_one/src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch14-more-about-cargo/no-listing-04-workspace-with-tests/add/add_one/src/lib.rs}}
```

Agora execute `cargo test` no diretório _add_ de nível superior. Executando `cargo test` em
um workspace estruturado como este executará os testes para todos os crates em
o workspace:

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/no-listing-04-workspace-with-tests/add
cargo test
copy output below; the output updating script doesn't handle subdirectories in
paths properly
-->

```console
$ cargo test
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.20s
     Running unittests src/lib.rs (target/debug/deps/add_one-93c49ee75dc46543)

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running unittests src/main.rs (target/debug/deps/adder-3a47283c568d2b6a)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests add_one

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

A primeira seção da saída mostra que o teste `it_works` no `add_one`
crate aprovado. A próxima seção mostra que nenhum teste foi encontrado no ` adder`
crate e a última seção mostra que nenhum teste de documentação foi encontrado
no ` add_one`crate.

Também podemos executar testes para um crate específico em um workspace a partir do
diretório de nível superior usando o sinalizador `-p` e especificando o nome do crate
queremos testar:

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/no-listing-04-workspace-with-tests/add
cargo test -p add_one
copy output below; the output updating script doesn't handle subdirectories in paths properly
-->

```console
$ cargo test -p add_one
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running unittests src/lib.rs (target/debug/deps/add_one-93c49ee75dc46543)

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests add_one

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

Esta saída mostra que `cargo test` executou apenas os testes para `add_one` crate e
não executou os testes `adder` crate.

Se você publicar o crates no workspace para
[crates.io](https://crates.io/)<!-- ignore -->, cada crate no workspace
precisarão ser publicados separadamente. Assim como `cargo test`, podemos publicar um
específico crate em nosso workspace usando o sinalizador ` -p`e especificando o
nome do crate que queremos publicar.

Para prática adicional, adicione um `add_two` crate a este workspace de forma semelhante
maneira como o `add_one` crate!

À medida que seu projeto cresce, considere usar um workspace: ele permite que você trabalhe com
componentes menores e mais fáceis de entender do que um grande bloco de código.
Além disso, manter o crates em um workspace pode facilitar a coordenação entre
crates é mais fácil se eles forem alterados com frequência ao mesmo tempo.

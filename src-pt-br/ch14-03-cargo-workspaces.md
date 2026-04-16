## Workspaces do Cargo

No Capítulo 12, construímos um pacote que incluía um crate binário e um crate
de biblioteca. À medida que o projeto evolui, você pode perceber que o crate de
biblioteca continua crescendo e desejar dividir ainda mais o pacote em vários
crates de biblioteca. O Cargo oferece um recurso chamado _workspaces_ que pode
ajudar a gerenciar vários pacotes relacionados, desenvolvidos em conjunto.

### Criando um Workspace

Um _workspace_ é um conjunto de pacotes que compartilham o mesmo
_Cargo.lock_ e o mesmo diretório de saída. Vamos criar um projeto usando um
workspace. Usaremos código trivial para que possamos nos concentrar na sua
estrutura. Existem várias maneiras de estruturar um workspace, então
mostraremos apenas uma forma comum. Teremos um workspace contendo um binário e
duas bibliotecas. O binário, que fornecerá a funcionalidade principal,
dependerá das duas bibliotecas. Uma delas fornecerá uma função `add_one`, e a
outra, uma função `add_two`. Esses três crates farão parte do mesmo workspace.
Começaremos criando um novo diretório para ele:

```console
$ mkdir add
$ cd add
```

Em seguida, no diretório _add_, criamos o arquivo _Cargo.toml_ que configurará
todo o workspace. Esse arquivo não terá uma seção `[package]`. Em vez disso,
começará com uma seção `[workspace]`, que nos permitirá adicionar membros ao
workspace. Também fazemos questão de usar a versão mais recente do algoritmo de
resolução do Cargo no workspace, definindo o valor de `resolver` como `"3"`:

<span class="filename">Nome do arquivo: Cargo.toml</span>

```toml
{{#include ../listings/ch14-more-about-cargo/no-listing-01-workspace/add/Cargo.toml}}
```

Em seguida, criaremos o crate binário `adder` executando `cargo new` dentro do
diretório _add_:

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

Executar `cargo new` dentro de um workspace também adiciona automaticamente o
pacote recém-criado à chave `members` na definição `[workspace]` do
_Cargo.toml_ do workspace, assim:

```toml
{{#include ../listings/ch14-more-about-cargo/output-only-01-adder-crate/add/Cargo.toml}}
```

Neste ponto, podemos compilar o workspace executando `cargo build`. Os arquivos
do diretório _add_ devem ficar assim:

```text
├── Cargo.lock
├── Cargo.toml
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

O workspace tem um único diretório _target_ no nível superior, no qual os
artefatos compilados serão colocados; o pacote `adder` não possui seu próprio
diretório _target_. Mesmo se executássemos `cargo build` de dentro do
diretório _adder_, os artefatos compilados ainda terminariam em _add/target_,
em vez de _add/adder/target_. O Cargo estrutura o diretório _target_ de um
workspace dessa forma porque os crates em um workspace devem
depender uns dos outros. Se cada crate tivesse seu próprio diretório _target_,
cada um teria de recompilar os outros crates do workspace para colocar os
artefatos em seu próprio _target_. Ao compartilhar um único diretório _target_,
os crates podem evitar recompilações desnecessárias.

### Criando o Segundo Pacote no Workspace

Em seguida, vamos criar outro pacote membro no workspace e chamá-lo de
`add_one`. Gere um novo crate de biblioteca chamado `add_one`:

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

O _Cargo.toml_ de nível superior agora incluirá o caminho _add_one_ na lista
`members`:

<span class="filename">Nome do arquivo: Cargo.toml</span>

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

No arquivo _add_one/src/lib.rs_, vamos adicionar uma função `add_one`:

<span class="filename">Nome do arquivo: add_one/src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch14-more-about-cargo/no-listing-02-workspace-with-two-crates/add/add_one/src/lib.rs}}
```

Agora podemos fazer o pacote `adder`, com nosso binário, depender do pacote
`add_one`, que contém nossa biblioteca. Primeiro, precisaremos adicionar uma
dependência por caminho para `add_one` em _adder/Cargo.toml_.

<span class="filename">Nome do arquivo: adder/Cargo.toml</span>

```toml
{{#include ../listings/ch14-more-about-cargo/no-listing-02-workspace-with-two-crates/add/adder/Cargo.toml:6:7}}
```

O Cargo não assume que crates em um workspace dependerão uns dos outros, então
precisamos ser explícitos sobre essas relações de dependência.

Em seguida, vamos usar a função `add_one` (do crate `add_one`) no crate
`adder`. Abra o arquivo _adder/src/main.rs_ e altere a função `main` para
chamar `add_one`, como na Listagem 14-7.

<Listing number="14-7" file-name="adder/src/main.rs" caption="Usando o crate de biblioteca `add_one` a partir do crate `adder`">

```rust,ignore
{{#rustdoc_include ../listings/ch14-more-about-cargo/listing-14-07/add/adder/src/main.rs}}
```

</Listing>

Vamos compilar o workspace executando `cargo build` no diretório _add_, no
nível superior!

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/listing-14-07/add
cargo build
copy output below; the output updating script doesn't handle subdirectories in paths properly
-->

```console
$ cargo build
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.22s
```

Para executar o crate binário a partir do diretório _add_, podemos especificar
qual pacote do workspace queremos executar usando o argumento `-p` e o nome do
pacote com `cargo run`:

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

### Dependendo de um Pacote Externo

Observe que o workspace possui apenas um arquivo _Cargo.lock_ no nível
superior, em vez de um _Cargo.lock_ no diretório de cada crate. Isso garante
que todos os crates usem a mesma versão de todas as dependências. Se
adicionarmos o pacote `rand` aos arquivos _adder/Cargo.toml_ e
_add_one/Cargo.toml_, o Cargo resolverá ambos para uma única versão de `rand` e
registrará isso no mesmo _Cargo.lock_. Fazer com que todos os crates do
workspace usem as mesmas dependências significa que eles serão sempre
compatíveis entre si. Vamos adicionar o crate `rand` à seção `[dependencies]`
do arquivo _add_one/Cargo.toml_, para que possamos usá-lo no crate `add_one`:

<!-- When updating the version of `rand` used, also update the version of
`rand` used in these files so they all match:
* ch02-00-guessing-game-tutorial.md
* ch07-04-bringing-paths-into-scope-with-the-use-keyword.md
-->

<span class="filename">Nome do arquivo: add_one/Cargo.toml</span>

```toml
{{#include ../listings/ch14-more-about-cargo/no-listing-03-workspace-with-external-dependency/add/add_one/Cargo.toml:6:7}}
```

Agora podemos adicionar `use rand;` ao arquivo _add_one/src/lib.rs_, e compilar
o workspace inteiro executando `cargo build` no diretório _add_ fará com que o
crate `rand` seja baixado e compilado. Receberemos um aviso porque não estamos
usando o `rand` que trouxemos para o escopo:

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/no-listing-03-workspace-with-external-dependency/add
cargo build
copy output below; the output updating script doesn't handle subdirectories in paths properly
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
`add_one` em `rand`. No entanto, embora `rand` seja usado em algum lugar do
workspace, não podemos usá-lo em outros crates do workspace, a menos que o
adicionemos também aos seus arquivos _Cargo.toml_. Por exemplo, se
adicionarmos `use rand;` ao arquivo _adder/src/main.rs_ do pacote `adder`,
obteremos um erro:

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/output-only-03-use-rand/add
cargo build
copy output below; the output updating script doesn't handle subdirectories in paths properly
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
que `rand` também é uma dependência dele. Compilar o pacote `adder`
adicionará `rand` à lista de dependências de `adder` em _Cargo.lock_, mas
nenhuma cópia adicional de `rand` será baixada. O Cargo garantirá que cada
crate de cada pacote do workspace que use o pacote `rand` utilize a mesma
versão, desde que sejam especificadas versões compatíveis, poupando espaço e
garantindo que os crates do workspace sejam compatíveis entre si.

Se crates do workspace especificarem versões incompatíveis da mesma
dependência, o Cargo resolverá cada uma delas, mas ainda tentará resolver o
menor número possível de versões.

### Adicionando um Teste a um Workspace

Para outra melhoria, vamos adicionar um teste da função `add_one::add_one`
dentro do crate `add_one`:

<span class="filename">Nome do arquivo: add_one/src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch14-more-about-cargo/no-listing-04-workspace-with-tests/add/add_one/src/lib.rs}}
```

Agora execute `cargo test` no diretório _add_, no nível superior. Executar
`cargo test` em um workspace estruturado dessa forma executará os testes de
todos os crates do workspace:

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

A primeira seção da saída mostra que o teste `it_works` no crate `add_one`
passou. A seção seguinte mostra que nenhum teste foi encontrado no crate
`adder`, e a última seção mostra que nenhum teste de documentação foi
encontrado no crate `add_one`.

Também podemos executar testes para um crate específico em um workspace a
partir do diretório de nível superior, usando o sinalizador `-p` e
especificando o nome do crate que queremos testar:

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

Essa saída mostra que `cargo test` executou apenas os testes do crate
`add_one` e não executou os testes do crate `adder`.

Se você publicar os crates do workspace em
[crates.io](https://crates.io/)<!-- ignore -->, cada crate precisará ser
publicado separadamente. Assim como em `cargo test`, podemos publicar um crate
específico do workspace usando o sinalizador `-p` e especificando o nome do
crate que queremos publicar.

Como prática adicional, adicione um crate `add_two` a este workspace de forma
semelhante ao crate `add_one`!

À medida que o projeto cresce, considere usar um workspace: ele permite
trabalhar com componentes menores e mais fáceis de entender do que um único
grande bloco de código. Além disso, manter os crates em um workspace pode
facilitar a coordenação entre eles, especialmente quando costumam ser alterados
ao mesmo tempo.

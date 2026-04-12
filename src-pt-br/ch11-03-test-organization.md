## Organização de Testes

Como mencionamos no início do capítulo, testes são uma disciplina complexa, e
pessoas diferentes usam terminologias e formas de organização diferentes. A
comunidade Rust costuma pensar em testes em duas categorias principais: testes
unitários e testes de integração. _Testes unitários_ são menores e mais
focados, verificam um módulo isoladamente por vez e podem testar interfaces
privadas. _Testes de integração_ são totalmente externos à sua biblioteca e
usam seu código da mesma forma que qualquer outro código externo usaria,
valendo-se apenas da interface pública e, potencialmente, exercitando vários
módulos em cada teste.

Escrever os dois tipos de testes é importante para garantir que as partes da
sua biblioteca façam o que você espera, tanto separadamente quanto em conjunto.

### Testes Unitários

O objetivo dos testes unitários é testar cada unidade de código isoladamente do
restante do código, para identificar rapidamente onde algo está ou não
funcionando como esperado. Você colocará os testes unitários no diretório
_src_, em cada arquivo que contenha o código sendo testado. A convenção é
criar em cada arquivo um módulo chamado `tests` para conter as funções de teste
e anotar esse módulo com `cfg(test)`.

#### O Módulo `tests` e `#[cfg(test)]`

A anotação `#[cfg(test)]` no módulo `tests` diz ao Rust para compilar e
executar o código de teste apenas quando você rodar `cargo test`, e não quando
executar `cargo build`. Isso economiza tempo de compilação quando você quer
apenas compilar a biblioteca e também economiza espaço no artefato compilado
resultante, porque os testes não são incluídos nele. Você verá que, como os
testes de integração ficam em um diretório separado, eles não precisam dessa
anotação `#[cfg(test)]`. No entanto, como os testes unitários ficam nos mesmos
arquivos do código, usamos `#[cfg(test)]` para indicar que eles não devem ser
incluídos no resultado compilado.

Lembre-se de que, quando geramos o novo projeto `adder` na primeira seção deste
capítulo, o Cargo gerou este código para nós:

<span class="filename">Nome do arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-01/src/lib.rs}}
```

No módulo `tests` gerado automaticamente, o atributo `cfg` significa
_configuração_ e diz ao Rust que o item seguinte só deve ser incluído sob uma
opção de configuração específica. Nesse caso, a opção é `test`, fornecida pelo
Rust para compilar e executar testes. Ao usar o atributo `cfg`, o Cargo
compila nosso código de teste apenas quando executamos ativamente os testes com
`cargo test`. Isso inclui quaisquer funções auxiliares que estejam dentro desse
módulo, além das funções anotadas com `#[test]`.

<!-- Old headings. Do not remove or links may break. -->

<a id="testing-private-functions"></a>

#### Testando Funções Privadas

Há debate na comunidade de testes sobre se funções privadas devem ou não ser
testadas diretamente, e outras linguagens tornam isso difícil ou até
impossível. Independentemente da filosofia de testes que você siga, as regras
de privacidade do Rust permitem testar funções privadas. Considere o código da
Listagem 11-12, com a função privada `internal_adder`.

<Listing number="11-12" file-name="src/lib.rs" caption="Testando uma função privada">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-12/src/lib.rs}}
```

</Listing>

Observe que a função `internal_adder` não está marcada como `pub`. Testes são
apenas código Rust, e o módulo `tests` é apenas mais um módulo. Como
discutimos em [“Caminhos para Referenciar um Item na Árvore de
Módulos”][paths]<!-- ignore -->, itens em módulos filhos podem usar itens de
seus módulos ancestrais. Neste teste, trazemos para o escopo todos os itens que
pertencem ao módulo pai de `tests` com `use super::*`, e então o teste pode
chamar `internal_adder`. Se você não achar que funções privadas devam ser
testadas, não há nada em Rust que vá obrigá-lo a fazer isso.

### Testes de Integração

Em Rust, testes de integração são totalmente externos à sua biblioteca. Eles
usam a biblioteca da mesma forma que qualquer outro código a usaria, o que
significa que só podem chamar funções que façam parte da API pública da sua
biblioteca. O objetivo deles é verificar se várias partes da biblioteca
funcionam corretamente em conjunto. Unidades de código que funcionam bem
isoladamente ainda podem apresentar problemas quando integradas, então a
cobertura de testes do código integrado também é importante. Para criar testes
de integração, primeiro precisamos de um diretório _tests_.

#### O Diretório _tests_

Criamos um diretório _tests_ no nível superior do diretório do projeto, ao lado
de _src_. O Cargo sabe que deve procurar arquivos de testes de integração nesse
diretório. Depois disso, podemos criar quantos arquivos de teste quisermos, e
o Cargo compilará cada um deles como um crate separado.

Vamos criar um teste de integração. Com o código da Listagem 11-12 ainda no
arquivo _src/lib.rs_, crie um diretório _tests_ e um novo arquivo chamado
_tests/integration_test.rs_. Sua estrutura de diretórios deve ficar assim:

```text
adder
├── Cargo.lock
├── Cargo.toml
├── src
│   └── lib.rs
└── tests
    └── integration_test.rs
```

Insira o código da Listagem 11-13 no arquivo _tests/integration_test.rs_.

<Listing number="11-13" file-name="tests/integration_test.rs" caption="Um teste de integração de uma função no crate `adder`">

```rust,ignore
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-13/tests/integration_test.rs}}
```

</Listing>

Cada arquivo no diretório _tests_ é um crate separado, então precisamos trazer
nossa biblioteca para o escopo de cada crate de teste. Por isso, adicionamos
`use adder::add_two;` no topo do código, algo que não era necessário nos
testes unitários.

Não precisamos anotar nenhum código em _tests/integration_test.rs_ com
`#[cfg(test)]`. O Cargo trata o diretório _tests_ de maneira especial e só
compila arquivos desse diretório quando executamos `cargo test`. Rode `cargo
test` agora:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-13/output.txt}}
```

As três seções da saída incluem os testes unitários, o teste de integração e
os doc tests. Observe que, se algum teste de uma seção falhar, as seções
seguintes não serão executadas. Por exemplo, se um teste unitário falhar, não
haverá saída para os testes de integração nem para os doc tests, porque eles só
rodam se todos os testes unitários passarem.

A primeira seção, referente aos testes unitários, é a mesma que já vimos: uma
linha para cada teste unitário, incluindo o chamado `internal`, que adicionamos
na Listagem 11-12, e depois uma linha-resumo.

A seção de testes de integração começa com a linha
`Running tests/integration_test.rs`. Em seguida, há uma linha para cada função
de teste presente nesse arquivo de integração e, logo antes do início da seção
`Doc-tests adder`, uma linha-resumo com o resultado do teste de integração.

Cada arquivo de teste de integração tem sua própria seção, então, se
adicionarmos mais arquivos ao diretório _tests_, teremos mais seções de testes
de integração.

Também podemos executar uma função específica de teste de integração
especificando o nome da função como argumento para `cargo test`. Para rodar
todos os testes de um arquivo específico de teste de integração, use o
argumento `--test` de `cargo test`, seguido do nome do arquivo:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-05-single-integration/output.txt}}
```

Esse comando executa apenas os testes do arquivo
_tests/integration_test.rs_.

#### Submódulos em Testes de Integração

À medida que você adiciona mais testes de integração, talvez queira criar mais
arquivos no diretório _tests_ para ajudar na organização; por exemplo, você
pode agrupar as funções de teste de acordo com a funcionalidade que elas
testam. Como mencionado antes, cada arquivo no diretório _tests_ é compilado
como seu próprio crate separado, o que é útil para criar escopos distintos que
imitam mais de perto a maneira como usuários finais utilizarão seu crate. No
entanto, isso significa que os arquivos no diretório _tests_ não compartilham o
mesmo comportamento que os arquivos em _src_, como você aprendeu no Capítulo 7
ao ver como separar código em módulos e arquivos.

Esse comportamento diferente dos arquivos em _tests_ fica mais evidente quando
você tem um conjunto de funções auxiliares para usar em vários arquivos de
teste de integração e tenta seguir os passos da seção [“Separando Módulos em
Arquivos Diferentes”][separating-modules-into-files]<!-- ignore --> do
Capítulo 7 para extraí-las para um módulo comum. Por exemplo, se criarmos
_tests/common.rs_ e colocarmos nele uma função chamada `setup`, podemos
adicionar código a `setup` que queremos chamar de várias funções de teste em
vários arquivos:

<span class="filename">Nome do arquivo: tests/common.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-12-shared-test-code-problem/tests/common.rs}}
```

Quando rodarmos os testes novamente, veremos uma nova seção na saída para o
arquivo _common.rs_, mesmo que esse arquivo não contenha nenhuma função de
teste e mesmo que não tenhamos chamado `setup` em lugar nenhum:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-12-shared-test-code-problem/output.txt}}
```

Ver `common` aparecer no resultado dos testes com `running 0 tests` não é o
que queríamos. Nosso objetivo era apenas compartilhar código com os outros
arquivos de teste de integração. Para evitar que `common` apareça na saída, em
vez de criar _tests/common.rs_, criaremos _tests/common/mod.rs_. O diretório do
projeto agora ficará assim:

```text
├── Cargo.lock
├── Cargo.toml
├── src
│   └── lib.rs
└── tests
    ├── common
    │   └── mod.rs
    └── integration_test.rs
```

Essa é a convenção de nomenclatura mais antiga, que o Rust também entende e
que mencionamos em [“Caminhos de Arquivo
Alternativos”][alt-paths]<!-- ignore --> no Capítulo 7. Dar esse nome ao
arquivo diz ao Rust para não tratar o módulo `common` como um arquivo de teste
de integração. Quando movemos o código da função `setup` para
_tests/common/mod.rs_ e apagamos o arquivo _tests/common.rs_, a seção
correspondente some da saída dos testes. Arquivos em subdiretórios de _tests_
não são compilados como crates separados e não ganham seções próprias na saída.

Depois de criar _tests/common/mod.rs_, podemos usá-lo como módulo em qualquer
arquivo de teste de integração. Aqui está um exemplo de chamada da função
`setup` a partir do teste `it_adds_two` em _tests/integration_test.rs_:

<span class="filename">Nome do arquivo: tests/integration_test.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-13-fix-shared-test-code-problem/tests/integration_test.rs}}
```

Observe que a declaração `mod common;` é igual à declaração de módulo que
mostramos na Listagem 7-21. Depois, dentro da função de teste, podemos chamar
`common::setup()`.

#### Testes de Integração para Crates Binários

Se nosso projeto for um crate binário que contenha apenas um arquivo
_src/main.rs_ e não tenha um arquivo _src/lib.rs_, não poderemos criar testes
de integração no diretório _tests_ e trazer para o escopo, com `use`, funções
definidas em _src/main.rs_. Apenas crates de biblioteca expõem funções que
outros crates podem usar; crates binários são feitos para ser executados por
conta própria.

Essa é uma das razões pelas quais projetos Rust que fornecem um binário costumam
ter um arquivo _src/main.rs_ bem direto, que apenas chama a lógica que vive em
_src/lib.rs_. Com essa estrutura, testes de integração _podem_ testar o crate
de biblioteca usando `use` para acessar a funcionalidade importante. Se essa
funcionalidade importante funciona, a pequena quantidade de código em
_src/main.rs_ também funcionará, e esse trecho pequeno nem precisa ser testado.

## Resumo

Os recursos de teste do Rust oferecem uma forma de especificar como o código
deve se comportar para garantir que ele continue funcionando como você espera,
mesmo enquanto você faz alterações. Testes unitários exercitam partes
diferentes de uma biblioteca separadamente e podem verificar detalhes privados
de implementação. Testes de integração verificam se muitas partes da biblioteca
funcionam corretamente em conjunto e usam a API pública da biblioteca para
testar o código da mesma forma que código externo irá usá-lo. Mesmo que o
sistema de tipos e as regras de ownership do Rust ajudem a evitar alguns tipos
de bugs, os testes continuam sendo importantes para reduzir bugs lógicos ligados
ao comportamento esperado do seu código.

Vamos combinar o que você aprendeu neste capítulo e nos anteriores para
trabalhar em um projeto!

[paths]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html
[separating-modules-into-files]: ch07-05-separating-modules-into-different-files.html
[alt-paths]: ch07-05-separating-modules-into-different-files.html#alternate-file-paths

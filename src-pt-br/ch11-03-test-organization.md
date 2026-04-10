## Organização de testes

Conforme mencionado no início do capítulo, o teste é uma disciplina complexa e
pessoas diferentes usam terminologia e organização diferentes. A comunidade Rust
pensa em testes em termos de duas categorias principais: testes unitários e testes de integração
testes. _Testes unitários_ são pequenos e mais focados, testando um módulo isoladamente
por vez e pode testar interfaces privadas. _Testes de integração_ são inteiramente
externo à sua biblioteca e use seu código da mesma forma que qualquer outro externo
código faria, usando apenas a interface pública e potencialmente exercendo múltiplos
módulos por teste.

Escrever os dois tipos de testes é importante para garantir que as partes do seu
biblioteca estão fazendo o que você espera que eles façam, separadamente e em conjunto.

### Testes unitários

O objetivo dos testes unitários é testar cada unidade de código isoladamente do
resto do código para identificar rapidamente onde o código está ou não funcionando como
esperado. Você colocará testes de unidade no diretório _src_ em cada arquivo com o
código que eles estão testando. A convenção é criar um módulo chamado `tests`
em cada arquivo para conter as funções de teste e anotar o módulo com
` cfg(test)`.

#### O Módulo `tests` e `#[cfg(test)]`

A anotação `#[cfg(test)]` no módulo `tests` diz ao Rust para compilar e
execute o código de teste somente ao executar `cargo test`, não ao executar ` cargo
build`. Isso economiza tempo de compilação quando você deseja apenas construir a biblioteca e
economiza espaço no artefato compilado resultante porque os testes não são
incluído. Você verá isso porque os testes de integração ocorrem de maneira diferente.
diretório, eles não precisam da anotação ` #[cfg(test)]`. No entanto, porque a unidade
os testes vão nos mesmos arquivos do código, você usará ` #[cfg(test)]`para especificar
que eles não devem ser incluídos no resultado compilado.

Lembre-se de que quando geramos o novo projeto `adder` na primeira seção do
neste capítulo, Cargo gerou este código para nós:

<span class="filename">Filename: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-01/src/lib.rs}}
```

No módulo `tests` gerado automaticamente, o atributo `cfg` significa
_configuração_ e informa ao Rust que o seguinte item só deve ser incluído
dada uma determinada opção de configuração. Neste caso, a opção de configuração é
`test `, fornecido pelo Rust para compilar e executar testes. Ao usar o
Atributo` cfg `, Cargo compila nosso código de teste somente se executarmos ativamente os testes
com` cargo test `. Isso inclui quaisquer funções auxiliares que possam estar dentro deste
módulo, além das funções anotadas com` #[test]`.

<!-- Old headings. Do not remove or links may break. -->

<a id="testing-private-functions"></a>

#### Private Function Tests

Há um debate na comunidade de testes sobre se é ou não privado
funções devem ser testadas diretamente, e outras linguagens dificultam ou
impossível testar funções privadas. Independentemente de qual ideologia de teste você
aderir, as regras de privacidade do Rust permitem que você teste funções privadas.
Considere o código da Listagem 11.12 com a função privada `internal_adder`.

<Listing number="11-12" file-name="src/lib.rs" caption="Testando uma função privada">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-12/src/lib.rs}}
```

</Listing>

Observe que a função `internal_adder` não está marcada como `pub`. Os testes são apenas
Código Rust, e o módulo ` tests`é apenas outro módulo. Como discutimos em
[“Caminhos para referência a um item na árvore de módulos”][paths]<!-- ignore -->,
itens em módulos filhos podem usar os itens em seus módulos ancestrais. Neste
teste, trazemos todos os itens pertencentes ao pai do módulo ` tests`para
escopo com ` use super::*`e então o teste pode chamar ` internal_adder`. Se você
não acho que funções privadas devam ser testadas, não há nada em Rust que
irá obrigá-lo a fazer isso.

### Integration Tests

No Rust, os testes de integração são totalmente externos à sua biblioteca. Eles usam o seu
biblioteca da mesma forma que qualquer outro código faria, o que significa que eles só podem chamar
funções que fazem parte da API pública da sua biblioteca. Seu objetivo é testar
se muitas partes da sua biblioteca funcionam juntas corretamente. Unidades de código que
funcionam corretamente por conta própria podem ter problemas quando integrados, então teste
a cobertura do código integrado também é importante. Para criar integração
testes, primeiro você precisa de um diretório _tests_.

#### O diretório _tests_

Criamos um diretório _tests_ no nível superior do diretório do nosso projeto, próximo
para _src_. Cargo sabe procurar arquivos de teste de integração neste diretório. Nós
podemos então criar quantos arquivos de teste quisermos e o Cargo irá compilar cada um dos
arquivos como um crate individual.

Vamos criar um teste de integração. Com o código na Listagem 11-12 ainda no
arquivo _src/lib.rs_, crie um diretório _tests_ e crie um novo arquivo chamado
_testes/integration_test.rs_. Sua estrutura de diretórios deve ficar assim:

```text
adder
├── Cargo.lock
├── Cargo.toml
├── src
│   └── lib.rs
└── tests
    └── integration_test.rs
```

Insira o código da Listagem 11.13 no arquivo _tests/integration_test.rs_.

<Listing number="11-13" file-name="tests/integration_test.rs" caption="Um teste de integração de uma função no crate `adder`">

```rust,ignore
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-13/tests/integration_test.rs}}
```

</Listing>

Cada arquivo no diretório _tests_ é um crate separado, então precisamos trazer nosso
biblioteca no escopo de cada teste crate. Por esse motivo, adicionamos `use
adder::add_two;` no topo do código, o que não precisávamos nos testes unitários.

Não precisamos anotar nenhum código em _tests/integration_test.rs_ com
`#[cfg(test)] `. Cargo trata o diretório _tests_ especialmente e compila arquivos
neste diretório somente quando executamos` cargo test `. Execute` cargo test`agora:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-13/output.txt}}
```

As três seções de saída incluem os testes de unidade, o teste de integração e
os testes do documento. Observe que se algum teste em uma seção falhar, as seções seguintes
não será executado. Por exemplo, se um teste de unidade falhar, não haverá nenhuma saída
para testes de integração e documentação, porque esses testes só serão executados se todas as unidades
os testes estão passando.

A primeira seção dos testes unitários é a mesma que vimos: uma linha
para cada teste de unidade (um chamado `internal` que adicionamos na Listagem 11-12) e
em seguida, uma linha de resumo para os testes de unidade.

A seção de testes de integração começa com a linha `Running
tests/integration_test.rs`. A seguir, há uma linha para cada função de teste em
esse teste de integração e uma linha de resumo para os resultados da integração
teste logo antes do início da seção ` Doc-tests adder`.

Each integration test file has its own section, so if we add more files in the
_tests_ directory, there will be more integration test sections.

Ainda podemos executar uma função de teste de integração específica especificando o teste
nome da função como argumento para `cargo test`. Para executar todos os testes em um
arquivo de teste de integração específico, use o argumento ` --test`de ` cargo test`
seguido do nome do arquivo:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-05-single-integration/output.txt}}
```

Este comando executa apenas os testes no arquivo _tests/integration_test.rs_.

#### Submodules in Integration Tests

À medida que você adiciona mais testes de integração, você pode querer criar mais arquivos no
diretório _tests_ para ajudar a organizá-los; por exemplo, você pode agrupar o teste
funções pela funcionalidade que estão testando. Como mencionado anteriormente, cada arquivo
no diretório _tests_ é compilado como seu próprio crate separado, o que é útil
para criar escopos separados para imitar mais de perto a forma como os usuários finais serão
usando seu crate. No entanto, isso significa que os arquivos no diretório _tests_ não
compartilham o mesmo comportamento dos arquivos em _src_, como você aprendeu no Capítulo 7
sobre como separar o código em módulos e arquivos.

O comportamento diferente dos arquivos do diretório _tests_ é mais perceptível quando você
ter um conjunto de funções auxiliares para usar em vários arquivos de teste de integração e
você tenta seguir as etapas em [“Separando Módulos em Diferentes
Arquivos”][separating-modules-into-files]seção <!-- ignore --> do Capítulo 7 para
extraia-os em um módulo comum. Por exemplo, se criarmos _tests/common.rs_
e colocar uma função chamada `setup` nela, podemos adicionar algum código ao `setup` que
queremos chamar várias funções de teste em vários arquivos de teste:

<span class="filename">Filename: tests/common.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-12-shared-test-code-problem/tests/common.rs}}
```

Quando executarmos os testes novamente, veremos uma nova seção na saída do teste para o
_common.rs_, mesmo que este arquivo não contenha nenhuma função de teste nem
chamamos a função `setup` de qualquer lugar:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-12-shared-test-code-problem/output.txt}}
```

Ter `common` aparecendo nos resultados do teste com `running 0 tests` exibido para
não é o que queríamos. Queríamos apenas compartilhar algum código com os outros
arquivos de teste de integração. Para evitar que `common` apareça na saída do teste,
em vez de criar _tests/common.rs_, criaremos _tests/common/mod.rs_. O
o diretório do projeto agora se parece com isto:

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

Esta é a convenção de nomenclatura mais antiga que Rust também entende e que mencionamos
em [“Caminhos de arquivo alternativos”][alt-paths]<!-- ignore --> no Capítulo 7. Nomeando o
arquivo desta forma diz ao Rust para não tratar o módulo `common` como um teste de integração
arquivo. Quando movemos o código da função `setup` para _tests/common/mod.rs_ e
exclua o arquivo _tests/common.rs_, a seção na saída do teste não será mais
aparecer. Arquivos em subdiretórios do diretório _tests_ não são compilados como
separe o crates ou tenha seções na saída do teste.

Depois de criarmos _tests/common/mod.rs_, podemos usá-lo em qualquer um dos
arquivos de teste de integração como um módulo. Aqui está um exemplo de chamada de `setup`
função do teste ` it_adds_two`em _tests/integration_test.rs_:

<span class="filename">Filename: tests/integration_test.rs</span>

```rust,ignore
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-13-fix-shared-test-code-problem/tests/integration_test.rs}}
```

Observe que a declaração `mod common;` é igual à declaração do módulo
demonstramos na Listagem 7-21. Então, na função de teste, podemos chamar o
Função `common::setup()`.

#### Testes de integração para caixas binárias

Se nosso projeto for um crate binário que contém apenas um arquivo _src/main.rs_ e
não possui um arquivo _src/lib.rs_, não podemos criar testes de integração no
_tests_ e traz as funções definidas no arquivo _src/main.rs_ para
escopo com uma instrução `use`. Somente a biblioteca crates expõe funções que outras
crates pode usar; O binário crates deve ser executado por conta própria.

Esta é uma das razões pelas quais os projetos Rust que fornecem um binário têm um
arquivo _src/main.rs_ direto que chama a lógica que reside no
arquivo _src/lib.rs_. Usando essa estrutura, os testes de integração _podem_ testar o
biblioteca crate com `use` para disponibilizar funcionalidades importantes. Se o
funcionalidade importante funciona, a pequena quantidade de código no _src/main.rs_
O arquivo também funcionará e essa pequena quantidade de código não precisa ser testada.

## Resumo

Os recursos de teste do Rust fornecem uma maneira de especificar como o código deve funcionar para
certifique-se de que ele continue funcionando conforme o esperado, mesmo enquanto você faz alterações. Unidade
os testes exercitam diferentes partes de uma biblioteca separadamente e podem testar
detalhes de implementação. Os testes de integração verificam se muitas partes da biblioteca
funcionam juntos corretamente e usam a API pública da biblioteca para testar o código
da mesma forma que o código externo irá utilizá-lo. Embora o sistema de tipos do Rust e
As regras ownership ajudam a prevenir alguns tipos de bugs, os testes ainda são importantes para
reduza bugs lógicos relacionados ao comportamento esperado do seu código.

Vamos combinar o conhecimento que você aprendeu neste capítulo e nos anteriores
capítulos para trabalhar em um projeto!

[paths]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html
[separating-modules-into-files]: ch07-05-separating-modules-into-different-files.html
[alt-paths]: ch07-05-separating-modules-into-different-files.html#alternate-file-paths

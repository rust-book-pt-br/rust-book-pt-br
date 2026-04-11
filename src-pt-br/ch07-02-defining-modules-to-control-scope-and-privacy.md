<!-- Old headings. Do not remove or links may break. -->

<a id="defining-modules-to-control-scope-and-privacy"></a>

## Controlando Escopo e Privacidade com Módulos

Nesta seção, falaremos sobre módulos e outras partes do sistema de módulos,
principalmente _paths_, que permitem nomear itens; a palavra-chave `use`, que
traz um caminho para o escopo; e a palavra-chave `pub`, para tornar itens
públicos. Também discutiremos a palavra-chave `as`, pacotes externos e o
operador glob.

### Folha de Referência de Módulos

Antes de entrarmos nos detalhes de módulos e caminhos, aqui vai uma referência
rápida sobre como módulos, caminhos, a palavra-chave `use` e a palavra-chave
`pub` funcionam no compilador e como a maioria das pessoas organiza seu código.
Vamos passar por exemplos de cada uma dessas regras ao longo deste capítulo,
mas esta é uma ótima seção para consultar quando você quiser relembrar como os
módulos funcionam.

- **Comece pela raiz do crate**: ao compilar um crate, o compilador primeiro
  procura no arquivo raiz do crate, geralmente _src/lib.rs_ para um crate de
  biblioteca e _src/main.rs_ para um crate binário, o código a ser compilado.
- **Declarando módulos**: no arquivo raiz do crate, você pode declarar novos
  módulos. Digamos que você declare um módulo `garden` com `mod garden;`. O
  compilador procurará o código desse módulo nos seguintes lugares:
  - Inline, entre chaves, substituindo o ponto e vírgula após `mod garden`
  - No arquivo _src/garden.rs_
  - No arquivo _src/garden/mod.rs_
- **Declarando submódulos**: em qualquer arquivo que não seja a raiz do crate,
  você pode declarar submódulos. Por exemplo, você poderia declarar
  `mod vegetables;` em _src/garden.rs_. O compilador procurará o código do
  submódulo dentro do diretório nomeado de acordo com o módulo pai, nos
  seguintes lugares:
  - Inline, logo após `mod vegetables`, entre chaves em vez do ponto e vírgula
  - No arquivo _src/garden/vegetables.rs_
  - No arquivo _src/garden/vegetables/mod.rs_
- **Caminhos para código em módulos**: depois que um módulo passa a fazer parte
  do seu crate, você pode se referir ao código desse módulo de qualquer outro
  lugar do mesmo crate, desde que as regras de privacidade permitam, usando o
  caminho até esse código. Por exemplo, um tipo `Asparagus` no módulo
  `garden::vegetables` seria encontrado em
  `crate::garden::vegetables::Asparagus`.
- **Privado versus público**: por padrão, o código dentro de um módulo é
  privado em relação aos seus módulos pais. Para tornar um módulo público,
  declare-o com `pub mod` em vez de `mod`. Para tornar públicos também os itens
  dentro de um módulo público, use `pub` antes de suas declarações.
- **A palavra-chave `use`**: dentro de um escopo, a palavra-chave `use` cria
  atalhos para itens, reduzindo a repetição de caminhos longos. Em qualquer
  escopo que possa se referir a `crate::garden::vegetables::Asparagus`, você
  pode criar um atalho com `use crate::garden::vegetables::Asparagus;`; a
  partir daí, basta escrever `Asparagus` para usar esse tipo no escopo.

Aqui, criamos um crate binário chamado `backyard` que ilustra essas regras. O
diretório do crate, também chamado _backyard_, contém estes arquivos e
diretórios:

```text
backyard
├── Cargo.lock
├── Cargo.toml
└── src
    ├── garden
    │   └── vegetables.rs
    ├── garden.rs
    └── main.rs
```

O arquivo raiz do crate, neste caso, é _src/main.rs_, e ele contém:

<Listing file-name="src/main.rs">

```rust,noplayground,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/quick-reference-example/src/main.rs}}
```

</Listing>

A linha `pub mod garden;` diz ao compilador para incluir o código encontrado em
_src/garden.rs_, que é:

<Listing file-name="src/garden.rs">

```rust,noplayground,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/quick-reference-example/src/garden.rs}}
```

</Listing>

Aqui, `pub mod vegetables;` significa que o código em
_src/garden/vegetables.rs_ também é incluído. Esse código é:

```rust,noplayground,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/quick-reference-example/src/garden/vegetables.rs}}
```

Agora vamos entrar nos detalhes dessas regras e demonstrá-las em ação!

### Agrupando Código Relacionado em Módulos

_Módulos_ nos permitem organizar o código dentro de um crate de modo a torná-lo
mais legível e fácil de reutilizar. Eles também nos permitem controlar a
_privacidade_ dos itens, porque, por padrão, o código dentro de um módulo é
privado. Itens privados são detalhes internos de implementação, não disponíveis
para uso externo. Podemos optar por tornar módulos e os itens dentro deles
públicos, expondo-os para que código externo possa usá-los e depender deles.

Como exemplo, vamos escrever um crate de biblioteca que fornece a
funcionalidade de um restaurante. Definiremos as assinaturas de funções, mas
deixaremos seus corpos vazios para nos concentrarmos na organização do código,
e não na implementação de um restaurante.

Na indústria de restaurantes, algumas partes de um restaurante são chamadas de
frente da casa e outras de fundos da casa. A _frente da casa_ é onde ficam os
clientes; isso inclui onde os anfitriões acomodam os clientes, onde os
atendentes recebem pedidos e pagamentos, e onde os bartenders preparam
bebidas. Os _fundos da casa_ são onde chefs e cozinheiros trabalham na cozinha,
onde a louça é lavada e onde gerentes fazem o trabalho administrativo.

Para estruturar nosso crate dessa forma, podemos organizar suas funções em
módulos aninhados. Crie uma nova biblioteca chamada `restaurant` executando
`cargo new restaurant --lib`. Em seguida, coloque o código da Listagem 7-1 em
_src/lib.rs_ para definir alguns módulos e assinaturas de função; esse código
representa a seção de frente da casa.

<Listing number="7-1" file-name="src/lib.rs" caption="Um módulo `front_of_house` contendo outros módulos, que por sua vez contêm funções">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-01/src/lib.rs}}
```

</Listing>

Definimos um módulo com a palavra-chave `mod`, seguida do nome do módulo, neste
caso `front_of_house`. O corpo do módulo vai então entre chaves. Dentro de
módulos, podemos colocar outros módulos, como neste caso com os módulos
`hosting` e `serving`. Módulos também podem conter definições de outros itens,
como structs, enums, constantes, traits e, como na Listagem 7-1, funções.

Ao usar módulos, podemos agrupar definições relacionadas e dar nome ao motivo
pelo qual elas se relacionam. Quem usa esse código pode navegar pelo projeto
com base nos agrupamentos, em vez de ter que ler todas as definições, o que
facilita encontrar aquelas que são relevantes. Quem adicionar nova
funcionalidade a esse código saberá onde colocá-la para manter o programa bem
organizado.

Antes, mencionamos que _src/main.rs_ e _src/lib.rs_ são chamados de _raízes do
crate_. O motivo desse nome é que o conteúdo de qualquer um desses arquivos
forma um módulo chamado `crate`, localizado na raiz da estrutura de módulos do
crate, conhecida como _árvore de módulos_.

A Listagem 7-2 mostra a árvore de módulos da estrutura da Listagem 7-1.

<Listing number="7-2" caption="A árvore de módulos do código da Listagem 7-1">

```text
crate
 └── front_of_house
     ├── hosting
     │   ├── add_to_waitlist
     │   └── seat_at_table
     └── serving
         ├── take_order
         ├── serve_order
         └── take_payment
```

</Listing>

Essa árvore mostra como alguns módulos ficam aninhados dentro de outros; por
exemplo, `hosting` está aninhado dentro de `front_of_house`. A árvore também
mostra que alguns módulos são _irmãos_, o que significa que estão definidos no
mesmo módulo; `hosting` e `serving` são irmãos definidos dentro de
`front_of_house`. Se o módulo A estiver contido dentro do módulo B, dizemos que
o módulo A é _filho_ do módulo B, e que o módulo B é _pai_ do módulo A.
Observe que toda a árvore de módulos está enraizada sob o módulo implícito
chamado `crate`.

A árvore de módulos pode lembrar a árvore de diretórios do sistema de arquivos
do seu computador; e essa comparação é bastante adequada. Assim como você usa
diretórios em um sistema de arquivos para organizar seus arquivos, você usa
módulos para organizar seu código. E, da mesma forma que acontece com arquivos
em um diretório, precisamos de uma maneira de encontrar nossos módulos.

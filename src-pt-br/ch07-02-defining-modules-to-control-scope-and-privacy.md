<!-- Old headings. Do not remove or links may break. -->

<a id="defining-modules-to-control-scope-and-privacy"></a>

## Controlando escopo e privacidade com módulos

Nesta seção, vamos falar sobre módulos e outras partes do sistema de módulos:
_paths_, que permitem nomear itens; a palavra-chave `use`, que traz um caminho
para o escopo; e a palavra-chave `pub`, que torna itens públicos. Também vamos
discutir a palavra-chave `as`, pacotes externos e o operador glob.

### Folha de referência de módulos

Antes de entrarmos nos detalhes de módulos e caminhos, aqui está uma referência
rápida de como módulos, caminhos, a palavra-chave `use` e a palavra-chave
`pub` funcionam no compilador, e de como a maior parte das pessoas organiza o
código. Ao longo deste capítulo veremos exemplos de cada uma dessas regras, mas
esta é uma ótima seção para consultar quando você quiser relembrar como módulos
funcionam.

- **Comece pela raiz da crate**: ao compilar uma crate, o compilador primeiro
  procura código para compilar no arquivo raiz da crate, que geralmente é
  _src/lib.rs_ para uma crate de biblioteca e _src/main.rs_ para uma crate
  binária.
- **Declarando módulos**: no arquivo raiz da crate, você pode declarar novos
  módulos. Digamos que você declare um módulo `garden` com `mod garden;`. O
  compilador procurará o código desse módulo nestes lugares:
  - Inline, entre chaves que substituem o ponto e vírgula após `mod garden`
  - No arquivo _src/garden.rs_
  - No arquivo _src/garden/mod.rs_
- **Declarando submódulos**: em qualquer arquivo que não seja a raiz da crate,
  você pode declarar submódulos. Por exemplo, você poderia declarar
  `mod vegetables;` em _src/garden.rs_. O compilador procurará o código do
  submódulo dentro do diretório nomeado em função do módulo pai, nestes
  lugares:
  - Inline, logo após `mod vegetables`, entre chaves no lugar do ponto e
    vírgula
  - No arquivo _src/garden/vegetables.rs_
  - No arquivo _src/garden/vegetables/mod.rs_
- **Caminhos para código em módulos**: depois que um módulo passa a fazer parte
  da crate, você pode se referir ao código dele de qualquer outro lugar dessa
  mesma crate, desde que as regras de privacidade permitam, usando o caminho
  até esse código. Por exemplo, um tipo `Asparagus` no módulo
  `garden::vegetables` seria encontrado em
  `crate::garden::vegetables::Asparagus`.
- **Privado versus público**: por padrão, o código dentro de um módulo é
  privado para seus módulos pai. Para tornar um módulo público, declare-o com
  `pub mod` em vez de `mod`. Para tornar públicos também os itens contidos em
  um módulo público, use `pub` antes de suas declarações.
- **A palavra-chave `use`**: dentro de um escopo, a palavra-chave `use` cria
  atalhos para itens, reduzindo a repetição de caminhos longos. Em qualquer
  escopo que possa se referir a `crate::garden::vegetables::Asparagus`, você
  pode criar um atalho com `use crate::garden::vegetables::Asparagus;`, e a
  partir daí só precisa escrever `Asparagus` para usar esse tipo naquele
  escopo.

Aqui, criamos uma crate binária chamada `backyard` que ilustra essas regras. O
diretório da crate, também chamado _backyard_, contém estes arquivos e
diretórios:

```text
backyard
├── Cargo.lock
├── Cargo.toml
└── src
    ├── garden
    │   └── vegetables.rs
    ├── garden.rs
    └── main.rs
```

O arquivo raiz da crate, neste caso, é _src/main.rs_, e ele contém:

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

Aqui, `pub mod vegetables;` também significa que o código em
_src/garden/vegetables.rs_ será incluído. Esse código é:

```rust,noplayground,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/quick-reference-example/src/garden/vegetables.rs}}
```

Agora vamos entrar nos detalhes dessas regras e vê-las em ação!

### Agrupando código relacionado em módulos

_Módulos_ nos permitem organizar o código dentro de uma crate para facilitar a
leitura e a reutilização. Eles também nos permitem controlar a _privacidade_
dos itens, porque o código dentro de um módulo é privado por padrão. Itens
privados são detalhes internos de implementação, não disponíveis para uso
externo. Podemos optar por tornar públicos os módulos e os itens dentro deles,
o que os expõe para que código externo possa usá-los e depender deles.

Como exemplo, vamos escrever uma crate de biblioteca que forneça a
funcionalidade de um restaurante. Vamos definir as assinaturas das funções, mas
deixaremos seus corpos vazios para nos concentrarmos na organização do código,
e não na implementação de um restaurante.

Na indústria de restaurantes, algumas partes de um restaurante são chamadas de
_front of house_ e outras de _back of house_. _Front of house_ é onde ficam os
clientes; isso inclui onde as pessoas da recepção acomodam os clientes, onde
os atendentes recebem pedidos e pagamentos e onde bartenders preparam bebidas.
_Back of house_ é onde chefs e cozinheiros trabalham na cozinha, onde a equipe
lava a louça e onde gerentes fazem trabalho administrativo.

Para estruturar nossa crate dessa forma, podemos organizar suas funções em
módulos aninhados. Crie uma nova biblioteca chamada `restaurant` executando
`cargo new restaurant --lib`. Em seguida, insira o código da Listagem 7-1 em
_src/lib.rs_ para definir alguns módulos e assinaturas de função; esse código
representa a seção de _front of house_.

<Listing number="7-1" file-name="src/lib.rs" caption="Um módulo `front_of_house` contendo outros módulos que, por sua vez, contêm funções">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-01/src/lib.rs}}
```

</Listing>

Definimos um módulo com a palavra-chave `mod`, seguida do nome do módulo, neste
caso `front_of_house`. O corpo do módulo vai entre chaves. Dentro de módulos,
podemos colocar outros módulos, como `hosting` e `serving` neste exemplo.
Módulos também podem conter definições de outros itens, como structs, enums,
constantes, traits e, como na Listagem 7-1, funções.

Ao usar módulos, podemos agrupar definições relacionadas e dar nome ao motivo
de essa relação existir. Pessoas que usam esse código podem navegar por ele com
base nesses agrupamentos, em vez de ter de ler todas as definições, o que
facilita encontrar os trechos relevantes. Pessoas adicionando novas
funcionalidades a esse código também saberiam onde colocar o código para manter
o programa organizado.

Antes, mencionamos que _src/main.rs_ e _src/lib.rs_ são chamados de _raízes de
crate_. A razão desse nome é que o conteúdo de qualquer um desses dois arquivos
forma um módulo chamado `crate`, na raiz da estrutura de módulos da crate,
conhecida como _árvore de módulos_.

A Listagem 7-2 mostra a árvore de módulos da estrutura definida na Listagem
7-1.

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

Essa árvore mostra como alguns módulos se aninham dentro de outros; por
exemplo, `hosting` está aninhado dentro de `front_of_house`. A árvore também
mostra que alguns módulos são _irmãos_, ou seja, são definidos dentro do mesmo
módulo; `hosting` e `serving` são irmãos definidos dentro de
`front_of_house`. Se o módulo A estiver contido dentro do módulo B, dizemos que
o módulo A é _filho_ do módulo B e que o módulo B é o _pai_ do módulo A.
Observe que toda a árvore de módulos está enraizada sob o módulo implícito
chamado `crate`.

A árvore de módulos pode lembrar a árvore de diretórios do sistema de arquivos
do seu computador, e essa comparação é muito apropriada! Assim como usamos
diretórios para organizar arquivos, usamos módulos para organizar código. E,
assim como arquivos em um diretório, precisamos de um jeito de encontrar nossos
módulos.

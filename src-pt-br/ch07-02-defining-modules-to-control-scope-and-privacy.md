<!-- Old headings. Do not remove or links may break. -->

<a id="defining-modules-to-control-scope-and-privacy"></a>

## Controle o escopo e a privacidade com módulos

Nesta seção, falaremos sobre módulos e outras partes do sistema de módulos,
nomeadamente _paths_, que permitem nomear itens; a palavra-chave `use` que traz um
caminho para o escopo; e a palavra-chave `pub` para tornar os itens públicos. Também discutiremos
a palavra-chave `as`, pacotes externos e o operador glob.

### Folha de referências dos módulos

Antes de entrarmos nos detalhes dos módulos e caminhos, fornecemos aqui uma rápida
referência sobre como módulos, caminhos, a palavra-chave `use` e a palavra-chave `pub` funcionam
no compilador e como a maioria dos desenvolvedores organiza seu código. Nós iremos
através de exemplos de cada uma dessas regras ao longo deste capítulo, mas esta é uma
ótimo lugar para consultar como um lembrete de como os módulos funcionam.

- **Comece pela raiz da crate**: Ao compilar uma crate, o compilador primeiro
procura no arquivo raiz da crate (geralmente _src/lib.rs_ para uma crate de biblioteca e
_src/main.rs_ para uma crate binária) para o código ser compilado.
- **Declarando módulos**: No arquivo raiz da crate, você pode declarar novos módulos;
digamos que você declare um módulo “jardim” com `mod garden;`. O compilador irá parecer
para o código do módulo nestes locais:
- Inline, entre chaves que substituem o ponto e vírgula após `mod
jardim`
- No arquivo _src/garden.rs_
- No arquivo _src/garden/mod.rs_
- **Declarando submódulos**: Em qualquer arquivo que não seja a raiz da crate, você pode
declarar submódulos. Por exemplo, você pode declarar `mod vegetables;` em
_src/garden.rs_. O compilador procurará o código do submódulo dentro do
diretório nomeado para o módulo pai nestes locais:
- Inline, seguindo diretamente `mod vegetables`, entre colchetes
do ponto e vírgula
- No arquivo _src/garden/vegetables.rs_
- No arquivo _src/garden/vegetables/mod.rs_
- **Caminhos para código em módulos**: quando um módulo fizer parte da sua crate, você poderá
consulte o código nesse módulo de qualquer outro lugar na mesma crate, desde que
conforme as regras de privacidade permitem, usando o caminho para o código. Por exemplo, um
O tipo `Asparagus` no módulo de hortaliças seria encontrado em
`crate::garden::vegetables::Asparagus`.
- **Privado x público**: o código dentro de um módulo é privado de seu pai
módulos por padrão. Para tornar um módulo público, declare-o com `pub mod`
em vez de `mod`. Para tornar públicos os itens de um módulo público também, use
`pub` antes de suas declarações.
- **A palavra-chave `use`**: Dentro de um escopo, a palavra-chave `use` cria atalhos para
itens para reduzir a repetição de caminhos longos. Em qualquer escopo que possa se referir a
`crate::garden::vegetables::Asparagus`, você pode criar um atalho com `use
crate::garden::vegetables::Asparagus;`, e a partir daí você só precisa
escreva `Asparagus` para fazer uso desse tipo no escopo.

Aqui, criamos uma crate binária chamada `backyard` que ilustra essas regras.
O diretório da crate, também chamado _backyard_, contém esses arquivos e
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

O arquivo raiz da crate neste caso é _src/main.rs_ e contém:

<Listing file-name="src/main.rs">

```rust,noplayground,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/quick-reference-example/src/main.rs}}
```

</Listing>

A linha `pub mod garden;` diz ao compilador para incluir o código que encontrar
_src/garden.rs_, que é:

<Listing file-name="src/garden.rs">

```rust,noplayground,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/quick-reference-example/src/garden.rs}}
```

</Listing>

Aqui, `pub mod vegetables;` significa que o código em _src/garden/vegetables.rs_ é
incluído também. Esse código é:

```rust,noplayground,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/quick-reference-example/src/garden/vegetables.rs}}
```

Agora vamos entrar em detalhes dessas regras e demonstrá-las em ação!

### Agrupando código relacionado em módulos

_Módulos_ nos permitem organizar o código em uma crate para facilitar a leitura e a reutilização.
Os módulos também nos permitem controlar a _privacidade_ dos itens porque o código dentro de um
o módulo é privado por padrão. Itens privados são detalhes de implementação interna
não disponível para uso externo. Podemos optar por fazer módulos e os itens
dentro deles públicos, o que os expõe para permitir que código externo use e dependa
neles.

Como exemplo, vamos escrever uma crate de biblioteca que forneça a funcionalidade de um
restaurante. Definiremos as assinaturas das funções, mas deixaremos seus corpos
vazio se concentrar na organização do código e não na
implementação de um restaurante.

Na indústria de restaurantes, algumas partes de um restaurante são chamadas de frente
de casa e outros como fundos de casa. _Frente da casa_ é onde estão os clientes;
isso abrange onde os anfitriões acomodam os clientes, os servidores recebem pedidos e
pagamento, e os bartenders preparam bebidas. _Nos fundos da casa_ é onde os chefs e
cozinheiros trabalham na cozinha, máquinas de lavar louça limpam e gerentes fazem tarefas administrativas
trabalhar.

Para estruturar nossa crate dessa forma, podemos organizar suas funções em grupos aninhados.
módulos. Crie uma nova biblioteca chamada `restaurant` executando `cargo new
restaurante --lib`. Em seguida, insira o código da Listagem 7-1 em _src/lib.rs_ para
definir alguns módulos e assinaturas de funções; esse código é a frente da casa
seção.

<Listing number="7-1" file-name="src/lib.rs" caption="A `front_of_house` module containing other modules that then contain functions">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-01/src/lib.rs}}
```

</Listing>

Definimos um módulo com a palavra-chave `mod` seguida do nome do módulo
(neste caso, `front_of_house`). O corpo do módulo então vai para dentro do cacheado
colchetes. Dentro dos módulos podemos colocar outros módulos, como neste caso com o
módulos `hosting` e `serving`. Os módulos também podem conter definições para outros
itens, como structs, enums, constantes, traits, e como na Listagem 7-1,
funções.

Ao usar módulos, podemos agrupar definições relacionadas e nomear o porquê
eles estão relacionados. Os programadores que usam este código podem navegar no código com base no
grupos em vez de ter que ler todas as definições, tornando mais fácil
para encontrar as definições relevantes para eles. Programadores adicionando novas funcionalidades
a este código saberia onde colocar o código para manter o programa organizado.

Anteriormente, mencionamos que _src/main.rs_ e _src/lib.rs_ são chamados de _crate
raízes_. A razão para o seu nome é que o conteúdo de qualquer um destes dois
os arquivos formam um módulo chamado `crate` na raiz da estrutura do módulo da crate,
conhecida como _árvore de módulos_.

A Listagem 7-2 mostra a árvore de módulos para a estrutura da Listagem 7-1.

<Listing number="7-2" caption="The module tree for the code in Listing 7-1">

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

Esta árvore mostra como alguns módulos se aninham dentro de outros módulos; por exemplo,
`hosting` aninha-se dentro de `front_of_house`. A árvore também mostra que alguns módulos
são _irmãos_, o que significa que estão definidos no mesmo módulo; `hosting` e
`serving` são irmãos definidos em `front_of_house`. Se o módulo A for
contido dentro do módulo B, dizemos que o módulo A é _filho_ do módulo B e
que o módulo B é o _pai_ do módulo A. Observe que toda a árvore do módulo
está enraizado no módulo implícito denominado `crate`.

A árvore de módulos pode lembrá-lo da árvore de diretórios do sistema de arquivos em seu
computador; esta é uma comparação muito adequada! Assim como os diretórios em um sistema de arquivos,
você usa módulos para organizar seu código. E assim como os arquivos em um diretório, nós
precisamos de uma maneira de encontrar nossos módulos.

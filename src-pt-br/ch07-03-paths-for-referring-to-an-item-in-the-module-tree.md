## Caminhos para se referir a um item na árvore de módulos

Para mostrar ao Rust onde encontrar um item em uma árvore de módulos, usamos um
caminho da mesma forma que usamos um caminho ao navegar em um sistema de
arquivos. Para chamar uma função, precisamos conhecer seu caminho.

Um caminho pode assumir duas formas:

- Um _caminho absoluto_ é o caminho completo começando na raiz da crate. Para
  código vindo de uma crate externa, o caminho absoluto começa com o nome da
  crate. Para código da crate atual, começa com o literal `crate`.
- Um _caminho relativo_ começa no módulo atual e usa `self`, `super` ou um
  identificador presente no módulo atual.

Tanto caminhos absolutos quanto relativos são seguidos por um ou mais
identificadores separados por dois pontos duplos (`::`).

Voltando à Listagem 7-1, digamos que queremos chamar a função
`add_to_waitlist`. Isso equivale a perguntar: qual é o caminho até a função
`add_to_waitlist`? A Listagem 7-3 contém a Listagem 7-1 com alguns módulos e
funções removidos.

Mostraremos duas formas de chamar a função `add_to_waitlist` a partir de uma
nova função, `eat_at_restaurant`, definida na raiz da crate. Esses caminhos
estão corretos, mas ainda existe outro problema que impedirá a compilação desse
exemplo como está. Daqui a pouco explicaremos o motivo.

A função `eat_at_restaurant` faz parte da API pública da nossa crate de
biblioteca, então nós a marcamos com a palavra-chave `pub`. Na seção
[“Expondo caminhos com a palavra-chave `pub`”][pub]<!-- ignore -->, veremos
`pub` com mais detalhes.

<Listing number="7-3" file-name="src/lib.rs" caption="Chamando a função `add_to_waitlist` usando caminhos absolutos e relativos">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-03/src/lib.rs}}
```

</Listing>

A primeira vez que chamamos a função `add_to_waitlist` em `eat_at_restaurant`,
usamos um caminho absoluto. A função `add_to_waitlist` está definida na mesma
crate que `eat_at_restaurant`, o que significa que podemos usar a palavra-chave
`crate` para começar um caminho absoluto. Em seguida, incluímos cada módulo
sucessivo até chegar a `add_to_waitlist`. Você pode imaginar um sistema de
arquivos com a mesma estrutura: especificaríamos o caminho
`/front_of_house/hosting/add_to_waitlist` para executar o programa
`add_to_waitlist`; usar o nome `crate` para começar da raiz da crate é como
usar `/` para começar da raiz do sistema de arquivos no shell.

A segunda vez que chamamos `add_to_waitlist` em `eat_at_restaurant`, usamos um
caminho relativo. O caminho começa com `front_of_house`, o nome do módulo
definido no mesmo nível da árvore de módulos que `eat_at_restaurant`. O
equivalente no sistema de arquivos seria usar o caminho
`front_of_house/hosting/add_to_waitlist`. Começar com o nome de um módulo
significa que o caminho é relativo.

Escolher entre usar um caminho relativo ou absoluto é uma decisão que você vai
tomar com base no seu projeto. Essa escolha depende de ser mais provável que
você mova o código que define o item separadamente ou junto com o código que o
utiliza. Por exemplo, se movêssemos o módulo `front_of_house` e a função
`eat_at_restaurant` para dentro de um módulo chamado `customer_experience`,
teríamos que atualizar o caminho absoluto para `add_to_waitlist`, mas o caminho
relativo continuaria válido. Porém, se movêssemos a função
`eat_at_restaurant` separadamente para um módulo chamado `dining`, o caminho
absoluto para `add_to_waitlist` permaneceria o mesmo, mas o caminho relativo
precisaria ser atualizado. Nossa preferência, em geral, é especificar caminhos
absolutos porque é mais provável que queiramos mover definições de código e
chamadas de item independentemente umas das outras.

Vamos tentar compilar a Listagem 7-3 e descobrir por que ela ainda não compila!
Os erros que recebemos são mostrados na Listagem 7-4.

<Listing number="7-4" caption="Erros do compilador ao tentar compilar o código da Listagem 7-3">

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-03/output.txt}}
```

</Listing>

As mensagens de erro dizem que o módulo `hosting` é privado. Em outras
palavras, temos os caminhos corretos para o módulo `hosting` e para a função
`add_to_waitlist`, mas Rust não nos deixa usá-los porque não temos acesso às
seções privadas. Em Rust, todos os itens, como funções, métodos, structs,
enums, módulos e constantes, são privados para módulos pai por padrão. Se você
quiser tornar um item como uma função ou struct privado, basta colocá-lo dentro
de um módulo.

Itens em um módulo pai não podem usar itens privados dentro de módulos filhos,
mas itens em módulos filhos podem usar itens em seus módulos ancestrais. Isso
acontece porque módulos filhos encapsulam e escondem seus detalhes de
implementação, mas ainda conseguem ver o contexto em que foram definidos. Para
continuar com a nossa metáfora, pense nas regras de privacidade como se fossem
o escritório interno de um restaurante: o que acontece lá é privado para os
clientes, mas a gerência pode ver e fazer tudo no restaurante que administra.

Rust escolheu fazer o sistema de módulos funcionar desse jeito para que esconder
detalhes internos de implementação seja o comportamento padrão. Assim, você
sabe quais partes do código interno pode alterar sem quebrar o código externo.
Ainda assim, Rust oferece a opção de expor partes internas do código de módulos
filhos a módulos ancestrais externos usando a palavra-chave `pub` para tornar
um item público.

### Expondo caminhos com a palavra-chave `pub`

Vamos voltar ao erro da Listagem 7-4 que nos dizia que o módulo `hosting` é
privado. Queremos que a função `eat_at_restaurant`, no módulo pai, tenha acesso
à função `add_to_waitlist`, no módulo filho, então marcamos o módulo `hosting`
com a palavra-chave `pub`, como mostra a Listagem 7-5.

<Listing number="7-5" file-name="src/lib.rs" caption="Declarando o módulo `hosting` como `pub` para usá-lo a partir de `eat_at_restaurant`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-05/src/lib.rs:here}}
```

</Listing>

Infelizmente, o código da Listagem 7-5 ainda resulta em erros do compilador,
como mostra a Listagem 7-6.

<Listing number="7-6" caption="Erros do compilador ao tentar compilar o código da Listagem 7-5">

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-05/output.txt}}
```

</Listing>

O que aconteceu? Adicionar a palavra-chave `pub` antes de `mod hosting` torna
o módulo público. Com essa mudança, se conseguirmos acessar `front_of_house`,
conseguiremos acessar `hosting`. Mas o _conteúdo_ de `hosting` continua privado;
tornar o módulo público não torna automaticamente seu conteúdo público. A
palavra-chave `pub` em um módulo só permite que código em seus módulos
ancestrais se refira a ele, e não que acesse seu código interno. Como módulos
são contêineres, não há muito o que fazer tornando apenas o módulo público;
precisamos ir além e escolher tornar público um ou mais itens dentro dele.

Os erros da Listagem 7-6 dizem que a função `add_to_waitlist` é privada. As
regras de privacidade se aplicam a structs, enums, funções e métodos, além de
módulos.

Vamos também tornar pública a função `add_to_waitlist`, adicionando a palavra-
chave `pub` antes de sua definição, como na Listagem 7-7.

<Listing number="7-7" file-name="src/lib.rs" caption="Adicionar a palavra-chave `pub` a `mod hosting` e `fn add_to_waitlist` nos permite chamar a função a partir de `eat_at_restaurant`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-07/src/lib.rs:here}}
```

</Listing>

Agora o código compilará! Para entender por que adicionar a palavra-chave `pub`
nos permite usar esses caminhos em `eat_at_restaurant` em conformidade com as
regras de privacidade, vamos observar os caminhos absoluto e relativo.

No caminho absoluto, começamos com `crate`, a raiz da árvore de módulos da
nossa crate. O módulo `front_of_house` está definido na raiz da crate. Embora
`front_of_house` não seja público, como a função `eat_at_restaurant` está
definida no mesmo módulo que `front_of_house`, ou seja, `eat_at_restaurant` e
`front_of_house` são irmãos, podemos nos referir a `front_of_house` a partir de
`eat_at_restaurant`. Em seguida vem o módulo `hosting`, marcado com `pub`.
Podemos acessar o módulo pai de `hosting`, então podemos acessar `hosting`. Por
fim, a função `add_to_waitlist` está marcada com `pub`, e podemos acessar seu
módulo pai, então essa chamada de função funciona.

No caminho relativo, a lógica é a mesma do caminho absoluto, com exceção do
primeiro passo: em vez de começar na raiz da crate, o caminho começa em
`front_of_house`. O módulo `front_of_house` está definido dentro do mesmo
módulo que `eat_at_restaurant`, então o caminho relativo que começa no módulo
em que `eat_at_restaurant` está definida funciona. Depois, como `hosting` e
`add_to_waitlist` estão marcados com `pub`, o restante do caminho também
funciona, e essa chamada é válida.

Se você pretende compartilhar sua crate de biblioteca para que outros projetos
possam usar seu código, sua API pública é o contrato com as pessoas que usam a
crate, e esse contrato determina como elas podem interagir com o seu código.
Existem muitas considerações envolvidas em gerenciar mudanças na API pública
para tornar mais fácil depender da sua crate. Essas considerações fogem do
escopo deste livro; se esse assunto lhe interessar, consulte [as Rust API
Guidelines][api-guidelines].

> #### Boas práticas para pacotes com binário e biblioteca
>
> Mencionamos que um pacote pode conter tanto uma crate binária com raiz em
> _src/main.rs_ quanto uma crate de biblioteca com raiz em _src/lib.rs_, e por
> padrão ambas terão o nome do pacote. Em geral, pacotes com esse padrão de
> conter uma crate de biblioteca e uma crate binária deixam apenas o código
> suficiente na crate binária para iniciar um executável que chame código
> definido na crate de biblioteca. Isso permite que outros projetos aproveitem
> a maior parte da funcionalidade fornecida pelo pacote, porque o código da
> crate de biblioteca pode ser compartilhado.
>
> A árvore de módulos deve ser definida em _src/lib.rs_. Depois, qualquer item
> público pode ser usado na crate binária começando o caminho pelo nome do
> pacote. A crate binária se torna usuária da crate de biblioteca exatamente
> como aconteceria com uma crate externa qualquer: ela só pode usar a API
> pública. Isso ajuda você a projetar uma boa API, porque você não é só o autor
> dela, mas também seu cliente!
>
> No [Capítulo 12][ch12]<!-- ignore -->, demonstraremos essa prática de
> organização com um programa de linha de comando que conterá tanto uma crate
> binária quanto uma crate de biblioteca.

### Iniciando caminhos relativos com `super`

Podemos construir caminhos relativos que começam no módulo pai, em vez do
módulo atual ou da raiz da crate, usando `super` no início do caminho. Isso é
como começar um caminho de sistema de arquivos com a sintaxe `..`, que
significa ir para o diretório pai. Usar `super` nos permite referenciar um item
que sabemos estar no módulo pai, o que pode facilitar a reorganização da árvore
de módulos quando um módulo está intimamente relacionado ao pai, mas esse pai
pode ser movido futuramente para outra posição na árvore.

Considere o código da Listagem 7-8, que modela a situação em que um chef
corrige um pedido incorreto e o leva pessoalmente ao cliente. A função
`fix_incorrect_order`, definida no módulo `back_of_house`, chama a função
`deliver_order`, definida no módulo pai, especificando o caminho para
`deliver_order` começando com `super`.

<Listing number="7-8" file-name="src/lib.rs" caption="Chamando uma função usando um caminho relativo que começa com `super`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-08/src/lib.rs}}
```

</Listing>

A função `fix_incorrect_order` está no módulo `back_of_house`, então podemos
usar `super` para subir ao módulo pai de `back_of_house`, que neste caso é
`crate`, a raiz. A partir daí, procuramos `deliver_order` e a encontramos.
Sucesso! Achamos provável que o módulo `back_of_house` e a função
`deliver_order` permaneçam na mesma relação entre si e sejam movidos juntos se
um dia decidirmos reorganizar a árvore de módulos da crate. Por isso, usamos
`super`, assim teremos menos lugares para atualizar no futuro caso esse código
seja movido para outro módulo.

### Tornando structs e enums públicos

Também podemos usar `pub` para designar structs e enums como públicos, mas há
alguns detalhes extras no uso de `pub` com structs e enums. Se usarmos `pub`
antes de uma definição de struct, tornamos a struct pública, mas seus campos
continuarão privados. Podemos tornar cada campo público ou não caso a caso. Na
Listagem 7-9, definimos uma struct pública `back_of_house::Breakfast` com um
campo público `toast`, mas um campo privado `seasonal_fruit`. Isso modela o
caso de um restaurante em que o cliente pode escolher o tipo de pão que
acompanha a refeição, mas o chef decide qual fruta virá junto com base no que
está na estação e disponível em estoque. As frutas disponíveis mudam
rapidamente, então clientes não podem escolher a fruta nem sequer ver qual
receberão.

<Listing number="7-9" file-name="src/lib.rs" caption="Uma struct com alguns campos públicos e outros privados">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-09/src/lib.rs}}
```

</Listing>

Como o campo `toast` da struct `back_of_house::Breakfast` é público, em
`eat_at_restaurant` podemos escrever e ler o campo `toast` usando a notação com
ponto. Observe que não podemos usar o campo `seasonal_fruit` em
`eat_at_restaurant`, porque `seasonal_fruit` é privado. Tente descomentar a
linha que modifica `seasonal_fruit` para ver qual erro você recebe!

Além disso, note que, como `back_of_house::Breakfast` tem um campo privado, a
struct precisa fornecer uma função associada pública que construa uma instância
de `Breakfast`, que chamamos aqui de `summer`. Se `Breakfast` não tivesse essa
função, não poderíamos criar uma instância de `Breakfast` em
`eat_at_restaurant`, porque não conseguiríamos definir o valor do campo privado
`seasonal_fruit`.

Em contraste, se tornarmos um enum público, todas as suas variantes passam a
ser públicas. Só precisamos colocar `pub` antes da palavra-chave `enum`, como
na Listagem 7-10.

<Listing number="7-10" file-name="src/lib.rs" caption="Tornar um enum público faz com que todas as suas variantes também sejam públicas">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-10/src/lib.rs}}
```

</Listing>

Como tornamos o enum `Appetizer` público, podemos usar as variantes `Soup` e
`Salad` em `eat_at_restaurant`.

Enums não são muito úteis se suas variantes não forem públicas; seria irritante
ter de anotar todas as variantes de enum com `pub` em todos os casos, então o
comportamento padrão das variantes de enum é serem públicas. Structs
frequentemente continuam úteis mesmo sem campos públicos, então campos de
struct seguem a regra geral de tudo ser privado por padrão, a menos que seja
explicitamente anotado com `pub`.

Há mais uma situação envolvendo `pub` que ainda não cobrimos, e ela está ligada
ao último recurso do sistema de módulos que veremos: a palavra-chave `use`.
Primeiro vamos tratar de `use` por si só, e depois mostraremos como combinar
`pub` e `use`.

[pub]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html#exposing-paths-with-the-pub-keyword
[api-guidelines]: https://rust-lang.github.io/api-guidelines/
[ch12]: ch12-00-an-io-project.html

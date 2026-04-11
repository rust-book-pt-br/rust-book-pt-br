## Caminhos para Referência a um Item na Árvore de Módulos

Para mostrar a Rust onde encontrar um item em uma árvore de módulos, usamos um
caminho da mesma forma como usamos um caminho ao navegar por um sistema de
arquivos. Para chamar uma função, precisamos conhecer seu caminho.

Um caminho pode assumir duas formas:

- Um _caminho absoluto_ é o caminho completo começando na raiz de um crate. No
  caso de código vindo de um crate externo, o caminho absoluto começa com o
  nome do crate; para código do crate atual, começa com o literal `crate`.
- Um _caminho relativo_ começa no módulo atual e usa `self`, `super` ou um
  identificador do módulo atual.

Tanto caminhos absolutos quanto relativos são seguidos por um ou mais
identificadores separados por dois-pontos duplos (`::`).

Voltando à Listagem 7-1, digamos que queremos chamar a função
`add_to_waitlist`. Isso equivale a perguntar: qual é o caminho da função
`add_to_waitlist`? A Listagem 7-3 contém a Listagem 7-1 com alguns dos módulos
e funções removidos.

Mostraremos duas maneiras de chamar a função `add_to_waitlist` a partir de uma
nova função, `eat_at_restaurant`, definida na raiz do crate. Esses caminhos
estão corretos, mas ainda existe outro problema que impedirá esse exemplo de
compilar como está. Já já explicaremos por quê.

A função `eat_at_restaurant` faz parte da API pública do nosso crate de
biblioteca, por isso a marcamos com a palavra-chave `pub`. Na seção [“Expondo
Caminhos com a Palavra-chave `pub`”][pub]<!-- ignore -->, entraremos em mais
detalhes sobre `pub`.

<Listing number="7-3" file-name="src/lib.rs" caption="Chamando a função `add_to_waitlist` usando caminhos absolutos e relativos">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-03/src/lib.rs}}
```

</Listing>

Na primeira vez em que chamamos a função `add_to_waitlist` em
`eat_at_restaurant`, usamos um caminho absoluto. A função `add_to_waitlist` é
definida no mesmo crate que `eat_at_restaurant`, o que significa que podemos
usar a palavra-chave `crate` para iniciar um caminho absoluto. Em seguida,
incluímos cada um dos módulos sucessivos até chegar a `add_to_waitlist`. Você
pode imaginar um sistema de arquivos com a mesma estrutura: especificaríamos o
caminho `/front_of_house/hosting/add_to_waitlist` para executar o programa
`add_to_waitlist`; usar o nome `crate` para começar pela raiz do crate é como
usar `/` para começar pela raiz do sistema de arquivos no shell.

Na segunda vez em que chamamos `add_to_waitlist` em `eat_at_restaurant`,
usamos um caminho relativo. O caminho começa com `front_of_house`, o nome do
módulo definido no mesmo nível da árvore de módulos em que está
`eat_at_restaurant`. O equivalente em um sistema de arquivos seria usar o
caminho `front_of_house/hosting/add_to_waitlist`. Começar com o nome de um
módulo significa que o caminho é relativo.

Escolher entre usar um caminho relativo ou absoluto é uma decisão que você
tomará com base no seu projeto, e depende de ser mais provável mover o código
que define o item separadamente ou junto com o código que o usa. Por exemplo,
se movêssemos o módulo `front_of_house` e a função `eat_at_restaurant` para um
módulo chamado `customer_experience`, precisaríamos atualizar o caminho
absoluto para `add_to_waitlist`, mas o caminho relativo continuaria válido. No
entanto, se movêssemos a função `eat_at_restaurant` separadamente para um
módulo chamado `dining`, o caminho absoluto para a chamada de
`add_to_waitlist` permaneceria o mesmo, mas o caminho relativo precisaria ser
atualizado. Em geral, nossa preferência é especificar caminhos absolutos,
porque é mais provável que queiramos mover definições e chamadas de itens
independentemente umas das outras.

Vamos tentar compilar a Listagem 7-3 e descobrir por que ela ainda não compila!
Os erros que obtemos são mostrados na Listagem 7-4.

<Listing number="7-4" caption="Erros do compilador ao compilar o código da Listagem 7-3">

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-03/output.txt}}
```

</Listing>

As mensagens de erro dizem que o módulo `hosting` é privado. Em outras
palavras, temos os caminhos corretos para o módulo `hosting` e para a função
`add_to_waitlist`, mas Rust não nos permite usá-los porque não temos acesso às
seções privadas. Em Rust, todos os itens, como funções, métodos, structs,
enums, módulos e constantes, são privados em relação aos módulos pais por
padrão. Se você quiser tornar privado um item como uma função ou uma struct,
basta colocá-lo em um módulo.

Itens de um módulo pai não podem usar os itens privados dentro de módulos
filhos, mas itens em módulos filhos podem usar os itens dos seus módulos
ancestrais. Isso acontece porque módulos filhos encapsulam e ocultam seus
detalhes de implementação, mas conseguem ver o contexto em que foram definidos.
Continuando com a metáfora, pense nas regras de privacidade como sendo o
escritório interno de um restaurante: o que acontece ali é privado para os
clientes, mas gerentes conseguem ver e fazer tudo no restaurante que operam.

Rust escolheu fazer o sistema de módulos funcionar dessa maneira para que
ocultar detalhes internos de implementação seja o padrão. Assim, você sabe
quais partes do código interno pode alterar sem quebrar o código externo.
Ainda assim, Rust oferece a opção de expor partes internas do código de módulos
filhos para módulos ancestrais externos usando a palavra-chave `pub` para
tornar um item público.

### Expondo Caminhos com a Palavra-chave `pub`

Voltemos ao erro da Listagem 7-4 que nos dizia que o módulo `hosting` é
privado. Queremos que a função `eat_at_restaurant`, no módulo pai, tenha acesso
à função `add_to_waitlist`, no módulo filho, então marcamos o módulo `hosting`
com a palavra-chave `pub`, como mostrado na Listagem 7-5.

<Listing number="7-5" file-name="src/lib.rs" caption="Declarar o módulo `hosting` como `pub` para usá-lo em `eat_at_restaurant`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-05/src/lib.rs:here}}
```

</Listing>

Infelizmente, o código da Listagem 7-5 ainda resulta em erros do compilador,
como mostra a Listagem 7-6.

<Listing number="7-6" caption="Erros do compilador ao compilar o código da Listagem 7-5">

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-05/output.txt}}
```

</Listing>

O que aconteceu? Adicionar a palavra-chave `pub` antes de `mod hosting` torna o
módulo público. Com essa mudança, se conseguirmos acessar `front_of_house`,
conseguiremos acessar `hosting`. Mas o _conteúdo_ de `hosting` continua sendo
privado; tornar o módulo público não torna seu conteúdo público. A palavra-chave
`pub` em um módulo apenas permite que código em seus módulos ancestrais se
refira a ele, não que acesse seu código interno. Como módulos são contêineres,
há pouco que possamos fazer apenas tornando o módulo público; precisamos ir
além e optar por tornar público um ou mais itens dentro do módulo também.

Os erros da Listagem 7-6 dizem que a função `add_to_waitlist` é privada. As
regras de privacidade se aplicam a structs, enums, funções e métodos, além de
módulos.

Vamos também tornar pública a função `add_to_waitlist` adicionando a
palavra-chave `pub` antes de sua definição, como na Listagem 7-7.

<Listing number="7-7" file-name="src/lib.rs" caption="Adicionar a palavra-chave `pub` a `mod hosting` e `fn add_to_waitlist` nos permite chamar a função a partir de `eat_at_restaurant`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-07/src/lib.rs:here}}
```

</Listing>

Agora o código compilará! Para ver por que adicionar a palavra-chave `pub` nos
permite usar esses caminhos em `eat_at_restaurant` com respeito às regras de
privacidade, vamos observar os caminhos absoluto e relativo.

No caminho absoluto, começamos com `crate`, a raiz da árvore de módulos do
nosso crate. O módulo `front_of_house` é definido na raiz do crate. Embora
`front_of_house` não seja público, como a função `eat_at_restaurant` é
definida no mesmo módulo que `front_of_house`, isto é, `eat_at_restaurant` e
`front_of_house` são irmãos, podemos nos referir a `front_of_house` a partir de
`eat_at_restaurant`. Em seguida vem o módulo `hosting`, marcado com `pub`.
Podemos acessar o módulo pai de `hosting`, então podemos acessar `hosting`.
Finalmente, a função `add_to_waitlist` está marcada com `pub`, e podemos
acessar seu módulo pai; por isso, essa chamada de função funciona.

No caminho relativo, a lógica é a mesma do caminho absoluto, exceto pelo
primeiro passo: em vez de começar na raiz do crate, o caminho começa em
`front_of_house`. O módulo `front_of_house` é definido dentro do mesmo módulo
que `eat_at_restaurant`, então o caminho relativo que parte do módulo em que
`eat_at_restaurant` está definido funciona. Depois, como `hosting` e
`add_to_waitlist` estão marcados com `pub`, o restante do caminho funciona, e
essa chamada de função é válida.

Se você pretende compartilhar seu crate de biblioteca para que outros projetos
possam usar seu código, sua API pública é o contrato com as pessoas usuárias do
seu crate e determina como elas podem interagir com o seu código. Existem
muitas considerações envolvidas em gerenciar mudanças na sua API pública para
facilitar a vida de quem depende do seu crate. Essas considerações fogem do
escopo deste livro; se você tiver interesse nesse tema, consulte [as Diretrizes
de API de Rust][api-guidelines].

> #### Boas Práticas para Pacotes com Binário e Biblioteca
>
> Mencionamos que um pacote pode conter tanto uma raiz de crate binário
> _src/main.rs_ quanto uma raiz de crate de biblioteca _src/lib.rs_, e ambos os
> crates terão o nome do pacote por padrão. Em geral, pacotes com esse padrão,
> contendo tanto um crate de biblioteca quanto um crate binário, terão no crate
> binário apenas código suficiente para iniciar um executável que chama o código
> definido no crate de biblioteca. Isso permite que outros projetos se
> beneficiem da maior parte da funcionalidade fornecida pelo pacote, porque o
> código do crate de biblioteca pode ser compartilhado.
>
> A árvore de módulos deve ser definida em _src/lib.rs_. Então, quaisquer itens
> públicos poderão ser usados no crate binário iniciando os caminhos com o nome
> do pacote. O crate binário se torna um usuário do crate de biblioteca, do
> mesmo modo que um crate externo o faria: ele só pode usar a API pública. Isso
> ajuda você a projetar uma boa API; você não é apenas a pessoa autora, mas
> também cliente.
>
> No [Capítulo 12][ch12]<!-- ignore -->, demonstraremos essa prática de
> organização com um programa de linha de comando que conterá tanto um crate
> binário quanto um crate de biblioteca.

### Iniciando Caminhos Relativos com `super`

Podemos construir caminhos relativos que começam no módulo pai, em vez de no
módulo atual ou na raiz do crate, usando `super` no início do caminho. Isso é
como iniciar um caminho de sistema de arquivos com a sintaxe `..`, que
significa ir para o diretório pai. Usar `super` nos permite referenciar um item
que sabemos estar no módulo pai, o que pode facilitar a reorganização da árvore
de módulos quando o módulo está intimamente relacionado ao pai, mas o pai pode
vir a ser movido para outro lugar da árvore de módulos no futuro.

Considere o código da Listagem 7-8, que modela a situação em que um chef
corrige um pedido errado e o leva pessoalmente ao cliente. A função
`fix_incorrect_order`, definida no módulo `back_of_house`, chama a função
`deliver_order`, definida no módulo pai, especificando o caminho para
`deliver_order` e começando com `super`.

<Listing number="7-8" file-name="src/lib.rs" caption="Chamando uma função usando um caminho relativo que começa com `super`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-08/src/lib.rs}}
```

</Listing>

A função `fix_incorrect_order` está no módulo `back_of_house`, então podemos
usar `super` para ir ao módulo pai de `back_of_house`, que neste caso é
`crate`, a raiz. A partir daí, procuramos por `deliver_order` e a encontramos.
Sucesso! Acreditamos que o módulo `back_of_house` e a função `deliver_order`
provavelmente permanecerão na mesma relação entre si e serão movidos juntos
caso decidamos reorganizar a árvore de módulos do crate. Por isso, usamos
`super` para ter menos lugares a atualizar no futuro, caso esse código seja
movido para um módulo diferente.

### Tornando Structs e Enums Públicas

Também podemos usar `pub` para designar structs e enums como públicas, mas há
alguns detalhes extras no uso de `pub` com structs e enums. Se usarmos `pub`
antes de uma definição de struct, tornamos a struct pública, mas os campos da
struct continuarão privados. Podemos tornar cada campo público ou não caso a
caso. Na Listagem 7-9, definimos uma struct pública
`back_of_house::Breakfast` com um campo público `toast`, mas um campo privado
`seasonal_fruit`. Isso modela o caso de um restaurante em que o cliente pode
escolher o tipo de pão que acompanha a refeição, mas o chef decide qual fruta
acompanhará a refeição com base no que está na estação e em estoque. A fruta
disponível muda rapidamente, então clientes não podem escolher a fruta nem
mesmo ver qual receberão.

<Listing number="7-9" file-name="src/lib.rs" caption="Uma struct com alguns campos públicos e outros privados">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-09/src/lib.rs}}
```

</Listing>

Como o campo `toast` na struct `back_of_house::Breakfast` é público, em
`eat_at_restaurant` podemos escrever e ler o campo `toast` usando a notação de
ponto. Observe que não podemos usar o campo `seasonal_fruit` em
`eat_at_restaurant`, porque `seasonal_fruit` é privado. Experimente descomentar
a linha que modifica o valor de `seasonal_fruit` para ver qual erro você obtém!

Observe também que, como `back_of_house::Breakfast` tem um campo privado, a
struct precisa fornecer uma função associada pública que construa uma instância
de `Breakfast`; aqui nós a chamamos de `summer`. Se `Breakfast` não tivesse
essa função, não conseguiríamos criar uma instância de `Breakfast` em
`eat_at_restaurant`, porque não poderíamos definir em `eat_at_restaurant` o
valor do campo privado `seasonal_fruit`.

Em contraste, se tornarmos uma enum pública, todas as suas variantes também
passarão a ser públicas. Precisamos apenas de `pub` antes da palavra-chave
`enum`, como mostrado na Listagem 7-10.

<Listing number="7-10" file-name="src/lib.rs" caption="Designar uma enum como pública torna públicas todas as suas variantes">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-10/src/lib.rs}}
```

</Listing>

Como tornamos a enum `Appetizer` pública, podemos usar as variantes `Soup` e
`Salad` em `eat_at_restaurant`.

Enums não são muito úteis a menos que suas variantes sejam públicas; seria
incômodo ter de anotar todas as variantes de enum com `pub` em todos os casos,
por isso o padrão para variantes de enum é serem públicas. Structs costumam
ser úteis mesmo sem que seus campos sejam públicos, então campos de struct
seguem a regra geral de que tudo é privado por padrão, a menos que seja
anotado com `pub`.

Há mais uma situação envolvendo `pub` que ainda não abordamos, e ela corresponde
ao último recurso do sistema de módulos: a palavra-chave `use`. Primeiro
falaremos de `use` por si só, e depois mostraremos como combinar `pub` e
`use`.

[pub]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html#exposing-paths-with-the-pub-keyword
[api-guidelines]: https://rust-lang.github.io/api-guidelines/
[ch12]: ch12-00-an-io-project.html

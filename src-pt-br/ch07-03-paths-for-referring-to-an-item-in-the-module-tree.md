## Caminhos para referência a um item na árvore de módulos

Para mostrar ao Rust onde encontrar um item em uma árvore de módulos, usamos um caminho no mesmo
maneira como usamos um caminho ao navegar em um sistema de arquivos. Para chamar uma função, precisamos
conheça seu caminho.

Um caminho pode assumir duas formas:

- Um _caminho absoluto_ é o caminho completo começando na raiz da crate; para código
de uma crate externa, o caminho absoluto começa com o nome da crate e, para
código da crate atual, ele começa com o literal `crate`.
- Um _caminho relativo_ começa no módulo atual e usa `self`, `super` ou
um identificador no módulo atual.

Os caminhos absolutos e relativos são seguidos por um ou mais identificadores
separados por dois pontos duplos (`::`).

Voltando à Listagem 7-1, digamos que queremos chamar a função `add_to_waitlist`.
Isso é o mesmo que perguntar: Qual é o caminho da função `add_to_waitlist`?
A Listagem 7-3 contém a Listagem 7-1 com alguns dos módulos e funções removidos.

Mostraremos duas maneiras de chamar a função `add_to_waitlist` a partir de uma nova função,
`eat_at_restaurant`, definido na raiz da crate. Esses caminhos estão corretos, mas
ainda há outro problema que impedirá a compilação deste exemplo
como está. Explicaremos o porquê daqui a pouco.

A função `eat_at_restaurant` faz parte da API pública da nossa biblioteca, então
nós o marcamos com a palavra-chave `pub`. Na seção [“Expondo caminhos com `pub`
Seção Palavra-chave ”][pub]<!-- ignore -->, entraremos em mais detalhes sobre `pub`.

<Listing number="7-3" file-name="src/lib.rs" caption="Calling the `add_to_waitlist` function using absolute and relative paths">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-03/src/lib.rs}}
```

</Listing>

A primeira vez que chamamos a função `add_to_waitlist` em `eat_at_restaurant`,
usamos um caminho absoluto. A função `add_to_waitlist` é definida da mesma forma
crate como `eat_at_restaurant`, o que significa que podemos usar a palavra-chave `crate` para
iniciar um caminho absoluto. Em seguida, incluímos cada um dos módulos sucessivos até que
siga para `add_to_waitlist`. Você pode imaginar um sistema de arquivos com o mesmo
estrutura: especificaríamos o caminho `/front_of_house/hosting/add_to_waitlist` para
execute o programa `add_to_waitlist`; usando o nome `crate` para começar do
crate root é como usar `/` para iniciar a partir da raiz do sistema de arquivos em seu shell.

Na segunda vez que chamamos `add_to_waitlist` em `eat_at_restaurant`, usamos um
caminho relativo. O caminho começa com `front_of_house`, o nome do módulo
definido no mesmo nível da árvore de módulos que `eat_at_restaurant`. Aqui o
equivalente do sistema de arquivos estaria usando o caminho
`front_of_house/hosting/add_to_waitlist`. Começar com um nome de módulo significa
que o caminho é relativo.

Escolher usar um caminho relativo ou absoluto é uma decisão que você tomará
com base no seu projeto e depende se você tem maior probabilidade de mudar
código de definição de item separadamente ou em conjunto com o código que usa o
item. Por exemplo, se movemos o módulo `front_of_house` e o
`eat_at_restaurant` em um módulo chamado `customer_experience`, teríamos
precisa atualizar o caminho absoluto para `add_to_waitlist`, mas o caminho relativo
ainda seria válido. No entanto, se movermos a função `eat_at_restaurant`
separadamente em um módulo chamado `dining`, o caminho absoluto para o
A chamada `add_to_waitlist` permaneceria a mesma, mas o caminho relativo precisaria
ser atualizado. Nossa preferência em geral é especificar caminhos absolutos porque é
é mais provável que desejemos mover definições de código e chamadas de item independentemente de
uns aos outros.

Vamos tentar compilar a Listagem 7.3 e descobrir por que ela ainda não foi compilada! O
os erros que obtemos são mostrados na Listagem 7-4.

<Listing number="7-4" caption="Compiler errors from building the code in Listing 7-3">

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-03/output.txt}}
```

</Listing>

As mensagens de erro dizem que o módulo `hosting` é privado. Em outras palavras, nós
tenha os caminhos corretos para o módulo `hosting` e o `add_to_waitlist`
função, mas Rust não nos permite usá-los porque não tem acesso ao
seções privadas. No Rust, todos os itens (funções, métodos, estruturas, enums,
módulos e constantes) são privados dos módulos pai por padrão. Se você quiser
para tornar um item como uma função ou estrutura privada, você o coloca em um módulo.

Os itens em um módulo pai não podem usar os itens privados dentro dos módulos filhos, mas
itens em módulos filhos podem usar os itens em seus módulos ancestrais. Isso é
porque os módulos filhos encapsulam e ocultam seus detalhes de implementação, mas o filho
os módulos podem ver o contexto em que estão definidos. Para continuar com o nosso
metáfora, pense nas regras de privacidade como sendo o back office de uma
restaurante: o que acontece lá é privado para os clientes do restaurante, mas
os gerentes de escritório podem ver e fazer tudo no restaurante que operam.

Rust optou por fazer com que o sistema de módulos funcionasse dessa maneira, para que ocultasse o interior
detalhes de implementação é o padrão. Dessa forma, você sabe quais partes do
código interno você pode alterar sem quebrar o código externo. No entanto, Rust faz
oferece a opção de expor as partes internas do código dos módulos filhos aos externos
módulos ancestrais usando a palavra-chave `pub` para tornar um item público.

### Expondo caminhos com a palavra-chave `pub`

Vamos voltar ao erro na Listagem 7-4 que nos disse que o módulo `hosting` é
privado. Queremos que a função `eat_at_restaurant` no módulo pai tenha
acesso à função `add_to_waitlist` no módulo filho, então marcamos o
`hosting` com a palavra-chave `pub`, conforme mostrado na Listagem 7-5.

<Listing number="7-5" file-name="src/lib.rs" caption="Declaring the `hosting` module as `pub` to use it from `eat_at_restaurant`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-05/src/lib.rs:here}}
```

</Listing>

Infelizmente, o código na Listagem 7-5 ainda resulta em erros do compilador, como
mostrado na Listagem 7-6.

<Listing number="7-6" caption="Compiler errors from building the code in Listing 7-5">

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-05/output.txt}}
```

</Listing>

O que aconteceu? Adicionar a palavra-chave `pub` na frente de `mod hosting` faz com que
módulo público. Com esta mudança, se pudermos acessar `front_of_house`, podemos
acesse `hosting`. Mas o _conteúdo_ de `hosting` ainda é privado; fazendo o
O módulo public não torna seu conteúdo público. A palavra-chave `pub` em um módulo
apenas permite que o código em seus módulos ancestrais se refira a ele, e não acesse seu código interno.
Como os módulos são contêineres, não há muito que possamos fazer apenas criando os
módulo público; precisamos ir mais longe e optar por fazer um ou mais dos
itens dentro do módulo public também.

Os erros na Listagem 7-6 dizem que a função `add_to_waitlist` é privada.
As regras de privacidade se aplicam a estruturas, enumerações, funções e métodos, bem como
módulos.

Vamos também tornar pública a função `add_to_waitlist` adicionando `pub`
palavra-chave antes de sua definição, como na Listagem 7-7.

<Listing number="7-7" file-name="src/lib.rs" caption="Adding the `pub` keyword to `mod hosting` and `fn add_to_waitlist` lets us call the function from `eat_at_restaurant`.">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-07/src/lib.rs:here}}
```

</Listing>

Agora o código será compilado! Para ver por que adicionar a palavra-chave `pub` nos permite usar
esses caminhos em `eat_at_restaurant` com respeito às regras de privacidade, vamos
observe os caminhos absolutos e relativos.

No caminho absoluto, começamos com `crate`, a raiz do módulo da nossa crate
árvore. O módulo `front_of_house` é definido na raiz da crate. Enquanto
`front_of_house` não é público, porque a função `eat_at_restaurant` é
definido no mesmo módulo que `front_of_house` (ou seja, `eat_at_restaurant`
e `front_of_house` são irmãos), podemos nos referir a `front_of_house` de
`eat_at_restaurant`. O próximo é o módulo `hosting` marcado com `pub`. Pudermos
acesse o módulo pai de `hosting`, para que possamos acessar `hosting`. Finalmente, o
A função `add_to_waitlist` está marcada com `pub` e podemos acessar seu pai
módulo, então esta chamada de função funciona!

No caminho relativo, a lógica é a mesma do caminho absoluto, exceto pelo
primeiro passo: em vez de começar na raiz da crate, o caminho começa
`front_of_house`. O módulo `front_of_house` é definido dentro do mesmo módulo
como `eat_at_restaurant`, então o caminho relativo começando no módulo no qual
`eat_at_restaurant` é trabalho definido. Então, porque `hosting` e
`add_to_waitlist` estão marcados com `pub`, o resto do caminho funciona, e este
a chamada de função é válida!

Se você planeja compartilhar sua crate de biblioteca para que outros projetos possam usar sua
código, sua API pública é o seu contrato com os usuários da sua crate que determina
como eles podem interagir com seu código. Existem muitas considerações em torno
gerenciar alterações em sua API pública para facilitar a dependência das pessoas
sua crate. Estas considerações estão além do escopo deste livro; se você estiver
interessado neste tópico, consulte [as Diretrizes da API Rust][api-guidelines].

> #### Melhores práticas para pacotes com binário e biblioteca
>
> Mencionamos que um pacote pode conter uma crate binária _src/main.rs_
> root, bem como uma raiz da crate da biblioteca _src/lib.rs_, e ambas as crates terão
> o nome do pacote por padrão. Normalmente, pacotes com esse padrão de
> contendo uma biblioteca e uma crate binária terá código suficiente no
> crate binária para iniciar um executável que chama o código definido na biblioteca
> crate. Isso permite que outros projetos se beneficiem do máximo de funcionalidades que o
> pacote fornece porque o código da crate da biblioteca pode ser compartilhado.
>
> A árvore do módulo deve ser definida em _src/lib.rs_. Então, quaisquer itens públicos podem
> ser usado na crate binária iniciando os caminhos com o nome do pacote.
> A crate binária se torna um usuário da crate da biblioteca, assim como um completamente
> A crate externa usaria a crate da biblioteca: ela só pode usar a API pública.
> Isso ajuda você a projetar uma boa API; você não é apenas o autor, mas também
> também cliente!
>
> No [Capítulo 12][ch12]<!-- ignore -->, demonstraremos esta organização
> pratique com um programa de linha de comando que conterá uma crate binária
> e uma crate de biblioteca.

### Iniciando caminhos relativos com `super`

Podemos construir caminhos relativos que começam no módulo pai, em vez de
o módulo atual ou a raiz da crate, usando `super` no início do
caminho. É como iniciar um caminho de sistema de arquivos com a sintaxe `..` que significa
para ir para o diretório pai. Usar `super` nos permite fazer referência a um item
que sabemos que está no módulo pai, o que pode tornar a reorganização do módulo
árvore mais fácil quando o módulo está intimamente relacionado ao pai, mas o pai
pode ser movido para outro lugar na árvore de módulos algum dia.

Considere o código da Listagem 7.8 que modela a situação em que um chef
corrige um pedido incorreto e o leva pessoalmente ao cliente. O
função `fix_incorrect_order` definida no módulo `back_of_house` chama o
função `deliver_order` definida no módulo pai especificando o caminho para
`deliver_order`, começando com `super`.

<Listing number="7-8" file-name="src/lib.rs" caption="Calling a function using a relative path starting with `super`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-08/src/lib.rs}}
```

</Listing>

A função `fix_incorrect_order` está no módulo `back_of_house`, então podemos
use `super` para ir para o módulo pai de `back_of_house`, que neste caso
é `crate`, a raiz. A partir daí, procuramos `deliver_order` e o encontramos.
Sucesso! Achamos que o módulo `back_of_house` e a função `deliver_order`
provavelmente permanecerão no mesmo relacionamento um com o outro e se mudarão
juntos caso decidamos reorganizar a árvore de módulos da crate. Portanto, nós
usei `super` para que tenhamos menos lugares para atualizar o código no futuro se
este código é movido para um módulo diferente.

### Tornando Estruturas e Enums Públicas

Também podemos usar `pub` para designar estruturas e enums como públicas, mas há uma
alguns detalhes extras sobre o uso de `pub` com estruturas e enumerações. Se usarmos `pub`
antes de uma definição de struct, tornamos a struct pública, mas os campos da struct
ainda será privado. Podemos tornar cada campo público ou não caso a caso
base. Na Listagem 7-9, definimos uma estrutura pública `back_of_house::Breakfast`
com um campo público `toast`, mas um campo privado `seasonal_fruit`. Este modelo
é o caso de um restaurante onde o cliente pode escolher o tipo de pão que
acompanha a refeição, mas o chef decide quais frutas acompanham a refeição com base
sobre o que está na temporada e em estoque. A fruta disponível muda rapidamente, então
os clientes não podem escolher as frutas ou mesmo ver quais frutas receberão.

<Listing number="7-9" file-name="src/lib.rs" caption="A struct with some public fields and some private fields">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-09/src/lib.rs}}
```

</Listing>

Como o campo `toast` na estrutura `back_of_house::Breakfast` é público,
em `eat_at_restaurant` podemos escrever e ler o campo `toast` usando ponto
notação. Observe que não podemos usar o campo `seasonal_fruit` em
`eat_at_restaurant`, porque `seasonal_fruit` é privado. Tente descomentar o
linha modificando o valor do campo `seasonal_fruit` para ver qual erro você obteve!

Além disso, observe que, como `back_of_house::Breakfast` possui um campo privado, o
struct precisa fornecer uma função pública associada que construa um
instância de `Breakfast` (nós a chamamos de `summer` aqui). Se `Breakfast` não
tiver tal função, não poderíamos criar uma instância de `Breakfast` em
`eat_at_restaurant`, porque não foi possível definir o valor do private
Campo `seasonal_fruit` em `eat_at_restaurant`.

Por outro lado, se tornarmos um enum público, todas as suas variantes serão públicas. Nós
só precisa do `pub` antes da palavra-chave `enum`, conforme mostrado na Listagem 7.10.

<Listing number="7-10" file-name="src/lib.rs" caption="Designating an enum as public makes all its variants public.">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-10/src/lib.rs}}
```

</Listing>

Como tornamos o enum `Appetizer` público, podemos usar `Soup` e `Salad`
variantes em `eat_at_restaurant`.

Enums não são muito úteis, a menos que suas variantes sejam públicas; seria irritante
ter que anotar todas as variantes de enum com `pub` em todos os casos, então o padrão
para variantes enum deve ser público. As estruturas são frequentemente úteis sem a sua
os campos são públicos, então os campos struct seguem a regra geral de tudo
sendo privado por padrão, a menos que seja anotado com `pub`.

Há mais uma situação envolvendo `pub` que não abordamos, e é
nosso último recurso do sistema de módulo: a palavra-chave `use`. Cobriremos `use` sozinho
primeiro, e depois mostraremos como combinar `pub` e `use`.

[pub]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html#exposing-paths-with-the-pub-keyword
[api-guidelines]: https://rust-lang.github.io/api-guidelines/
[ch12]: ch12-00-an-io-project.html

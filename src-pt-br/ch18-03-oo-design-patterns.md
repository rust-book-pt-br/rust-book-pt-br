## Implementando um padrão de design orientado a objetos

O _state pattern_ é um padrão de design orientado a objetos. O ponto crucial do
O padrão é que definimos um conjunto de estados que um valor pode ter internamente. O
estados são representados por um conjunto de _objetos de estado_, e o comportamento do valor
muda com base em seu estado. Vamos trabalhar com um exemplo de blog
post struct que possui um campo para armazenar seu estado, que será um objeto de estado
do conjunto “rascunho”, “revisão” ou “publicado”.

Os objetos de estado compartilham funcionalidade: No Rust, é claro, usamos structs e
traits em vez de objetos e herança. Cada objeto de estado é responsável
por seu próprio comportamento e por governar quando deveria se transformar em outro
estado. O valor que contém um objeto de estado não sabe nada sobre os diferentes
comportamento dos estados ou quando fazer a transição entre estados.

A vantagem de usar o padrão estatal é que, quando o negócio
requisitos da mudança do programa, não precisaremos alterar o código do
valor que contém o estado ou o código que usa o valor. Só precisaremos
atualizar o código dentro de um dos objetos de estado para alterar suas regras ou talvez
adicione mais objetos de estado.

Primeiro, vamos implementar o padrão de estado de uma forma mais tradicional
maneira orientada a objetos. Então, usaremos uma abordagem um pouco mais natural em
Rust. Vamos nos aprofundar na implementação incremental de um fluxo de trabalho de postagem de blog usando o
padrão de estado.

A funcionalidade final ficará assim:

1. Uma postagem de blog começa como um rascunho vazio.
1. Terminado o rascunho, é solicitada a revisão da postagem.
1. Quando a postagem for aprovada, ela será publicada.
1. Somente postagens de blog publicadas retornam conteúdo para impressão, para que postagens não aprovadas
   não pode ser publicado acidentalmente.

Quaisquer outras alterações tentadas em uma postagem não terão efeito. Por exemplo, se nós
tentar aprovar um rascunho de postagem do blog antes de solicitarmos uma revisão, a postagem
deve permanecer um rascunho não publicado.

<!-- Old headings. Do not remove or links may break. -->

<a id="a-traditional-object-oriented-attempt"></a>

### Attempting Traditional Object-Oriented Style

Existem infinitas maneiras de estruturar código para resolver o mesmo problema, cada uma com
diferentes compensações. A implementação desta seção é mais tradicional
estilo orientado a objetos, que é possível escrever em Rust, mas não leva
vantagem de alguns dos pontos fortes do Rust. Mais tarde, demonstraremos um diferente
solução que ainda usa o padrão de design orientado a objetos, mas é estruturada
de uma forma que pode parecer menos familiar para programadores com orientação a objetos
experiência. Compararemos as duas soluções para experimentar as compensações de
projetar o código Rust de maneira diferente do código em outras linguagens.

A Listagem 18-11 mostra esse fluxo de trabalho em forma de código: Este é um exemplo de uso do
API que implementaremos em uma biblioteca crate chamada `blog`. Isso ainda não será compilado
porque não implementamos o ` blog`crate.

<Listing number="18-11" file-name="src/main.rs" caption="Código que demonstra o comportamento desejado que queremos para o crate `blog`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch18-oop/listing-18-11/src/main.rs:all}}
```

</Listing>

Queremos permitir que o usuário crie um novo rascunho de postagem no blog com `Post::new`. Nós
deseja permitir que texto seja adicionado à postagem do blog. Se tentarmos obter o post
conteúdo imediatamente, antes da aprovação, não devemos receber nenhum texto porque o
a postagem ainda é um rascunho. Adicionamos ` assert_eq!`no código para demonstração
propósitos. Um excelente teste de unidade para isso seria afirmar que um rascunho de blog
post retorna uma string vazia do método ` content`, mas não vamos
escreva testes para este exemplo.

Em seguida, queremos ativar uma solicitação de revisão da postagem e queremos
`content ` para retornar uma string vazia enquanto aguarda a revisão. Quando a postagem
receber aprovação, deverá ser publicado, ou seja, o texto da postagem será
será retornado quando`content` for chamado.

Observe que o único tipo com o qual estamos interagindo no crate é o `Post`
tipo. Este tipo usará o padrão de estado e conterá um valor que será
um dos três objetos de estado que representam os vários estados que uma postagem pode ser
in - rascunho, revisão ou publicado. A mudança de um estado para outro será
gerenciado internamente dentro do tipo ` Post`. Os estados mudam em resposta à
métodos chamados pelos usuários de nossa biblioteca na instância ` Post`, mas eles não
tem que gerenciar as mudanças de estado diretamente. Além disso, os usuários não podem cometer erros
com os estados, como publicar uma postagem antes de ser revisada.

<!-- Old headings. Do not remove or links may break. -->

<a id="defining-post-and-creating-a-new-instance-in-the-draft-state"></a>

#### Definindo `Post` e criando uma nova instância

Vamos começar a implementação da biblioteca! Sabemos que precisamos de um
estrutura pública `Post` que contém algum conteúdo, então começaremos com o
definição da estrutura e uma função `new` pública associada para criar um
instância de `Post`, conforme mostrado na Listagem 18-12. Também faremos um privado
` State `trait que definirá o comportamento de todos os objetos de estado para um` Post`
deve ter.

Então, `Post` irá manter um objeto trait de `Box<dyn State>` dentro de um `Option<T>`
em um campo privado denominado ` state`para armazenar o objeto de estado. Você verá por que
` Option<T>`será necessário em breve.

<Listing number="18-12" file-name="src/lib.rs" caption="Definição de uma struct `Post`, de uma função `new` que cria uma nova instância de `Post`, de uma trait `State` e de uma struct `Draft`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-12/src/lib.rs}}
```

</Listing>

O `State` trait define o comportamento compartilhado por diferentes estados de postagem. O
objetos de estado são `Draft`, ` PendingReview`e ` Published`, e todos eles serão
implementar o ` State`trait. Por enquanto, o trait não possui nenhum método, e
começaremos definindo apenas o estado ` Draft`porque esse é o estado que
quero uma postagem para começar.

Quando criamos um novo `Post`, definimos seu campo ` state`para um valor ` Some`que
contém um ` Box`. Este ` Box`aponta para uma nova instância da estrutura ` Draft`. Isto
garante que sempre que criarmos uma nova instância de ` Post`, ela começará como
um rascunho. Como o campo ` state`de ` Post`é privado, não há como
crie um ` Post`em qualquer outro estado! Na função ` Post::new`, definimos o
` content `para um novo` String`vazio.

#### Armazenando o texto do conteúdo da postagem

Vimos na Listagem 18-11 que queremos poder chamar um método chamado
`add_text ` e passe um`&str ` que é então adicionado como o conteúdo de texto do
postagem no blog. Implementamos isso como um método, em vez de expor o`content `
campo como` pub `, para que posteriormente possamos implementar um método que irá controlar como
os dados do campo` content `são lidos. O método` add_text `é bonito
simples, então vamos adicionar a implementação da Listagem 18.13 ao bloco` impl
Post`.

<Listing number="18-13" file-name="src/lib.rs" caption="Implementando o método `add_text` para adicionar texto ao `content` de um post">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-13/src/lib.rs:here}}
```

</Listing>

O método `add_text` usa uma referência mutável para `self` porque estamos
alterando a instância `Post` na qual estamos chamando `add_text`. Chamamos então
` push_str `no` String `em` content `e passe o argumento` text `para adicionar
o` content `salvo. Esse comportamento não depende do estado em que a postagem se encontra,
então não faz parte do padrão estadual. O método` add_text `não interage
com o campo` state`, mas faz parte do comportamento que queremos
suporte.

<!-- Old headings. Do not remove or links may break. -->

<a id="ensuring-the-content-of-a-draft-post-is-empty"></a>

#### Garantindo que o conteúdo de um rascunho de postagem esteja vazio

Mesmo depois de ligarmos para `add_text` e adicionarmos algum conteúdo à nossa postagem, ainda
deseja que o método `content` retorne uma string vazia slice porque a postagem é
ainda em estado de rascunho, conforme mostrado pelo primeiro `assert_eq!` na Listagem 18-11.
Por enquanto, vamos implementar o método `content` com a coisa mais simples que irá
cumpra este requisito: sempre retornando uma string vazia slice. Nós vamos mudar
isso mais tarde, quando implementarmos a capacidade de alterar o estado de uma postagem para que ela
pode ser publicado. Até agora, as postagens só podem estar no estado de rascunho, então a postagem
o conteúdo deve estar sempre vazio. A Listagem 18-14 mostra este espaço reservado
implementação.

<Listing number="18-14" file-name="src/lib.rs" caption="Adicionando uma implementação provisória para o método `content` em `Post` que sempre retorna um string slice vazio">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-14/src/lib.rs:here}}
```

</Listing>

Com esse método `content` adicionado, tudo na Listagem 18-11 até o primeiro
`assert_eq!` funciona conforme planejado.

<!-- Old headings. Do not remove or links may break. -->

<a id="requesting-a-review-of-the-post-changes-its-state"></a>
<a id="requesting-a-review-changes-the-posts-state"></a>

#### Solicitando uma revisão, que altera o estado da postagem

Em seguida, precisamos adicionar funcionalidade para solicitar a revisão de uma postagem, que deve
altere seu estado de `Draft` para `PendingReview`. A Listagem 18-15 mostra esse código.

<Listing number="18-15" file-name="src/lib.rs" caption="Implementando métodos `request_review` em `Post` e na trait `State`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-15/src/lib.rs:here}}
```

</Listing>

Damos ao `Post` um método público chamado `request_review` que terá um valor mutável
referência a `self`. Então, chamamos um método ` request_review`interno no
estado atual de ` Post`, e este segundo método ` request_review`consome o
estado atual e retorna um novo estado.

Adicionamos o método `request_review` ao `State` trait; todos os tipos que
implementar o trait agora precisará implementar o método `request_review`.
Observe que em vez de ter ` self`, ` &self`ou ` &mut self`como o primeiro
parâmetro do método, temos ` self: Box<Self>`. Esta sintaxe significa o
O método só é válido quando chamado em um ` Box`que contém o tipo. Esta sintaxe leva
ownership de ` Box<Self>`, invalidando o estado antigo para que o valor do estado de
o ` Post`pode se transformar em um novo estado.

Para consumir o estado antigo, o método `request_review` precisa tomar ownership
do valor do estado. É aí que entra o `Option` no campo `state` de `Post`:
chamamos o método `take` para retirar o valor `Some` do campo `state` e deixar
um `None` em seu lugar, porque o Rust não nos permite ter campos não
preenchidos em structs. Isso nos permite mover o valor de `state` para fora de
`Post`, em vez de apenas pegá-lo emprestado. Em seguida, definimos o valor de
`state` do post como o resultado dessa operação.

Precisamos definir `state` temporariamente como `None`, em vez de defini-lo
diretamente com código como `self.state = self.state.request_review();`, para
obter ownership do valor de `state`. Isso garante que `Post` não possa usar o
valor antigo de `state` depois de transformá-lo em um novo estado.

O método `request_review` em `Draft` retorna uma nova instância encaixotada de
uma nova struct `PendingReview`, que representa o estado em que um post está
aguardando revisão. A struct `PendingReview` também implementa o método
`request_review`, mas ele não realiza nenhuma transformação. Em vez disso, ele
retorna a si mesmo, porque, quando solicitamos revisão para um post que já está
no estado `PendingReview`, ele deve continuar nesse estado.

Agora podemos começar a ver as vantagens do padrão estatal:
O método `request_review` em `Post` é o mesmo, independentemente do valor `state`. Cada
O Estado é responsável pelas suas próprias regras.

Deixaremos o método `content` em `Post` como está, retornando uma string vazia
slice. Agora podemos ter um `Post` no estado `PendingReview`, bem como no estado
estado ` Draft`, mas queremos o mesmo comportamento no estado ` PendingReview`.
A Listagem 18-11 agora funciona até a segunda chamada ` assert_eq!`!

<!-- Old headings. Do not remove or links may break. -->

<a id="adding-the-approve-method-that-changes-the-behavior-of-content"></a>
<a id="adding-approve-to-change-the-behavior-of-content"></a>

#### Adding `approve` to Change `content`'s Behavior

O método `approve` será semelhante ao método `request_review`: Será
defina ` state`para o valor que o estado atual diz que deveria ter quando isso
estado é aprovado, conforme mostrado na Listagem 18-16.

<Listing number="18-16" file-name="src/lib.rs" caption="Implementando o método `approve` em `Post` e na trait `State`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-16/src/lib.rs:here}}
```

</Listing>

Adicionamos o método `approve` ao `State` trait e adicionamos uma nova estrutura que
implementa `State`, o estado ` Published`.

Semelhante à forma como `request_review` em `PendingReview` funciona, se chamarmos o
método `approve` em um `Draft`, não terá efeito porque ` approve`
retorne ` self`. Quando chamamos ` approve`em ` PendingReview`, ele retorna um novo,
instância em caixa da estrutura ` Published`. A estrutura ` Published`implementa o
` State `trait, e tanto para o método` request_review `quanto para o` approve `
método, ele retorna sozinho porque a postagem deve permanecer no estado` Published`
nesses casos.

Agora precisamos atualizar o método `content` em `Post`. Queremos o valor
retornado de ` content`para depender do estado atual do ` Post`, então estamos
terá o ` Post`delegado a um método ` content`definido em seu ` state`,
conforme mostrado na Listagem 18-17.

<Listing number="18-17" file-name="src/lib.rs" caption="Atualizando o método `content` em `Post` para delegar a um método `content` em `State`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch18-oop/listing-18-17/src/lib.rs:here}}
```

</Listing>

Porque o objetivo é manter todas essas regras dentro das estruturas que
implementar `State`, chamamos um método ` content`no valor em ` state`e passamos
a instância post (ou seja, ` self`) como um argumento. Então, retornamos o valor
que é retornado ao usar o método ` content`no valor ` state`.

Chamamos o método `as_ref` no `Option` porque queremos uma referência ao
valor dentro de `Option` em vez de ownership do valor. Porque `state` é
um `Option<Box<dyn State>>`, quando chamamos ` as_ref`, um ` Option<&Box<dyn
State>>`é retornado. Se não chamássemos ` as_ref`, receberíamos um erro porque
não podemos mover ` state`do ` &self`emprestado do parâmetro de função.

Chamamos então o método `unwrap`, que sabemos que nunca será panic porque
conhecer os métodos em ` Post`garantir que ` state`sempre conterá um ` Some`
valor quando esses métodos são concluídos. Este é um dos casos de que falamos em
o [“Quando você tem mais informações do que o
Compilador”][more-info-than-rustc]seção <!-- ignore --> do Capítulo 9 quando
saiba que um valor ` None`nunca é possível, mesmo que o compilador não seja capaz
para entender isso.

Neste ponto, quando chamamos `content` no `&Box<dyn State>`, a coerção deref
entrará em vigor no ` &`e no ` Box`para que o método ` content`
em última análise, será chamado no tipo que implementa o ` State`trait. Isso significa
precisamos adicionar ` content`à definição ` State`trait, e é aí que
colocaremos a lógica de qual conteúdo retornar dependendo de qual estado
possuem, conforme mostrado na Listagem 18-18.

<Listing number="18-18" file-name="src/lib.rs" caption="Adicionando o método `content` à trait `State`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-18/src/lib.rs:here}}
```

</Listing>

Adicionamos uma implementação padrão para o método `content` que retorna um valor vazio
string slice. Isso significa que não precisamos implementar `content` no `Draft`
e estruturas ` PendingReview`. A estrutura ` Published`substituirá o ` content`
método e retorne o valor em ` post.content`. Embora seja conveniente, ter o
O método ` content`em ` State`determina que o conteúdo do ` Post`está desfocado
as linhas entre a responsabilidade de ` State`e a responsabilidade de
` Post`.

Observe que precisamos de anotações lifetime neste método, conforme discutimos em
Capítulo 10. Estamos tomando uma referência a `post` como argumento e retornando um
referência a parte desse `post`, então o lifetime da referência retornada é
relacionado ao lifetime do argumento ` post`.

E terminamos – toda a Listagem 18-11 agora funciona! Implementamos o estado
padrão com as regras do fluxo de trabalho de postagem do blog. A lógica relacionada ao
as regras residem nos objetos de estado, em vez de serem espalhadas por `Post`.

> ### Why Not An Enum?
>
> Você deve estar se perguntando por que não usamos um enum com os diferentes
> possíveis estados de postagem como variantes. Essa é certamente uma solução possível; experimente
> e compare os resultados finais para ver qual você prefere! Uma desvantagem de usar
> um enum é que todo lugar que verifica o valor do enum precisará de um
> Expressão `match` ou similar para lidar com todas as variantes possíveis. Isso poderia ficar
> mais repetitivo que esta solução de objeto trait.

<!-- Old headings. Do not remove or links may break. -->

<a id="trade-offs-of-the-state-pattern"></a>

#### Avaliando o padrão de estado

Mostramos que Rust é capaz de implementar o estado orientado a objetos
padrão para encapsular os diferentes tipos de comportamento que uma postagem deve ter em
cada estado. Os métodos em `Post` não sabem nada sobre os vários comportamentos.
Devido à forma como organizamos o código, temos que procurar em apenas um lugar para
conhecer as diferentes maneiras como uma postagem publicada pode se comportar: a implementação do
`State ` trait na estrutura`Published`.

Se criássemos uma implementação alternativa que não usasse o estado
padrão, podemos usar expressões `match` nos métodos em `Post` ou
até mesmo no código `main` que verifica o estado da postagem e altera o comportamento
nesses lugares. Isso significaria que teríamos que procurar em vários lugares para
entender todas as implicações de uma postagem estar no estado publicado.

Com o padrão de estado, os métodos `Post` e os locais em que usamos `Post` não
precisamos de expressões `match` e, para adicionar um novo estado, precisaríamos apenas adicionar um
nova estrutura e implemente os métodos trait nessa estrutura em um local.

A implementação usando o padrão de estado é fácil de estender para adicionar mais
funcionalidade. Para ver a simplicidade de manter código que usa o estado
padrão, tente algumas destas sugestões:

- Adicione um método `reject` que altera o estado da postagem de `PendingReview` para trás
  para `Draft`.
- São necessárias duas chamadas para ` approve`antes que o estado possa ser alterado para ` Published`.
- Permitir que os usuários adicionem conteúdo de texto somente quando uma postagem estiver no estado ` Draft`.
  Dica: deixe o objeto de estado responsável pelo que pode mudar no
  conteúdo, mas não é responsável pela modificação do ` Post`.

Uma desvantagem do padrão estatal é que, como os estados implementam o
transições entre estados, alguns dos estados são acoplados entre si. Se nós
adicione outro estado entre `PendingReview` e `Published`, como ` Scheduled`,
teríamos que alterar o código em ` PendingReview`para fazer a transição para
` Scheduled `em vez disso. Seria menos trabalhoso se` PendingReview`não precisasse
mudar com a adição de um novo estado, mas isso significaria mudar para
outro padrão de design.

Outra desvantagem é que duplicamos alguma lógica. Para eliminar alguns dos
duplicação, podemos tentar fazer implementações padrão para o
Métodos `request_review` e `approve` no `State` trait que retornam `self`.
No entanto, isso não funcionaria: ao usar ` State`como objeto trait, o objeto trait
não sabe exatamente qual será o ` self`concreto, então o tipo de retorno não é
conhecido em tempo de compilação. (Esta é uma das regras de compatibilidade dyn mencionadas
anteriormente.)

Outra duplicação inclui implementações semelhantes do `request_review`
e métodos ` approve`em ` Post`. Ambos os métodos usam ` Option::take`com o
campo ` state`de ` Post`, e se ` state`for ` Some`, eles delegam para o empacotado
implementação do valor do mesmo método e definir o novo valor do ` state`
campo para o resultado. Se tivéssemos muitos métodos no ` Post`que seguissem este
padrão, podemos considerar a definição de uma macro para eliminar a repetição (veja
seção [“Macros”][macros]<!-- ignore --> no Capítulo 20).

Implementando o padrão de estado exatamente como é definido para orientação a objetos
idiomas, não estamos aproveitando ao máximo os pontos fortes do Rust quanto poderíamos.
Vejamos algumas alterações que podemos fazer no `blog` crate que podem fazer
estados inválidos e transições para erros em tempo de compilação.

### Codificando Estados e Comportamento como Tipos

Mostraremos como repensar o padrão de estado para obter um conjunto diferente de
compensações. Em vez de encapsular completamente os estados e as transições
que o código externo não tem conhecimento deles, codificaremos os estados em
tipos diferentes. Consequentemente, o sistema de verificação de tipo do Rust impedirá
tenta usar rascunhos de postagens onde apenas postagens publicadas são permitidas, emitindo um
erro do compilador.

Vamos considerar a primeira parte de `main` na Listagem 18-11:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch18-oop/listing-18-11/src/main.rs:here}}
```

</Listing>

Ainda habilitamos a criação de novas postagens no estado de rascunho usando `Post::new`
e a capacidade de adicionar texto ao conteúdo da postagem. Mas em vez de ter um
Método ` content`em uma postagem de rascunho que retorna uma string vazia, faremos assim
que os rascunhos de postagens não possuem o método ` content`. Dessa forma, se tentarmos
obter o conteúdo de um rascunho da postagem, receberemos um erro do compilador informando o método
não existe. Como resultado, será impossível para nós acidentalmente
exibir o conteúdo do rascunho da postagem em produção porque esse código nem mesmo será compilado.
A Listagem 18-19 mostra a definição de uma estrutura ` Post`e uma estrutura ` DraftPost`,
bem como métodos em cada um.

<Listing number="18-19" file-name="src/lib.rs" caption="Um `Post` com método `content` e um `DraftPost` sem método `content`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-19/src/lib.rs}}
```

</Listing>

Ambas as estruturas `Post` e `DraftPost` possuem um campo `content` privado que
armazena o texto da postagem do blog. As estruturas não possuem mais o campo `state` porque
estamos movendo a codificação do estado para os tipos das estruturas. O `Post`
struct representará uma postagem publicada e possui um método ` content`que
retorna o ` content`.

Ainda temos uma função `Post::new`, mas em vez de retornar uma instância de
` Post `, retorna uma instância de` DraftPost `. Como` content `é privado e
não há funções que retornem` Post `, não é possível criar um
instância de` Post`agora.

A estrutura `DraftPost` possui um método `add_text`, então podemos adicionar texto a
` content `como antes, mas observe que` DraftPost `não possui um método` content`
definido! Portanto, agora o programa garante que todas as postagens comecem como rascunhos e
rascunhos de postagens não têm seu conteúdo disponível para exibição. Qualquer tentativa de obter
contornar essas restrições resultará em um erro do compilador.

<!-- Old headings. Do not remove or links may break. -->

<a id="implementing-transitions-as-transformations-into-different-types"></a>

Então, como conseguimos uma postagem publicada? Queremos fazer cumprir a regra de que um projecto
a postagem deve ser revisada e aprovada antes de ser publicada. Uma postagem no
o estado de revisão pendente ainda não deve exibir nenhum conteúdo. Vamos implementar
essas restrições adicionando outra estrutura, `PendingReviewPost`, definindo o
Método ` request_review`em ` DraftPost`para retornar um ` PendingReviewPost`e
definindo um método ` approve`em ` PendingReviewPost`para retornar um ` Post`, como
mostrado na Listagem 18-20.

<Listing number="18-20" file-name="src/lib.rs" caption="Um `PendingReviewPost` criado ao chamar `request_review` em `DraftPost` e um método `approve` que transforma `PendingReviewPost` em um `Post` publicado">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-20/src/lib.rs:here}}
```

</Listing>

Os métodos `request_review` e `approve` levam ownership de `self`, portanto
consumindo as instâncias ` DraftPost`e ` PendingReviewPost`e transformando
em um ` PendingReviewPost`e um ` Post`publicado, respectivamente. Desta forma,
não teremos nenhuma instância ` DraftPost`remanescente depois de ligarmos
` request_review `neles e assim por diante. A estrutura` PendingReviewPost `não
tem um método` content `definido nele, então tentar ler seu conteúdo
resulta em um erro do compilador, como acontece com` DraftPost `. Porque a única maneira de conseguir um
instância` Post `publicada que possui um método` content `definido é chamar
o método` approve `em um` PendingReviewPost `, e a única maneira de obter um
` PendingReviewPost `é para chamar o método` request_review `em um` DraftPost`,
agora codificamos o fluxo de trabalho da postagem do blog no sistema de tipos.

Mas também temos que fazer algumas pequenas alterações no `main`. O ` request_review`e
Os métodos ` approve`retornam novas instâncias em vez de modificar a estrutura que estão
solicitado, então precisamos adicionar mais atribuições de sombreamento ` let post =`para salvar
as instâncias retornadas. Também não podemos ter afirmações sobre o projecto e
o conteúdo das postagens de revisão pendentes são strings vazias, nem precisamos delas: não podemos
compilar o código que tenta mais usar o conteúdo das postagens nesses estados.
O código atualizado em ` main`é mostrado na Listagem 18-21.

<Listing number="18-21" file-name="src/main.rs" caption="Modificações em `main` para usar a nova implementação do fluxo de trabalho de posts do blog">

```rust,ignore
{{#rustdoc_include ../listings/ch18-oop/listing-18-21/src/main.rs}}
```

</Listing>

As mudanças que tivemos de fazer em `main` para reatribuir `post` significam
que essa implementação já não segue exatamente o padrão de estado orientado a
objetos: as transformações entre os estados já não ficam totalmente
encapsuladas dentro da implementação de `Post`. No entanto, o ganho é que
estados inválidos agora se tornam impossíveis por causa do sistema de tipos e
da checagem de tipos que acontece em tempo de compilação! Isso garante que
certos bugs, como exibir o conteúdo de um post não publicado, sejam
descobertos antes de chegarem à produção.

Experimente as tarefas sugeridas no início desta seção no crate `blog` como ele
está após a Listagem 18-21 para ver o que você acha do design desta versão do
código. Observe que algumas das tarefas talvez já estejam concluídas neste
projeto.

Vimos que, embora Rust seja capaz de implementar padrões de projeto orientados
a objetos, outros padrões, como codificar estado no sistema de tipos, também
estão disponíveis em Rust. Esses padrões têm trade-offs diferentes. Embora você
possa estar bastante familiarizado com padrões orientados a objetos, repensar o
problema para aproveitar os recursos de Rust pode trazer benefícios, como
evitar alguns bugs em tempo de compilação. Padrões orientados a objetos nem
sempre serão
the best solution in Rust due to certain features, like ownership, that
linguagens orientadas a objetos não possuem.

## Resumo

Independentemente de você achar que Rust é uma linguagem orientada a objetos depois
lendo este capítulo, agora você sabe que pode usar objetos trait para obter alguns
recursos orientados a objetos em Rust. O despacho dinâmico pode dar ao seu código alguma
flexibilidade em troca de um pouco de desempenho em tempo de execução. Você pode usar isso
flexibilidade para implementar padrões orientados a objetos que podem ajudar seu código
manutenibilidade. Rust também possui outros recursos, como ownership, que
linguagens orientadas a objetos não possuem. Um padrão orientado a objetos nem sempre
ser a melhor maneira de aproveitar os pontos fortes do Rust, mas é uma opção disponível
opção.

A seguir, veremos os padrões, que são outro recurso do Rust que permite
muita flexibilidade. Nós os examinamos brevemente ao longo do livro, mas
ainda não vimos sua capacidade total. Vamos!

[more-info-than-rustc]: ch09-03-to-panic-or-not-to-panic.html#cases-in-which-you-have-more-information-than-the-compiler
[macros]: ch20-05-macros.html#macros

## Implementando um Padrão de Projeto Orientado a Objetos

O _state pattern_ é um padrão de projeto orientado a objetos. A ideia central
do padrão é definir um conjunto de estados que um valor pode ter internamente.
Os estados são representados por um conjunto de _objetos de estado_, e o
comportamento do valor muda com base em seu estado. Vamos trabalhar em um
exemplo de uma struct de post de blog que tem um campo para guardar seu estado,
que será um objeto de estado do conjunto “rascunho”, “em revisão” ou
“publicado”.

Os objetos de estado compartilham funcionalidade: em Rust, é claro, usamos
structs e traits em vez de objetos e herança. Cada objeto de estado é
responsável por seu próprio comportamento e por governar quando deve mudar para
outro estado. O valor que guarda um objeto de estado não sabe nada sobre os
diferentes comportamentos dos estados nem sobre quando fazer transições entre
estados.

A vantagem de usar o state pattern é que, quando os requisitos de negócio do
programa mudarem, não precisaremos alterar o código do valor que guarda o
estado nem o código que usa esse valor. Precisaremos apenas atualizar o código
dentro de um dos objetos de estado para alterar suas regras ou talvez adicionar
mais objetos de estado.

Primeiro, implementaremos o state pattern de uma forma mais tradicionalmente
orientada a objetos. Depois, usaremos uma abordagem um pouco mais natural em
Rust. Vamos começar implementando incrementalmente um fluxo de trabalho de post
de blog usando o state pattern.

A funcionalidade final será assim:

1. Um post de blog começa como um rascunho vazio.
1. Quando o rascunho está pronto, uma revisão do post é solicitada.
1. Quando o post é aprovado, ele é publicado.
1. Apenas posts de blog publicados retornam conteúdo para impressão, para que
   posts não aprovados não possam ser publicados acidentalmente.

Qualquer outra mudança tentada em um post não deve ter efeito. Por exemplo, se
tentarmos aprovar um rascunho de post antes de solicitar uma revisão, o post
deve continuar sendo um rascunho não publicado.

<!-- Old headings. Do not remove or links may break. -->

<a id="a-traditional-object-oriented-attempt"></a>

### Tentando o Estilo Orientado a Objetos Tradicional

Há infinitas maneiras de estruturar código para resolver o mesmo problema, cada
uma com trade-offs diferentes. A implementação desta seção segue mais um estilo
tradicionalmente orientado a objetos, que é possível escrever em Rust, mas não
aproveita alguns dos pontos fortes de Rust. Mais adiante, demonstraremos uma
solução diferente que ainda usa o padrão de projeto orientado a objetos, mas é
estruturada de uma forma que pode parecer menos familiar para programadores com
experiência em orientação a objetos. Compararemos as duas soluções para
experimentar os trade-offs de projetar código Rust de forma diferente do código
em outras linguagens.

A Listagem 18-11 mostra esse fluxo de trabalho em forma de código: este é um
exemplo de uso da API que implementaremos em um crate de biblioteca chamado
`blog`. Este código ainda não compila porque não implementamos o crate `blog`.

<Listing number="18-11" file-name="src/main.rs" caption="Código que demonstra o comportamento desejado para nosso crate `blog`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch18-oop/listing-18-11/src/main.rs:all}}
```

</Listing>

Queremos permitir que o usuário crie um novo rascunho de post de blog com
`Post::new`. Queremos permitir que texto seja adicionado ao post. Se tentarmos
obter o conteúdo do post imediatamente, antes da aprovação, não devemos obter
texto algum, porque o post ainda é um rascunho. Adicionamos `assert_eq!` ao
código para fins de demonstração. Um excelente teste unitário para isso seria
afirmar que um rascunho de post de blog retorna uma string vazia do método
`content`, mas não escreveremos testes para este exemplo.

Em seguida, queremos permitir uma solicitação de revisão do post e queremos que
`content` retorne uma string vazia enquanto aguarda a revisão. Quando o post
receber aprovação, ele deve ser publicado, o que significa que o texto do post
será retornado quando `content` for chamado.

Observe que o único tipo com o qual interagimos a partir do crate é o tipo
`Post`. Esse tipo usará o state pattern e guardará um valor que será um dos
três objetos de estado que representam os vários estados em que um post pode
estar: rascunho, em revisão ou publicado. A mudança de um estado para outro
será gerenciada internamente dentro do tipo `Post`. Os estados mudam em
resposta aos métodos chamados pelos usuários da nossa biblioteca na instância
de `Post`, mas eles não precisam gerenciar as mudanças de estado diretamente.
Além disso, usuários não podem cometer erros com os estados, como publicar um
post antes de ele ser revisado.

<!-- Old headings. Do not remove or links may break. -->

<a id="defining-post-and-creating-a-new-instance-in-the-draft-state"></a>

#### Definindo `Post` e Criando uma Nova Instância

Vamos começar a implementação da biblioteca! Sabemos que precisamos de uma
struct pública `Post` que guarda algum conteúdo, então começaremos com a
definição da struct e uma função associada pública `new` para criar uma
instância de `Post`, como mostrado na Listagem 18-12. Também criaremos uma
trait privada `State`, que definirá o comportamento que todos os objetos de
estado de um `Post` devem ter.

Então, `Post` guardará um objeto trait `Box<dyn State>` dentro de um
`Option<T>` em um campo privado chamado `state`, para armazenar o objeto de
estado. Você verá em breve por que o `Option<T>` é necessário.

<Listing number="18-12" file-name="src/lib.rs" caption="Definição de uma struct `Post`, de uma função `new` que cria uma nova instância de `Post`, de uma trait `State` e de uma struct `Draft`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-12/src/lib.rs}}
```

</Listing>

A trait `State` define o comportamento compartilhado pelos diferentes estados
de um post. Os objetos de estado são `Draft`, `PendingReview` e `Published`, e
todos eles implementarão a trait `State`. Por enquanto, a trait não tem nenhum
método, e começaremos definindo apenas o estado `Draft`, porque esse é o estado
em que queremos que um post comece.

Quando criamos um novo `Post`, definimos seu campo `state` como um valor
`Some` que contém um `Box`. Esse `Box` aponta para uma nova instância da struct
`Draft`. Isso garante que, sempre que criarmos uma nova instância de `Post`,
ela começará como rascunho. Como o campo `state` de `Post` é privado, não há
como criar um `Post` em qualquer outro estado! Na função `Post::new`, definimos
o campo `content` como uma nova `String` vazia.

#### Armazenando o Texto do Conteúdo do Post

Vimos na Listagem 18-11 que queremos poder chamar um método chamado `add_text`
e passar a ele um `&str` que será adicionado como o conteúdo textual do post de
blog. Implementamos isso como um método, em vez de expor o campo `content` como
`pub`, para que mais tarde possamos implementar um método que controlará como
os dados do campo `content` são lidos. O método `add_text` é bem simples, então
vamos adicionar a implementação da Listagem 18-13 ao bloco `impl Post`.

<Listing number="18-13" file-name="src/lib.rs" caption="Implementando o método `add_text` para adicionar texto ao `content` de um post">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-13/src/lib.rs:here}}
```

</Listing>

O método `add_text` recebe uma referência mutável a `self` porque estamos
alterando a instância de `Post` na qual chamamos `add_text`. Então chamamos
`push_str` na `String` em `content` e passamos o argumento `text` para adicionar
ao `content` salvo. Esse comportamento não depende do estado em que o post está,
então não faz parte do state pattern. O método `add_text` não interage com o
campo `state` de forma alguma, mas faz parte do comportamento que queremos
oferecer.

<!-- Old headings. Do not remove or links may break. -->

<a id="ensuring-the-content-of-a-draft-post-is-empty"></a>

#### Garantindo Que o Conteúdo de um Rascunho Esteja Vazio

Mesmo depois de chamarmos `add_text` e adicionarmos algum conteúdo ao nosso
post, ainda queremos que o método `content` retorne um string slice vazio,
porque o post ainda está no estado de rascunho, como mostrado pelo primeiro
`assert_eq!` na Listagem 18-11. Por enquanto, vamos implementar o método
`content` com a coisa mais simples que satisfaz esse requisito: sempre retornar
um string slice vazio. Alteraremos isso mais tarde, depois que implementarmos a
capacidade de mudar o estado de um post para que ele possa ser publicado. Até
agora, posts só podem estar no estado de rascunho, então o conteúdo do post
deve estar sempre vazio. A Listagem 18-14 mostra essa implementação provisória.

<Listing number="18-14" file-name="src/lib.rs" caption="Adicionando uma implementação provisória para o método `content` em `Post` que sempre retorna um string slice vazio">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-14/src/lib.rs:here}}
```

</Listing>

Com esse método `content` adicionado, tudo na Listagem 18-11 até o primeiro
`assert_eq!` funciona como pretendido.

<!-- Old headings. Do not remove or links may break. -->

<a id="requesting-a-review-of-the-post-changes-its-state"></a>
<a id="requesting-a-review-changes-the-posts-state"></a>

#### Solicitando uma Revisão, o Que Muda o Estado do Post

Em seguida, precisamos adicionar a funcionalidade para solicitar uma revisão de
um post, o que deve alterar seu estado de `Draft` para `PendingReview`. A
Listagem 18-15 mostra esse código.

<Listing number="18-15" file-name="src/lib.rs" caption="Implementando métodos `request_review` em `Post` e na trait `State`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-15/src/lib.rs:here}}
```

</Listing>

Damos a `Post` um método público chamado `request_review`, que receberá uma
referência mutável a `self`. Então chamamos um método `request_review` interno
no estado atual de `Post`, e esse segundo método `request_review` consome o
estado atual e retorna um novo estado.

Adicionamos o método `request_review` à trait `State`; todos os tipos que
implementam a trait agora precisarão implementar o método `request_review`.
Observe que, em vez de ter `self`, `&self` ou `&mut self` como o primeiro
parâmetro do método, temos `self: Box<Self>`. Essa sintaxe significa que o
método só é válido quando chamado em um `Box` que contém o tipo. Essa sintaxe
toma ownership de `Box<Self>`, invalidando o estado antigo para que o valor de
estado de `Post` possa se transformar em um novo estado.

Para consumir o estado antigo, o método `request_review` precisa tomar
ownership do valor de estado. É aqui que entra o `Option` no campo `state` de
`Post`: chamamos o método `take` para retirar o valor `Some` do campo `state` e
deixar um `None` em seu lugar, porque Rust não permite que tenhamos campos não
preenchidos em structs. Isso nos permite mover o valor de `state` para fora de
`Post`, em vez de apenas pegá-lo emprestado. Então definiremos o valor de
`state` do post como o resultado dessa operação.

Precisamos definir `state` temporariamente como `None`, em vez de defini-lo
diretamente com código como `self.state = self.state.request_review();`, para
obter ownership do valor de `state`. Isso garante que `Post` não possa usar o
valor antigo de `state` depois de o termos transformado em um novo estado.

O método `request_review` em `Draft` retorna uma nova instância encaixotada de
uma nova struct `PendingReview`, que representa o estado em que um post está
aguardando revisão. A struct `PendingReview` também implementa o método
`request_review`, mas não faz nenhuma transformação. Em vez disso, retorna a si
mesma, porque, quando solicitamos revisão em um post que já está no estado
`PendingReview`, ele deve permanecer no estado `PendingReview`.

Agora começamos a ver as vantagens do state pattern: o método `request_review`
em `Post` é o mesmo independentemente do valor de `state`. Cada estado é
responsável por suas próprias regras.

Deixaremos o método `content` em `Post` como está, retornando um string slice
vazio. Agora podemos ter um `Post` no estado `PendingReview`, bem como no
estado `Draft`, mas queremos o mesmo comportamento no estado `PendingReview`.
A Listagem 18-11 agora funciona até a segunda chamada a `assert_eq!`!

<!-- Old headings. Do not remove or links may break. -->

<a id="adding-the-approve-method-that-changes-the-behavior-of-content"></a>
<a id="adding-approve-to-change-the-behavior-of-content"></a>

#### Adicionando `approve` Para Alterar o Comportamento de `content`

O método `approve` será semelhante ao método `request_review`: ele definirá
`state` como o valor que o estado atual diz que deve ter quando esse estado é
aprovado, como mostrado na Listagem 18-16.

<Listing number="18-16" file-name="src/lib.rs" caption="Implementando o método `approve` em `Post` e na trait `State`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-16/src/lib.rs:here}}
```

</Listing>

Adicionamos o método `approve` à trait `State` e adicionamos uma nova struct
que implementa `State`, o estado `Published`.

De forma semelhante ao funcionamento de `request_review` em `PendingReview`,
se chamarmos o método `approve` em um `Draft`, ele não terá efeito, porque
`approve` retornará `self`. Quando chamamos `approve` em `PendingReview`, ele
retorna uma nova instância encaixotada da struct `Published`. A struct
`Published` implementa a trait `State` e, tanto para o método `request_review`
quanto para o método `approve`, ela retorna a si mesma, porque o post deve
permanecer no estado `Published` nesses casos.

Agora precisamos atualizar o método `content` em `Post`. Queremos que o valor
retornado por `content` dependa do estado atual de `Post`, então faremos `Post`
delegar a um método `content` definido em seu `state`, como mostrado na
Listagem 18-17.

<Listing number="18-17" file-name="src/lib.rs" caption="Atualizando o método `content` em `Post` para delegar a um método `content` em `State`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch18-oop/listing-18-17/src/lib.rs:here}}
```

</Listing>

Como o objetivo é manter todas essas regras dentro das structs que implementam
`State`, chamamos um método `content` no valor em `state` e passamos a
instância do post (isto é, `self`) como argumento. Então retornamos o valor
retornado pelo uso do método `content` no valor de `state`.

Chamamos o método `as_ref` no `Option` porque queremos uma referência ao valor
dentro do `Option`, em vez de ownership do valor. Como `state` é um
`Option<Box<dyn State>>`, quando chamamos `as_ref`, um `Option<&Box<dyn State>>`
é retornado. Se não chamássemos `as_ref`, obteríamos um erro porque não podemos
mover `state` para fora do `&self` emprestado do parâmetro da função.

Então chamamos o método `unwrap`, que sabemos que nunca entrará em pânico
porque sabemos que os métodos em `Post` garantem que `state` sempre conterá um
valor `Some` quando esses métodos terminarem. Este é um dos casos sobre os
quais falamos na seção [“Quando Você Tem Mais Informações que o
Compilador”][more-info-than-rustc]<!-- ignore --> do Capítulo 9, em que
sabemos que um valor `None` nunca é possível, mesmo que o compilador não seja
capaz de entender isso.

Neste ponto, quando chamamos `content` em `&Box<dyn State>`, a coerção deref
entrará em vigor em `&` e em `Box`, de modo que o método `content` será chamado
no fim das contas no tipo que implementa a trait `State`. Isso significa que
precisamos adicionar `content` à definição da trait `State`, e é aí que
colocaremos a lógica sobre qual conteúdo retornar dependendo do estado que
temos, como mostrado na Listagem 18-18.

<Listing number="18-18" file-name="src/lib.rs" caption="Adicionando o método `content` à trait `State`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-18/src/lib.rs:here}}
```

</Listing>

Adicionamos uma implementação padrão para o método `content` que retorna um
string slice vazio. Isso significa que não precisamos implementar `content` nas
structs `Draft` e `PendingReview`. A struct `Published` sobrescreverá o método
`content` e retornará o valor em `post.content`. Embora seja conveniente, fazer
o método `content` em `State` determinar o conteúdo de `Post` borra a fronteira
entre a responsabilidade de `State` e a responsabilidade de `Post`.

Observe que precisamos de anotações de lifetime neste método, como discutimos
no Capítulo 10. Estamos recebendo uma referência a um `post` como argumento e
retornando uma referência a parte desse `post`, então o lifetime da referência
retornada está relacionado ao lifetime do argumento `post`.

E terminamos: toda a Listagem 18-11 agora funciona! Implementamos o state
pattern com as regras do fluxo de trabalho de posts de blog. A lógica
relacionada às regras reside nos objetos de estado, em vez de ficar espalhada
por `Post`.

> ### Por Que Não Um Enum?
>
> Talvez você tenha se perguntado por que não usamos um enum com os diferentes
> estados possíveis de um post como variantes. Essa certamente é uma solução
> possível; experimente e compare os resultados finais para ver qual você
> prefere! Uma desvantagem de usar um enum é que todo lugar que verifica o
> valor do enum precisará de uma expressão `match` ou algo semelhante para
> tratar todas as variantes possíveis. Isso poderia se tornar mais repetitivo
> do que esta solução com objetos trait.

<!-- Old headings. Do not remove or links may break. -->

<a id="trade-offs-of-the-state-pattern"></a>

#### Avaliando o State Pattern

Mostramos que Rust é capaz de implementar o state pattern orientado a objetos
para encapsular os diferentes tipos de comportamento que um post deve ter em
cada estado. Os métodos em `Post` não sabem nada sobre os vários
comportamentos. Pela forma como organizamos o código, precisamos olhar em
apenas um lugar para saber as diferentes maneiras como um post publicado pode
se comportar: a implementação da trait `State` na struct `Published`.

Se criássemos uma implementação alternativa que não usasse o state pattern,
poderíamos usar expressões `match` nos métodos de `Post` ou até mesmo no código
de `main`, que verificaria o estado do post e alteraria o comportamento nesses
lugares. Isso significaria que precisaríamos olhar em vários lugares para
entender todas as implicações de um post estar no estado publicado.

Com o state pattern, os métodos de `Post` e os lugares em que usamos `Post` não
precisam de expressões `match`; para adicionar um novo estado, precisaríamos
apenas adicionar uma nova struct e implementar os métodos da trait nessa struct
em um único lugar.

A implementação que usa o state pattern é fácil de estender para adicionar mais
funcionalidade. Para ver como é simples manter código que usa o state pattern,
experimente algumas destas sugestões:

- Adicione um método `reject` que altera o estado do post de `PendingReview`
  de volta para `Draft`.
- Exija duas chamadas a `approve` antes que o estado possa ser alterado para
  `Published`.
- Permita que usuários adicionem conteúdo textual apenas quando um post estiver
  no estado `Draft`. Dica: faça o objeto de estado ser responsável pelo que
  pode mudar em relação ao conteúdo, mas não responsável por modificar o
  `Post`.

Uma desvantagem do state pattern é que, como os estados implementam as
transições entre estados, alguns estados ficam acoplados uns aos outros. Se
adicionarmos outro estado entre `PendingReview` e `Published`, como
`Scheduled`, teremos que alterar o código em `PendingReview` para fazer a
transição para `Scheduled` em vez disso. Daria menos trabalho se
`PendingReview` não precisasse mudar com a adição de um novo estado, mas isso
significaria trocar para outro padrão de projeto.

Outra desvantagem é que duplicamos alguma lógica. Para eliminar parte da
duplicação, poderíamos tentar criar implementações padrão para os métodos
`request_review` e `approve` na trait `State` que retornassem `self`. No
entanto, isso não funcionaria: ao usar `State` como objeto trait, a trait não
sabe exatamente qual será o `self` concreto, então o tipo de retorno não é
conhecido em tempo de compilação. (Essa é uma das regras de compatibilidade dyn
mencionadas anteriormente.)

Outra duplicação aparece nas implementações semelhantes dos métodos
`request_review` e `approve` em `Post`. Ambos os métodos usam `Option::take`
com o campo `state` de `Post` e, se `state` for `Some`, delegam para a
implementação do mesmo método no valor encapsulado e definem o novo valor do
campo `state` como o resultado. Se tivéssemos muitos métodos em `Post` que
seguissem esse padrão, poderíamos considerar definir uma macro para eliminar a
repetição (veja a seção [“Macros”][macros]<!-- ignore --> do Capítulo 20).

Ao implementar o state pattern exatamente como ele é definido para linguagens
orientadas a objetos, não estamos aproveitando os pontos fortes de Rust tanto
quanto poderíamos. Vamos ver algumas mudanças que podemos fazer no crate `blog`
para transformar estados e transições inválidos em erros de tempo de
compilação.

### Codificando Estados e Comportamento Como Tipos

Mostraremos como repensar o state pattern para obter um conjunto diferente de
trade-offs. Em vez de encapsular completamente os estados e as transições de
modo que o código externo não saiba nada sobre eles, codificaremos os estados
em tipos diferentes. Consequentemente, o sistema de verificação de tipos de
Rust impedirá tentativas de usar posts em rascunho onde apenas posts publicados
são permitidos, emitindo um erro do compilador.

Vamos considerar a primeira parte de `main` na Listagem 18-11:

<Listing file-name="src/main.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch18-oop/listing-18-11/src/main.rs:here}}
```

</Listing>

Ainda permitimos criar novos posts no estado de rascunho usando `Post::new` e
adicionar texto ao conteúdo do post. Mas, em vez de ter um método `content` em
um rascunho de post que retorna uma string vazia, faremos com que rascunhos de
posts não tenham o método `content` de forma alguma. Assim, se tentarmos obter
o conteúdo de um rascunho de post, receberemos um erro do compilador dizendo
que o método não existe. Como resultado, será impossível exibir acidentalmente
conteúdo de rascunhos em produção, porque esse código nem sequer compilará. A
Listagem 18-19 mostra a definição de uma struct `Post` e de uma struct
`DraftPost`, bem como métodos em cada uma.

<Listing number="18-19" file-name="src/lib.rs" caption="Um `Post` com método `content` e um `DraftPost` sem método `content`">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-19/src/lib.rs}}
```

</Listing>

Tanto a struct `Post` quanto a struct `DraftPost` têm um campo privado
`content` que armazena o texto do post de blog. As structs não têm mais o campo
`state` porque estamos movendo a codificação do estado para os tipos das
structs. A struct `Post` representará um post publicado e tem um método
`content` que retorna o `content`.

Ainda temos uma função `Post::new`, mas, em vez de retornar uma instância de
`Post`, ela retorna uma instância de `DraftPost`. Como `content` é privado e
não há funções que retornem `Post`, não é possível criar uma instância de
`Post` neste momento.

A struct `DraftPost` tem um método `add_text`, então podemos adicionar texto a
`content` como antes, mas observe que `DraftPost` não tem um método `content`
definido! Agora o programa garante que todos os posts começam como rascunhos, e
rascunhos não têm seu conteúdo disponível para exibição. Qualquer tentativa de
contornar essas restrições resultará em um erro do compilador.

<!-- Old headings. Do not remove or links may break. -->

<a id="implementing-transitions-as-transformations-into-different-types"></a>

Então, como obtemos um post publicado? Queremos impor a regra de que um
rascunho de post precisa ser revisado e aprovado antes de poder ser publicado.
Um post no estado pendente de revisão ainda não deve exibir conteúdo. Vamos
implementar essas restrições adicionando outra struct, `PendingReviewPost`,
definindo o método `request_review` em `DraftPost` para retornar um
`PendingReviewPost` e definindo um método `approve` em `PendingReviewPost` para
retornar um `Post`, como mostrado na Listagem 18-20.

<Listing number="18-20" file-name="src/lib.rs" caption="Um `PendingReviewPost` criado ao chamar `request_review` em `DraftPost` e um método `approve` que transforma `PendingReviewPost` em um `Post` publicado">

```rust,noplayground
{{#rustdoc_include ../listings/ch18-oop/listing-18-20/src/lib.rs:here}}
```

</Listing>

Os métodos `request_review` e `approve` tomam ownership de `self`, consumindo
as instâncias de `DraftPost` e `PendingReviewPost` e transformando-as em um
`PendingReviewPost` e um `Post` publicado, respectivamente. Dessa forma, não
teremos nenhuma instância de `DraftPost` restante depois de chamarmos
`request_review` nela, e assim por diante. A struct `PendingReviewPost` não tem
um método `content` definido nela, então tentar ler seu conteúdo resulta em um
erro do compilador, como acontece com `DraftPost`. Como a única forma de obter
uma instância publicada de `Post` que tenha um método `content` definido é
chamar o método `approve` em um `PendingReviewPost`, e a única forma de obter
um `PendingReviewPost` é chamar o método `request_review` em um `DraftPost`,
agora codificamos o fluxo de trabalho de posts de blog no sistema de tipos.

Mas também precisamos fazer algumas pequenas alterações em `main`. Os métodos
`request_review` e `approve` retornam novas instâncias em vez de modificar a
struct na qual são chamados, então precisamos adicionar mais atribuições de
sombreamento `let post =` para salvar as instâncias retornadas. Também não
podemos ter as asserções de que o conteúdo dos posts em rascunho e pendentes de
revisão é uma string vazia, nem precisamos delas: não podemos mais compilar
código que tenta usar o conteúdo de posts nesses estados. O código atualizado
em `main` é mostrado na Listagem 18-21.

<Listing number="18-21" file-name="src/main.rs" caption="Modificações em `main` para usar a nova implementação do fluxo de trabalho de posts de blog">

```rust,ignore
{{#rustdoc_include ../listings/ch18-oop/listing-18-21/src/main.rs}}
```

</Listing>

As mudanças que tivemos que fazer em `main` para reatribuir `post` significam
que essa implementação já não segue exatamente o state pattern orientado a
objetos: as transformações entre os estados não estão mais totalmente
encapsuladas dentro da implementação de `Post`. No entanto, nosso ganho é que
estados inválidos agora são impossíveis por causa do sistema de tipos e da
verificação de tipos que acontece em tempo de compilação! Isso garante que
certos bugs, como exibir o conteúdo de um post não publicado, sejam descobertos
antes de chegarem à produção.

Experimente as tarefas sugeridas no começo desta seção no crate `blog` como ele
fica depois da Listagem 18-21 para ver o que você acha do design desta versão
do código. Observe que algumas das tarefas talvez já estejam resolvidas neste
design.

Vimos que, embora Rust seja capaz de implementar padrões de projeto orientados
a objetos, outros padrões, como codificar estado no sistema de tipos, também
estão disponíveis em Rust. Esses padrões têm trade-offs diferentes. Embora você
possa estar muito familiarizado com padrões orientados a objetos, repensar o
problema para aproveitar os recursos de Rust pode trazer benefícios, como
evitar alguns bugs em tempo de compilação. Padrões orientados a objetos nem
sempre serão a melhor solução em Rust por causa de certos recursos, como
ownership, que linguagens orientadas a objetos não têm.

## Resumo

Independentemente de você achar que Rust é uma linguagem orientada a objetos
depois de ler este capítulo, agora você sabe que pode usar objetos trait para
obter alguns recursos orientados a objetos em Rust. Despacho dinâmico pode dar
ao seu código alguma flexibilidade em troca de um pouco de desempenho em tempo
de execução. Você pode usar essa flexibilidade para implementar padrões
orientados a objetos que podem ajudar na manutenibilidade do seu código. Rust
também tem outros recursos, como ownership, que linguagens orientadas a objetos
não têm. Um padrão orientado a objetos nem sempre será a melhor forma de
aproveitar os pontos fortes de Rust, mas é uma opção disponível.

A seguir, veremos patterns, outro recurso de Rust que permite muita
flexibilidade. Nós os vimos brevemente ao longo do livro, mas ainda não vimos
toda a sua capacidade. Vamos lá!

[more-info-than-rustc]: ch09-03-to-panic-or-not-to-panic.html#cases-in-which-you-have-more-information-than-the-compiler
[macros]: ch20-05-macros.html#macros

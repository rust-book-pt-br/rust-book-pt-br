## Usando `Box<T>` para Apontar para Dados no Heap

O ponteiro inteligente mais direto é um _box_, cujo tipo é escrito como
`Box<T>`. _Boxes_ permitem armazenar dados no heap em vez de na pilha. O que
permanece na pilha é o ponteiro para os dados no heap. Consulte o Capítulo 4
para rever a diferença entre pilha e heap.

Boxes não têm custo adicional de desempenho, além de armazenar seus dados no
heap em vez de na pilha. Mas eles também não têm muitas capacidades extras.
Você os usará com mais frequência nestas situações:

- Quando você tem um tipo cujo tamanho não pode ser conhecido em tempo de
  compilação e quer usar um valor desse tipo em um contexto que exige um tamanho
  exato
- Quando você tem uma grande quantidade de dados e quer transferir ownership,
  mas garantir que os dados não sejam copiados ao fazer isso
- Quando você quer ter ownership de um valor e só se importa que ele seja de um
  tipo que implementa uma trait específica, em vez de ser de um tipo concreto
  específico

Vamos demonstrar a primeira situação em [“Possibilitando Tipos Recursivos com
Boxes”](#enabling-recursive-types-with-boxes)<!-- ignore -->. No segundo caso,
transferir ownership de uma grande quantidade de dados pode levar muito tempo,
porque os dados são copiados pela pilha. Para melhorar o desempenho nessa
situação, podemos armazenar a grande quantidade de dados no heap em um box.
Então, apenas a pequena quantidade de dados do ponteiro é copiada pela pilha,
enquanto os dados aos quais ele se refere permanecem em um único lugar no heap.
O terceiro caso é conhecido como _objeto de trait_ (_trait object_), e a seção
[“Usando Objetos de Trait para Abstrair Comportamento Compartilhado”][trait-objects]<!-- ignore -->
no Capítulo 18 é dedicada a esse tópico. Portanto, o que você aprender aqui
será aplicado novamente naquela seção!

<!-- Old headings. Do not remove or links may break. -->

<a id="using-boxt-to-store-data-on-the-heap"></a>

### Armazenando Dados no Heap

Antes de discutirmos o caso de uso de armazenamento no heap para `Box<T>`,
vamos cobrir a sintaxe e como interagir com valores armazenados dentro de um
`Box<T>`.

A Listagem 15-1 mostra como usar um box para armazenar um valor `i32` no heap.

<Listing number="15-1" file-name="src/main.rs" caption="Armazenando um valor `i32` no heap usando um box">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-01/src/main.rs}}
```

</Listing>

Definimos a variável `b` com o valor de um `Box` que aponta para o valor `5`,
que está alocado no heap. Esse programa imprimirá `b = 5`; nesse caso, podemos
acessar os dados no box de forma semelhante a como faríamos se esses dados
estivessem na pilha. Assim como qualquer valor com ownership, quando um box sai
de escopo, como `b` faz no final de `main`, ele é desalocado. A desalocação
acontece tanto para o box (armazenado na pilha) quanto para os dados para os
quais ele aponta (armazenados no heap).

Colocar um único valor no heap não é muito útil, então você não usará boxes
sozinhos dessa forma com muita frequência. Ter valores como um único `i32` na
pilha, onde são armazenados por padrão, é mais apropriado na maioria das
situações. Vamos olhar para um caso em que boxes nos permitem definir tipos que
não poderíamos definir sem eles.

### Possibilitando Tipos Recursivos com Boxes

Um valor de um _tipo recursivo_ pode ter outro valor do mesmo tipo como parte
de si mesmo. Tipos recursivos apresentam um problema porque Rust precisa saber,
em tempo de compilação, quanto espaço um tipo ocupa. No entanto, o aninhamento
de valores de tipos recursivos poderia, em teoria, continuar infinitamente, de
modo que Rust não consegue saber quanto espaço o valor precisa. Como boxes têm
um tamanho conhecido, podemos possibilitar tipos recursivos inserindo um box na
definição do tipo recursivo.

Como exemplo de tipo recursivo, vamos explorar a cons list. Esse é um tipo de
dado comum em linguagens de programação funcional. O tipo cons list que
definiremos é simples, exceto pela recursão; portanto, os conceitos no exemplo
com que trabalharemos serão úteis sempre que você entrar em situações mais
complexas envolvendo tipos recursivos.

<!-- Old headings. Do not remove or links may break. -->

<a id="more-information-about-the-cons-list"></a>

#### Entendendo a Cons List

Uma _cons list_ é uma estrutura de dados que vem da linguagem de programação
Lisp e seus dialetos, é composta por pares aninhados e é a versão de Lisp de
uma lista ligada. Seu nome vem da função `cons` (abreviação de _construct
function_) em Lisp, que constrói um novo par a partir de seus dois argumentos.
Ao chamar `cons` em um par composto por um valor e outro par, podemos construir
cons lists compostas por pares recursivos.

Por exemplo, aqui está uma representação em pseudocódigo de uma cons list que
contém a lista `1, 2, 3`, com cada par entre parênteses:

```text
(1, (2, (3, Nil)))
```

Cada item em uma cons list contém dois elementos: o valor do item atual e o
próximo item. O último item da lista contém apenas um valor chamado `Nil`, sem
um próximo item. Uma cons list é produzida chamando recursivamente a função
`cons`. O nome canônico para indicar o caso base da recursão é `Nil`. Observe
que isso não é o mesmo que o conceito de "null" ou "nil" discutido no Capítulo
6, que é um valor inválido ou ausente.

A cons list não é uma estrutura de dados muito usada em Rust. Na maioria das
vezes, quando você tem uma lista de itens em Rust, `Vec<T>` é uma escolha
melhor. Outros tipos de dados recursivos, mais complexos, _são_ úteis em várias
situações, mas, começando com a cons list neste capítulo, podemos explorar como
boxes nos permitem definir um tipo de dado recursivo sem muita distração.

A Listagem 15-2 contém uma definição de enum para uma cons list. Observe que
esse código ainda não compila, porque o tipo `List` não tem um tamanho
conhecido, como demonstraremos.

<Listing number="15-2" file-name="src/main.rs" caption="A primeira tentativa de definir um enum para representar uma estrutura de dados cons list de valores `i32`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-02/src/main.rs:here}}
```

</Listing>

> Observação: estamos implementando uma cons list que armazena apenas valores
> `i32` para os propósitos deste exemplo. Poderíamos tê-la implementado usando
> genéricos, como discutimos no Capítulo 10, para definir um tipo cons list que
> pudesse armazenar valores de qualquer tipo.

Usar o tipo `List` para armazenar a lista `1, 2, 3` ficaria como o código da
Listagem 15-3.

<Listing number="15-3" file-name="src/main.rs" caption="Usando o enum `List` para armazenar a lista `1, 2, 3`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-03/src/main.rs:here}}
```

</Listing>

O primeiro valor `Cons` armazena `1` e outro valor `List`. Esse valor `List` é
outro valor `Cons` que armazena `2` e outro valor `List`. Esse valor `List` é
mais um valor `Cons` que armazena `3` e um valor `List`, que finalmente é
`Nil`, a variante não recursiva que sinaliza o fim da lista.

Se tentarmos compilar o código da Listagem 15-3, receberemos o erro mostrado na
Listagem 15-4.

<Listing number="15-4" caption="O erro que recebemos ao tentar definir um enum recursivo">

```console
{{#include ../listings/ch15-smart-pointers/listing-15-03/output.txt}}
```

</Listing>

O erro mostra que esse tipo "tem tamanho infinito". O motivo é que definimos
`List` com uma variante recursiva: ela armazena diretamente outro valor de si
mesma. Como resultado, Rust não consegue descobrir quanto espaço precisa para
armazenar um valor `List`. Vamos decompor por que recebemos esse erro.
Primeiro, veremos como Rust decide quanto espaço precisa para armazenar um
valor de um tipo não recursivo.

#### Calculando o Tamanho de um Tipo Não Recursivo

Lembre-se do enum `Message` que definimos na Listagem 6-2 quando discutimos
definições de enum no Capítulo 6:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-02/src/main.rs:here}}
```

Para determinar quanto espaço alocar para um valor `Message`, Rust percorre
cada uma das variantes para ver qual delas precisa de mais espaço. Rust vê que
`Message::Quit` não precisa de espaço, `Message::Move` precisa de espaço
suficiente para armazenar dois valores `i32`, e assim por diante. Como apenas
uma variante será usada, o máximo de espaço que um valor `Message` precisará é
o espaço necessário para armazenar a maior de suas variantes.

Compare isso com o que acontece quando Rust tenta determinar quanto espaço um
tipo recursivo como o enum `List` da Listagem 15-2 precisa. O compilador começa
olhando para a variante `Cons`, que armazena um valor do tipo `i32` e um valor
do tipo `List`. Portanto, `Cons` precisa de uma quantidade de espaço igual ao
tamanho de um `i32` mais o tamanho de um `List`. Para descobrir quanta memória
o tipo `List` precisa, o compilador olha para as variantes, começando pela
variante `Cons`. A variante `Cons` armazena um valor do tipo `i32` e um valor
do tipo `List`, e esse processo continua infinitamente, como mostra a Figura
15-1.

<img alt="Uma cons list infinita: um retângulo rotulado 'Cons' dividido em dois retângulos menores. O primeiro retângulo menor contém o rótulo 'i32', e o segundo contém o rótulo 'Cons' e uma versão menor do retângulo externo 'Cons'. Os retângulos 'Cons' continuam contendo versões cada vez menores de si mesmos até que o menor retângulo confortavelmente visível contém um símbolo de infinito, indicando que essa repetição continua para sempre." src="img/trpl15-01.svg" class="center" style="width: 50%;" />

<span class="caption">Figura 15-1: Uma `List` infinita composta por infinitas
variantes `Cons`</span>

<!-- Old headings. Do not remove or links may break. -->

<a id="using-boxt-to-get-a-recursive-type-with-a-known-size"></a>

#### Obtendo um Tipo Recursivo com Tamanho Conhecido

Como Rust não consegue descobrir quanto espaço alocar para tipos definidos
recursivamente, o compilador apresenta um erro com esta sugestão útil:

<!-- manual-regeneration
after doing automatic regeneration, look at listings/ch15-smart-pointers/listing-15-03/output.txt and copy the relevant line
-->

```text
help: insert some indirection (e.g., a `Box`, `Rc`, or `&`) to break the cycle
  |
2 |     Cons(i32, Box<List>),
  |               ++++    +
```

Nessa sugestão, _indireção_ significa que, em vez de armazenar um valor
diretamente, devemos mudar a estrutura de dados para armazenar o valor
indiretamente, armazenando um ponteiro para ele.

Como `Box<T>` é um ponteiro, Rust sempre sabe de quanto espaço um `Box<T>`
precisa: o tamanho de um ponteiro não muda de acordo com a quantidade de dados
para a qual ele aponta. Isso significa que podemos colocar um `Box<T>` dentro
da variante `Cons`, em vez de outro valor `List` diretamente. O `Box<T>`
apontará para o próximo valor `List`, que estará no heap em vez de dentro da
variante `Cons`. Conceitualmente, ainda temos uma lista criada com listas que
armazenam outras listas, mas essa implementação agora se parece mais com itens
colocados um ao lado do outro do que um dentro do outro.

Podemos mudar a definição do enum `List` da Listagem 15-2 e o uso de `List` da
Listagem 15-3 para o código da Listagem 15-5, que compilará.

<Listing number="15-5" file-name="src/main.rs" caption="A definição de `List` que usa `Box<T>` para ter um tamanho conhecido">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-05/src/main.rs}}
```

</Listing>

A variante `Cons` precisa do tamanho de um `i32` mais o espaço para armazenar
os dados do ponteiro do box. A variante `Nil` não armazena valores, então
precisa de menos espaço na pilha que a variante `Cons`. Agora sabemos que
qualquer valor `List` ocupará o tamanho de um `i32` mais o tamanho dos dados do
ponteiro de um box. Ao usar um box, quebramos a cadeia recursiva infinita, de
modo que o compilador consegue descobrir o tamanho necessário para armazenar um
valor `List`. A Figura 15-2 mostra como a variante `Cons` fica agora.

<img alt="Um retângulo rotulado 'Cons' dividido em dois retângulos menores. O primeiro retângulo menor contém o rótulo 'i32', e o segundo contém o rótulo 'Box', com um retângulo interno que contém o rótulo 'usize', representando o tamanho finito do ponteiro do box." src="img/trpl15-02.svg" class="center" />

<span class="caption">Figura 15-2: Uma `List` que não tem tamanho infinito,
porque `Cons` armazena um `Box`</span>

Boxes fornecem apenas indireção e alocação no heap; eles não têm nenhuma outra
capacidade especial, como as que veremos nos outros tipos de ponteiros
inteligentes. Eles também não têm o custo adicional de desempenho que essas
capacidades especiais trazem, então podem ser úteis em casos como o da cons
list, em que a indireção é a única funcionalidade de que precisamos. Veremos
mais casos de uso para boxes no Capítulo 18.

O tipo `Box<T>` é um ponteiro inteligente porque implementa a trait `Deref`, o
que permite que valores `Box<T>` sejam tratados como referências. Quando um
valor `Box<T>` sai de escopo, os dados no heap para os quais o box aponta
também são limpos por causa da implementação da trait `Drop`. Essas duas traits
serão ainda mais importantes para a funcionalidade fornecida pelos outros tipos
de ponteiros inteligentes que discutiremos no restante deste capítulo. Vamos
explorar essas duas traits em mais detalhes.

[trait-objects]: ch18-02-trait-objects.html#using-trait-objects-to-abstract-over-shared-behavior

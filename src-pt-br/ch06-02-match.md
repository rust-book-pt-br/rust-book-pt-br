<!-- Old headings. Do not remove or links may break. -->

<a id="the-match-control-flow-operator"></a>

## A construção de fluxo de controle `match`

Rust tem uma construção de fluxo de controle extremamente poderosa chamada `match` que
permite comparar um valor com uma série de padrões e depois executar
código com base em qual padrão corresponde. Os padrões podem ser compostos de valores literais,
nomes de variáveis, curingas e muitas outras coisas; [Capítulo
19][ch19-00-patterns]<!-- ignore --> abrange todos os diferentes tipos de padrões
e o que eles fazem. O poder de `match` vem da expressividade do
padrões e o fato de que o compilador confirma que todos os casos possíveis são
manipulado.

Pense em uma expressão `match` como uma máquina de classificação de moedas: Slide de moedas
por uma trilha com buracos de tamanhos variados ao longo dela, e cada moeda cai
o primeiro buraco que encontra e onde se encaixa. Da mesma forma, os valores vão
através de cada padrão em `match`, e no primeiro padrão o valor “se ajusta”,
o valor cai no bloco de código associado a ser usado durante a execução.

Falando em moedas, vamos usá-las como exemplo usando `match`! Podemos escrever um
função que pega uma moeda americana desconhecida e, de forma semelhante à contagem
máquina, determina qual moeda é e retorna seu valor em centavos, conforme mostrado
na Listagem 6-3.

<Listing number="6-3" caption="An enum and a `match` expression that has the variants of the enum as its patterns">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-03/src/main.rs:here}}
```

</Listing>

Vamos dividir `match` na função `value_in_cents`. Primeiro, listamos
a palavra-chave `match` seguida por uma expressão, que neste caso é o valor
`coin`. Isso parece muito semelhante a uma expressão condicional usada com `if`, mas
há uma grande diferença: com `if`, a condição precisa ser avaliada como
Valor booleano, mas aqui pode ser de qualquer tipo. O tipo de `coin` neste exemplo
é o `Coin` enum que definimos na primeira linha.

Em seguida estão os braços `match`. Um braço tem duas partes: um padrão e algum código. O
o primeiro braço aqui tem um padrão que é o valor `Coin::Penny` e depois o `=>`
operador que separa o padrão e o código a ser executado. O código neste caso
é apenas o valor `1`. Cada braço é separado do próximo por uma vírgula.

Quando a expressão `match` é executada, ela compara o valor resultante com
o padrão de cada braço, em ordem. Se um padrão corresponder ao valor, o código
associado a esse padrão é executado. Se esse padrão não corresponder ao
valor, a execução continua para o braço seguinte, tal como numa máquina de classificação de moedas.
Podemos ter quantos braços precisarmos: Na Listagem 6-3, nosso `match` tem quatro braços.

O código associado a cada braço é uma expressão e o valor resultante de
a expressão no braço correspondente é o valor retornado para o
expressão `match` inteira.

Normalmente não usamos chaves se o código do braço de correspondência for curto, pois é
na Listagem 6-3, onde cada braço retorna apenas um valor. Se você quiser executar vários
linhas de código em um braço de correspondência, você deve usar colchetes e a vírgula
seguir o braço é então opcional. Por exemplo, o código a seguir imprime
“Um centavo da sorte!” toda vez que o método é chamado com `Coin::Penny`, mas
ainda retorna o último valor do bloco, `1`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-08-match-arm-multiple-lines/src/main.rs:here}}
```

### Padrões que se vinculam a valores

Outra característica útil dos braços de fósforo é que eles podem se ligar às partes do
valores que correspondem ao padrão. É assim que podemos extrair valores de enum
variantes.

Como exemplo, vamos alterar uma de nossas variantes de enum para armazenar dados dentro dela.
De 1999 a 2008, os Estados Unidos cunharam moedas com diferentes
projetos para cada um dos 50 estados de um lado. Nenhuma outra moeda obteve estado
designs, portanto, apenas os quartos têm esse valor extra. Podemos adicionar essas informações
nosso `enum` alterando a variante `Quarter` para incluir um valor `UsState`
armazenado dentro dele, o que fizemos na Listagem 6-4.

<Listing number="6-4" caption="A `Coin` enum in which the `Quarter` variant also holds a `UsState` value">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-04/src/main.rs:here}}
```

</Listing>

Vamos imaginar que um amigo esteja tentando coletar todos os 50 bairros estaduais. Enquanto
classificarmos nossos trocos por tipo de moeda, também chamaremos o nome do
estado associado a cada trimestre para que, se for um que nosso amigo não tenha,
eles podem adicioná-lo à sua coleção.

Na expressão de correspondência deste código, adicionamos uma variável chamada `state` ao
padrão que corresponde aos valores da variante `Coin::Quarter`. Quando um
`Coin::Quarter` corresponde, a variável `state` será vinculada ao valor desse
estado do trimestre. Então, podemos usar `state` no código desse braço, assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-09-variable-in-pattern/src/main.rs:here}}
```

Se ligássemos para `value_in_cents(Coin::Quarter(UsState::Alaska))`, `coin`
seria `Coin::Quarter(UsState::Alaska)`. Quando comparamos esse valor com cada
dos braços do jogo, nenhum deles combina até chegarmos a `Coin::Quarter(state)`. No
nesse ponto, a ligação para `state` será o valor `UsState::Alaska`. Pudermos
então use essa ligação na expressão `println!`, obtendo assim o interior
valor de estado da variante enum `Coin` para `Quarter`.

<!-- Old headings. Do not remove or links may break. -->

<a id="matching-with-optiont"></a>

### O padrão `Option<T>` `match`


Na seção anterior, queríamos obter o valor interno `T` de `Some`
caso ao usar `Option<T>`; também podemos lidar com `Option<T>` usando `match`, como
fizemos com o `Coin` enum! Em vez de comparar moedas, compararemos o
variantes de `Option<T>`, mas a forma como a expressão `match` funciona continua sendo a
mesmo.

Digamos que queremos escrever uma função que receba `Option<i32>` e, se
há um valor dentro, adiciona 1 a esse valor. Se não houver um valor dentro,
a função deve retornar o valor `None` e não tentar realizar qualquer
operações.

Esta função é muito fácil de escrever, graças a `match`, e será semelhante a
Listagem 6-5.

<Listing number="6-5" caption="A function that uses a `match` expression on an `Option<i32>`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-05/src/main.rs:here}}
```

</Listing>

Vamos examinar a primeira execução de `plus_one` com mais detalhes. Quando ligamos
`plus_one(five)`, a variável `x` no corpo de `plus_one` terá o
valor `Some(5)`. Em seguida, comparamos isso com cada braço da partida:

```rust,ignore
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-05/src/main.rs:first_arm}}
```

O valor `Some(5)` não corresponde ao padrão `None`, então continuamos para o
próximo braço:

```rust,ignore
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-05/src/main.rs:second_arm}}
```

`Some(5)` corresponde a `Some(i)`? É verdade! Temos a mesma variante. O `i`
se liga ao valor contido em `Some`, então `i` assume o valor `5`. O código em
o braço de correspondência é então executado, então adicionamos 1 ao valor de `i` e criamos um
novo valor `Some` com nosso total `6` dentro.

Agora vamos considerar a segunda chamada de `plus_one` na Listagem 6-5, onde `x` é
`None`. Entramos no `match` e comparamos com o primeiro braço:

```rust,ignore
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-05/src/main.rs:first_arm}}
```

Combina! Não há valor a ser adicionado, então o programa para e retorna o
`None` valor no lado direito de `=>`. Como o primeiro braço combinou, nenhum outro
braços são comparados.

Combinar `match` e enums é útil em muitas situações. Você verá isso
padrão muito no código Rust: `match` contra um enum, vincule uma variável ao
dados dentro e, em seguida, execute o código com base nele. É um pouco complicado no começo, mas
depois de se acostumar, você desejará tê-lo em todos os idiomas. Isso é
consistentemente um favorito do usuário.

### As partidas são exaustivas

Há outro aspecto de `match` que precisamos discutir: os padrões dos braços devem
cobrir todas as possibilidades. Considere esta versão da nossa função `plus_one`,
que tem um bug e não compila:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-10-non-exhaustive-match/src/main.rs:here}}
```

Não cuidamos do caso `None`, então esse código causará um bug. Felizmente, é
um bug que Rust sabe como capturar. Se tentarmos compilar este código, obteremos isso
erro:

```console
{{#include ../listings/ch06-enums-and-pattern-matching/no-listing-10-non-exhaustive-match/output.txt}}
```

Rust sabe que não cobrimos todos os casos possíveis e até sabe quais
padrão que esquecemos! As partidas em Rust são _exaustivas_: devemos esgotar até o último
possibilidade para que o código seja válido. Especialmente no caso de
`Option<T>`, quando Rust nos impede de esquecer de lidar explicitamente com o
`None` caso, isso nos protege de assumir que temos um valor quando poderíamos
têm nulo, tornando impossível o erro de um bilhão de dólares discutido anteriormente.

### Padrões pega-tudo e o espaço reservado `_`

Usando enums, também podemos realizar ações especiais para alguns valores específicos, mas
para todos os outros valores, execute uma ação padrão. Imagine que estamos implementando um jogo
onde, se você lançar um 3 em um lançamento de dados, seu jogador não se move, mas em vez disso
ganha um chapéu novo e chique. Se você tirar um 7, seu jogador perde um chapéu chique. Para todos
outros valores, seu jogador move esse número de espaços no tabuleiro de jogo. Aqui está
um `match` que implementa essa lógica, com o resultado do lançamento dos dados
codificado em vez de um valor aleatório, e todas as outras lógicas representadas por
funcionam sem órgãos porque a sua implementação efectiva está fora do alcance
este exemplo:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-15-binding-catchall/src/main.rs:here}}
```

Para os dois primeiros braços, os padrões são os valores literais `3` e `7`. Para
o último braço que cobre todos os outros valores possíveis, o padrão é o
variável que escolhemos nomear `other`. O código executado para o braço `other`
usa a variável passando-a para a função `move_player`.

Este código compila, mesmo que não tenhamos listado todos os valores possíveis
`u8` pode ter, porque o último padrão corresponderá a todos os valores, não especificamente
listado. Este padrão abrangente atende ao requisito de que `match` deve ser
exaustivo. Observe que temos que colocar o braço pega-tudo por último porque o
os padrões são avaliados em ordem. Se tivéssemos colocado o braço pega-tudo antes, o
outros braços nunca funcionariam, então Rust nos avisará se adicionarmos braços após um
pega tudo!

Rust também tem um padrão que podemos usar quando queremos algo abrangente, mas não queremos
_use_ o valor no padrão pega-tudo: `_` é um padrão especial que corresponde
qualquer valor e não se vincula a esse valor. Isso diz a Rust que não vamos
use o valor, para que Rust não nos avise sobre uma variável não utilizada.

Vamos mudar as regras do jogo: agora, se você tirar qualquer resultado diferente de 3 ou
um 7, você deve rolar novamente. Não precisamos mais usar o valor genérico, então
podemos alterar nosso código para usar `_` em vez da variável chamada `other`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-16-underscore-catchall/src/main.rs:here}}
```

Este exemplo também atende ao requisito de exaustividade porque estamos explicitamente
ignorando todos os outros valores no último braço; não esquecemos nada.

Por fim, mudaremos as regras do jogo mais uma vez para que nada mais
acontece no seu turno se você rolar algo diferente de 3 ou 7. Podemos expressar
que usando o valor unitário (o tipo de tupla vazia que mencionamos em [“The Tuple
Digite”][tuples]<!-- ignore --> seção) como o código que acompanha o braço `_`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-17-underscore-unit/src/main.rs:here}}
```

Aqui, estamos dizendo explicitamente ao Rust que não usaremos nenhum outro valor
que não corresponde a um padrão em um braço anterior e não queremos executar nenhum
código neste caso.

Há mais informações sobre padrões e correspondência que abordaremos no [Capítulo
19][ch19-00-patterns]<!-- ignore -->. Por enquanto, vamos passar para o
Sintaxe `if let`, que pode ser útil em situações onde a expressão `match`
é um pouco prolixo.

[tuples]: ch03-02-data-types.html#the-tuple-type
[ch19-00-patterns]: ch19-00-patterns.html

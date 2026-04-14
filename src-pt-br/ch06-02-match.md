<!-- Old headings. Do not remove or links may break. -->

<a id="the-match-control-flow-operator"></a>

## A construção de fluxo de controle `match`

Rust tem uma construção de fluxo de controle extremamente poderosa chamada
`match`, que permite comparar um valor com uma série de padrões e então
executar código com base em qual padrão corresponde. Padrões podem ser formados
por valores literais, nomes de variáveis, curingas e muitas outras coisas; o
[Capítulo 19][ch19-00-patterns]<!-- ignore --> aborda todos os tipos de padrões
e o que eles fazem. O poder de `match` vem da expressividade desses padrões e
do fato de o compilador confirmar que todos os casos possíveis foram tratados.

Pense em uma expressão `match` como uma máquina de classificar moedas: as
moedas deslizam por uma trilha com buracos de tamanhos variados, e cada moeda
cai no primeiro buraco em que ela cabe. Da mesma forma, valores passam por cada
padrão de um `match`, e, no primeiro padrão em que o valor “se encaixa”, ele
cai no bloco de código associado para ser usado durante a execução.

Já que falamos em moedas, vamos usá-las como exemplo com `match`! Podemos
escrever uma função que recebe uma moeda americana desconhecida e, de forma
parecida com uma máquina de contagem, determina qual moeda é e retorna seu
valor em centavos, como mostra a Listagem 6-3.

<Listing number="6-3" caption="Um enum e uma expressão `match` que usa as variantes desse enum como padrões">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-03/src/main.rs:here}}
```

</Listing>

Vamos destrinchar o `match` da função `value_in_cents`. Primeiro, temos a
palavra-chave `match`, seguida por uma expressão, que neste caso é o valor
`coin`. Isso parece bastante com uma expressão condicional usada com `if`, mas
há uma grande diferença: com `if`, a condição precisa ser avaliada para um
valor booleano; aqui, ela pode ser de qualquer tipo. O tipo de `coin`, neste
exemplo, é o enum `Coin` que definimos na primeira linha.

Depois vêm os braços do `match`. Um braço tem duas partes: um padrão e algum
código. O primeiro braço aqui tem como padrão o valor `Coin::Penny` e, em
seguida, o operador `=>`, que separa o padrão do código a ser executado. O
código, neste caso, é apenas o valor `1`. Cada braço é separado do seguinte
por uma vírgula.

Quando a expressão `match` é executada, ela compara o valor resultante com o
padrão de cada braço, em ordem. Se um padrão corresponder ao valor, o código
associado a esse padrão é executado. Se esse padrão não corresponder, a
execução continua para o próximo braço, como numa máquina de classificar
moedas. Podemos ter quantos braços precisarmos: na Listagem 6-3, nosso `match`
tem quatro braços.

O código associado a cada braço é uma expressão, e o valor resultante da
expressão no braço correspondente é o valor retornado pela expressão `match`
inteira.

Normalmente não usamos chaves quando o código do braço é curto, como na
Listagem 6-3, em que cada braço apenas retorna um valor. Se você quiser
executar várias linhas de código em um braço de `match`, deve usar chaves, e a
vírgula após esse braço passa então a ser opcional. Por exemplo, o código a
seguir imprime “Lucky penny!” toda vez que o método é chamado com
`Coin::Penny`, mas ainda retorna o último valor do bloco, `1`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-08-match-arm-multiple-lines/src/main.rs:here}}
```

### Padrões que se ligam a valores

Outro recurso útil dos braços de `match` é que eles podem se ligar às partes
dos valores que correspondem ao padrão. É assim que podemos extrair valores de
variantes de enum.

Como exemplo, vamos alterar uma das variantes do nosso enum para armazenar
dados dentro dela. De 1999 a 2008, os Estados Unidos cunharam moedas de 25
centavos com desenhos diferentes para cada um dos 50 estados em um dos lados.
Nenhuma outra moeda recebeu desenhos de estados, então apenas os quarters têm
esse valor extra. Podemos adicionar essa informação ao nosso `enum` alterando a
variante `Quarter` para incluir um valor `UsState` armazenado dentro dela, como
fizemos na Listagem 6-4.

<Listing number="6-4" caption="Um enum `Coin` em que a variante `Quarter` também armazena um valor `UsState`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-04/src/main.rs:here}}
```

</Listing>

Vamos imaginar que um amigo esteja tentando colecionar todos os 50 quarters de
estados. Enquanto classificamos nosso troco por tipo de moeda, também diremos o
nome do estado associado a cada quarter para que, se for um que nosso amigo não
tenha, ele possa adicioná-lo à coleção.

Na expressão `match` deste código, adicionamos uma variável chamada `state` ao
padrão que corresponde a valores da variante `Coin::Quarter`. Quando um
`Coin::Quarter` corresponder, a variável `state` será ligada ao valor do estado
daquele quarter. Depois, podemos usar `state` no código desse braço, assim:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-09-variable-in-pattern/src/main.rs:here}}
```

Se chamássemos `value_in_cents(Coin::Quarter(UsState::Alaska))`, `coin` seria
`Coin::Quarter(UsState::Alaska)`. Quando comparamos esse valor com cada um dos
braços do `match`, nenhum deles corresponde até chegarmos a
`Coin::Quarter(state)`. Nesse ponto, a ligação `state` terá o valor
`UsState::Alaska`. Podemos então usar essa ligação na expressão `println!`,
obtendo assim o valor interno do estado da variante `Coin::Quarter`.

<!-- Old headings. Do not remove or links may break. -->

<a id="matching-with-optiont"></a>

### O padrão `match` com `Option<T>`

Na seção anterior, queríamos obter o valor interno `T` do caso `Some` ao usar
`Option<T>`; também podemos tratar `Option<T>` com `match`, assim como fizemos
com o enum `Coin`! Em vez de comparar moedas, vamos comparar as variantes de
`Option<T>`, mas a forma como a expressão `match` funciona continua a mesma.

Digamos que queremos escrever uma função que recebe um `Option<i32>` e, se
houver um valor dentro, soma 1 a esse valor. Se não houver valor algum, a
função deve retornar `None` e não tentar executar operação nenhuma.

Essa função é muito fácil de escrever graças a `match`, e ficará como a
Listagem 6-5.

<Listing number="6-5" caption="Uma função que usa uma expressão `match` sobre um `Option<i32>`">

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-05/src/main.rs:here}}
```

</Listing>

Vamos examinar a primeira execução de `plus_one` com mais detalhes. Quando
chamamos `plus_one(five)`, a variável `x` no corpo de `plus_one` terá o valor
`Some(5)`. Em seguida, comparamos isso com cada braço do `match`:

```rust,ignore
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-05/src/main.rs:first_arm}}
```

O valor `Some(5)` não corresponde ao padrão `None`, então seguimos para o
próximo braço:

```rust,ignore
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-05/src/main.rs:second_arm}}
```

`Some(5)` corresponde a `Some(i)`? Sim! Temos a mesma variante. O `i` se liga
ao valor contido em `Some`, então `i` recebe o valor `5`. O código daquele
braço do `match` é então executado, somamos 1 ao valor de `i` e criamos um
novo valor `Some` com o total `6` dentro.

Agora vamos considerar a segunda chamada de `plus_one` na Listagem 6-5, em que
`x` é `None`. Entramos no `match` e comparamos com o primeiro braço:

```rust,ignore
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/listing-06-05/src/main.rs:first_arm}}
```

Ele corresponde! Não há valor a ser somado, então o programa para e retorna o
valor `None` que está do lado direito de `=>`. Como o primeiro braço
correspondeu, nenhum outro braço é comparado.

Combinar `match` e enums é útil em muitas situações. Você verá bastante esse
padrão em código Rust: fazer `match` sobre um enum, ligar uma variável aos
dados internos e então executar código com base nisso. No começo ele parece um
pouco complicado, mas, depois que você se acostuma, acaba desejando ter isso em
todas as linguagens. É consistentemente um dos recursos favoritos dos usuários.

### Matches são exaustivos

Há outro aspecto de `match` que precisamos discutir: os padrões dos braços
devem cobrir todas as possibilidades. Considere esta versão da nossa função
`plus_one`, que tem um bug e não compila:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-10-non-exhaustive-match/src/main.rs:here}}
```

Não tratamos o caso `None`, então esse código causará um bug. Felizmente, esse
é um bug que Rust sabe capturar. Se tentarmos compilar esse código, obteremos
este erro:

```console
{{#include ../listings/ch06-enums-and-pattern-matching/no-listing-10-non-exhaustive-match/output.txt}}
```

Rust sabe que não cobrimos todos os casos possíveis e até sabe qual padrão foi
esquecido! Matches em Rust são _exaustivos_: precisamos cobrir até a última
possibilidade para que o código seja válido. Especialmente no caso de
`Option<T>`, quando Rust nos impede de esquecer de tratar explicitamente o caso
`None`, ela nos protege de assumir que temos um valor quando na verdade
poderíamos ter `null`, tornando impossível o erro de um bilhão de dólares
discutido antes.

### Padrões pega-tudo e o marcador `_`

Usando enums, também podemos realizar ações especiais para alguns valores
específicos e, para todos os outros, executar uma ação padrão. Imagine que
estamos implementando um jogo em que, se você tirar 3 em uma rolagem de dado,
seu personagem não se move, mas ganha um chapéu novo e elegante. Se você tirar
7, seu personagem perde um chapéu elegante. Para todos os outros valores, seu
personagem anda aquele número de casas no tabuleiro. Aqui está um `match` que
implementa essa lógica, com o resultado do dado fixado no código em vez de ser
um valor aleatório, e toda a outra lógica representada por funções sem corpo,
porque implementá-las de verdade foge do escopo deste exemplo:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-15-binding-catchall/src/main.rs:here}}
```

Nos dois primeiros braços, os padrões são os valores literais `3` e `7`. Para
o último braço, que cobre todos os outros valores possíveis, o padrão é a
variável que escolhemos chamar de `other`. O código executado para o braço
`other` usa essa variável ao passá-la para a função `move_player`.

Esse código compila mesmo sem listarmos todos os valores possíveis de um `u8`,
porque o último padrão corresponderá a todos os valores não listados
explicitamente. Esse padrão pega-tudo atende ao requisito de que `match` deve
ser exaustivo. Observe que precisamos colocar o braço pega-tudo por último,
porque os padrões são avaliados em ordem. Se tivéssemos colocado o braço
pega-tudo antes, os outros braços nunca seriam executados, então Rust nos
avisará se adicionarmos braços depois de um pega-tudo.

Rust também tem um padrão que podemos usar quando queremos um pega-tudo, mas
não queremos _usar_ o valor capturado por ele: `_` é um padrão especial que
corresponde a qualquer valor e não se liga a ele. Isso diz ao Rust que não
vamos usar o valor, então ela não nos avisará sobre uma variável não utilizada.

Vamos mudar as regras do jogo: agora, se você tirar qualquer valor diferente de
3 ou 7, deve rolar novamente. Não precisamos mais usar o valor pega-tudo,
então podemos alterar o código para usar `_` em vez da variável chamada
`other`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-16-underscore-catchall/src/main.rs:here}}
```

Este exemplo também atende ao requisito de exaustividade porque estamos
explicitamente ignorando todos os outros valores no último braço; não
esquecemos nada.

Por fim, vamos mudar as regras do jogo mais uma vez, de modo que nada mais
aconteça no turno se você tirar qualquer coisa diferente de 3 ou 7. Podemos
expressar isso usando o valor unitário, o tipo de tupla vazia mencionado na
seção [“O tipo tupla”][tuples]<!-- ignore -->, como o código associado ao braço
`_`:

```rust
{{#rustdoc_include ../listings/ch06-enums-and-pattern-matching/no-listing-17-underscore-unit/src/main.rs:here}}
```

Aqui, estamos dizendo explicitamente ao Rust que não vamos usar nenhum outro
valor que não corresponda a um padrão de um braço anterior e que também não
queremos executar código algum nesse caso.

Há mais sobre padrões e correspondência no [Capítulo
19][ch19-00-patterns]<!-- ignore -->. Por enquanto, vamos seguir para a sintaxe
`if let`, que pode ser útil em situações em que a expressão `match` fica um
pouco verbosa.

[tuples]: ch03-02-data-types.html#the-tuple-type
[ch19-00-patterns]: ch19-00-patterns.html

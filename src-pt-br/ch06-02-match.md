## O Construto de Controle de Fluxo `match`

Rust tem um construto de controle de fluxo extremamente poderoso chamado
`match`, que permite comparar um valor com uma série de padrões e então
executar um código com base no padrão que casar. Padrões podem ser compostos de
valores literais, nomes de variáveis, curingas e muitas outras coisas. O
Capítulo 19 aborda todos os diferentes tipos de padrões e o que eles fazem. O
poder do `match` vem da expressividade dos padrões e do fato de o compilador
confirmar que todos os casos possíveis estão sendo tratados.

Pense em uma expressão `match` como se fosse uma máquina de separar moedas: as
moedas descem por um trilho com furos de tamanhos variados, e cada moeda cai no
primeiro furo em que couber. Da mesma forma, os valores passam por cada padrão
de um `match`, e, no primeiro padrão em que o valor "couber", ele cai no bloco
de código associado para ser usado durante a execução.

Já que estamos falando de moedas, vamos usá-las como exemplo de `match`!
Podemos escrever uma função que recebe uma moeda desconhecida dos Estados
Unidos e, de maneira semelhante à máquina de contagem, determina qual moeda é e
retorna seu valor em _cents_, como mostra a Listagem 6-3:

> **Nota do tradutor:** diferentemente do que acontece na maioria dos países,
> as moedas dos Estados Unidos possuem nomes: as de 1 _cent_ são chamadas de
> _Penny_; as de 5 _cents_, de _Nickel_; as de 10 _cents_, de _Dime_; e as de
> 25 _cents_, de _Quarter_.

```rust
enum Moeda {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn valor_em_cents(moeda: Moeda) -> u32 {
    match moeda {
        Moeda::Penny => 1,
        Moeda::Nickel => 5,
        Moeda::Dime => 10,
        Moeda::Quarter => 25,
    }
}
```

<span class="caption">Listagem 6-3: Uma enum e uma expressão `match` cujos
padrões são as variantes da enum</span>

Vamos analisar o `match` da função `valor_em_cents`. Primeiro, escrevemos a
palavra-chave `match` seguida de uma expressão, que neste caso é o valor
`moeda`. Isso se parece bastante com uma expressão condicional usada com `if`,
mas há uma grande diferença: com `if`, a condição precisa resultar em um valor
_booleano_; aqui, ela pode ser de qualquer tipo. O tipo de `moeda`, neste
exemplo, é a enum `Moeda`, que definimos na primeira linha.

Em seguida vêm os braços do `match`. Um braço tem duas partes: um padrão e
algum código. O primeiro braço, neste caso, tem como padrão o valor
`Moeda::Penny` e, depois, o operador `=>`, que separa o padrão do código a ser
executado. O código aqui é apenas o valor `1`. Cada braço é separado do
seguinte por uma vírgula.

Quando a expressão `match` é executada, ela compara o valor resultante com o
padrão de cada braço, em ordem. Se um padrão casar com o valor, o código
associado a esse padrão será executado. Se esse padrão não casar com o valor,
a execução continuará para o próximo braço, de forma muito parecida com a
máquina de separar moedas. Podemos ter quantos braços forem necessários: na
Listagem 6-3, nosso `match` tem quatro braços.

O código associado a cada braço é uma expressão, e o valor resultante da
expressão no braço que casar é o valor retornado pela expressão `match` como um
todo.

Normalmente, não usamos chaves quando o código do braço do `match` é curto,
como na Listagem 6-3, em que cada braço apenas retorna um valor. Se você quiser
executar várias linhas de código em um braço do `match`, precisará usar chaves,
e a vírgula após o braço passa a ser opcional. Por exemplo, o código a seguir
escreve "Moeda da sorte!" toda vez que o método é chamado com `Moeda::Penny`,
mas ainda assim retorna o último valor do bloco, `1`:

```rust
# enum Moeda {
#    Penny,
#    Nickel,
#    Dime,
#    Quarter,
# }
#
fn valor_em_cents(moeda: Moeda) -> u32 {
    match moeda {
        Moeda::Penny => {
            println!("Moeda da sorte!");
            1
        },
        Moeda::Nickel => 5,
        Moeda::Dime => 10,
        Moeda::Quarter => 25,
    }
}
```

### Padrões Que Associam Valores

Outra característica útil dos braços do `match` é que eles podem associar
partes dos valores que casam com o padrão. É assim que conseguimos extrair
valores de variantes de enums.

Como exemplo, vamos alterar uma das nossas variantes para armazenar dados. De
1999 a 2008, os Estados Unidos cunharam _quarters_ com desenhos diferentes para
cada um dos 50 estados em um dos lados da moeda. Nenhuma outra moeda tinha
desenhos de estados, então apenas os _quarters_ têm esse valor extra. Podemos
adicionar essa informação à nossa `enum` mudando a variante `Quarter` para
incluir um valor `Estado`, como na Listagem 6-4:

```rust
#[derive(Debug)] // Para podermos ver qual é o estado com mais facilidade
enum Estado {
    Alabama,
    Alaska,
    // ... etc
}

enum Moeda {
    Penny,
    Nickel,
    Dime,
    Quarter(Estado),
}
```

<span class="caption">Listagem 6-4: Enum `Moeda`, em que a variante `Quarter`
também armazena um valor `Estado`</span>

Vamos imaginar que um amigo nosso está tentando colecionar todos os _quarters_
dos 50 estados. Enquanto separamos nosso troco por tipo de moeda, também vamos
anunciar o nome do estado associado a cada _quarter_, para que, se for um que o
nosso amigo ainda não tenha, ele possa adicioná-lo à coleção.

Na expressão `match` desse código, adicionamos uma variável chamada `estado` ao
padrão que casa com valores da variante `Moeda::Quarter`. Quando um
`Moeda::Quarter` casar, a variável `estado` ficará associada ao valor do estado
daquele _quarter_. Assim, poderemos usar `estado` no código desse braço, da
seguinte forma:

```rust
# #[derive(Debug)]
# enum Estado {
#    Alabama,
#    Alaska,
# }
#
# enum Moeda {
#    Penny,
#    Nickel,
#    Dime,
#    Quarter(Estado),
# }
#
fn valor_em_cents(moeda: Moeda) -> u32 {
    match moeda {
        Moeda::Penny => 1,
        Moeda::Nickel => 5,
        Moeda::Dime => 10,
        Moeda::Quarter(estado) => {
            println!("Quarter do estado {:?}!", estado);
            25
        },
    }
}
```

Se executarmos `valor_em_cents(Moeda::Quarter(Estado::Alaska))`, `moeda` será
`Moeda::Quarter(Estado::Alaska)`. Ao comparar esse valor com cada braço do
`match`, nenhum deles casará até chegarmos a `Moeda::Quarter(estado)`. Nesse
ponto, `estado` estará associado ao valor `Estado::Alaska`. Podemos então usar
esse valor na expressão `println!`, obtendo o valor interno do estado da
variante `Quarter` da enum `Moeda`.

### O Padrão de `match` para `Option<T>`

Na seção anterior, queríamos obter o valor interno do tipo `T` no caso `Some`
ao usar `Option<T>`; também podemos tratar `Option<T>` usando `match`, como
fizemos com a enum `Moeda`! Em vez de comparar moedas, vamos comparar as
variantes de `Option<T>`, mas a forma como a expressão `match` funciona
continua a mesma.

Digamos que queremos escrever uma função que recebe um `Option<i32>` e, se
houver um valor dentro dele, some 1 a esse valor. Se não houver valor, a
função deve retornar `None` e não tentar executar nenhuma operação.

Essa função é muito fácil de escrever graças ao `match`, e ficará como na
Listagem 6-5:

```rust
fn mais_um(x: Option<i32>) -> Option<i32> {
    match x {
        None => None,
        Some(i) => Some(i + 1),
    }
}

let cinco = Some(5);
let seis = mais_um(cinco);
let nenhum = mais_um(None);
```

<span class="caption">Listagem 6-5: Uma função que usa uma expressão `match`
em um `Option<i32>`</span>

Vamos examinar a primeira execução de `mais_um` com mais detalhes. Quando
chamamos `mais_um(cinco)`, a variável `x` no corpo da função `mais_um` terá o
valor `Some(5)`. Então comparamos esse valor com cada braço do `match`.

```rust,ignore
None => None,
```

O valor `Some(5)` não casa com o padrão `None`, então seguimos para o próximo
braço:

```rust,ignore
Some(i) => Some(i + 1),
```

`Some(5)` casa com `Some(i)`? Sim, casa! Temos a mesma variante. O `i` fica
associado ao valor contido em `Some`, então `i` passa a valer `5`. O código
desse braço é executado, somamos 1 ao valor de `i` e criamos um novo `Some`
contendo o total `6`.

Agora vamos considerar a segunda chamada de `mais_um` na Listagem 6-5, em que
`x` é `None`. Entramos no `match` e comparamos com o primeiro braço:

```rust,ignore
None => None,
```

Agora casou! Não há nenhum valor ao qual somar, então o programa para e
retorna o valor `None` à direita de `=>`. Como o primeiro braço já casou,
nenhum dos demais será testado.

Combinar `match` e enums é útil em muitas situações. Você verá muito esse
padrão em código Rust: usar `match` em uma enum, associar uma variável aos
dados internos e então executar um código com base nisso. No começo pode
parecer um pouco complicado, mas, quando você se acostuma, passa a querer isso
em todas as linguagens. É um recurso consistentemente querido por quem usa
Rust.

### `match` É Exaustivo

Há outro aspecto do `match` que precisamos discutir: os padrões dos braços
precisam cobrir todas as possibilidades. Considere esta versão da nossa função
`mais_um`, que tem um bug e não compila:

```rust,ignore
fn mais_um(x: Option<i32>) -> Option<i32> {
    match x {
        Some(i) => Some(i + 1),
    }
}
```

Nós não tratamos o caso `None`, então esse código causará um erro. Por sorte,
é um erro que Rust sabe detectar. Se tentarmos compilar esse código, teremos
esta mensagem:

```text
error[E0004]: non-exhaustive patterns: `None` not covered
 -->
  |
6 |         match x {
  |               ^ pattern `None` not covered
```

Rust sabe que não cobrimos todos os casos possíveis e até qual padrão
esquecemos! Expressões `match` em Rust são *exaustivas*: precisamos cobrir cada
última possibilidade para que o código seja válido. Especialmente no caso de
`Option<T>`, quando Rust nos impede de esquecer de tratar explicitamente o caso
`None`, ele nos protege de assumir que temos um valor quando podemos ter um
nulo, tornando impossível o erro de um bilhão de dólares discutido antes.

### Padrões Curinga e o Placeholder `_`

Usando enums, também podemos executar ações especiais para alguns valores
específicos e, para todos os demais, executar uma ação padrão. Imagine que
estamos implementando um jogo em que, se você tirar 3 em uma rolagem de dado,
o jogador não se move, mas ganha um chapéu novo e estiloso. Se tirar 7, perde
um desses chapéus. Para qualquer outro valor, o jogador anda o número
correspondente de casas no tabuleiro. Aqui está um `match` que implementa essa
lógica, com o resultado da rolagem fixado no código em vez de ser aleatório, e
todo o restante da lógica representado por funções sem corpo, porque implementá
la de verdade foge do escopo deste exemplo:

```rust
fn adicionar_chapeu_elegante() {}
fn remover_chapeu_elegante() {}
fn mover_jogador(num_casas: u8) {}

let resultado_dado = 9;
match resultado_dado {
    3 => adicionar_chapeu_elegante(),
    7 => remover_chapeu_elegante(),
    other => mover_jogador(other),
}
```

Nos dois primeiros braços, os padrões são os valores literais `3` e `7`. No
último braço, que cobre todos os demais valores possíveis, o padrão é a
variável que escolhemos chamar de `other`. O código executado nesse braço usa a
variável ao passá-la para a função `mover_jogador`.

Esse código compila, ainda que não tenhamos listado todos os valores possíveis
de um `u8`, porque o último padrão casará com todos os valores não listados
explicitamente. Esse padrão "pega-tudo" atende ao requisito de que o `match`
deve ser exaustivo. Note que precisamos colocar esse braço por último, porque
os padrões são avaliados em ordem. Se colocássemos o braço pega-tudo antes, os
demais nunca seriam executados; por isso, Rust avisa quando adicionamos braços
depois de um padrão pega-tudo.

Rust também tem um padrão que podemos usar quando queremos um braço pega-tudo,
mas não queremos *usar* o valor capturado: `_` é um padrão especial que casa
com qualquer valor sem associá-lo a uma variável. Isso informa a Rust que não
vamos usar esse valor, então o compilador não emitirá aviso sobre variável não
utilizada.

Vamos mudar as regras do jogo: agora, se você tirar qualquer coisa diferente de
3 ou 7, terá de rolar de novo. Já não precisamos usar o valor capturado no
braço pega-tudo, então podemos trocar a variável `other` por `_`:

```rust
fn adicionar_chapeu_elegante() {}
fn remover_chapeu_elegante() {}

let resultado_dado = 9;
match resultado_dado {
    3 => adicionar_chapeu_elegante(),
    7 => remover_chapeu_elegante(),
    _ => (),
}
```

Este exemplo também atende ao requisito de exaustividade, porque estamos
ignorando explicitamente todos os outros valores no último braço; não deixamos
nada de fora.

Se mudarmos as regras mais uma vez para que absolutamente nada aconteça no seu
turno quando você tirar qualquer coisa diferente de 3 ou 7, podemos expressar
isso usando o valor unitário, que é o código associado ao braço `_`.

Há muito mais sobre padrões e casamento de padrões no Capítulo 19. Por ora,
vamos passar para a sintaxe `if let`, que pode ser útil em situações em que a
expressão `match` fica um pouco verbosa.

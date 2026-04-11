## Variáveis e Mutabilidade

Como mencionado na seção [“Armazenando valores com
variáveis”][storing-values-with-variables]<!-- ignore -->, por padrão, as
variáveis são imutáveis. Esse é um dos vários empurrões que o Rust dá para que
você escreva código tirando proveito da segurança e da facilidade de
concorrência que a linguagem oferece. Ainda assim, você continua tendo a opção
de tornar suas variáveis mutáveis. Vamos explorar como e por que Rust incentiva
você a preferir a imutabilidade e por que, às vezes, pode fazer sentido abrir
mão disso.

Quando uma variável é imutável, depois que um valor é associado a um nome, você
não pode alterar esse valor. Para ilustrar isso, gere um novo projeto chamado
_variables_ dentro do diretório _projects_ usando `cargo new variables`.

Depois, no novo diretório _variables_, abra _src/main.rs_ e substitua seu
código pelo seguinte, que ainda não compilará:

<span class="filename">Filename: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-01-variables-are-immutable/src/main.rs}}
```

Salve e execute o programa com `cargo run`. Você deverá receber uma mensagem de
erro sobre imutabilidade, como mostrado nesta saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-01-variables-are-immutable/output.txt}}
```

Este exemplo mostra como o compilador ajuda você a encontrar erros em seus
programas. Erros de compilação podem ser frustrantes, mas, na verdade, eles só
significam que seu programa ainda não está fazendo com segurança aquilo que
você quer; eles _não_ significam que você é um mau programador! Rustaceans
experientes também recebem erros do compilador.

Você recebeu a mensagem de erro `` cannot assign twice to immutable variable
`x` `` porque tentou atribuir um segundo valor à variável imutável `x`.

É importante recebermos erros em tempo de compilação quando tentamos mudar um
valor marcado como imutável, porque exatamente esse tipo de situação pode levar
a bugs. Se uma parte do código opera supondo que um valor nunca vai mudar e
outra parte muda esse valor, é possível que a primeira parte do código não faça
o que foi projetada para fazer. A causa desse tipo de bug pode ser difícil de
rastrear depois, principalmente quando a segunda parte do código muda o valor
apenas _às vezes_. O compilador Rust garante que, quando você afirma que um
valor não vai mudar, ele realmente não vai mudar, então você não precisa ficar
acompanhando isso manualmente. Isso torna o código mais fácil de entender.

Mas a mutabilidade pode ser muito útil e pode tornar o código mais prático de
escrever. Embora as variáveis sejam imutáveis por padrão, você pode torná-las
mutáveis adicionando `mut` antes do nome da variável, como fez no [Capítulo
2][storing-values-with-variables]<!-- ignore -->. Adicionar `mut` também
comunica intenção a futuras pessoas leitoras do código, indicando que outras
partes do programa mudarão o valor dessa variável.

Por exemplo, vamos mudar _src/main.rs_ para o seguinte:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-02-adding-mut/src/main.rs}}
```

Quando executamos o programa agora, obtemos isto:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-02-adding-mut/output.txt}}
```

Temos permissão para mudar o valor associado a `x` de `5` para `6` quando
`mut` é usado. No fim das contas, decidir usar mutabilidade ou não depende de
você e do que parecer mais claro naquela situação específica.

<!-- Old headings. Do not remove or links may break. -->
<a id="constants"></a>

### Declarando constantes

Assim como variáveis imutáveis, _constantes_ são valores associados a um nome e
que não podem mudar, mas há algumas diferenças entre constantes e variáveis.

Primeiro, não é permitido usar `mut` com constantes. Constantes não são apenas
imutáveis por padrão, elas são sempre imutáveis. Você declara constantes usando
a palavra-chave `const` em vez de `let`, e o tipo do valor _deve_ ser anotado.
Falaremos sobre tipos e anotações de tipo na próxima seção,
[“Tipos de dados”][data-types]<!-- ignore -->, então não se preocupe com os
detalhes agora. Só saiba que você sempre precisa anotar o tipo.

Constantes podem ser declaradas em qualquer escopo, inclusive no escopo
global, o que as torna úteis para valores que muitas partes do código precisam
conhecer.

A última diferença é que constantes só podem ser definidas como expressões
constantes, e não como o resultado de um valor que só poderia ser calculado em
tempo de execução.

Aqui está um exemplo de declaração de constante:

```rust
const THREE_HOURS_IN_SECONDS: u32 = 60 * 60 * 3;
```

O nome da constante é `THREE_HOURS_IN_SECONDS`, e seu valor é o resultado da
multiplicação de 60, o número de segundos em um minuto, por 60, o número de
minutos em uma hora, por 3, o número de horas que queremos contar neste
programa. A convenção de nomenclatura do Rust para constantes é usar somente
maiúsculas, com underscores entre as palavras. O compilador consegue avaliar um
conjunto limitado de operações em tempo de compilação, o que nos permite
escrever esse valor de uma forma mais fácil de entender e verificar, em vez de
definir a constante diretamente como 10.800. Veja a [seção do Rust Reference
sobre avaliação de constantes][const-eval] para mais informações sobre as
operações que podem ser usadas ao declarar constantes.

Constantes são válidas durante todo o tempo de execução do programa, dentro do
escopo em que foram declaradas. Essa propriedade as torna úteis para valores do
domínio da sua aplicação que múltiplas partes do programa talvez precisem
conhecer, como o número máximo de pontos que qualquer jogador de um jogo pode
ganhar ou a velocidade da luz.

Dar nome de constantes a valores hardcoded usados ao longo do programa é útil
para transmitir o significado desse valor a futuras pessoas mantenedoras do
código. Isso também ajuda a ter apenas um lugar no código que precisará ser
alterado se o valor hardcoded tiver de ser atualizado no futuro.

### Shadowing

Como você viu no tutorial do jogo de adivinhação no [Capítulo
2][comparing-the-guess-to-the-secret-number]<!-- ignore -->, você pode declarar
uma nova variável com o mesmo nome de uma variável anterior. Rustaceans dizem
que a primeira variável é _shadowed_ pela segunda, o que significa que a
segunda variável é aquela que o compilador verá quando você usar aquele nome.
Na prática, a segunda variável encobre a primeira, e qualquer uso desse nome se
refere a ela até que ela própria seja shadowed ou até que o escopo termine.
Podemos fazer shadowing de uma variável repetindo o mesmo nome e usando
novamente a palavra-chave `let`, assim:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-03-shadowing/src/main.rs}}
```

Este programa primeiro associa `x` ao valor `5`. Em seguida, cria uma nova
variável `x` repetindo `let x =`, pegando o valor original e somando `1`, de
modo que `x` passa a valer `6`. Depois, dentro de um escopo interno criado com
chaves, a terceira instrução `let` também faz shadowing de `x` e cria uma nova
variável, multiplicando o valor anterior por `2`, o que faz `x` valer `12`.
Quando esse escopo termina, o shadowing interno acaba, e `x` volta a valer
`6`. Quando executamos esse programa, ele produz a seguinte saída:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-03-shadowing/output.txt}}
```

Shadowing é diferente de marcar uma variável com `mut`, porque receberemos um
erro em tempo de compilação se, por engano, tentarmos reatribuir um valor a
essa variável sem usar a palavra-chave `let`. Ao usar `let`, podemos realizar
algumas transformações sobre um valor, mas fazer com que a variável seja
imutável depois que essas transformações terminarem.

A outra diferença entre `mut` e shadowing é que, como estamos efetivamente
criando uma nova variável quando usamos `let` de novo, podemos mudar o tipo do
valor e ainda reutilizar o mesmo nome. Por exemplo, suponha que nosso programa
peça a uma pessoa usuária que informe quantos espaços quer entre certos textos,
digitando caracteres de espaço, e depois queiramos armazenar essa entrada como
um número:

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-04-shadowing-can-change-types/src/main.rs:here}}
```

A primeira variável `spaces` é do tipo string, e a segunda variável `spaces` é
do tipo numérico. Shadowing nos poupa de precisar inventar nomes diferentes,
como `spaces_str` e `spaces_num`; em vez disso, podemos reutilizar o nome mais
simples `spaces`. No entanto, se tentarmos usar `mut` para isso, como mostrado
aqui, receberemos um erro em tempo de compilação:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-05-mut-cant-change-types/src/main.rs:here}}
```

O erro diz que não temos permissão para mudar o tipo de uma variável:

```console
{{#include ../listings/ch03-common-programming-concepts/no-listing-05-mut-cant-change-types/output.txt}}
```

Agora que exploramos como as variáveis funcionam, vamos ver mais tipos de dados
que elas podem assumir.

[comparing-the-guess-to-the-secret-number]: ch02-00-guessing-game-tutorial.html#comparing-the-guess-to-the-secret-number
[data-types]: ch03-02-data-types.html#tipos-de-dados
[storing-values-with-variables]: ch02-00-guessing-game-tutorial.html#armazenando-valores-com-variáveis
[const-eval]: ../reference/const_eval.html

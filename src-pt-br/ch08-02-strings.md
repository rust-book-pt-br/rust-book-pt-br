## Armazenando texto codificado em UTF-8 com strings

Falamos sobre strings no Capítulo 4, mas agora vamos examiná-las com mais
profundidade. Pessoas novas em Rust frequentemente travam em strings por uma
combinação de três razões: a tendência de Rust a expor erros possíveis, o fato
de strings serem uma estrutura de dados mais complexa do que muita gente
imagina e o UTF-8. Esses fatores se combinam de um jeito que pode parecer
difícil para quem vem de outras linguagens de programação.

Discutimos strings no contexto de coleções porque strings são implementadas como
uma coleção de bytes, junto com alguns métodos que fornecem funcionalidades
úteis quando esses bytes são interpretados como texto. Nesta seção, falaremos
sobre as operações em `String` que todo tipo de coleção possui, como criar,
atualizar e ler. Também discutiremos as maneiras pelas quais `String` difere
das outras coleções, especialmente como a indexação em `String` é complicada
pelas diferenças entre a forma como pessoas e computadores interpretam dados de
`String`.

<!-- Old headings. Do not remove or links may break. -->

<a id="what-is-a-string"></a>

### Definindo strings

Primeiro, vamos definir o que queremos dizer com o termo _string_. Rust tem
apenas um tipo de string no núcleo da linguagem, que é o string slice `str`,
geralmente visto em sua forma emprestada, `&str`. No Capítulo 4, falamos sobre
string slices, que são referências a dados de string codificados em UTF-8
armazenados em algum outro lugar. Literais de string, por exemplo, ficam
armazenados no binário do programa e, portanto, são string slices.

O tipo `String`, fornecido pela biblioteca padrão de Rust em vez de fazer parte
do núcleo da linguagem, é um tipo de string expansível, mutável, com ownership
e codificado em UTF-8. Quando pessoas da comunidade Rust se referem a
“strings” em Rust, podem estar falando tanto do tipo `String` quanto do tipo
string slice `&str`, e não apenas de um deles. Embora esta seção trate
principalmente de `String`, os dois tipos são bastante usados na biblioteca
padrão de Rust, e tanto `String` quanto string slices são codificados em UTF-8.

### Criando uma nova string

Muitas das mesmas operações disponíveis para `Vec<T>` também estão disponíveis
para `String`, porque `String` é implementada como um invólucro em torno de um
vetor de bytes com algumas garantias, restrições e capacidades extras. Um
exemplo de função que funciona da mesma forma em `Vec<T>` e em `String` é a
função `new`, usada para criar uma instância, como mostra a Listagem 8-11.

<Listing number="8-11" caption="Criando uma `String` nova e vazia">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-11/src/main.rs:here}}
```

</Listing>

Essa linha cria uma nova string vazia chamada `s`, na qual depois podemos
colocar dados. Muitas vezes, no entanto, já teremos alguns dados iniciais com
os quais queremos começar a string. Para isso, usamos o método `to_string`,
disponível em qualquer tipo que implemente a trait `Display`, como é o caso dos
literais de string. A Listagem 8-12 mostra dois exemplos.

<Listing number="8-12" caption="Usando o método `to_string` para criar uma `String` a partir de um literal de string">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-12/src/main.rs:here}}
```

</Listing>

Esse código cria uma string contendo `initial contents`.

Também podemos usar a função `String::from` para criar uma `String` a partir de
um literal de string. O código da Listagem 8-13 é equivalente ao código da
Listagem 8-12 que usa `to_string`.

<Listing number="8-13" caption="Usando a função `String::from` para criar uma `String` a partir de um literal de string">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-13/src/main.rs:here}}
```

</Listing>

Como strings são usadas para muitas coisas, podemos usar muitas APIs genéricas
diferentes para elas, o que nos dá bastante opção. Algumas podem parecer
redundantes, mas todas têm seu lugar! Neste caso, `String::from` e
`to_string` fazem a mesma coisa, então escolher entre uma e outra é uma questão
de estilo e legibilidade.

Lembre-se de que strings são codificadas em UTF-8, então podemos incluir nelas
quaisquer dados corretamente codificados, como mostra a Listagem 8-14.

<Listing number="8-14" caption="Armazenando saudações em diferentes idiomas em strings">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-14/src/main.rs:here}}
```

</Listing>

Todos esses são valores válidos de `String`.

### Atualizando uma string

Uma `String` pode crescer de tamanho e seu conteúdo pode mudar, assim como o
conteúdo de um `Vec<T>` muda se você empurrar mais dados para dentro dele. Além
disso, também podemos usar convenientemente o operador `+` ou a macro
`format!` para concatenar valores de `String`.

<!-- Old headings. Do not remove or links may break. -->

<a id="appending-to-a-string-with-push_str-and-push"></a>

#### Anexando com `push_str` ou `push`

Podemos fazer uma `String` crescer usando o método `push_str` para anexar um
string slice, como mostra a Listagem 8-15.

<Listing number="8-15" caption="Anexando um string slice a uma `String` usando o método `push_str`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-15/src/main.rs:here}}
```

</Listing>

Depois dessas duas linhas, `s` conterá `foobar`. O método `push_str` recebe um
string slice porque não queremos necessariamente tomar ownership do parâmetro.
Por exemplo, no código da Listagem 8-16, queremos continuar podendo usar `s2`
mesmo depois de anexar seu conteúdo a `s1`.

<Listing number="8-16" caption="Usando um string slice depois de anexar seu conteúdo a uma `String`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-16/src/main.rs:here}}
```

</Listing>

Se o método `push_str` tomasse ownership de `s2`, não poderíamos imprimir seu
valor na última linha. No entanto, esse código funciona exatamente como
esperávamos!

O método `push` recebe um único caractere como parâmetro e o adiciona à
`String`. A Listagem 8-17 adiciona a letra _l_ a uma `String` usando o método
`push`.

<Listing number="8-17" caption="Adicionando um único caractere a uma `String` com `push`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-17/src/main.rs:here}}
```

</Listing>

Como resultado, `s` conterá `lol`.

<!-- Old headings. Do not remove or links may break. -->

<a id="concatenation-with-the--operator-or-the-format-macro"></a>

#### Concatenando com `+` ou `format!`

Frequentemente você vai querer combinar duas strings existentes. Uma forma de
fazer isso é usar o operador `+`, como mostra a Listagem 8-18.

<Listing number="8-18" caption="Usando o operador `+` para combinar dois valores `String` em um novo valor `String`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-18/src/main.rs:here}}
```

</Listing>

A string `s3` conterá `Hello, world!`. O motivo pelo qual `s1` deixa de ser
válida após a adição, e o motivo pelo qual usamos uma referência para `s2`, têm
a ver com a assinatura do método chamado quando usamos o operador `+`. O
operador `+` usa o método `add`, cuja assinatura se parece com isto:

```rust,ignore
fn add(self, s: &str) -> String {
```

Na biblioteca padrão, você verá `add` definido usando genéricos e tipos
associados. Aqui, substituímos isso por tipos concretos, que é o que acontece
quando chamamos esse método com valores `String`. Veremos genéricos no Capítulo
10. Essa assinatura já nos dá as pistas necessárias para entender as partes
mais complicadas do operador `+`.

Primeiro, `s2` tem um `&`, o que significa que estamos adicionando uma
referência da segunda string à primeira string. Isso acontece por causa do
parâmetro `s` na função `add`: só podemos adicionar um string slice a uma
`String`; não podemos somar diretamente dois valores `String`. Mas espere: o
tipo de `&s2` é `&String`, não `&str`, como especificado no segundo parâmetro
de `add`. Então por que a Listagem 8-18 compila?

A razão pela qual conseguimos usar `&s2` na chamada a `add` é que o compilador
pode coagir o argumento `&String` para `&str`. Quando chamamos o método `add`,
Rust usa uma coerção de deref, que aqui transforma `&s2` em `&s2[..]`.
Falaremos sobre coerção de deref com mais profundidade no Capítulo 15. Como
`add` não toma ownership do parâmetro `s`, `s2` continuará sendo uma `String`
válida depois dessa operação.

Em segundo lugar, podemos ver na assinatura que `add` toma ownership de `self`
porque `self` _não_ tem `&`. Isso significa que `s1`, na Listagem 8-18, será
movida para a chamada de `add` e não será mais válida depois disso. Então,
embora `let s3 = s1 + &s2;` pareça que vai copiar as duas strings e criar uma
nova, essa instrução, na verdade, toma ownership de `s1`, anexa uma cópia do
conteúdo de `s2` e então devolve ownership do resultado. Em outras palavras,
parece que está fazendo muitas cópias, mas não está; a implementação é mais
eficiente do que copiar.

Se precisarmos concatenar várias strings, o comportamento do operador `+` fica
difícil de lidar:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/no-listing-01-concat-multiple-strings/src/main.rs:here}}
```

Nesse ponto, `s` será `tic-tac-toe`. Com todos os caracteres `+` e `"`, fica
difícil enxergar o que está acontecendo. Para combinar strings de formas mais
complicadas, podemos usar a macro `format!`:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/no-listing-02-format/src/main.rs:here}}
```

Esse código também define `s` como `tic-tac-toe`. A macro `format!` funciona
como `println!`, mas, em vez de imprimir a saída na tela, ela retorna uma
`String` com o conteúdo. A versão do código que usa `format!` é bem mais fácil
de ler, e o código gerado por `format!` usa referências, de modo que essa
chamada não toma ownership de nenhum de seus parâmetros.

### Indexando strings

Em muitas outras linguagens de programação, acessar caracteres individuais de
uma string por índice é uma operação válida e comum. No entanto, se você tentar
acessar partes de uma `String` com sintaxe de indexação em Rust, receberá um
erro. Considere o código inválido da Listagem 8-19.

<Listing number="8-19" caption="Tentando usar sintaxe de indexação com uma `String`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-19/src/main.rs:here}}
```

</Listing>

Esse código produzirá o seguinte erro:

```console
{{#include ../listings/ch08-common-collections/listing-08-19/output.txt}}
```

A mensagem de erro conta a história: strings em Rust não dão suporte a
indexação. Mas por que não? Para responder a essa pergunta, precisamos
discutir como Rust armazena strings na memória.

#### Representação interna

Uma `String` é um invólucro sobre um `Vec<u8>`. Vamos olhar novamente para
algumas das strings de exemplo codificadas corretamente em UTF-8 da Listagem
8-14. Primeiro, esta aqui:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-14/src/main.rs:spanish}}
```

Nesse caso, `len` será `4`, o que significa que o vetor que armazena a string
`"Hola"` tem 4 bytes de comprimento. Cada uma dessas letras ocupa 1 byte quando
codificada em UTF-8. Já a linha a seguir pode surpreender você; observe que
essa string começa com a letra cirílica maiúscula _Ze_, e não com o número 3:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-14/src/main.rs:russian}}
```

Se alguém perguntasse o comprimento dessa string, você talvez dissesse 12. Na
verdade, a resposta de Rust é 24: esse é o número de bytes necessários para
codificar “Здравствуйте” em UTF-8, porque cada valor escalar Unicode nessa
string ocupa 2 bytes de armazenamento. Portanto, um índice nos bytes da string
nem sempre corresponderá a um valor escalar Unicode válido. Para demonstrar,
considere este código Rust inválido:

```rust,ignore,does_not_compile
let hello = "Здравствуйте";
let answer = &hello[0];
```

Você já sabe que `answer` não será `З`, a primeira letra. Quando codificado em
UTF-8, o primeiro byte de `З` é `208` e o segundo é `151`, então poderia
parecer que `answer` deveria ser `208`, mas `208` não é um caractere válido por
si só. Retornar `208` provavelmente não é o que uma pessoa desejaria se
pedisse a primeira letra dessa string; no entanto, esse é o único dado que Rust
tem no índice de byte 0. Em geral, quem usa o programa não quer receber o
valor do byte, mesmo quando a string contém apenas letras latinas: se
`&"hi"[0]` fosse um código válido que retornasse o valor do byte, ele
retornaria `104`, e não `h`.

A resposta, então, é que, para evitar retornar um valor inesperado e causar
bugs que talvez não fossem descobertos imediatamente, Rust simplesmente não
compila esse código, evitando mal-entendidos logo no início do processo de
desenvolvimento.

<!-- Old headings. Do not remove or links may break. -->

<a id="bytes-and-scalar-values-and-grapheme-clusters-oh-my"></a>

#### Bytes, valores escalares e clusters de grafemas

Outro ponto sobre UTF-8 é que existem, na verdade, três formas relevantes de
olhar para strings do ponto de vista de Rust: como bytes, como valores
escalares e como clusters de grafemas, que são a coisa mais próxima do que
chamaríamos de _letras_.

Se olharmos para a palavra hindi “नमस्ते”, escrita na escrita devanágari, ela é
armazenada como um vetor de valores `u8` que se parece com isto:

```text
[224, 164, 168, 224, 164, 174, 224, 164, 184, 224, 165, 141, 224, 164, 164,
224, 165, 135]
```

Isso representa 18 bytes e é a forma como os computadores armazenam esses
dados em última instância. Se olharmos para esses dados como valores escalares
Unicode, que é o que o tipo `char` de Rust representa, esses bytes ficam assim:

```text
['न', 'म', 'स', '्', 'त', 'े']
```

Temos aqui seis valores `char`, mas o quarto e o sexto não são letras: são
marcas diacríticas que não fazem sentido sozinhas. Por fim, se olharmos para
isso como clusters de grafemas, obteremos o que uma pessoa consideraria as
quatro letras que formam a palavra hindi:

```text
["न", "म", "स्", "ते"]
```

Rust oferece formas diferentes de interpretar os dados brutos de string que os
computadores armazenam, para que cada programa possa escolher a interpretação
de que precisa, independentemente da linguagem humana em que os dados estejam.

Um último motivo pelo qual Rust não nos permite indexar uma `String` para obter
um caractere é que se espera que operações de indexação sempre levem tempo
constante, O(1). Mas não é possível garantir esse desempenho com uma `String`,
porque Rust teria de percorrer o conteúdo desde o começo até o índice para
determinar quantos caracteres válidos existem ali.

### Fatiando strings

Indexar uma string costuma ser uma má ideia porque não está claro qual deveria
ser o tipo de retorno da operação de indexação: um valor de byte, um
caractere, um cluster de grafemas ou um string slice. Por isso, se você
realmente precisa usar índices para criar string slices, Rust exige que você
seja mais específico.

Em vez de indexar usando `[]` com um único número, você pode usar `[]` com um
intervalo para criar um string slice contendo bytes específicos:

```rust
let hello = "Здравствуйте";

let s = &hello[0..4];
```

Aqui, `s` será um `&str` que contém os primeiros 4 bytes da string. Antes,
mencionamos que cada um desses caracteres tinha 2 bytes, o que significa que
`s` será `Зд`.

Se tentássemos fatiar apenas parte dos bytes de um caractere com algo como
`&hello[0..1]`, Rust entraria em pânico em tempo de execução, da mesma forma
que faz quando acessamos um índice inválido em um vetor:

```console
{{#include ../listings/ch08-common-collections/output-only-01-not-char-boundary/output.txt}}
```

Você deve tomar cuidado ao criar string slices com intervalos, porque isso pode
fazer seu programa travar.

<!-- Old headings. Do not remove or links may break. -->

<a id="methods-for-iterating-over-strings"></a>

### Iterando sobre strings

A melhor maneira de operar sobre partes de strings é ser explícito sobre se
você quer caracteres ou bytes. Para valores escalares Unicode individuais, use
o método `chars`. Chamar `chars` sobre “Зд” separa e retorna dois valores do
tipo `char`, e você pode iterar sobre o resultado para acessar cada elemento:

```rust
for c in "Зд".chars() {
    println!("{c}");
}
```

Esse código imprimirá o seguinte:

```text
З
д
```

Como alternativa, o método `bytes` retorna cada byte bruto, o que pode ser o
mais apropriado para o seu domínio:

```rust
for b in "Зд".bytes() {
    println!("{b}");
}
```

Esse código imprimirá os 4 bytes que compõem essa string:

```text
208
151
208
180
```

Mas lembre-se sempre de que valores escalares Unicode válidos podem ser
compostos de mais de 1 byte.

Obter clusters de grafemas a partir de strings, como acontece com a escrita
devanágari, é algo complexo, então essa funcionalidade não é fornecida pela
biblioteca padrão. Há crates disponíveis em
[crates.io](https://crates.io/)<!-- ignore --> caso isso seja a funcionalidade
de que você precisa.

<!-- Old headings. Do not remove or links may break. -->

<a id="strings-are-not-so-simple"></a>

### Lidando com as complexidades das strings

Resumindo, strings são complicadas. Diferentes linguagens de programação fazem
escolhas diferentes sobre como apresentar essa complexidade para quem programa.
Rust escolheu tornar o tratamento correto de dados `String` o comportamento
padrão de todos os programas Rust, o que significa que programadores precisam
pensar mais cedo sobre como lidar com dados UTF-8. Essa troca expõe mais da
complexidade das strings do que fica aparente em outras linguagens, mas evita
que você tenha de lidar, mais tarde no ciclo de desenvolvimento, com erros
envolvendo caracteres não ASCII.

A boa notícia é que a biblioteca padrão oferece bastante funcionalidade
construída sobre os tipos `String` e `&str` para ajudar a tratar corretamente
essas situações complexas. Não deixe de consultar a documentação de métodos
úteis como `contains`, para procurar em uma string, e `replace`, para
substituir partes de uma string por outra.

Vamos mudar para algo um pouco menos complexo: hash maps!

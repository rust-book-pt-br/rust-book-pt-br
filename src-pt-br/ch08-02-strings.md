## Armazenando texto codificado em UTF-8 com strings

Falamos sobre strings no Capítulo 4, mas vamos examiná-las com mais profundidade agora.
Novos Rustáceos geralmente ficam presos em cordas por uma combinação de três
razões: a propensão do Rust em expor possíveis erros, sendo as strings uma forma mais
estrutura de dados complicada que muitos programadores atribuem a eles, e
UTF-8. Esses fatores se combinam de uma forma que pode parecer difícil quando você está
vindo de outras linguagens de programação.

Discutimos strings no contexto de coleções porque strings são
implementado como uma coleção de bytes, além de alguns métodos para fornecer informações úteis
funcionalidade quando esses bytes são interpretados como texto. Nesta seção, vamos
fale sobre as operações em `String` que todo tipo de coleção possui, como
criação, atualização e leitura. Também discutiremos as maneiras pelas quais `String`
é diferente das outras coleções, ou seja, como a indexação em `String` é
complicado pelas diferenças entre como as pessoas e os computadores interpretam
`String` dados.

<!-- Old headings. Do not remove or links may break. -->

<a id="what-is-a-string"></a>

### Definindo Strings

Primeiro definiremos o que queremos dizer com o termo _string_. Rust tem apenas uma string
digite a linguagem principal, que é a fatia de string `str` que geralmente é vista
em sua forma emprestada, `&str`. No Capítulo 4, falamos sobre fatias de string,
que são referências a alguns dados de string codificados em UTF-8 armazenados em outro lugar. Corda
literais, por exemplo, são armazenados no binário do programa e, portanto,
fatias de corda.

O tipo `String`, que é fornecido pela biblioteca padrão do Rust em vez de
codificado na linguagem principal, é um ambiente expansível, mutável, de propriedade e codificado em UTF-8.
tipo de string. Quando Rustáceos se referem a “cordas” em Rust, eles podem ser
referindo-se aos tipos `String` ou string slice `&str`, não apenas a um
desses tipos. Embora esta seção seja principalmente sobre `String`, ambos os tipos são
muito usado na biblioteca padrão do Rust, e `String` e fatias de string
são codificados em UTF-8.

### Criando uma nova string

Muitas das mesmas operações disponíveis com `Vec<T>` estão disponíveis com `String`
também porque `String` é na verdade implementado como um wrapper em torno de um vetor
de bytes com algumas garantias, restrições e recursos extras. Um exemplo
de uma função que funciona da mesma maneira com `Vec<T>` e `String` é o `new`
função para criar uma instância, mostrada na Listagem 8-11.

<Listing number="8-11" caption="Creating a new, empty `String`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-11/src/main.rs:here}}
```

</Listing>

Esta linha cria uma nova string vazia chamada `s`, na qual podemos carregar
dados. Muitas vezes, teremos alguns dados iniciais com os quais queremos iniciar o
corda. Para isso utilizamos o método `to_string`, que está disponível em qualquer tipo
que implementa o traço `Display`, como fazem os literais de string. Listagem de 8 a 12 programas
dois exemplos.

<Listing number="8-12" caption="Using the `to_string` method to create a `String` from a string literal">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-12/src/main.rs:here}}
```

</Listing>

Este código cria uma string contendo `initial contents`.

Também podemos usar a função `String::from` para criar um `String` a partir de uma string
literal. O código na Listagem 8-13 é equivalente ao código na Listagem 8-12
que usa `to_string`.

<Listing number="8-13" caption="Using the `String::from` function to create a `String` from a string literal">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-13/src/main.rs:here}}
```

</Listing>

Como as strings são usadas para muitas coisas, podemos usar muitos tipos genéricos diferentes.
APIs para strings, nos fornecendo muitas opções. Alguns deles podem parecer
redundantes, mas todos têm o seu lugar! Neste caso, `String::from` e
`to_string` faça a mesma coisa, então qual você escolhe é uma questão de estilo e
legibilidade.

Lembre-se de que as strings são codificadas em UTF-8, portanto, podemos incluir qualquer string codificada corretamente.
dados neles, conforme mostrado na Listagem 8-14.

<Listing number="8-14" caption="Storing greetings in different languages in strings">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-14/src/main.rs:here}}
```

</Listing>

Todos esses são valores `String` válidos.

### Atualizando uma String

Um `String` pode aumentar de tamanho e seu conteúdo pode mudar, assim como o conteúdo
de um `Vec<T>`, se você inserir mais dados nele. Além disso, você pode convenientemente
use o operador `+` ou a macro `format!` para concatenar valores `String`.

<!-- Old headings. Do not remove or links may break. -->

<a id="appending-to-a-string-with-push_str-and-push"></a>

#### Anexando com `push_str` ou `push`

Podemos aumentar um `String` usando o método `push_str` para anexar uma fatia de string,
conforme mostrado na Listagem 8-15.

<Listing number="8-15" caption="Appending a string slice to a `String` using the `push_str` method">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-15/src/main.rs:here}}
```

</Listing>

Após essas duas linhas, `s` conterá `foobar`. O método `push_str` leva um
fatia de string porque não queremos necessariamente nos apropriar do
parâmetro. Por exemplo, no código da Listagem 8.16, queremos poder usar
`s2` após anexar seu conteúdo a `s1`.

<Listing number="8-16" caption="Using a string slice after appending its contents to a `String`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-16/src/main.rs:here}}
```

</Listing>

Se o método `push_str` se apropriasse de `s2`, não poderíamos imprimir
seu valor na última linha. No entanto, este código funciona como esperávamos!

O método `push` pega um único caractere como parâmetro e o adiciona ao
`String`. A Listagem 8-17 adiciona a letra _l_ a `String` usando o `push`
método.

<Listing number="8-17" caption="Adding one character to a `String` value using `push`">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-17/src/main.rs:here}}
```

</Listing>

Como resultado, `s` conterá `lol`.

<!-- Old headings. Do not remove or links may break. -->

<a id="concatenation-with-the--operator-or-the-format-macro"></a>

#### Concatenando com `+` ou `format!`

Freqüentemente, você desejará combinar duas strings existentes. Uma maneira de fazer isso é usar
o operador `+`, conforme mostrado na Listagem 8-18.

<Listing number="8-18" caption="Using the `+` operator to combine two `String` values into a new `String` value">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-18/src/main.rs:here}}
```

</Listing>

A string `s3` conterá `Hello, world!`. A razão pela qual `s1` não é mais
válido após a adição, e a razão pela qual usamos uma referência para `s2`, tem a ver
com a assinatura do método que é chamado quando usamos o operador `+`.
O operador `+` usa o método `add`, cuja assinatura se parece com
esse:

```rust,ignore
fn add(self, s: &str) -> String {
```

Na biblioteca padrão, você verá `add` definido usando genéricos e associados
tipos. Aqui, substituímos por tipos concretos, que é o que acontece quando
chame esse método com valores `String`. Discutiremos genéricos no Capítulo 10.
Esta assinatura nos dá as pistas que precisamos para entender o complicado
bits do operador `+`.

Primeiro, `s2` tem `&`, o que significa que estamos adicionando uma referência do segundo
string para a primeira string. Isso ocorre por causa do parâmetro `s` no `add`
função: Só podemos adicionar uma fatia de string a `String`; não podemos adicionar dois
`String` valores juntos. Mas espere – o tipo de `&s2` é `&String`, não `&str`,
conforme especificado no segundo parâmetro para `add`. Então, por que a Listagem 8-18
compilar?

A razão pela qual podemos usar `&s2` na chamada para `add` é que o compilador
pode forçar o argumento `&String` em `&str`. Quando chamamos o método `add`,
Rust usa uma coerção deref, que aqui transforma `&s2` em `&s2[..]`. Bem
discuta a coerção deref com mais profundidade no Capítulo 15. Porque `add` não leva
propriedade do parâmetro `s`, `s2` ainda será um `String` válido depois disso
operação.

Em segundo lugar, podemos ver na assinatura que `add` assume a propriedade de `self`
porque `self` _não_ tem `&`. Isso significa que `s1` na Listagem 8-18 será
movido para a chamada `add` e não será mais válido depois disso. Então, embora
`let s3 = s1 + &s2;` parece que copiará as duas strings e criará uma nova,
esta declaração na verdade é propriedade de `s1`, anexa uma cópia do conteúdo
de `s2` e, em seguida, retorna a propriedade do resultado. Em outras palavras, parece
como se estivesse fazendo muitas cópias, mas não está; a implementação é mais
eficiente do que copiar.

Se precisarmos concatenar múltiplas strings, o comportamento do operador `+`
fica pesado:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/no-listing-01-concat-multiple-strings/src/main.rs:here}}
```

Neste ponto, `s` será `tic-tac-toe`. Com todos os `+` e `"`
personagens, é difícil ver o que está acontecendo. Para combinar strings em
maneiras mais complicadas, podemos usar a macro `format!`:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/no-listing-02-format/src/main.rs:here}}
```

Este código também define `s` como `tic-tac-toe`. A macro `format!` funciona como
`println!`, mas em vez de imprimir a saída na tela, ele retorna um
`String` com o conteúdo. A versão do código usando `format!` é muito
mais fácil de ler, e o código gerado pela macro `format!` usa referências
para que esta chamada não se aproprie de nenhum de seus parâmetros.

### Indexação em Strings

Em muitas outras linguagens de programação, acessar caracteres individuais em um
string referenciando-os por índice é uma operação válida e comum. No entanto,
se você tentar acessar partes de `String` usando sintaxe de indexação em Rust, você
obter um erro. Considere o código inválido na Listagem 8-19.

<Listing number="8-19" caption="Attempting to use indexing syntax with a `String`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-19/src/main.rs:here}}
```

</Listing>

Este código resultará no seguinte erro:

```console
{{#include ../listings/ch08-common-collections/listing-08-19/output.txt}}
```

O erro conta a história: Strings Rust não suportam indexação. Mas por que não? Para
Para responder a essa pergunta, precisamos discutir como Rust armazena strings na memória.

#### Representação Interna

Um `String` é um wrapper sobre um `Vec<u8>`. Vejamos alguns dos nossos
strings de exemplo UTF-8 codificadas da Listagem 8-14. Primeiro, este:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-14/src/main.rs:spanish}}
```

Neste caso, `len` será `4`, o que significa o vetor que armazena a string
`"Hola"` tem 4 bytes de comprimento. Cada uma dessas letras ocupa 1 byte quando codificada em
UTF-8. A linha a seguir, entretanto, pode surpreendê-lo (observe que esta string
começa com a letra cirílica maiúscula _Ze_, não com o número 3):

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-14/src/main.rs:russian}}
```

Se lhe perguntassem qual é o comprimento da corda, você poderia dizer 12. Na verdade, Rust's
a resposta é 24: Esse é o número de bytes necessários para codificar “Здравствуйте” em
UTF-8, porque cada valor escalar Unicode nessa string ocupa 2 bytes de
armazenar. Portanto, um índice nos bytes da string nem sempre estará correlacionado
para um valor escalar Unicode válido. Para demonstrar, considere este Rust inválido
código:

```rust,ignore,does_not_compile
let hello = "Здравствуйте";
let answer = &hello[0];
```

Você já sabe que `answer` não será `З`, a primeira letra. Quando codificado
em UTF-8, o primeiro byte de `З` é `208` e o segundo é `151`, então seria
parece que `answer` deveria de fato ser `208`, mas `208` não é um caractere válido
por conta própria. Retornar `208` provavelmente não é o que um usuário desejaria se perguntasse
para a primeira letra desta string; no entanto, esses são os únicos dados que Rust
tem índice de bytes 0. Os usuários geralmente não querem que o valor do byte seja retornado, mesmo
se a string contiver apenas letras latinas: Se `&"hi"[0]` fosse um código válido que
retornasse o valor do byte, retornaria `104`, não `h`.

A resposta, então, é evitar retornar um valor inesperado e causar
bugs que podem não ser descobertos imediatamente, Rust não compila este código
e evita mal-entendidos no início do processo de desenvolvimento.

<!-- Old headings. Do not remove or links may break. -->

<a id="bytes-and-scalar-values-and-grapheme-clusters-oh-my"></a>

#### Bytes, valores escalares e clusters de grafemas

Outro ponto sobre o UTF-8 é que na verdade existem três maneiras relevantes de
observe as strings da perspectiva de Rust: como bytes, valores escalares e grafema
clusters (a coisa mais próxima do que chamaríamos de _letras_).

Se olharmos para a palavra Hindi “नमस्ते” escrita na escrita Devanagari, é
armazenado como um vetor de valores `u8` semelhante a este:

```text
[224, 164, 168, 224, 164, 174, 224, 164, 184, 224, 165, 141, 224, 164, 164,
224, 165, 135]
```

São 18 bytes e é como os computadores armazenam esses dados. Se olharmos
eles como valores escalares Unicode, que são o tipo `char` de Rust, aqueles
bytes ficam assim:

```text
['न', 'म', 'स', '्', 'त', 'े']
```

Existem seis valores `char` aqui, mas o quarto e o sexto não são letras:
Eles são diacríticos que não fazem sentido por si só. Finalmente, se olharmos
agrupando-os como aglomerados de grafemas, obteríamos o que uma pessoa chamaria de quatro letras
que compõem a palavra Hindi:

```text
["न", "म", "स्", "ते"]
```

Rust fornece diferentes maneiras de interpretar os dados brutos de string que os computadores
armazenar para que cada programa possa escolher a interpretação que necessita, não importa
em que linguagem humana os dados estão.

Uma última razão pela qual Rust não nos permite indexar em `String` para obter um
caráter é que se espera que as operações de indexação sempre levem tempo constante
(O(1)). Mas não é possível garantir esse desempenho com um `String`,
porque Rust teria que percorrer o conteúdo do início ao fim
índice para determinar quantos caracteres válidos havia.

### Cortando cordas

A indexação em uma string costuma ser uma má ideia porque não está claro qual é o objetivo.
O tipo de retorno da operação de indexação de string deve ser: um valor de byte, um
caractere, um cluster de grafema ou uma fatia de string. Se você realmente precisa usar
índices para criar fatias de string, portanto, Rust pede que você seja mais específico.

Em vez de indexar usando `[]` com um único número, você pode usar `[]` com um
range para criar uma fatia de string contendo bytes específicos:

```rust
let hello = "Здравствуйте";

let s = &hello[0..4];
```

Aqui, `s` será um `&str` que contém os primeiros 4 bytes da string.
Anteriormente, mencionamos que cada um desses caracteres tinha 2 bytes, o que significa
`s` será `Зд`.

Se tentássemos cortar apenas parte dos bytes de um caractere com algo como
`&hello[0..1]`, Rust entraria em pânico em tempo de execução da mesma forma que se um inválido
index foram acessados ​​em um vetor:

```console
{{#include ../listings/ch08-common-collections/output-only-01-not-char-boundary/output.txt}}
```

Você deve ter cuidado ao criar fatias de string com intervalos, porque fazer
então pode travar seu programa.

<!-- Old headings. Do not remove or links may break. -->

<a id="methods-for-iterating-over-strings"></a>

### Iterando sobre Strings

A melhor maneira de operar com pedaços de cordas é ser explícito sobre se
você quer caracteres ou bytes. Para valores escalares Unicode individuais, use o
`chars` método. Chamar `chars` em “Зд” separa e retorna dois valores de
digite `char` e você pode iterar sobre o resultado para acessar cada elemento:

```rust
for c in "Зд".chars() {
    println!("{c}");
}
```

Este código imprimirá o seguinte:

```text
З
д
```

Alternativamente, o método `bytes` retorna cada byte bruto, que pode ser
apropriado para o seu domínio:

```rust
for b in "Зд".bytes() {
    println!("{b}");
}
```

Este código imprimirá os 4 bytes que compõem esta string:

```text
208
151
208
180
```

Mas lembre-se de que os valores escalares Unicode válidos podem ser compostos de mais
de 1 byte.

Obter clusters de grafemas a partir de strings, como acontece com o script Devanagari, é
complexo, portanto esta funcionalidade não é fornecida pela biblioteca padrão. Caixas
estão disponíveis em [crates.io](https://crates.io/)<!-- ignore --> se este for o
funcionalidade que você precisa.

<!-- Old headings. Do not remove or links may break. -->

<a id="strings-are-not-so-simple"></a>

### Lidando com as complexidades das strings

Para resumir, as strings são complicadas. Diferentes linguagens de programação fazem
diferentes escolhas sobre como apresentar essa complexidade ao programador. Ferrugem
optou por tornar o tratamento correto dos dados `String` o comportamento padrão
para todos os programas Rust, o que significa que os programadores precisam pensar mais
lidar com dados UTF-8 antecipadamente. Esta compensação expõe mais a complexidade do
strings do que é aparente em outras linguagens de programação, mas impede que você
de ter que lidar com erros envolvendo caracteres não-ASCII posteriormente em seu
ciclo de vida do desenvolvimento.

A boa notícia é que a biblioteca padrão oferece muitas funcionalidades construídas
fora dos tipos `String` e `&str` para ajudar a lidar com essas situações complexas
corretamente. Certifique-se de verificar a documentação para métodos úteis como
`contains` para pesquisar em uma string e `replace` para substituir partes de uma
string com outra string.

Vamos mudar para algo um pouco menos complexo: mapas hash!

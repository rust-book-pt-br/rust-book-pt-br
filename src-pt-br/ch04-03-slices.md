## O tipo de fatia

_Slices_ permitem fazer referência a uma sequência contígua de elementos em um
[coleção](ch08-00-common-collections.md)<!-- ignore -->. Uma fatia é uma espécie
de referência, portanto não tem propriedade.

Aqui está um pequeno problema de programação: Escreva uma função que receba uma string de
palavras separadas por espaços e retorna a primeira palavra encontrada naquela string.
Se a função não encontrar um espaço na string, toda a string deverá ser
uma palavra, então a string inteira deve ser retornada.

> Nota: Para fins de introdução de fatias, estamos assumindo ASCII apenas em
> esta seção; uma discussão mais completa sobre o tratamento de UTF-8 está no
> [“Armazenando texto codificado em UTF-8 com strings”][strings]<!-- ignore --> seção
> do Capítulo 8.

Vamos ver como escreveríamos a assinatura desta função sem usar
fatias, para entender o problema que as fatias resolverão:

```rust,ignore
fn first_word(s: &String) -> ?
```

A função `first_word` possui um parâmetro do tipo `&String`. Nós não precisamos
propriedade, então está tudo bem. (Em Rust idiomático, as funções não assumem propriedade
dos seus argumentos, a menos que seja necessário, e as razões para isso se tornarão
claro à medida que continuamos.) Mas o que devemos retornar? Nós realmente não temos um jeito
para falar sobre *parte* de uma string. No entanto, poderíamos retornar o índice do final
da palavra, indicada por um espaço. Vamos tentar isso, conforme mostrado na Listagem 4-7.

<Listing number="4-7" file-name="src/main.rs" caption="The `first_word` function that returns a byte index value into the `String` parameter">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-07/src/main.rs:here}}
```

</Listing>

Porque precisamos passar pelo `String` elemento por elemento e verificar se
um valor é um espaço, converteremos nosso `String` em uma matriz de bytes usando o
`as_bytes` método.

```rust,ignore
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-07/src/main.rs:as_bytes}}
```

A seguir, criamos um iterador sobre o array de bytes usando o método `iter`:

```rust,ignore
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-07/src/main.rs:iter}}
```

Discutiremos iteradores com mais detalhes no [Capítulo 13][ch13]<!-- ignore -->.
Por enquanto, saiba que `iter` é um método que retorna cada elemento de uma coleção
e que `enumerate` agrupa o resultado de `iter` e retorna cada elemento como
parte de uma tupla. O primeiro elemento da tupla retornado de
`enumerate` é o índice e o segundo elemento é uma referência ao elemento.
Isso é um pouco mais conveniente do que calcular o índice nós mesmos.

Como o método `enumerate` retorna uma tupla, podemos usar padrões para
desestruturar essa tupla. Discutiremos mais padrões no [Capítulo
6][ch6]<!-- ignore -->. No loop `for`, especificamos um padrão que tem `i`
para o índice na tupla e `&item` para o byte único na tupla.
Como obtemos uma referência ao elemento de `.iter().enumerate()`, usamos
`&` no padrão.

Dentro do loop `for`, procuramos o byte que representa o espaço por
usando a sintaxe literal de byte. Se encontrarmos um espaço, retornamos a posição.
Caso contrário, retornamos o comprimento da string usando `s.len()`.

```rust,ignore
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-07/src/main.rs:inside_for}}
```

Agora temos uma maneira de descobrir o índice do final da primeira palavra no
string, mas há um problema. Estamos retornando um `usize` sozinho, mas é
apenas um número significativo no contexto de `&String`. Em outras palavras,
porque é um valor separado de `String`, não há garantia de que
ainda será válido no futuro. Considere o programa na Listagem 4-8 que
usa a função `first_word` da Listagem 4-7.

<Listing number="4-8" file-name="src/main.rs" caption="Storing the result from calling the `first_word` function and then changing the `String` contents">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-08/src/main.rs:here}}
```

</Listing>

Este programa compila sem erros e também o faria se usássemos `word`
depois de ligar para `s.clear()`. Porque `word` não está conectado ao estado de `s`
de forma alguma, `word` ainda contém o valor `5`. Poderíamos usar esse valor `5` com
a variável `s` para tentar extrair a primeira palavra, mas isso seria um bug
porque o conteúdo de `s` mudou desde que salvamos `5` em `word`.

Ter que se preocupar com o índice em `word` ficando fora de sincronia com os dados em
`s` é tedioso e sujeito a erros! Gerenciar esses índices é ainda mais frágil se
escrevemos uma função `second_word`. Sua assinatura teria que ser assim:

```rust,ignore
fn second_word(s: &String) -> (usize, usize) {
```

Agora estamos rastreando um índice inicial _e_ final, e temos ainda mais
valores que foram calculados a partir de dados em um determinado estado, mas não estão vinculados a
esse estado. Temos três variáveis ​​não relacionadas flutuando que precisam
para ser mantido em sincronia.

Felizmente, Rust tem uma solução para este problema: fatias de string.

### Fatias de corda

Uma _string slice_ é uma referência a uma sequência contígua dos elementos de um
`String`, e fica assim:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-17-slice/src/main.rs:here}}
```

Em vez de uma referência a `String` inteiro, `hello` é uma referência a um
parte do `String`, especificada no bit extra `[0..5]`. Nós criamos fatias
usando um intervalo entre colchetes, especificando
`[starting_index..ending_index]`, onde _`starting_index`_ é o primeiro
posição na fatia e _`ending_index`_ é um a mais que a última posição
na fatia. Internamente, a estrutura de dados da fatia armazena a posição inicial
e o comprimento da fatia, que corresponde a _`ending_index`_ menos
_`starting_index`_. Então, no caso de `let world = &s[6..11];`, `world` seria
ser uma fatia que contém um ponteiro para o byte no índice 6 de `s` com comprimento
valor de `5`.

A Figura 4-7 mostra isso em um diagrama.

<img alt="Três tabelas: uma tabela que representa os dados da pilha de s, que aponta
para o byte no índice 0 em uma tabela de dados de string "hello world" em
a pilha. A terceira tabela representa os dados da pilha do mundo da fatia, que
tem um valor de comprimento de 5 e aponta para o byte 6 da tabela de dados heap."
src="img/trpl04-07.svg" class="center" style="largura: 50%;" />

<span class="caption">Figura 4-7: Uma fatia de string referente a parte de um
`String`</span>

Com a sintaxe de intervalo `..` do Rust, se quiser começar no índice 0, você pode descartar
o valor antes dos dois períodos. Em outras palavras, estes são iguais:

```rust
let s = String::from("hello");

let slice = &s[0..2];
let slice = &s[..2];
```

Da mesma forma, se sua fatia incluir o último byte de `String`, você
pode eliminar o número final. Isso significa que são iguais:

```rust
let s = String::from("hello");

let len = s.len();

let slice = &s[3..len];
let slice = &s[3..];
```

Você também pode eliminar ambos os valores para obter uma fatia de toda a string. Então, esses
são iguais:

```rust
let s = String::from("hello");

let len = s.len();

let slice = &s[0..len];
let slice = &s[..];
```

> Observação: os índices de intervalo de fatias de string devem ocorrer em caracteres UTF-8 válidos
> limites. Se você tentar criar uma fatia de string no meio de uma
> caractere multibyte, seu programa será encerrado com um erro.

Com todas essas informações em mente, vamos reescrever `first_word` para retornar um
fatiar. O tipo que significa “string slice” é escrito como `&str`:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-18-first-word-slice/src/main.rs:here}}
```

</Listing>

Obtemos o índice para o final da palavra da mesma forma que fizemos na Listagem 4-7, por
procurando a primeira ocorrência de um espaço. Quando encontramos um espaço, retornamos um
fatia de string usando o início da string e o índice do espaço como o
índices iniciais e finais.

Agora, quando chamamos `first_word`, obtemos de volta um único valor que está vinculado ao
dados subjacentes. O valor é composto por uma referência ao ponto inicial do
a fatia e o número de elementos na fatia.

Retornar uma fatia também funcionaria para uma função `second_word`:

```rust,ignore
fn second_word(s: &String) -> &str {
```

Agora temos uma API simples que é muito mais difícil de bagunçar porque o
o compilador garantirá que as referências em `String` permaneçam válidas.
Lembre-se do bug no programa da Listagem 4.8, quando obtivemos o índice para o
final da primeira palavra, mas depois limpou a string, então nosso índice ficou inválido?
Esse código estava logicamente incorreto, mas não apresentava erros imediatos. O
problemas apareceriam mais tarde se continuássemos tentando usar o índice da primeira palavra com
uma string vazia. Slices tornam esse bug impossível e nos avisam muito mais cedo
que temos um problema com nosso código. Usando a versão slice de `first_word`
gerará um erro em tempo de compilação:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-19-slice-error/src/main.rs:here}}
```

</Listing>

Aqui está o erro do compilador:

```console
{{#include ../listings/ch04-understanding-ownership/no-listing-19-slice-error/output.txt}}
```

Lembre-se das regras de empréstimo que se tivermos uma referência imutável a
alguma coisa, não podemos também tomar uma referência mutável. Porque `clear` precisa
truncar o `String`, ele precisa obter uma referência mutável. O `println!`
após a chamada para `clear` usa a referência em `word`, então o imutável
a referência ainda deve estar ativa nesse ponto. Rust não permite o mutável
referência em `clear` e a referência imutável em `word` existente no
ao mesmo tempo e a compilação falha. Rust não apenas tornou nossa API mais fácil de usar,
mas também eliminou uma classe inteira de erros em tempo de compilação!

<!-- Old headings. Do not remove or links may break. -->

<a id="string-literals-are-slices"></a>

#### Literais de string como fatias

Lembre-se de que falamos sobre literais de string armazenados dentro do binário. Agora
que sabemos sobre fatias, podemos entender corretamente os literais de string:

```rust
let s = "Hello, world!";
```

O tipo de `s` aqui é `&str`: é uma fatia apontando para aquele ponto específico de
o binário. É também por isso que os literais de string são imutáveis; `&str` é um
referência imutável.

#### Fatias de string como parâmetros

Saber que você pode pegar fatias de literais e valores `String` nos leva a
mais uma melhoria em `first_word`, e essa é sua assinatura:

```rust,ignore
fn first_word(s: &String) -> &str {
```

Um Rustáceo mais experiente escreveria a assinatura mostrada na Listagem 4-9
em vez disso, porque nos permite usar a mesma função em ambos os valores `&String`
e `&str` valores.

<Listing number="4-9" caption="Improving the `first_word` function by using a string slice for the type of the `s` parameter">

```rust,ignore
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-09/src/main.rs:here}}
```

</Listing>

Se tivermos uma fatia de string, podemos passá-la diretamente. Se tivermos um `String`, nós
pode passar uma fatia do `String` ou uma referência ao `String`. Esse
a flexibilidade aproveita as coerções deref, um recurso que abordaremos em
o [“Usando Coerções Deref em Funções e Métodos”][deref-coercions]<!--
ignore --> do Capítulo 15.

Definindo uma função para obter uma fatia de string em vez de uma referência a `String`
torna nossa API mais geral e útil sem perder nenhuma funcionalidade:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-09/src/main.rs:usage}}
```

</Listing>

### Outras fatias

Fatias de string, como você pode imaginar, são específicas para strings. Mas há um
tipo de fatia mais geral também. Considere esta matriz:

```rust
let a = [1, 2, 3, 4, 5];
```

Assim como podemos querer nos referir a parte de uma string, podemos querer nos referir a
parte de uma matriz. Faríamos assim:

```rust
let a = [1, 2, 3, 4, 5];

let slice = &a[1..3];

assert_eq!(slice, &[2, 3]);
```

Esta fatia tem o tipo `&[i32]`. Funciona da mesma maneira que as fatias de string, por
armazenando uma referência ao primeiro elemento e um comprimento. Você usará esse tipo de
fatia para todos os tipos de outras coleções. Discutiremos essas coleções em
detalhes quando falamos sobre vetores no Capítulo 8.

## Resumo

Os conceitos de propriedade, empréstimo e fatias garantem a segurança da memória em Rust
programas em tempo de compilação. A linguagem Rust oferece controle sobre sua memória
uso da mesma maneira que outras linguagens de programação de sistemas. Mas tendo o
o proprietário dos dados limpa automaticamente esses dados quando o proprietário sai do escopo
significa que você não precisa escrever e depurar código extra para obter esse controle.

A propriedade afeta o funcionamento de muitas outras partes do Rust, então falaremos sobre
aprofundar esses conceitos ao longo do restante do livro. Vamos passar para
Capítulo 5 e observe o agrupamento de dados em um `struct`.

[ch13]: ch13-02-iterators.html
[ch6]: ch06-02-match.html#patterns-that-bind-to-values
[strings]: ch08-02-strings.html#storing-utf-8-encoded-text-with-strings
[deref-coercions]: ch15-02-deref.html#using-deref-coercions-in-functions-and-methods

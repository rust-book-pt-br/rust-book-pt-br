## Erros Recuperáveis com `Result`

A maioria dos erros não é séria o bastante para exigir que o programa pare por
completo. Às vezes, quando uma função falha, é por um motivo que você consegue
interpretar facilmente e ao qual consegue responder. Por exemplo, se você
tentar abrir um arquivo e essa operação falhar porque o arquivo não existe,
talvez queira criar o arquivo em vez de encerrar o processo.

Lembre-se, da seção [“Lidando com Falhas Potenciais com
`Result`”][handle_failure]<!-- ignore --> no Capítulo 2, que o enum `Result`
é definido com duas variantes, `Ok` e `Err`, assim:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

`T` e `E` são parâmetros de tipo genérico. Vamos discutir genéricos com mais
detalhe no Capítulo 10. Por enquanto, o que você precisa saber é que `T`
representa o tipo do valor retornado em caso de sucesso, dentro da variante
`Ok`, e `E` representa o tipo do erro retornado em caso de falha, dentro da
variante `Err`. Como `Result` tem esses parâmetros genéricos, podemos usar o
tipo `Result` e as funções definidas nele em muitas situações diferentes nas
quais o valor de sucesso e o valor de erro podem variar.

Vamos chamar uma função que retorna um valor `Result`, porque ela pode falhar.
Na Listagem 9-3, tentamos abrir um arquivo.

<Listing number="9-3" file-name="src/main.rs" caption="Abrindo um arquivo">

```rust
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-03/src/main.rs}}
```

</Listing>

O tipo de retorno de `File::open` é `Result<T, E>`. O parâmetro genérico `T`
foi preenchido pela implementação de `File::open` com o tipo do valor de
sucesso, `std::fs::File`, que é um handle de arquivo. O tipo de `E` usado no
valor de erro é `std::io::Error`. Esse tipo de retorno significa que a chamada
a `File::open` pode dar certo e retornar um handle de arquivo do qual podemos
ler ou no qual podemos escrever. Mas a chamada também pode falhar: por
exemplo, o arquivo pode não existir, ou talvez não tenhamos permissão para
acessá-lo. A função `File::open` precisa de uma maneira de nos dizer se
funcionou ou falhou e, ao mesmo tempo, nos fornecer ou o handle de arquivo ou
as informações de erro. Isso é exatamente o que o enum `Result` transmite.

No caso em que `File::open` tiver sucesso, o valor da variável
`greeting_file_result` será uma instância de `Ok` contendo um handle de
arquivo. No caso em que falhar, o valor em `greeting_file_result` será uma
instância de `Err` contendo mais informações sobre o tipo de erro ocorrido.

Precisamos acrescentar código à Listagem 9-3 para executar ações diferentes
dependendo do valor retornado por `File::open`. A Listagem 9-4 mostra uma
forma de tratar `Result` usando uma ferramenta básica: a expressão `match`,
que discutimos no Capítulo 6.

<Listing number="9-4" file-name="src/main.rs" caption="Usando uma expressão `match` para tratar as variantes de `Result` que podem ser retornadas">

```rust,should_panic
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-04/src/main.rs}}
```

</Listing>

Observe que, assim como o enum `Option`, o enum `Result` e suas variantes
foram trazidos para o escopo pelo prelude, então não precisamos escrever
`Result::` antes de `Ok` e `Err` nos braços do `match`.

Quando o resultado é `Ok`, esse código devolve o valor interno `file` para fora
da variante `Ok`, e então atribuímos esse handle de arquivo à variável
`greeting_file`. Depois do `match`, podemos usar o handle para leitura ou
escrita.

O outro braço do `match` lida com o caso em que recebemos um valor `Err` de
`File::open`. Neste exemplo, escolhemos chamar a macro `panic!`. Se não houver
um arquivo chamado _hello.txt_ no diretório atual e executarmos esse código,
veremos a seguinte saída da macro `panic!`:

```console
{{#include ../listings/ch09-error-handling/listing-09-04/output.txt}}
```

Como sempre, essa saída nos diz exatamente o que deu errado.

### Dando `match` em Erros Diferentes

O código da Listagem 9-4 vai dar `panic!` independentemente do motivo pelo qual
`File::open` falhou. No entanto, queremos tomar ações diferentes para motivos
de falha diferentes. Se `File::open` falhou porque o arquivo não existe,
queremos criar o arquivo e retornar o handle do novo arquivo. Se `File::open`
falhou por qualquer outro motivo, por exemplo, porque não temos permissão para
abri-lo, ainda queremos que o código dê `panic!` da mesma maneira que na
Listagem 9-4. Para isso, adicionamos uma expressão `match` interna, mostrada
na Listagem 9-5.

<Listing number="9-5" file-name="src/main.rs" caption="Tratando diferentes tipos de erro de formas diferentes">

<!-- ignore this test because otherwise it creates hello.txt which causes other
tests to fail lol -->

```rust,ignore
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-05/src/main.rs}}
```

</Listing>

O tipo do valor retornado por `File::open` dentro da variante `Err` é
`io::Error`, que é uma struct fornecida pela biblioteca padrão. Essa struct tem
um método, `kind`, que podemos chamar para obter um valor `io::ErrorKind`. O
enum `io::ErrorKind` também é fornecido pela biblioteca padrão e tem variantes
que representam os diferentes tipos de erro que uma operação de `io` pode
produzir. A variante que queremos usar é `ErrorKind::NotFound`, que indica que
o arquivo que estamos tentando abrir ainda não existe. Então, damos `match` em
`greeting_file_result`, mas também temos um `match` interno em `error.kind()`.

A condição que queremos verificar no `match` interno é se o valor retornado por
`error.kind()` é a variante `NotFound` do enum `ErrorKind`. Se for, tentamos
criar o arquivo com `File::create`. No entanto, como `File::create` também
pode falhar, precisamos de um segundo braço nessa expressão `match` interna.
Quando o arquivo não pode ser criado, uma mensagem de erro diferente é
impressa. O segundo braço do `match` externo permanece o mesmo, então o
programa entra em pânico em qualquer erro que não seja o de arquivo ausente.

> #### Alternativas a Usar `match` com `Result<T, E>`
>
> Isso é muito `match`! A expressão `match` é muito útil, mas também é bastante
> primitiva. No Capítulo 13, você vai aprender sobre closures, que são usadas
> com muitos dos métodos definidos em `Result<T, E>`. Esses métodos podem ser
> mais concisos do que usar `match` ao lidar com valores `Result<T, E>` no seu
> código.
>
> Por exemplo, aqui vai outra maneira de escrever a mesma lógica mostrada na
> Listagem 9-5, desta vez usando closures e o método `unwrap_or_else`:
>
> <!-- CAN'T EXTRACT SEE https://github.com/rust-lang/mdBook/issues/1127 -->
>
> ```rust,ignore
> use std::fs::File;
> use std::io::ErrorKind;
>
> fn main() {
>     let greeting_file = File::open("hello.txt").unwrap_or_else(|error| {
>         if error.kind() == ErrorKind::NotFound {
>             File::create("hello.txt").unwrap_or_else(|error| {
>                 panic!("Problem creating the file: {error:?}");
>             })
>         } else {
>             panic!("Problem opening the file: {error:?}");
>         }
>     });
> }
> ```
>
> Embora esse código tenha o mesmo comportamento da Listagem 9-5, ele não
> contém nenhuma expressão `match` e é mais limpo de ler. Volte a este exemplo
> depois de ler o Capítulo 13 e procure o método `unwrap_or_else` na
> documentação da biblioteca padrão. Muitos outros métodos como esse podem
> limpar expressões `match` grandes e aninhadas quando você estiver lidando com
> erros.

<!-- Old headings. Do not remove or links may break. -->

<a id="shortcuts-for-panic-on-error-unwrap-and-expect"></a>

#### Atalhos para Pânico em Caso de Erro

Usar `match` funciona bem, mas pode ser um pouco verboso e nem sempre comunica
bem a intenção. O tipo `Result<T, E>` tem muitos métodos auxiliares definidos
nele para executar tarefas mais específicas. O método `unwrap` é um atalho
implementado exatamente como a expressão `match` que escrevemos na Listagem
9-4. Se o valor `Result` for a variante `Ok`, `unwrap` devolverá o valor
dentro de `Ok`. Se `Result` for a variante `Err`, `unwrap` chamará a macro
`panic!` por nós. Aqui está um exemplo de `unwrap` em ação:

<Listing file-name="src/main.rs">

```rust,should_panic
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-04-unwrap/src/main.rs}}
```

</Listing>

Se executarmos esse código sem um arquivo _hello.txt_, veremos uma mensagem de
erro vinda da chamada a `panic!` que o método `unwrap` faz:

<!-- manual-regeneration
cd listings/ch09-error-handling/no-listing-04-unwrap
cargo run
copy and paste relevant text
-->

```text
thread 'main' panicked at src/main.rs:4:49:
called `Result::unwrap()` on an `Err` value: Os { code: 2, kind: NotFound, message: "No such file or directory" }
```

Da mesma forma, o método `expect` também nos permite escolher a mensagem de
erro usada em `panic!`. Usar `expect` em vez de `unwrap` e fornecer boas
mensagens de erro pode transmitir melhor sua intenção e tornar mais fácil
rastrear a origem de um pânico. A sintaxe de `expect` é assim:

<Listing file-name="src/main.rs">

```rust,should_panic
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-05-expect/src/main.rs}}
```

</Listing>

Usamos `expect` da mesma forma que `unwrap`: para devolver o handle de arquivo
ou chamar a macro `panic!`. A mensagem de erro usada por `expect` em sua
chamada a `panic!` será o parâmetro que passarmos para `expect`, em vez da
mensagem padrão de `panic!` usada por `unwrap`. Ela fica assim:

<!-- manual-regeneration
cd listings/ch09-error-handling/no-listing-05-expect
cargo run
copy and paste relevant text
-->

```text
thread 'main' panicked at src/main.rs:5:10:
hello.txt should be included in this project: Os { code: 2, kind: NotFound, message: "No such file or directory" }
```

Em código de qualidade de produção, a maioria dos rustaceanos prefere
`expect` a `unwrap` e fornece mais contexto sobre por que a operação deveria
sempre ter sucesso. Assim, se suas suposições se mostrarem erradas, você terá
mais informações para usar na depuração.

### Propagando Erros

Quando a implementação de uma função chama algo que pode falhar, em vez de
tratar o erro dentro da própria função, você pode devolver o erro ao código
chamador para que ele decida o que fazer. Isso é conhecido como _propagar_ o
erro e dá mais controle ao código chamador, onde pode haver mais informação ou
lógica ditando como o erro deve ser tratado do que aquela disponível no
contexto da função.

Por exemplo, a Listagem 9-6 mostra uma função que lê um nome de usuário a
partir de um arquivo. Se o arquivo não existir ou não puder ser lido, essa
função devolverá esses erros ao código que a chamou.

<Listing number="9-6" file-name="src/main.rs" caption="Uma função que retorna erros ao código chamador usando `match`">

<!-- Deliberately not using rustdoc_include here; the `main` function in the
file panics. We do want to include it for reader experimentation purposes, but
don't want to include it for rustdoc testing purposes. -->

```rust
{{#include ../listings/ch09-error-handling/listing-09-06/src/main.rs:here}}
```

</Listing>

Essa função pode ser escrita de um jeito muito mais curto, mas vamos começar
fazendo bastante coisa manualmente para explorar o tratamento de erros; no
final, mostraremos o jeito mais curto. Primeiro, vamos olhar o tipo de retorno
da função: `Result<String, io::Error>`. Isso significa que a função está
retornando um valor do tipo `Result<T, E>`, em que o parâmetro genérico `T`
foi preenchido com o tipo concreto `String` e o tipo genérico `E` foi
preenchido com o tipo concreto `io::Error`.

Se essa função tiver sucesso sem problemas, o código que a chama receberá um
valor `Ok` contendo uma `String`, o `username` que a função leu do arquivo. Se
essa função encontrar algum problema, o código chamador receberá um valor `Err`
contendo uma instância de `io::Error`, que traz mais informações sobre o que
deu errado. Escolhemos `io::Error` como tipo de retorno dessa função porque
esse é justamente o tipo do valor de erro retornado pelas duas operações do
corpo da função que podem falhar: a função `File::open` e o método
`read_to_string`.

O corpo da função começa chamando `File::open`. Em seguida, tratamos o valor
`Result` com um `match` semelhante ao da Listagem 9-4. Se `File::open` tiver
sucesso, o handle de arquivo presente na variável de padrão `file` se torna o
valor da variável mutável `username_file`, e a função continua. No caso de
`Err`, em vez de chamar `panic!`, usamos a palavra-chave `return` para sair da
função imediatamente e passar o valor de erro de `File::open`, agora na
variável de padrão `e`, de volta ao código chamador como o valor de erro dessa
função.

Então, se tivermos um handle de arquivo em `username_file`, a função cria uma
nova `String` na variável `username` e chama o método `read_to_string` no
handle de arquivo em `username_file` para ler o conteúdo do arquivo para dentro
de `username`. O método `read_to_string` também retorna um `Result`, porque ele
pode falhar mesmo que `File::open` tenha funcionado. Portanto, precisamos de
outro `match` para tratar esse `Result`: se `read_to_string` tiver sucesso,
então a função também terá tido sucesso, e retornaremos o nome de usuário do
arquivo, agora armazenado em `username`, empacotado em `Ok`. Se
`read_to_string` falhar, retornamos o valor de erro da mesma forma que no
`match` que tratou o valor de retorno de `File::open`. No entanto, não
precisamos escrever `return` explicitamente, porque esta é a última expressão
da função.

O código que chama essa função então terá de lidar com receber um valor `Ok`
contendo um nome de usuário ou um valor `Err` contendo um `io::Error`. Cabe ao
código chamador decidir o que fazer com esses valores. Se ele receber um valor
`Err`, pode chamar `panic!` e encerrar o programa, usar um nome de usuário
padrão ou buscar esse nome em outro lugar além de um arquivo, por exemplo. Não
temos informação suficiente sobre o que o código chamador realmente está
tentando fazer, então propagamos todas as informações de sucesso ou erro para
cima, para que ele as trate adequadamente.

Esse padrão de propagação de erros é tão comum em Rust que a linguagem fornece
o operador ponto de interrogação `?` para tornar isso mais fácil.

<!-- Old headings. Do not remove or links may break. -->

<a id="a-shortcut-for-propagating-errors-the--operator"></a>

#### O Atalho do Operador `?`

A Listagem 9-7 mostra uma implementação de `read_username_from_file` com a
mesma funcionalidade da Listagem 9-6, mas essa implementação usa o operador
`?`.

<Listing number="9-7" file-name="src/main.rs" caption="Uma função que retorna erros ao código chamador usando o operador `?`">

<!-- Deliberately not using rustdoc_include here; the `main` function in the
file panics. We do want to include it for reader experimentation purposes, but
don't want to include it for rustdoc testing purposes. -->

```rust
{{#include ../listings/ch09-error-handling/listing-09-07/src/main.rs:here}}
```

</Listing>

O `?` colocado depois de um valor `Result` foi definido para funcionar quase da
mesma maneira que as expressões `match` que criamos para tratar os valores
`Result` na Listagem 9-6. Se o valor de `Result` for `Ok`, o valor dentro de
`Ok` será devolvido por essa expressão, e o programa continuará. Se o valor
for `Err`, esse `Err` será retornado da função inteira, como se tivéssemos
usado a palavra-chave `return`, para que o valor de erro seja propagado para o
código chamador.

Existe uma diferença entre o que a expressão `match` da Listagem 9-6 faz e o
que o operador `?` faz: os valores de erro sobre os quais `?` é chamado passam
pela função `from`, definida na trait `From` da biblioteca padrão, usada para
converter valores de um tipo em outro. Quando o operador `?` chama a função
`from`, o tipo de erro recebido é convertido no tipo de erro definido no tipo
de retorno da função atual. Isso é útil quando uma função retorna um único tipo
de erro para representar todas as formas pelas quais ela pode falhar, mesmo que
partes diferentes possam falhar por razões distintas.

Por exemplo, poderíamos alterar a função `read_username_from_file` da Listagem
9-7 para retornar um tipo de erro personalizado chamado `OurError`, definido
por nós. Se também definíssemos `impl From<io::Error> for OurError` para
construir uma instância de `OurError` a partir de um `io::Error`, então as
chamadas de `?` no corpo de `read_username_from_file` chamariam `from` e
converteriam os tipos de erro sem que precisássemos acrescentar mais código à
função.

No contexto da Listagem 9-7, o `?` no final da chamada a `File::open`
retornará o valor dentro de `Ok` para a variável `username_file`. Se ocorrer um
erro, o operador `?` retornará imediatamente da função inteira e entregará
qualquer valor `Err` ao código chamador. O mesmo vale para o `?` no final da
chamada a `read_to_string`.

O operador `?` elimina bastante código repetitivo e torna a implementação dessa
função mais simples. Poderíamos até encurtar ainda mais o código encadeando
chamadas de método logo depois do `?`, como mostra a Listagem 9-8.

<Listing number="9-8" file-name="src/main.rs" caption="Encadeando chamadas de método após o operador `?`">

<!-- Deliberately not using rustdoc_include here; the `main` function in the
file panics. We do want to include it for reader experimentation purposes, but
don't want to include it for rustdoc testing purposes. -->

```rust
{{#include ../listings/ch09-error-handling/listing-09-08/src/main.rs:here}}
```

</Listing>

Movemos a criação da nova `String` em `username` para o início da função; essa
parte não mudou. Em vez de criar uma variável `username_file`, encadeamos a
chamada para `read_to_string` diretamente sobre o resultado de
`File::open("hello.txt")?`. Continuamos tendo um `?` no final da chamada a
`read_to_string`, e ainda retornamos um valor `Ok` contendo `username` quando
`File::open` e `read_to_string` têm sucesso, em vez de retornar erros. A
funcionalidade é, mais uma vez, a mesma das Listagens 9-6 e 9-7; esta é apenas
uma forma diferente e mais ergonômica de escrever.

A Listagem 9-9 mostra uma maneira de deixar isso ainda mais curto usando
`fs::read_to_string`.

<Listing number="9-9" file-name="src/main.rs" caption="Usando `fs::read_to_string` em vez de abrir o arquivo e depois lê-lo">

<!-- Deliberately not using rustdoc_include here; the `main` function in the
file panics. We do want to include it for reader experimentation purposes, but
don't want to include it for rustdoc testing purposes. -->

```rust
{{#include ../listings/ch09-error-handling/listing-09-09/src/main.rs:here}}
```

</Listing>

Ler um arquivo para dentro de uma string é uma operação bastante comum, então a
biblioteca padrão fornece a conveniente função `fs::read_to_string`, que abre o
arquivo, cria uma nova `String`, lê o conteúdo do arquivo, coloca esse
conteúdo nessa `String` e a retorna. Claro, usar `fs::read_to_string` não nos
dá a oportunidade de explicar todo o tratamento de erros, então primeiro
seguimos pelo caminho mais longo.

<!-- Old headings. Do not remove or links may break. -->

<a id="where-the--operator-can-be-used"></a>

#### Onde o Operador `?` Pode Ser Usado

O operador `?` só pode ser usado em funções cujo tipo de retorno seja
compatível com o valor sobre o qual `?` é usado. Isso acontece porque o
operador `?` foi definido para realizar um retorno antecipado de um valor para
fora da função, da mesma maneira que a expressão `match` que definimos na
Listagem 9-6. Na Listagem 9-6, o `match` estava lidando com um valor `Result`,
e o braço de retorno antecipado retornava um valor `Err(e)`. O tipo de retorno
da função precisa ser `Result` para que isso seja compatível com esse
`return`.

Na Listagem 9-10, vejamos o erro que obteremos se usarmos o operador `?` em
uma função `main` com um tipo de retorno incompatível com o tipo do valor sobre
o qual usamos `?`.

<Listing number="9-10" file-name="src/main.rs" caption="Tentar usar `?` na função `main`, que retorna `()`, não compila">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-10/src/main.rs}}
```

</Listing>

Esse código abre um arquivo, o que pode falhar. O operador `?` acompanha o
valor `Result` retornado por `File::open`, mas essa função `main` tem tipo de
retorno `()`, e não `Result`. Quando compilamos esse código, recebemos a
seguinte mensagem de erro:

```console
{{#include ../listings/ch09-error-handling/listing-09-10/output.txt}}
```

Esse erro indica que só podemos usar o operador `?` em uma função que retorne
`Result`, `Option` ou outro tipo que implemente `FromResidual`.

Para corrigir o erro, você tem duas opções. Uma delas é alterar o tipo de
retorno da função para que ele seja compatível com o valor sobre o qual você
está usando `?`, desde que não haja nenhuma restrição que impeça isso. A outra
opção é usar `match` ou um dos métodos de `Result<T, E>` para tratar
`Result<T, E>` da maneira mais apropriada.

A mensagem de erro também mencionou que `?` pode ser usado com valores
`Option<T>`. Assim como acontece com `Result`, você só pode usar `?` em
`Option` dentro de uma função que retorne `Option`. O comportamento do operador
`?` quando chamado em `Option<T>` é semelhante ao seu comportamento quando
chamado em `Result<T, E>`: se o valor for `None`, `None` será retornado
antecipadamente da função naquele ponto. Se o valor for `Some`, o valor dentro
de `Some` será o valor resultante da expressão, e a função continuará. A
Listagem 9-11 traz um exemplo de função que encontra o último caractere da
primeira linha do texto fornecido.

<Listing number="9-11" caption="Usando o operador `?` em um valor `Option<T>`">

```rust
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-11/src/main.rs:here}}
```

</Listing>

Essa função retorna `Option<char>` porque é possível que haja um caractere ali,
mas também é possível que não haja. Esse código recebe o argumento `text`, uma
fatia de string, e chama o método `lines` sobre ele, que retorna um iterador
sobre as linhas da string. Como essa função quer examinar a primeira linha, ela
chama `next` no iterador para obter o primeiro valor. Se `text` for a string
vazia, essa chamada a `next` retornará `None`; nesse caso, usamos `?` para
parar e retornar `None` de `last_char_of_first_line`. Se `text` não for a
string vazia, `next` retornará um valor `Some` contendo uma fatia de string da
primeira linha de `text`.

O `?` extrai a fatia de string, e podemos chamar `chars` nessa fatia para
obter um iterador sobre seus caracteres. Como estamos interessados no último
caractere da primeira linha, chamamos `last` para retornar o último item do
iterador. Isso resulta em um `Option`, porque é possível que a primeira linha
seja a string vazia, por exemplo, se `text` começar com uma linha em branco,
mas tiver caracteres em outras linhas, como em `"\nhi"`. No entanto, se houver
um último caractere na primeira linha, ele será retornado dentro da variante
`Some`. O operador `?` no meio nos dá uma forma concisa de expressar essa
lógica, permitindo implementar a função em uma única linha. Se não pudéssemos
usar o operador `?` com `Option`, teríamos de implementar essa lógica usando
mais chamadas de método ou uma expressão `match`.

Observe que você pode usar o operador `?` sobre um `Result` em uma função que
retorna `Result`, e pode usar o operador `?` sobre um `Option` em uma função
que retorna `Option`, mas não pode misturar os dois casos livremente. O
operador `?` não converte automaticamente `Result` em `Option`, nem
vice-versa. Nesses casos, você pode usar métodos como `ok` em `Result` ou
`ok_or` em `Option` para fazer a conversão explicitamente.

Até aqui, todas as funções `main` que usamos retornaram `()`. A função `main` é
especial porque é o ponto de entrada e o ponto de saída de um programa
executável, e há restrições sobre qual pode ser seu tipo de retorno para que o
programa se comporte como esperado.

Felizmente, `main` também pode retornar `Result<(), E>`. A Listagem 9-12 traz
o código da Listagem 9-10, mas com o tipo de retorno de `main` alterado para
`Result<(), Box<dyn Error>>` e com um valor de retorno `Ok(())` adicionado ao
fim. Esse código agora compila.

<Listing number="9-12" file-name="src/main.rs" caption="Alterar `main` para retornar `Result<(), E>` permite usar o operador `?` em valores `Result`">

```rust,ignore
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-12/src/main.rs}}
```

</Listing>

O tipo `Box<dyn Error>` é um trait object, assunto sobre o qual falaremos em
[“Usando Trait Objects para Abstrair sobre Comportamento
Compartilhado”][trait-objects]<!-- ignore --> no Capítulo 18. Por enquanto,
você pode ler `Box<dyn Error>` como “qualquer tipo de erro”. Usar `?` em um
valor `Result` dentro de uma função `main` cujo tipo de erro é
`Box<dyn Error>` é permitido porque isso deixa qualquer valor `Err` ser
retornado antecipadamente. Mesmo que o corpo dessa função `main` retorne apenas
erros do tipo `std::io::Error`, ao especificar `Box<dyn Error>` essa
assinatura continuará correta mesmo se mais código que retorne outros erros for
adicionado ao corpo de `main`.

Quando uma função `main` retorna `Result<(), E>`, o executável sai com valor
`0` se `main` retornar `Ok(())` e sai com um valor diferente de zero se
`main` retornar um valor `Err`. Executáveis escritos em C retornam inteiros
quando encerram: programas que terminam com sucesso retornam o inteiro `0`, e
programas que falham retornam algum inteiro diferente de `0`. O Rust também
retorna inteiros a partir de executáveis para ser compatível com essa
convenção.

A função `main` pode retornar qualquer tipo que implemente [a trait
`std::process::Termination`][termination]<!-- ignore -->, que contém uma
função `report` que retorna um `ExitCode`. Consulte a documentação da
biblioteca padrão para mais informações sobre como implementar a trait
`Termination` para seus próprios tipos.

Agora que discutimos os detalhes de chamar `panic!` ou retornar `Result`,
vamos voltar ao tópico de como decidir qual dessas abordagens é a apropriada em
cada caso.

[handle_failure]: ch02-00-guessing-game-tutorial.html#handling-potential-failure-with-result
[trait-objects]: ch18-02-trait-objects.html#using-trait-objects-to-abstract-over-shared-behavior
[termination]: ../std/process/trait.Termination.html

## Erros recuperáveis ​​com `Result`

A maioria dos erros não é grave o suficiente para exigir a parada total do programa.
Às vezes, quando uma função falha, é por um motivo que você pode interpretar facilmente
e responder. Por exemplo, se você tentar abrir um arquivo e a operação falhar
porque o arquivo não existe, você pode querer criar o arquivo em vez de
encerrando o processo.

Lembre-se de [“Lidando com falhas potenciais com `Result`”][handle_failure]<!--
ignore -> no Capítulo 2 que o `Result` enum é definido como tendo dois
variantes, `Ok` e `Err`, como segue:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

Os `T` e `E` são parâmetros de tipo genérico: discutiremos os genéricos com mais detalhes.
detalhes no Capítulo 10. O que você precisa saber agora é que `T` representa
o tipo do valor que será retornado em um caso de sucesso dentro de `Ok`
variante, e `E` representa o tipo de erro que será retornado em um
caso de falha dentro da variante `Err`. Porque `Result` tem esse tipo genérico
parâmetros, podemos usar o tipo `Result` e as funções definidas nele em
muitas situações diferentes onde o valor de sucesso e o valor de erro que queremos
o retorno pode ser diferente.

Vamos chamar uma função que retorna um valor `Result` porque a função poderia
falhar. Na Listagem 9-3, tentamos abrir um arquivo.

<Listing number="9-3" file-name="src/main.rs" caption="Opening a file">

```rust
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-03/src/main.rs}}
```

</Listing>

O tipo de retorno de `File::open` é `Result<T, E>`. O parâmetro genérico `T`
foi preenchido pela implementação de `File::open` com o tipo do
valor de sucesso, `std::fs::File`, que é um identificador de arquivo. O tipo de `E` usado em
o valor do erro é `std::io::Error`. Este tipo de retorno significa a chamada para
`File::open` pode ter sucesso e retornar um identificador de arquivo que podemos ler ou
escreva para. A chamada de função também pode falhar: por exemplo, o arquivo pode não
existir ou talvez não tenhamos permissão para acessar o arquivo. O `File::open`
função precisa ter uma maneira de nos dizer se foi bem-sucedida ou falhou e pelo menos
ao mesmo tempo, forneça o identificador do arquivo ou as informações de erro. Esse
informação é exatamente o que o `Result` enum transmite.

No caso em que `File::open` for bem-sucedido, o valor na variável
`greeting_file_result` será uma instância de `Ok` que contém um identificador de arquivo.
Caso falhe, o valor em `greeting_file_result` será um
instância de `Err` que contém mais informações sobre o tipo de erro que
ocorreu.

Precisamos adicionar ao código na Listagem 9-3 para executar ações diferentes dependendo
no valor `File::open` retorna. A Listagem 9-4 mostra uma maneira de lidar com o
`Result` usando uma ferramenta básica, a expressão `match` que discutimos em
Capítulo 6.

<Listing number="9-4" file-name="src/main.rs" caption="Using a `match` expression to handle the `Result` variants that might be returned">

```rust,should_panic
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-04/src/main.rs}}
```

</Listing>

Observe que, assim como o enum `Option`, o enum `Result` e suas variantes foram
trazido ao escopo pelo prelúdio, então não precisamos especificar `Result::`
antes das variantes `Ok` e `Err` nos braços `match`.

Quando o resultado for `Ok`, este código retornará o valor interno `file` de
a variante `Ok` e, em seguida, atribuímos esse valor de identificador de arquivo à variável
`greeting_file`. Após `match`, podemos usar o identificador de arquivo para leitura ou
escrita.

O outro braço do `match` trata do caso em que obtemos um valor `Err` de
`File::open`. Neste exemplo, optamos por chamar a macro `panic!`. Se
não há nenhum arquivo chamado _hello.txt_ em nosso diretório atual e executamos isso
código, veremos a seguinte saída da macro `panic!`:

```console
{{#include ../listings/ch09-error-handling/listing-09-04/output.txt}}
```

Como sempre, esta saída nos diz exatamente o que deu errado.

### Correspondência em erros diferentes

O código na Listagem 9-4 será `panic!`, independentemente do motivo da falha de `File::open`.
No entanto, queremos tomar ações diferentes por motivos de falha diferentes. Se
`File::open` falhou porque o arquivo não existe, queremos criar o arquivo
e retorne o identificador para o novo arquivo. Se `File::open` falhou em qualquer outro
motivo - por exemplo, porque não tínhamos permissão para abrir o arquivo - ainda
deseja que o código seja `panic!` da mesma forma que fez na Listagem 9-4. Para isso, nós
adicione uma expressão interna `match`, mostrada na Listagem 9-5.

<Listing number="9-5" file-name="src/main.rs" caption="Handling different kinds of errors in different ways">

<!-- ignore this test because otherwise it creates hello.txt which causes other
testes falharam haha ​​-->

```rust,ignore
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-05/src/main.rs}}
```

</Listing>

O tipo de valor que `File::open` retorna dentro da variante `Err` é
`io::Error`, que é uma estrutura fornecida pela biblioteca padrão. Esta estrutura
tem um método, `kind`, que podemos chamar para obter um valor `io::ErrorKind`. O
enum `io::ErrorKind` é fornecido pela biblioteca padrão e possui variantes
representando os diferentes tipos de erros que podem resultar de um `io`
operação. A variante que queremos usar é `ErrorKind::NotFound`, que indica
o arquivo que estamos tentando abrir ainda não existe. Então, combinamos
`greeting_file_result`, mas também temos uma correspondência interna em `error.kind()`.

A condição que queremos verificar na correspondência interna é se o valor retornado
por `error.kind()` é a variante `NotFound` do `ErrorKind` enum. Se for,
tentamos criar o arquivo com `File::create`. No entanto, porque `File::create`
também pode falhar, precisamos de um segundo braço na expressão interna `match`. Quando o
arquivo não pode ser criado, uma mensagem de erro diferente será impressa. O segundo braço de
o `match` externo permanece o mesmo, então o programa entra em pânico com qualquer erro além
o erro de arquivo ausente.

> #### Alternativas para usar `match` com `Result<T, E>`
>
> Isso é muito `match`! A expressão `match` é muito útil, mas também muito
> muito primitivo. No Capítulo 13, você aprenderá sobre encerramentos, que são usados
> com muitos dos métodos definidos em `Result<T, E>`. Esses métodos podem ser mais
> conciso do que usar `match` ao lidar com valores `Result<T, E>` em seu código.
>
> Por exemplo, aqui está outra maneira de escrever a mesma lógica mostrada na Listagem
> 9-5, desta vez usando encerramentos e o método `unwrap_or_else`:
>
> <!-- CAN'T EXTRACT SEE https://github.com/rust-lang/mdBook/issues/1127 -->
>
> ```ferrugem, ignore
> usar std::fs::Arquivo;
> use std::io::ErrorKind;
>
> fn principal() {
>     deixe saudação_file = Arquivo::open("hello.txt").unwrap_or_else(|error| {
>         if error.kind() == ErrorKind::NotFound {
>             Arquivo::create("hello.txt").unwrap_or_else(|error| {
>                 panic!("Problema ao criar o arquivo: {error:?}");
>             })
>         } outro {
>             panic!("Problema ao abrir o arquivo: {erro:?}");
>         }
>     });
> }
> ```
>
> Embora este código tenha o mesmo comportamento da Listagem 9.5, ele não contém
> qualquer expressão `match` e é mais fácil de ler. Volte a este exemplo
> depois de ler o Capítulo 13 e procurar o método `unwrap_or_else` no
> documentação padrão da biblioteca. Muitos outros desses métodos podem limpar enormes,
> expressões `match` aninhadas quando você está lidando com erros.

<!-- Old headings. Do not remove or links may break. -->

<a id="shortcuts-for-panic-on-error-unwrap-and-expect"></a>

#### Atalhos para pânico em caso de erro

Usar `match` funciona bem, mas pode ser um pouco detalhado e nem sempre
comunicar bem a intenção. O tipo `Result<T, E>` possui muitos métodos auxiliares
definido nele para realizar várias tarefas mais específicas. O método `unwrap` é um
método de atalho implementado exatamente como a expressão `match` que escrevemos em
Listagem 9-4. Se o valor `Result` for a variante `Ok`, `unwrap` retornará
o valor dentro de `Ok`. Se `Result` for a variante `Err`, `unwrap` irá
chame a macro `panic!` para nós. Aqui está um exemplo de `unwrap` em ação:

<Listing file-name="src/main.rs">

```rust,should_panic
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-04-unwrap/src/main.rs}}
```

</Listing>

Se executarmos este código sem um arquivo _hello.txt_, veremos uma mensagem de erro de
a chamada `panic!` que o método `unwrap` faz:

<!-- manual-regeneration
listagens de cd/ch09-error-handling/no-listing-04-unwrap
corrida de carga
copie e cole o texto relevante
-->

```text
thread 'main' panicked at src/main.rs:4:49:
called `Result::unwrap()` on an `Err` value: Os { code: 2, kind: NotFound, message: "No such file or directory" }
```

Da mesma forma, o método `expect` também nos permite escolher a mensagem de erro `panic!`.
Usar `expect` em vez de `unwrap` e fornecer boas mensagens de erro pode transmitir
sua intenção e tornar mais fácil rastrear a origem do pânico. A sintaxe de
`expect` fica assim:

<Listing file-name="src/main.rs">

```rust,should_panic
{{#rustdoc_include ../listings/ch09-error-handling/no-listing-05-expect/src/main.rs}}
```

</Listing>

Usamos `expect` da mesma forma que `unwrap`: para retornar o identificador ou chamada do arquivo
a macro `panic!`. A mensagem de erro usada por `expect` em sua chamada para `panic!`
será o parâmetro que passaremos para `expect`, em vez do padrão
`panic!` mensagem que `unwrap` usa. Aqui está o que parece:

<!-- manual-regeneration
listagens de cd/ch09-error-handling/no-listing-05-expect
corrida de carga
copie e cole o texto relevante
-->

```text
thread 'main' panicked at src/main.rs:5:10:
hello.txt should be included in this project: Os { code: 2, kind: NotFound, message: "No such file or directory" }
```

No código de qualidade de produção, a maioria dos Rustáceos escolhe `expect` em vez de
`unwrap` e forneça mais contexto sobre por que se espera que a operação sempre
ter sucesso. Dessa forma, se suas suposições forem provadas erradas, você terá mais
informações para usar na depuração.

### Propagando Erros

Quando a implementação de uma função chama algo que pode falhar, em vez de
manipulando o erro dentro da própria função, você pode retornar o erro para o
chamando o código para que ele possa decidir o que fazer. Isso é conhecido como _propagação_
o erro e dá mais controle ao código de chamada, onde pode haver mais
informação ou lógica que dita como o erro deve ser tratado do que o que
você tem disponível no contexto do seu código.

Por exemplo, a Listagem 9.6 mostra uma função que lê um nome de usuário de um arquivo. Se
o arquivo não existe ou não pode ser lido, esta função retornará esses erros
ao código que chamou a função.

<Listing number="9-6" file-name="src/main.rs" caption="A function that returns errors to the calling code using `match`">

<!-- Deliberately not using rustdoc_include here; the `main` function in the
arquivo pânico. Queremos incluí-lo para fins de experimentação do leitor, mas
não quero incluí-lo para fins de teste de ferrugem. -->

```rust
{{#include ../listings/ch09-error-handling/listing-09-06/src/main.rs:here}}
```

</Listing>

Esta função pode ser escrita de uma forma muito mais curta, mas vamos começar por
fazer muito isso manualmente para explorar o tratamento de erros; no final,
mostraremos o caminho mais curto. Vejamos o tipo de retorno da função
primeiro: `Result<String, io::Error>`. Isso significa que a função está retornando um
valor do tipo `Result<T, E>`, onde o parâmetro genérico `T` foi
preenchido com o tipo concreto `String` e o tipo genérico `E` foi
preenchido com o tipo concreto `io::Error`.

Se esta função for bem-sucedida sem problemas, o código que a chama
função receberá um valor `Ok` que contém um `String` - o `username` que
esta função lê o arquivo. Se esta função encontrar algum problema, o
o código de chamada receberá um valor `Err` que contém uma instância de `io::Error`
que contém mais informações sobre quais eram os problemas. Nós escolhemos
`io::Error` como o tipo de retorno desta função porque esse é o
tipo do valor de erro retornado de ambas as operações que estamos chamando
corpo desta função que pode falhar: a função `File::open` e o
`read_to_string` método.

O corpo da função começa chamando a função `File::open`. Então, nós
lide com o valor `Result` com um `match` semelhante ao `match` na Listagem 9-4.
Se `File::open` for bem-sucedido, o identificador de arquivo na variável padrão `file`
torna-se o valor na variável mutável `username_file` e na função
continua. No caso `Err`, em vez de chamar `panic!`, usamos o `return`
palavra-chave para retornar totalmente da função e passar o valor do erro
de `File::open`, agora na variável padrão `e`, de volta ao código de chamada como
o valor de erro desta função.

Então, se tivermos um identificador de arquivo em `username_file`, a função criará um
new `String` na variável `username` e chama o método `read_to_string`
o identificador do arquivo em `username_file` para ler o conteúdo do arquivo em
`username`. O método `read_to_string` também retorna `Result` porque
pode falhar, mesmo que `File::open` tenha sido bem-sucedido. Então, precisamos de outro `match` para
lidar com isso `Result`: Se `read_to_string` for bem-sucedido, então nossa função tem
foi bem-sucedido e retornamos o nome de usuário do arquivo que agora está em `username`
embrulhado em um `Ok`. Se `read_to_string` falhar, retornamos o valor do erro no
da mesma forma que retornamos o valor do erro no `match` que tratou o
valor de retorno de `File::open`. No entanto, não precisamos dizer explicitamente
`return`, porque esta é a última expressão da função.

O código que chama esse código irá então obter um valor `Ok`
que contém um nome de usuário ou um valor `Err` que contém um `io::Error`. Isso é
depende do código de chamada para decidir o que fazer com esses valores. Se a chamada
código recebe um valor `Err`, ele poderia chamar `panic!` e travar o programa, usar um
nome de usuário padrão ou procure o nome de usuário em algum lugar diferente de um arquivo, por
exemplo. Não temos informações suficientes sobre qual é realmente o código de chamada
tentando fazer, então propagamos todas as informações de sucesso ou erro para cima para
para lidar adequadamente.

Este padrão de propagação de erros é tão comum no Rust que o Rust fornece o
operador de ponto de interrogação `?` para tornar isso mais fácil.

<!-- Old headings. Do not remove or links may break. -->

<a id="a-shortcut-for-propagating-errors-the--operator"></a>

#### O atalho do operador `?`

A Listagem 9-7 mostra uma implementação de `read_username_from_file` que tem o
mesma funcionalidade da Listagem 9-6, mas esta implementação usa o `?`
operador.

<Listing number="9-7" file-name="src/main.rs" caption="A function that returns errors to the calling code using the `?` operator">

<!-- Deliberately not using rustdoc_include here; the `main` function in the
arquivo pânico. Queremos incluí-lo para fins de experimentação do leitor, mas
não quero incluí-lo para fins de teste de ferrugem. -->

```rust
{{#include ../listings/ch09-error-handling/listing-09-07/src/main.rs:here}}
```

</Listing>

O `?` colocado após um valor `Result` é definido para funcionar quase da mesma maneira
como as expressões `match` que definimos para lidar com os valores `Result` em
Listagem 9-6. Se o valor de `Result` for `Ok`, o valor dentro de `Ok`
será retornado desta expressão e o programa continuará. Se o
valor for `Err`, `Err` será retornado de toda a função como se
usou a palavra-chave `return` para que o valor do erro fosse propagado para o
código de chamada.

Há uma diferença entre o que a expressão `match` da Listagem 9.6 faz
e o que o operador `?` faz: Valores de erro que têm o operador `?` chamado
neles passe pela função `from`, definida no traço `From` no
biblioteca padrão, que é usada para converter valores de um tipo para outro.
Quando o operador `?` chama a função `from`, o tipo de erro recebido é
convertido no tipo de erro definido no tipo de retorno do atual
função. Isto é útil quando uma função retorna um tipo de erro para representar
todas as maneiras pelas quais uma função pode falhar, mesmo que partes possam falhar por muitos motivos diferentes.
razões.

Por exemplo, poderíamos alterar a função `read_username_from_file` na Listagem
9-7 para retornar um tipo de erro personalizado chamado `OurError` que definimos. Se nós também
defina `impl From<io::Error> for OurError` para construir uma instância de
`OurError` de um `io::Error`, então o operador `?` chama no corpo de
`read_username_from_file` chamará `from` e converterá os tipos de erro sem
necessidade de adicionar mais código à função.

No contexto da Listagem 9-7, o `?` no final da chamada `File::open` irá
retorne o valor dentro de `Ok` para a variável `username_file`. Se um erro
ocorrer, o operador `?` retornará no início de toda a função e fornecerá
qualquer valor `Err` para o código de chamada. A mesma coisa se aplica a `?` no
final da chamada `read_to_string`.

O operador `?` elimina muitos clichês e torna esta função
implementação mais simples. Poderíamos até encurtar ainda mais esse código encadeando
chama o método imediatamente após `?`, conforme mostrado na Listagem 9-8.

<Listing number="9-8" file-name="src/main.rs" caption="Chaining method calls after the `?` operator">

<!-- Deliberately not using rustdoc_include here; the `main` function in the
arquivo pânico. Queremos incluí-lo para fins de experimentação do leitor, mas
não quero incluí-lo para fins de teste de ferrugem. -->

```rust
{{#include ../listings/ch09-error-handling/listing-09-08/src/main.rs:here}}
```

</Listing>

Movemos a criação do novo `String` em `username` para o início de
a função; essa parte não mudou. Em vez de criar uma variável
`username_file`, encadeamos a chamada para `read_to_string` diretamente no
resultado de `File::open("hello.txt")?`. Ainda temos um `?` no final do
`read_to_string` e ainda retornamos um valor `Ok` contendo `username`
quando `File::open` e `read_to_string` são bem-sucedidos em vez de retornar
erros. A funcionalidade é novamente a mesma da Listagem 9-6 e da Listagem 9-7;
esta é apenas uma maneira diferente e mais ergonômica de escrever.

A Listagem 9-9 mostra uma maneira de tornar isso ainda mais curto usando `fs::read_to_string`.

<Listing number="9-9" file-name="src/main.rs" caption="Using `fs::read_to_string` instead of opening and then reading the file">

<!-- Deliberately not using rustdoc_include here; the `main` function in the
arquivo pânico. Queremos incluí-lo para fins de experimentação do leitor, mas
não quero incluí-lo para fins de teste de ferrugem. -->

```rust
{{#include ../listings/ch09-error-handling/listing-09-09/src/main.rs:here}}
```

</Listing>

Ler um arquivo em uma string é uma operação bastante comum, então o padrão
biblioteca fornece a conveniente função `fs::read_to_string` que abre o
arquivo, cria um novo `String`, lê o conteúdo do arquivo, coloca o conteúdo
naquele `String` e o retorna. Claro, usando `fs::read_to_string`
não nos dá a oportunidade de explicar todo o tratamento de erros, então fizemos isso
o caminho mais longo primeiro.

<!-- Old headings. Do not remove or links may break. -->

<a id="where-the--operator-can-be-used"></a>

#### Onde usar o operador `?`

O operador `?` só pode ser usado em funções cujo tipo de retorno seja compatível
com o valor em que `?` é usado. Isso ocorre porque o operador `?` é definido
realizar um retorno antecipado de um valor fora da função, da mesma maneira
como a expressão `match` que definimos na Listagem 9-6. Na Listagem 9-6, o
`match` estava usando um valor `Result`, e o braço de retorno antecipado retornou um
`Err(e)` valor. O tipo de retorno da função deve ser `Result` para que
é compatível com este `return`.

Na Listagem 9.10, vejamos o erro que obteremos se usarmos o operador `?`
em uma função `main` com um tipo de retorno incompatível com o tipo de
o valor que usamos em `?`.

<Listing number="9-10" file-name="src/main.rs" caption="Attempting to use the `?` in the `main` function that returns `()` won’t compile.">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-10/src/main.rs}}
```

</Listing>

Este código abre um arquivo, que pode falhar. O operador `?` segue o `Result`
valor retornado por `File::open`, mas esta função `main` tem o tipo de retorno de
`()`, não `Result`. Quando compilamos este código, obtemos o seguinte erro
mensagem:

```console
{{#include ../listings/ch09-error-handling/listing-09-10/output.txt}}
```

Este erro indica que só podemos usar o operador `?` em um
função que retorna `Result`, `Option` ou outro tipo que implementa
`FromResidual`.

Para corrigir o erro, você tem duas opções. Uma opção é alterar o tipo de retorno
da sua função para ser compatível com o valor que você está usando o operador `?`
contanto que você não tenha restrições que impeçam isso. A outra escolha é
use um `match` ou um dos métodos `Result<T, E>` para lidar com `Result<T, E>`
da maneira que for apropriada.

A mensagem de erro também mencionou que `?` pode ser usado com valores `Option<T>`
também. Assim como usar `?` em `Result`, você só pode usar `?` em `Option` em um
função que retorna um `Option`. O comportamento do operador `?` quando chamado
em `Option<T>` é semelhante ao seu comportamento quando chamado em `Result<T, E>`:
Se o valor for `None`, `None` será retornado antecipadamente da função em
esse ponto. Se o valor for `Some`, o valor dentro de `Some` é o
valor resultante da expressão e a função continua. A Listagem 9-11 tem
um exemplo de função que encontra o último caractere da primeira linha no
dado texto.

<Listing number="9-11" caption="Using the `?` operator on an `Option<T>` value">

```rust
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-11/src/main.rs:here}}
```

</Listing>

Esta função retorna `Option<char>` porque é possível que exista um
personagem lá, mas também é possível que não haja. Este código leva o
argumento de fatia de string `text` e chama o método `lines` nele, que retorna
um iterador sobre as linhas da string. Porque esta função quer
examine a primeira linha, ele chama `next` no iterador para obter o primeiro valor
do iterador. Se `text` for a string vazia, esta chamada para `next` irá
return `None`, nesse caso usamos `?` para parar e retornar `None` de
`last_char_of_first_line`. Se `text` não for uma string vazia, `next` irá
retorna um valor `Some` contendo uma fatia de string da primeira linha em `text`.

O `?` extrai a fatia da string e podemos chamar `chars` nessa fatia da string
para obter um iterador de seus personagens. Estamos interessados ​​no último personagem de
esta primeira linha, então chamamos `last` para retornar o último item do iterador.
Este é um `Option` porque é possível que a primeira linha esteja vazia
corda; por exemplo, se `text` começar com uma linha em branco, mas tiver caracteres
outras linhas, como em `"\nhi"`. No entanto, se houver um último caractere no primeiro
linha, ele será retornado na variante `Some`. O operador `?` no meio
nos dá uma maneira concisa de expressar essa lógica, permitindo-nos implementar o
funcionar em uma linha. Se não pudéssemos usar o operador `?` em `Option`, teríamos
tem que implementar esta lógica usando mais chamadas de método ou uma expressão `match`.

Observe que você pode usar o operador `?` em `Result` em uma função que retorna
`Result`, e você pode usar o operador `?` em um `Option` em uma função que
retorna `Option`, mas você não pode misturar e combinar. O operador `?` não
converter automaticamente `Result` em `Option` ou vice-versa; nesses casos,
você pode usar métodos como o método `ok` em `Result` ou o método `ok_or` em
`Option` para fazer a conversão explicitamente.

Até agora, todas as funções `main` que usamos retornaram `()`. A função `main` é
especial porque é o ponto de entrada e o ponto de saída de um programa executável,
e há restrições sobre qual pode ser o tipo de retorno para o programa
comporte-se conforme o esperado.

Felizmente, `main` também pode retornar `Result<(), E>`. A Listagem 9-12 tem o código
da Listagem 9-10, mas alteramos o tipo de retorno de `main` para ser
`Result<(), Box<dyn Error>>` e adicionou um valor de retorno `Ok(())` ao final. Esse
o código agora será compilado.

<Listing number="9-12" file-name="src/main.rs" caption="Changing `main` to return `Result<(), E>` allows the use of the `?` operator on `Result` values.">

```rust,ignore
{{#rustdoc_include ../listings/ch09-error-handling/listing-09-12/src/main.rs}}
```

</Listing>

O tipo `Box<dyn Error>` é um objeto trait, sobre o qual falaremos em [“Usando
Objetos de características para comportamento abstrato em vez de compartilhado”][trait-objects]<!-- ignore -->
no Capítulo 18. Por enquanto, você pode ler `Box<dyn Error>` como significando “qualquer tipo de
erro." Usando `?` em um valor `Result` em uma função `main` com o tipo de erro
`Box<dyn Error>` é permitido porque permite que qualquer valor `Err` seja retornado
cedo. Mesmo que o corpo desta função `main` retorne apenas
erros do tipo `std::io::Error`, especificando `Box<dyn Error>`, esta assinatura
continuará correto mesmo se mais código que retorna outros erros for
adicionado ao corpo de `main`.

Quando uma função `main` retorna `Result<(), E>`, o executável sairá com
um valor de `0` se `main` retornar `Ok(())` e sairá com um valor diferente de zero se
`main` retorna um valor `Err`. Executáveis ​​escritos em C retornam números inteiros quando
eles saem: os programas que saem com sucesso retornam o número inteiro `0` e os programas
esse erro retorna algum número inteiro diferente de `0`. Rust também retorna números inteiros de
executáveis ​​para serem compatíveis com esta convenção.

A função `main` pode retornar qualquer tipo que implemente [o
`std::process::Termination` traço][termination]<!-- ignore -->, que contém
uma função `report` que retorna um `ExitCode`. Consulte a biblioteca padrão
documentação para obter mais informações sobre a implementação do traço `Termination` para
seus próprios tipos.

Agora que discutimos os detalhes de ligar para `panic!` ou retornar `Result`,
vamos voltar ao tópico de como decidir o que é apropriado usar em quais
casos.

[handle_failure]: ch02-00-guessing-game-tutorial.html#handling-potential-failure-with-result
[trait-objects]: ch18-02-trait-objects.html#using-trait-objects-to-abstract-over-shared-behavior
[termination]: ../std/process/trait.Termination.html

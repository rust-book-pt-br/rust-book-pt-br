## Como escrever testes

_Testes_ são funções Rust que verificam se o código que não é de teste está se
comportando da forma esperada. Os corpos das funções de teste normalmente
executam estas três ações:

- Configurar os dados ou o estado necessários.
- Executar o código que você quer testar.
- Verificar se os resultados são os esperados.

Vamos ver os recursos que Rust fornece especificamente para escrever testes que
sigam esse fluxo, incluindo o atributo `test`, algumas macros e o atributo
`should_panic`.

<!-- Old headings. Do not remove or links may break. -->

<a id="the-anatomy-of-a-test-function"></a>

### Estruturando funções de teste

Na forma mais simples, um teste em Rust é uma função anotada com o atributo
`test`. Atributos são metadados sobre partes do código Rust; um exemplo é o
atributo `derive`, que usamos com structs no Capítulo 5. Para transformar uma
função em uma função de teste, adicione `#[test]` na linha anterior a `fn`.
Quando você executa seus testes com o comando `cargo test`, Rust constrói um
binário executor de testes que executa as funções anotadas e informa se cada
função de teste passou ou falhou.

Sempre que criamos um novo projeto de biblioteca com Cargo, um módulo de testes
com uma função de teste dentro dele é gerado automaticamente. Esse módulo
oferece um modelo para escrever seus testes, para que você não precise
relembrar a estrutura e a sintaxe exatas toda vez que iniciar um projeto novo.
Você pode adicionar quantas funções de teste extras e quantos módulos de teste
quiser!

Vamos explorar alguns aspectos de como os testes funcionam experimentando o
modelo inicial antes de realmente testar qualquer código. Depois, escreveremos
alguns testes mais realistas que chamam código escrito por nós e verificam se
seu comportamento está correto.

Vamos criar um novo projeto de biblioteca chamado `adder`, que somará dois
números:

```console
$ cargo new adder --lib
     Created library `adder` project
$ cd adder
```

O conteúdo do arquivo _src/lib.rs_ na sua biblioteca `adder` deve se parecer
com a Listagem 11-1.

<Listing number="11-1" file-name="src/lib.rs" caption="Código gerado automaticamente por `cargo new`">

<!-- manual-regeneration
cd listings/ch11-writing-automated-tests
rm -rf listing-11-01
cargo new listing-11-01 --lib --name adder
cd listing-11-01
echo "$ cargo test" > output.txt
RUSTFLAGS="-A unused_variables -A dead_code" RUST_TEST_THREADS=1 cargo test >> output.txt 2>&1
git diff output.txt # commit any relevant changes; discard irrelevant ones
cd ../../..
-->

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-01/src/lib.rs}}
```

</Listing>

O arquivo começa com uma função de exemplo, `add`, para que tenhamos algo a
testar.

Por enquanto, vamos focar apenas na função `it_works`. Observe a anotação
`#[test]`: esse atributo indica que esta é uma função de teste, para que o
executor saiba tratá-la como tal. Também podemos ter funções que não são
testes dentro do módulo `tests` para ajudar a montar cenários comuns ou
executar operações repetidas, por isso sempre precisamos indicar quais funções
são testes.

O corpo da função de exemplo usa a macro `assert_eq!` para verificar que
`result`, que contém o resultado de chamar `add` com 2 e 2, é igual a 4. Essa
verificação serve como exemplo do formato de um teste típico. Vamos executá-lo
para confirmar que esse teste passa.

O comando `cargo test` executa todos os testes do nosso projeto, como mostra a
Listagem 11-2.

<Listing number="11-2" caption="Saída da execução do teste gerado automaticamente">

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-01/output.txt}}
```

</Listing>

Cargo compilou e executou o teste. Vemos a linha `running 1 test`. A linha
seguinte mostra o nome da função de teste gerada, `tests::it_works`, e que o
resultado da execução desse teste é `ok`. O resumo geral `test result: ok.`
significa que todos os testes passaram, e a parte que diz `1 passed; 0 failed`
totaliza quantos testes passaram ou falharam.

É possível marcar um teste como ignorado para que ele não seja executado em
determinada ocasião; veremos isso mais adiante neste capítulo, na seção
[“Ignorando testes, a menos que sejam solicitados especificamente”][ignoring]
<!-- ignore -->. Como ainda não fizemos isso aqui, o resumo mostra
`0 ignored`. Também podemos passar um argumento ao comando `cargo test` para
executar somente os testes cujo nome corresponda a uma string; isso é chamado
de _filtragem_, e veremos esse recurso na seção
[“Executando um subconjunto de testes por nome”][subset]<!-- ignore -->. Aqui,
não filtramos os testes executados, então o fim do resumo mostra
`0 filtered out`.

A estatística `0 measured` é usada para testes de benchmark que medem
desempenho. No momento em que este livro foi escrito, testes de benchmark só
estavam disponíveis no Rust noturno. Veja
[a documentação sobre testes de benchmark][bench] para saber mais.

A próxima parte da saída, que começa em `Doc-tests adder`, corresponde aos
resultados de quaisquer testes de documentação. Ainda não temos testes de
documentação, mas Rust pode compilar qualquer exemplo de código que apareça na
nossa documentação de API. Esse recurso ajuda a manter documentação e código em
sincronia! Vamos discutir como escrever testes de documentação na seção
[“Comentários de documentação como testes”][doc-comments]<!-- ignore --> do
Capítulo 14. Por enquanto, vamos ignorar a saída `Doc-tests`.

Vamos começar a adaptar o teste às nossas necessidades. Primeiro, altere o nome
da função `it_works` para outro nome, como `exploration`, assim:

<span class="filename">Nome do arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-01-changing-test-name/src/lib.rs}}
```

Depois, execute `cargo test` novamente. Agora a saída mostra `exploration` em
vez de `it_works`:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-01-changing-test-name/output.txt}}
```

Agora vamos adicionar outro teste, mas desta vez faremos um teste que falha!
Testes falham quando algo dentro da função de teste entra em pânico. Cada teste
é executado em uma nova thread, e quando a thread principal percebe que uma
thread de teste morreu, esse teste é marcado como falho. No Capítulo 9,
comentamos que a forma mais simples de provocar um pânico é chamar a macro
`panic!`. Digite o novo teste como uma função chamada `another`, para que seu
arquivo _src/lib.rs_ fique como na Listagem 11-3.

<Listing number="11-3" file-name="src/lib.rs" caption="Adicionando um segundo teste que falhará porque chamamos a macro `panic!`">

```rust,panics,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-03/src/lib.rs}}
```

</Listing>

Execute os testes novamente com `cargo test`. A saída deve se parecer com a
Listagem 11-4, que mostra que nosso teste `exploration` passou e `another`
falhou.

<Listing number="11-4" caption="Resultados dos testes quando um passa e outro falha">

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-03/output.txt}}
```

</Listing>

<!-- manual-regeneration
rg panicked listings/ch11-writing-automated-tests/listing-11-03/output.txt
check the line number of the panic matches the line number in the following paragraph
 -->

Em vez de `ok`, a linha `test tests::another` mostra `FAILED`. Duas novas
seções aparecem entre os resultados individuais e o resumo. A primeira exibe o
motivo detalhado de cada falha de teste. Neste caso, vemos que
`tests::another` falhou porque entrou em pânico com a mensagem `Make this test
fail` na linha 17 do arquivo _src/lib.rs_. A seção seguinte lista apenas os
nomes de todos os testes que falharam, o que é útil quando há muitos testes e
muitas saídas detalhadas de falha. Podemos usar o nome de um teste que falhou
para executá-lo isoladamente e depurá-lo com mais facilidade; falaremos mais
sobre formas de executar testes na seção
[“Controlando como os testes são executados”][controlling-how-tests-are-run]
<!-- ignore -->.

A linha de resumo aparece ao final: no geral, o resultado do nosso teste é
`FAILED`. Tivemos um teste que passou e um teste que falhou.

Agora que você já viu como os resultados de teste se apresentam em cenários
diferentes, vamos examinar algumas macros além de `panic!` que são úteis em
testes.

<!-- Old headings. Do not remove or links may break. -->

<a id="checking-results-with-the-assert-macro"></a>

### Verificando resultados com `assert!`

A macro `assert!`, fornecida pela biblioteca padrão, é útil quando você quer
garantir que alguma condição em um teste seja avaliada como `true`. Passamos à
macro `assert!` um argumento que é avaliado como um booleano. Se o valor for
`true`, nada acontece e o teste passa. Se o valor for `false`, a macro
`assert!` chama `panic!` para fazer o teste falhar. Usar a macro `assert!` nos
ajuda a verificar se o código está funcionando da maneira que pretendemos.

No Capítulo 5, na Listagem 5-15, usamos uma struct `Rectangle` e um método
`can_hold`, repetidos aqui na Listagem 11-5. Vamos colocar esse código no
arquivo _src/lib.rs_ e, em seguida, escrever alguns testes para ele usando a
macro `assert!`.

<Listing number="11-5" file-name="src/lib.rs" caption="A struct `Rectangle` e seu método `can_hold`, do Capítulo 5">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-05/src/lib.rs}}
```

</Listing>

O método `can_hold` retorna um booleano, o que o torna um caso de uso perfeito
para a macro `assert!`. Na Listagem 11-6, escrevemos um teste que exercita o
método `can_hold` criando uma instância de `Rectangle` com largura 8 e altura
7 e verificando que ela consegue conter outra instância de `Rectangle` com
largura 5 e altura 1.

<Listing number="11-6" file-name="src/lib.rs" caption="Um teste para `can_hold` que verifica se um retângulo maior realmente consegue conter um retângulo menor">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-06/src/lib.rs:here}}
```

</Listing>

Observe a linha `use super::*;` dentro do módulo `tests`. O módulo `tests` é um
módulo comum que segue as regras usuais de visibilidade que vimos no Capítulo 7
na seção
[“Caminhos para se referir a um item na árvore de módulos”][paths-for-referring-to-an-item-in-the-module-tree]
<!-- ignore -->. Como o módulo `tests` é um módulo interno, precisamos trazer
para o escopo do módulo interno o código em teste definido no módulo externo.
Usamos um glob aqui, então tudo o que definirmos no módulo externo fica
disponível para esse módulo `tests`.

Chamamos nosso teste de `larger_can_hold_smaller` e criamos as duas instâncias
de `Rectangle` de que precisamos. Em seguida, chamamos a macro `assert!` e
passamos o resultado da chamada `larger.can_hold(&smaller)`. Essa expressão
deve retornar `true`, então nosso teste deve passar. Vamos conferir!

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-06/output.txt}}
```

Ele passa! Vamos adicionar outro teste, desta vez verificando que um retângulo
menor não pode conter um retângulo maior:

<span class="filename">Nome do arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-02-adding-another-rectangle-test/src/lib.rs:here}}
```

Como o resultado correto da função `can_hold` nesse caso é `false`, precisamos
negar esse resultado antes de passá-lo à macro `assert!`. Como resultado, nosso
teste vai passar se `can_hold` retornar `false`:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-02-adding-another-rectangle-test/output.txt}}
```

Dois testes passando! Agora vamos ver o que acontece com os resultados quando
introduzimos um bug no nosso código. Vamos mudar a implementação do método
`can_hold`, substituindo o sinal de maior que (`>`) por um sinal de menor que
(`<`) na comparação das larguras:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-03-introducing-a-bug/src/lib.rs:here}}
```

Executando os testes agora, obtemos o seguinte:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-03-introducing-a-bug/output.txt}}
```

Nossos testes detectaram o bug! Como `larger.width` é `8` e `smaller.width` é
`5`, a comparação das larguras em `can_hold` agora retorna `false`: 8 não é
menor que 5.

<!-- Old headings. Do not remove or links may break. -->

<a id="testing-equality-with-the-assert_eq-and-assert_ne-macros"></a>

### Testando igualdade com `assert_eq!` e `assert_ne!`

Uma forma comum de verificar funcionalidade é testar a igualdade entre o
resultado do código em teste e o valor que você espera que esse código retorne.
Você poderia fazer isso usando a macro `assert!` e passando a ela uma expressão
com o operador `==`. Porém, isso é tão comum em testes que a biblioteca padrão
fornece um par de macros, `assert_eq!` e `assert_ne!`, para realizar essa
verificação de forma mais conveniente. Essas macros comparam dois argumentos
quanto à igualdade ou à desigualdade, respectivamente. Elas também imprimem os
dois valores quando a verificação falha, o que facilita entender _por que_ o
teste falhou; em contraste, a macro `assert!` apenas indica que recebeu `false`
para a expressão com `==`, sem mostrar os valores que levaram a esse resultado.

Na Listagem 11-7, escrevemos uma função chamada `add_two`, que soma `2` ao seu
parâmetro, e depois testamos essa função usando a macro `assert_eq!`.

<Listing number="11-7" file-name="src/lib.rs" caption="Testando a função `add_two` com a macro `assert_eq!`">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-07/src/lib.rs}}
```

</Listing>

Vamos verificar se ela passa!

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-07/output.txt}}
```

Criamos uma variável chamada `result` que guarda o resultado de chamar
`add_two(2)`. Em seguida, passamos `result` e `4` como argumentos para a macro
`assert_eq!`. A linha de saída desse teste é `test tests::it_adds_two ... ok`,
e o texto `ok` indica que nosso teste passou!

Vamos introduzir um bug no código para ver como `assert_eq!` se comporta quando
falha. Altere a implementação da função `add_two` para que ela some `3`:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-04-bug-in-add-two/src/lib.rs:here}}
```

Execute os testes novamente:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-04-bug-in-add-two/output.txt}}
```

Nosso teste detectou o bug! O teste `tests::it_adds_two` falhou, e a mensagem
nos informa que a verificação que falhou foi `left == right` e quais são os
valores `left` e `right`. Essa mensagem já nos ajuda a começar a depuração: o
argumento `left`, no qual tínhamos o resultado da chamada `add_two(2)`, era
`5`, enquanto o argumento `right` era `4`. Você pode imaginar como isso é
especialmente útil quando temos muitos testes em execução.

Observe que, em algumas linguagens e frameworks de teste, os parâmetros das
funções de verificação de igualdade são chamados de `expected` e `actual`, e a
ordem em que especificamos os argumentos importa. Em Rust, porém, eles se
chamam `left` e `right`, e a ordem em que fornecemos o valor esperado e o valor
produzido pelo código não importa. Poderíamos escrever a verificação desse
teste como `assert_eq!(4, result)`, o que produziria a mesma mensagem de falha
que mostra `` assertion `left == right` failed ``.

A macro `assert_ne!` passa se os dois valores fornecidos forem diferentes e
falha se forem iguais. Ela é mais útil em casos em que não sabemos exatamente
qual valor _será_ produzido, mas sabemos qual valor definitivamente _não deve_
ser. Por exemplo, se estivermos testando uma função que certamente modifica sua
entrada de alguma maneira, mas a forma dessa modificação depende do dia da
semana em que executamos os testes, talvez a melhor verificação seja afirmar
que a saída da função não é igual à entrada.

Por baixo dos panos, as macros `assert_eq!` e `assert_ne!` usam os operadores
`==` e `!=`, respectivamente. Quando as verificações falham, essas macros
imprimem seus argumentos usando formatação de depuração, o que significa que os
valores comparados precisam implementar as traits `PartialEq` e `Debug`. Todos
os tipos primitivos e a maior parte dos tipos da biblioteca padrão implementam
essas traits. Para structs e enums definidos por você, será necessário
implementar `PartialEq` para verificar igualdade entre esses tipos. Também será
necessário implementar `Debug` para imprimir os valores quando a verificação
falhar. Como ambas são traits deriváveis, como mencionado na Listagem 5-12 do
Capítulo 5, isso normalmente é tão simples quanto adicionar a anotação
`#[derive(PartialEq, Debug)]` à definição da sua struct ou enum. Veja o
Apêndice C, [“Traits deriváveis”][derivable-traits]<!-- ignore -->, para mais
detalhes sobre essas e outras traits deriváveis.

### Adicionando mensagens de falha personalizadas

Você também pode adicionar uma mensagem personalizada para ser impressa junto
com a mensagem de falha como argumentos opcionais das macros `assert!`,
`assert_eq!` e `assert_ne!`. Todos os argumentos especificados depois dos
argumentos obrigatórios são repassados à macro `format!` (discutida em
[“Concatenação com `+` ou `format!`”][concatenating]<!-- ignore -->, no
Capítulo 8), então você pode fornecer uma string de formatação com espaços
reservados `{}` e os valores que devem preenchê-los. Mensagens personalizadas
são úteis para documentar o que a verificação quer dizer; quando um teste
falha, você terá uma noção melhor do que está errado no código.

Por exemplo, digamos que temos uma função que cumprimenta as pessoas pelo nome
e queremos testar se o nome passado para a função aparece na saída:

<span class="filename">Nome do arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-05-greeter/src/lib.rs}}
```

Os requisitos desse programa ainda não foram definidos por completo, e temos
quase certeza de que o texto `Hello` no começo da saudação vai mudar. Decidimos
que não queremos ter de atualizar o teste sempre que os requisitos mudarem; por
isso, em vez de verificar igualdade exata com o valor retornado por
`greeting`, vamos apenas verificar se a saída contém o texto do parâmetro de
entrada.

Agora vamos introduzir um bug nesse código, alterando `greeting` para excluir
`name`, para ver como é a mensagem de falha padrão:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-06-greeter-with-bug/src/lib.rs:here}}
```

Executar esse teste produz o seguinte:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-06-greeter-with-bug/output.txt}}
```

Esse resultado apenas indica que a verificação falhou e em qual linha ela
está. Uma mensagem de falha mais útil mostraria o valor retornado por
`greeting`. Vamos adicionar uma mensagem de falha personalizada, composta por
uma string de formatação com um espaço reservado preenchido pelo valor real que
obtivemos da função `greeting`:

```rust,ignore
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-07-custom-failure-message/src/lib.rs:here}}
```

Agora, quando executarmos o teste, teremos uma mensagem de erro mais
informativa:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-07-custom-failure-message/output.txt}}
```

Conseguimos ver o valor que realmente obtivemos na saída do teste, o que ajuda
a depurar o que aconteceu, em vez de apenas o que esperávamos que tivesse
acontecido.

### Verificando pânicos com `should_panic`

Além de verificar valores de retorno, é importante confirmar se o código lida
com condições de erro da maneira esperada. Por exemplo, considere o tipo
`Guess` que criamos no Capítulo 9, na Listagem 9-13. Outro código que usa
`Guess` depende da garantia de que instâncias de `Guess` conterão apenas
valores entre 1 e 100. Podemos escrever um teste que garanta que tentar criar
uma instância de `Guess` com um valor fora desse intervalo provoque um pânico.

Fazemos isso adicionando o atributo `should_panic` à função de teste. O teste
passa se o código dentro da função entrar em pânico; o teste falha se o código
dentro da função não entrar em pânico.

A Listagem 11-8 mostra um teste que verifica se as condições de erro de
`Guess::new` acontecem quando esperamos.

<Listing number="11-8" file-name="src/lib.rs" caption="Testando que uma condição provocará um `panic!`">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-08/src/lib.rs}}
```

</Listing>

Colocamos o atributo `#[should_panic]` depois do atributo `#[test]` e antes da
função de teste à qual ele se aplica. Vamos ver o resultado quando esse teste
passa:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-08/output.txt}}
```

Parece bom! Agora vamos introduzir um bug em nosso código removendo a condição
de que a função `new` deve entrar em pânico quando o valor for maior que 100:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-08-guess-with-bug/src/lib.rs:here}}
```

Quando executarmos o teste da Listagem 11-8, ele falhará:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-08-guess-with-bug/output.txt}}
```

Nesse caso, não recebemos uma mensagem muito útil, mas, olhando a função de
teste, vemos que ela está anotada com `#[should_panic]`. A falha que obtivemos
significa que o código dentro da função de teste não provocou pânico.

Testes que usam `should_panic` podem ser imprecisos. Um teste com
`should_panic` passa mesmo que o código entre em pânico por um motivo diferente
daquele que esperávamos. Para tornar esses testes mais precisos, podemos
adicionar um parâmetro opcional `expected` ao atributo `should_panic`. O
executor de testes verificará se a mensagem de falha contém o texto fornecido.
Por exemplo, considere o código modificado de `Guess` na Listagem 11-9, em que
a função `new` entra em pânico com mensagens diferentes dependendo de o valor
ser pequeno demais ou grande demais.

<Listing number="11-9" file-name="src/lib.rs" caption="Testando um `panic!` com uma mensagem de pânico que contém uma substring especificada">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-09/src/lib.rs:here}}
```

</Listing>

Esse teste passará porque o valor que colocamos no parâmetro `expected` do
atributo `should_panic` é uma substring da mensagem com a qual a função
`Guess::new` entra em pânico. Poderíamos ter especificado a mensagem completa
de pânico esperada, que nesse caso seria `Guess value must be less than or
equal to 100, got 200`. O que você escolhe especificar depende de quanto da
mensagem é único ou dinâmico e de quão preciso você quer que o teste seja.
Neste caso, uma substring da mensagem de pânico já basta para garantir que o
código da função de teste execute o caso `else if value > 100`.

Para ver o que acontece quando um teste com `should_panic` e mensagem
`expected` falha, vamos introduzir novamente um bug no nosso código trocando os
corpos dos blocos `if value < 1` e `else if value > 100`:

```rust,ignore,not_desired_behavior
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-09-guess-with-panic-msg-bug/src/lib.rs:here}}
```

Desta vez, quando executarmos o teste `should_panic`, ele falhará:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-09-guess-with-panic-msg-bug/output.txt}}
```

A mensagem de falha indica que esse teste realmente entrou em pânico como
esperávamos, mas a mensagem de pânico não continha a string esperada
`less than or equal to 100`. A mensagem de pânico que recebemos neste caso foi
`Guess value must be greater than or equal to 1, got 200`. Agora já podemos
começar a descobrir onde está o bug!

### Usando `Result<T, E>` em testes

Até agora, todos os nossos testes entram em pânico quando falham. Também podemos
escrever testes que usem `Result<T, E>`! Aqui está o teste da Listagem 11-1,
reescrito para usar `Result<T, E>` e retornar um `Err` em vez de entrar em
pânico:

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-10-result-in-tests/src/lib.rs:here}}
```

A função `it_works` agora tem tipo de retorno `Result<(), String>`. No corpo da
função, em vez de chamar a macro `assert_eq!`, retornamos `Ok(())` quando o
teste passa e um `Err` contendo uma `String` quando ele falha.

Escrever testes para que retornem um `Result<T, E>` permite usar o operador de
interrogação no corpo dos testes, o que pode ser uma maneira conveniente de
escrever testes que devem falhar se qualquer operação interna retornar uma
variante `Err`.

Você não pode usar a anotação `#[should_panic]` em testes que usam
`Result<T, E>`. Para verificar que uma operação retorna uma variante `Err`,
_não_ use o operador de interrogação sobre o valor `Result<T, E>`. Em vez
disso, use `assert!(value.is_err())`.

Agora que você conhece várias maneiras de escrever testes, vamos ver o que
acontece quando executamos nossos testes e explorar as diferentes opções que
podemos usar com `cargo test`.

[concatenating]: ch08-02-strings.html#concatenating-with--or-format
[bench]: ../unstable-book/library-features/test.html
[ignoring]: ch11-02-running-tests.html#ignoring-tests-unless-specifically-requested
[subset]: ch11-02-running-tests.html#running-a-subset-of-tests-by-name
[controlling-how-tests-are-run]: ch11-02-running-tests.html#controlling-how-tests-are-run
[derivable-traits]: appendix-03-derivable-traits.html
[doc-comments]: ch14-02-publishing-to-crates-io.html#documentation-comments-as-tests
[paths-for-referring-to-an-item-in-the-module-tree]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html

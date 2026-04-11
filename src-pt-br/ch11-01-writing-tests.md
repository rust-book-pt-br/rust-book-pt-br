## Como escrever testes

_Testes_ são funções Rust que verificam se o código que não é de teste está
funcionando da maneira esperada. Os corpos das funções de teste normalmente
executam estas três ações:

- Configurar quaisquer dados ou estados necessários.
- Executar o código que deseja testar.
- Verificar se os resultados são os que você espera.

Vamos ver os recursos que o Rust fornece especificamente para escrever testes
que executam essas ações, incluindo o atributo `test`, algumas macros e o
atributo `should_panic`.

<!-- Old headings. Do not remove or links may break. -->

<a id="the-anatomy-of-a-test-function"></a>

### Estruturando Funções de Teste

Na forma mais simples, um teste em Rust é uma função anotada com o atributo
`test`. Atributos são metadados sobre partes do código Rust; um exemplo é o
atributo `derive`, que usamos com structs no Capítulo 5. Para transformar uma
função em uma função de teste, adicione `#[test]` na linha anterior a `fn`.
Quando você executa os testes com o comando `cargo test`, o Rust cria um
binário executor de testes que roda as funções anotadas e informa se cada
função de teste passou ou falhou.

Sempre que criamos um novo projeto de biblioteca com Cargo, um módulo de teste
com uma função de teste é gerado automaticamente. Esse módulo oferece um modelo
para escrever os testes, para que você não precise procurar a estrutura e a
sintaxe exatas toda vez que iniciar um novo projeto. Você pode adicionar
quantas funções de teste extras e quantos módulos de teste quiser.

Vamos explorar alguns aspectos de como os testes funcionam experimentando esse
teste-modelo antes de testarmos qualquer código de verdade. Depois,
escreveremos alguns testes mais realistas que chamam código que escrevemos e
afirmam que seu comportamento está correto.

Vamos criar um novo projeto de biblioteca chamado `adder` que somará dois números:

```console
$ cargo new adder --lib
     Created library `adder` project
$ cd adder
```

O conteúdo do arquivo _src/lib.rs_ em sua biblioteca `adder` deve ser
semelhante ao da Listagem 11-1.

<Listing number="11-1" file-name="src/lib.rs" caption="O código gerado automaticamente por `cargo new`">

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

O arquivo começa com um exemplo de função `add`, para que tenhamos algo para
testar.

Por enquanto, vamos nos concentrar apenas na função `it_works`. Observe a
anotação `#[test]`: esse atributo indica que esta é uma função de teste, então
o executor de testes sabe tratá-la como tal. Também podemos ter funções que não
são testes dentro do módulo `tests`, para ajudar a configurar cenários comuns
ou executar operações recorrentes, por isso sempre precisamos indicar quais
funções são testes.

O corpo da função de exemplo usa a macro `assert_eq!` para afirmar que
`result`, que contém o resultado da chamada de `add` com 2 e 2, é igual a 4.
Essa asserção serve como exemplo do formato de um teste típico. Vamos executá-lo
para ver se ele passa.

O comando `cargo test` executa todos os testes do projeto, como mostra a
Listagem 11-2.

<Listing number="11-2" caption="A saída da execução do teste gerado automaticamente">

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-01/output.txt}}
```

</Listing>

O Cargo compilou e executou o teste. Vemos a linha `running 1 test`. A linha
seguinte mostra o nome da função de teste gerada, chamada `tests::it_works`, e
que o resultado da execução desse teste é `ok`. O resumo geral `test result:
ok.` significa que todos os testes passaram, e a parte que contém `1 passed; 0
failed` totaliza o número de testes aprovados e reprovados.

É possível marcar um teste como ignorado para que ele não seja executado em uma
determinada situação; veremos isso na seção [“Ignorando testes, a menos que
seja solicitado especificamente”][ignoring]<!-- ignore -->, mais adiante neste
capítulo. Como não fizemos isso aqui, o resumo mostra `0 ignored`. Também
podemos passar um argumento ao comando `cargo test` para executar apenas testes
cujo nome corresponda a uma string; isso é chamado de _filtragem_ e veremos o
tema na seção [“Executando um subconjunto de testes por nome”][subset]<!--
ignore -->. Aqui, não filtramos os testes em execução, então o final do resumo
mostra `0 filtered out`.

A estatística `0 measured` é para testes de benchmark que medem desempenho. No
momento em que este livro foi escrito, testes de benchmark estavam disponíveis
apenas no Rust nightly. Veja [a documentação sobre testes de benchmark][bench]
para saber mais.

A próxima parte da saída de teste, começando em `Doc-tests adder`, corresponde
aos resultados de quaisquer testes de documentação. Ainda não temos testes de
documentação, mas o Rust pode compilar qualquer exemplo de código que apareça
na nossa documentação de API. Esse recurso ajuda a manter a documentação e o
código sincronizados! Veremos como escrever testes de documentação na seção
[“Comentários de documentação como testes”][doc-comments]<!-- ignore --> do
Capítulo 14. Por enquanto, vamos ignorar a saída `Doc-tests`.

Vamos começar a personalizar o teste de acordo com as nossas necessidades.
Primeiro, mude o nome da função `it_works` para um nome diferente, como
`exploration`, assim:

<span class="filename">Nome do arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-01-changing-test-name/src/lib.rs}}
```

Depois, execute `cargo test` novamente. A saída agora mostra `exploration` em
vez de `it_works`:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-01-changing-test-name/output.txt}}
```

Agora adicionaremos outro teste, mas desta vez faremos um teste que falha!
Testes falham quando algo na função de teste entra em pânico. Cada teste é
executado em uma nova thread, e quando a thread principal vê que a thread de um
teste morreu, o teste é marcado como falho. No Capítulo 9, falamos sobre como a
forma mais simples de entrar em pânico é chamar a macro `panic!`. Insira o novo
teste como uma função chamada `another`, e então seu arquivo _src/lib.rs_ se
parecerá com a Listagem 11-3.

<Listing number="11-3" file-name="src/lib.rs" caption="Adicionando um segundo teste que falhará porque chamamos a macro `panic!`">

```rust,panics,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-03/src/lib.rs}}
```

</Listing>

Execute os testes novamente usando `cargo test`. A saída deve ser semelhante à
Listagem 11-4, que mostra que nosso teste `exploration` passou e `another`
falhou.

<Listing number="11-4" caption="Resultados dos testes quando um passa e outro falha">

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-03/output.txt}}
```

</Listing>

<!-- manual-regeneration
listagens em pânico rg/ch11-writing-automated-tests/listing-11-03/output.txt
verifique se o número da linha do panic corresponde ao número da linha no parágrafo seguinte
 -->

Em vez de `ok`, a linha `test tests::another` mostra `FAILED`. Duas novas
seções aparecem entre os resultados individuais e o resumo. A primeira exibe o
motivo detalhado de cada falha de teste. Neste caso, vemos o detalhe de que
`tests::another` falhou porque entrou em pânico com a mensagem `Make this test
fail` na linha 17 do arquivo _src/lib.rs_. A próxima seção lista apenas os
nomes de todos os testes que falharam, o que é útil quando há muitos testes e
muitos detalhes de saída de falha. Podemos usar o nome de um teste com falha
para executar apenas esse teste e depurá-lo com mais facilidade; falaremos mais
sobre formas de executar testes na seção [“Controlando como os testes são
executados”][controlling-how-tests-are-run]<!-- ignore -->.

A linha de resumo aparece ao final: no geral, o resultado do nosso teste é
`FAILED`. Tivemos um teste aprovado e um teste reprovado.

Agora que você viu como são os resultados do teste em diferentes cenários,
vejamos algumas macros além de `panic!` que são úteis em testes.

<!-- Old headings. Do not remove or links may break. -->

<a id="checking-results-with-the-assert-macro"></a>

### Verificando resultados com `assert!`

A macro `assert!`, fornecida pela biblioteca padrão, é útil quando você quer
garantir que alguma condição em um teste seja avaliada como `true`. Fornecemos
à macro `assert!` um argumento que é avaliado como um booleano. Se o valor for
`true`, nada acontece e o teste passa. Se o valor for `false`, a macro
`assert!` chama `panic!` para fazer o teste falhar. Usar a macro `assert!` nos
ajuda a verificar se nosso código está funcionando da maneira que pretendemos.

No Capítulo 5, na Listagem 5-15, usamos uma struct `Rectangle` e um método
`can_hold`, que aparecem novamente aqui na Listagem 11-5. Vamos colocar esse
código no arquivo _src/lib.rs_ e, em seguida, escrever alguns testes para ele
usando a macro `assert!`.

<Listing number="11-5" file-name="src/lib.rs" caption="A struct `Rectangle` e seu método `can_hold` do Capítulo 5">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-05/src/lib.rs}}
```

</Listing>

O método `can_hold` retorna um booleano, o que significa que ele é um caso de
uso perfeito para a macro `assert!`. Na Listagem 11-6, escrevemos um teste que
exercita o método `can_hold` criando uma instância de `Rectangle` com largura 8
e altura 7 e afirmando que ela pode conter outra instância de `Rectangle` com
largura 5 e altura 1.

<Listing number="11-6" file-name="src/lib.rs" caption="Um teste para `can_hold` que verifica se um retângulo maior realmente pode conter um menor">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-06/src/lib.rs:here}}
```

</Listing>

Observe a linha `use super::*;` dentro do módulo `tests`. O módulo `tests` é um
módulo regular que segue as regras usuais de visibilidade abordadas no Capítulo
7, na seção [“Caminhos para referenciar um item na árvore de módulos”]
[paths-for-referring-to-an-item-in-the-module-tree]<!-- ignore -->. Como o
módulo `tests` é um módulo interno, precisamos trazer o código em teste do
módulo externo para o escopo do módulo interno. Usamos um glob aqui, então
qualquer coisa que definirmos no módulo externo fica disponível para este
módulo `tests`.

Chamamos nosso teste de `larger_can_hold_smaller` e criamos as duas instâncias
de `Rectangle` de que precisamos. Em seguida, chamamos a macro `assert!` e
passamos a ela o resultado de `larger.can_hold(&smaller)`. Essa expressão deve
retornar `true`, então nosso teste deve passar. Vamos conferir!

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-06/output.txt}}
```

Ele passa! Vamos adicionar outro teste, desta vez afirmando que um retângulo
menor não pode conter um retângulo maior:

<span class="filename">Nome do arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-02-adding-another-rectangle-test/src/lib.rs:here}}
```

Como o resultado correto da função `can_hold` neste caso é `false`, precisamos
negar esse resultado antes de passá-lo para a macro `assert!`. Como resultado,
nosso teste será aprovado se `can_hold` retornar `false`:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-02-adding-another-rectangle-test/output.txt}}
```

Dois testes passam! Agora vamos ver o que acontece com os resultados quando
introduzimos um bug no nosso código. Vamos mudar a implementação do método
`can_hold`, substituindo o sinal de maior que (`>`) por um sinal de menor que
(`<`) na comparação das larguras:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-03-introducing-a-bug/src/lib.rs:here}}
```

A execução dos testes agora produz o seguinte:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-03-introducing-a-bug/output.txt}}
```

Nossos testes detectaram o bug! Como `larger.width` é `8` e `smaller.width` é
`5`, a comparação das larguras em `can_hold` agora retorna `false`: 8 não é
menor que 5.

<!-- Old headings. Do not remove or links may break. -->

<a id="testing-equality-with-the-assert_eq-and-assert_ne-macros"></a>

### Testando igualdade com `assert_eq!` e `assert_ne!`

Uma maneira comum de verificar funcionalidade é testar a igualdade entre o
resultado do código sob teste e o valor que você espera que ele retorne. Você
poderia fazer isso usando a macro `assert!` e passando a ela uma expressão com
o operador `==`. No entanto, esse é um teste tão comum que a biblioteca padrão
fornece um par de macros, `assert_eq!` e `assert_ne!`, para fazê-lo de forma
mais conveniente. Essas macros comparam dois argumentos por igualdade ou
desigualdade, respectivamente. Elas também imprimem os dois valores se a
asserção falhar, o que torna mais fácil ver _por que_ o teste falhou; em
contraste, a macro `assert!` apenas indica que recebeu um valor `false` para a
expressão `==`, sem imprimir os valores que levaram a esse `false`.

Na Listagem 11-7, escrevemos uma função chamada `add_two` que adiciona `2` ao
seu parâmetro e então testamos essa função usando a macro `assert_eq!`.

<Listing number="11-7" file-name="src/lib.rs" caption="Testando a função `add_two` usando a macro `assert_eq!`">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-07/src/lib.rs}}
```

</Listing>

Vamos verificar se passa!

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-07/output.txt}}
```

Criamos uma variável chamada `result` que contém o resultado da chamada
`add_two(2)`. Então, passamos `result` e `4` como argumentos para a macro
`assert_eq!`. A linha de saída para esse teste é `test tests::it_adds_two...
ok`, e o texto `ok` indica que nosso teste foi aprovado!

Vamos introduzir um bug em nosso código para ver como fica `assert_eq!` quando
falha. Altere a implementação da função `add_two` para adicionar `3`:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-04-bug-in-add-two/src/lib.rs:here}}
```

Execute os testes novamente:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-04-bug-in-add-two/output.txt}}
```

Nosso teste detectou o bug! O teste `tests::it_adds_two` falhou, e a mensagem
nos diz que a asserção que falhou foi `left == right` e quais eram os valores
de `left` e `right`. Essa mensagem nos ajuda a começar a depuração: o argumento
`left`, onde tínhamos o resultado da chamada `add_two(2)`, foi `5`, mas o
argumento `right` era `4`. Você pode imaginar como isso é especialmente útil
quando temos muitos testes em execução.

Observe que, em algumas linguagens e frameworks de teste, os parâmetros das
funções de asserção de igualdade são chamados `expected` e `actual`, e a ordem
em que especificamos os argumentos importa. No entanto, em Rust, eles são
chamados `left` e `right`, e a ordem em que especificamos o valor esperado e o
valor produzido pelo código não importa. Poderíamos escrever a asserção deste
teste como `assert_eq!(4, result)`, o que resultaria na mesma mensagem de falha
indicando que a asserção `left == right` falhou.

A macro `assert_ne!` passa se os dois valores que fornecemos não forem iguais e
falha se forem iguais. Essa macro é mais útil em casos nos quais não temos
certeza de qual valor _será_, mas sabemos qual valor definitivamente _não deve_
ser. Por exemplo, se estivermos testando uma função que certamente mudará sua
entrada de alguma forma, mas a maneira como a entrada é alterada depende do dia
da semana em que executamos nossos testes, a melhor afirmação pode ser que a
saída da função não seja igual à entrada.

Por baixo dos panos, as macros `assert_eq!` e `assert_ne!` usam os operadores
`==` e `!=`, respectivamente. Quando as asserções falham, essas macros imprimem
seus argumentos usando formatação de debug, o que significa que os valores
comparados precisam implementar os traits `PartialEq` e `Debug`. Todos os tipos
primitivos e a maioria dos tipos da biblioteca padrão implementam esses traits.
Para structs e enums que você mesmo definir, precisará implementar `PartialEq`
para poder afirmar igualdade desses tipos. Também precisará implementar
`Debug` para imprimir os valores quando a asserção falhar. Como ambos são
traits deriváveis, conforme mencionado na Listagem 5-12 do Capítulo 5, isso
geralmente é tão simples quanto adicionar a anotação
`#[derive(PartialEq, Debug)]` à definição da sua struct ou enum. Veja o
Apêndice C, [“Traits deriváveis”][derivable-traits]<!-- ignore -->, para mais
detalhes sobre esses e outros traits deriváveis.

### Adicionando Mensagens de Falha Personalizadas

Você também pode adicionar uma mensagem personalizada para ser impressa junto
com a mensagem de falha, como argumentos opcionais para as macros `assert!`,
`assert_eq!` e `assert_ne!`. Quaisquer argumentos especificados depois dos
argumentos obrigatórios são repassados para a macro `format!`, discutida em
[“Concatenando com `+` ou `format!`”][concatenating]<!-- ignore --> no
Capítulo 8. Assim, você pode passar uma format string que contém placeholders
`{}` e valores para preenchê-los. Mensagens personalizadas são úteis para
documentar o significado de uma asserção; quando um teste falhar, você terá uma
ideia melhor de qual é o problema no código.

Por exemplo, digamos que temos uma função que cumprimenta pessoas pelo nome e
queremos testar se o nome que passamos para a função aparece na saída:

<span class="filename">Nome do arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-05-greeter/src/lib.rs}}
```

Os requisitos deste programa ainda não foram definidos por completo, e estamos
razoavelmente certos de que o texto `Hello` no início da saudação vai mudar.
Decidimos que não queremos atualizar o teste toda vez que os requisitos
mudarem, então, em vez de verificar igualdade exata com o valor retornado pela
função `greeting`, afirmaremos apenas que a saída contém o texto do parâmetro
de entrada.

Agora vamos introduzir um bug nesse código alterando `greeting` para excluir
`name`, a fim de ver como é a falha padrão do teste:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-06-greeter-with-bug/src/lib.rs:here}}
```

A execução deste teste produz o seguinte:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-06-greeter-with-bug/output.txt}}
```

Esse resultado apenas indica que a asserção falhou e em qual linha isso
aconteceu. Uma mensagem de falha mais útil imprimiria o valor retornado pela
função `greeting`. Vamos adicionar uma mensagem de falha personalizada composta
por uma format string com um placeholder preenchido com o valor real que
obtivemos da função `greeting`:

```rust,ignore
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-07-custom-failure-message/src/lib.rs:here}}
```

Agora, quando executarmos o teste, obteremos uma mensagem de erro mais
informativa:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-07-custom-failure-message/output.txt}}
```

Podemos ver o valor que realmente obtivemos na saída do teste, o que nos
ajudaria a depurar o que aconteceu em vez de apenas o que esperávamos que
acontecesse.

### Verificando pânico com `should_panic`

Além de verificar valores de retorno, é importante verificar se nosso código
lida com condições de erro conforme esperamos. Por exemplo, considere o tipo
`Guess` que criamos no Capítulo 9, na Listagem 9-13. Outro código que usa
`Guess` depende da garantia de que instâncias de `Guess` conterão apenas
valores entre 1 e 100. Podemos escrever um teste que garanta que a tentativa de
criar uma instância de `Guess` com um valor fora desse intervalo entre em
pânico.

Fazemos isso adicionando o atributo `should_panic` à função de teste. O teste
passa se o código dentro da função entrar em pânico; o teste falha se o código
dentro da função não entrar em pânico.

A Listagem 11-8 mostra um teste que verifica se as condições de erro de `Guess::new`
acontecem quando esperamos que aconteçam.

<Listing number="11-8" file-name="src/lib.rs" caption="Testando que uma condição causará um `panic!`">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-08/src/lib.rs}}
```

</Listing>

Colocamos o atributo `#[should_panic]` depois do atributo `#[test]` e antes da
função de teste à qual ele se aplica. Vejamos o resultado quando esse teste
passa:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-08/output.txt}}
```

Parece bom! Agora vamos introduzir um bug em nosso código removendo a condição
que faz a função `new` entrar em pânico se o valor for maior que 100:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-08-guess-with-bug/src/lib.rs:here}}
```

Quando executarmos o teste da Listagem 11-8, ele falhará:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-08-guess-with-bug/output.txt}}
```

Não recebemos uma mensagem muito útil nesse caso, mas, quando olhamos para a
função de teste, vemos que ela está anotada com `#[should_panic]`. A falha que
tivemos significa que o código na função de teste não causou pânico.

Os testes que usam `should_panic` podem ser imprecisos. Um teste
`should_panic` passaria mesmo que o teste entrasse em pânico por um motivo
diferente daquele que estávamos esperando. Para tornar testes `should_panic`
mais precisos, podemos adicionar um parâmetro opcional `expected` ao atributo
`should_panic`. O executor de testes se certificará de que a mensagem de falha
contenha o texto fornecido. Por exemplo, considere o código modificado para
`Guess` na Listagem 11-9, em que a função `new` entra em pânico com mensagens
diferentes dependendo de o valor ser pequeno demais ou grande demais.

<Listing number="11-9" file-name="src/lib.rs" caption="Testando um `panic!` com uma mensagem contendo uma substring especificada">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-09/src/lib.rs:here}}
```

</Listing>

Esse teste passará porque o valor colocado no parâmetro `expected` do atributo
`should_panic` é uma substring da mensagem com a qual a função `Guess::new`
entra em pânico. Poderíamos ter especificado toda a mensagem de panic esperada,
que neste caso seria `Guess value must be less than or equal to 100, got 200`.
O que você escolhe especificar depende de quanto da mensagem de panic é único
ou dinâmico e de quão preciso você quer que o teste seja. Neste caso, uma
substring da mensagem de panic é suficiente para garantir que o código na
função de teste execute o caso `else if value > 100`.

Para ver o que acontece quando um teste `should_panic` com mensagem `expected`
falha, vamos novamente introduzir um bug no nosso código trocando os corpos dos
blocos `if value < 1` e `else if value > 100`:

```rust,ignore,not_desired_behavior
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-09-guess-with-panic-msg-bug/src/lib.rs:here}}
```

Desta vez, quando executarmos o teste `should_panic`, ele falhará:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-09-guess-with-panic-msg-bug/output.txt}}
```

A mensagem de falha indica que esse teste realmente entrou em pânico como
esperávamos, mas a mensagem de panic não incluía a string esperada `less than
or equal to 100`. A mensagem de panic que recebemos neste caso foi `Guess value
must be greater than or equal to 1, got 200`. Agora podemos começar a descobrir
onde está o bug!

### Usando `Result<T, E>` em testes

Todos os nossos testes até agora entram em pânico quando falham. Também podemos
escrever testes que usam `Result<T, E>`! Aqui está o teste da Listagem 11-1,
reescrito para usar `Result<T, E>` e retornar um `Err` em vez de entrar em
pânico:

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-10-result-in-tests/src/lib.rs:here}}
```

A função `it_works` agora tem o tipo de retorno `Result<(), String>`. No corpo
da função, em vez de chamar a macro `assert_eq!`, retornamos `Ok(())` quando o
teste passa e um `Err` contendo uma `String` quando o teste falha.

Escrever testes para que retornem um `Result<T, E>` permite que você use o
operador ponto de interrogação no corpo dos testes, o que pode ser uma maneira
conveniente de escrever testes que devem falhar se alguma operação dentro deles
retornar uma variante `Err`.

Você não pode usar a anotação `#[should_panic]` em testes que usam
`Result<T, E>`. Para afirmar que uma operação retorna uma variante `Err`, _não_
use o operador ponto de interrogação no valor `Result<T, E>`. Em vez disso,
use `assert!(value.is_err())`.

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

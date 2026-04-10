## Como escrever testes

_Testes_ são funções Rust que verificam se o código que não é de teste está funcionando em
da maneira esperada. Os corpos das funções de teste normalmente executam essas três
ações:

- Configure quaisquer dados ou estados necessários.
- Execute o código que deseja testar.
- Afirme que os resultados são os que você espera.

Vejamos os recursos que o Rust fornece especificamente para escrever testes que
execute essas ações, que incluem o atributo `test`, algumas macros e o
Atributo ` should_panic`.

<!-- Old headings. Do not remove or links may break. -->

<a id="the-anatomy-of-a-test-function"></a>

### Structuring Test Functions

Na sua forma mais simples, um teste em Rust é uma função anotada com o `test`
atributo. Atributos são metadados sobre partes do código Rust; um exemplo é
o atributo ` derive`que usamos com estruturas no Capítulo 5. Para alterar uma função
em uma função de teste, adicione ` #[test]`na linha antes de ` fn`. Quando você executa seu
testes com o comando ` cargo test`, Rust cria um binário do executor de teste que executa
as funções anotadas e relatórios sobre se cada função de teste foi aprovada ou
falha.

Sempre que fazemos um novo projeto de biblioteca com Cargo, um módulo de teste com um teste
função nele é gerada automaticamente para nós. Este módulo oferece uma
modelo para escrever seus testes para que você não precise procurar o exato
estrutura e sintaxe sempre que você inicia um novo projeto. Você pode adicionar quantos
funções de teste adicionais e quantos módulos de teste você desejar!

Exploraremos alguns aspectos de como os testes funcionam, experimentando o modelo
test antes de realmente testarmos qualquer código. Então, escreveremos alguns testes do mundo real
que chamam algum código que escrevemos e afirmam que seu comportamento está correto.

Vamos criar um novo projeto de biblioteca chamado `adder` que somará dois números:

```console
$ cargo new adder --lib
     Created library `adder` project
$ cd adder
```

O conteúdo do arquivo _src/lib.rs_ em sua biblioteca `adder` deve ser semelhante a
Listagem 11-1.

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

O arquivo começa com um exemplo de função `add` para que tenhamos algo para
teste.

Por enquanto, vamos nos concentrar apenas na função `it_works`. Observe o ` #[test]`
anotação: Este atributo indica que esta é uma função de teste, então o teste
runner sabe tratar esta função como um teste. Também podemos ter não-teste
funções no módulo ` tests`para ajudar a configurar cenários comuns ou executar
operações comuns, por isso sempre precisamos indicar quais funções são testes.

O corpo da função de exemplo usa a macro `assert_eq!` para afirmar que `result`,
que contém o resultado da chamada de ` add`com 2 e 2, é igual a 4. Este
asserção serve como exemplo do formato de um teste típico. Vamos executá-lo
para ver se esse teste passa.

The `cargo test` command runs all tests in our project, as shown in Listing
11-2.

<Listing number="11-2" caption="A saída da execução do teste gerado automaticamente">

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-01/output.txt}}
```

</Listing>

Cargo compilou e executou o teste. Vemos a linha `running 1 test`. O próximo
linha mostra o nome da função de teste gerada, chamada ` tests::it_works`,
e que o resultado da execução desse teste é ` ok`. O resumo geral ` test
result: ok.`significa que todos os testes foram aprovados e a parte que contém ` 1
passed; 0 failed`totaliza o número de testes que foram aprovados ou reprovados.

É possível marcar um teste como ignorado para que ele não seja executado em um determinado
instância; abordaremos isso em [“Ignorando testes, a menos que especificamente
Solicitado”][ignoring]seção <!-- ignore --> posteriormente neste capítulo. Porque nós
não fiz isso aqui, o resumo mostra `0 ignored`. Também podemos passar um
argumento para o comando ` cargo test`para executar apenas testes cujo nome corresponda a um
corda; isso é chamado de _filtragem_ e abordaremos isso no [“Executando um
Subconjunto de testes por nome”][subset]seção <!-- ignore -->. Aqui, não temos
filtrou os testes que estão sendo executados, então o final do resumo mostra ` 0 filtered out`.

A estatística `0 measured` é para testes de benchmark que medem o desempenho.
Os testes de benchmark estão, no momento em que este livro foi escrito, disponíveis apenas no Rust noturno. Veja
[a documentação sobre testes de benchmark][bench] para saber mais.

A próxima parte da saída de teste começando em `Doc-tests adder` é para o
resultados de quaisquer testes de documentação. Ainda não temos nenhum teste de documentação,
mas Rust pode compilar qualquer exemplo de código que apareça em nossa documentação de API.
Este recurso ajuda a manter seus documentos e seu código sincronizados! Discutiremos como
escrever testes de documentação em [“Comentários de documentação como
Testes”][doc-comments]seção <!-- ignore --> do Capítulo 14. Por enquanto, vamos
ignore a saída `Doc-tests`.

Vamos começar a personalizar o teste de acordo com nossas necessidades. Primeiro, mude o nome de
a função `it_works` para um nome diferente, como `exploration`, assim:

<span class="filename">Filename: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-01-changing-test-name/src/lib.rs}}
```

Then, run `cargo test` again. The output now shows `exploration` instead of
`it_works`:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-01-changing-test-name/output.txt}}
```

Agora adicionaremos outro teste, mas desta vez faremos um teste que falha! Testes
falha quando algo na função de teste entra em pânico. Cada teste é executado em um novo
thread, e quando o thread principal vê que um teste thread morreu, o teste é
marcado como falhou. No Capítulo 9, falamos sobre como a maneira mais simples de panic
é chamar a macro `panic!`. Insira o novo teste como uma função chamada
` another`, então seu arquivo _src/lib.rs_ se parece com a Listagem 11-3.

<Listing number="11-3" file-name="src/lib.rs" caption="Adicionando um segundo teste que falhará porque chamamos a macro `panic!`">

```rust,panics,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-03/src/lib.rs}}
```

</Listing>

Execute os testes novamente usando `cargo test`. A saída deve ser semelhante à Listagem
11-4, que mostra que nosso teste ` exploration`passou e ` another`falhou.

<Listing number="11-4" caption="Resultados dos testes quando um passa e outro falha">

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-03/output.txt}}
```

</Listing>

<!-- manual-regeneration
listagens em pânico rg/ch11-writing-automated-tests/listing-11-03/output.txt
verifique se o número da linha do panic corresponde ao número da linha no parágrafo seguinte
 -->

Em vez de `ok`, a linha ` test tests::another`mostra ` FAILED`. Dois novos
seções aparecem entre os resultados individuais e o resumo: A primeira
exibe o motivo detalhado de cada falha de teste. Neste caso, obtemos o
detalha que ` tests::another`falhou porque entrou em pânico com a mensagem ` Make
this test fail`na linha 17 no arquivo _src/lib.rs_. A próxima seção lista
apenas os nomes de todos os testes que falharam, o que é útil quando há muitos
testes e muitos resultados detalhados de testes com falha. Podemos usar o nome de um
falhar no teste para executar apenas esse teste para depurá-lo mais facilmente; falaremos mais
sobre maneiras de executar testes no [“Controlando como os testes são
Executar”][controlling-how-tests-are-run]seção <!-- ignore -->.

A linha de resumo é exibida no final: No geral, o resultado do nosso teste é `FAILED`. Nós
teve um teste aprovado e um teste reprovado.

Agora que você viu como são os resultados do teste em diferentes cenários,
vejamos algumas macros além de `panic!` que são úteis em testes.

<!-- Old headings. Do not remove or links may break. -->

<a id="checking-results-with-the-assert-macro"></a>

### Verificando resultados com `assert!`

A macro `assert!`, fornecida pela biblioteca padrão, é útil quando você deseja
para garantir que alguma condição em um teste seja avaliada como ` true`. Nós damos o
Macro ` assert!`um argumento que é avaliado como um booleano. Se o valor for
` true `, nada acontece e o teste passa. Se o valor for` false `, o
A macro` assert! `chama` panic! `para causar falha no teste. Usando o` assert!`
macro nos ajuda a verificar se nosso código está funcionando da maneira que pretendemos.

No Capítulo 5, Listagem 5-15, usamos uma estrutura `Rectangle` e uma estrutura `can_hold`
método, que são repetidos aqui na Listagem 11-5. Vamos colocar esse código no
_src/lib.rs_ e, em seguida, escreva alguns testes para ele usando a macro ` assert!`.

<Listing number="11-5" file-name="src/lib.rs" caption="A struct `Rectangle` e seu método `can_hold` do Capítulo 5">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-05/src/lib.rs}}
```

</Listing>

O método `can_hold` retorna um booleano, o que significa que é um caso de uso perfeito
para a macro `assert!`. Na Listagem 11-6, escrevemos um teste que exercita o
Método ` can_hold`criando uma instância ` Rectangle`que tem uma largura de 8 e
uma altura de 7 e afirmando que pode conter outra instância ` Rectangle`que
tem largura 5 e altura 1.

<Listing number="11-6" file-name="src/lib.rs" caption="Um teste para `can_hold` que verifica se um retângulo maior realmente pode conter um menor">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-06/src/lib.rs:here}}
```

</Listing>

Observe a linha `use super::*;` dentro do módulo `tests`. O módulo ` tests`é
um módulo regular que segue as regras usuais de visibilidade que abordamos no Capítulo
7 em [“Caminhos para referência a um item no módulo
Tree”][paths-for-referring-to-an-item-in-the-module-tree]<!-- ignore -->
seção. Como o módulo `tests` é um módulo interno, precisamos trazer o
código em teste no módulo externo no escopo do módulo interno. Nós usamos
um glob aqui, então qualquer coisa que definirmos no módulo externo está disponível para este
Módulo `tests`.

Chamamos nosso teste de `larger_can_hold_smaller` e criamos os dois
Instâncias `Rectangle` que precisamos. Então, chamamos a macro `assert!` e
passou o resultado da chamada de `larger.can_hold(&smaller)`. Esta expressão é
deveria retornar ` true`, então nosso teste deve passar. Vamos descobrir!

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-06/output.txt}}
```

Isso passa! Vamos adicionar outro teste, desta vez afirmando que um valor menor
retângulo não pode conter um retângulo maior:

<span class="filename">Filename: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-02-adding-another-rectangle-test/src/lib.rs:here}}
```

Como o resultado correto da função `can_hold` neste caso é `false`,
precisamos negar esse resultado antes de passá-lo para a macro ` assert!`. Como um
resultado, nosso teste será aprovado se ` can_hold`retornar ` false`:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-02-adding-another-rectangle-test/output.txt}}
```

Dois testes que passam! Agora vamos ver o que acontece com os resultados dos nossos testes quando
introduzir um bug em nosso código. Vamos mudar a implementação do `can_hold`
método substituindo o sinal de maior que (` > `) por um sinal de menor que (` <`)
quando compara as larguras:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-03-introducing-a-bug/src/lib.rs:here}}
```

A execução dos testes agora produz o seguinte:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-03-introducing-a-bug/output.txt}}
```

Nossos testes detectaram o bug! Porque `larger.width` é `8` e `smaller.width` é
`5 `, a comparação das larguras em` can_hold `agora retorna` false`: 8 não é
menos de 5.

<!-- Old headings. Do not remove or links may break. -->

<a id="testing-equality-with-the-assert_eq-and-assert_ne-macros"></a>

### Testando igualdade com `assert_eq!` e `assert_ne!`

Uma maneira comum de verificar a funcionalidade é testar a igualdade entre o resultado
do código em teste e o valor que você espera que o código retorne. Você poderia
faça isso usando a macro `assert!` e passando para ela uma expressão usando o
Operador `==`. No entanto, este é um teste tão comum que a biblioteca padrão
fornece um par de macros – ` assert_eq!`e ` assert_ne!`– para realizar este teste
mais convenientemente. Estas macros comparam dois argumentos para igualdade ou
desigualdade, respectivamente. Eles também imprimirão os dois valores se a afirmação
falha, o que torna mais fácil ver _por que_ o teste falhou; inversamente, o
A macro ` assert!`indica apenas que obteve um valor ` false`para o ` ==`
expressão, sem imprimir os valores que levaram ao valor ` false`.

Na Listagem 11-7, escrevemos uma função chamada `add_two` que adiciona `2` ao seu
parâmetro e então testamos esta função usando a macro `assert_eq!`.

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
`add_two(2) `. Então, passamos` result `e` 4 `como argumentos para o
Macro` assert_eq! `. A linha de saída para este teste é` test tests::it_adds_two... ok `, e o texto` ok`indica que nosso teste foi aprovado!

Vamos introduzir um bug em nosso código para ver como fica `assert_eq!` quando
falha. Altere a implementação da função `add_two` para adicionar `3`:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-04-bug-in-add-two/src/lib.rs:here}}
```

Execute os testes novamente:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-04-bug-in-add-two/output.txt}}
```

Nosso teste detectou o bug! O teste `tests::it_adds_two` falhou e a mensagem
nos diz que a afirmação que falhou foi `left == right` e qual o `left`
e os valores ` right`são. Esta mensagem nos ajuda a iniciar a depuração: O ` left`
argumento, onde tivemos o resultado da chamada de ` add_two(2)`, foi ` 5`, mas o
O argumento ` right`era ` 4`. Você pode imaginar que isso seria especialmente útil
quando temos muitos testes em andamento.

Observe que em algumas linguagens e estruturas de teste, os parâmetros de igualdade
funções de asserção são chamadas `expected` e `actual`, e a ordem em que
especificamos os assuntos dos argumentos. No entanto, em Rust, eles são chamados de ` left`e
` right `e a ordem em que especificamos o valor que esperamos e o valor
o código produz não importa. Poderíamos escrever a afirmação neste teste como
` assert_eq!(4, result) `, o que resultaria na mesma mensagem de falha que
exibe` ` assertion`esquerda == direita ` failed``.

A macro `assert_ne!` será aprovada se os dois valores que fornecemos não forem iguais e
falhará se forem iguais. Esta macro é mais útil para casos em que não estamos
tenho certeza de qual valor _será_, mas sabemos qual valor definitivamente _não deveria_
ser. Por exemplo, se estivermos testando uma função que certamente mudará seu
entrada de alguma forma, mas a forma como a entrada é alterada depende do dia
da semana em que executamos nossos testes, a melhor coisa a afirmar pode ser que o
a saída da função não é igual à entrada.

Superficialmente, as macros `assert_eq!` e `assert_ne!` usam os operadores
`== ` e`!= `, respectivamente. Quando as asserções falham, essas macros imprimem seus
argumentos usando formatação de depuração, o que significa que os valores que estão sendo comparados devem
implementar o` PartialEq `e` Debug `traits. Todos os tipos primitivos e a maioria
os tipos de biblioteca padrão implementam estes traits. Para estruturas e enums que
você mesmo se define, precisará implementar` PartialEq `para afirmar a igualdade de
esses tipos. Você também precisará implementar` Debug `para imprimir os valores quando o
afirmação falha. Como ambos traits são traits deriváveis, conforme mencionado em
Listagem 5-12 no Capítulo 5, isso geralmente é tão simples quanto adicionar o
Anotação` #[derive(PartialEq, Debug)]`para sua definição de struct ou enum. Veja
Apêndice C, [“Características Deriváveis,”][derivable-traits]<!-- ignore --> para mais
detalhes sobre estes e outros traits deriváveis.

### Adding Custom Failure Messages

Você também pode adicionar uma mensagem personalizada para ser impressa com a mensagem de falha como
argumentos opcionais para as macros `assert!`, ` assert_eq!`e ` assert_ne!`. Qualquer
argumentos especificados depois que os argumentos necessários são passados para o
Macro ` format!`(discutida em [“Concatenando com ` +`ou
` format! `”][concatenating]<!--
ignore --> no Capítulo 8), para que você possa passar um format string que contém` {}`
espaços reservados e valores para ir nesses espaços reservados. Mensagens personalizadas são úteis
para documentar o que significa uma afirmação; quando um teste falhar, você terá uma melhor
ideia de qual é o problema com o código.

Por exemplo, digamos que temos uma função que cumprimenta as pessoas pelo nome e
queremos testar se o nome que passamos para a função aparece na saída:

<span class="filename">Filename: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-05-greeter/src/lib.rs}}
```

Os requisitos para este programa ainda não foram acordados e estamos
tenho certeza que o texto `Hello` no início da saudação mudará. Nós
decidimos que não queremos atualizar o teste quando os requisitos mudarem,
então, em vez de verificar a igualdade exata com o valor retornado do
Função `greeting`, apenas afirmaremos que a saída contém o texto do
parâmetro de entrada.

Agora vamos introduzir um bug neste código alterando `greeting` para excluir
`name` para ver como é a falha no teste padrão:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-06-greeter-with-bug/src/lib.rs:here}}
```

A execução deste teste produz o seguinte:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-06-greeter-with-bug/output.txt}}
```

Este resultado apenas indica que a afirmação falhou e qual linha a
a afirmação está ativada. Uma mensagem de falha mais útil imprimiria o valor do
Função `greeting`. Vamos adicionar uma mensagem de falha personalizada composta por um formato
string com um espaço reservado preenchido com o valor real que obtivemos do
Função ` greeting`:

```rust,ignore
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-07-custom-failure-message/src/lib.rs:here}}
```

Now when we run the test, we’ll get a more informative error message:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-07-custom-failure-message/output.txt}}
```

Podemos ver o valor que realmente obtivemos na saída do teste, o que nos ajudaria
depurar o que aconteceu em vez do que esperávamos que acontecesse.

### Verificando pânico com `should_panic`

Além de verificar os valores de retorno, é importante verificar se nosso código
lida com condições de erro conforme esperamos. Por exemplo, considere o tipo `Guess`
que criamos no Capítulo 9, Listagem 9-13. Outro código que usa ` Guess`
depende da garantia de que as instâncias ` Guess`conterão apenas valores
entre 1 e 100. Podemos escrever um teste que garanta que a tentativa de criar um
A instância ` Guess`com um valor fora desse intervalo entra em pânico.

Fazemos isso adicionando o atributo `should_panic` à nossa função de teste. O
o teste será aprovado se o código dentro da função entrar em pânico; o teste falha se o código
dentro da função não panic.

A Listagem 11-8 mostra um teste que verifica se as condições de erro de `Guess::new`
acontecem quando esperamos que aconteçam.

<Listing number="11-8" file-name="src/lib.rs" caption="Testando que uma condição causará um `panic!`">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-08/src/lib.rs}}
```

</Listing>

Colocamos o atributo `#[should_panic]` após o atributo `#[test]` e
antes da função de teste à qual se aplica. Vejamos o resultado quando este teste
passa:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-08/output.txt}}
```

Parece bom! Agora vamos introduzir um bug em nosso código removendo a condição
que a função `new` será panic se o valor for maior que 100:

```rust,not_desired_behavior,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-08-guess-with-bug/src/lib.rs:here}}
```

Quando executarmos o teste da Listagem 11-8, ele falhará:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-08-guess-with-bug/output.txt}}
```

Não recebemos uma mensagem muito útil neste caso, mas quando olhamos para o teste
função, vemos que ela está anotada com `#[should_panic]`. O fracasso que tivemos
significa que o código na função de teste não causou panic.

Os testes que usam `should_panic` podem ser imprecisos. Um teste `should_panic` seria
passar mesmo que o teste entre em pânico por um motivo diferente daquele que estávamos
esperando. Para tornar os testes `should_panic` mais precisos, podemos adicionar um opcional
Parâmetro `expected` para o atributo `should_panic`. O equipamento de teste
certifique-se de que a mensagem de falha contenha o texto fornecido. Por exemplo,
considere o código modificado para ` Guess`na Listagem 11-9 onde a função ` new`
entra em pânico com mensagens diferentes dependendo se o valor é muito pequeno ou
muito grande.

<Listing number="11-9" file-name="src/lib.rs" caption="Testando um `panic!` com uma mensagem contendo uma substring especificada">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-09/src/lib.rs:here}}
```

</Listing>

Este teste será aprovado porque o valor que colocamos no atributo `should_panic`
O parâmetro ` expected`é uma substring da mensagem que o ` Guess::new`
função entra em pânico com. Poderíamos ter especificado toda a mensagem panic que
esperar, que neste caso seria ` Guess value must be less than or equal to
100, got 200`. O que você escolhe especificar depende de quanto do panic
a mensagem é única ou dinâmica e quão preciso você deseja que seu teste seja. Neste
caso, uma substring da mensagem panic é suficiente para garantir que o código no
A função de teste executa o caso ` else if value > 100`.

Para ver o que acontece quando um teste `should_panic` com uma mensagem `expected`
falhar, vamos introduzir novamente um bug em nosso código trocando os corpos do
Blocos ` if value < 1`e ` else if value > 100`:

```rust,ignore,not_desired_behavior
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-09-guess-with-panic-msg-bug/src/lib.rs:here}}
```

Desta vez, quando executarmos o teste `should_panic`, ele falhará:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-09-guess-with-panic-msg-bug/output.txt}}
```

A mensagem de falha indica que este teste realmente funcionou como panic como esperávamos,
mas a mensagem panic não incluía a sequência esperada `less than or equal
to 100`. A mensagem panic que recebemos neste caso foi ` Guess value must
be greater than or equal to 1, got 200`. Agora podemos começar a descobrir onde
nosso bug é!

### Usando `Result<T, E>` em testes

Todos os nossos testes até agora panic quando falharam. Também podemos escrever testes que usam
`Result<T, E> `! Aqui está o teste da Listagem 11-1, reescrito para usar` Result<T,
E> `e retornar um` Err`em vez de entrar em pânico:

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-10-result-in-tests/src/lib.rs:here}}
```

A função `it_works` agora possui o tipo de retorno `Result<(), String>`. No
corpo da função, em vez de chamar a macro ` assert_eq!`, retornamos
` Ok(()) `quando o teste passa e um` Err `com um` String`dentro quando o teste
falha.

Escrever testes para que eles retornem um `Result<T, E>` permite que você use o
operador de ponto de interrogação no corpo dos testes, o que pode ser uma maneira conveniente de
escrever testes que deverão falhar se alguma operação dentro deles retornar um `Err`
variante.

Você não pode usar a anotação `#[should_panic]` em testes que usam `Result<T,
E>`. Para afirmar que uma operação retorna uma variante ` Err`, _não_ use o
operador de ponto de interrogação no valor ` Result<T, E>`. Em vez disso, use
` assert!(value.is_err())`.

Agora que você conhece várias maneiras de escrever testes, vamos ver o que está acontecendo
quando executamos nossos testes e exploramos as diferentes opções que podemos usar com `cargo
test`.

[concatenating]: ch08-02-strings.html#concatenating-with--or-format
[bench]: ../unstable-book/library-features/test.html
[ignoring]: ch11-02-running-tests.html#ignoring-tests-unless-specifically-requested
[subset]: ch11-02-running-tests.html#running-a-subset-of-tests-by-name
[controlling-how-tests-are-run]: ch11-02-running-tests.html#controlling-how-tests-are-run
[derivable-traits]: appendix-03-derivable-traits.html
[doc-comments]: ch14-02-publishing-to-crates-io.html#documentation-comments-as-tests
[paths-for-referring-to-an-item-in-the-module-tree]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html

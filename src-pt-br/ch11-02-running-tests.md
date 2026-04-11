## Controlando Como os Testes São Executados

Assim como `cargo run` compila seu código e executa o binário resultante,
`cargo test` compila seu código em modo de teste e executa o binário de testes
resultante. O comportamento padrão do binário produzido por `cargo test` é
executar todos os testes em paralelo e capturar a saída gerada durante a
execução deles, impedindo que ela seja exibida e tornando mais fácil ler as
informações relacionadas aos resultados dos testes. No entanto, você pode
especificar opções de linha de comando para alterar esse comportamento padrão.

Algumas opções de linha de comando vão para `cargo test`, e outras vão para o
binário de testes resultante. Para separar esses dois tipos de argumentos, você
lista os argumentos destinados a `cargo test`, seguidos do separador `--`, e
depois aqueles que vão para o binário de testes. Executar `cargo test --help`
exibe as opções que você pode usar com `cargo test`, e executar
`cargo test -- --help` exibe as opções que você pode usar após o separador.
Essas opções também estão documentadas na [seção “Tests” de _The `rustc`
Book_][tests].

[tests]: https://doc.rust-lang.org/rustc/tests/index.html

### Executando Testes em Paralelo ou em Sequência

Quando você executa vários testes, por padrão eles são executados em paralelo
usando threads, o que significa que terminam mais rapidamente e você recebe
feedback mais cedo. Como os testes estão sendo executados ao mesmo tempo, você
precisa garantir que eles não dependam uns dos outros nem de qualquer estado
compartilhado, incluindo um ambiente compartilhado, como o diretório de
trabalho atual ou variáveis de ambiente.

Por exemplo, imagine que cada um dos seus testes execute algum código que cria
um arquivo no disco chamado _test-output.txt_ e grave dados nesse arquivo.
Depois, cada teste lê os dados desse arquivo e verifica se ele contém um certo
valor, que é diferente em cada teste. Como os testes são executados ao mesmo
tempo, um teste pode sobrescrever o arquivo no intervalo entre o momento em que
outro teste está escrevendo nele e o momento em que está lendo. O segundo
teste então falhará, não porque o código esteja incorreto, mas porque os
testes interferiram uns nos outros enquanto rodavam em paralelo. Uma solução é
garantir que cada teste escreva em um arquivo diferente; outra é executar os
testes um de cada vez.

Se você não quiser executar os testes em paralelo, ou se quiser um controle
mais fino sobre o número de threads usado, pode passar a flag
`--test-threads`, seguida do número de threads desejado, para o binário de
testes. Veja o exemplo a seguir:

```console
$ cargo test -- --test-threads=1
```

Definimos o número de threads de teste como `1`, dizendo ao programa para não
usar paralelismo. Executar os testes com uma única thread levará mais tempo do
que executá-los em paralelo, mas eles não interferirão uns nos outros caso
compartilhem estado.

### Exibindo a Saída das Funções

Por padrão, se um teste passar, a biblioteca de testes de Rust captura tudo o
que for impresso na saída padrão. Por exemplo, se chamarmos `println!` em um
teste e ele passar, não veremos a saída de `println!` no terminal; veremos
apenas a linha indicando que o teste passou. Se um teste falhar, veremos tudo
o que foi impresso na saída padrão junto com o restante da mensagem de falha.

Como exemplo, a Listagem 11-10 tem uma função boba que imprime o valor do seu
parâmetro e retorna 10, bem como um teste que passa e outro que falha.

<Listing number="11-10" file-name="src/lib.rs" caption="Testes para uma função que chama `println!`">

```rust,panics,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-10/src/lib.rs}}
```

</Listing>

Quando executamos esses testes com `cargo test`, vemos a seguinte saída:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-10/output.txt}}
```

Observe que em nenhum lugar dessa saída aparece `I got the value 4`, que é
impresso quando o teste que passa é executado. Essa saída foi capturada. A
saída do teste que falhou, `I got the value 8`, aparece na seção do resumo dos
testes, que também mostra a causa da falha.

Se quisermos ver também os valores impressos nos testes que passam, podemos
pedir a Rust que mostre a saída dos testes bem-sucedidos com `--show-output`:

```console
$ cargo test -- --show-output
```

Quando executamos novamente os testes da Listagem 11-10 com a flag
`--show-output`, vemos a seguinte saída:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-01-show-output/output.txt}}
```

### Executando um Subconjunto de Testes pelo Nome

Executar a suíte de testes completa às vezes pode levar bastante tempo. Se
você estiver trabalhando no código de uma área específica, talvez queira
executar apenas os testes relacionados àquele código. Você pode escolher quais
testes executar passando a `cargo test` o nome, ou parte do nome, dos testes
que deseja rodar.

Para demonstrar como executar um subconjunto de testes, criaremos primeiro três
testes para a nossa função `add_two`, como mostrado na Listagem 11-11, e
depois escolheremos quais deles executar.

<Listing number="11-11" file-name="src/lib.rs" caption="Três testes com três nomes diferentes">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-11/src/lib.rs}}
```

</Listing>

Se executarmos os testes sem passar nenhum argumento, como vimos antes, todos
eles serão executados em paralelo:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-11/output.txt}}
```

#### Executando um Teste Específico

Podemos passar o nome de qualquer função de teste para `cargo test` para
executar apenas esse teste:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-02-single-test/output.txt}}
```

Somente o teste chamado `one_hundred` foi executado; os outros dois testes não
corresponderam a esse nome. A saída nos informa que houve outros testes não
executados exibindo `2 filtered out` ao final.

Não podemos especificar os nomes de vários testes dessa maneira; apenas o
primeiro valor fornecido a `cargo test` será usado. Mas existe uma forma de
executar vários testes.

#### Filtrando para Executar Vários Testes

Podemos especificar parte do nome de um teste, e qualquer teste cujo nome
corresponda a esse valor será executado. Por exemplo, como dois dos nossos
testes contêm `add` no nome, podemos executar esses dois com `cargo test add`:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-03-multiple-tests/output.txt}}
```

Esse comando executou todos os testes cujo nome contém `add` e filtrou o teste
chamado `one_hundred`. Observe também que o módulo em que um teste aparece se
torna parte do nome do teste, de modo que podemos executar todos os testes de
um módulo filtrando pelo nome desse módulo.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-some-tests-unless-specifically-requested"></a>

### Ignorando Testes, a Menos que Sejam Solicitados Especificamente

Às vezes, alguns testes específicos podem demorar bastante para serem
executados, então talvez você queira excluí-los da maior parte das execuções de
`cargo test`. Em vez de listar como argumentos todos os testes que deseja
executar, você pode anotar os testes demorados com o atributo `ignore` para
excluí-los, como mostrado aqui:

<span class="filename">Arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-11-ignore-a-test/src/lib.rs:here}}
```

Depois de `#[test]`, adicionamos a linha `#[ignore]` ao teste que queremos
excluir. Agora, quando executamos nossos testes, `it_works` roda, mas
`expensive_test` não:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-11-ignore-a-test/output.txt}}
```

A função `expensive_test` aparece listada como `ignored`. Se quisermos
executar apenas os testes ignorados, podemos usar `cargo test -- --ignored`:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-04-running-ignored/output.txt}}
```

Ao controlar quais testes são executados, você pode garantir que os resultados
de `cargo test` cheguem rapidamente. Quando você estiver em um ponto em que
faça sentido verificar os resultados dos testes `ignored`, e tiver tempo para
esperar, poderá executar `cargo test -- --ignored`. Se quiser executar todos os
testes, estejam eles ignorados ou não, pode usar
`cargo test -- --include-ignored`.

## Controlando como os testes são executados

Assim como `cargo run` compila seu código e depois executa o binário
resultante, `cargo test` compila seu código em modo de teste e executa o
binário de testes resultante. O comportamento padrão do binário produzido por
`cargo test` é executar todos os testes em paralelo e capturar a saída gerada
durante as execuções, impedindo que ela seja exibida e facilitando a leitura da
saída relacionada aos resultados. Você pode, no entanto, especificar opções de
linha de comando para alterar esse comportamento padrão.

Algumas opções de linha de comando são passadas para `cargo test`, e outras são
passadas para o binário de teste resultante. Para separar esses dois tipos de
argumento, liste os argumentos destinados a `cargo test`, depois o separador
`--`, e então os argumentos destinados ao binário de teste. Executar
`cargo test --help` exibe as opções que você pode usar com `cargo test`, e
executar `cargo test -- --help` exibe as opções que você pode usar depois do
separador. Essas opções também estão documentadas na seção [“Tests”][tests] de
_The `rustc` Book_.

[tests]: https://doc.rust-lang.org/rustc/tests/index.html

### Executando testes em paralelo ou em sequência

Quando você executa vários testes, por padrão eles rodam em paralelo usando
threads, o que significa que terminam mais rápido e você recebe feedback mais
cedo. Como os testes estão rodando ao mesmo tempo, é preciso garantir que eles
não dependam uns dos outros nem de algum estado compartilhado, incluindo um
ambiente compartilhado, como o diretório de trabalho atual ou variáveis de
ambiente.

Por exemplo, imagine que cada teste execute código que cria um arquivo em disco
chamado _test-output.txt_ e escreva alguns dados nele. Em seguida, cada teste
lê os dados desse arquivo e verifica que ele contém um determinado valor,
diferente em cada teste. Como os testes são executados ao mesmo tempo, um teste
pode sobrescrever o arquivo no intervalo entre outro teste escrevê-lo e lê-lo.
O segundo teste então falhará, não porque o código esteja incorreto, mas porque
os testes interferiram uns nos outros durante a execução em paralelo. Uma
solução é garantir que cada teste escreva em um arquivo diferente; outra é
executar os testes um de cada vez.

Se você não quiser executar os testes em paralelo, ou se quiser um controle
mais detalhado sobre o número de threads usadas, pode passar a flag
`--test-threads` e a quantidade de threads desejada ao binário de teste. Veja o
seguinte exemplo:

```console
$ cargo test -- --test-threads=1
```

Definimos o número de threads de teste como `1`, instruindo o programa a não
usar paralelismo. Executar os testes usando apenas uma thread levará mais tempo
do que executá-los em paralelo, mas os testes não interferirão entre si caso
compartilhem estado.

### Mostrando a saída de funções

Por padrão, se um teste passa, a biblioteca de testes do Rust captura tudo o
que foi impresso na saída padrão. Por exemplo, se chamarmos `println!` em um
teste e esse teste passar, não veremos a saída de `println!` no terminal;
veremos apenas a linha que indica que o teste passou. Se um teste falhar,
veremos o que foi impresso na saída padrão junto com o restante da mensagem de
falha.

Como exemplo, a Listagem 11-10 tem uma função simples que imprime o valor de
seu parâmetro e retorna 10, além de um teste que passa e um teste que falha.

<Listing number="11-10" file-name="src/lib.rs" caption="Testes para uma função que chama `println!`">

```rust,panics,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-10/src/lib.rs}}
```

</Listing>

Quando executarmos esses testes com `cargo test`, veremos a seguinte saída:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-10/output.txt}}
```

Observe que em nenhum ponto dessa saída vemos `I got the value 4`, que é o
texto impresso quando o teste que passa é executado. Essa saída foi capturada.
A saída do teste que falhou, `I got the value 8`, aparece na seção do resumo de
testes, que também mostra a causa da falha.

Se quisermos ver os valores impressos também para testes que passam, podemos
pedir ao Rust para mostrar a saída de testes bem-sucedidos com
`--show-output`:

```console
$ cargo test -- --show-output
```

Quando executarmos novamente os testes da Listagem 11-10 com a flag
`--show-output`, veremos a seguinte saída:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-01-show-output/output.txt}}
```

### Executando um subconjunto de testes por nome

Executar uma suíte completa de testes às vezes pode levar bastante tempo. Se
você estiver trabalhando em código de uma área específica, talvez queira
executar apenas os testes relacionados àquela parte. Você pode escolher quais
testes rodar passando ao `cargo test` o nome, ou os nomes, do(s) teste(s) que
quer executar como argumento.

Para demonstrar como executar um subconjunto de testes, primeiro criaremos três
testes para nossa função `add_two`, como mostra a Listagem 11-11, e veremos
quais deles são executados.

<Listing number="11-11" file-name="src/lib.rs" caption="Três testes com três nomes diferentes">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-11/src/lib.rs}}
```

</Listing>

Se executarmos os testes sem passar nenhum argumento, como vimos antes, todos
os testes serão executados em paralelo:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-11/output.txt}}
```

#### Executando testes individuais

Podemos passar o nome de qualquer função de teste a `cargo test` para executar
somente aquele teste:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-02-single-test/output.txt}}
```

Apenas o teste chamado `one_hundred` foi executado; os outros dois não
corresponderam a esse nome. A saída nos informa que havia mais testes não
executados exibindo `2 filtered out` no final.

Não podemos especificar os nomes de vários testes dessa forma; somente o
primeiro valor fornecido a `cargo test` será usado. Mas existe uma forma de
executar vários testes.

#### Filtrando para executar vários testes

Podemos especificar parte do nome de um teste, e qualquer teste cujo nome
corresponda a esse valor será executado. Por exemplo, como os nomes de dois dos
nossos testes contêm `add`, podemos executá-los rodando `cargo test add`:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-03-multiple-tests/output.txt}}
```

Esse comando executou todos os testes cujo nome contém `add` e filtrou o teste
chamado `one_hundred`. Observe também que o módulo no qual um teste aparece
passa a fazer parte do nome do teste, de modo que podemos executar todos os
testes de um módulo filtrando pelo nome desse módulo.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-some-tests-unless-specifically-requested"></a>

### Ignorando testes, a menos que sejam solicitados especificamente

Às vezes, alguns testes específicos podem levar muito tempo para executar, então
talvez você queira excluí-los da maioria das execuções de `cargo test`. Em vez
de listar como argumentos todos os testes que deseja executar, você pode
anotar os testes demorados com o atributo `ignore` para excluí-los, como
mostrado aqui:

<span class="filename">Nome do arquivo: src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-11-ignore-a-test/src/lib.rs:here}}
```

Depois de `#[test]`, adicionamos a linha `#[ignore]` ao teste que queremos
excluir. Agora, quando executamos os testes, `it_works` roda, mas
`expensive_test` não:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-11-ignore-a-test/output.txt}}
```

A função `expensive_test` aparece listada como `ignored`. Se quisermos executar
somente os testes ignorados, podemos usar `cargo test -- --ignored`:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-04-running-ignored/output.txt}}
```

Ao controlar quais testes são executados, você pode garantir que os resultados
de `cargo test` retornem rapidamente. Quando chegar a um ponto em que faça
sentido verificar os resultados dos testes `ignored` e você tiver tempo para
esperar, poderá executar `cargo test -- --ignored`. Se quiser rodar todos os
testes, ignorados ou não, pode executar `cargo test -- --include-ignored`.

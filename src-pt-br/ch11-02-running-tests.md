## Controlando como os testes são executados

Assim como `cargo run` compila seu código e depois executa o binário resultante,
`cargo test` compila seu código em modo de teste e executa o teste resultante
binário. O comportamento padrão do binário produzido por `cargo test` é executar
todos os testes em paralelo e capturar a saída gerada durante as execuções de teste,
impedindo que a saída seja exibida e facilitando a leitura do
saída relacionada aos resultados do teste. Você pode, no entanto, especificar a linha de comando
opções para alterar esse comportamento padrão.

Algumas opções de linha de comando vão para `cargo test` e outras vão para o teste resultante
binário. Para separar esses dois tipos de argumentos, você lista os argumentos que
vá para `cargo test` seguido do separador `--` e depois os que vão para
o binário de teste. Executar `cargo test --help` exibe as opções que você pode usar
com `cargo test` e executar `cargo test -- --help` exibe as opções que você
pode usar após o separador. Essas opções também estão documentadas em [os “Testes”
seção de _O `rustc` Livro_][tests].

[tests]: https://doc.rust-lang.org/rustc/tests/index.html

### Executando testes em paralelo ou consecutivamente

Quando você executa vários testes, por padrão eles são executados em paralelo usando threads,
o que significa que eles terminam a execução mais rapidamente e você recebe feedback mais cedo. Porque
os testes estão sendo executados ao mesmo tempo, você deve garantir que seus testes não
dependem uns dos outros ou de qualquer estado compartilhado, incluindo um ambiente compartilhado,
como o diretório de trabalho atual ou variáveis ​​de ambiente.

Por exemplo, digamos que cada um dos seus testes execute algum código que cria um arquivo no disco
chamado _test-output.txt_ e grava alguns dados nesse arquivo. Então, cada teste
lê os dados nesse arquivo e afirma que o arquivo contém um determinado
valor, que é diferente em cada teste. Como os testes são executados ao mesmo tempo,
um teste pode substituir o arquivo no intervalo entre o momento em que outro teste é
escrevendo e lendo o arquivo. O segundo teste falhará então, não porque o
o código está incorreto, mas porque os testes interferiram uns nos outros enquanto
correndo em paralelo. Uma solução é garantir que cada teste grave em um
arquivo diferente; outra solução é executar os testes um de cada vez.

Se você não quiser executar os testes em paralelo ou se quiser mais detalhes
controle sobre o número de threads usados, você pode enviar o sinalizador `--test-threads`
e o número de threads que você deseja usar no binário de teste. Dê uma olhada
o seguinte exemplo:

```console
$ cargo test -- --test-threads=1
```

Definimos o número de threads de teste como `1`, informando ao programa para não usar nenhum
paralelismo. A execução dos testes usando um thread levará mais tempo do que a execução
em paralelo, mas os testes não interferirão entre si se compartilharem
estado.

### Mostrando a saída da função

Por padrão, se um teste for aprovado, a biblioteca de testes do Rust captura qualquer coisa impressa em
saída padrão. Por exemplo, se chamarmos `println!` em um teste e o teste
passa, não veremos a saída `println!` no terminal; veremos apenas o
linha que indica que o teste foi aprovado. Se um teste falhar, veremos o que foi
impresso na saída padrão com o restante da mensagem de falha.

Como exemplo, a Listagem 11.10 tem uma função boba que imprime o valor de seu
parâmetro e retorna 10, bem como um teste que passa e um teste que falha.

<Listing number="11-10" file-name="src/lib.rs" caption="Tests for a function that calls `println!`">

```rust,panics,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-10/src/lib.rs}}
```

</Listing>

Quando executarmos esses testes com `cargo test`, veremos o seguinte resultado:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-10/output.txt}}
```

Observe que em nenhum lugar desta saída vemos `I got the value 4`, que é
impresso quando o teste aprovado é executado. Essa saída foi capturada. O
a saída do teste que falhou, `I got the value 8`, aparece na seção
da saída do resumo do teste, que também mostra a causa da falha do teste.

Se quisermos ver os valores impressos para passar nos testes também, podemos dizer ao Rust para
também mostre o resultado de testes bem-sucedidos com `--show-output`:

```console
$ cargo test -- --show-output
```

Quando executamos os testes na Listagem 11-10 novamente com o sinalizador `--show-output`, nós
veja a seguinte saída:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-01-show-output/output.txt}}
```

### Executando um subconjunto de testes por nome

A execução de um conjunto de testes completo às vezes pode levar muito tempo. Se você estiver trabalhando
código em uma área específica, talvez você queira executar apenas os testes pertencentes a
esse código. Você pode escolher quais testes executar passando `cargo test` o nome
ou nomes dos testes que você deseja executar como argumento.

Para demonstrar como executar um subconjunto de testes, primeiro criaremos três testes para
nossa função `add_two`, conforme mostrado na Listagem 11.11, e escolha quais delas serão executadas.

<Listing number="11-11" file-name="src/lib.rs" caption="Three tests with three different names">

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/listing-11-11/src/lib.rs}}
```

</Listing>

Se executarmos os testes sem passar nenhum argumento, como vimos anteriormente, todos os
os testes serão executados em paralelo:

```console
{{#include ../listings/ch11-writing-automated-tests/listing-11-11/output.txt}}
```

#### Executando testes únicos

Podemos passar o nome de qualquer função de teste para `cargo test` para executar apenas esse teste:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-02-single-test/output.txt}}
```

Apenas o teste com o nome `one_hundred` foi executado; os outros dois testes não corresponderam
esse nome. A saída do teste nos informa que tivemos mais testes que não foram executados
exibindo `2 filtered out` no final.

Não podemos especificar os nomes de vários testes desta forma; apenas o primeiro valor
dado a `cargo test` será usado. Mas existe uma maneira de executar vários testes.

#### Filtrando para executar vários testes

Podemos especificar parte do nome de um teste e qualquer teste cujo nome corresponda a esse valor
será executado. Por exemplo, como o nome de dois dos nossos testes contém `add`, podemos
execute esses dois executando `cargo test add`:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-03-multiple-tests/output.txt}}
```

Este comando executou todos os testes com `add` no nome e filtrou o teste
chamado `one_hundred`. Observe também que o módulo no qual um teste aparece torna-se
parte do nome do teste, para que possamos executar todos os testes em um módulo filtrando
no nome do módulo.

<!-- Old headings. Do not remove or links may break. -->

<a id="ignoring-some-tests-unless-specifically-requested"></a>

### Ignorando testes, a menos que solicitado especificamente

Às vezes, alguns testes específicos podem levar muito tempo para serem executados, então você
talvez você queira excluí-los durante a maioria das execuções de `cargo test`. Em vez de
listando como argumentos todos os testes que você deseja executar, você pode anotar o
testes demorados usando o atributo `ignore` para excluí-los, conforme mostrado
aqui:

<span class="filename">Nome do arquivo:src/lib.rs</span>

```rust,noplayground
{{#rustdoc_include ../listings/ch11-writing-automated-tests/no-listing-11-ignore-a-test/src/lib.rs:here}}
```

Depois de `#[test]`, adicionamos a linha `#[ignore]` ao teste que queremos excluir.
Agora, quando executamos nossos testes, `it_works` é executado, mas `expensive_test` não:

```console
{{#include ../listings/ch11-writing-automated-tests/no-listing-11-ignore-a-test/output.txt}}
```

A função `expensive_test` está listada como `ignored`. Se quisermos correr apenas
os testes ignorados, podemos usar `cargo test -- --ignored`:

```console
{{#include ../listings/ch11-writing-automated-tests/output-only-04-running-ignored/output.txt}}
```

Ao controlar quais testes são executados, você pode garantir que seus resultados `cargo test`
será devolvido rapidamente. Quando você chega a um ponto em que faz sentido verificar
os resultados dos testes `ignored` e você tem tempo para esperar pelos resultados,
você pode executar `cargo test -- --ignored` em vez disso. Se você quiser executar todos os testes
sejam eles ignorados ou não, você pode executar `cargo test -- --include-ignored`.

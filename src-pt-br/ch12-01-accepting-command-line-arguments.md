## Aceitando argumentos de linha de comando

Vamos criar um novo projeto com, como sempre, `cargo new`. Chamaremos nosso projeto
`minigrep` para distingui-lo da ferramenta `grep` que você já pode ter
no seu sistema:

```console
$ cargo new minigrep
     Created binary (application) `minigrep` project
$ cd minigrep
```

A primeira tarefa é fazer `minigrep` aceitar seus dois argumentos de linha de comando: o
caminho do arquivo e uma string para pesquisar. Ou seja, queremos ser capazes de executar o nosso
programa com `cargo run`, dois hífens para indicar os seguintes argumentos são
para o nosso programa em vez de `cargo`, uma string para pesquisar e um caminho para
um arquivo para pesquisar, assim:

```console
$ cargo run -- searchstring example-filename.txt
```

No momento, o programa gerado por `cargo new` não pode processar argumentos que
dê. Algumas bibliotecas existentes em [crates.io](https://crates.io/) podem ajudar
escrever um programa que aceita argumentos de linha de comando, mas porque você está
apenas aprendendo esse conceito, vamos implementar esse recurso nós mesmos.

### Lendo os valores dos argumentos

Para permitir que `minigrep` leia os valores dos argumentos da linha de comando, passamos para
isso, precisaremos da função `std::env::args` fornecida no padrão do Rust
biblioteca. Esta função retorna um iterador dos argumentos da linha de comando passados
para `minigrep`. Abordaremos completamente os iteradores no [Capítulo 13][ch13]<!-- ignore
-->. Por enquanto, você só precisa saber dois detalhes sobre iteradores: Iteradores
produzir uma série de valores, e podemos chamar o método `collect` em um iterador
para transformá-lo em uma coleção, como um vetor, que contém todos os elementos
o iterador produz.

O código na Listagem 12-1 permite que seu programa `minigrep` leia qualquer comando
argumentos de linha passados ​​​​para ele e, em seguida, coletam os valores em um vetor.

<Listing number="12-1" file-name="src/main.rs" caption="Collecting the command line arguments into a vector and printing them">

```rust
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-01/src/main.rs}}
```

</Listing>

Primeiro, trazemos o módulo `std::env` para o escopo com uma instrução `use` para que
podemos usar sua função `args`. Observe que a função `std::env::args` é
aninhados em dois níveis de módulos. Como discutimos no [Capítulo
7][ch7-idiomatic-use]<!-- ignore -->, nos casos em que a função desejada é
aninhado em mais de um módulo, optamos por trazer o módulo pai para
escopo e não a função. Ao fazer isso, podemos facilmente usar outras funções
de `std::env`. Também é menos ambíguo do que adicionar `use std::env::args` e
em seguida, chamar a função com apenas `args`, porque `args` pode ser facilmente
confundido com uma função definida no módulo atual.

> ### A função `args` e Unicode inválido
>
> Observe que `std::env::args` entrará em pânico se algum argumento contiver inválido
> Unicode. Se o seu programa precisar aceitar argumentos contendo inválidos
> Unicode, use `std::env::args_os`. Essa função retorna um iterador
> que produz valores `OsString` em vez de valores `String`. Nós escolhemos
> use `std::env::args` aqui para simplificar porque os valores `OsString` diferem por
> plataforma e são mais complexos de trabalhar do que valores `String`.

Na primeira linha de `main`, chamamos `env::args` e usamos imediatamente
`collect` para transformar o iterador em um vetor contendo todos os valores produzidos
pelo iterador. Podemos usar a função `collect` para criar vários tipos de
coleções, então anotamos explicitamente o tipo de `args` para especificar que
quero um vetor de strings. Embora você raramente precise anotar tipos em
Rust, `collect` é uma função que você frequentemente precisa anotar porque Rust
não é capaz de inferir o tipo de coleção que você deseja.

Finalmente, imprimimos o vetor usando a macro de depuração. Vamos tentar executar o código
primeiro sem argumentos e depois com dois argumentos:

```console
{{#include ../listings/ch12-an-io-project/listing-12-01/output.txt}}
```

```console
{{#include ../listings/ch12-an-io-project/output-only-01-with-args/output.txt}}
```

Observe que o primeiro valor no vetor é `"target/debug/minigrep"`, que
é o nome do nosso binário. Isso corresponde ao comportamento da lista de argumentos em
C, permitindo que os programas usem o nome pelo qual foram invocados em sua execução.
Muitas vezes é conveniente ter acesso ao nome do programa caso você queira
imprimi-lo em mensagens ou alterar o comportamento do programa com base no que
o alias da linha de comando foi usado para invocar o programa. Mas para efeitos deste
capítulo, vamos ignorá-lo e salvar apenas os dois argumentos que precisamos.

### Salvando os valores dos argumentos em variáveis

O programa atualmente é capaz de acessar os valores especificados na linha de comando
argumentos. Agora precisamos salvar os valores dos dois argumentos em variáveis ​​para que
que podemos usar os valores durante todo o resto do programa. Fazemos isso em
Listagem 12-2.

<Listing number="12-2" file-name="src/main.rs" caption="Creating variables to hold the query argument and file path argument">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-02/src/main.rs}}
```

</Listing>

Como vimos quando imprimimos o vetor, o nome do programa ocupa o primeiro lugar
valor no vetor em `args[0]`, então estamos iniciando os argumentos no índice 1. O
primeiro argumento `minigrep` leva é a string que estamos procurando, então colocamos um
referência ao primeiro argumento na variável `query`. O segundo argumento
será o caminho do arquivo, então colocamos uma referência ao segundo argumento no
variável `file_path`.

Imprimimos temporariamente os valores dessas variáveis ​​para provar que o código é
funcionando como pretendemos. Vamos executar este programa novamente com os argumentos `test`
e `sample.txt`:

```console
{{#include ../listings/ch12-an-io-project/listing-12-02/output.txt}}
```

Ótimo, o programa está funcionando! Os valores dos argumentos que precisamos estão sendo
salvo nas variáveis ​​corretas. Mais tarde adicionaremos algum tratamento de erros para lidar
com certas situações potencialmente errôneas, como quando o usuário não fornece
argumentos; por enquanto, vamos ignorar essa situação e trabalhar na adição de leitura de arquivos
em vez disso, capacidades.

[ch13]: ch13-00-functional-features.html
[ch7-idiomatic-use]: ch07-04-bringing-paths-into-scope-with-the-use-keyword.html#creating-idiomatic-use-paths

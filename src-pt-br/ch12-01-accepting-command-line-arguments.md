## Aceitando argumentos de linha de comando

Vamos criar um novo projeto com, como sempre, `cargo new`. Chamaremos nosso
projeto de `minigrep` para distingui-lo da ferramenta `grep` que você talvez
já tenha instalada no sistema:

```console
$ cargo new minigrep
     Created binary (application) `minigrep` project
$ cd minigrep
```

A primeira tarefa é fazer `minigrep` aceitar seus dois argumentos de linha de
comando: o caminho do arquivo e uma string a ser pesquisada. Ou seja, queremos
ser capazes de executar nosso programa com `cargo run`, dois hífens para
indicar que os argumentos seguintes são para o nosso programa e não para o
`cargo`, uma string de busca e um caminho de arquivo onde faremos a busca,
assim:

```console
$ cargo run -- searchstring example-filename.txt
```

Neste momento, o programa gerado por `cargo new` não consegue processar os
argumentos que passamos a ele. Algumas bibliotecas existentes em
[crates.io](https://crates.io/) podem ajudar a escrever um programa que aceite
argumentos de linha de comando, mas, como você está aprendendo esse conceito
agora, vamos implementar essa capacidade nós mesmos.

### Lendo os valores dos argumentos

Para permitir que `minigrep` leia os valores dos argumentos de linha de comando
que passamos a ele, precisaremos da função `std::env::args`, fornecida pela
biblioteca padrão de Rust. Essa função retorna um iterador com os argumentos de
linha de comando passados para `minigrep`. Vamos estudar iteradores em
profundidade no [Capítulo 13][ch13]<!-- ignore -->. Por enquanto, você só
precisa saber duas coisas sobre eles: iteradores produzem uma sequência de
valores, e podemos chamar o método `collect` em um iterador para transformá-lo
em uma coleção, como um vetor, contendo todos os elementos produzidos.

O código da Listagem 12-1 permite que seu programa `minigrep` leia quaisquer
argumentos de linha de comando recebidos e depois reúna esses valores em um
vetor.

<Listing number="12-1" file-name="src/main.rs" caption="Coletando os argumentos de linha de comando em um vetor e imprimindo-os">

```rust
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-01/src/main.rs}}
```

</Listing>

Primeiro, trazemos o módulo `std::env` para o escopo com uma instrução `use`,
para que possamos usar sua função `args`. Observe que a função
`std::env::args` está aninhada em dois níveis de módulos. Como discutimos no
[Capítulo 7][ch7-idiomatic-use]<!-- ignore -->, nos casos em que a função
desejada está aninhada em mais de um módulo, optamos por trazer o módulo pai
para o escopo em vez da função. Fazendo isso, podemos usar com facilidade
outras funções de `std::env`. Isso também é menos ambíguo do que adicionar
`use std::env::args` e depois chamar a função apenas como `args`, porque
`args` poderia facilmente ser confundida com uma função definida no módulo
atual.

> ### A função `args` e Unicode inválido
>
> Observe que `std::env::args` entrará em pânico se algum argumento contiver
> Unicode inválido. Se o seu programa precisar aceitar argumentos contendo
> Unicode inválido, use `std::env::args_os`. Essa função retorna um iterador
> que produz valores `OsString` em vez de valores `String`. Escolhemos usar
> `std::env::args` aqui por simplicidade, porque os valores `OsString` variam
> entre plataformas e são mais complexos de manipular do que valores `String`.

Na primeira linha de `main`, chamamos `env::args` e usamos imediatamente
`collect` para transformar o iterador em um vetor que contém todos os valores
produzidos. Podemos usar a função `collect` para criar muitos tipos
diferentes de coleção, então anotamos explicitamente o tipo de `args` para
especificar que queremos um vetor de strings. Embora em Rust você raramente
precise anotar tipos, `collect` é uma função que com frequência exige isso,
porque Rust não consegue inferir sozinha qual tipo de coleção você quer.

Por fim, imprimimos o vetor usando a macro de depuração. Vamos tentar executar
o código primeiro sem argumentos e depois com dois argumentos:

```console
{{#include ../listings/ch12-an-io-project/listing-12-01/output.txt}}
```

```console
{{#include ../listings/ch12-an-io-project/output-only-01-with-args/output.txt}}
```

Observe que o primeiro valor no vetor é `"target/debug/minigrep"`, que é o
nome do nosso binário. Isso corresponde ao comportamento da lista de
argumentos em C, permitindo que programas usem o nome pelo qual foram
invocados durante a execução. Muitas vezes é conveniente ter acesso ao nome do
programa caso você queira imprimi-lo em mensagens ou alterar o comportamento
com base no alias de linha de comando usado para invocá-lo. Mas, para os fins
deste capítulo, vamos ignorá-lo e guardar apenas os dois argumentos de que
precisamos.

### Salvando os valores dos argumentos em variáveis

No momento, o programa consegue acessar os valores fornecidos como argumentos
de linha de comando. Agora precisamos salvar os valores desses dois argumentos
em variáveis para poder usá-los ao longo do restante do programa. Fazemos isso
na Listagem 12-2.

<Listing number="12-2" file-name="src/main.rs" caption="Criando variáveis para armazenar o argumento de busca e o argumento do caminho do arquivo">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-02/src/main.rs}}
```

</Listing>

Como vimos ao imprimir o vetor, o nome do programa ocupa a primeira posição,
em `args[0]`, então começamos os argumentos úteis no índice 1. O primeiro
argumento que `minigrep` recebe é a string que estamos procurando, então
colocamos uma referência ao primeiro argumento na variável `query`. O segundo
argumento será o caminho do arquivo, então colocamos uma referência ao segundo
argumento na variável `file_path`.

Imprimimos temporariamente os valores dessas variáveis para comprovar que o
código está funcionando como esperamos. Vamos executar este programa novamente
com os argumentos `test` e `sample.txt`:

```console
{{#include ../listings/ch12-an-io-project/listing-12-02/output.txt}}
```

Ótimo, o programa está funcionando! Os valores dos argumentos de que
precisamos estão sendo salvos nas variáveis corretas. Mais adiante,
adicionaremos algum tratamento de erro para lidar com situações potencialmente
problemáticas, como quando o usuário não fornece argumentos. Por enquanto,
vamos ignorar isso e seguir para a leitura de arquivos.

[ch13]: ch13-00-functional-features.html
[ch7-idiomatic-use]: ch07-04-bringing-paths-into-scope-with-the-use-keyword.html#creating-idiomatic-use-paths

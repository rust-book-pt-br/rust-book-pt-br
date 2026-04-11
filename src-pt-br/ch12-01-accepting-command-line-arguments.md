## Aceitando Argumentos de Linha de Comando

Vamos criar um novo projeto usando, como sempre, `cargo new`. Chamaremos nosso
projeto de `minigrep` para distingui-lo da ferramenta `grep` que você talvez já
tenha no seu sistema:

```console
$ cargo new minigrep
     Created binary (application) `minigrep` project
$ cd minigrep
```

A primeira tarefa é fazer com que `minigrep` aceite dois argumentos de linha
de comando: o caminho do arquivo e uma string a ser procurada. Ou seja,
queremos poder executar o nosso programa com `cargo run`, dois hífens para
indicar que os argumentos seguintes são para o nosso programa e não para o
Cargo, uma string para procurar e um caminho para um arquivo onde a busca será
feita, assim:

```console
$ cargo run -- searchstring example-filename.txt
```

Neste momento, o programa gerado por `cargo new` não consegue processar os
argumentos que passamos. Existem bibliotecas em
[crates.io](https://crates.io/) que ajudam a escrever programas que aceitam
argumentos de linha de comando, mas, como você está aprendendo esses conceitos,
vamos implementar essa capacidade por conta própria.

### Lendo os Valores dos Argumentos

Para permitir que `minigrep` leia os valores dos argumentos de linha de comando
que passamos a ele, precisaremos da função `std::env::args`, fornecida pela
biblioteca padrão de Rust. Essa função retorna um *iterador* com os argumentos
de linha de comando passados para `minigrep`. Veremos iteradores por completo
no [Capítulo 13][ch13]<!-- ignore -->. Por enquanto, você só precisa saber dois
detalhes sobre eles: iteradores produzem uma série de valores, e podemos
chamar o método `collect` em um iterador para transformá-lo em uma coleção,
como um vetor, contendo todos os elementos produzidos por ele.

O código da Listagem 12-1 permite que o programa `minigrep` leia quaisquer
argumentos de linha de comando passados para ele e depois colete esses valores
em um vetor.

<Listing number="12-1" file-name="src/main.rs" caption="Coletando os argumentos de linha de comando em um vetor e imprimindo-os">

```rust
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-01/src/main.rs}}
```

</Listing>

Primeiro, trazemos o módulo `std::env` para o escopo com uma instrução `use`,
para podermos usar sua função `args`. Observe que `std::env::args` está
aninhada em dois níveis de módulos. Como discutimos no [Capítulo
7][ch7-idiomatic-use]<!-- ignore -->, quando a função desejada está aninhada em
mais de um módulo, costumamos trazer o módulo pai para o escopo em vez da
própria função. Fazendo isso, também podemos usar facilmente outras funções de
`std::env`. Além disso, fica menos ambíguo do que adicionar
`use std::env::args` e depois chamar a função apenas como `args`, já que
`args` poderia ser facilmente confundido com uma função definida no módulo
atual.

> ### A Função `args` e Unicode Inválido
>
> Observe que `std::env::args` entrará em pânico se algum argumento contiver
> Unicode inválido. Se o seu programa precisar aceitar argumentos contendo
> Unicode inválido, use `std::env::args_os` em vez disso. Essa função retorna
> um iterador que produz valores `OsString` em vez de `String`. Escolhemos usar
> `std::env::args` aqui por simplicidade, porque valores `OsString` variam de
> plataforma para plataforma e são mais complexos de manipular do que valores
> `String`.

Na primeira linha de `main`, chamamos `env::args` e usamos imediatamente
`collect` para transformar o iterador em um vetor contendo todos os valores
produzidos por ele. Podemos usar `collect` para criar muitos tipos de coleção,
então explicitamos o tipo de `args` para especificar que queremos um vetor de
strings. Embora raramente seja preciso anotar tipos em Rust, `collect` é uma
das funções para as quais isso costuma ser necessário, porque Rust não consegue
inferir qual tipo de coleção você deseja.

Por fim, imprimimos o vetor usando o formatador de debug. Vamos tentar executar
o código primeiro sem argumentos e depois com dois argumentos:

```console
{{#include ../listings/ch12-an-io-project/listing-12-01/output.txt}}
```

```console
{{#include ../listings/ch12-an-io-project/output-only-01-with-args/output.txt}}
```

Observe que o primeiro valor do vetor é `"target/debug/minigrep"`, que é o
nome do nosso binário. Isso corresponde ao comportamento da lista de argumentos
em C, permitindo que programas usem o nome com o qual foram invocados durante
a execução. Muitas vezes é conveniente ter acesso ao nome do programa, caso
queiramos imprimi-lo em mensagens ou alterar seu comportamento com base no
alias de linha de comando usado para invocá-lo. Mas, para os fins deste
capítulo, vamos ignorá-lo e salvar apenas os dois argumentos de que
precisamos.

### Salvando os Valores dos Argumentos em Variáveis

O programa agora consegue acessar os valores especificados como argumentos de
linha de comando. Em seguida, precisamos salvar os valores dos dois argumentos
em variáveis para podermos usá-los ao longo do restante do programa. Fazemos
isso na Listagem 12-2.

<Listing number="12-2" file-name="src/main.rs" caption="Criando variáveis para armazenar o argumento de consulta e o argumento do caminho do arquivo">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-02/src/main.rs}}
```

</Listing>

Como vimos quando imprimimos o vetor, o nome do programa ocupa o primeiro valor
em `args[0]`, então começamos pelo índice `1`. O primeiro argumento que
`minigrep` recebe é a string que estamos procurando, então colocamos uma
referência a esse argumento na variável `query`. O segundo argumento será o
caminho do arquivo, então colocamos uma referência a ele na variável
`file_path`.

Imprimimos temporariamente os valores dessas variáveis para provar que o código
está funcionando como esperamos. Vamos executar esse programa novamente com os
argumentos `test` e `sample.txt`:

```console
{{#include ../listings/ch12-an-io-project/listing-12-02/output.txt}}
```

Ótimo, o programa está funcionando! Os valores dos argumentos de que
precisamos estão sendo salvos nas variáveis corretas. Mais adiante,
adicionaremos tratamento de erros para lidar com situações potencialmente
problemáticas, como quando a pessoa usuária não fornece argumentos; por
enquanto, vamos ignorar essa situação e trabalhar na adição da funcionalidade
de leitura de arquivos.

[ch13]: ch13-00-functional-features.html
[ch7-idiomatic-use]: ch07-04-bringing-paths-into-scope-with-the-use-keyword.html#creating-idiomatic-use-paths

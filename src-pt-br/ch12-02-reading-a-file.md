## Lendo um Arquivo

Agora vamos adicionar a funcionalidade para ler o arquivo especificado no
argumento `file_path`. Primeiro, precisamos de um arquivo de amostra para
testar: usaremos um arquivo com uma pequena quantidade de texto em várias
linhas, com algumas palavras repetidas. A Listagem 12-3 traz um poema de Emily
Dickinson que funciona muito bem! Crie um arquivo chamado _poem.txt_ na raiz
do seu projeto e coloque nele o poema “I’m Nobody! Who are you?”.

<Listing number="12-3" file-name="poem.txt" caption="Um poema de Emily Dickinson é um bom caso de teste">

```text
{{#include ../listings/ch12-an-io-project/listing-12-03/poem.txt}}
```

</Listing>

Com o texto no lugar, edite _src/main.rs_ e adicione código para ler o
arquivo, como mostrado na Listagem 12-4.

<Listing number="12-4" file-name="src/main.rs" caption="Lendo o conteúdo do arquivo especificado pelo segundo argumento">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-04/src/main.rs:here}}
```

</Listing>

Primeiro, trazemos para o escopo uma parte relevante da biblioteca padrão com
uma instrução `use`: precisamos de `std::fs` para lidar com arquivos.

Em `main`, a nova instrução `fs::read_to_string` recebe `file_path`, abre esse
arquivo e retorna um valor do tipo `std::io::Result<String>` contendo o
conteúdo do arquivo.

Depois disso, adicionamos novamente um `println!` temporário que imprime o
valor de `contents` depois que o arquivo é lido, para que possamos verificar se
o programa está funcionando até aqui.

Vamos executar esse código com qualquer string como primeiro argumento de linha
de comando, porque ainda não implementamos a parte da busca, e o arquivo
_poem.txt_ como segundo argumento:

```console
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-04/output.txt}}
```

Ótimo! O código leu e depois imprimiu o conteúdo do arquivo. Mas esse código
tem alguns problemas. No momento, a função `main` tem múltiplas
responsabilidades: em geral, funções são mais claras e mais fáceis de manter
se cada uma for responsável por apenas uma ideia. O outro problema é que não
estamos lidando com erros tão bem quanto poderíamos. O programa ainda é
pequeno, então esses problemas não são tão graves, mas, à medida que ele
crescer, será mais difícil corrigir isso de forma elegante. É uma boa prática
começar a refatoração cedo no desenvolvimento de um programa, porque é muito
mais fácil refatorar pequenas quantidades de código. Faremos isso em seguida.

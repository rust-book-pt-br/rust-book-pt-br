## Lendo um arquivo

Agora vamos adicionar funcionalidade para ler o arquivo especificado no
argumento `file_path`. Primeiro, precisamos de um arquivo de exemplo para
testar: usaremos um arquivo com uma pequena quantidade de texto distribuída em
várias linhas e com algumas palavras repetidas. A Listagem 12-3 traz um poema
de Emily Dickinson que funciona muito bem para isso! Crie um arquivo chamado
_poem.txt_ na raiz do seu projeto e coloque nele o poema “I’m Nobody! Who are
you?”.

<Listing number="12-3" file-name="poem.txt" caption="Um poema de Emily Dickinson é um bom caso de teste">

```text
{{#include ../listings/ch12-an-io-project/listing-12-03/poem.txt}}
```

</Listing>

Com o texto no lugar, edite _src/main.rs_ e adicione o código para ler o
arquivo, como mostrado na Listagem 12-4.

<Listing number="12-4" file-name="src/main.rs" caption="Lendo o conteúdo do arquivo especificado pelo segundo argumento">

```rust,should_panic,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-04/src/main.rs:here}}
```

</Listing>

Primeiro, trazemos uma parte relevante da biblioteca padrão com uma instrução
`use`: precisamos de `std::fs` para lidar com arquivos.

Em `main`, a nova chamada `fs::read_to_string` recebe `file_path`, abre o
arquivo e retorna um valor do tipo `std::io::Result<String>` contendo seu
conteúdo.

Depois disso, adicionamos novamente uma instrução `println!` temporária que
imprime o valor de `contents` após a leitura do arquivo, para que possamos
confirmar que o programa está funcionando até aqui.

Vamos executar esse código com qualquer string como primeiro argumento da linha
de comando, porque ainda não implementamos a parte da busca, e com o arquivo
_poem.txt_ como segundo argumento:

```console
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-04/output.txt}}
```

Ótimo! O código leu e depois imprimiu o conteúdo do arquivo. Mas ele tem
alguns problemas. Neste momento, a função `main` tem responsabilidades demais.
Em geral, funções são mais claras e mais fáceis de manter quando cada uma é
responsável por apenas uma ideia. O outro problema é que ainda não estamos
tratando erros tão bem quanto poderíamos. O programa ainda é pequeno, então
essas falhas não são graves, mas, à medida que ele crescer, será mais difícil
corrigi-las de forma limpa. Uma boa prática é começar a refatorar cedo no
desenvolvimento, porque é muito mais fácil refatorar pequenas quantidades de
código. É isso que faremos a seguir.

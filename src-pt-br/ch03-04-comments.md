## Comentários

Todos os programadores se esforçam para tornar seu código fácil de entender,
mas, às vezes, uma explicação extra é necessária. Nesses casos, os programadores
deixam notas, ou *comentários*, em seu código-fonte que o compilador ignora, mas que as pessoas que
lerem o código-fonte podem achar útil.

Aqui está um comentário simples:

```rust
// Olá, mundo.
```

Em Rust, os comentários devem começar com duas barras e continuar até o final da
linha. Para comentários que se estendem por mais de uma linha, você precisará incluir
`//` em cada linha, assim:

```rust
// Então, estamos fazendo algo complicado aqui, tempo suficiente para que precisemos
// várias linhas de comentários para fazer isso! Ufa! Espero que este comentário
// explique o que está acontecendo.
```

Comentários também podem ser colocados no final das linhas contendo código:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
fn main() {
    let numero_da_sorte = 7; // Estou com sorte hoje.
}
```

Mas você verá isso com mais frequência neste formato, com o comentário em uma
linha separada acima do código que está anotando:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
fn main() {
    // Estou com sorte hoje.
    let numero_da_sorte = 7;
}
```

O Rust também tem outro tipo de comentário, os comentários de documentação, que discutiremos
no Capítulo 14.

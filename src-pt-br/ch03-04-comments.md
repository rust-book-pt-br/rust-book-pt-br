## Comentários

Todos os programadores se esforçam para tornar seu código fácil de entender, mas às vezes
explicação extra é garantida. Nestes casos, os programadores deixam notas ou
*comentários*, em seus códigos fonte que o compilador irá ignorar, mas as pessoas que
lerem o código-fonte podem achar útil.

Aqui está um comentário simples:

```rust
// Olá, mundo.
```

Em Rust, os comentários devem começar com duas barras e continuar até o final da
linha. Para comentários que se estendem além de uma única linha, você precisará incluir
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

Mas você verá com mais frequência essas palavras nesse formato, com o comentário em uma
linha separada acima do código que está anotando:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
fn main() {
    // Estou com sorte hoje.
    let numero_da_sorte = 7;
}
```

O Rust também tem outro tipo de comentário, comentários de documentação, que discutiremos
no Capítulo 14.

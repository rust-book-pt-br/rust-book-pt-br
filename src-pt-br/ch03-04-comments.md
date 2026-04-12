## Comentários

Todo programador se esforça para tornar seu código fácil de entender, mas às
vezes uma explicação extra é necessária. Nesses casos, programadores deixam
_comentários_ no código-fonte, que o compilador ignora, mas que podem ser úteis
para quem estiver lendo o código.

Aqui está um comentário simples:

```rust
// hello, world
```

Em Rust, o estilo idiomático de comentário começa com duas barras, e o
comentário continua até o fim da linha. Para comentários que ocupam mais de uma
linha, você precisa incluir `//` em cada linha, assim:

```rust
// So we're doing something complicated here, long enough that we need
// multiple lines of comments to do it! Whew! Hopefully, this comment will
// explain what's going on.
```

Comentários também podem ser colocados ao final de linhas que contêm código:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-24-comments-end-of-line/src/main.rs}}
```

Mas com mais frequência você os verá neste formato, com o comentário em uma
linha separada acima do código que ele está anotando:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-25-comments-above-line/src/main.rs}}
```

Rust também tem outro tipo de comentário, os comentários de documentação, que
discutiremos na seção
[“Publicando uma crate no Crates.io”][publishing]<!-- ignore --> do Capítulo
14.

[publishing]: ch14-02-publishing-to-crates-io.html

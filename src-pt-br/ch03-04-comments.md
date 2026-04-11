## Comentários

Todos os programadores se esforçam para tornar seu código fácil de entender, mas às vezes
explicação extra é necessária. Nestes casos, os programadores deixam _comentários_ em
seu código-fonte que o compilador irá ignorar, mas que as pessoas que lêem o
o código-fonte pode ser útil.

Aqui está um comentário simples:

```rust
// hello, world
```

No Rust, o estilo de comentário idiomático inicia um comentário com duas barras, e o
o comentário continua até o final da linha. Para comentários que vão além de um
única linha, você precisará incluir `//` em cada linha, assim:

```rust
// So we're doing something complicated here, long enough that we need
// multiple lines of comments to do it! Whew! Hopefully, this comment will
// explain what's going on.
```

Comentários também podem ser colocados no final das linhas que contêm código:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-24-comments-end-of-line/src/main.rs}}
```

Mas você os verá com mais frequência usados ​​neste formato, com o comentário em um
linha separada acima do código que está anotando:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-25-comments-above-line/src/main.rs}}
```

Rust também tem outro tipo de comentário, comentários de documentação, que iremos
discutir em [“Publicando uma caixa no Crates.io”][publishing]<!-- ignore -->
seção do Capítulo 14.

[publishing]: ch14-02-publishing-to-crates-io.html

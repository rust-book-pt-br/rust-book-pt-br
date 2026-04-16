<!-- Old headings. Do not remove or links may break. -->

<a id="installing-binaries-from-cratesio-with-cargo-install"></a>

## Instalando Binários com `cargo install`

O comando `cargo install` permite instalar e usar crates binários localmente.
Isso não se destina a substituir pacotes do sistema; a ideia é oferecer uma
forma conveniente para pessoas desenvolvedoras Rust instalarem ferramentas que outras
pessoas compartilharam em [crates.io](https://crates.io/)<!-- ignore -->.
Observe que você só pode instalar pacotes que tenham alvos binários. Um _alvo
binário_ é o programa executável criado quando o crate tem um arquivo
_src/main.rs_ ou outro arquivo especificado como binário, em contraste com um
alvo de biblioteca, que não pode ser executado por conta própria, mas é
apropriado para ser incluído em outros programas. Normalmente, crates têm
informações no README sobre se são bibliotecas, se têm um alvo binário ou se
têm ambos.

Todos os binários instalados com `cargo install` são armazenados na pasta _bin_
da raiz de instalação. Se você instalou o Rust usando _rustup.rs_ e não tem
configurações personalizadas, esse diretório será *$HOME/.cargo/bin*. Garanta
que ele esteja no seu `$PATH` para poder executar os programas instalados com
`cargo install`.

Por exemplo, no Capítulo 12 mencionamos que existe uma implementação em Rust da
ferramenta `grep`, chamada `ripgrep`, para pesquisar em arquivos. Para instalar
o `ripgrep`, podemos executar o seguinte:

<!-- manual-regeneration
cargo install something you don't have, copy relevant output below
-->

```console
$ cargo install ripgrep
    Updating crates.io index
  Downloaded ripgrep v14.1.1
  Downloaded 1 crate (213.6 KB) in 0.40s
  Installing ripgrep v14.1.1
--snip--
   Compiling grep v0.3.2
    Finished `release` profile [optimized + debuginfo] target(s) in 6.73s
  Installing ~/.cargo/bin/rg
   Installed package `ripgrep v14.1.1` (executable `rg`)
```

A penúltima linha da saída mostra a localização e o nome do binário instalado,
que no caso de `ripgrep` é `rg`. Desde que o diretório de instalação esteja no
seu `$PATH`, como mencionado anteriormente, você poderá executar `rg --help` e
começar a usar uma ferramenta mais rápida, escrita em Rust, para pesquisar
arquivos!

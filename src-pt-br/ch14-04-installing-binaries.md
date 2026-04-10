<!-- Old headings. Do not remove or links may break. -->

<a id="installing-binaries-from-cratesio-with-cargo-install"></a>

## Instalando binários com `cargo install`

O comando `cargo install` permite instalar e usar o binário crates
localmente. Isto não se destina a substituir pacotes do sistema; é para ser um
maneira conveniente para os desenvolvedores do Rust instalarem ferramentas que outras pessoas compartilharam
[crates.io](https://crates.io/)<!-- ignore -->. Observe que você só pode instalar
pacotes que possuem alvos binários. Um _alvo binário_ é o programa executável
que é criado se o crate tiver um arquivo _src/main.rs_ ou outro arquivo especificado
como um binário, em oposição a um alvo de biblioteca que não pode ser executado por si só, mas
é adequado para inclusão em outros programas. Normalmente, crates tem
informações no arquivo README sobre se um crate é uma biblioteca, tem um
alvo binário ou ambos.

Todos os binários instalados com `cargo install` são armazenados no arquivo de instalação
pasta _bin_ do root. Se você instalou o Rust usando _rustup.rs_ e não tem nenhum
configurações personalizadas, este diretório será *$HOME/.cargo/bin*. Certifique-se de que
este diretório está no seu `$PATH` para poder executar programas que você instalou
com `cargo install`.

Por exemplo, no Capítulo 12 mencionamos que existe uma implementação Rust de
a ferramenta `grep` chamada `ripgrep` para pesquisar arquivos. Para instalar o `ripgrep`, nós
pode executar o seguinte:

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

A penúltima linha da saída mostra a localização e o nome do
binário instalado, que no caso de `ripgrep` é `rg`. Enquanto o
diretório de instalação está em seu ` $PATH`, conforme mencionado anteriormente, você pode
em seguida, execute ` rg --help`e comece a usar uma ferramenta Rustier mais rápida para pesquisar arquivos!

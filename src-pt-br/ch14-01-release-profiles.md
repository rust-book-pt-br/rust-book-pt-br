## Personalizando Builds com Perfis de Release

Em Rust, _perfis de release_ são perfis predefinidos e personalizáveis com
configurações diferentes, que permitem à pessoa programadora ter mais controle
sobre várias opções de compilação. Cada perfil é configurado independentemente
dos demais.

Cargo tem dois perfis principais: o perfil `dev`, que o Cargo usa quando você
executa `cargo build`, e o perfil `release`, que o Cargo usa quando você
executa `cargo build --release`. O perfil `dev` tem bons padrões para
desenvolvimento, e o perfil `release` tem bons padrões para builds de release.

Esses nomes de perfil talvez já sejam familiares pela saída das suas
compilações:

<!-- manual-regeneration
anywhere, run:
cargo build
cargo build --release
and ensure output below is accurate
-->

```console
$ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
$ cargo build --release
    Finished `release` profile [optimized] target(s) in 0.32s
```

Esses `dev` e `release` são os perfis diferentes usados pelo compilador.

Cargo possui configurações padrão para cada perfil, aplicadas quando você não
adiciona explicitamente seções `[profile.*]` ao arquivo _Cargo.toml_ do
projeto. Ao adicionar seções `[profile.*]` para qualquer perfil que queira
personalizar, você substitui qualquer subconjunto dessas configurações padrão.
Por exemplo, estes são os valores padrão da configuração `opt-level` para os
perfis `dev` e `release`:

<span class="filename">Arquivo: Cargo.toml</span>

```toml
[profile.dev]
opt-level = 0

[profile.release]
opt-level = 3
```

A configuração `opt-level` controla o número de otimizações que Rust aplicará
ao seu código, em uma escala de 0 a 3. Aplicar mais otimizações aumenta o
tempo de compilação; então, se você está em desenvolvimento e compila seu
código com frequência, vai querer menos otimizações para compilar mais rápido,
mesmo que o código resultante rode mais devagar. Por isso, o `opt-level`
padrão para `dev` é `0`. Quando você estiver pronto para lançar seu código, é
melhor gastar mais tempo compilando. Você só compilará em modo de release uma
vez, mas executará o programa compilado muitas vezes, então o modo de release
troca um tempo de compilação maior por código que executa mais rápido. É por
isso que o `opt-level` padrão do perfil `release` é `3`.

Você pode substituir uma configuração padrão adicionando um valor diferente para
ela em _Cargo.toml_. Por exemplo, se quisermos usar o nível de otimização 1 no
perfil de desenvolvimento, podemos adicionar estas duas linhas ao
_Cargo.toml_ do projeto:

<span class="filename">Arquivo: Cargo.toml</span>

```toml
[profile.dev]
opt-level = 1
```

Esse código substitui a configuração padrão `0`. Agora, quando executarmos
`cargo build`, o Cargo usará os padrões do perfil `dev` mais a nossa
customização de `opt-level`. Como definimos `opt-level` como `1`, o Cargo
aplicará mais otimizações do que o padrão, mas não tantas quanto em um build
de release.

Para obter a lista completa de opções de configuração e os padrões de cada
perfil, consulte [a documentação do Cargo](https://doc.rust-lang.org/cargo/reference/profiles.html).

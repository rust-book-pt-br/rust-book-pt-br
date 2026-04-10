## Personalizando compilações com perfis de lançamento

No Rust, _perfis de lançamento_ são perfis predefinidos e personalizáveis com
configurações diferentes que permitem ao programador ter mais controle sobre
várias opções para compilar código. Cada perfil é configurado independentemente de
os outros.

Cargo tem dois perfis principais: o perfil `dev` que Cargo usa quando você executa `cargo
build` e o perfil `release` que Cargo usa quando você executa `cargo build
--release`. O perfil ` dev`é definido com bons padrões para desenvolvimento,
e o perfil ` release`possui bons padrões para compilações de lançamento.

Esses nomes de perfil podem ser familiares na saída de suas compilações:

<!-- manual-regeneration
em qualquer lugar, execute:
Construção cargo
Compilação cargo --lançamento
e garantir que a saída abaixo seja precisa
-->

```console
$ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
$ cargo build --release
    Finished `release` profile [optimized] target(s) in 0.32s
```

O `dev` e `release` são esses perfis diferentes usados ​​pelo compilador.

Cargo possui configurações padrão para cada um dos perfis que se aplicam quando você não
adicionou explicitamente quaisquer seções `[profile.*]` no arquivo _Cargo.toml_ do projeto.
Ao adicionar seções `[profile.*]` para qualquer perfil que você deseja personalizar, você
substituir qualquer subconjunto das configurações padrão. Por exemplo, aqui estão os padrões
valores para a configuração `opt-level` para os perfis `dev` e `release`:

<span class="filename">Filename: Cargo.toml</span>

```toml
[profile.dev]
opt-level = 0

[profile.release]
opt-level = 3
```

A configuração `opt-level` controla o número de otimizações que Rust aplicará
seu código, com um intervalo de 0 a 3. Aplicar mais otimizações estende
tempo de compilação, portanto, se você estiver desenvolvendo e compilando seu código com frequência,
você desejará menos otimizações para compilar mais rapidamente, mesmo que o código resultante
corre mais devagar. O `opt-level` padrão para `dev` é, portanto, `0`. Quando você está
pronto para liberar seu código, é melhor gastar mais tempo compilando. Você só vai
compilar no modo de lançamento uma vez, mas você executará o programa compilado muitas vezes,
portanto, o modo de liberação troca um tempo de compilação mais longo por código que é executado mais rapidamente. Isso é
por que o ` opt-level`padrão para o perfil ` release`é ` 3`.

Você pode substituir uma configuração padrão adicionando um valor diferente para ela em
_Carga.toml_. Por exemplo, se quisermos usar o nível de otimização 1 no
perfil de desenvolvimento, podemos adicionar essas duas linhas ao _Cargo.toml_ do nosso projeto
arquivo:

<span class="filename">Filename: Cargo.toml</span>

```toml
[profile.dev]
opt-level = 1
```

Este código substitui a configuração padrão de `0`. Agora, quando executamos ` cargo build`,
Cargo usará os padrões para o perfil ` dev`mais nossa personalização para
` opt-level `. Como definimos` opt-level `como` 1`, Cargo aplicará mais
otimizações do que o padrão, mas não tantas quanto em uma versão de lançamento.

Para obter a lista completa de opções de configuração e padrões para cada perfil, consulte
[Documentação do Cargo](https://doc.rust-lang.org/cargo/reference/profiles.html).

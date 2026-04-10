## Publicando uma caixa no Crates.io

Usamos pacotes de [crates.io](https://crates.io/)<!-- ignore --> como
dependências do nosso projeto, mas você também pode compartilhar seu código com outras pessoas
publicando seus próprios pacotes. O registro crate em
[crates.io](https://crates.io/)<!-- ignore --> distribui o código-fonte de
seus pacotes, portanto, ele hospeda principalmente código de código aberto.

Rust e Cargo possuem recursos que tornam seu pacote publicado mais fácil para as pessoas
para encontrar e usar. Falaremos sobre alguns desses recursos a seguir e depois explicaremos
como publicar um pacote.

### Making Useful Documentation Comments

Documentar com precisão seus pacotes ajudará outros usuários a saber como e quando
use-os, então vale a pena investir tempo para escrever a documentação. No capítulo
3, discutimos como comentar o código Rust usando duas barras, `//`. Rust também tem
um tipo particular de comentário para documentação, conhecido convenientemente como
_comentário de documentação_, que irá gerar a documentação HTML. O HTML
exibe o conteúdo dos comentários da documentação para itens públicos da API destinados
para programadores interessados em saber como _usar_ seu crate em vez de como
seu crate está _implementado_.

Os comentários da documentação usam três barras, `///`, em vez de duas e suportam
Notação Markdown para formatar o texto. Coloque comentários de documentação apenas
antes do item que estão documentando. A Listagem 14-1 mostra comentários da documentação
para uma função ` add_one`em um crate denominado ` my_crate`.

<Listing number="14-1" file-name="src/lib.rs" caption="Um comentário de documentação para uma função">

```rust,ignore
{{#rustdoc_include ../listings/ch14-more-about-cargo/listing-14-01/src/lib.rs}}
```

</Listing>

Aqui damos uma descrição do que a função `add_one` faz, iniciamos um
seção com o título `Examples` e, em seguida, forneça o código que demonstra
como usar a função `add_one`. Podemos gerar a documentação HTML a partir de
este comentário da documentação executando ` cargo doc`. Este comando executa o
Ferramenta ` rustdoc`distribuída com Rust e coloca a documentação HTML gerada
no diretório _target/doc_.

Por conveniência, executar `cargo doc --open` criará o HTML para o seu
documentação atual do crate (bem como a documentação de todos os seus
Dependências do crate) e abra o resultado em um navegador da web. Navegue até o
Função `add_one` e você verá como é o texto nos comentários da documentação
renderizado, conforme mostrado na Figura 14-1.

<img alt="Rendered HTML documentation for the `add_one` function of `my_crate` " src="img/trpl14-01.png" class="center" />

<span class="caption">Figura 14-1: A documentação HTML do `add_one`
função</span>

#### Commonly Used Sections

Usamos o título `# Examples` Markdown na Listagem 14-1 para criar uma seção
no HTML com o título “Exemplos”. Aqui estão algumas outras seções que crate
autores comumente usam em sua documentação:

- **Pânicos**: Estes são os cenários em que a função que está sendo documentada
  poderia panic. Chamadores da função que não desejam que seus programas sejam panic
  devem garantir que eles não chamem a função nessas situações.
- **Erros**: Se a função retornar um `Result`, descrevendo os tipos de
  erros que podem ocorrer e quais condições podem fazer com que esses erros sejam
  retornado pode ser útil para os chamadores, para que possam escrever código para lidar com o
  diferentes tipos de erros de maneiras diferentes.
- **Segurança**: Se a função for chamada ` unsafe`(discutiremos insegurança em
  Capítulo 20), deve haver uma seção explicando por que a função não é segura
  e cobrindo as invariantes que a função espera que os chamadores mantenham.

A maioria dos comentários de documentação não precisa de todas essas seções, mas esta é uma
uma boa lista de verificação para lembrá-lo dos aspectos dos usuários do seu código será
interessado em saber.

#### Documentation Comments as Tests

Adicionar blocos de código de exemplo nos comentários da documentação pode ajudar a demonstrar
como usar sua biblioteca e tem um bônus adicional: executar `cargo test` irá
execute os exemplos de código em sua documentação como testes! Nada é melhor do que
documentação com exemplos. Mas nada é pior do que exemplos que não funcionam
porque o código mudou desde que a documentação foi escrita. Se corrermos
`cargo test ` com a documentação para a função`add_one` da Listagem
14-1, veremos uma seção nos resultados do teste semelhante a esta:

<!-- manual-regeneration
cd listings/ch14-more-about-cargo/listing-14-01/
cargo test
copy just the doc-tests section below
-->

```text
   Doc-tests my_crate

running 1 test
test src/lib.rs - add_one (line 5) ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.27s
```

Agora, se mudarmos a função ou o exemplo para que `assert_eq!`
no exemplo entra em pânico e execute ` cargo test`novamente, veremos que o documento testa
perceba que o exemplo e o código estão fora de sincronia um com o outro!

<!-- Old headings. Do not remove or links may break. -->

<a id="commenting-contained-items"></a>

#### Contained Item Comments

O estilo de comentário do documento `//!` adiciona documentação ao item que *contém*
os comentários, e não aos itens *após* os comentários. Nós normalmente
use estes comentários do documento dentro do arquivo raiz crate (_src/lib.rs_ por convenção)
ou dentro de um módulo para documentar o crate ou o módulo como um todo.

Por exemplo, para adicionar documentação que descreva a finalidade do `my_crate`
crate que contém a função ` add_one`, adicionamos comentários de documentação que
comece com ` //!`até o início do arquivo _src/lib.rs_, conforme mostrado na Listagem
14-2.

<Listing number="14-2" file-name="src/lib.rs" caption="A documentação do crate `my_crate` como um todo">

```rust,ignore
{{#rustdoc_include ../listings/ch14-more-about-cargo/listing-14-02/src/lib.rs:here}}
```

</Listing>

Observe que não há nenhum código após a última linha que comece com `//!`. Porque
iniciamos os comentários com ` //!`em vez de ` ///`, estamos documentando o item
que contém este comentário em vez de um item que segue este comentário. Em
neste caso, esse item é o arquivo _src/lib.rs_, que é a raiz crate. Estes
comentários descrevem todo o crate.

Quando executamos `cargo doc --open`, esses comentários serão exibidos na primeira página
da documentação para ` my_crate`acima da lista de itens públicos no
crate, conforme mostrado na Figura 14-2.

Os comentários da documentação nos itens são úteis para descrever crates e
módulos especialmente. Use-os para explicar o propósito geral do contêiner para
ajude seus usuários a entender a organização do crate.

<img alt="Rendered HTML documentation with a comment for the crate as a whole" src="img/trpl14-02.png" class="center" />

<span class="caption">Figura 14-2: A documentação renderizada para `my_crate`,
incluindo o comentário que descreve o crate como um todo</span>

<!-- Old headings. Do not remove or links may break. -->

<a id="exporting-a-convenient-public-api-with-pub-use"></a>

### Exporting a Convenient Public API

A estrutura da sua API pública é uma consideração importante ao publicar um
crate. As pessoas que usam seu crate estão menos familiarizadas com a estrutura do que você
são e podem ter dificuldade em encontrar as peças que desejam usar se o seu crate
tem uma grande hierarquia de módulos.

No Capítulo 7, abordamos como tornar os itens públicos usando a palavra-chave `pub` e
como trazer itens para um escopo com a palavra-chave `use`. No entanto, a estrutura
que faz sentido para você enquanto você está desenvolvendo um crate pode não ser muito
conveniente para seus usuários. Você pode querer organizar suas estruturas em um
hierarquia contendo vários níveis, mas as pessoas que desejam usar um tipo
que você definiu profundamente na hierarquia pode ter dificuldade em descobrir esse tipo
existe. Eles também podem ficar incomodados por ter que inserir ` use
my_crate::some_module::another_module::UsefulType;`em vez de ` use
my_crate::UsefulType;`.

A boa notícia é que se a estrutura _não_ for conveniente para outros usarem
de outra biblioteca, você não precisa reorganizar sua organização interna:
Em vez disso, você pode reexportar itens para criar uma estrutura pública diferente
da sua estrutura privada usando `pub use`. *Reexportar* torna público
item em um local e o torna público em outro local, como se fosse
definido em outro local.

Por exemplo, digamos que criamos uma biblioteca chamada `art` para modelar conceitos artísticos.
Dentro desta biblioteca estão dois módulos: um módulo `kinds` contendo dois enums
nomeados `PrimaryColor` e `SecondaryColor` e um módulo `utils` contendo um
função chamada `mix`, conforme mostrado na Listagem 14-3.

<Listing number="14-3" file-name="src/lib.rs" caption="Uma biblioteca `art` com itens organizados nos módulos `kinds` e `utils`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch14-more-about-cargo/listing-14-03/src/lib.rs:here}}
```

</Listing>

A Figura 14-3 mostra a primeira página da documentação deste crate
gerado por `cargo doc` seria.

<img alt="Rendered documentation for the `art` crate that lists the `kinds` and `utils` modules" src="img/trpl14-03.png" class="center" />

<span class="caption">Figura 14-3: A primeira página da documentação do `art`
que lista os módulos ` kinds`e ` utils`</span>

Observe que os tipos `PrimaryColor` e `SecondaryColor` não estão listados no
primeira página, nem a função `mix`. Temos que clicar em ` kinds`e ` utils`para
vê-los.

Outro crate que depende desta biblioteca precisaria de instruções `use` que
traga os itens de `art` para o escopo, especificando a estrutura do módulo que está
atualmente definido. A Listagem 14-4 mostra um exemplo de crate que usa o
Itens `PrimaryColor` e `mix` do `art` crate.

<Listing number="14-4" file-name="src/main.rs" caption="Um crate usando os itens do crate `art` com sua estrutura interna exportada">

```rust,ignore
{{#rustdoc_include ../listings/ch14-more-about-cargo/listing-14-04/src/main.rs}}
```

</Listing>

O autor do código na Listagem 14-4, que usa `art` crate, teve que
descubra que `PrimaryColor` está no módulo `kinds` e `mix` está no módulo
Módulo `utils`. A estrutura do módulo do ` art`crate é mais relevante para
desenvolvedores que trabalham no ` art`crate do que aqueles que o utilizam. O interno
estrutura não contém nenhuma informação útil para alguém que está tentando
entender como usar o ` art`crate, mas causa confusão porque
os desenvolvedores que o utilizam precisam descobrir onde procurar e devem especificar o
nomes de módulos nas instruções ` use`.

Para remover a organização interna da API pública, podemos modificar o
`art ` Código crate na Listagem 14-3 para adicionar instruções`pub use` para reexportar o
itens no nível superior, conforme mostrado na Listagem 14-5.

<Listing number="14-5" file-name="src/lib.rs" caption="Adicionando instruções `pub use` para reexportar itens">

```rust,ignore
{{#rustdoc_include ../listings/ch14-more-about-cargo/listing-14-05/src/lib.rs:here}}
```

</Listing>

A documentação da API que `cargo doc` gera para este crate agora listará
e reexportações de links na primeira página, conforme mostrado na Figura 14-4, fazendo com que o
Os tipos `PrimaryColor` e `SecondaryColor` e a função `mix` são mais fáceis de encontrar.

<img alt="Rendered documentation for the `art` crate with the re-exports on the front page" src="img/trpl14-04.png" class="center" />

<span class="caption">Figura 14-4: A primeira página da documentação do `art`
que lista as reexportações</span>

Os usuários `art` crate ainda podem ver e usar a estrutura interna da Listagem
14-3 conforme demonstrado na Listagem 14-4, ou podem usar a forma mais conveniente
estrutura na Listagem 14-5, conforme mostrado na Listagem 14-6.

<Listing number="14-6" file-name="src/main.rs" caption="Um programa usando os itens reexportados do crate `art`">

```rust,ignore
{{#rustdoc_include ../listings/ch14-more-about-cargo/listing-14-06/src/main.rs:here}}
```

</Listing>

Nos casos em que há muitos módulos aninhados, reexportar os tipos no topo
nível com `pub use` pode fazer uma diferença significativa na experiência de
pessoas que usam o crate. Outro uso comum do `pub use` é reexportar
definições de uma dependência no crate atual para fazer com que o crate
definições que fazem parte da API pública do seu crate.

Criar uma estrutura de API pública útil é mais uma arte do que uma ciência, e você
pode iterar para encontrar a API que funciona melhor para seus usuários. Escolhendo `pub use`
oferece flexibilidade na forma como você estrutura seu crate internamente e desacopla
essa estrutura interna a partir do que você apresenta aos seus usuários. Veja alguns
o código do crates que você instalou para ver se sua estrutura interna é diferente
de sua API pública.

### Configurando uma conta Crates.io

Antes de publicar qualquer crates, você precisa criar uma conta no
[crates.io](https://crates.io/)<!-- ignore --> e obtenha um token de API. Para fazer isso,
visite a página inicial em [crates.io](https://crates.io/)<!-- ignore --> e registre-se
por meio de uma conta GitHub. (A conta GitHub é atualmente um requisito, mas
o site pode oferecer suporte a outras formas de criação de uma conta no future.) Uma vez
você está logado, visite as configurações da sua conta em
[https://crates.io/me/](https://crates.io/me/)<!-- ignore --> e recupere seu
Chave de API. Em seguida, execute o comando `cargo login` e cole sua chave API quando solicitado, assim:

```console
$ cargo login
abcdefghijklmnopqrstuvwxyz012345
```

Este comando informará Cargo sobre seu token de API e o armazenará localmente em
_~/.cargo/credenciais.toml_. Observe que este token é um segredo: não compartilhe
isso com qualquer outra pessoa. Se você compartilhá-lo com alguém por qualquer motivo, você deve
revogá-lo e gerar um novo token em [crates.io](https://crates.io/)<!-- ignore
-->.

### Adding Metadata to a New Crate

Digamos que você tenha um crate que deseja publicar. Antes de publicar, você precisará
para adicionar alguns metadados na seção `[package]` do _Cargo.toml_ do crate
arquivo.

Seu crate precisará de um nome exclusivo. Enquanto você trabalha em um crate localmente,
você pode nomear um crate como quiser. No entanto, os nomes crate em
[crates.io](https://crates.io/)<!-- ignore --> são alocados por ordem de chegada,
primeiro a ser servido. Depois que um nome crate for escolhido, ninguém mais poderá publicar um crate
com esse nome. Antes de tentar publicar um crate, pesquise o nome que você
deseja usar. Se o nome tiver sido usado, você precisará encontrar outro nome e
edite o campo `name` no arquivo _Cargo.toml_ na seção `[package]` para
use o novo nome para publicação, assim:

<span class="filename">Filename: Cargo.toml</span>

```toml
[package]
name = "guessing_game"
```

Mesmo que você tenha escolhido um nome exclusivo, ao executar `cargo publish` para publicar
o crate neste ponto, você receberá um aviso e, em seguida, um erro:

<!-- manual-regeneration
Crie um novo pacote com um nome não registrado, sem fazer mais modificações
  ao pacote gerado, portanto faltam os campos de descrição e licença.
Publicação cargo
copie apenas as linhas relevantes abaixo
-->

```console
$ cargo publish
    Updating crates.io index
warning: manifest has no description, license, license-file, documentation, homepage or repository.
See https://doc.rust-lang.org/cargo/reference/manifest.html#package-metadata for more info.
--snip--
error: failed to publish to registry at https://crates.io

Caused by:
  the remote server responded with an error (status 400 Bad Request): missing or empty metadata fields: description, license. Please see https://doc.rust-lang.org/cargo/reference/manifest.html for more information on configuring these fields
```

Isso resulta em um erro porque estão faltando algumas informações cruciais: A
descrição e licença são necessárias para que as pessoas saibam qual é o seu crate
faz e sob quais termos eles podem usá-lo. Em _Cargo.toml_, adicione uma descrição
isso é apenas uma ou duas frases, porque aparecerá com seu crate na pesquisa
resultados. Para o campo `license`, você precisa fornecer um identificador _license
valor_. O [Troca de Dados de Pacotes de Software (SPDX) da Linux Foundation][spdx]
lista os identificadores que você pode usar para esse valor. Por exemplo, para especificar que
você licenciou seu crate usando a licença MIT, adicione o identificador ` MIT`:

<span class="filename">Filename: Cargo.toml</span>

```toml
[package]
name = "guessing_game"
license = "MIT"
```

Se você quiser usar uma licença que não aparece no SPDX, você precisa colocar
o texto dessa licença em um arquivo, inclua o arquivo em seu projeto e, em seguida,
use `license-file` para especificar o nome desse arquivo em vez de usar o
Chave `license`.

A orientação sobre qual licença é apropriada para o seu projeto está além do escopo
deste livro. Muitas pessoas na comunidade Rust licenciam seus projetos no
da mesma forma que Rust usando uma licença dupla de `MIT OR Apache-2.0`. Esta prática
demonstra que você também pode especificar vários identificadores de licença separados
por ` OR`para ter múltiplas licenças para o seu projeto.

Com um nome exclusivo, a versão, sua descrição e uma licença adicionada, o
O arquivo _Cargo.toml_ para um projeto que está pronto para publicação pode ter a seguinte aparência:

<span class="filename">Filename: Cargo.toml</span>

```toml
[package]
name = "guessing_game"
version = "0.1.0"
edition = "2024"
description = "A fun game where you guess what number the computer has chosen."
license = "MIT OR Apache-2.0"

[dependencies]
```

[Documentação do Cargo](https://doc.rust-lang.org/cargo/) descreve outros
metadados que você pode especificar para garantir que outras pessoas possam descobrir e usar seu crate
mais facilmente.

### Publicando em Crates.io

Agora que você criou uma conta, salvou seu token de API, escolheu um nome para
seu crate e especificou os metadados necessários, você está pronto para publicar!
Publicar um crate carrega uma versão específica para
[crates.io](https://crates.io/)<!-- ignore --> para outros usarem.

Tenha cuidado, porque uma publicação é _permanente_. A versão nunca pode ser
substituído e o código não pode ser excluído, exceto em certas circunstâncias.
Um dos principais objetivos do Crates.io é atuar como um arquivo permanente de código para que
builds de todos os projetos que dependem do crates de
[crates.io](https://crates.io/)<!-- ignore --> continuará funcionando. Permitindo
exclusões de versões tornariam impossível cumprir esse objetivo. No entanto, há
não há limite para o número de versões do crate que você pode publicar.

Run the `cargo publish` command again. It should succeed now:

<!-- manual-regeneration
go to some valid crate, publish a new version
cargo publish
copy just the relevant lines below
-->

```console
$ cargo publish
    Updating crates.io index
   Packaging guessing_game v0.1.0 (file:///projects/guessing_game)
    Packaged 6 files, 1.2KiB (895.0B compressed)
   Verifying guessing_game v0.1.0 (file:///projects/guessing_game)
   Compiling guessing_game v0.1.0
(file:///projects/guessing_game/target/package/guessing_game-0.1.0)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.19s
   Uploading guessing_game v0.1.0 (file:///projects/guessing_game)
    Uploaded guessing_game v0.1.0 to registry `crates-io`
note: waiting for `guessing_game v0.1.0` to be available at registry
`crates-io`.
You may press ctrl-c to skip waiting; the crate should be available shortly.
   Published guessing_game v0.1.0 at registry `crates-io`
```

Parabéns! Agora você compartilhou seu código com a comunidade Rust e
qualquer pessoa pode facilmente adicionar seu crate como uma dependência de seu projeto.

### Publishing a New Version of an Existing Crate

Quando você fizer alterações em seu crate e estiver pronto para lançar uma nova versão,
você altera o valor `version` especificado em seu arquivo _Cargo.toml_ e
republicar. Use as [Regras de Versionamento Semântico][semver] para decidir qual
O próximo número de versão apropriado é baseado nos tipos de alterações que você fez.
Em seguida, execute `cargo publish` para fazer upload da nova versão.

<!-- Old headings. Do not remove or links may break. -->

<a id="removing-versions-from-cratesio-with-cargo-yank"></a>
<a id="deprecating-versions-from-cratesio-with-cargo-yank"></a>

### Descontinuando versões do Crates.io

Embora não seja possível remover versões anteriores de um crate, você pode evitar qualquer
Projetos future de adicioná-los como uma nova dependência. Isto é útil quando um
A versão crate está quebrada por um motivo ou outro. Em tais situações, Cargo
suporta arrancar uma versão crate.

_Extrair_ uma versão evita que novos projetos dependam dessa versão enquanto
permitindo que todos os projetos existentes que dependem dele continuem. Essencialmente, um
yank significa que todos os projetos com _Cargo.lock_ não serão quebrados e qualquer future
Os arquivos _Cargo.lock_ gerados não usarão a versão extraída.

Para extrair uma versão de um crate, no diretório do crate que você
publicado anteriormente, execute `cargo yank` e especifique qual versão você deseja
puxar. Por exemplo, se publicamos uma versão crate chamada `guessing_game`
1.0.1 e quisermos arrancá-lo, então executaríamos o seguinte no projeto
diretório para ` guessing_game`:

<!-- manual-regeneration:
cargo yank carol-test --version 2.1.0
cargo yank carol-test --version 2.1.0 --undo
-->

```console
$ cargo yank --vers 1.0.1
    Updating crates.io index
        Yank guessing_game@1.0.1
```

Ao adicionar `--undo` ao comando, você também pode desfazer um puxão e permitir projetos
para começar a depender de uma versão novamente:

```console
$ cargo yank --vers 1.0.1 --undo
    Updating crates.io index
      Unyank guessing_game@1.0.1
```

Um puxão _não_ exclui nenhum código. Não pode, por exemplo, excluir acidentalmente
segredos carregados. Se isso acontecer, você deverá redefinir esses segredos imediatamente.

[spdx]: https://spdx.org/licenses/
[semver]: https://semver.org/

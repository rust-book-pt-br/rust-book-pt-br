## Apêndice G - Como o Rust é Feito e o “Rust Nightly”

Este apêndice trata de como o Rust é produzido e de como isso afeta você como
desenvolvedora ou desenvolvedor Rust.

### Estabilidade sem estagnação

Como linguagem, Rust se importa _muito_ com a estabilidade do seu código.
Queremos que Rust seja uma base sólida sobre a qual você possa construir, e,
se as coisas estivessem mudando o tempo todo, isso seria impossível. Ao mesmo
tempo, se não pudermos experimentar recursos novos, talvez só descubramos
falhas importantes depois do lançamento, quando já não poderemos mais mudar as
coisas.

Nossa solução para esse problema é o que chamamos de “estabilidade sem
estagnação”, e nosso princípio orientador é este: você nunca deveria ter medo
de atualizar para uma nova versão estável do Rust. Cada atualização deve ser
indolor, mas também deve trazer recursos novos, menos bugs e tempos de
compilação mais rápidos.

### Tchu, tchu! Canais de lançamento e o modelo de trem

O desenvolvimento do Rust segue um _modelo de trem_. Isto é, todo o
desenvolvimento acontece no branch principal do repositório do Rust. Os
lançamentos seguem um modelo de trem de lançamento de software, como o usado
pelo Cisco IOS e por outros projetos. Há três _canais de lançamento_ do Rust:

- Nightly
- Beta
- Stable

A maior parte das pessoas desenvolvedoras Rust usa principalmente o canal
stable, mas quem quiser experimentar recursos novos ainda experimentais pode
usar nightly ou beta.

Aqui está um exemplo de como o processo de desenvolvimento e lançamento
funciona: vamos supor que a equipe do Rust esteja trabalhando no lançamento do
Rust 1.5. Esse lançamento aconteceu em dezembro de 2015, mas nos fornecerá
números de versão realistas. Um novo recurso é adicionado ao Rust: um novo
commit chega ao branch principal. A cada noite, uma nova versão nightly do
Rust é produzida. Todo dia é dia de lançamento, e esses lançamentos são
criados automaticamente pela nossa infraestrutura. Então, com o passar do
tempo, os lançamentos ficam assim, uma vez por noite:

```text
nightly: * - - * - - *
```

A cada seis semanas, chega a hora de preparar um novo lançamento! O branch
`beta` do repositório do Rust é criado a partir do branch principal usado pelo
nightly. Agora, há dois lançamentos:

```text
nightly: * - - * - - *
                     |
beta:                *
```

A maioria das pessoas usuárias do Rust não usa lançamentos beta ativamente,
mas testa contra o beta em seus sistemas de CI para ajudar o Rust a descobrir
possíveis regressões. Enquanto isso, continua existindo um lançamento nightly
toda noite:

```text
nightly: * - - * - - * - - * - - *
                     |
beta:                *
```

Digamos que uma regressão seja encontrada. Ainda bem que tivemos algum tempo
para testar o beta antes que a regressão escapasse para um lançamento stable!
A correção é aplicada ao branch principal, para que o nightly fique corrigido,
e depois essa correção é portada de volta para o branch `beta`, produzindo um
novo lançamento beta:

```text
nightly: * - - * - - * - - * - - * - - *
                     |
beta:                * - - - - - - - - *
```

Seis semanas depois da criação do primeiro beta, chega a hora de um lançamento
stable! O branch `stable` é produzido a partir do branch `beta`:

```text
nightly: * - - * - - * - - * - - * - - * - * - *
                     |
beta:                * - - - - - - - - *
                                       |
stable:                                *
```

Viva! Rust 1.5 está pronto! Só que esquecemos uma coisa: como as seis semanas
já passaram, também precisamos de um novo beta da _próxima_ versão do Rust,
1.6. Então, depois que o branch `stable` se separa de `beta`, a próxima versão
de `beta` volta a se separar de `nightly`:

```text
nightly: * - - * - - * - - * - - * - - * - * - *
                     |                         |
beta:                * - - - - - - - - *       *
                                       |
stable:                                *
```

Isso é chamado de “modelo de trem” porque, a cada seis semanas, um lançamento
“sai da estação”, mas ainda precisa percorrer uma jornada pelo canal beta
antes de chegar como um lançamento stable.

O Rust lança uma nova versão a cada seis semanas, como um relógio. Se você
sabe a data de um lançamento do Rust, pode saber a data do próximo: é seis
semanas depois. Um aspecto positivo de ter lançamentos programados a cada seis
semanas é que o próximo trem chega logo. Se um recurso perder um lançamento
específico, não é preciso se preocupar: outro acontecerá em pouco tempo! Isso
ajuda a reduzir a pressão para tentar encaixar recursos possivelmente ainda
inacabados perto da data de lançamento.

Graças a esse processo, você sempre pode testar o próximo build do Rust e
verificar por conta própria que a atualização é fácil: se um lançamento beta
não funcionar como esperado, você pode reportar isso à equipe e fazer com que
o problema seja corrigido antes do próximo lançamento stable! Quebras em um
lançamento beta são relativamente raras, mas `rustc` ainda é um software, e
bugs existem.

### Tempo de manutenção

O projeto Rust dá suporte à versão estável mais recente. Quando uma nova
versão estável é lançada, a versão antiga chega ao fim de sua vida útil (EOL).
Isso significa que cada versão é suportada por seis semanas.

### Recursos instáveis

Há mais um detalhe nesse modelo de lançamento: recursos instáveis. Rust usa
uma técnica chamada _feature flags_ para determinar quais recursos estão
habilitados em um determinado lançamento. Se um novo recurso ainda estiver em
desenvolvimento ativo, ele entra no branch principal e, portanto, no nightly,
mas atrás de uma _feature flag_. Se você, como pessoa usuária, quiser
experimentar esse recurso em andamento, pode, mas terá de usar uma versão
nightly do Rust e anotar seu código-fonte com a flag apropriada para aderir ao
recurso.

Se você estiver usando uma versão beta ou stable do Rust, não poderá usar
nenhuma feature flag. Essa é a chave que nos permite obter uso prático de
recursos novos antes de declará-los estáveis para sempre. Quem quiser ficar na
vanguarda pode fazer isso, e quem quiser uma experiência sólida como rocha
pode permanecer no stable e saber que seu código não vai quebrar. Estabilidade
sem estagnação.

Este livro contém apenas informações sobre recursos estáveis, porque os
recursos em andamento ainda estão mudando, e certamente serão diferentes entre
o momento em que este livro foi escrito e o momento em que forem habilitados
em builds estáveis. Você pode encontrar online a documentação para recursos
disponíveis apenas no nightly.

### Rustup e o papel do Rust Nightly

O Rustup facilita a troca entre diferentes canais de lançamento do Rust, seja
globalmente, seja por projeto. Por padrão, você terá o Rust stable instalado.
Para instalar o nightly, por exemplo:

```console
$ rustup toolchain install nightly
```

Você também pode ver todos os _toolchains_ (lançamentos do Rust e componentes
associados) instalados com o `rustup`. Aqui está um exemplo no computador com
Windows de um dos autores:

```powershell
> rustup toolchain list
stable-x86_64-pc-windows-msvc (default)
beta-x86_64-pc-windows-msvc
nightly-x86_64-pc-windows-msvc
```

Como você pode ver, o toolchain stable é o padrão. A maioria das pessoas
usuárias do Rust usa stable na maior parte do tempo. Talvez você queira usar
stable quase sempre, mas usar nightly em um projeto específico por se importar
com um recurso de ponta. Para isso, você pode usar `rustup override` no
diretório do projeto e definir o toolchain nightly como aquele que o `rustup`
deve usar quando você estiver naquele diretório:

```console
$ cd ~/projects/needs-nightly
$ rustup override set nightly
```

Agora, sempre que você chamar `rustc` ou `cargo` dentro de
_~/projects/needs-nightly_, o `rustup` garantirá que você esteja usando Rust
nightly, em vez do seu Rust stable padrão. Isso é útil quando você tem muitos
projetos Rust!

### O processo de RFC e as equipes

Então, como você fica sabendo desses novos recursos? O modelo de desenvolvimento
do Rust segue um _processo de Request For Comments (RFC)_. Se você quiser uma
melhoria no Rust, pode escrever uma proposta, chamada RFC.

Qualquer pessoa pode escrever RFCs para melhorar o Rust, e as propostas são
revisadas e discutidas pela equipe do Rust, composta por muitos subgrupos
temáticos. Há uma lista completa das equipes [no site do
Rust](https://www.rust-lang.org/governance), incluindo equipes para cada área
do projeto: design da linguagem, implementação do compilador, infraestrutura,
documentação e muito mais. A equipe apropriada lê a proposta e os comentários,
escreve seus próprios comentários e, eventualmente, chega a um consenso para
aceitar ou rejeitar o recurso.

Se o recurso for aceito, uma issue é aberta no repositório do Rust, e alguém
pode implementá-lo. A pessoa que o implementa muito possivelmente não é a
mesma que propôs o recurso no início! Quando a implementação está pronta, ela
chega ao branch principal atrás de um feature gate, como discutimos na seção
[“Recursos instáveis”](#recursos-instáveis)<!-- ignore -->.

Depois de algum tempo, quando desenvolvedores Rust que usam versões nightly
já tiveram oportunidade de experimentar o novo recurso, integrantes da equipe
discutem o recurso, como ele se comportou no nightly e se ele deve ou não
entrar no Rust stable. Se a decisão for seguir em frente, o feature gate é
removido, e o recurso passa a ser considerado estável! Ele pega o trem rumo a
um novo lançamento stable do Rust.

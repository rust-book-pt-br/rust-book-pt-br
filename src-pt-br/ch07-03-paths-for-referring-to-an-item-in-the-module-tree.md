## Caminhos para referência a um item na árvore de módulos

To show Rust where to find an item in a module tree, we use a path in the same
way we use a path when navigating a filesystem. To call a function, we need to
know its path.

A path can take two forms:

- Um _caminho absoluto_ é o caminho completo começando em uma raiz crate; para código
  de um crate externo, o caminho absoluto começa com o nome crate e para
  código do crate atual, ele começa com o literal `crate`.
- Um _caminho relativo_ começa no módulo atual e usa ` self`, ` super`ou
  um identificador no módulo atual.

Both absolute and relative paths are followed by one or more identifiers
separated by double colons (`::`).

Voltando à Listagem 7-1, digamos que queremos chamar a função `add_to_waitlist`.
Isto é o mesmo que perguntar: Qual é o caminho da função ` add_to_waitlist`?
A Listagem 7-3 contém a Listagem 7-1 com alguns dos módulos e funções removidos.

Mostraremos duas maneiras de chamar a função `add_to_waitlist` a partir de uma nova função,
`eat_at_restaurant`, definido na raiz crate. Esses caminhos estão corretos, mas
ainda há outro problema que impedirá a compilação deste exemplo
como está. Explicaremos o porquê daqui a pouco.

A função `eat_at_restaurant` faz parte da API pública da nossa biblioteca crate, então
nós o marcamos com a palavra-chave `pub`. Na seção [“Expondo caminhos com o ` pub`
Palavra-chave”][pub]<!-- ignore -->, entraremos em mais detalhes sobre ` pub`.

<Listing number="7-3" file-name="src/lib.rs" caption="Chamando a função `add_to_waitlist` usando caminhos absolutos e relativos">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-03/src/lib.rs}}
```

</Listing>

A primeira vez que chamamos a função `add_to_waitlist` em `eat_at_restaurant`,
usamos um caminho absoluto. A função ` add_to_waitlist`é definida no mesmo
crate como ` eat_at_restaurant`, o que significa que podemos usar a palavra-chave ` crate`para
iniciar um caminho absoluto. Em seguida, incluímos cada um dos módulos sucessivos até que
siga para ` add_to_waitlist`. Você pode imaginar um sistema de arquivos com o mesmo
estrutura: especificaríamos o caminho ` /front_of_house/hosting/add_to_waitlist`para
execute o programa ` add_to_waitlist`; usando o nome ` crate`para iniciar a partir do
A raiz crate é como usar ` /`para iniciar a partir da raiz do sistema de arquivos em seu shell.

Na segunda vez que chamamos `add_to_waitlist` em `eat_at_restaurant`, usamos um
caminho relativo. O caminho começa com ` front_of_house`, o nome do módulo
definido no mesmo nível da árvore do módulo que ` eat_at_restaurant`. Aqui o
equivalente do sistema de arquivos estaria usando o caminho
` front_of_house/hosting/add_to_waitlist`. Começar com um nome de módulo significa
que o caminho é relativo.

Escolher usar um caminho relativo ou absoluto é uma decisão que você tomará
com base no seu projeto e depende se você tem maior probabilidade de mudar
código de definição de item separadamente ou em conjunto com o código que usa o
artigo. Por exemplo, se movemos o módulo `front_of_house` e o
Função `eat_at_restaurant` em um módulo chamado `customer_experience`, teríamos
precisa atualizar o caminho absoluto para ` add_to_waitlist`, mas o caminho relativo
ainda seria válido. No entanto, se movermos a função ` eat_at_restaurant`
separadamente em um módulo chamado ` dining`, o caminho absoluto para o
A chamada ` add_to_waitlist`permaneceria a mesma, mas o caminho relativo precisaria
ser atualizado. Nossa preferência em geral é especificar caminhos absolutos porque é
é mais provável que desejemos mover definições de código e chamadas de item independentemente de
um ao outro.

Vamos tentar compilar a Listagem 7.3 e descobrir por que ela ainda não foi compilada! O
os erros que obtemos são mostrados na Listagem 7-4.

<Listing number="7-4" caption="Erros do compilador ao compilar o código da Listagem 7-3">

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-03/output.txt}}
```

</Listing>

As mensagens de erro dizem que o módulo `hosting` é privado. Em outras palavras, nós
tenha os caminhos corretos para o módulo `hosting` e o `add_to_waitlist`
função, mas Rust não nos permite usá-los porque não tem acesso ao
seções privadas. Em Rust, todos os itens (funções, métodos, estruturas, enums,
módulos e constantes) são privados dos módulos pai por padrão. Se você quiser
para tornar um item como uma função ou estrutura privada, você o coloca em um módulo.

Os itens em um módulo pai não podem usar os itens privados dentro dos módulos filhos, mas
itens em módulos filhos podem usar os itens em seus módulos ancestrais. Isto é
porque os módulos filhos encapsulam e ocultam seus detalhes de implementação, mas o filho
os módulos podem ver o contexto em que estão definidos. Para continuar com o nosso
metáfora, pense nas regras de privacidade como sendo o back office de uma
restaurante: o que acontece lá é privado para os clientes do restaurante, mas
os gerentes de escritório podem ver e fazer tudo no restaurante que operam.

Rust optou por fazer com que o sistema do módulo funcionasse desta forma para que ocultar
detalhes de implementação é o padrão. Dessa forma, você sabe quais partes do
código interno você pode alterar sem quebrar o código externo. No entanto, Rust faz
oferece a opção de expor as partes internas do código dos módulos filhos aos externos
módulos ancestrais usando a palavra-chave `pub` para tornar um item público.

### Expondo caminhos com a palavra-chave `pub`

Voltemos ao erro na Listagem 7-4 que nos disse que o módulo `hosting` é
privado. Queremos que a função `eat_at_restaurant` no módulo pai tenha
acesso à função `add_to_waitlist` no módulo filho, então marcamos o
Módulo `hosting` com a palavra-chave `pub`, conforme mostrado na Listagem 7-5.

<Listing number="7-5" file-name="src/lib.rs" caption="Declarando o módulo `hosting` como `pub` para usá-lo em `eat_at_restaurant`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-05/src/lib.rs:here}}
```

</Listing>

Unfortunately, the code in Listing 7-5 still results in compiler errors, as
shown in Listing 7-6.

<Listing number="7-6" caption="Erros do compilador ao compilar o código da Listagem 7-5">

```console
{{#include ../listings/ch07-managing-growing-projects/listing-07-05/output.txt}}
```

</Listing>

O que aconteceu? Adicionar a palavra-chave `pub` na frente de `mod hosting` torna o
módulo público. Com esta mudança, se pudermos acessar `front_of_house`, podemos
acesse ` hosting`. Mas o _conteúdo_ do ` hosting`ainda é privado; fazendo o
O módulo public não torna seu conteúdo público. A palavra-chave ` pub`em um módulo
apenas permite que o código em seus módulos ancestrais se refira a ele, e não acesse seu código interno.
Como os módulos são contêineres, não há muito que possamos fazer apenas criando os
módulo público; precisamos ir mais longe e optar por fazer um ou mais dos
itens dentro do módulo public também.

Os erros na Listagem 7-6 dizem que a função `add_to_waitlist` é privada.
As regras de privacidade se aplicam a estruturas, enumerações, funções e métodos, bem como
módulos.

Vamos também tornar pública a função `add_to_waitlist` adicionando o `pub`
palavra-chave antes de sua definição, como na Listagem 7-7.

<Listing number="7-7" file-name="src/lib.rs" caption="Adicionar a palavra-chave `pub` a `mod hosting` e `fn add_to_waitlist` nos permite chamar a função de `eat_at_restaurant`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-07/src/lib.rs:here}}
```

</Listing>

Agora o código será compilado! Para ver por que adicionar a palavra-chave `pub` nos permite usar
esses caminhos em `eat_at_restaurant` com respeito às regras de privacidade, vamos
observe os caminhos absolutos e relativos.

No caminho absoluto, começamos com `crate`, a raiz do nosso módulo crate
árvore. O módulo ` front_of_house`é definido na raiz crate. Enquanto
` front_of_house `não é público, porque a função` eat_at_restaurant `é
definido no mesmo módulo que` front_of_house `(ou seja,` eat_at_restaurant `
e` front_of_house `são irmãos), podemos nos referir a` front_of_house `de
` eat_at_restaurant `. O próximo é o módulo` hosting `marcado com` pub `. Nós podemos
acessar o módulo pai do` hosting `, para que possamos acessar o` hosting `. Finalmente, o
A função` add_to_waitlist `está marcada com` pub`e podemos acessar seu pai
módulo, então esta chamada de função funciona!

No caminho relativo, a lógica é a mesma do caminho absoluto, exceto pelo
primeira etapa: em vez de começar na raiz crate, o caminho começa em
`front_of_house `. O módulo` front_of_house `é definido dentro do mesmo módulo
como` eat_at_restaurant `, então o caminho relativo começando no módulo no qual
` eat_at_restaurant `é definido como funciona. Então, porque` hosting `e
` add_to_waitlist `estão marcados com` pub`, o resto do caminho funciona e este
a chamada de função é válida!

Se você planeja compartilhar sua biblioteca crate para que outros projetos possam usar seu
código, sua API pública é o seu contrato com os usuários do seu crate que determina
como eles podem interagir com seu código. Existem muitas considerações em torno
gerenciar alterações em sua API pública para facilitar a dependência das pessoas
seu crate. Estas considerações estão além do escopo deste livro; se você estiver
interessado neste tópico, consulte [as Diretrizes da API Rust][api-guidelines].

> #### Melhores Práticas para Pacotes com Binário e Biblioteca
>
> Mencionamos que um pacote pode conter um binário _src/main.rs_ crate
> root, bem como uma biblioteca _src/lib.rs_ raiz crate, e ambos crates terão
> o nome do pacote por padrão. Normalmente, pacotes com esse padrão de
> contendo uma biblioteca e um binário crate terá código suficiente no
> binário crate para iniciar um executável que chama o código definido na biblioteca
> crate. Isso permite que outros projetos se beneficiem do máximo de funcionalidades que o
> pacote fornece porque o código da biblioteca crate pode ser compartilhado.
>
> A árvore do módulo deve ser definida em _src/lib.rs_. Então, quaisquer itens públicos podem
> ser usado no binário crate iniciando os caminhos com o nome do pacote.
> O binário crate torna-se usuário da biblioteca crate como um usuário completamente
> crate externo usaria a biblioteca crate: Só pode usar a API pública.
> Isso ajuda você a projetar uma boa API; você não é apenas o autor, mas também
> também cliente!
>
> No [Capítulo 12][ch12]<!-- ignore -->, demonstraremos esta organização
> pratique com um programa de linha de comando que conterá um crate binário
> e uma biblioteca crate.

### Iniciando caminhos relativos com `super`

Podemos construir caminhos relativos que começam no módulo pai, em vez de
o módulo atual ou a raiz crate, usando `super` no início do
caminho. É como iniciar um caminho de sistema de arquivos com a sintaxe `..`, o que significa
para ir para o diretório pai. Usar ` super`nos permite fazer referência a um item
que sabemos que está no módulo pai, o que pode tornar a reorganização do módulo
árvore mais fácil quando o módulo está intimamente relacionado ao pai, mas o pai
pode ser movido para outro lugar na árvore de módulos algum dia.

Considere o código da Listagem 7.8 que modela a situação em que um chef
corrige um pedido incorreto e o leva pessoalmente ao cliente. O
função `fix_incorrect_order` definida no módulo `back_of_house` chama o
função `deliver_order` definida no módulo pai especificando o caminho para
`deliver_order `, começando com` super`.

<Listing number="7-8" file-name="src/lib.rs" caption="Chamando uma função usando um caminho relativo que começa com `super`">

```rust,noplayground,test_harness
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-08/src/lib.rs}}
```

</Listing>

A função `fix_incorrect_order` está no módulo `back_of_house`, então podemos
use ` super`para ir para o módulo pai de ` back_of_house`, que neste caso
é ` crate`, a raiz. A partir daí, procuramos ` deliver_order`e o encontramos.
Sucesso! Achamos que o módulo ` back_of_house`e a função ` deliver_order`
provavelmente permanecerão no mesmo relacionamento um com o outro e se mudarão
juntos devemos decidir reorganizar a árvore de módulos do crate. Portanto, nós
usamos ` super`para que tenhamos menos lugares para atualizar o código no future se
este código é movido para um módulo diferente.

### Tornando estruturas e enumerações públicas

Também podemos usar `pub` para designar estruturas e enumerações como públicas, mas há uma
alguns detalhes extras sobre o uso de `pub` com estruturas e enumerações. Se usarmos `pub`
antes de uma definição de struct, tornamos a struct pública, mas os campos da struct
ainda será privado. Podemos tornar cada campo público ou não caso a caso
base. Na Listagem 7-9, definimos uma estrutura pública ` back_of_house::Breakfast`
com um campo ` toast`público, mas um campo ` seasonal_fruit`privado. Este modelo
é o caso de um restaurante onde o cliente pode escolher o tipo de pão que
acompanha a refeição, mas o chef decide quais frutas acompanham a refeição com base
sobre o que está na temporada e em estoque. A fruta disponível muda rapidamente, então
os clientes não podem escolher as frutas ou mesmo ver quais frutas receberão.

<Listing number="7-9" file-name="src/lib.rs" caption="Uma struct com alguns campos públicos e outros privados">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-09/src/lib.rs}}
```

</Listing>

Como o campo `toast` na estrutura `back_of_house::Breakfast` é público,
em `eat_at_restaurant` podemos escrever e ler no campo `toast` usando ponto
notação. Observe que não podemos usar o campo `seasonal_fruit` em
`eat_at_restaurant `, porque` seasonal_fruit `é privado. Tente descomentar o
linha modificando o valor do campo` seasonal_fruit`para ver qual erro você obtém!

Além disso, observe que como `back_of_house::Breakfast` possui um campo privado, o
struct precisa fornecer uma função pública associada que construa um
instância de `Breakfast` (nós o chamamos de `summer` aqui). Se `Breakfast` não
tiver tal função, não poderíamos criar uma instância de `Breakfast` em
`eat_at_restaurant `, porque não foi possível definir o valor do private
Campo` seasonal_fruit `em` eat_at_restaurant`.

Por outro lado, se tornarmos um enum público, todas as suas variantes serão públicas. Nós
só precisa do `pub` antes da palavra-chave `enum`, conforme mostrado na Listagem 7-10.

<Listing number="7-10" file-name="src/lib.rs" caption="Marcar uma enum como pública torna todas as suas variantes públicas">

```rust,noplayground
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-10/src/lib.rs}}
```

</Listing>

Como tornamos pública a enumeração `Appetizer`, podemos usar ` Soup`e ` Salad`
variantes em ` eat_at_restaurant`.

Enums não são muito úteis, a menos que suas variantes sejam públicas; seria irritante
ter que anotar todas as variantes de enum com `pub` em todos os casos, então o padrão
para variantes enum deve ser público. As estruturas são frequentemente úteis sem a sua
os campos são públicos, então os campos struct seguem a regra geral de tudo
sendo privado por padrão, a menos que seja anotado com `pub`.

Há mais uma situação envolvendo `pub` que não abordamos, e é
nosso último recurso do sistema de módulo: a palavra-chave `use`. Cobriremos o ` use`sozinho
primeiro, e depois mostraremos como combinar ` pub`e ` use`.

[pub]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html#exposing-paths-with-the-pub-keyword
[api-guidelines]: https://rust-lang.github.io/api-guidelines/
[ch12]: ch12-00-an-io-project.html

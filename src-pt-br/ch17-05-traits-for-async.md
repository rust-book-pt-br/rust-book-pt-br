<!-- Old headings. Do not remove or links may break. -->

<a id="digging-into-the-traits-for-async"></a>

## Uma análise mais detalhada das traits de async

Ao longo do capítulo, usamos as traits `Future`, `Stream` e `StreamExt`
de várias maneiras. Até aqui, porém, evitamos entrar muito nos detalhes de
como elas funcionam ou como se encaixam, o que é suficiente na maior parte do
tempo para o trabalho cotidiano com Rust. Às vezes, no entanto, você vai se
deparar com situações em que precisará entender um pouco melhor os detalhes
dessas traits, junto com o tipo `Pin` e a trait `Unpin`. Nesta seção, vamos
nos aprofundar apenas o bastante para ajudar nesses cenários, deixando o
mergulho _realmente_ profundo para outras documentações.

<!-- Old headings. Do not remove or links may break. -->

<a id="future"></a>

### A trait `Future`

Vamos começar olhando mais de perto como a trait `Future` funciona. Veja como
o Rust a define:

```rust
use std::pin::Pin;
use std::task::{Context, Poll};

pub trait Future {
    type Output;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}
```

Essa definição de trait inclui vários tipos novos e também uma sintaxe que
ainda não vimos, então vamos analisá-la parte por parte.

Primeiro, o tipo associado `Output` de `Future` diz em que valor o future
resulta. Isso é análogo ao tipo associado `Item` da trait `Iterator`.
Em segundo lugar, `Future` tem o método `poll`, que recebe uma referência
especial `Pin` para seu parâmetro `self`, além de uma referência mutável para
um `Context`, e retorna um `Poll<Self::Output>`. Falaremos mais sobre `Pin` e
`Context` daqui a pouco. Por enquanto, vamos focar no que o método retorna, o
tipo `Poll`:

```rust
pub enum Poll<T> {
    Ready(T),
    Pending,
}
```

Esse tipo `Poll` é semelhante a um `Option`. Ele tem uma variante com valor,
`Ready(T)`, e outra sem valor, `Pending`. Mas `Poll` significa algo bem
diferente de `Option`! A variante `Pending` indica que o future ainda tem
trabalho a fazer, então o chamador precisará verificá-lo novamente mais tarde.
A variante `Ready` indica que o `Future` concluiu seu trabalho e que o valor
`T` está disponível.

> Observação: raramente é necessário chamar `poll` diretamente, mas, se você
> precisar, lembre-se de que, com a maioria dos futures, o chamador não deve
> chamar `poll` novamente depois que o future tiver retornado `Ready`. Muitos
> futures entram em `panic!` se forem consultados outra vez depois de ficarem
> prontos. Futures que podem ser consultados novamente com segurança dizem isso
> explicitamente em sua documentação. Isso é semelhante ao comportamento de
> `Iterator::next`.

Quando você vê um código que usa `await`, o Rust o compila internamente para
código que chama `poll`. Se você voltar à Listagem 17-4, em que imprimimos o
título da página de uma única URL quando ela é resolvida, o Rust o compila em
algo mais ou menos assim, embora não exatamente:

```rust,ignore
match page_title(url).poll() {
    Ready(page_title) => match page_title {
        Some(title) => println!("The title for {url} was {title}"),
        None => println!("{url} had no title"),
    }
    Pending => {
        // But what goes here?
    }
}
```

O que devemos fazer quando o future ainda está em `Pending`? Precisamos de
alguma forma de tentar de novo, e de novo, e de novo, até que ele finalmente
esteja pronto. Em outras palavras, precisamos de um loop:

```rust,ignore
let mut page_title_fut = page_title(url);
loop {
    match page_title_fut.poll() {
        Ready(value) => match page_title {
            Some(title) => println!("The title for {url} was {title}"),
            None => println!("{url} had no title"),
        }
        Pending => {
            // continue
        }
    }
}
```

Se o Rust o compilasse exatamente para esse código, porém, cada `await` seria
bloqueante, justamente o oposto do que queremos! Em vez disso, o Rust garante
que o loop possa transferir o controle para algo que consiga pausar o trabalho
nesse future, executar outros futures e depois voltar para verificar este mais
tarde. Como vimos, esse algo é um runtime assíncrono, e esse trabalho de
agendamento e coordenação é uma de suas funções principais.

Na seção [“Enviando dados entre duas tarefas usando passagem de
mensagens”][message-passing]<!-- ignore -->, descrevemos a espera em
`rx.recv`. A chamada a `recv` retorna um future, e aguardar esse future faz com
que ele seja consultado. Observamos que um runtime pausa o future até que ele
fique pronto com `Some(message)` ou com `None`, quando o canal é fechado. Com
essa compreensão mais profunda da trait `Future`, e especificamente de
`Future::poll`, podemos ver como isso funciona. O runtime sabe que o future
não está pronto quando ele retorna `Poll::Pending`. Por outro lado, o runtime
sabe que o future _está_ pronto e o avança quando `poll` retorna
`Poll::Ready(Some(message))` ou `Poll::Ready(None)`.

Os detalhes exatos de como um runtime faz isso estão fora do escopo deste
livro, mas o importante é entender a mecânica básica dos futures: um runtime
faz _poll_ em cada future sob sua responsabilidade e o coloca de volta em
espera quando ele ainda não está pronto.

<!-- Old headings. Do not remove or links may break. -->

<a id="pinning-and-the-pin-and-unpin-traits"></a>
<a id="the-pin-and-unpin-traits"></a>

### O tipo `Pin` e a trait `Unpin`

Voltando à Listagem 17-13, usamos a macro `trpl::join!` para aguardar três
futures. No entanto, é comum ter uma coleção, como um vetor, contendo algum
número de futures que só será conhecido em tempo de execução. Vamos alterar a
Listagem 17-13 para o código da Listagem 17-23, que coloca os três futures em
um vetor e chama a função `trpl::join_all`, que ainda não compilará.

<Listing number="17-23" caption="Aguardando futures em uma coleção"  file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch17-async-await/listing-17-23/src/main.rs:here}}
```

</Listing>

Colocamos cada future dentro de um `Box` para transformá-los em _objetos trait_,
assim como fizemos na seção “Retornando erros de `run`” no Capítulo 12.
(Abordaremos objetos trait em detalhes no Capítulo 18.) Usar objetos trait nos
permite tratar cada um dos futures anônimos produzidos por esses tipos como o
mesmo tipo, porque todos implementam a trait `Future`.

Isso pode ser surpreendente. Afinal, nenhum dos blocos async retorna nada, então
cada um produz um `Future<Output = ()>`. Lembre-se, porém, de que `Future` é
uma trait, e o compilador cria uma enumeração exclusiva para cada bloco async,
mesmo quando eles têm tipos de saída idênticos. Assim como você não pode
colocar duas structs manuscritas diferentes em um `Vec`, você também não pode
misturar enums geradas pelo compilador.

Em seguida, passamos a coleção de futures para a função `trpl::join_all` e
aguardamos o resultado. No entanto, isso não compila; aqui está a parte
relevante das mensagens de erro.

<!-- manual-regeneration
listagens de cd/ch17-async-await/listing-17-23
Construção cargo
copie *apenas* o bloco `error` final dos erros
-->

```text
error[E0277]: `dyn Future<Output = ()>` cannot be unpinned
  --> src/main.rs:48:33
   |
48 |         trpl::join_all(futures).await;
   |                                 ^^^^^ the trait `Unpin` is not implemented for `dyn Future<Output = ()>`
   |
   = note: consider using the `pin!` macro
           consider using `Box::pin` if you need to access the pinned value outside of the current scope
   = note: required for `Box<dyn Future<Output = ()>>` to implement `Future`
note: required by a bound in `futures_util::future::join_all::JoinAll`
  --> file:///home/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/futures-util-0.3.30/src/future/join_all.rs:29:8
   |
27 | pub struct JoinAll<F>
   |            ------- required by a bound in this struct
28 | where
29 |     F: Future,
   |        ^^^^^^ required by this bound in `JoinAll`
```

A observação nessa mensagem de erro nos diz que devemos usar a macro `pin!`
para _fixar_ os valores, isto é, colocá-los dentro do tipo `Pin`, que garante
que eles não serão movidos na memória. A mensagem de erro diz que isso é
necessário porque `dyn Future<Output = ()>` precisa implementar a trait
`Unpin`, e atualmente não implementa.

A função `trpl::join_all` retorna uma struct chamada `JoinAll`. Essa struct é
genérica sobre um tipo `F`, que é restringido a implementar a trait `Future`.
Aguardar diretamente um future com `await` o fixa implicitamente. É por isso
que não precisamos usar `pin!` em todo lugar em que queremos aguardar futures.

No entanto, aqui não estamos aguardando diretamente um future. Em vez disso,
construímos um novo future, `JoinAll`, ao passar uma coleção de futures para a
função `join_all`. A assinatura de `join_all` exige que os tipos dos itens da
coleção implementem a trait `Future`, e `Box<T>` só implementa `Future` se o
`T` encapsulado for um future que implemente a trait `Unpin`.

Isso é bastante coisa para absorver! Para realmente entender, vamos nos
aprofundar um pouco mais em como a trait `Future` funciona na prática,
especialmente em relação ao pinning. Observe novamente sua definição:

```rust
use std::pin::Pin;
use std::task::{Context, Poll};

pub trait Future {
    type Output;

    // Required method
    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}
```

O parâmetro `cx` e seu tipo `Context` são a chave para como um runtime
realmente sabe quando verificar um dado future enquanto continua sendo
preguiçoso. Novamente, os detalhes de como isso funciona estão fora do escopo
deste capítulo, e normalmente você só precisa pensar nisso ao escrever uma
implementação personalizada de `Future`. Em vez disso, vamos nos concentrar no
tipo de `self`, porque esta é a primeira vez que vemos um método em que `self`
tem uma anotação de tipo. Uma anotação de tipo para `self` funciona como as
anotações de tipo para outros parâmetros de função, mas com duas diferenças
principais:

- Informa ao Rust qual tipo `self` deve ser para que o método seja chamado.
- Não pode ser qualquer tipo. Está restrito ao tipo em que o método está
  implementado, uma referência ou smart pointer para esse tipo, ou um `Pin` envolvendo um
  referência a esse tipo.

Veremos mais sobre essa sintaxe no [Capítulo 18][ch-18]<!-- ignore -->. Por
enquanto, basta saber que, se quisermos fazer `poll` em um future para verificar
se ele está em `Pending` ou em `Ready(Output)`, precisamos de uma referência
mutável ao tipo encapsulada em `Pin`.

`Pin` é um invólucro para tipos parecidos com ponteiros, como `&`, `&mut`,
`Box` e `Rc`. (Tecnicamente, `Pin` funciona com tipos que implementam as traits
`Deref` ou `DerefMut`, mas isso equivale, na prática, a trabalhar apenas com
referências e smart pointers.) `Pin` não é um ponteiro em si e não tem
comportamento próprio, como `Rc` e `Arc` têm com contagem de referências; ele é
puramente uma ferramenta que o compilador pode usar para impor restrições ao
uso de ponteiros.

Lembrar que `await` é implementado em termos de chamadas a `poll` começa a
explicar a mensagem de erro que vimos antes, mas ela falava em `Unpin`, não em
`Pin`. Então, como exatamente `Pin` se relaciona com `Unpin`, e por que
`Future` precisa que `self` esteja em um tipo `Pin` para chamar `poll`?

Lembre-se de que, como vimos anteriormente neste capítulo, uma série de pontos
de espera (`await`) em um future é compilada em uma máquina de estados, e o
compilador garante que essa máquina de estados siga todas as regras normais de
segurança do Rust, incluindo borrowing e ownership. Para fazer isso funcionar,
o Rust analisa quais dados são necessários entre um ponto `await` e o próximo,
ou entre um ponto `await` e o fim do bloco async. Em seguida, ele cria uma
variante correspondente na máquina de estados compilada. Cada variante recebe o
acesso necessário aos dados que serão usados naquela seção do código-fonte,
seja tomando ownership desses dados ou obtendo uma
referência mutável ou imutável a ele.

Até aqui, tudo bem: se houver algo errado com ownership ou com referências em
um determinado bloco async, o borrow checker nos avisará. Quando queremos mover
o future correspondente a esse bloco, como ao colocá-lo em um `Vec` para
passá-lo a `join_all`, as coisas ficam mais complicadas.

Quando movemos um future, seja inserindo-o em uma estrutura de dados para usá-lo
com `join_all` ou retornando-o de uma função, isso na verdade significa mover a
máquina de estados que o Rust cria para nós. E, ao contrário da maioria dos
outros tipos em Rust, os futures criados pelo Rust para blocos async podem
acabar contendo referências a si mesmos nos campos de alguma variante, como
mostra a ilustração simplificada da Figura 17-4.

<figure>

<img alt="Uma tabela de coluna única e três linhas representando um future, `fut1`, que tem os valores de dados 0 e 1 nas duas primeiras linhas e uma seta apontando da terceira linha de volta para a segunda, representando uma referência interna dentro do future." src="img/trpl17-04.svg" class="center" />

<figcaption>Figura 17-4: Um tipo de dado autorreferencial</figcaption>

</figure>

Por padrão, qualquer objeto que tenha uma referência a si mesmo não é seguro
para ser movido, porque referências sempre apontam para o endereço de memória
real daquilo a que se referem, como mostra a Figura 17-5. Se você mover a
própria estrutura de dados, essas referências internas continuarão apontando
para o lugar antigo. Só que essa posição de memória agora é inválida. Por um
lado, seu valor não será atualizado quando você modificar a estrutura de dados.
Mais importante ainda, o computador agora está livre para reutilizar essa
memória para outros fins. Você pode acabar lendo depois dados completamente sem
relação.

<figure>

<img alt="Duas tabelas, representando dois futures, `fut1` e `fut2`, cada um com uma coluna e três linhas, mostrando o resultado de mover um future para fora de `fut1` e para dentro de `fut2`. A primeira, `fut1`, está acinzentada, com um ponto de interrogação em cada posição, representando memória desconhecida. A segunda, `fut2`, tem 0 e 1 na primeira e na segunda linhas, e uma seta apontando de sua terceira linha de volta para a segunda linha de `fut1`, representando um ponteiro que referencia a antiga posição em memória do future antes de ele ter sido movido." src="img/trpl17-05.svg" class="center" />

<figcaption>Figura 17-5: O resultado inseguro de mover um tipo de dado autorreferencial</figcaption>

</figure>

Teoricamente, o compilador Rust poderia tentar atualizar cada referência a um
objeto sempre que ele fosse movido, mas isso poderia adicionar muita sobrecarga
de desempenho, especialmente se toda uma rede de referências precisasse ser
atualizada. Se, em vez disso, pudermos garantir que a estrutura de dados em
questão _não se move na memória_, não precisaremos atualizar referência alguma.
É exatamente para isso que serve o borrow checker do Rust: em código seguro, ele
impede que você mova qualquer item que tenha uma referência ativa para ele.

`Pin` se baseia nisso para nos dar exatamente a garantia de que precisamos.
Quando _fixamos_ um valor envolvendo um ponteiro para esse valor em `Pin`, ele
não pode mais ser movido. Assim, se você tiver `Pin<Box<SomeType>>`, na
verdade estará fixando o valor `SomeType`, e _não_ o ponteiro `Box`. A
Figura 17-6 ilustra esse processo.

<figure>

<img alt="Três caixas dispostas lado a lado. A primeira está rotulada “Pin”, a segunda “b1” e a terceira “pinned”. Dentro de “pinned” há uma tabela rotulada “fut”, com uma única coluna; ela representa um future com células para cada parte da estrutura de dados. Sua primeira célula tem o valor “0”, a segunda tem uma seta saindo dela e apontando para a quarta e última célula, que contém o valor “1”, e a terceira célula tem linhas tracejadas e reticências para indicar que pode haver outras partes da estrutura de dados. No conjunto, a tabela “fut” representa um future autorreferencial. Uma seta sai da caixa rotulada “Pin”, passa pela caixa “b1” e termina dentro da caixa “pinned”, na tabela “fut”." src="img/trpl17-06.svg" class="center" />

<figcaption>Figura 17-6: Fixando um `Box` que aponta para um tipo de future autorreferencial</figcaption>

</figure>

Na verdade, o ponteiro `Box` ainda pode se mover livremente. Lembre-se: o que
nos importa é garantir que os dados referenciados permaneçam no lugar. Se um
ponteiro se move, _mas os dados para os quais ele aponta_ continuam no mesmo
lugar, como na Figura 17-7, não há problema potencial. Como exercício
independente, consulte a documentação desses tipos, bem como a do módulo
`std::pin`, e tente descobrir como fazer isso com um `Pin` envolvendo um
`Box`. O ponto principal é que o tipo autorreferencial em si não pode se mover,
porque continua fixado.

<figure>

<img alt="Quatro caixas dispostas em três colunas aproximadas, idênticas ao diagrama anterior com uma mudança na segunda coluna. Agora há duas caixas na segunda coluna, rotuladas “b1” e “b2”; “b1” está acinzentada, e a seta que sai de “Pin” passa por “b2” em vez de “b1”, indicando que o ponteiro foi movido de “b1” para “b2”, mas os dados em “pinned” não se moveram." src="img/trpl17-07.svg" class="center" />

<figcaption>Figura 17-7: Movendo um `Box` que aponta para um tipo de future autorreferencial</figcaption>

</figure>

No entanto, a maioria dos tipos é perfeitamente segura para ser movida, mesmo
quando está por trás de um ponteiro `Pin`. Só precisamos pensar em fixação
quando os itens têm referências internas. Valores primitivos, como números e
booleanos, são seguros porque obviamente não têm referências internas. O mesmo
vale para a maior parte dos tipos com que você normalmente trabalha em Rust.
Você pode mover um `Vec`, por exemplo, sem se preocupar. Dado o que vimos até
agora, se você tivesse um `Pin<Vec<String>>`, precisaria fazer tudo por meio
das APIs seguras, mas restritivas, fornecidas por `Pin`, embora `Vec<String>`
seja sempre seguro de mover se não houver outras referências a ele. Precisamos
de uma forma de dizer ao compilador que mover itens em casos como esse não é um
problema, e é aí que entra `Unpin`.

`Unpin` é uma marker trait, semelhante às traits `Send` e `Sync` que vimos no
Capítulo 16 e, portanto, não tem funcionalidade própria. Marker traits existem
apenas para informar ao compilador que é seguro usar o tipo que implementa uma
determinada trait em um contexto específico. `Unpin` informa ao compilador que
um determinado tipo _não_ precisa manter garantias especiais sobre se o valor
em questão pode ser movido com segurança.

<!--
O `<code>` embutido no próximo bloco é para permitir o `<em>` embutido dentro dele,
  combinando o que o NoStarch faz em termos de estilo e enfatizando o texto aqui
  que é algo distinto de um tipo normal.
-->

Assim como acontece com `Send` e `Sync`, o compilador implementa `Unpin`
automaticamente para todos os tipos para os quais consegue provar que isso é
seguro. Um caso especial, novamente semelhante a `Send` e `Sync`, é quando
`Unpin` _não_ é implementada para um tipo. A notação para isso é
<code>impl !Unpin for <em>SomeType</em></code>, em que
<code><em>SomeType</em></code> é o nome de um tipo que _precisa_ manter essas
garantias para ser seguro sempre que um ponteiro para ele for usado dentro de
um `Pin`.

Em outras palavras, há duas coisas a ter em mente sobre a relação entre `Pin` e
`Unpin`. Primeiro, `Unpin` é o caso “normal”, e `!Unpin` é o caso especial.
Segundo, o fato de um tipo implementar `Unpin` ou `!Unpin` _só_ importa quando
você está usando um ponteiro fixado para esse tipo, como
<code>Pin<&mut <em>SomeType</em>></code>.

Para tornar isso mais concreto, pense em uma `String`: ela tem um comprimento e
os caracteres Unicode que a compõem. Podemos envolver uma `String` em `Pin`,
como mostra a Figura 17-8. No entanto, `String` implementa `Unpin`
automaticamente, assim como a maioria dos outros tipos em Rust.

<figure>

<img alt="Uma caixa rotulada “Pin” à esquerda com uma seta apontando para uma caixa rotulada “String” à direita. A caixa “String” contém o dado 5usize, representando o comprimento da string, e as letras “h”, “e”, “l”, “l” e “o”, representando os caracteres da string “hello” armazenada nessa instância de `String`. Um retângulo pontilhado envolve a caixa “String” e seu rótulo, mas não a caixa “Pin”." src="img/trpl17-08.svg" class="center" />

<figcaption>Figura 17-8: Fixando um `String`; a linha pontilhada indica que `String` implementa a trait `Unpin` e, portanto, não fica permanentemente fixado no lugar</figcaption>

</figure>

Como resultado, podemos fazer coisas que seriam ilegais se `String`
implementasse `!Unpin`, como substituir uma string por outra exatamente no
mesmo local de memória, como na Figura 17-9. Isso não viola o contrato de
`Pin`, porque `String` não tem referências internas que tornem sua movimentação
insegura. É justamente por isso que ela implementa `Unpin`, e não `!Unpin`.

<figure>

<img alt="Os mesmos dados da string “hello” do exemplo anterior, agora rotulados “s1” e acinzentados. A caixa “Pin” do exemplo anterior agora aponta para uma instância diferente de `String`, rotulada “s2”, que é válida, tem comprimento 7usize e contém os caracteres da string “goodbye”. `s2` é cercada por um retângulo pontilhado porque ela também implementa a trait `Unpin`." src="img/trpl17-09.svg" class="center" />

<figcaption>Figura 17-9: Substituindo o `String` por um `String` totalmente diferente na memória</figcaption>

</figure>

Agora sabemos o suficiente para entender os erros relatados para aquela chamada
a `join_all` na Listagem 17-23. Originalmente, tentamos mover os futures
produzidos por blocos async para dentro de um `Vec<Box<dyn Future<Output = ()>>>`,
mas, como vimos, esses futures podem ter referências internas, então não
implementam `Unpin` automaticamente. Depois de fixá-los, podemos passar o tipo
`Pin` resultante para o `Vec`, confiantes de que os dados subjacentes dos
futures _não_ serão movidos. A Listagem 17-24 mostra como corrigir o código
chamando a macro `pin!` no ponto em que cada um dos três futures é definido e
ajustando o tipo do objeto trait.

<Listing number="17-24" caption="Fixando os futures para permitir movê-los para dentro do vetor">

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-24/src/main.rs:here}}
```

</Listing>

Esse exemplo agora compila e executa, e poderíamos adicionar ou remover futures
do vetor em tempo de execução e então aguardar todos eles.

`Pin` e `Unpin` são importantes principalmente na construção de bibliotecas de
nível mais baixo, ou quando você está construindo um runtime em si, em vez de
apenas escrever código Rust do dia a dia. Ainda assim, quando você vir essas
traits em mensagens de erro, agora terá uma ideia melhor de como corrigir seu
código.

> Nota: Esta combinação de `Pin` e `Unpin` torna possível
> implementar toda uma classe de tipos complexos em Rust que de outra forma seriam
> desafiadores porque são autorreferenciais. Tipos que exigem `Pin` aparecem
> mais comumente em async Rust hoje, mas, de vez em quando, você também pode
> vê-los em outros contextos.
>
> As especificidades de como `Pin` e `Unpin` funcionam, bem como as regras que
> eles precisam manter, são abordadas extensivamente na documentação da API de
> `std::pin`, então, se você tiver interesse em aprender mais, esse é um ótimo
> lugar para começar.
>
> Se você quiser entender como as coisas funcionam nos bastidores com ainda mais detalhes,
> veja os capítulos [2][under-the-hood]<!-- ignore --> e
> [4][pinning]<!-- ignore --> de
> [_Programação Assíncrona em Rust_][async-book].

### A trait `Stream`

Agora que você tem uma compreensão mais profunda das traits `Future`, `Pin` e
`Unpin`, podemos voltar nossa atenção para a trait `Stream`. Como você aprendeu
anteriormente neste capítulo, streams são semelhantes a iterators assíncronos.
Ao contrário de `Iterator` e `Future`, porém, `Stream` ainda não tem uma
definição na biblioteca padrão no momento em que este texto foi escrito. Ainda
assim, _há_ uma definição muito comum vinda do crate `futures`, usada em todo o
ecossistema.

Vamos revisar as definições das traits `Iterator` e `Future` antes de ver como
uma trait `Stream` pode reuni-las. De `Iterator`, temos a ideia de uma
sequência: seu método `next` fornece um `Option<Self::Item>`. De `Future`,
temos a ideia de prontidão ao longo do tempo: seu método `poll` fornece um
`Poll<Self::Output>`. Para representar uma sequência de itens que ficam prontos
ao longo do tempo, definimos uma trait `Stream` que combina essas duas ideias:

```rust
use std::pin::Pin;
use std::task::{Context, Poll};

trait Stream {
    type Item;

    fn poll_next(
        self: Pin<&mut Self>,
        cx: &mut Context<'_>
    ) -> Poll<Option<Self::Item>>;
}
```

A trait `Stream` define um tipo associado chamado `Item` para o tipo de itens
produzidos pelo stream. Isso é semelhante a `Iterator`, em que pode haver de
zero a muitos itens, e diferente de `Future`, em que sempre há um único
`Output`, mesmo que ele seja o tipo unitário `()`.

`Stream` também define um método para obter esses itens. Nós o chamamos de
`poll_next`, para deixar claro que ele faz _poll_ da mesma forma que
`Future::poll` e produz uma sequência de itens do mesmo modo que
`Iterator::next`. Seu tipo de retorno combina `Poll` com `Option`. O tipo
externo é `Poll`, porque ele precisa ser verificado quanto à prontidão, assim
como acontece com um future. O tipo interno é `Option`, porque precisa
sinalizar se ainda existem mais mensagens, assim como acontece com um iterator.

Algo muito semelhante a essa definição provavelmente acabará fazendo parte da
biblioteca padrão do Rust. Enquanto isso, ela faz parte do conjunto de
ferramentas da maioria dos runtimes, então você pode contar com isso, e tudo o
que abordaremos a seguir deve se aplicar de modo geral.

Nos exemplos que vimos na seção [“Streams: Futures in Sequence”][streams]<!--
ignore -->, porém, não usamos `poll_next` _nem_ `Stream`; em vez disso,
usamos `next` e `StreamExt`. _Poderíamos_ trabalhar diretamente com a API
`poll_next`, escrevendo manualmente nossas próprias máquinas de estados para
`Stream`, é claro, assim como _poderíamos_ trabalhar com futures diretamente
por meio do método `poll`. Usar `await` é muito mais agradável, no entanto, e a
trait `StreamExt` fornece o método `next` para que possamos fazer exatamente
isso:

```rust
{{#rustdoc_include ../listings/ch17-async-await/no-listing-stream-ext/src/lib.rs:here}}
```

> Nota: A definição real que usamos anteriormente neste capítulo parece um pouco
> diferente disso, pois ela dá suporte a versões do Rust que ainda não
> suportavam o uso de funções async em traits. Como resultado, ela fica assim:
>
> ```rust,ignore
> fn next(&mut self) -> Next<'_, Self> where Self: Unpin;
> ```
>
> Esse tipo `Next` é uma `struct` que implementa `Future` e nos permite nomear
> o lifetime da referência a `self` com `Next<'_, Self>`, para que `await`
> possa funcionar com esse método.

A trait `StreamExt` também é o lugar em que vivem todos os métodos interessantes
disponíveis para uso com streams. `StreamExt` é implementada automaticamente
para cada tipo que implementa `Stream`, mas essas traits são definidas
separadamente para permitir que a comunidade evolua APIs de conveniência sem
afetar a trait fundamental.

Na versão de `StreamExt` usada no crate `trpl`, a trait não apenas define o
método `next`, como também fornece uma implementação padrão de `next` que lida
corretamente com os detalhes da chamada a `Stream::poll_next`. Isso significa
que, mesmo quando você precisa escrever seu próprio tipo de dado de streaming,
você _só_ precisa implementar `Stream`; depois disso, qualquer pessoa que usar
esse tipo poderá usar `StreamExt` e seus métodos automaticamente.

Isso é tudo o que abordaremos sobre os detalhes de mais baixo nível dessas
traits. Para finalizar, vamos considerar como futures, incluindo streams,
tarefas e threads se encaixam em conjunto.

[message-passing]: ch17-02-concurrency-with-async.md#sending-data-between-two-tasks-using-message-passing
[ch-18]: ch18-00-oop.html
[async-book]: https://rust-lang.github.io/async-book/
[under-the-hood]: https://rust-lang.github.io/async-book/02_execution/01_chapter.html
[pinning]: https://rust-lang.github.io/async-book/04_pinning/01_chapter.html
[first-async]: ch17-01-futures-and-syntax.html#our-first-async-program
[any-number-futures]: ch17-03-more-futures.html#working-with-any-number-of-futures
[streams]: ch17-04-streams.html

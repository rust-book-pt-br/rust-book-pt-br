## `RefCell<T>` e o Padrão de Mutabilidade Interior

_Mutabilidade interior_ (_interior mutability_) é um padrão de projeto em Rust
que permite modificar dados mesmo quando há referências imutáveis para esses
dados; normalmente, essa ação é proibida pelas regras de borrowing. Para
modificar dados, o padrão usa código `unsafe` dentro de uma estrutura de dados
para flexibilizar as regras usuais de Rust que governam mutação e borrowing.
Código unsafe indica ao compilador que estamos verificando as regras
manualmente, em vez de depender do compilador para verificá-las por nós;
discutiremos código unsafe com mais detalhes no Capítulo 20.

Só podemos usar tipos que usam o padrão de mutabilidade interior quando
conseguimos garantir que as regras de borrowing serão seguidas em tempo de
execução, mesmo que o compilador não consiga garantir isso. O código `unsafe`
envolvido é então envolvido por uma API segura, e o tipo externo continua sendo
imutável.

Vamos explorar esse conceito olhando para o tipo `RefCell<T>`, que segue o
padrão de mutabilidade interior.

<!-- Old headings. Do not remove or links may break. -->

<a id="enforcing-borrowing-rules-at-runtime-with-refcellt"></a>

### Aplicando Regras de Borrowing em Tempo de Execução

Diferente de `Rc<T>`, o tipo `RefCell<T>` representa ownership único sobre os
dados que armazena. Então, o que torna `RefCell<T>` diferente de um tipo como
`Box<T>`? Lembre-se das regras de borrowing que você aprendeu no Capítulo 4:

- Em qualquer momento, você pode ter _ou_ uma referência mutável _ou_ qualquer
  quantidade de referências imutáveis (mas não ambas).
- Referências devem sempre ser válidas.

Com referências e `Box<T>`, as invariantes das regras de borrowing são
aplicadas em tempo de compilação. Com `RefCell<T>`, essas invariantes são
aplicadas _em tempo de execução_. Com referências, se você quebrar essas regras,
receberá um erro do compilador. Com `RefCell<T>`, se você quebrar essas regras,
seu programa entrará em pânico e será encerrado.

As vantagens de verificar as regras de borrowing em tempo de compilação são que
os erros são capturados mais cedo no processo de desenvolvimento e não há
impacto no desempenho em tempo de execução, porque toda a análise é concluída
previamente. Por esses motivos, verificar as regras de borrowing em tempo de
compilação é a melhor escolha na maioria dos casos, e por isso esse é o padrão
de Rust.

A vantagem de verificar as regras de borrowing em tempo de execução, por outro
lado, é que certos cenários seguros em memória passam a ser permitidos, embora
fossem rejeitados pelas verificações em tempo de compilação. Análise estática,
como a do compilador Rust, é inerentemente conservadora. Algumas propriedades
do código são impossíveis de detectar analisando o código: o exemplo mais
famoso é o Problema da Parada, que está fora do escopo deste livro, mas é um
tópico interessante para pesquisar.

Como algumas análises são impossíveis, se o compilador Rust não puder ter
certeza de que o código está de acordo com as regras de ownership, ele pode
rejeitar um programa correto; nesse sentido, ele é conservador. Se Rust
aceitasse um programa incorreto, as pessoas não poderiam confiar nas garantias
que Rust oferece. No entanto, se Rust rejeita um programa correto, a pessoa
programadora terá um inconveniente, mas nada catastrófico poderá acontecer. O
tipo `RefCell<T>` é útil quando você tem certeza de que seu código segue as
regras de borrowing, mas o compilador é incapaz de entender e garantir isso.

De forma semelhante a `Rc<T>`, `RefCell<T>` deve ser usado apenas em cenários
de thread única e produzirá um erro em tempo de compilação se você tentar usá-lo
em um contexto multithread. Falaremos sobre como obter a funcionalidade de
`RefCell<T>` em um programa multithread no Capítulo 16.

Aqui está uma recapitulação dos motivos para escolher `Box<T>`, `Rc<T>` ou
`RefCell<T>`:

- `Rc<T>` permite múltiplos donos dos mesmos dados; `Box<T>` e `RefCell<T>` têm
  donos únicos.
- `Box<T>` permite empréstimos imutáveis ou mutáveis verificados em tempo de
  compilação; `Rc<T>` permite apenas empréstimos imutáveis verificados em tempo
  de compilação; `RefCell<T>` permite empréstimos imutáveis ou mutáveis
  verificados em tempo de execução.
- Como `RefCell<T>` permite empréstimos mutáveis verificados em tempo de
  execução, você pode modificar o valor dentro de `RefCell<T>` mesmo quando o
  próprio `RefCell<T>` é imutável.

Modificar o valor dentro de um valor imutável é o padrão de mutabilidade
interior. Vamos olhar para uma situação em que a mutabilidade interior é útil e
examinar como ela é possível.

<!-- Old headings. Do not remove or links may break. -->

<a id="interior-mutability-a-mutable-borrow-to-an-immutable-value"></a>

### Usando Mutabilidade Interior

Uma consequência das regras de borrowing é que, quando você tem um valor
imutável, não pode pegá-lo emprestado mutavelmente. Por exemplo, este código
não compila:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch15-smart-pointers/no-listing-01-cant-borrow-immutable-as-mutable/src/main.rs}}
```

Se você tentasse compilar esse código, receberia o seguinte erro:

```console
{{#include ../listings/ch15-smart-pointers/no-listing-01-cant-borrow-immutable-as-mutable/output.txt}}
```

No entanto, há situações em que seria útil que um valor modificasse a si mesmo
em seus métodos, mas parecesse imutável para outros códigos. O código fora dos
métodos do valor não conseguiria modificá-lo. Usar `RefCell<T>` é uma forma de
obter a capacidade de ter mutabilidade interior, mas `RefCell<T>` não contorna
completamente as regras de borrowing: o borrow checker no compilador permite
essa mutabilidade interior, e as regras de borrowing são verificadas em tempo
de execução. Se você violar as regras, receberá um `panic!` em vez de um erro
do compilador.

Vamos trabalhar com um exemplo prático em que podemos usar `RefCell<T>` para
modificar um valor imutável e ver por que isso é útil.

<!-- Old headings. Do not remove or links may break. -->

<a id="a-use-case-for-interior-mutability-mock-objects"></a>

#### Testando com Objetos Mock

Às vezes, durante testes, uma pessoa programadora usa um tipo no lugar de outro
para observar determinado comportamento e verificar que ele foi implementado
corretamente. Esse tipo substituto é chamado de _test double_. Pense nele no
sentido de um dublê no cinema, em que uma pessoa substitui um ator para fazer
uma cena especialmente complicada. Test doubles substituem outros tipos quando
executamos testes. _Objetos mock_ (_mock objects_) são tipos específicos de test
doubles que registram o que acontece durante um teste para que você possa
verificar que as ações corretas ocorreram.

Rust não tem objetos no mesmo sentido em que outras linguagens têm objetos, e
Rust não tem funcionalidade de objetos mock embutida na biblioteca padrão como
algumas outras linguagens têm. No entanto, você certamente pode criar uma
struct que sirva aos mesmos propósitos de um objeto mock.

Este é o cenário que vamos testar: criaremos uma biblioteca que acompanha um
valor em relação a um valor máximo e envia mensagens com base em quão próximo o
valor atual está do valor máximo. Essa biblioteca poderia ser usada, por
exemplo, para acompanhar a cota de uma pessoa usuária quanto ao número de
chamadas de API que ela tem permissão para fazer.

Nossa biblioteca fornecerá apenas a funcionalidade de acompanhar quão perto do
máximo um valor está e quais mensagens devem ser enviadas em quais momentos.
Aplicações que usarem nossa biblioteca deverão fornecer o mecanismo de envio
das mensagens: a aplicação poderia mostrar a mensagem diretamente à pessoa
usuária, enviar um email, enviar uma mensagem de texto ou fazer outra coisa. A
biblioteca não precisa saber esse detalhe. Tudo de que ela precisa é algo que
implemente uma trait que forneceremos, chamada `Messenger`. A Listagem 15-20
mostra o código da biblioteca.

<Listing number="15-20" file-name="src/lib.rs" caption="Uma biblioteca para acompanhar quão próximo um valor está de um valor máximo e avisar quando o valor está em certos níveis">

```rust,noplayground
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-20/src/lib.rs}}
```

</Listing>

Uma parte importante desse código é que a trait `Messenger` tem um método
chamado `send`, que recebe uma referência imutável para `self` e o texto da
mensagem. Essa trait é a interface que nosso objeto mock precisa implementar
para que o mock possa ser usado da mesma forma que um objeto real. A outra
parte importante é que queremos testar o comportamento do método `set_value` em
`LimitTracker`. Podemos mudar o que passamos para o parâmetro `value`, mas
`set_value` não retorna nada sobre o que possamos fazer asserções. Queremos
poder dizer que, se criarmos um `LimitTracker` com algo que implementa a trait
`Messenger` e um valor específico para `max`, o messenger será instruído a
enviar as mensagens apropriadas quando passarmos números diferentes para
`value`.

Precisamos de um objeto mock que, em vez de enviar um email ou mensagem de
texto quando chamamos `send`, apenas registre as mensagens que foi instruído a
enviar. Podemos criar uma nova instância do objeto mock, criar um
`LimitTracker` que usa o objeto mock, chamar o método `set_value` em
`LimitTracker` e então verificar se o objeto mock tem as mensagens que
esperamos. A Listagem 15-21 mostra uma tentativa de implementar um objeto mock
para fazer exatamente isso, mas o borrow checker não permite.

<Listing number="15-21" file-name="src/lib.rs" caption="Uma tentativa de implementar um `MockMessenger` que não é permitida pelo borrow checker">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-21/src/lib.rs:here}}
```

</Listing>

Esse código de teste define uma struct `MockMessenger` que tem um campo
`sent_messages` com um `Vec` de valores `String` para registrar as mensagens
que foi instruída a enviar. Também definimos uma função associada `new` para
facilitar a criação de novos valores `MockMessenger` que começam com uma lista
vazia de mensagens. Em seguida, implementamos a trait `Messenger` para
`MockMessenger` para que possamos fornecer um `MockMessenger` a um
`LimitTracker`. Na definição do método `send`, pegamos a mensagem passada como
parâmetro e a armazenamos na lista `sent_messages` de `MockMessenger`.

No teste, estamos verificando o que acontece quando o `LimitTracker` é
instruído a definir `value` para algo que é mais de 75 por cento do valor
`max`. Primeiro, criamos um novo `MockMessenger`, que começará com uma lista
vazia de mensagens. Depois, criamos um novo `LimitTracker` e damos a ele uma
referência para o novo `MockMessenger` e um valor `max` de `100`. Chamamos o
método `set_value` em `LimitTracker` com um valor de `80`, que é mais de 75 por
cento de 100. Então verificamos que a lista de mensagens que o `MockMessenger`
está registrando agora deve conter uma mensagem.

No entanto, há um problema com esse teste, como mostrado aqui:

```console
{{#include ../listings/ch15-smart-pointers/listing-15-21/output.txt}}
```

Não podemos modificar o `MockMessenger` para registrar as mensagens, porque o
método `send` recebe uma referência imutável para `self`. Também não podemos
seguir a sugestão do texto de erro de usar `&mut self` tanto no método do
`impl` quanto na definição da trait. Não queremos mudar a trait `Messenger`
apenas por causa do teste. Em vez disso, precisamos encontrar uma forma de
fazer nosso código de teste funcionar corretamente com o design existente.

Essa é uma situação em que a mutabilidade interior pode ajudar! Armazenaremos
`sent_messages` dentro de um `RefCell<T>`, e então o método `send` poderá
modificar `sent_messages` para armazenar as mensagens que vimos. A Listagem
15-22 mostra como isso fica.

<Listing number="15-22" file-name="src/lib.rs" caption="Usando `RefCell<T>` para modificar um valor interno enquanto o valor externo é considerado imutável">

```rust,noplayground
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-22/src/lib.rs:here}}
```

</Listing>

O campo `sent_messages` agora é do tipo `RefCell<Vec<String>>` em vez de
`Vec<String>`. Na função `new`, criamos uma nova instância de
`RefCell<Vec<String>>` em torno do vetor vazio.

Na implementação do método `send`, o primeiro parâmetro ainda é um empréstimo
imutável de `self`, o que corresponde à definição da trait. Chamamos
`borrow_mut` no `RefCell<Vec<String>>` em `self.sent_messages` para obter uma
referência mutável para o valor dentro de `RefCell<Vec<String>>`, que é o
vetor. Então podemos chamar `push` na referência mutável para o vetor para
registrar as mensagens enviadas durante o teste.

A última mudança que precisamos fazer é na asserção: para ver quantos itens
estão no vetor interno, chamamos `borrow` no `RefCell<Vec<String>>` para obter
uma referência imutável para o vetor.

Agora que você viu como usar `RefCell<T>`, vamos nos aprofundar em como ele
funciona!

<!-- Old headings. Do not remove or links may break. -->

<a id="keeping-track-of-borrows-at-runtime-with-refcellt"></a>

#### Registrando Empréstimos em Tempo de Execução

Ao criar referências imutáveis e mutáveis, usamos as sintaxes `&` e `&mut`,
respectivamente. Com `RefCell<T>`, usamos os métodos `borrow` e `borrow_mut`,
que fazem parte da API segura pertencente a `RefCell<T>`. O método `borrow`
retorna o tipo de ponteiro inteligente `Ref<T>`, e `borrow_mut` retorna o tipo
de ponteiro inteligente `RefMut<T>`. Ambos implementam `Deref`, então podemos
tratá-los como referências comuns.

O `RefCell<T>` registra quantos ponteiros inteligentes `Ref<T>` e `RefMut<T>`
estão ativos no momento. Toda vez que chamamos `borrow`, o `RefCell<T>` aumenta
sua contagem de quantos empréstimos imutáveis estão ativos. Quando um valor
`Ref<T>` sai de escopo, a contagem de empréstimos imutáveis diminui em 1. Assim
como as regras de borrowing em tempo de compilação, `RefCell<T>` nos permite
ter muitos empréstimos imutáveis ou um empréstimo mutável em qualquer momento.

Se tentarmos violar essas regras, em vez de receber um erro do compilador como
aconteceria com referências, a implementação de `RefCell<T>` entrará em pânico
em tempo de execução. A Listagem 15-23 mostra uma modificação da implementação
de `send` da Listagem 15-22. Estamos tentando deliberadamente criar dois
empréstimos mutáveis ativos no mesmo escopo para ilustrar que `RefCell<T>` nos
impede de fazer isso em tempo de execução.

<Listing number="15-23" file-name="src/lib.rs" caption="Criando duas referências mutáveis no mesmo escopo para ver que `RefCell<T>` entrará em pânico">

```rust,ignore,panics
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-23/src/lib.rs:here}}
```

</Listing>

Criamos uma variável `one_borrow` para o ponteiro inteligente `RefMut<T>`
retornado por `borrow_mut`. Depois, criamos outro empréstimo mutável da mesma
forma na variável `two_borrow`. Isso cria duas referências mutáveis no mesmo
escopo, o que não é permitido. Quando executarmos os testes da nossa
biblioteca, o código da Listagem 15-23 compilará sem erros, mas o teste
falhará:

```console
{{#include ../listings/ch15-smart-pointers/listing-15-23/output.txt}}
```

Observe que o código entrou em pânico com a mensagem `already borrowed:
BorrowMutError`. É assim que `RefCell<T>` lida com violações das regras de
borrowing em tempo de execução.

Escolher capturar erros de borrowing em tempo de execução em vez de em tempo de
compilação, como fizemos aqui, significa que você possivelmente encontrará
erros no seu código mais tarde no processo de desenvolvimento: talvez só depois
que o código já estiver implantado em produção. Além disso, seu código terá uma
pequena penalidade de desempenho em tempo de execução como resultado de
registrar os empréstimos em tempo de execução em vez de em tempo de compilação.
No entanto, usar `RefCell<T>` torna possível escrever um objeto mock que pode
modificar a si mesmo para registrar as mensagens que viu enquanto é usado em um
contexto em que apenas valores imutáveis são permitidos. Você pode usar
`RefCell<T>`, apesar de seus trade-offs, para obter mais funcionalidade do que
referências comuns fornecem.

<!-- Old headings. Do not remove or links may break. -->

<a id="having-multiple-owners-of-mutable-data-by-combining-rc-t-and-ref-cell-t"></a>
<a id="allowing-multiple-owners-of-mutable-data-with-rct-and-refcellt"></a>

### Permitindo Múltiplos Donos de Dados Mutáveis

Uma forma comum de usar `RefCell<T>` é em combinação com `Rc<T>`. Lembre-se de
que `Rc<T>` permite ter múltiplos donos de alguns dados, mas só fornece acesso
imutável a esses dados. Se você tem um `Rc<T>` que armazena um `RefCell<T>`,
pode obter um valor que pode ter múltiplos donos _e_ que você pode modificar!

Por exemplo, lembre-se do exemplo da cons list na Listagem 15-18, em que usamos
`Rc<T>` para permitir que múltiplas listas compartilhassem ownership de outra
lista. Como `Rc<T>` armazena apenas valores imutáveis, não podemos alterar
nenhum dos valores na lista depois de criá-los. Vamos adicionar `RefCell<T>`
por sua capacidade de alterar os valores nas listas. A Listagem 15-24 mostra
que, usando um `RefCell<T>` na definição de `Cons`, podemos modificar o valor
armazenado em todas as listas.

<Listing number="15-24" file-name="src/main.rs" caption="Usando `Rc<RefCell<i32>>` para criar uma `List` que podemos modificar">

```rust
{{#rustdoc_include ../listings/ch15-smart-pointers/listing-15-24/src/main.rs}}
```

</Listing>

Criamos um valor que é uma instância de `Rc<RefCell<i32>>` e o armazenamos em
uma variável chamada `value`, para que possamos acessá-lo diretamente mais
tarde. Então criamos uma `List` em `a` com uma variante `Cons` que armazena
`value`. Precisamos clonar `value` para que tanto `a` quanto `value` tenham
ownership do valor interno `5`, em vez de transferir ownership de `value` para
`a` ou fazer `a` pegar emprestado de `value`.

Envolvemos a lista `a` em um `Rc<T>` para que, quando criarmos as listas `b` e
`c`, ambas possam se referir a `a`, que é o que fizemos na Listagem 15-18.

Depois de criar as listas em `a`, `b` e `c`, queremos adicionar 10 ao valor em
`value`. Fazemos isso chamando `borrow_mut` em `value`, o que usa o recurso de
desreferência automática que discutimos em [“Onde Está o Operador
`->`?”][wheres-the---operator]<!-- ignore --> no Capítulo 5 para desreferenciar
o `Rc<T>` até o valor interno `RefCell<T>`. O método `borrow_mut` retorna um
ponteiro inteligente `RefMut<T>`, e usamos o operador de desreferência nele
para alterar o valor interno.

Quando imprimimos `a`, `b` e `c`, vemos que todos eles têm o valor modificado
`15` em vez de `5`:

```console
{{#include ../listings/ch15-smart-pointers/listing-15-24/output.txt}}
```

Essa técnica é bem interessante! Ao usar `RefCell<T>`, temos um valor `List`
externamente imutável. Mas podemos usar os métodos em `RefCell<T>` que
fornecem acesso à sua mutabilidade interior para modificar nossos dados quando
precisarmos. As verificações em tempo de execução das regras de borrowing nos
protegem de data races, e às vezes vale trocar um pouco de velocidade por essa
flexibilidade nas nossas estruturas de dados. Observe que `RefCell<T>` não
funciona em código multithread! `Mutex<T>` é a versão thread-safe de
`RefCell<T>`, e discutiremos `Mutex<T>` no Capítulo 16.

[wheres-the---operator]: ch05-03-method-syntax.html#wheres-the---operator

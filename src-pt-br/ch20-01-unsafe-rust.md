## Unsafe Rust

Todo o código que discutimos até agora teve as garantias de segurança de memória do Rust
aplicadas em tempo de compilação. No entanto, o Rust possui uma segunda linguagem escondida dentro dele
que não impõe essas garantias de segurança de memória: ela é chamada de _unsafe Rust_
e funciona como o Rust normal, mas nos dá superpoderes extras.

O Rust inseguro existe porque, por natureza, a análise estática é conservadora. Quando
o compilador tenta determinar se o código mantém ou não as garantias,
é melhor rejeitar alguns programas válidos do que aceitar alguns programas inválidos.
Embora o código _possa_ estar correto, se o compilador Rust não tiver
informações suficientes para ter confiança, ele rejeitará o código. Nestes casos,
você pode usar código inseguro para dizer ao compilador: “Confie em mim, eu sei o que estou
fazendo.” Esteja avisado, entretanto, de que você usa Rust inseguro por sua própria conta e risco: se você
usar código inseguro incorretamente, podem ocorrer problemas devido à insegurança da memória, como
desreferenciação de ponteiro nulo.

Outra razão pela qual o Rust tem um alter ego inseguro é que o hardware subjacente
do computador é inerentemente inseguro. Se o Rust não permitisse que você realizasse operações inseguras,
você não conseguiria executar certas tarefas. O Rust precisa permitir que você faça
programação de sistemas de baixo nível, como interagir diretamente com o sistema operacional ou até
mesmo escrever seu próprio sistema operacional. Trabalhar com programação de sistemas de baixo nível
é um dos objetivos da linguagem. Vamos explorar o que podemos fazer com
unsafe Rust e como fazê-lo.

<!-- Old headings. Do not remove or links may break. -->

<a id="unsafe-superpowers"></a>

### Executando superpoderes inseguros

Para mudar para Rust inseguro, use a palavra-chave `unsafe` e inicie um novo bloco
que contenha o código inseguro. Você pode realizar cinco ações em Rust inseguro que você
não pode realizar em Rust seguro, que chamamos de _superpoderes inseguros_. Esses superpoderes
incluem a capacidade de:

1. Desreferenciar um raw pointer.
1. Chamar uma função ou método `unsafe`.
1. Acessar ou modificar uma variável estática mutável.
1. Implementar uma trait `unsafe`.
1. Acessar campos de `union`s.

É importante entender que `unsafe` não desliga o borrow checker
nem desabilita qualquer uma das outras verificações de segurança do Rust: se você usar uma referência em
código inseguro, ela ainda será verificada. A palavra-chave `unsafe` só dá acesso a
esses cinco recursos que não são verificados pelo compilador quanto à segurança de memória.
Você ainda terá algum grau de segurança dentro de um bloco inseguro.

Além disso, `unsafe` não significa que o código dentro do bloco seja necessariamente
perigoso ou que definitivamente terá problemas de segurança de memória: A intenção é
que, como programador, você garantirá que o código dentro de um bloco `unsafe`
acessará a memória de maneira válida.

As pessoas são falíveis e erros acontecerão, mas, ao exigir que essas cinco
operações inseguras estejam dentro de blocos anotados com `unsafe`, você saberá que
quaisquer erros relacionados à segurança de memória devem estar dentro de um bloco `unsafe`.
Mantenha os blocos `unsafe` pequenos; você ficará grato depois, quando estiver investigando bugs de memória.

Para isolar o máximo possível o código inseguro, é melhor incluí-lo
dentro de uma abstração segura e fornecer uma API segura, que discutiremos mais tarde
o capítulo quando examinamos funções e métodos inseguros. Partes do padrão
biblioteca são implementadas como abstrações seguras sobre código inseguro que foi
auditado. Agrupar código inseguro em uma abstração segura evita o uso de `unsafe`
evite que vaze para todos os lugares que você ou seus usuários possam querer usar
a funcionalidade implementada com o código ` unsafe`, pois utilizando um
a abstração é segura.

Vejamos cada uma das cinco superpotências inseguras. Também veremos
algumas abstrações que fornecem uma interface segura para código inseguro.

### Desreferenciando um raw pointer

No Capítulo 4, na seção [“Referências pendentes”][dangling-references]<!-- ignore
-->, mencionamos que o compilador garante que as referências sejam sempre
válidas. Unsafe Rust tem dois novos tipos chamados _raw pointers_, que são semelhantes a
referências. Assim como acontece com referências, raw pointers podem ser imutáveis ou mutáveis e
são escritos como `*const T` e `*mut T`, respectivamente. O asterisco não é o
operador de desreferência; faz parte do nome do tipo. No contexto da matéria-prima
ponteiros, _imutável_ significa que o ponteiro não pode ser atribuído diretamente a
depois de ser desreferenciado.

Diferentemente de referências e smart pointers, raw pointers:

- Podem ignorar as regras de borrowing, tendo ponteiros imutáveis e mutáveis,
  ou vários ponteiros mutáveis, para o mesmo local
- Não há garantia de apontar para memória válida
- Podem ser nulos
- Não implementam nenhuma limpeza automática

Ao optar por não fazer com que Rust aplique essas garantias, você pode desistir
segurança garantida em troca de maior desempenho ou capacidade de
interface com outro idioma ou hardware onde as garantias do Rust não se aplicam.

A Listagem 20-1 mostra como criar um raw pointer imutável e um mutável.

<Listing number="20-1" caption="Criando ponteiros brutos com os operadores de empréstimo bruto">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-01/src/main.rs:here}}
```

</Listing>

Observe que não incluímos a palavra-chave `unsafe` neste código. Podemos criar
raw pointers em código seguro; simplesmente não podemos desreferenciar raw pointers fora de um
bloco inseguro, como você verá daqui a pouco.

Criamos ponteiros brutos usando os operadores de borrowing bruto: `&raw const num`
cria um ponteiro bruto imutável ` *const i32`e ` &raw mut num`cria um ponteiro bruto mutável ` *mut
i32`. Porque nós os criamos diretamente de um local
variável, sabemos que esses ponteiros brutos específicos são válidos, mas não podemos fazer
essa suposição sobre qualquer ponteiro bruto.

Para demonstrar isso, a seguir criaremos um ponteiro bruto cuja validade não podemos
tão certo de usar a palavra-chave `as` para converter um valor em vez de usar o valor bruto
operador de borrowing. A Listagem 20-2 mostra como criar um ponteiro bruto para um valor arbitrário
localização na memória. Tentar usar memória arbitrária é indefinido: pode haver
dados naquele endereço ou não, o compilador pode otimizar o código
para que não haja acesso à memória, ou o programa pode terminar com um
falha de segmentação. Normalmente, não há um bom motivo para escrever código como este,
especialmente nos casos em que você pode usar um operador de borrowing bruto, mas é
possível.

<Listing number="20-2" caption="Criando um ponteiro bruto para um endereço de memória arbitrário">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-02/src/main.rs:here}}
```

</Listing>

Lembre-se de que podemos criar ponteiros brutos em código seguro, mas não podemos desreferenciar
ponteiros brutos e lê os dados apontados. Na Listagem 20-3, usamos o
operador de desreferência `*` em um ponteiro bruto que requer um bloco `unsafe`.

<Listing number="20-3" caption="Dereferenciando ponteiros brutos dentro de um bloco `unsafe`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-03/src/main.rs:here}}
```

</Listing>

Criar um ponteiro não causa nenhum dano; é somente quando tentamos acessar o valor que
isso indica que podemos acabar lidando com um valor inválido.

Observe também que nas Listagens 20-1 e 20-3, criamos ponteiros brutos `*const i32` e `*mut
i32` que apontavam para o mesmo local de memória, onde `num` é
armazenado. Se em vez disso tentássemos criar uma referência imutável e mutável para
`num`, o código não teria sido compilado porque as regras ownership do Rust não
permitir uma referência mutável ao mesmo tempo que quaisquer referências imutáveis. Com
ponteiros brutos, podemos criar um ponteiro mutável e um ponteiro imutável para o
mesmo local e alterar dados através do ponteiro mutável, potencialmente criando
uma corrida de dados. Tome cuidado!

Com todos esses perigos, por que você usaria ponteiros brutos? Um uso importante
O caso é durante a interface com o código C, como você verá na próxima seção.
Outro caso é ao construir abstrações seguras que o borrow checker
não entende. Apresentaremos funções inseguras e depois veremos um
exemplo de uma abstração segura que usa código inseguro.

### Chamando uma função ou método `unsafe`

O segundo tipo de operação que você pode realizar em um bloco inseguro é chamar
funções inseguras. Funções e métodos inseguros parecem exatamente iguais aos normais
funções e métodos, mas eles têm um `unsafe` extra antes do resto do
definição. A palavra-chave `unsafe` neste contexto indica que a função tem
requisitos que precisamos manter quando chamamos esta função, porque Rust não pode
garantimos que cumprimos esses requisitos. Ao chamar uma função insegura dentro de um
Bloco `unsafe`, estamos dizendo que lemos a documentação desta função e
assumimos a responsabilidade de manter os contratos da função.

Aqui está uma função `unsafe` chamada `dangerous` que não faz nada em seu
corpo:

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-01-unsafe-fn/src/main.rs:here}}
```

Devemos chamar a função `dangerous` dentro de um bloco `unsafe` separado. Se nós
tente chamar `dangerous` sem o bloco `unsafe`, obteremos um erro:

```console
{{#include ../listings/ch20-advanced-features/output-only-01-missing-unsafe/output.txt}}
```

Com o bloco `unsafe`, estamos afirmando para Rust que lemos o valor da função
documentação, entendemos como usá-la corretamente e verificamos que
estamos cumprindo o contrato da função.

Para realizar operações inseguras no corpo de uma função `unsafe`, você ainda
precisa usar um bloco ` unsafe`, assim como dentro de uma função regular, e o
o compilador irá avisá-lo se você esquecer. Isso nos ajuda a manter os blocos ` unsafe`como
tão pequena quanto possível, uma vez que operações inseguras podem não ser necessárias em todo o
corpo funcional.

#### Criando uma abstração segura sobre código unsafe

Só porque uma função contém código inseguro não significa que precisamos marcar o
toda a função como insegura. Na verdade, agrupar código inseguro em uma função segura é
uma abstração comum. Como exemplo, vamos estudar a função `split_at_mut`
da biblioteca padrão, que requer algum código inseguro. Exploraremos como
podemos implementá-lo. Este método seguro é definido no slices mutável: é necessário
um slice e torna-o dois dividindo o slice no índice fornecido como um
argumento. A Listagem 20-4 mostra como usar ` split_at_mut`.

<Listing number="20-4" caption="Usando a função segura `split_at_mut`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-04/src/main.rs:here}}
```

</Listing>

Não podemos implementar esta função usando apenas Rust seguro. Uma tentativa pode parecer
algo como a Listagem 20-5, que não será compilada. Para simplificar, vamos
implementar `split_at_mut` como uma função em vez de um método e apenas para slices
de valores `i32` em vez de um tipo genérico `T`.

<Listing number="20-5" caption="Uma tentativa de implementar `split_at_mut` usando apenas Rust seguro">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-05/src/main.rs:here}}
```

</Listing>

Esta função obtém primeiro o comprimento total do slice. Então, afirma que
o índice fornecido como parâmetro está dentro do slice verificando se está
menor ou igual ao comprimento. A afirmação significa que se passarmos um índice
que é maior que o comprimento para dividir o slice, a função será panic
antes de tentar usar esse índice.

Então, retornamos dois slices mutáveis em uma tupla: um do início do
slice original para o índice `mid` e outro de `mid` até o final do
slice.

Quando tentarmos compilar o código da Listagem 20-5, receberemos um erro:

```console
{{#include ../listings/ch20-advanced-features/listing-20-05/output.txt}}
```

O borrow checker do Rust não consegue entender que somos borrowing partes diferentes de
o slice; ele só sabe que somos borrowing do mesmo slice duas vezes.
Emprestar diferentes partes de um slice é fundamentalmente aceitável porque os dois
slices não se sobrepõem, mas Rust não é inteligente o suficiente para saber disso. Quando nós
Se você sabe que o código está correto, mas Rust não, é hora de procurar um código inseguro.

A Listagem 20-6 mostra como usar um bloco `unsafe`, um ponteiro bruto e algumas chamadas
a funções inseguras para fazer a implementação do ` split_at_mut`funcionar.

<Listing number="20-6" caption="Usando código unsafe na implementação da função `split_at_mut`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-06/src/main.rs:here}}
```

</Listing>

Lembre-se da seção [“The Slice Type”][the-slice-type]<!-- ignore --> em
Capítulo 4 que slice é um ponteiro para alguns dados e o comprimento do slice.
Usamos o método `len` para obter o comprimento de um slice e do `as_mut_ptr`
método para acessar o ponteiro bruto de um slice. Neste caso, porque temos um
valores mutáveis ​​de slice para ` i32`, ` as_mut_ptr`retorna um ponteiro bruto com o tipo
` *mut i32 `, que armazenamos na variável` ptr`.

Mantemos a afirmação de que o índice `mid` está dentro do slice. Então, chegamos a
o código inseguro: a função `slice::from_raw_parts_mut` usa um ponteiro bruto
e um comprimento, e cria um slice. Usamos esta função para criar um slice
que começa em `ptr` e tem `mid` itens de comprimento. Então, chamamos o método `add`
em ` ptr`com ` mid`como argumento para obter um ponteiro bruto que começa em ` mid`,
e criamos um slice usando esse ponteiro e o número restante de itens
após ` mid`como o comprimento.

A função `slice::from_raw_parts_mut` não é segura porque requer um valor bruto
ponteiro e deve confiar que esse ponteiro é válido. O método `add` em bruto
ponteiros também não é seguro porque deve confiar que o local do deslocamento também é
um ponteiro válido. Portanto, tivemos que colocar um bloco `unsafe` em torno de nossas chamadas para
`slice::from_raw_parts_mut ` e`add ` para que possamos chamá-los. Ao olhar para
o código e adicionando a afirmação de que`mid ` deve ser menor ou igual a
`len `, podemos dizer que todos os ponteiros brutos usados no bloco` unsafe `
serão ponteiros válidos para dados dentro do slice. Isto é aceitável e
uso apropriado de` unsafe`.

Observe que não precisamos marcar a função `split_at_mut` resultante como
`unsafe `, e podemos chamar esta função do Rust seguro. Criamos um cofre
abstração para o código inseguro com uma implementação da função que usa
código` unsafe`de forma segura, pois cria apenas ponteiros válidos a partir do
dados aos quais esta função tem acesso.

Em contraste, o uso de `slice::from_raw_parts_mut` na Listagem 20-7 seria
provavelmente travará quando o slice for usado. Este código ocupa uma memória arbitrária
local e cria um slice com 10.000 itens.

<Listing number="20-7" caption="Criando um slice a partir de uma posição arbitrária de memória">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-07/src/main.rs:here}}
```

</Listing>

Não possuímos a memória neste local arbitrário e não há garantia
que o slice criado por esse código contém valores `i32` válidos. Tentando usar
`values` como se fosse um slice válido resulta em comportamento indefinido.

#### Usando funções `extern` para chamar código externo

Às vezes, seu código Rust pode precisar interagir com código escrito em outro
linguagem. Para isso, Rust possui a palavra-chave `extern` que facilita a criação
e uso de uma _Foreign Function Interface (FFI)_, que é uma forma de
linguagem de programação para definir funções e permitir um diferente (estrangeiro)
linguagem de programação para chamar essas funções.

A Listagem 20-8 demonstra como configurar uma integração com a função `abs`
da biblioteca padrão C. As funções declaradas nos blocos ` extern`são
geralmente não é seguro chamar do código Rust, portanto os blocos ` extern`também devem ser marcados
` unsafe`. A razão é que outras linguagens não aplicam as regras do Rust e
garantias, e Rust não pode verificá-las, então a responsabilidade recai sobre o
Programador para garantir a segurança.

<Listing number="20-8" file-name="src/main.rs" caption="Declarando e chamando uma função `extern` definida em outra linguagem">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-08/src/main.rs}}
```

</Listing>

Dentro do bloco `unsafe extern "C"`, listamos os nomes e assinaturas de
funções externas de outra linguagem que queremos chamar. A parte ` "C"`
define qual _interface binária de aplicativo (ABI)_ a função externa usa:
A ABI define como chamar a função no nível do assembly. A ABI ` "C"`
é o mais comum e segue a ABI da linguagem de programação C. Informação
sobre todas as ABIs suportadas pelo Rust está disponível em [Referência Rust][ABI].

Cada item declarado em um bloco `unsafe extern` é implicitamente inseguro.
No entanto, algumas funções FFI *são* seguras para serem chamadas. Por exemplo, a função `abs`
da biblioteca padrão de C não tem nenhuma consideração de segurança de memória, e nós
saiba que pode ser chamado com qualquer ` i32`. Em casos como este, podemos usar o ` safe`
palavra-chave para dizer que esta função específica é segura para chamar, mesmo que esteja em
um bloco ` unsafe extern`. Depois de fazermos essa mudança, não chamaremos mais
requer um bloco ` unsafe`, conforme mostrado na Listagem 20-9.

<Listing number="20-9" file-name="src/main.rs" caption="Marcando explicitamente uma função como `safe` dentro de um bloco `unsafe extern` e chamando-a com segurança">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-09/src/main.rs}}
```

</Listing>

Marcar uma função como `safe` não a torna inerentemente segura! Em vez disso, é
como uma promessa que você está fazendo ao Rust de que é seguro. Ainda é seu
responsabilidade de garantir que essa promessa seja cumprida!

#### Chamando funções Rust de outros idiomas

Também podemos usar `extern` para criar uma interface que permite que outras linguagens
chamar funções Rust. Em vez de criar um bloco `extern` inteiro, adicionamos o
palavra-chave `extern` e especifique a ABI a ser usada logo antes da palavra-chave `fn` para
a função relevante. Também precisamos adicionar uma anotação `#[unsafe(no_mangle)]`
para informar ao compilador Rust para não alterar o nome desta função. _Mangling_
é quando um compilador muda o nome que demos a uma função para um nome diferente
que contém mais informações para outras partes do processo de compilação
consumir, mas é menos legível por humanos. Todo compilador de linguagem de programação confunde
nomes ligeiramente diferentes, portanto, para que uma função Rust possa ser nomeada por outros
linguagens, devemos desabilitar a manipulação de nomes do compilador Rust. Isso não é seguro
porque pode haver colisões de nomes entre bibliotecas sem o recurso integrado
mutilado, por isso é nossa responsabilidade garantir que o nome que escolhemos seja seguro
para exportar sem mutilar.

No exemplo a seguir, tornamos a função `call_from_c` acessível em C
código, depois de compilado em uma biblioteca compartilhada e vinculado a C:

```
#[unsafe(no_mangle)]
pub extern "C" fn call_from_c() {
    println!("Just called a Rust function from C!");
}
```

Este uso de `extern` requer `unsafe` apenas no atributo, não no
Bloco `extern`.

### Accessing or Modifying a Mutable Static Variable

Neste livro, ainda não falamos sobre variáveis globais, o que Rust faz
suporte, mas que pode ser problemático com as regras ownership do Rust. Se dois
threads estão acessando a mesma variável global mutável, isso pode causar um problema de dados
corrida.

Em Rust, as variáveis ​​globais são chamadas de variáveis ​​_estáticas_. A listagem 20-10 mostra um
declaração de exemplo e uso de uma variável estática com uma string slice como
valor.

<Listing number="20-10" file-name="src/main.rs" caption="Definindo e usando uma variável estática imutável">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-10/src/main.rs}}
```

</Listing>

Variáveis estáticas são semelhantes a constantes, que discutimos no
[“Declarando Constantes”][constants]<!-- ignore --> seção no Capítulo 3. O
os nomes das variáveis estáticas estão em `SCREAMING_SNAKE_CASE` por convenção. Estático
variáveis só podem armazenar referências com `'static` lifetime, o que significa
o compilador Rust pode descobrir o lifetime e não somos obrigados a
anote-o explicitamente. Acessar uma variável estática imutável é seguro.

Uma diferença sutil entre constantes e variáveis estáticas imutáveis é que
os valores em uma variável estática têm um endereço fixo na memória. Usando o valor
sempre acessará os mesmos dados. As constantes, por outro lado, podem
duplicar seus dados sempre que forem usados. Outra diferença é que a estática
variáveis podem ser mutáveis. Acessar e modificar variáveis estáticas mutáveis é
_inseguro_. A Listagem 20-11 mostra como declarar, acessar e modificar um mutável
variável estática chamada `COUNTER`.

<Listing number="20-11" file-name="src/main.rs" caption="Ler de uma variável estática mutável ou escrever nela é unsafe">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-11/src/main.rs}}
```

</Listing>

Tal como acontece com as variáveis ​​regulares, especificamos a mutabilidade usando a palavra-chave `mut`. Qualquer
o código que lê ou grava de ` COUNTER`deve estar dentro de um bloco ` unsafe`. O
o código na Listagem 20-11 compila e imprime ` COUNTER: 3`como seria de esperar
porque é de thread único. Ter vários acessos threads ` COUNTER`seria
provavelmente resultará em corridas de dados, portanto, é um comportamento indefinido. Portanto, precisamos
marque toda a função como ` unsafe`e documente a limitação de segurança para que
qualquer pessoa que chame a função sabe o que é e não tem permissão para fazer
com segurança.

Sempre que escrevemos uma função insegura, é idiomático escrever um comentário
começando com `SAFETY` e explicando o que o chamador precisa fazer para chamar o
funcionar com segurança. Da mesma forma, sempre que realizamos uma operação insegura, é
idiomático escrever um comentário começando com `SAFETY` para explicar como a segurança
regras são mantidas.

Além disso, o compilador negará por padrão qualquer tentativa de criar
referências a uma variável estática mutável por meio de um lint do compilador. Você deve
opte explicitamente por sair das proteções desse lint adicionando um
Anotação `#[allow(static_mut_refs)]` ou acesso à variável estática mutável
através de um ponteiro bruto criado com um dos operadores de borrowing bruto. Isso inclui
casos em que a referência é criada de forma invisível, como quando é usada no
`println!` nesta listagem de código. Exigindo referências a mutável estático
variáveis a serem criadas por meio de ponteiros brutos ajudam a cumprir os requisitos de segurança para
usá-los mais óbvio.

Com dados mutáveis acessíveis globalmente, é difícil garantir que
não há corridas de dados, e é por isso que Rust considera variáveis estáticas mutáveis
ser inseguro. Sempre que possível, é preferível usar as técnicas de simultaneidade
e thread seguro para smart pointers que discutimos no Capítulo 16 para que o compilador
verifica se o acesso aos dados de diferentes threads é feito com segurança.

### Implementando uma característica insegura

Podemos usar `unsafe` para implementar um trait inseguro. Um trait não é seguro quando
pelo menos um de seus métodos possui alguma invariante que o compilador não pode verificar. Nós
declare que um trait é `unsafe` adicionando a palavra-chave `unsafe` antes de `trait`
e marcando a implementação do trait como ` unsafe`também, conforme mostrado em
Listagem 20-12.

<Listing number="20-12" caption="Definindo e implementando uma trait unsafe">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-12/src/main.rs:here}}
```

</Listing>

Ao usar `unsafe impl`, prometemos que manteremos os invariantes que
o compilador não pode verificar.

Como exemplo, lembre-se dos marcadores `Send` e `Sync` traits que discutimos no
[“Extensible Concurrency with `Send` and `Sync`”][send-and-sync]<!-- ignore -->
seção no Capítulo 16: O compilador implementa estes traits automaticamente se
nossos tipos são compostos inteiramente de outros tipos que implementam `Send` e
`Sync `. Se implementarmos um tipo que contém um tipo que não implementa
` Send `ou` Sync `, como ponteiros brutos, e queremos marcar esse tipo como` Send `
ou` Sync `, devemos usar` unsafe `. Rust não pode verificar se nosso tipo mantém o
garante que ele pode ser enviado com segurança pelo threads ou acessado de vários
threads; portanto, precisamos fazer essas verificações manualmente e indicar como tal
com` unsafe`.

### Accessing Fields of a Union

A ação final que funciona apenas com `unsafe` é acessar os campos de uma união.
Uma *união* é semelhante a um `struct`, mas apenas um campo declarado é usado em um
instância específica de uma só vez. Os sindicatos são usados principalmente para fazer interface com
sindicatos no código C. Acessar campos de união não é seguro porque Rust não pode garantir
o tipo de dados que estão sendo armazenados atualmente na instância de união. Você pode
saiba mais sobre uniões na [Referência Rust][unions].

### Usando Miri para verificar código inseguro

Ao escrever código inseguro, você pode querer verificar se o que você escreveu
na verdade é seguro e correto. Uma das melhores maneiras de fazer isso é usar Miri,
uma ferramenta oficial Rust para detectar comportamento indefinido. Considerando que o borrowing
checker é uma ferramenta _estática_ que funciona em tempo de compilação, Miri é uma ferramenta _dinâmica_
ferramenta que funciona em tempo de execução. Ele verifica seu código executando seu programa ou
seu conjunto de testes e detectando quando você viola as regras que ele entende
como Rust deve funcionar.

O uso do Miri requer uma compilação noturna do Rust (sobre o qual falaremos mais em
[Apêndice G: Como Rust é feito e “Nightly Rust”][nightly]<!-- ignore -->). Você
Você pode instalar uma versão noturna do Rust e a ferramenta Miri digitando `rustup
+nightly component add miri`. Isso não altera qual versão do Rust seu
usos do projeto; ele apenas adiciona a ferramenta ao seu sistema para que você possa usá-la quando precisar.
quero. Você pode executar o Miri em um projeto digitando ` cargo +nightly miri run`ou
` cargo +nightly miri test`.

Para obter um exemplo de como isso pode ser útil, considere o que acontece quando o executamos
contra a Listagem 20-7.

```console
{{#include ../listings/ch20-advanced-features/listing-20-07/output.txt}}
```

Miri nos avisa corretamente que estamos convertendo um número inteiro em um ponteiro, o que pode
ser um problema, mas Miri não consegue determinar se existe um problema porque
não sabe como o ponteiro se originou. Então, Miri retorna um erro onde
A Listagem 20-7 tem comportamento indefinido porque temos um ponteiro pendente. Obrigado
para Miri, agora sabemos que existe um risco de comportamento indefinido e podemos pensar
sobre como tornar o código seguro. Em alguns casos, Miri pode até fazer
recomendações sobre como corrigir erros.

Miri não detecta tudo o que você pode errar ao escrever um código inseguro.
Miri é uma ferramenta de análise dinâmica, por isso só detecta problemas com código que
na verdade é executado. Isso significa que você precisará usá-lo em conjunto com bons
técnicas de teste para aumentar sua confiança sobre o código inseguro que você possui
escrito. Miri também não cobre todas as maneiras possíveis pelas quais seu código pode estar incorreto.

Dito de outra forma: se Miri _detectar_ um problema, você sabe que há um bug, mas
só porque Miri _não_ detecta um bug não significa que não haja problema. Isso
pode pegar muito, no entanto. Tente executá-lo em outros exemplos de código inseguro em
este capítulo e veja o que ele diz!

Você pode aprender mais sobre o Miri em [seu repositório no GitHub][miri].

<!-- Old headings. Do not remove or links may break. -->

<a id="when-to-use-unsafe-code"></a>

### Usando código inseguro corretamente

Usar `unsafe` para usar um dos cinco superpoderes que acabamos de discutir não é errado ou
até desaprovado, mas é mais complicado obter o código `unsafe` correto porque o
o compilador não pode ajudar a manter a segurança da memória. Quando você tem um motivo para usar
código `unsafe`, você pode fazer isso, e ter a anotação ` unsafe`explícita faz
é mais fácil rastrear a origem dos problemas quando eles ocorrem. Sempre que você
escrever código inseguro, você pode usar o Miri para ajudá-lo a ter mais certeza de que o código
que você escreveu mantém as regras do Rust.

Para uma exploração muito mais profunda de como trabalhar de forma eficaz com Rust inseguro, leia
Guia oficial do Rust para `unsafe`, [The Rustonomicon][nomicon].

[dangling-references]: ch04-02-references-and-borrowing.html#dangling-references
[ABI]: https://doc.rust-lang.org/reference/items/external-blocks.html#abi
[constants]: ch03-01-variables-and-mutability.html#declaring-constants
[send-and-sync]: ch16-04-extensible-concurrency-sync-and-send.html
[the-slice-type]: ch04-03-slices.html#the-slice-type
[unions]: https://doc.rust-lang.org/reference/items/unions.html
[miri]: https://github.com/rust-lang/miri
[editions]: appendix-05-editions.html
[nightly]: appendix-07-nightly-rust.html
[nomicon]: https://doc.rust-lang.org/nomicon/

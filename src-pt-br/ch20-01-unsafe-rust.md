## Unsafe Rust

Todo o código que discutimos até agora teve as garantias de segurança de
memória de Rust aplicadas em tempo de compilação. No entanto, Rust tem uma
segunda linguagem escondida dentro dele que não aplica essas garantias de
segurança de memória: ela é chamada de _unsafe Rust_ e funciona como Rust
normal, mas nos dá superpoderes extras.

Unsafe Rust existe porque, por natureza, a análise estática é conservadora.
Quando o compilador tenta determinar se um código mantém ou não as garantias, é
melhor rejeitar alguns programas válidos do que aceitar alguns programas
inválidos. Embora o código _possa_ estar correto, se o compilador Rust não
tiver informações suficientes para ter confiança, ele rejeitará o código.
Nesses casos, você pode usar código unsafe para dizer ao compilador: "Confie em
mim, eu sei o que estou fazendo." Mas fica o aviso: você usa unsafe Rust por
sua própria conta e risco. Se usar código unsafe incorretamente, podem ocorrer
problemas de memory unsafety, como desreferenciar um ponteiro nulo.

Outra razão pela qual Rust tem um alter ego unsafe é que o hardware subjacente
do computador é inerentemente inseguro. Se Rust não permitisse operações
unsafe, você não conseguiria realizar certas tarefas. Rust precisa permitir que
você faça programação de sistemas de baixo nível, como interagir diretamente
com o sistema operacional ou até mesmo escrever seu próprio sistema operacional.
Trabalhar com programação de sistemas de baixo nível é um dos objetivos da
linguagem. Vamos explorar o que podemos fazer com unsafe Rust e como fazê-lo.

<!-- Old headings. Do not remove or links may break. -->

<a id="unsafe-superpowers"></a>

### Executando Superpoderes Unsafe

Para entrar em unsafe Rust, use a palavra-chave `unsafe` e inicie um novo bloco
que contém o código unsafe. Você pode realizar cinco ações em unsafe Rust que
não pode realizar em Rust seguro; chamamos essas ações de _superpoderes
unsafe_. Esses superpoderes incluem a capacidade de:

1. Desreferenciar um raw pointer.
1. Chamar uma função ou método `unsafe`.
1. Acessar ou modificar uma variável estática mutável.
1. Implementar uma trait `unsafe`.
1. Acessar campos de `union`s.

É importante entender que `unsafe` não desliga o borrow checker nem desabilita
qualquer outra verificação de segurança de Rust: se você usar uma referência em
código unsafe, ela ainda será verificada. A palavra-chave `unsafe` só dá acesso
a esses cinco recursos, que então não são verificados pelo compilador quanto à
segurança de memória. Você ainda terá algum grau de segurança dentro de um
bloco unsafe.

Além disso, `unsafe` não significa que o código dentro do bloco seja
necessariamente perigoso nem que ele definitivamente terá problemas de segurança
de memória. A intenção é que você, como programador, garanta que o código dentro
de um bloco `unsafe` acessará a memória de forma válida.

Pessoas cometem erros, mas, ao exigir que essas cinco operações unsafe estejam
dentro de blocos anotados com `unsafe`, você saberá que quaisquer erros
relacionados à segurança de memória devem estar dentro de um bloco `unsafe`.
Mantenha os blocos `unsafe` pequenos; você agradecerá depois, quando estiver
investigando bugs de memória.

Para isolar código unsafe tanto quanto possível, é melhor colocá-lo dentro de
uma abstração segura e fornecer uma API segura, algo que discutiremos mais
adiante neste capítulo ao examinar funções e métodos unsafe. Partes da
biblioteca padrão são implementadas como abstrações seguras sobre código unsafe
que foi auditado. Envolver código unsafe em uma abstração segura impede que o
uso de `unsafe` vaze para todos os lugares em que você ou seus usuários queiram
usar a funcionalidade implementada com código `unsafe`, porque usar uma
abstração segura é seguro.

Vamos examinar cada um dos cinco superpoderes unsafe. Também veremos algumas
abstrações que fornecem uma interface segura para código unsafe.

### Desreferenciando um Raw Pointer

No Capítulo 4, na seção [“Referências Pendentes”][dangling-references]<!--
ignore -->, mencionamos que o compilador garante que referências sejam sempre
válidas. Unsafe Rust tem dois novos tipos chamados _raw pointers_, que são
semelhantes a referências. Assim como referências, raw pointers podem ser
imutáveis ou mutáveis e são escritos como `*const T` e `*mut T`,
respectivamente. O asterisco não é o operador de desreferência; ele faz parte
do nome do tipo. No contexto de raw pointers, _imutável_ significa que o
ponteiro não pode receber uma atribuição direta depois de ser desreferenciado.

Diferentemente de referências e smart pointers, raw pointers:

- Podem ignorar as regras de borrowing, permitindo ponteiros imutáveis e
  mutáveis, ou vários ponteiros mutáveis, para o mesmo local
- Não têm garantia de apontar para memória válida
- Podem ser nulos
- Não implementam nenhuma limpeza automática

Ao optar por não fazer Rust aplicar essas garantias, você pode abrir mão da
segurança garantida em troca de mais desempenho ou da capacidade de interagir
com outra linguagem ou hardware em que as garantias de Rust não se aplicam.

A Listagem 20-1 mostra como criar um raw pointer imutável e um mutável.

<Listing number="20-1" caption="Criando raw pointers com os operadores de raw borrow">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-01/src/main.rs:here}}
```

</Listing>

Observe que não incluímos a palavra-chave `unsafe` nesse código. Podemos criar
raw pointers em código seguro; apenas não podemos desreferenciar raw pointers
fora de um bloco unsafe, como você verá daqui a pouco.

Criamos raw pointers usando os operadores de raw borrow: `&raw const num` cria
um raw pointer imutável `*const i32`, e `&raw mut num` cria um raw pointer
mutável `*mut i32`. Como os criamos diretamente a partir de uma variável local,
sabemos que esses raw pointers específicos são válidos, mas não podemos fazer
essa suposição sobre qualquer raw pointer.

Para demonstrar isso, a seguir criaremos um raw pointer cuja validade não
podemos ter tanta certeza, usando a palavra-chave `as` para converter um valor
em vez de usar o operador de raw borrow. A Listagem 20-2 mostra como criar um
raw pointer para uma posição arbitrária de memória. Tentar usar memória
arbitrária é comportamento indefinido: pode haver dados naquele endereço ou
não, o compilador pode otimizar o código de modo que não haja acesso à memória,
ou o programa pode terminar com uma falha de segmentação. Normalmente, não há
um bom motivo para escrever código assim, especialmente nos casos em que você
pode usar um operador de raw borrow, mas é possível.

<Listing number="20-2" caption="Criando um raw pointer para um endereço de memória arbitrário">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-02/src/main.rs:here}}
```

</Listing>

Lembre-se de que podemos criar raw pointers em código seguro, mas não podemos
desreferenciá-los e ler os dados apontados por eles. Na Listagem 20-3, usamos o
operador de desreferência `*` em um raw pointer, o que exige um bloco `unsafe`.

<Listing number="20-3" caption="Desreferenciando raw pointers dentro de um bloco `unsafe`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-03/src/main.rs:here}}
```

</Listing>

Criar um ponteiro não causa dano; é somente quando tentamos acessar o valor para
o qual ele aponta que podemos acabar lidando com um valor inválido.

Observe também que, nas Listagens 20-1 e 20-3, criamos raw pointers
`*const i32` e `*mut i32` que apontavam para o mesmo local de memória, onde
`num` está armazenado. Se, em vez disso, tentássemos criar uma referência
imutável e uma referência mutável para `num`, o código não compilaria, porque
as regras de ownership de Rust não permitem uma referência mutável ao mesmo
tempo que quaisquer referências imutáveis. Com raw pointers, podemos criar um
ponteiro mutável e um ponteiro imutável para o mesmo local e alterar dados por
meio do ponteiro mutável, potencialmente criando uma data race. Tome cuidado!

Com todos esses perigos, por que você usaria raw pointers? Um caso de uso
importante é ao interagir com código C, como você verá na próxima seção. Outro
caso é ao construir abstrações seguras que o borrow checker não entende.
Apresentaremos funções unsafe e depois veremos um exemplo de abstração segura
que usa código unsafe.

### Chamando uma Função ou Método `unsafe`

O segundo tipo de operação que você pode realizar em um bloco unsafe é chamar
funções unsafe. Funções e métodos unsafe se parecem exatamente com funções e
métodos normais, mas têm um `unsafe` extra antes do restante da definição. A
palavra-chave `unsafe` nesse contexto indica que a função tem requisitos que
precisamos manter ao chamá-la, porque Rust não consegue garantir que
cumprimos esses requisitos. Ao chamar uma função unsafe dentro de um bloco
`unsafe`, estamos dizendo que lemos a documentação dessa função e assumimos a
responsabilidade de manter os contratos dela.

Aqui está uma função `unsafe` chamada `dangerous` que não faz nada em seu corpo:

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/no-listing-01-unsafe-fn/src/main.rs:here}}
```

Devemos chamar a função `dangerous` dentro de um bloco `unsafe` separado. Se
tentarmos chamar `dangerous` sem o bloco `unsafe`, obteremos um erro:

```console
{{#include ../listings/ch20-advanced-features/output-only-01-missing-unsafe/output.txt}}
```

Com o bloco `unsafe`, estamos afirmando para Rust que lemos a documentação da
função, entendemos como usá-la corretamente e verificamos que estamos
cumprindo o contrato da função.

Para realizar operações unsafe no corpo de uma função `unsafe`, você ainda
precisa usar um bloco `unsafe`, assim como dentro de uma função normal, e o
compilador avisará se você esquecer. Isso nos ajuda a manter os blocos
`unsafe` tão pequenos quanto possível, já que operações unsafe podem não ser
necessárias em todo o corpo da função.

#### Criando uma Abstração Segura sobre Código Unsafe

Só porque uma função contém código unsafe não significa que precisamos marcar a
função inteira como unsafe. Na verdade, envolver código unsafe em uma função
segura é uma abstração comum. Como exemplo, vamos estudar a função
`split_at_mut` da biblioteca padrão, que requer algum código unsafe.
Exploraremos como poderíamos implementá-la. Esse método seguro é definido em
slices mutáveis: ele pega um slice e o transforma em dois, dividindo o slice no
índice fornecido como argumento. A Listagem 20-4 mostra como usar
`split_at_mut`.

<Listing number="20-4" caption="Usando a função segura `split_at_mut`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-04/src/main.rs:here}}
```

</Listing>

Não podemos implementar essa função usando apenas Rust seguro. Uma tentativa
poderia se parecer com a Listagem 20-5, que não compila. Para simplificar,
implementaremos `split_at_mut` como uma função em vez de um método, e apenas
para slices de valores `i32` em vez de para um tipo genérico `T`.

<Listing number="20-5" caption="Uma tentativa de implementar `split_at_mut` usando apenas Rust seguro">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-05/src/main.rs:here}}
```

</Listing>

Essa função primeiro obtém o comprimento total do slice. Então, afirma que o
índice fornecido como parâmetro está dentro do slice verificando se ele é menor
ou igual ao comprimento. A afirmação significa que, se passarmos um índice
maior que o comprimento para dividir o slice, a função entrará em panic antes
de tentar usar esse índice.

Depois, retornamos dois slices mutáveis em uma tupla: um do início do slice
original até o índice `mid`, e outro de `mid` até o fim do slice.

Quando tentarmos compilar o código da Listagem 20-5, receberemos um erro:

```console
{{#include ../listings/ch20-advanced-features/listing-20-05/output.txt}}
```

O borrow checker de Rust não consegue entender que estamos fazendo borrowing de
partes diferentes do slice; ele só sabe que estamos fazendo borrowing do mesmo
slice duas vezes. Fazer borrowing de partes diferentes de um slice é
fundamentalmente aceitável, porque os dois slices não se sobrepõem, mas Rust
não é inteligente o suficiente para saber disso. Quando sabemos que o código
está correto, mas Rust não sabe, é hora de recorrer a código unsafe.

A Listagem 20-6 mostra como usar um bloco `unsafe`, um raw pointer e algumas
chamadas a funções unsafe para fazer a implementação de `split_at_mut`
funcionar.

<Listing number="20-6" caption="Usando código unsafe na implementação da função `split_at_mut`">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-06/src/main.rs:here}}
```

</Listing>

Lembre-se da seção [“O Tipo Slice”][the-slice-type]<!-- ignore --> no Capítulo
4: um slice é um ponteiro para alguns dados e o comprimento do slice. Usamos o
método `len` para obter o comprimento de um slice e o método `as_mut_ptr` para
acessar o raw pointer de um slice. Nesse caso, como temos um slice mutável para
valores `i32`, `as_mut_ptr` retorna um raw pointer com o tipo `*mut i32`, que
armazenamos na variável `ptr`.

Mantemos a afirmação de que o índice `mid` está dentro do slice. Então,
chegamos ao código unsafe: a função `slice::from_raw_parts_mut` recebe um raw
pointer e um comprimento, e cria um slice. Usamos essa função para criar um
slice que começa em `ptr` e tem `mid` itens de comprimento. Depois, chamamos o
método `add` em `ptr`, com `mid` como argumento, para obter um raw pointer que
começa em `mid`, e criamos um slice usando esse ponteiro e o número restante de
itens depois de `mid` como comprimento.

A função `slice::from_raw_parts_mut` é unsafe porque recebe um raw pointer e
precisa confiar que esse ponteiro é válido. O método `add` em raw pointers
também é unsafe, porque precisa confiar que a posição deslocada também é um
ponteiro válido. Portanto, tivemos que colocar um bloco `unsafe` em torno das
chamadas a `slice::from_raw_parts_mut` e `add` para poder chamá-las. Ao olhar
para o código e ao adicionar a afirmação de que `mid` deve ser menor ou igual a
`len`, podemos dizer que todos os raw pointers usados dentro do bloco `unsafe`
serão ponteiros válidos para dados dentro do slice. Esse é um uso aceitável e
apropriado de `unsafe`.

Observe que não precisamos marcar a função `split_at_mut` resultante como
`unsafe`, e podemos chamá-la a partir de Rust seguro. Criamos uma abstração
segura para o código unsafe com uma implementação da função que usa código
`unsafe` de maneira segura, porque cria apenas ponteiros válidos a partir dos
dados aos quais essa função tem acesso.

Em contraste, o uso de `slice::from_raw_parts_mut` na Listagem 20-7
provavelmente causaria uma falha quando o slice fosse usado. Esse código pega
uma posição arbitrária de memória e cria um slice com 10.000 itens.

<Listing number="20-7" caption="Criando um slice a partir de uma posição arbitrária de memória">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-07/src/main.rs:here}}
```

</Listing>

Não possuímos a memória nessa posição arbitrária, e não há garantia de que o
slice criado por esse código contenha valores `i32` válidos. Tentar usar
`values` como se fosse um slice válido resulta em comportamento indefinido.

#### Usando Funções `extern` para Chamar Código Externo

Às vezes, seu código Rust pode precisar interagir com código escrito em outra
linguagem. Para isso, Rust tem a palavra-chave `extern`, que facilita a criação
e o uso de uma _Foreign Function Interface (FFI)_, uma forma de uma linguagem
de programação definir funções e permitir que uma linguagem de programação
diferente, ou estrangeira, chame essas funções.

A Listagem 20-8 demonstra como configurar uma integração com a função `abs` da
biblioteca padrão de C. Funções declaradas dentro de blocos `extern` geralmente
são unsafe para chamar a partir de código Rust, então blocos `extern` também
devem ser marcados como `unsafe`. A razão é que outras linguagens não aplicam
as regras e garantias de Rust, e Rust não consegue verificá-las; portanto, a
responsabilidade de garantir a segurança recai sobre o programador.

<Listing number="20-8" file-name="src/main.rs" caption="Declarando e chamando uma função `extern` definida em outra linguagem">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-08/src/main.rs}}
```

</Listing>

Dentro do bloco `unsafe extern "C"`, listamos os nomes e assinaturas das
funções externas de outra linguagem que queremos chamar. A parte `"C"` define
qual _application binary interface (ABI)_ a função externa usa: a ABI define
como chamar a função no nível de assembly. A ABI `"C"` é a mais comum e segue a
ABI da linguagem de programação C. Informações sobre todas as ABIs aceitas por
Rust estão disponíveis na [Referência de Rust][ABI].

Todo item declarado dentro de um bloco `unsafe extern` é implicitamente unsafe.
No entanto, algumas funções FFI _são_ seguras para chamar. Por exemplo, a
função `abs` da biblioteca padrão de C não tem nenhuma consideração de
segurança de memória, e sabemos que ela pode ser chamada com qualquer `i32`. Em
casos assim, podemos usar a palavra-chave `safe` para dizer que essa função
específica é segura para chamar, mesmo estando em um bloco `unsafe extern`.
Depois de fazermos essa mudança, chamá-la não exigirá mais um bloco `unsafe`,
como mostrado na Listagem 20-9.

<Listing number="20-9" file-name="src/main.rs" caption="Marcando explicitamente uma função como `safe` dentro de um bloco `unsafe extern` e chamando-a com segurança">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-09/src/main.rs}}
```

</Listing>

Marcar uma função como `safe` não a torna inerentemente segura! Em vez disso, é
como uma promessa que você faz ao Rust de que ela é segura. Ainda é sua
responsabilidade garantir que essa promessa seja cumprida!

#### Chamando Funções Rust a partir de Outras Linguagens

Também podemos usar `extern` para criar uma interface que permite que outras
linguagens chamem funções Rust. Em vez de criar um bloco `extern` inteiro,
adicionamos a palavra-chave `extern` e especificamos a ABI a ser usada logo
antes da palavra-chave `fn` da função relevante. Também precisamos adicionar
uma anotação `#[unsafe(no_mangle)]` para informar ao compilador Rust que ele
não deve modificar o nome dessa função. _Mangling_ acontece quando um
compilador altera o nome que demos a uma função para outro nome que contém mais
informações para outras partes do processo de compilação consumirem, mas que é
menos legível para humanos. Cada compilador de linguagem de programação faz
mangling de nomes de maneira ligeiramente diferente; portanto, para que uma
função Rust possa ser nomeada por outras linguagens, precisamos desabilitar o
name mangling do compilador Rust. Isso é unsafe porque pode haver colisões de
nomes entre bibliotecas sem o mangling integrado, então é nossa
responsabilidade garantir que o nome escolhido seja seguro para exportar sem
mangling.

No exemplo a seguir, tornamos a função `call_from_c` acessível a partir de
código C, depois que ela é compilada em uma biblioteca compartilhada e vinculada
a partir de C:

```
#[unsafe(no_mangle)]
pub extern "C" fn call_from_c() {
    println!("Just called a Rust function from C!");
}
```

Esse uso de `extern` exige `unsafe` apenas no atributo, não no bloco `extern`.

### Acessando ou Modificando uma Variável Estática Mutável

Neste livro, ainda não falamos sobre variáveis globais, que Rust oferece, mas
que podem ser problemáticas com as regras de ownership de Rust. Se duas threads
estiverem acessando a mesma variável global mutável, isso pode causar uma data
race.

Em Rust, variáveis globais são chamadas de variáveis _estáticas_. A Listagem
20-10 mostra um exemplo de declaração e uso de uma variável estática com uma
string slice como valor.

<Listing number="20-10" file-name="src/main.rs" caption="Definindo e usando uma variável estática imutável">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-10/src/main.rs}}
```

</Listing>

Variáveis estáticas são semelhantes a constantes, que discutimos na seção
[“Declarando Constantes”][constants]<!-- ignore --> no Capítulo 3. Por
convenção, os nomes de variáveis estáticas ficam em `SCREAMING_SNAKE_CASE`.
Variáveis estáticas só podem armazenar referências com lifetime `'static`, o
que significa que o compilador Rust consegue descobrir o lifetime e não somos
obrigados a anotá-lo explicitamente. Acessar uma variável estática imutável é
seguro.

Uma diferença sutil entre constantes e variáveis estáticas imutáveis é que os
valores em uma variável estática têm um endereço fixo na memória. Usar o valor
sempre acessará os mesmos dados. Constantes, por outro lado, podem duplicar
seus dados sempre que forem usadas. Outra diferença é que variáveis estáticas
podem ser mutáveis. Acessar e modificar variáveis estáticas mutáveis é
_unsafe_. A Listagem 20-11 mostra como declarar, acessar e modificar uma
variável estática mutável chamada `COUNTER`.

<Listing number="20-11" file-name="src/main.rs" caption="Ler de uma variável estática mutável ou escrever nela é unsafe">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-11/src/main.rs}}
```

</Listing>

Assim como acontece com variáveis normais, especificamos mutabilidade usando a
palavra-chave `mut`. Qualquer código que leia de `COUNTER` ou escreva nele deve
estar dentro de um bloco `unsafe`. O código da Listagem 20-11 compila e imprime
`COUNTER: 3`, como esperaríamos, porque é single-threaded. Fazer várias threads
acessarem `COUNTER` provavelmente resultaria em data races, portanto é
comportamento indefinido. Por isso, precisamos marcar toda a função como
`unsafe` e documentar a limitação de segurança para que qualquer pessoa que
chame a função saiba o que pode e não pode fazer com segurança.

Sempre que escrevemos uma função unsafe, é idiomático escrever um comentário
começando com `SAFETY` e explicando o que o chamador precisa fazer para chamar
a função com segurança. Da mesma forma, sempre que realizamos uma operação
unsafe, é idiomático escrever um comentário começando com `SAFETY` para
explicar como as regras de segurança são mantidas.

Além disso, o compilador negará por padrão qualquer tentativa de criar
referências para uma variável estática mutável por meio de um lint do
compilador. Você precisa abrir mão explicitamente das proteções desse lint
adicionando uma anotação `#[allow(static_mut_refs)]` ou acessar a variável
estática mutável por meio de um raw pointer criado com um dos operadores de raw
borrow. Isso inclui casos em que a referência é criada de forma invisível, como
quando é usada no `println!` nessa listagem de código. Exigir que referências
para variáveis estáticas mutáveis sejam criadas por meio de raw pointers ajuda
a deixar mais óbvios os requisitos de segurança para usá-las.

Com dados mutáveis acessíveis globalmente, é difícil garantir que não haja data
races, e é por isso que Rust considera variáveis estáticas mutáveis unsafe.
Sempre que possível, é preferível usar as técnicas de concorrência e os smart
pointers thread-safe que discutimos no Capítulo 16, para que o compilador
verifique que o acesso aos dados a partir de threads diferentes é feito com
segurança.

### Implementando uma Trait Unsafe

Podemos usar `unsafe` para implementar uma trait unsafe. Uma trait é unsafe
quando pelo menos um de seus métodos tem alguma invariante que o compilador não
consegue verificar. Declaramos que uma trait é `unsafe` adicionando a
palavra-chave `unsafe` antes de `trait` e marcando a implementação da trait
como `unsafe` também, como mostrado na Listagem 20-12.

<Listing number="20-12" caption="Definindo e implementando uma trait unsafe">

```rust
{{#rustdoc_include ../listings/ch20-advanced-features/listing-20-12/src/main.rs:here}}
```

</Listing>

Ao usar `unsafe impl`, prometemos que manteremos as invariantes que o
compilador não consegue verificar.

Como exemplo, lembre-se das traits marcadoras `Send` e `Sync` que discutimos na
seção [“Concorrência Extensível com `Send` e `Sync`”][send-and-sync]<!-- ignore
--> do Capítulo 16: o compilador implementa essas traits automaticamente se
nossos tipos forem compostos inteiramente por outros tipos que implementam
`Send` e `Sync`. Se implementarmos um tipo que contém um tipo que não
implementa `Send` ou `Sync`, como raw pointers, e quisermos marcar esse tipo
como `Send` ou `Sync`, precisamos usar `unsafe`. Rust não consegue verificar se
nosso tipo mantém as garantias de que ele pode ser enviado com segurança entre
threads ou acessado a partir de várias threads; portanto, precisamos fazer
essas verificações manualmente e indicar isso com `unsafe`.

### Acessando Campos de uma Union

A ação final que funciona apenas com `unsafe` é acessar campos de uma union.
Uma _union_ é semelhante a uma `struct`, mas apenas um campo declarado é usado
em uma instância específica por vez. Unions são usadas principalmente para
interagir com unions em código C. Acessar campos de uma union é unsafe porque
Rust não consegue garantir o tipo dos dados atualmente armazenados na instância
da union. Você pode aprender mais sobre unions na [Referência de Rust][unions].

### Usando Miri para Verificar Código Unsafe

Ao escrever código unsafe, você talvez queira verificar se o que escreveu é, de
fato, seguro e correto. Uma das melhores maneiras de fazer isso é usar Miri,
uma ferramenta oficial de Rust para detectar comportamento indefinido. Enquanto
o borrow checker é uma ferramenta _estática_ que funciona em tempo de
compilação, Miri é uma ferramenta _dinâmica_ que funciona em tempo de execução.
Ele verifica seu código executando seu programa, ou sua suíte de testes, e
detectando quando você viola as regras que ele entende sobre como Rust deve
funcionar.

Usar Miri requer uma compilação nightly de Rust (sobre a qual falamos mais no
[Apêndice G: Como Rust é Feito e “Nightly Rust”][nightly]<!-- ignore -->).
Você pode instalar tanto uma versão nightly de Rust quanto a ferramenta Miri
digitando `rustup +nightly component add miri`. Isso não altera a versão de
Rust usada pelo seu projeto; apenas adiciona a ferramenta ao seu sistema para
que você possa usá-la quando quiser. Você pode executar Miri em um projeto
digitando `cargo +nightly miri run` ou `cargo +nightly miri test`.

Para ver um exemplo de como isso pode ser útil, considere o que acontece quando
o executamos contra a Listagem 20-7.

```console
{{#include ../listings/ch20-advanced-features/listing-20-07/output.txt}}
```

Miri nos avisa corretamente que estamos convertendo um inteiro em um ponteiro,
o que pode ser um problema, mas Miri não consegue determinar se existe um
problema porque não sabe como o ponteiro se originou. Então, Miri retorna um
erro onde a Listagem 20-7 tem comportamento indefinido, porque temos um
ponteiro pendente. Graças ao Miri, agora sabemos que há um risco de
comportamento indefinido e podemos pensar em como tornar o código seguro. Em
alguns casos, Miri pode até fazer recomendações sobre como corrigir erros.

Miri não detecta tudo o que você pode fazer de errado ao escrever código
unsafe. Miri é uma ferramenta de análise dinâmica, portanto só detecta
problemas com código que de fato é executado. Isso significa que você precisará
usá-lo em conjunto com boas técnicas de teste para aumentar sua confiança no
código unsafe que escreveu. Miri também não cobre todas as maneiras possíveis
pelas quais seu código pode estar incorreto.

Dito de outra forma: se Miri _detectar_ um problema, você sabe que há um bug,
mas só porque Miri _não_ detecta um bug não significa que não haja problema.
Ainda assim, ele consegue detectar muita coisa. Experimente executá-lo nos
outros exemplos de código unsafe deste capítulo e veja o que ele diz!

Você pode aprender mais sobre Miri em [seu repositório no GitHub][miri].

<!-- Old headings. Do not remove or links may break. -->

<a id="when-to-use-unsafe-code"></a>

### Usando Código Unsafe Corretamente

Usar `unsafe` para acessar um dos cinco superpoderes que acabamos de discutir
não é errado nem mesmo malvisto, mas é mais difícil escrever código `unsafe`
corretamente porque o compilador não consegue ajudar a manter a segurança de
memória. Quando você tiver um motivo para usar código `unsafe`, pode fazê-lo, e
ter a anotação `unsafe` explícita facilita rastrear a origem dos problemas
quando eles ocorrerem. Sempre que escrever código unsafe, você pode usar Miri
para ajudar a ter mais confiança de que o código escrito mantém as regras de
Rust.

Para uma exploração muito mais profunda de como trabalhar de forma eficaz com
unsafe Rust, leia o guia oficial de Rust para `unsafe`, [The Rustonomicon][nomicon].

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

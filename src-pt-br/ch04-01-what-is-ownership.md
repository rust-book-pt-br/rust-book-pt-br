## O que é Ownership?

_Ownership_ é um conjunto de regras que governa como um programa Rust gerencia
a memória. Todo programa precisa gerenciar a forma como usa a memória do
computador durante a execução. Algumas linguagens têm garbage collection, que
procura regularmente por memória não utilizada enquanto o programa roda; em
outras, a pessoa programadora precisa alocar e liberar memória explicitamente.
Rust usa uma terceira abordagem: a memória é gerenciada por meio de um sistema
de ownership com um conjunto de regras verificadas pelo compilador. Se alguma
delas for violada, o programa não compila. Nenhum dos recursos de ownership
torna seu programa mais lento em tempo de execução.

Como ownership é um conceito novo para muita gente, leva algum tempo para se
acostumar. A boa notícia é que, quanto mais experiência você adquire com Rust e
com as regras do sistema de ownership, mais natural se torna escrever código
seguro e eficiente. Continue firme!

Ao entender ownership, você terá uma base sólida para compreender os recursos
que tornam o Rust único. Neste capítulo, aprenderemos ownership trabalhando com
alguns exemplos que se concentram em uma estrutura de dados muito comum:
strings.

> ### A pilha e o heap
>
> Muitas linguagens de programação não exigem que você pense na pilha e no
> heap com muita frequência. Mas, em uma linguagem de programação de sistemas
> como Rust, o fato de um valor estar na pilha ou no heap afeta a forma como a
> linguagem se comporta e por que você precisa tomar certas decisões. Partes de
> ownership serão explicadas mais adiante neste capítulo em relação à pilha e
> ao heap, então aqui vai uma explicação breve para preparar o terreno.
>
> Tanto a pilha quanto o heap são regiões de memória disponíveis para o código
> em tempo de execução, mas são organizadas de formas diferentes. A pilha
> armazena valores na ordem em que eles chegam e os remove na ordem inversa.
> Isso é chamado de _último a entrar, primeiro a sair (LIFO)_. Pense em uma
> pilha de pratos: ao adicionar mais pratos, você os coloca no topo; quando
> precisa de um, tira o prato do topo. Adicionar ou remover pratos do meio ou
> da base não funcionaria tão bem. Adicionar dados recebe o nome de _pushing
> onto the stack_, e remover dados é _popping off the stack_. Todos os dados
> armazenados na pilha precisam ter tamanho fixo e conhecido. Dados com tamanho
> desconhecido em tempo de compilação, ou cujo tamanho pode mudar, precisam ir
> para o heap.
>
> O heap é menos organizado: quando você coloca dados no heap, precisa pedir
> uma certa quantidade de espaço. O alocador de memória encontra um espaço livre
> no heap que seja grande o bastante, marca esse espaço como ocupado e retorna
> um _ponteiro_, isto é, o endereço daquela região. Esse processo é chamado de
> _allocating on the heap_ e às vezes é abreviado apenas para _allocating_.
> Como o ponteiro para o heap tem tamanho fixo e conhecido, podemos armazená-lo
> na pilha; mas, para acessar os dados em si, é preciso seguir o ponteiro.
> Pense em um restaurante: ao chegar, você diz quantas pessoas há no seu grupo,
> e a pessoa na recepção encontra uma mesa que acomoda todo mundo e leva vocês
> até lá. Se alguém chegar atrasado, essa pessoa pode perguntar onde vocês se
> sentaram para encontrar o grupo.
>
> Colocar dados na pilha é mais rápido do que alocar no heap porque o alocador
> nunca precisa procurar um lugar para armazenar novos dados: esse lugar está
> sempre no topo da pilha. Já alocar espaço no heap exige mais trabalho porque
> o alocador primeiro precisa encontrar uma região grande o suficiente para
> comportar os dados e depois fazer a contabilidade necessária para a próxima
> alocação.
>
> Acessar dados no heap geralmente é mais lento do que acessar dados na pilha,
> porque é preciso seguir um ponteiro para chegar até eles. Processadores
> modernos costumam ser mais rápidos quando precisam se mover menos pela
> memória. Continuando a analogia, pense em uma pessoa atendendo mesas em um
> restaurante. É mais eficiente pegar todos os pedidos de uma mesa antes de ir
> para a seguinte. Pegar um pedido da mesa A, depois um da mesa B, depois
> voltar à A e então novamente à B seria bem mais lento. Pelo mesmo motivo, um
> processador tende a trabalhar melhor com dados próximos uns dos outros, como
> ocorre na pilha, em vez de dados mais espalhados, como pode acontecer no
> heap.
>
> Quando seu código chama uma função, os valores passados ​​para a função
> (incluindo, potencialmente, ponteiros para dados no heap) e a função
> variáveis ​​locais são colocadas na pilha. Quando a função terminar, aqueles
> os valores são retirados da pilha.
>
> Acompanhar quais partes do código estão usando quais dados no heap,
> minimizar a quantidade de dados duplicados no heap e limpar dados que já não
> são mais necessários para que você não fique sem memória são problemas que
> ownership resolve. Depois que você entender ownership, não precisará pensar
> na pilha e no heap com tanta frequência. Mas saber que o objetivo principal
> de ownership é gerenciar dados no heap ajuda a entender por que ele funciona
> da forma como funciona.

### Regras de Ownership

Primeiro, vamos olhar para as regras de ownership. Tenha essas regras em mente
enquanto passamos pelos exemplos que as ilustram:

- Cada valor em Rust possui um _proprietário_.
- Só pode haver um proprietário por vez.
- Quando o proprietário sai do escopo, o valor será eliminado.

### Escopo de Variáveis

Agora que ultrapassamos a sintaxe básica do Rust, não incluiremos todos os `fn main() {`
código nos exemplos, então se você estiver acompanhando, certifique-se de colocar o
seguintes exemplos dentro de uma função `main` manualmente. Como resultado, nossos exemplos
será um pouco mais conciso, permitindo-nos focar nos detalhes reais em vez de
código padrão.

Como primeiro exemplo de ownership, vamos observar o escopo de algumas
variáveis. Um _escopo_ é o intervalo dentro de um programa durante o qual um
item é válido. Considere a variável a seguir:

```rust
let s = "hello";
```

A variável `s` se refere a uma string literal, cujo valor está codificado no
texto do próprio programa. A variável é válida a partir do ponto em que é
declarada até o fim do escopo atual. A Listagem 4-1 mostra um programa com
comentários anotando onde a variável `s` seria válida.

<Listing number="4-1" caption="Uma variável e o escopo em que ela é válida">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-01/src/main.rs:here}}
```

</Listing>

Em outras palavras, existem dois pontos importantes no tempo aqui:

- Quando `s` entra _no_ escopo, é válido.
- Ela permanece válida até sair _de_ escopo.

Neste ponto, a relação entre escopos e validade de variáveis é semelhante à de
outras linguagens de programação. Agora vamos aprofundar essa ideia
introduzindo o tipo `String`.

### O Tipo `String`

Para ilustrar as regras de ownership, precisamos de um tipo de dado mais
complexo do que aqueles que cobrimos na seção [“Tipos de
Dados”][data-types]<!-- ignore --> do Capítulo 3. Os tipos vistos até agora têm
tamanho conhecido, podem ser armazenados na pilha e removidos dela quando o
escopo termina, e podem ser copiados de maneira rápida e trivial para criar
uma nova instância independente quando outra parte do código precisar usar o
mesmo valor em outro escopo. Mas agora queremos olhar para dados armazenados no
heap e explorar como o Rust sabe quando deve limpá-los, e o tipo `String` é um
ótimo exemplo.

Vamos nos concentrar nas partes de `String` relacionadas a ownership. Esses
mesmos aspectos também se aplicam a outros tipos de dados complexos, sejam eles
fornecidos pela biblioteca padrão ou criados por você. Falaremos dos aspectos
de `String` que não envolvem ownership no [Capítulo 8][ch8]<!-- ignore -->.

Já vimos literais de string, nas quais o valor da string fica codificado no
programa. Literais de string são convenientes, mas não servem para toda
situação em que podemos querer usar texto. Uma razão é que elas são
imutáveis. Outra é que nem todo valor de string pode ser conhecido quando
escrevemos o código: e se quisermos, por exemplo, ler a entrada do usuário e
armazená-la? Para esse tipo de situação, Rust oferece o tipo `String`. Esse
tipo gerencia dados alocados no heap e, por isso, consegue armazenar uma
quantidade de texto desconhecida em tempo de compilação. Podemos criar um
`String` a partir de uma string literal usando a função `from`:

```rust
let s = String::from("hello");
```

O operador de dois pontos duplos `::` nos permite nomear essa função `from`
específica sob o tipo `String`, em vez de usar algum nome como `string_from`.
Falaremos mais sobre essa sintaxe na seção [“Métodos”][methods]<!--
ignore -->
do Capítulo 5 e, quando tratarmos de namespace com módulos, em [“Caminhos para
Referenciar um Item na Árvore de Módulos”][paths-module-tree]<!-- ignore --> no
Capítulo 7.

Esse tipo de string _pode_ ser mutado:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-01-can-mutate-string/src/main.rs:here}}
```

Então, qual é a diferença aqui? Por que `String` pode sofrer mutação, mas
literais não? A diferença está na forma como esses dois tipos lidam com a
memória.

### Memória e Alocação

No caso de uma string literal, conhecemos o conteúdo em tempo de compilação, e
por isso o texto é gravado diretamente no executável final. É isso que torna
string literals rápidas e eficientes. Mas essas propriedades vêm justamente da
imutabilidade da string literal. Infelizmente, não podemos colocar um bloco de
memória no binário para cada pedaço de texto cujo tamanho é desconhecido em
tempo de compilação e que pode mudar enquanto o programa roda.

Com o tipo `String`, para suportar um trecho de texto mutável e que possa
crescer, precisamos alocar no heap uma quantidade de memória desconhecida em
tempo de compilação para armazenar o conteúdo. Isso significa:

- A memória precisa ser solicitada ao alocador em tempo de execução.
- Precisamos de uma forma de devolver essa memória ao alocador quando
  terminarmos de usar nossa `String`.

Essa primeira parte é feita por nós: quando chamamos `String::from`, a
implementação solicita a memória necessária. Isso é praticamente universal em
linguagens de programação.

No entanto, a segunda parte é diferente. Em linguagens com um _garbage
collector (GC)_, o GC acompanha e limpa a memória que não está mais em uso, e
não precisamos pensar nisso. Na maioria das linguagens sem GC, é nossa
responsabilidade identificar quando a memória deixou de ser usada e chamar
código para liberá-la explicitamente, assim como fizemos para solicitá-la.
Fazer isso corretamente foi historicamente um problema difícil de programação.
Se esquecermos, desperdiçaremos memória. Se fizermos isso cedo demais, teremos
uma variável inválida. Se fizermos isso duas vezes, também é um bug.
Precisamos emparelhar exatamente um `allocate` com exatamente um `free`.

O Rust segue um caminho diferente: a memória é devolvida automaticamente assim
que a variável que a possui sai de escopo. Esta é uma versão do nosso exemplo
de escopo da Listagem 4-1 usando uma `String` em vez de uma string literal:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-02-string-scope/src/main.rs:here}}
```

Existe um ponto natural em que podemos devolver ao alocador a memória da qual
nossa `String` precisa: quando `s` sai de escopo. Quando uma variável sai de
escopo, o Rust chama uma função especial para nós. Essa função se chama
`drop`, e é nela que o autor de `String` pode colocar o código que devolve a
memória. O Rust chama `drop` automaticamente ao encontrar a chave de
fechamento.

> Nota: em C++, esse padrão de desalocar recursos ao final da vida útil de um
> item às vezes é chamado de _Resource Acquisition Is Initialization (RAII)_.
> A função `drop` do Rust será familiar para você se já usou padrões RAII.

Esse padrão tem um impacto profundo na forma como código Rust é escrito. Ele
pode parecer simples agora, mas o comportamento do código pode ser inesperado
em situações mais complicadas, quando queremos que múltiplas variáveis usem os
dados que alocamos no heap. Vamos explorar algumas dessas situações agora.

<!-- Old headings. Do not remove or links may break. -->

<a id="ways-variables-and-data-interact-move"></a>

#### Variáveis e Dados Interagindo com `move`

Múltiplas variáveis podem interagir com os mesmos dados de maneiras diferentes
no Rust. A Listagem 4-2 mostra um exemplo usando um inteiro.

<Listing number="4-2" caption="Atribuindo o valor inteiro da variável `x` a `y`">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-02/src/main.rs:here}}
```

</Listing>

Provavelmente conseguimos adivinhar o que isso faz: “Associe o valor `5` a `x`;
depois, faça uma cópia do valor em `x` e associe-a a `y`.” Agora temos duas
variáveis, `x` e `y`, e ambas são iguais a `5`. É exatamente isso que está
acontecendo, porque inteiros são valores simples com tamanho fixo e conhecido,
e esses dois valores `5` são empilhados na pilha.

Agora vamos dar uma olhada na versão `String`:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-03-string-move/src/main.rs:here}}
```

Isso parece muito semelhante, então podemos supor que funcione do mesmo jeito:
isto é, que a segunda linha faria uma cópia do valor em `s1` e a associaria a
`s2`. Mas não é bem isso que acontece.

Dê uma olhada na Figura 4-1 para ver o que está acontecendo “por baixo dos
panos” com `String`. Uma `String` é composta de três partes, mostradas à
esquerda: um ponteiro para a memória que contém o conteúdo da string, um
comprimento e uma capacidade. Esse conjunto de dados é armazenado na pilha. À
direita está a memória no heap que contém o conteúdo.

<img alt="Duas tabelas: a primeira tabela contém a representação de s1 na
pilha, consistindo em seu comprimento (5), capacidade (5) e um ponteiro para o
primeiro valor da segunda tabela. A segunda tabela contém a representação dos
dados de string no heap, byte a byte." src="img/trpl04-01.svg" class="center"
style="width: 50%;" />

<span class="caption">Figura 4-1: A representação na memória de um `String`
mantendo o valor `"hello"` vinculado a `s1`</span>

O comprimento é a quantidade de memória, em bytes, que o conteúdo de `String`
está usando no momento. A capacidade é a quantidade total de memória, em
bytes, que a `String` recebeu do alocador. A diferença entre comprimento e
capacidade é importante, mas não neste contexto, então por enquanto podemos
ignorar a capacidade.

Quando atribuímos `s1` a `s2`, os dados de `String` são copiados, o que
significa que copiamos o ponteiro, o comprimento e a capacidade que estão na
pilha. Não copiamos os dados no heap para os quais o ponteiro aponta. Em
outras palavras, a representação na memória fica como na Figura 4-2.

<img alt="Três tabelas: as tabelas s1 e s2 representam essas strings na
pilha, respectivamente, e ambas apontam para os mesmos dados de string no
heap." src="img/trpl04-02.svg" class="center" style="width: 50%;" />

<span class="caption">Figura 4-2: A representação na memória da variável
`s2` que possui uma cópia do ponteiro, comprimento e capacidade de `s1`</span>

A representação _não_ se parece com a Figura 4-3, que mostra como a memória
ficaria se o Rust também copiasse os dados do heap. Se o Rust fizesse isso, a
operação `s2 = s1` poderia ser muito cara em tempo de execução caso os dados no
heap fossem grandes.

<img alt="Quatro tabelas: duas tabelas representam os dados da pilha para s1 e
s2, e cada uma aponta para sua própria cópia dos dados da string no heap."
src="img/trpl04-03.svg" class="center" style="width: 50%;" />

<span class="caption">Figura 4-3: Outra possibilidade para o que `s2 = s1`
poderia fazer se o Rust também copiasse os dados do heap</span>

Anteriormente, dissemos que, quando uma variável sai de escopo, o Rust chama
automaticamente a função `drop` e limpa a memória no heap daquela variável.
Mas a Figura 4-2 mostra os dois ponteiros de dados apontando para o mesmo
local. Isso é um problema: quando `s2` e `s1` saírem de escopo, ambas tentarão
liberar a mesma memória. Isso é conhecido como erro de _double free_ e é um
dos bugs de segurança de memória que mencionamos antes. Liberar memória duas
vezes pode levar à corrupção de memória, o que potencialmente abre espaço para
vulnerabilidades de segurança.

Para garantir a segurança de memória, depois da linha `let s2 = s1;`, o Rust
considera `s1` como não mais válida. Portanto, o Rust não precisa liberar nada
quando `s1` sair de escopo. Veja o que acontece quando você tenta usar `s1`
depois que `s2` é criada; isso não funciona:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-04-cant-use-after-move/src/main.rs:here}}
```

Você receberá um erro como este porque o Rust impede que você use a referência
invalidada:

```console
{{#include ../listings/ch04-understanding-ownership/no-listing-04-cant-use-after-move/output.txt}}
```

Se você já ouviu os termos _cópia superficial_ e _cópia profunda_ enquanto trabalhava com
outras linguagens, o conceito de copiar o ponteiro, comprimento e capacidade
sem copiar os dados provavelmente parece fazer uma cópia superficial. Mas
porque Rust também invalida a primeira variável, em vez de ser chamada de
cópia superficial, é conhecida como _move_. Neste exemplo, diríamos que `s1`
foi _movido_ para `s2`. Então, o que realmente acontece é mostrado na Figura 4-4.

<img alt="Três tabelas: tabelas s1 e s2 representando essas strings no
pilha, respectivamente, e ambos apontando para os mesmos dados de string no heap.
A tabela s1 está esmaecida porque s1 não é mais válida; apenas s2 pode ser usado para
acesse os dados do heap." src="img/trpl04-04.svg" class="center" style="width:
50%;" />

<span class="caption">Figura 4-4: A representação na memória após `s1` ter
sido invalidada</span>

Isso resolve nosso problema! Com apenas `s2` válida, quando ela sair de
escopo, sozinha liberará a memória, e pronto.

Além disso, há uma escolha de design implícita aqui: o Rust nunca cria
automaticamente cópias "profundas" de seus dados. Portanto, qualquer cópia
_automática_ pode ser considerada barata em termos de desempenho em tempo de
execução.

#### Escopo e Atribuição

O oposto também vale para a relação entre escopo, ownership e a liberação de
memória por meio da função `drop`. Quando você atribui um valor totalmente novo
a uma variável existente, o Rust chama `drop` e libera imediatamente a memória
do valor original. Considere este código, por exemplo:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-04b-replacement-drop/src/main.rs:here}}
```

Inicialmente declaramos uma variável `s` e a associamos a uma `String` com o
valor `"hello"`. Em seguida, criamos imediatamente uma nova `String` com o
valor `"ahoy"` e a atribuímos a `s`. Nesse ponto, nada mais se refere ao valor
original no heap. A Figura 4-5 ilustra os dados da pilha e do heap nesse
momento:

<img alt="Uma tabela representando o valor da string na pilha, apontando para
o segundo bloco de dados de string (ahoy) no heap, com os dados originais
(hello) esmaecidos porque não podem mais ser acessados."
src="img/trpl04-05.svg" class="center" style="width: 50%;" />

<span class="caption">Figura 4-5: A representação na memória depois que o
valor inicial foi completamente substituído</span>

A string original sai imediatamente de escopo. O Rust executará `drop` sobre
ela, e sua memória será liberada imediatamente. Quando imprimirmos o valor no
fim, ele será `"ahoy, world!"`.

<!-- Old headings. Do not remove or links may break. -->

<a id="ways-variables-and-data-interact-clone"></a>

#### Variáveis e Dados Interagindo com `clone`

Se _quisermos_ copiar profundamente os dados no heap de uma `String`, e não
apenas os dados na pilha, podemos usar um método comum chamado `clone`.
Falaremos sobre a sintaxe de métodos no Capítulo 5, mas, como esse é um
recurso comum em muitas linguagens de programação, é provável que você já os
tenha visto antes.

Aqui está um exemplo do método `clone` em ação:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-05-clone/src/main.rs:here}}
```

Isso funciona muito bem e produz explicitamente o comportamento mostrado na
Figura 4-3, em que os dados no heap _de fato_ são copiados.

Quando você vê uma chamada para `clone`, você sabe que algum código arbitrário está sendo
executado e esse código pode ser caro. É um indicador visual de que algo
diferente está acontecendo.

#### Dados Somente de Pilha: `Copy`

Há outro detalhe sobre o qual ainda não falamos. Este código usando inteiros,
parte do qual foi mostrado na Listagem 4-2, funciona e é válido:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-06-copy/src/main.rs:here}}
```

Mas esse código parece contradizer o que acabamos de aprender: não temos uma
chamada para `clone`, mas `x` ainda é válido e não foi movido para `y`.

A razão é que tipos como números inteiros, que têm um tamanho conhecido em
tempo de compilação, são armazenados inteiramente na pilha; por isso, copiar
seus valores é rápido. Isso significa que não há motivo para impedir que `x`
continue válido depois que criamos a variável `y`. Em outras palavras, aqui
não há diferença entre cópia profunda e cópia superficial, então chamar
`clone` não faria nada diferente da cópia superficial usual, e podemos omiti-lo.

O Rust tem uma anotação especial chamada trait `Copy` que podemos usar em
tipos armazenados na pilha, como os inteiros. Falaremos mais sobre traits no
[Capítulo 10][traits]<!-- ignore -->. Se um tipo implementa a trait `Copy`,
as variáveis que o usam não são movidas; em vez disso, são copiadas de forma
simples, continuando válidas após a atribuição a outra variável.

O Rust não nos permitirá anotar um tipo com `Copy` se esse tipo, ou qualquer
uma de suas partes, implementar a trait `Drop`. Se o tipo precisar que algo
especial aconteça quando o valor sair de escopo e adicionarmos a anotação
`Copy` a esse tipo, receberemos um erro em tempo de compilação. Para saber
como adicionar a anotação `Copy` ao seu tipo para implementar essa trait,
consulte [“Derivable Traits”][derivable-traits]<!-- ignore --> no Apêndice C.

Então, quais tipos implementam a trait `Copy`? Você pode verificar a
documentação do tipo em questão para ter certeza, mas, como regra geral,
qualquer grupo de valores escalares simples pode implementar `Copy`, e nada
que exija alocação ou represente algum tipo de recurso pode implementar
`Copy`. Estes são alguns dos tipos que implementam `Copy`:

- Todos os tipos inteiros, como `u32`.
- O tipo booleano, `bool`, com valores `true` e `false`.
- Todos os tipos de ponto flutuante, como `f64`.
- O tipo de caractere, `char`.
- Tuplas, se contiverem apenas tipos que também implementem `Copy`. Por exemplo,
`(i32, i32)` implementa `Copy`, mas `(i32, String)` não.

### Ownership e Funções

A mecânica de passar um valor para uma função é semelhante à de atribuí-lo a
uma variável. Passar uma variável para uma função move ou copia esse valor,
assim como acontece em uma atribuição. A Listagem 4-3 traz um exemplo com
algumas anotações mostrando onde as variáveis entram e saem de escopo.

<Listing number="4-3" file-name="src/main.rs" caption="Funções com ownership e escopo anotados">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-03/src/main.rs}}
```

</Listing>

Se tentássemos usar `s` após a chamada para `takes_ownership`, Rust lançaria um
erro em tempo de compilação. Essas verificações estáticas nos protegem de erros. Tente adicionar
código para `main` que usa `s` e `x` para ver onde você pode usá-los e onde
as regras de ownership impedem que você faça isso.

### Valores de retorno e escopo

A devolução de valores também pode transferir ownership. A Listagem 4-4 mostra
um exemplo de função que retorna algum valor, com anotações semelhantes às da
Listagem 4-3.

<Listing number="4-4" file-name="src/main.rs" caption="Transferindo ownership de valores de retorno">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-04/src/main.rs}}
```

</Listing>

O ownership de uma variável sempre segue o mesmo padrão: atribuir um valor a
outra variável o move. Quando uma variável que inclui dados no heap sai de
escopo, o valor é limpo por `drop`, a menos que o ownership desses dados tenha
sido movido para outra variável.

Embora isso funcione, assumir ownership e depois devolvê-lo a cada função é um
pouco tedioso. E se quisermos deixar uma função usar um valor, mas não assumir
ownership? É muito chato que tudo o que passamos também precise
ser repassado se quisermos usá-lo novamente, além de quaisquer dados resultantes
do corpo da função que também podemos querer retornar.

O Rust nos permite retornar vários valores usando uma tupla, como mostrado na
Listagem 4-5.

<Listing number="4-5" file-name="src/main.rs" caption="Retornando ownership de parâmetros">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-05/src/main.rs}}
```

</Listing>

Mas isso é muita cerimônia e trabalho para um conceito que deveria ser comum.
Felizmente, o Rust tem um recurso para usar um valor sem transferir ownership:
referências.

[data-types]: ch03-02-data-types.html#data-types
[ch8]: ch08-02-strings.html
[traits]: ch10-02-traits.html
[derivable-traits]: appendix-03-derivable-traits.html
[methods]: ch05-03-method-syntax.html#methods
[paths-module-tree]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html

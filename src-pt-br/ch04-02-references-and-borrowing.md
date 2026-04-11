## Referências e empréstimos

O problema com o código da tupla na Listagem 4-5 é que temos que retornar o
`String` à função de chamada para que ainda possamos usar `String` depois
a chamada para `calculate_length`, porque `String` foi movido para
`calculate_length`. Em vez disso, podemos fornecer uma referência ao valor `String`.
Uma referência é como um ponteiro, pois é um endereço que podemos seguir para acessar
os dados armazenados nesse endereço; esses dados pertencem a alguma outra variável.
Ao contrário de um ponteiro, é garantido que uma referência aponte para um valor válido de um
tipo particular durante a vida dessa referência.

Aqui está como você definiria e usaria uma função `calculate_length` que possui um
referência a um objeto como parâmetro em vez de apropriar-se do valor:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-07-reference/src/main.rs:all}}
```

</Listing>

Primeiro, observe que todo o código da tupla na declaração da variável e o
o valor de retorno da função desapareceu. Segundo, observe que passamos `&s1` para
`calculate_length` e, em sua definição, tomamos `&String` em vez de
`String`. Esses e comercial representam referências e permitem que você faça referência a
algum valor sem se apropriar dele. A Figura 4-6 ilustra esse conceito.

<img alt="Três tabelas: a tabela para s contém apenas um ponteiro para a tabela
para s1. A tabela para s1 contém os dados da pilha para s1 e aponta para o
dados de string no heap." src="img/trpl04-06.svg" class="center" />

<span class="caption">Figura 4-6: Um diagrama de `&String` `s` apontando para
`String` `s1`</span>

> Nota: O oposto de referenciar usando `&` é _dereferência_, que é
> realizado com o operador de desreferência, `*`. Veremos alguns usos do
> operador de desreferência no Capítulo 8 e discutir detalhes de desreferência no
> Capítulo 15.

Vamos dar uma olhada mais de perto na chamada de função aqui:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-07-reference/src/main.rs:here}}
```

A sintaxe `&s1` nos permite criar uma referência que _refere_ ao valor de `s1`
mas não o possui. Como a referência não a possui, o valor que ela aponta
to não será descartado quando a referência parar de ser usada.

Da mesma forma, a assinatura da função usa `&` para indicar que o tipo de
o parâmetro `s` é uma referência. Vamos adicionar algumas anotações explicativas:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-08-reference-with-annotations/src/main.rs:here}}
```

O escopo em que a variável `s` é válida é o mesmo de qualquer função
escopo do parâmetro, mas o valor apontado pela referência não é descartado
quando `s` deixa de ser usado, porque `s` não tem propriedade. Quando funções
tiver referências como parâmetros em vez dos valores reais, não precisaremos
devolver os valores para devolver a propriedade, porque nunca tivemos
propriedade.

Chamamos a ação de criar uma referência de _empréstimo_. Como na vida real, se um
pessoa possui algo, você pode pedir emprestado a ela. Quando terminar, você tem
para devolvê-lo. Você não é o dono disso.

Então, o que acontece se tentarmos modificar algo que pegamos emprestado? Experimente o código em
Listagem 4-6. Alerta de spoiler: não funciona!

<Listing number="4-6" file-name="src/main.rs" caption="Attempting to modify a borrowed value">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-06/src/main.rs}}
```

</Listing>

Aqui está o erro:

```console
{{#include ../listings/ch04-understanding-ownership/listing-04-06/output.txt}}
```

Assim como as variáveis ​​são imutáveis ​​por padrão, as referências também o são. Nós não estamos
permitido modificar algo ao qual temos uma referência.

### Referências mutáveis

Podemos corrigir o código da Listagem 4-6 para nos permitir modificar um valor emprestado
com apenas alguns pequenos ajustes que usam, em vez disso, uma _referência mutável_:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-09-fixes-listing-04-06/src/main.rs}}
```

</Listing>

Primeiro, mudamos `s` para `mut`. Então, criamos uma referência mutável com
`&mut s` onde chamamos a função `change` e atualizamos a assinatura da função
para aceitar uma referência mutável com `some_string: &mut String`. Isso faz com que
muito claro que a função `change` irá alterar o valor que ela empresta.

As referências mutáveis ​​têm uma grande restrição: se você tiver uma referência mutável para
um valor, você não poderá ter outras referências a esse valor. Esse código que
tentativas de criar duas referências mutáveis ​​para `s` falharão:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-10-multiple-mut-not-allowed/src/main.rs:here}}
```

</Listing>

Aqui está o erro:

```console
{{#include ../listings/ch04-understanding-ownership/no-listing-10-multiple-mut-not-allowed/output.txt}}
```

Este erro diz que este código é inválido porque não podemos emprestar `s` como
mutável mais de uma vez por vez. O primeiro empréstimo mutável está em `r1` e deve
dura até ser usado no `println!`, mas entre a criação desse
referência mutável e seu uso, tentamos criar outra referência mutável
em `r2` que empresta os mesmos dados que `r1`.

A restrição que impede múltiplas referências mutáveis ​​aos mesmos dados no
ao mesmo tempo permite a mutação, mas de uma forma muito controlada. É algo
que os novos Rustáceos enfrentam porque a maioria das línguas permite que você sofra mutação
sempre que quiser. A vantagem de ter essa restrição é que o Rust pode
evitar corridas de dados em tempo de compilação. Uma _corrida de dados_ é semelhante a uma corrida
condição e acontece quando estes três comportamentos ocorrem:

- Dois ou mais ponteiros acessam os mesmos dados ao mesmo tempo.
- Pelo menos um dos ponteiros está sendo usado para gravar nos dados.
- Não há nenhum mecanismo sendo usado para sincronizar o acesso aos dados.

Corridas de dados causam comportamento indefinido e podem ser difíceis de diagnosticar e corrigir
quando você está tentando rastreá-los em tempo de execução; A ferrugem evita esse problema ao
recusando-se a compilar código com corridas de dados!

Como sempre, podemos usar chaves para criar um novo escopo, permitindo
múltiplas referências mutáveis, mas não _simultâneas_:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-11-muts-in-separate-scopes/src/main.rs:here}}
```

Rust impõe uma regra semelhante para combinar referências mutáveis ​​e imutáveis.
Este código resulta em um erro:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-12-immutable-and-mutable-not-allowed/src/main.rs:here}}
```

Aqui está o erro:

```console
{{#include ../listings/ch04-understanding-ownership/no-listing-12-immutable-and-mutable-not-allowed/output.txt}}
```

Uau! _Também_ não podemos ter uma referência mutável enquanto tivermos uma imutável
para o mesmo valor.

Os usuários de uma referência imutável não esperam que o valor mude repentinamente
debaixo deles! No entanto, múltiplas referências imutáveis ​​são permitidas porque nenhuma
aquele que está apenas lendo os dados tem a capacidade de afetar a vida de qualquer outra pessoa.
leitura dos dados.

Observe que o escopo de uma referência começa onde ela é introduzida e continua
até a última vez que essa referência foi usada. Por exemplo, este código irá
compilar porque o último uso das referências imutáveis ​​está em `println!`,
antes da referência mutável ser introduzida:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-13-reference-scope-ends/src/main.rs:here}}
```

Os escopos das referências imutáveis ​​`r1` e `r2` terminam após `println!`
onde eles foram usados ​​pela última vez, que é antes da referência mutável `r3` ser
criado. Esses escopos não se sobrepõem, então este código é permitido: O compilador pode
dizer que a referência não está mais sendo usada em um ponto antes do final do
o escopo.

Mesmo que os erros de empréstimo possam às vezes ser frustrantes, lembre-se de que é
o compilador Rust apontando um bug potencial antecipadamente (em tempo de compilação, em vez
do que em tempo de execução) e mostrando exatamente onde está o problema. Então, você não
você precisa descobrir por que seus dados não são o que você pensava.

### Referências pendentes

Em linguagens com ponteiros, é fácil criar erroneamente um _dangling
pointer_ — um ponteiro que faz referência a um local na memória que pode ter sido
dado a outra pessoa - liberando um pouco de memória enquanto preserva um ponteiro para aquele
memória. Em Rust, por outro lado, o compilador garante que as referências serão
nunca fique com referências pendentes: se você tiver uma referência a alguns dados, o
compilador garantirá que os dados não sairão do escopo antes do
referência aos dados sim.

Vamos tentar criar uma referência pendente para ver como o Rust os impede com um
erro em tempo de compilação:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-14-dangling-reference/src/main.rs}}
```

</Listing>

Aqui está o erro:

```console
{{#include ../listings/ch04-understanding-ownership/no-listing-14-dangling-reference/output.txt}}
```

Esta mensagem de erro refere-se a um recurso que ainda não abordamos: tempos de vida. Bem
discutiremos os tempos de vida em detalhes no Capítulo 10. Mas, se você desconsiderar as partes
sobre tempos de vida, a mensagem contém a chave do motivo pelo qual esse código é um problema:

```text
this function's return type contains a borrowed value, but there is no value
for it to be borrowed from
```

Vamos dar uma olhada mais de perto no que exatamente está acontecendo em cada estágio do nosso
`dangle` código:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-15-dangling-reference-annotated/src/main.rs:here}}
```

</Listing>

Como `s` é criado dentro de `dangle`, quando o código de `dangle` for concluído,
`s` será desalocado. Mas tentamos retornar uma referência a ele. Isso significa
esta referência estaria apontando para um `String` inválido. Isso não é bom! Ferrugem
não nos deixará fazer isso.

A solução aqui é retornar `String` diretamente:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-16-no-dangle/src/main.rs:here}}
```

Isso funciona sem problemas. A propriedade é transferida e nada é
desalocado.

### As regras de referências

Vamos recapitular o que discutimos sobre referências:

- A qualquer momento, você pode ter _ou_ uma referência mutável _ou_ qualquer
número de referências imutáveis.
- As referências devem ser sempre válidas.

A seguir, veremos um tipo diferente de referência: fatias.

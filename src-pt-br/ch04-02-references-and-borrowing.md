## Referências e Empréstimos

O problema com o código com a tupla da Listagem 4-5 é que precisamos retornar
a `String` para a função chamadora para que ainda possamos usá-la depois da
chamada para `calculate_length`, porque a `String` foi movida para dentro de
`calculate_length`. Em vez disso, podemos fornecer uma referência ao valor
`String`. Uma referência é parecida com um ponteiro no sentido de que é um
endereço que podemos seguir para acessar os dados armazenados naquele local;
esses dados pertencem a alguma outra variável. Diferentemente de um ponteiro,
uma referência tem a garantia de apontar para um valor válido de um tipo
específico durante toda a vida dessa referência.

Veja como você definiria e usaria uma função `calculate_length` que recebe como
parâmetro uma referência a um objeto, em vez de assumir o ownership do valor:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-07-reference/src/main.rs:all}}
```

</Listing>

Primeiro, repare que todo o código envolvendo a tupla na declaração da variável
e no valor de retorno da função desapareceu. Segundo, observe que passamos
`&s1` para `calculate_length` e que, na definição da função, recebemos
`&String` em vez de `String`. Esses e comerciais (`&`) representam
referências, e elas permitem que você se refira a algum valor sem assumir seu
ownership. A Figura 4-6 ilustra esse conceito.

<img alt="Three tables: the table for s contains only a pointer to the table
for s1. The table for s1 contains the stack data for s1 and points to the
string data on the heap." src="img/trpl04-06.svg" class="center" />

<span class="caption">Figura 4-6: Um diagrama de `&String` `s` apontando para
`String` `s1`</span>

> Observação: o oposto de referenciar usando `&` é _desreferenciar_, o que é
> feito com o operador de desreferência, `*`. Veremos alguns usos do operador
> de desreferência no Capítulo 8 e discutiremos os detalhes de desreferenciação
> no Capítulo 15.

Vamos observar mais de perto a chamada de função aqui:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-07-reference/src/main.rs:here}}
```

A sintaxe `&s1` nos permite criar uma referência que se _refere_ ao valor de
`s1`, mas não é dona dele. Como a referência não possui ownership, o valor
para o qual ela aponta não será desalocado quando a referência deixar de ser
usada.

Da mesma forma, a assinatura da função usa `&` para indicar que o tipo do
parâmetro `s` é uma referência. Vamos adicionar algumas anotações
explicativas:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-08-reference-with-annotations/src/main.rs:here}}
```

O escopo em que a variável `s` é válida é igual ao escopo de qualquer
parâmetro de função, mas o valor apontado pela referência não é desalocado
quando `s` deixa de ser usado, porque `s` não tem ownership. Quando funções
recebem referências como parâmetros em vez dos próprios valores, não
precisamos devolver esses valores para transferir o ownership de volta, porque
nunca o tivemos.

Chamamos o ato de criar uma referência de _borrowing_ ou empréstimo. Como na
vida real: se uma pessoa é dona de algo, você pode pegar emprestado dela.
Quando terminar, precisa devolver. Você não é o dono.

Então, o que acontece se tentarmos modificar algo que estamos pegando
emprestado? Experimente o código da Listagem 4-6. Aviso de antemão: não
funciona!

<Listing number="4-6" file-name="src/main.rs" caption="Tentando modificar um valor emprestado">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/listing-04-06/src/main.rs}}
```

</Listing>

Este é o erro:

```console
{{#include ../listings/ch04-understanding-ownership/listing-04-06/output.txt}}
```

Assim como variáveis são imutáveis por padrão, referências também são. Não
temos permissão para modificar algo para o qual temos apenas uma referência.

### Referências Mutáveis

Podemos corrigir o código da Listagem 4-6 para permitir modificar um valor
emprestado com apenas alguns pequenos ajustes, usando, em vez disso, uma
_referência mutável_:

<Listing file-name="src/main.rs">

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-09-fixes-listing-04-06/src/main.rs}}
```

</Listing>

Primeiro, mudamos `s` para `mut`. Depois, criamos uma referência mutável com
`&mut s` no ponto em que chamamos a função `change` e atualizamos a assinatura
da função para aceitar uma referência mutável com `some_string: &mut String`.
Isso deixa muito claro que a função `change` vai mutar o valor que tomou
emprestado.

Referências mutáveis têm uma grande restrição: se você tem uma referência
mutável para um valor, não pode ter nenhuma outra referência para esse mesmo
valor. Este código, que tenta criar duas referências mutáveis para `s`, falha:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-10-multiple-mut-not-allowed/src/main.rs:here}}
```

</Listing>

Este é o erro:

```console
{{#include ../listings/ch04-understanding-ownership/no-listing-10-multiple-mut-not-allowed/output.txt}}
```

Esse erro diz que o código é inválido porque não podemos pegar `s` emprestada
como mutável mais de uma vez ao mesmo tempo. O primeiro empréstimo mutável está
em `r1` e precisa durar até ser usado no `println!`, mas, entre a criação dessa
referência mutável e seu uso, tentamos criar outra referência mutável em `r2`
que empresta os mesmos dados de `r1`.

A restrição que impede múltiplas referências mutáveis aos mesmos dados ao mesmo
tempo permite mutação, mas de uma forma muito controlada. É algo com que novos
rustaceanos costumam ter dificuldade, porque a maioria das linguagens permite
mutar quando você quiser. A vantagem dessa restrição é que o Rust consegue
evitar _data races_ em tempo de compilação. Uma _data race_ é parecida com uma
condição de corrida e acontece quando estes três comportamentos ocorrem:

- Dois ou mais ponteiros acessam os mesmos dados ao mesmo tempo.
- Pelo menos um desses ponteiros está sendo usado para escrever nos dados.
- Não há nenhum mecanismo de sincronização sendo usado para coordenar o acesso.

Data races causam comportamento indefinido e podem ser difíceis de diagnosticar
e corrigir quando você está tentando rastreá-las em tempo de execução; o Rust
evita esse problema recusando-se a compilar código com data races.

Como sempre, podemos usar chaves para criar um novo escopo, permitindo
múltiplas referências mutáveis, desde que não sejam _simultâneas_:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-11-muts-in-separate-scopes/src/main.rs:here}}
```

O Rust impõe uma regra semelhante para combinar referências mutáveis e
imutáveis. Este código gera um erro:

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-12-immutable-and-mutable-not-allowed/src/main.rs:here}}
```

Este é o erro:

```console
{{#include ../listings/ch04-understanding-ownership/no-listing-12-immutable-and-mutable-not-allowed/output.txt}}
```

Também _não_ podemos ter uma referência mutável enquanto temos uma referência
imutável ao mesmo valor.

Quem está usando uma referência imutável não espera que o valor mude de
repente enquanto a referência ainda está em uso. No entanto, múltiplas
referências imutáveis são permitidas, porque ninguém que esteja apenas lendo
os dados consegue afetar a leitura dos demais.

Observe que o escopo de uma referência começa no ponto em que ela é
introduzida e continua até a última vez em que essa referência é usada. Por
exemplo, este código compila porque o último uso das referências imutáveis está
no `println!`, antes da introdução da referência mutável:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-13-reference-scope-ends/src/main.rs:here}}
```

Os escopos das referências imutáveis `r1` e `r2` terminam depois do `println!`,
onde são usadas pela última vez, o que acontece antes da criação da referência
mutável `r3`. Esses escopos não se sobrepõem, então esse código é permitido: o
compilador consegue perceber que a referência já não está mais sendo usada em
um ponto anterior ao fim do escopo.

Mesmo que erros de borrowing possam ser frustrantes às vezes, lembre-se de que
é o compilador do Rust apontando um possível bug cedo, em tempo de compilação
em vez de em tempo de execução, e mostrando exatamente onde está o problema.
Assim, você não precisa sair procurando por que seus dados não são aquilo que
você achava que fossem.

### Referências Pendentes

Em linguagens com ponteiros, é fácil criar por engano um _dangling
pointer_ ou ponteiro pendente, isto é, um ponteiro que faz referência a um
local da memória que talvez já tenha sido entregue a outra pessoa, ao liberar
alguma memória enquanto ainda se preserva um ponteiro para ela. Em Rust, ao
contrário, o compilador garante que referências jamais serão pendentes: se você
tem uma referência para algum dado, o compilador garante que o dado não sairá
de escopo antes da referência.

Vamos tentar criar uma referência pendente para ver como o Rust evita isso com
um erro de compilação:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-14-dangling-reference/src/main.rs}}
```

</Listing>

Este é o erro:

```console
{{#include ../listings/ch04-understanding-ownership/no-listing-14-dangling-reference/output.txt}}
```

Essa mensagem de erro faz referência a um recurso que ainda não cobrimos:
_lifetimes_. Discutiremos lifetimes em detalhe no Capítulo 10. Mas, se você
ignorar as partes sobre lifetimes, a mensagem contém a chave para entender por
que esse código é um problema:

```text
this function's return type contains a borrowed value, but there is no value
for it to be borrowed from
```

Vamos observar com mais cuidado o que está acontecendo em cada etapa do código
de `dangle`:

<Listing file-name="src/main.rs">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-15-dangling-reference-annotated/src/main.rs:here}}
```

</Listing>

Como `s` é criada dentro de `dangle`, quando o código de `dangle` termina, `s`
é desalocada. Mas tentamos retornar uma referência a ela. Isso significa que a
referência apontaria para uma `String` inválida. Nada bom! O Rust não nos
deixa fazer isso.

A solução aqui é retornar a `String` diretamente:

```rust
{{#rustdoc_include ../listings/ch04-understanding-ownership/no-listing-16-no-dangle/src/main.rs:here}}
```

Isso funciona sem problemas. O ownership é movido para fora, e nada é
desalocado.

### As Regras das Referências

Vamos recapitular o que discutimos sobre referências:

- Em qualquer momento, você pode ter _ou_ uma referência mutável _ou_ qualquer
  quantidade de referências imutáveis.
- Referências sempre precisam ser válidas.

A seguir, veremos um tipo diferente de referência: fatias.

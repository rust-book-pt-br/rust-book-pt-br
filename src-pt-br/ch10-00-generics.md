# Tipos Genéricos, Traits e Lifetimes

Toda linguagem de programação tem ferramentas para lidar de forma eficaz com a
duplicação de conceitos. Em Rust, uma dessas ferramentas são os _genéricos_:
substitutos abstratos para tipos concretos ou outras propriedades. Podemos
expressar o comportamento de genéricos ou como eles se relacionam com outros
genéricos sem saber o que estará em seu lugar quando o código for compilado e
executado.

Funções podem receber parâmetros de algum tipo genérico, em vez de um tipo
concreto como `i32` ou `String`, da mesma forma que recebem parâmetros com
valores desconhecidos para executar o mesmo código sobre vários valores
concretos. Na verdade, já usamos genéricos no Capítulo 6 com `Option<T>`, no
Capítulo 8 com `Vec<T>` e `HashMap<K, V>`, e no Capítulo 9 com `Result<T, E>`.
Neste capítulo, você vai explorar como definir seus próprios tipos, funções e
métodos com genéricos!

Primeiro, vamos revisar como extrair uma função para reduzir duplicação de
código. Em seguida, usaremos a mesma técnica para criar uma função genérica a
partir de duas funções que diferem apenas nos tipos de seus parâmetros.
Também explicaremos como usar tipos genéricos em definições de structs e enums.

Depois, você vai aprender a usar traits para definir comportamento de maneira
genérica. Você pode combinar traits com tipos genéricos para restringir um tipo
genérico a aceitar apenas tipos que tenham um comportamento específico, em vez
de aceitar qualquer tipo.

Por fim, discutiremos _lifetimes_: uma variedade de genéricos que fornece ao
compilador informações sobre como referências se relacionam entre si.
Lifetimes nos permitem dar ao compilador informações suficientes sobre valores
emprestados para que ele possa garantir que referências serão válidas em mais
situacões do que conseguiria sem a nossa ajuda.

## Removendo Duplicação Extraindo uma Função

Genéricos nos permitem substituir tipos específicos por um placeholder que
representa múltiplos tipos, removendo duplicação de código. Antes de mergulhar
na sintaxe dos genéricos, vamos primeiro ver como remover duplicação de uma
forma que não envolva tipos genéricos, extraindo uma função que substitui
valores específicos por um placeholder que representa vários valores. Depois,
vamos aplicar a mesma técnica para extrair uma função genérica! Ao observar
como reconhecer código duplicado que pode ser extraído para uma função, você
começará a reconhecer código duplicado que pode usar genéricos.

Vamos começar com o pequeno programa da Listagem 10-1, que encontra o maior
número em uma lista.

<Listing number="10-1" file-name="src/main.rs" caption="Encontrando o maior número em uma lista de números">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-01/src/main.rs:here}}
```

</Listing>

Armazenamos uma lista de inteiros na variável `number_list` e colocamos uma
referência ao primeiro número da lista em uma variável chamada `largest`.
Depois, iteramos por todos os números da lista e, se o número atual for maior
do que o número armazenado em `largest`, substituímos a referência nessa
variável. No entanto, se o número atual for menor ou igual ao maior número
visto até aquele momento, a variável não muda, e o código segue para o próximo
número da lista. Depois de considerar todos os números da lista, `largest`
deverá se referir ao maior número, que neste caso é 100.

Agora recebemos a tarefa de encontrar o maior número em duas listas diferentes
de números. Para isso, podemos escolher duplicar o código da Listagem 10-1 e
usar a mesma lógica em dois lugares diferentes do programa, como mostrado na
Listagem 10-2.

<Listing number="10-2" file-name="src/main.rs" caption="Código para encontrar o maior número em *duas* listas de números">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-02/src/main.rs}}
```

</Listing>

Embora esse código funcione, duplicar código é tedioso e propenso a erros.
Também precisamos lembrar de atualizar o código em vários lugares quando
quisermos mudá-lo.

Para eliminar essa duplicação, vamos criar uma abstração definindo uma função
que opere sobre qualquer lista de inteiros passada como parâmetro. Essa solução
deixa nosso código mais claro e nos permite expressar de forma abstrata o
conceito de encontrar o maior número de uma lista.

Na Listagem 10-3, extraímos o código que encontra o maior número para uma
função chamada `largest`. Depois, chamamos essa função para encontrar o maior
número nas duas listas da Listagem 10-2. Também poderíamos usar a função em
qualquer outra lista de valores `i32` que venhamos a ter no futuro.

<Listing number="10-3" file-name="src/main.rs" caption="Código abstraído para encontrar o maior número em duas listas">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-03/src/main.rs:here}}
```

</Listing>

A função `largest` tem um parâmetro chamado `list`, que representa qualquer
fatia concreta de valores `i32` que possamos passar para a função. Como
resultado, quando chamamos a função, o código é executado sobre os valores
específicos que fornecemos.

Em resumo, estas foram as etapas que usamos para transformar o código da
Listagem 10-2 em código como o da Listagem 10-3:

1. Identificar código duplicado.
1. Extrair o código duplicado para o corpo de uma função e especificar as
   entradas e os valores de retorno desse código na assinatura da função.
1. Atualizar as duas instâncias do código duplicado para chamar a função.

A seguir, vamos usar essas mesmas etapas com genéricos para reduzir duplicação
de código. Da mesma forma que o corpo da função pode operar sobre uma `list`
abstrata em vez de valores específicos, genéricos permitem que o código opere
sobre tipos abstratos.

Por exemplo, digamos que tivéssemos duas funções: uma encontra o maior item em
uma fatia de valores `i32`, e a outra encontra o maior item em uma fatia de
valores `char`. Como eliminaríamos essa duplicação? Vamos descobrir!

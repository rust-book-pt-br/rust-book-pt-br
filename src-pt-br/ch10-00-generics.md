# Tipos genéricos, características e tempos de vida

Cada linguagem de programação possui ferramentas para lidar eficazmente com a duplicação
de conceitos. No Rust, uma dessas ferramentas é _generics_: substitutos abstratos para
tipos de concreto ou outras propriedades. Podemos expressar o comportamento de genéricos ou
como eles se relacionam com outros genéricos sem saber o que estará em seu lugar
ao compilar e executar o código.

As funções podem receber parâmetros de algum tipo genérico, em vez de um tipo concreto
como `i32` ou `String`, da mesma forma que aceitam parâmetros com desconhecidos
valores para executar o mesmo código em vários valores concretos. Na verdade, já
usei genéricos no Capítulo 6 com `Option<T>`, no Capítulo 8 com `Vec<T>` e
`HashMap<K, V>`, e no Capítulo 9 com `Result<T, E>`. Neste capítulo, você
explore como definir seus próprios tipos, funções e métodos com genéricos!

Primeiro, revisaremos como extrair uma função para reduzir a duplicação de código. Bem
então use a mesma técnica para criar uma função genérica a partir de duas funções que
diferem apenas nos tipos de seus parâmetros. Também explicaremos como usar
tipos genéricos em definições de struct e enum.

Em seguida, você aprenderá como usar características para definir o comportamento de maneira genérica. Você
pode combinar características com tipos genéricos para restringir um tipo genérico a aceitar
apenas aqueles tipos que têm um comportamento específico, em oposição a qualquer tipo.

Finalmente, discutiremos _lifetimes_: uma variedade de genéricos que dão a
informações do compilador sobre como as referências se relacionam entre si. As vidas permitem
fornecer ao compilador informações suficientes sobre os valores emprestados para que ele possa
garantir que as referências serão válidas em mais situações do que seriam sem
nossa ajuda.

## Removendo duplicação extraindo uma função

Os genéricos nos permitem substituir tipos específicos por um espaço reservado que representa
vários tipos para remover a duplicação de código. Antes de mergulhar na sintaxe genérica,
vamos primeiro ver como remover a duplicação de uma forma que não envolva
tipos genéricos extraindo uma função que substitui valores específicos por um
espaço reservado que representa vários valores. Então, aplicaremos o mesmo
técnica para extrair uma função genérica! Ao observar como reconhecer
código duplicado que você pode extrair para uma função, você começará a reconhecer
código duplicado que pode usar genéricos.

Começaremos com o programa curto da Listagem 10-1 que encontra o maior
número em uma lista.

<Listing number="10-1" file-name="src/main.rs" caption="Finding the largest number in a list of numbers">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-01/src/main.rs:here}}
```

</Listing>

Armazenamos uma lista de inteiros na variável `number_list` e colocamos uma referência
ao primeiro número da lista em uma variável chamada `largest`. Nós então iteramos
através de todos os números da lista, e se o número atual for maior que
o número armazenado em `largest`, substituímos a referência nessa variável.
No entanto, se o número atual for menor ou igual ao maior número visto
até agora, a variável não muda e o código passa para o próximo número
na lista. Depois de considerar todos os números da lista, `largest` deve
referem-se ao maior número, que neste caso é 100.

Agora temos a tarefa de encontrar o maior número em duas listas diferentes de
números. Para fazer isso, podemos optar por duplicar o código da Listagem 10-1 e usar
a mesma lógica em dois locais diferentes do programa, conforme mostrado na Listagem 10-2.

<Listing number="10-2" file-name="src/main.rs" caption="Code to find the largest number in *two* lists of numbers">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-02/src/main.rs}}
```

</Listing>

Embora esse código funcione, duplicar código é tedioso e sujeito a erros. Nós também
temos que lembrar de atualizar o código em vários lugares quando quisermos alterar
isto.

Para eliminar esta duplicação, criaremos uma abstração definindo um
função que opera em qualquer lista de inteiros passados ​​como parâmetro. Esse
solução torna nosso código mais claro e nos permite expressar o conceito de encontrar o
maior número em uma lista abstratamente.

Na Listagem 10-3, extraímos o código que encontra o maior número em um
função chamada `largest`. Então, chamamos a função para encontrar o maior número
nas duas listas da Listagem 10-2. Também poderíamos usar a função em qualquer outro
lista de valores `i32` que poderemos ter no futuro.

<Listing number="10-3" file-name="src/main.rs" caption="Abstracted code to find the largest number in two lists">

```rust
{{#rustdoc_include ../listings/ch10-generic-types-traits-and-lifetimes/listing-10-03/src/main.rs:here}}
```

</Listing>

A função `largest` possui um parâmetro chamado `list`, que representa qualquer
fatia concreta de valores `i32` que podemos passar para a função. Como resultado,
quando chamamos a função, o código é executado nos valores específicos que passamos
em.

Em resumo, aqui estão as etapas que executamos para alterar o código da Listagem 10.2 para
Listagem 10-3:

1. Identifique código duplicado.
1. Extraia o código duplicado no corpo da função e especifique o
entradas e valores de retorno desse código na assinatura da função.
1. Atualize as duas instâncias de código duplicado para chamar a função.

A seguir, usaremos essas mesmas etapas com genéricos para reduzir a duplicação de código. Em
da mesma forma que o corpo da função pode operar em um `list` abstrato
de valores específicos, os genéricos permitem que o código opere em tipos abstratos.

Por exemplo, digamos que temos duas funções: uma que encontra o maior item em um
fatia de valores `i32` e aquela que encontra o maior item em uma fatia de `char`
valores. Como eliminaríamos essa duplicação? Vamos descobrir!

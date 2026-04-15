## Armazenando Chaves com Valores Associados em Hash Maps

A última das nossas coleções comuns é o hash map. O tipo `HashMap<K, V>`
armazena um mapeamento de chaves do tipo `K` para valores do tipo `V` usando
uma _hashing function_, que determina como essas chaves e valores são
organizados na memória. Muitas linguagens de programação oferecem esse tipo de
estrutura de dados, mas frequentemente com nomes diferentes, como _hash_,
_map_, _object_, _hash table_, _dictionary_ ou _associative array_, para citar
alguns.

Hash maps são úteis quando você quer procurar dados não por índice, como faz
com vetores, mas por meio de uma chave que pode ser de qualquer tipo. Por
exemplo, em um jogo, você pode acompanhar a pontuação de cada time em um hash
map, em que cada chave é o nome de um time e os valores são suas respectivas
pontuações. Dado o nome de um time, você pode recuperar sua pontuação.

Nesta seção, veremos a API básica de hash maps, mas há muito mais
funcionalidades escondidas nas funções definidas em `HashMap<K, V>` pela
biblioteca padrão. Como sempre, consulte a documentação da biblioteca padrão
para mais informações.

### Criando um Novo Hash Map

Uma forma de criar um hash map vazio é usar `new` e adicionar elementos com
`insert`. Na Listagem 8-20, estamos acompanhando as pontuações de dois times,
_Blue_ e _Yellow_. O time Blue começa com 10 pontos, e o time Yellow começa
com 50.

<Listing number="8-20" caption="Criando um novo hash map e inserindo algumas chaves e valores">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-20/src/main.rs:here}}
```

</Listing>

Observe que primeiro precisamos usar `use` para trazer `HashMap` da parte de
coleções da biblioteca padrão. Das nossas três coleções comuns, esta é a menos
usada com frequência, então não faz parte dos itens colocados automaticamente
em escopo pelo prelude. Hash maps também recebem menos suporte direto da
biblioteca padrão; por exemplo, não existe uma macro embutida para construí-los.

Assim como vetores, hash maps armazenam seus dados na heap. Esse `HashMap` tem
chaves do tipo `String` e valores do tipo `i32`. Como vetores, hash maps são
homogêneos: todas as chaves precisam ter o mesmo tipo, e todos os valores
também precisam ter o mesmo tipo.

### Acessando Valores em um Hash Map

Podemos obter um valor de um hash map fornecendo sua chave ao método `get`,
como mostra a Listagem 8-21.

<Listing number="8-21" caption="Acessando a pontuação do time Blue armazenada no hash map">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-21/src/main.rs:here}}
```

</Listing>

Aqui, `score` terá o valor associado ao time Blue, e o resultado será `10`. O
método `get` retorna um `Option<&V>`; se não houver valor para aquela chave no
hash map, `get` retornará `None`. Este programa lida com o `Option` chamando
`copied` para obter um `Option<i32>` em vez de um `Option<&i32>` e, em seguida,
`unwrap_or` para definir `score` como zero caso `scores` não tenha uma entrada
para aquela chave.

Podemos iterar sobre cada par chave-valor em um hash map de maneira parecida
com o que fazemos com vetores, usando um loop `for`:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/no-listing-03-iterate-over-hashmap/src/main.rs:here}}
```

Esse código imprimirá cada par em uma ordem arbitrária:

```text
Yellow: 50
Blue: 10
```

<!-- Old headings. Do not remove or links may break. -->

<a id="hash-maps-and-ownership"></a>

### Gerenciando Ownership em Hash Maps

Para tipos que implementam a trait `Copy`, como `i32`, os valores são copiados
para dentro do hash map. Para valores próprios, como `String`, os valores são
movidos, e o hash map passa a ser o proprietário desses valores, como mostra a
Listagem 8-22.

<Listing number="8-22" caption="Mostrando que as chaves e os valores passam a ser de propriedade do hash map depois de inseridos">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-22/src/main.rs:here}}
```

</Listing>

Não podemos mais usar as variáveis `field_name` e `field_value` depois que elas
forem movidas para dentro do hash map pela chamada a `insert`.

Se inserirmos referências a valores no hash map, os valores em si não serão
movidos para dentro dele. Os valores apontados por essas referências precisam
continuar válidos por pelo menos tanto tempo quanto o hash map for válido.
Falaremos mais sobre essas questões em [“Validando Referências com
Lifetimes”][validating-references-with-lifetimes]<!-- ignore --> no Capítulo
10.

### Atualizando um Hash Map

Embora o número de pares chave-valor possa crescer, cada chave única só pode
ter um valor associado por vez, embora o inverso não seja verdadeiro. Por
exemplo, tanto o time Blue quanto o time Yellow podem ter o valor `10`
armazenado no hash map `scores`.

Quando você quer alterar os dados em um hash map, precisa decidir como tratar o
caso em que uma chave já possui um valor associado. Você pode substituir o
valor antigo pelo novo, ignorando completamente o valor anterior. Pode manter o
valor antigo e ignorar o novo, adicionando o novo valor apenas se a chave
_ainda não_ tiver um valor. Ou pode combinar o valor antigo com o novo. Vamos
ver como fazer cada uma dessas coisas!

#### Sobrescrevendo um Valor

Se inserirmos uma chave e um valor em um hash map e depois inserirmos essa
mesma chave com um valor diferente, o valor associado a ela será substituído.
Mesmo que o código da Listagem 8-23 chame `insert` duas vezes, o hash map
conterá apenas um par chave-valor, porque estamos inserindo valor para a chave
do time Blue nas duas vezes.

<Listing number="8-23" caption="Substituindo o valor armazenado em uma determinada chave">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-23/src/main.rs:here}}
```

</Listing>

Esse código imprimirá `{"Blue": 25}`. O valor original, `10`, foi
sobrescrito.

<!-- Old headings. Do not remove or links may break. -->

<a id="only-inserting-a-value-if-the-key-has-no-value"></a>

#### Adicionando uma Chave e um Valor Somente se a Chave Ainda Não Estiver Presente

É comum verificar se uma determinada chave já existe no hash map com algum
valor e então tomar as seguintes ações: se a chave já existir, o valor atual
deve permanecer como está; se a chave não existir, inserimos a chave e um valor
para ela.

Hash maps têm uma API especial para isso chamada `entry`, que recebe como
parâmetro a chave que você quer verificar. O valor retornado pelo método
`entry` é um enum chamado `Entry`, que representa um valor que pode ou não
existir. Digamos que queremos verificar se a chave do time Yellow tem um valor
associado. Se não tiver, queremos inserir o valor `50`, e o mesmo vale para o
time Blue. Usando a API `entry`, o código fica como na Listagem 8-24.

<Listing number="8-24" caption="Usando o método `entry` para inserir apenas se a chave ainda não tiver um valor">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-24/src/main.rs:here}}
```

</Listing>

O método `or_insert` em `Entry` foi definido para retornar uma referência
mutável ao valor da chave correspondente caso essa chave exista; se não
existir, ele insere o parâmetro como novo valor dessa chave e retorna uma
referência mutável a esse novo valor. Essa técnica é bem mais limpa do que
escrever toda a lógica manualmente e, além disso, funciona melhor com o borrow
checker.

Executar o código da Listagem 8-24 imprimirá `{"Yellow": 50, "Blue": 10}`. A
primeira chamada a `entry` vai inserir a chave do time Yellow com o valor `50`,
porque o time Yellow ainda não tem um valor. A segunda chamada a `entry` não
vai alterar o hash map, porque o time Blue já tem o valor `10`.

#### Atualizando um Valor com Base no Valor Antigo

Outro caso de uso comum para hash maps é procurar o valor de uma chave e, em
seguida, atualizá-lo com base no valor anterior. Por exemplo, a Listagem 8-25
mostra um código que conta quantas vezes cada palavra aparece em um texto.
Usamos um hash map com as palavras como chaves e incrementamos o valor para
acompanhar quantas vezes vimos cada palavra. Se for a primeira vez que vemos
uma palavra, primeiro inserimos o valor `0`.

<Listing number="8-25" caption="Contando ocorrências de palavras usando um hash map que armazena palavras e contagens">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-25/src/main.rs:here}}
```

</Listing>

Esse código imprimirá `{"world": 2, "hello": 1, "wonderful": 1}`. Você pode
ver os mesmos pares chave-valor impressos em outra ordem. Lembre-se, pela
seção [“Acessando Valores em um Hash Map”][access]<!-- ignore -->, que iterar
sobre um hash map acontece em ordem arbitrária.

O método `split_whitespace` retorna um iterador sobre subfatias do valor em
`text`, separadas por espaço em branco. O método `or_insert` retorna uma
referência mutável (`&mut V`) ao valor da chave especificada. Aqui, armazenamos
essa referência mutável na variável `count`, então, para atribuir um valor a
ela, primeiro precisamos desreferenciar `count` usando o asterisco (`*`). A
referência mutável sai de escopo no fim do loop `for`, então todas essas
mudanças são seguras e permitidas pelas regras de borrowing.

### Funções de Hash

Por padrão, `HashMap` usa uma função de hash chamada _SipHash_, que pode
oferecer resistência a ataques de negação de serviço (DoS) envolvendo tabelas
hash[^siphash]<!-- ignore -->. Esse não é o algoritmo de hash mais rápido
disponível, mas o trade-off por maior segurança, mesmo com a queda de
desempenho, vale a pena. Se você fizer profiling do seu código e descobrir que
a função de hash padrão é lenta demais para o seu caso, pode trocar por outra,
especificando um hasher diferente. Um _hasher_ é um tipo que implementa a trait
`BuildHasher`. Falaremos sobre traits e sobre como implementá-las no [Capítulo
10][traits]<!-- ignore -->. Você não precisa necessariamente implementar seu
próprio hasher do zero; [crates.io](https://crates.io/)<!-- ignore --> tem
bibliotecas compartilhadas por outros usuários de Rust que fornecem hashers com
vários algoritmos de hash comuns.

[^siphash]: [https://en.wikipedia.org/wiki/SipHash](https://en.wikipedia.org/wiki/SipHash)

## Resumo

Vetores, strings e hash maps oferecem grande parte da funcionalidade necessária
em programas quando você precisa armazenar, acessar e modificar dados. Aqui
estão alguns exercícios para os quais você já deve estar preparado:

1. Dada uma lista de inteiros, use um vetor e retorne a mediana, isto é, o
   valor na posição do meio após ordenar, e a moda, o valor que ocorre com mais
   frequência. Um hash map será útil aqui.
1. Converta strings para Pig Latin. A primeira consoante de cada palavra vai
   para o final da palavra, e adicionamos _ay_; assim, _first_ vira
   _irst-fay_. Palavras que começam com vogal recebem _hay_ no final, então
   _apple_ vira _apple-hay_. Tenha em mente os detalhes da codificação UTF-8!
1. Usando um hash map e vetores, crie uma interface de texto para permitir que
   a pessoa usuária adicione nomes de funcionários a um departamento de uma
   empresa; por exemplo, “Add Sally to Engineering” ou “Add Amir to Sales”.
   Depois, permita que a pessoa usuária recupere uma lista de todas as pessoas
   de um departamento ou de todas as pessoas da empresa agrupadas por
   departamento, em ordem alfabética.

A documentação da API da biblioteca padrão descreve métodos de vetores,
strings e hash maps que serão úteis para esses exercícios!

Estamos entrando em programas mais complexos, nos quais operações podem falhar,
então este é um momento perfeito para discutir tratamento de erros. É o que
veremos a seguir!

[validating-references-with-lifetimes]: ch10-03-lifetime-syntax.html
[access]: #acessando-valores-em-um-hash-map
[traits]: ch10-02-traits.html

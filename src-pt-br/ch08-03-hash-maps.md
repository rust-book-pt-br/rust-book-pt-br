## Armazenando Chaves com Valores Associados em Mapas Hash

A última de nossas coleções comuns é o mapa hash. O tipo `HashMap<K, V>`
armazena um mapeamento de chaves do tipo `K` para valores do tipo `V` usando um _hashing
function_, que determina como colocar essas chaves e valores na memória.
Muitas linguagens de programação suportam esse tipo de estrutura de dados, mas muitas vezes
use um nome diferente, como _hash_, _map_, _object_, _hash table_,
_dicionário_ ou _matriz associativa_, apenas para citar alguns.

Os mapas hash são úteis quando você deseja pesquisar dados sem usar um índice, como
você pode com vetores, mas usando uma chave que pode ser de qualquer tipo. Por exemplo,
em um jogo, você pode acompanhar a pontuação de cada equipe em um mapa hash no qual
cada chave é o nome de uma equipe e os valores são a pontuação de cada equipe. Dada uma equipe
nome, você pode recuperar sua pontuação.

Abordaremos a API básica de mapas hash nesta seção, mas com muito mais novidades
estão escondidos nas funções definidas em `HashMap<K, V>` pela biblioteca padrão.
Como sempre, verifique a documentação padrão da biblioteca para obter mais informações.

### Criando um novo mapa de hash

Uma maneira de criar um mapa hash vazio é usar `new` e adicionar elementos com
`insert`. Na Listagem 8.20, estamos acompanhando as pontuações de duas equipes cujas
os nomes são _Azul_ e _Amarelo_. O time Azul começa com 10 pontos, e o
O time amarelo começa com 50.

<Listing number="8-20" caption="Creating a new hash map and inserting some keys and values">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-20/src/main.rs:here}}
```

</Listing>

Observe que precisamos primeiro `use` do `HashMap` da parte de coleções do
a biblioteca padrão. Das nossas três coleções comuns, esta é a menos
usado com frequência, por isso não está incluído nos recursos incluídos no escopo
automaticamente no prelúdio. Os mapas hash também têm menos suporte do
biblioteca padrão; não há macro integrada para construí-los, por exemplo.

Assim como os vetores, os mapas hash armazenam seus dados na pilha. Este `HashMap` tem
chaves do tipo `String` e valores do tipo `i32`. Assim como os vetores, os mapas hash são
homogêneo: todas as chaves devem ter o mesmo tipo e todos os valores
deve ser do mesmo tipo.

### Acessando Valores em um Mapa Hash

Podemos obter um valor do mapa hash fornecendo sua chave para `get`
método, conforme mostrado na Listagem 8-21.

<Listing number="8-21" caption="Accessing the score for the Blue team stored in the hash map">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-21/src/main.rs:here}}
```

</Listing>

Aqui, `score` terá o valor associado ao time Azul, e o
o resultado será `10`. O método `get` retorna um `Option<&V>`; se não houver
valor para essa chave no mapa hash, `get` retornará `None`. Este programa
lida com `Option` chamando `copied` para obter um `Option<i32>` em vez de um
`Option<&i32>`, então `unwrap_or` para definir `score` como zero se `scores` não
tem uma entrada para a chave.

Podemos iterar cada par de valores-chave em um mapa hash de maneira semelhante a
faça com vetores, usando um loop `for`:

```rust
{{#rustdoc_include ../listings/ch08-common-collections/no-listing-03-iterate-over-hashmap/src/main.rs:here}}
```

Este código imprimirá cada par em uma ordem arbitrária:

```text
Yellow: 50
Blue: 10
```

<!-- Old headings. Do not remove or links may break. -->

<a id="hash-maps-and-ownership"></a>

### Gerenciando propriedade em mapas hash

Para tipos que implementam a característica `Copy`, como `i32`, os valores são copiados
no mapa hash. Para valores próprios como `String`, os valores serão movidos e
o mapa hash será o proprietário desses valores, conforme demonstrado na Listagem 8.22.

<Listing number="8-22" caption="Showing that keys and values are owned by the hash map once they’re inserted">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-22/src/main.rs:here}}
```

</Listing>

Não podemos usar as variáveis ​​`field_name` e `field_value` depois
eles foram movidos para o mapa hash com a chamada para `insert`.

Se inserirmos referências a valores no mapa hash, os valores não serão movidos
no mapa hash. Os valores para os quais as referências apontam devem ser válidos por pelo menos
pelo menos enquanto o mapa hash for válido. Falaremos mais sobre esses assuntos em
[“Validando Referências com
Vidas”][validating-references-with-lifetimes]<!-- ignore --> no Capítulo 10.

### Atualizando um mapa hash

Embora o número de pares de chave e valor possa crescer, cada chave exclusiva pode
tem apenas um valor associado a ele por vez (mas não vice-versa: para
por exemplo, tanto a equipe Azul quanto a equipe Amarela poderiam ter o valor `10`
armazenado no mapa hash `scores`).

Quando você deseja alterar os dados em um mapa hash, você deve decidir como
lidar com o caso quando uma chave já tem um valor atribuído. Você poderia substituir o
valor antigo pelo novo valor, desconsiderando completamente o valor antigo. Você poderia
mantenha o valor antigo e ignore o novo valor, apenas adicionando o novo valor se o
key _não_ já tem um valor. Ou você pode combinar o valor antigo e o
novo valor. Vejamos como fazer cada um deles!

#### Substituindo um valor

Se inserirmos uma chave e um valor em um mapa hash e depois inserirmos a mesma chave
com um valor diferente, o valor associado a essa chave será substituído.
Mesmo que o código na Listagem 8-23 chame `insert` duas vezes, o mapa hash
contêm apenas um par de valores-chave porque estamos inserindo o valor para o Azul
chave da equipe em ambas as vezes.

<Listing number="8-23" caption="Replacing a value stored with a particular key">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-23/src/main.rs:here}}
```

</Listing>

Este código imprimirá `{"Blue": 25}`. O valor original de `10` foi
sobrescrito.

<!-- Old headings. Do not remove or links may break. -->

<a id="only-inserting-a-value-if-the-key-has-no-value"></a>

#### Adicionando uma chave e um valor somente se uma chave não estiver presente

É comum verificar se uma determinada chave já existe no mapa hash
com um valor e, em seguida, executar as seguintes ações: Se a chave existir em
no mapa hash, o valor existente deve permanecer como está; se a chave
não existe, insira-o e um valor para ele.

Os mapas hash têm uma API especial para isso chamada `entry` que pega a chave que você
deseja verificar como parâmetro. O valor de retorno do método `entry` é um enum
chamado `Entry` que representa um valor que pode ou não existir. Digamos
queremos verificar se a chave do time Amarelo tem um valor associado
com isso. Caso contrário, queremos inserir o valor `50`, e o mesmo para o
Equipe azul. Usando a API `entry`, o código se parece com a Listagem 8.24.

<Listing number="8-24" caption="Using the `entry` method to only insert if the key does not already have a value">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-24/src/main.rs:here}}
```

</Listing>

O método `or_insert` em `Entry` é definido para retornar uma referência mutável para
o valor da chave `Entry` correspondente, se essa chave existir, e se não, ela
insere o parâmetro como o novo valor para esta chave e retorna um mutável
referência ao novo valor. Esta técnica é muito mais limpa do que escrever o
lógica e, além disso, funciona melhor com o verificador de empréstimo.

A execução do código na Listagem 8.24 imprimirá `{"Yellow": 50, "Blue": 10}`. O
a primeira chamada para `entry` irá inserir a chave para o time Amarelo com o valor
`50` porque o time Amarelo ainda não tem valor. A segunda chamada para
`entry` não irá alterar o mapa hash, pois a equipe Azul já possui o
valor `10`.

#### Atualizando um valor com base no valor antigo

Outro caso de uso comum para mapas hash é procurar o valor de uma chave e então
atualize-o com base no valor antigo. Por exemplo, a Listagem 8-25 mostra o código que
conta quantas vezes cada palavra aparece em algum texto. Usamos um mapa hash com
as palavras como chaves e incrementar o valor para controlar quantas vezes
vi essa palavra. Se for a primeira vez que vemos uma palavra, primeiro inseriremos
o valor `0`.

<Listing number="8-25" caption="Counting occurrences of words using a hash map that stores words and counts">

```rust
{{#rustdoc_include ../listings/ch08-common-collections/listing-08-25/src/main.rs:here}}
```

</Listing>

Este código imprimirá `{"world": 2, "hello": 1, "wonderful": 1}`. Você pode ver
os mesmos pares de valores-chave impressos em uma ordem diferente: Lembre-se de [“Acessando
Valores em um mapa hash”][access]<!-- ignore --> que itera sobre um mapa hash
acontece em uma ordem arbitrária.

O método `split_whitespace` retorna um iterador sobre subfatias, separadas por
espaço em branco, do valor em `text`. O método `or_insert` retorna um mutável
referência (`&mut V`) ao valor da chave especificada. Aqui, nós armazenamos isso
referência mutável na variável `count`, portanto, para atribuir a esse valor,
devemos primeiro desreferenciar `count` usando o asterisco (`*`). O mutável
referência sai do escopo no final do loop `for`, então todos esses
as mudanças são seguras e permitidas pelas regras de empréstimo.

### Funções de hash

Por padrão, `HashMap` usa uma função hash chamada _SipHash_ que pode fornecer
resistência a ataques de negação de serviço (DoS) envolvendo hash
tabelas[^siphash]<!-- ignore -->. Este não é o algoritmo de hash mais rápido
disponível, mas a compensação por melhor segurança que vem com a queda na
o desempenho vale a pena. Se você criar o perfil do seu código e descobrir que o padrão
a função hash é muito lenta para seus propósitos, você pode mudar para outra função
especificando um hasher diferente. Um _hasher_ é um tipo que implementa o
`BuildHasher` característica. Falaremos sobre características e como implementá-las em
[Capítulo 10][traits]<!-- ignore -->. Você não precisa necessariamente implementar
seu próprio hasher do zero; [crates.io](https://crates.io/)<!-- ignore -->
tem bibliotecas compartilhadas por outros usuários do Rust que fornecem hashers implementando muitos
algoritmos de hash comuns.

[^siphash]: [https://en.wikipedia.org/wiki/SipHash](https://en.wikipedia.org/wiki/SipHash)

## Resumo

Vetores, strings e mapas hash fornecerão uma grande quantidade de funcionalidades
necessário em programas quando você precisa armazenar, acessar e modificar dados. Aqui estão
alguns exercícios que você agora deve estar preparado para resolver:

1. Dada uma lista de inteiros, use um vetor e retorne a mediana (quando classificado,
o valor na posição intermediária) e moda (o valor que ocorre mais
muitas vezes; um mapa hash será útil aqui) da lista.
1. Converta strings para Pig Latin. A primeira consoante de cada palavra é movida para
o final da palavra e _ay_ são adicionados, então _first_ se torna _irst-fay_. Palavras
que começam com uma vogal têm _hay_ adicionado ao final (_apple_ se torna
_maçã-feno_). Tenha em mente os detalhes sobre a codificação UTF-8!
1. Usando um mapa hash e vetores, crie uma interface de texto para permitir que um usuário adicione
nomes de funcionários de um departamento de uma empresa; por exemplo, “Adicionar Sally a
Engenharia” ou “Adicionar Amir às Vendas”. Em seguida, deixe o usuário recuperar uma lista de
todas as pessoas de um departamento ou todas as pessoas da empresa por departamento, classificadas
alfabeticamente.

A documentação da API da biblioteca padrão descreve métodos que vetores, strings,
e mapas hash que serão úteis para esses exercícios!

Estamos entrando em programas mais complexos nos quais as operações podem falhar, por isso é
um momento perfeito para discutir o tratamento de erros. Faremos isso a seguir!

[validating-references-with-lifetimes]: ch10-03-lifetime-syntax.html#validating-references-with-lifetimes
[access]: #accessing-values-in-a-hash-map
[traits]: ch10-02-traits.html

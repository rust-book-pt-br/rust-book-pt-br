## Apêndice C: Características Deriváveis

Em vários lugares do livro, discutimos o atributo `derive`, que
você pode aplicar a uma definição de struct ou enum. O atributo ` derive`gera
código que implementará um trait com sua própria implementação padrão no
tipo que você anotou com a sintaxe ` derive`.

Neste apêndice, fornecemos uma referência de todos os traits no padrão
biblioteca que você pode usar com `derive`. Cada seção cobre:

- Quais operadores e métodos derivados deste trait permitirão
- O que faz a implementação do trait fornecido pelo `derive`
- O que a implementação do trait significa sobre o tipo
- As condições nas quais você tem permissão ou não para implementar o trait
- Exemplos de operações que requerem o trait

Se desejar um comportamento diferente daquele fornecido pelo atributo `derive`,
consult the [standard library documentation](../std/index.html)<!-- ignore -->
para cada trait para obter detalhes sobre como implementá-los manualmente.

Os traits listados aqui são os únicos definidos pela biblioteca padrão que
pode ser implementado em seus tipos usando `derive`. Outros traits definidos no
biblioteca padrão não tem comportamento padrão sensato, então cabe a você
implemente-os da maneira que faça sentido para o que você está tentando realizar.

Um exemplo de trait que não pode ser derivado é `Display`, que trata
formatação para usuários finais. Você deve sempre considerar a maneira apropriada de
exibir um tipo para um usuário final. Quais partes do tipo um usuário final deve ser
permitido ver? Que partes eles considerariam relevantes? Qual formato dos dados
seria mais relevante para eles? O compilador Rust não tem esse insight, então
ele não pode fornecer um comportamento padrão apropriado para você.

A lista de traits deriváveis fornecida neste apêndice não é abrangente:
As bibliotecas podem implementar `derive` para seu próprio traits, tornando a lista de
traits você pode usar `derive` com verdadeiramente aberto. Implementando `derive`
envolve o uso de uma macro processual, que é abordada no [“Custom ` derive`
Macros”][custom-derive-macros]<!-- ignore --> no Capítulo 20.

### `Debug` para saída do programador

O `Debug` trait permite a formatação de depuração em strings de formato, que você
indique adicionando `:?` aos espaços reservados `{}`.

O `Debug` trait permite imprimir instâncias de um tipo para depuração
propósitos, para que você e outros programadores que usam seu tipo possam inspecionar uma instância
em um ponto específico da execução de um programa.

O `Debug` trait é necessário, por exemplo, no uso do `assert_eq!`
macro. Esta macro imprime os valores das instâncias dadas como argumentos se o
a afirmação de igualdade falha para que os programadores possam ver por que as duas instâncias
não eram iguais.

### `PartialEq` e `Eq` para comparações de igualdade

O `PartialEq` trait permite comparar instâncias de um tipo para verificar
igualdade e permite o uso dos operadores `==` e `!=`.

A derivação de `PartialEq` implementa o método `eq`. Quando ` PartialEq`é derivado de
estruturas, duas instâncias são iguais apenas se _todos_ os campos forem iguais, e o
as instâncias não são iguais se _qualquer_ campo não for igual. Quando derivado de enums,
cada variante é igual a si mesma e não é igual às outras variantes.

O `PartialEq` trait é necessário, por exemplo, com o uso do
Macro `assert_eq!`, que precisa ser capaz de comparar duas instâncias de um tipo
pela igualdade.

O `Eq` trait não possui métodos. Seu objetivo é sinalizar que para cada valor de
o tipo anotado, o valor é igual a si mesmo. O `Eq` trait só pode ser
aplicado a tipos que também implementam `PartialEq`, embora nem todos os tipos que
implementar ` PartialEq`pode implementar ` Eq`. Um exemplo disso é o ponto flutuante
tipos de números: A implementação de números de ponto flutuante afirma que dois
as instâncias do valor não-um-número (` NaN`) não são iguais entre si.

Um exemplo de quando `Eq` é necessário é para chaves em um `HashMap<K, V>` para que
o `HashMap<K, V>` pode dizer se duas chaves são iguais.

### `PartialOrd` e `Ord` para comparações de pedidos

O `PartialOrd` trait permite comparar instâncias de um tipo para classificação
propósitos. Um tipo que implementa `PartialOrd` pode ser usado com `<`, ` >`,
Operadores ` <=`e ` >=`. Você só pode aplicar o ` PartialOrd`trait aos tipos
que também implementam ` PartialEq`.

Derivando `PartialOrd` implementa o método `partial_cmp`, que retorna um
` Option<Ordering> `que será` None `quando os valores fornecidos não produzirem um
encomenda. Um exemplo de valor que não produz uma ordenação, embora
a maioria dos valores desse tipo podem ser comparados, é o valor de ponto flutuante` NaN `.
Chamando` partial_cmp `com qualquer número de ponto flutuante e o` NaN `
o valor de ponto flutuante retornará` None`.

Quando derivado em estruturas, `PartialOrd` compara duas instâncias comparando o
valor em cada campo na ordem em que os campos aparecem na estrutura
definição. Quando derivadas de enums, variantes do enum declaradas anteriormente no
definição de enum são consideradas inferiores às variantes listadas posteriormente.

O `PartialOrd` trait é necessário, por exemplo, para o método `gen_range`
do ` rand`crate que gera um valor aleatório no intervalo especificado por um
expressão de intervalo.

O `Ord` trait permite saber que para quaisquer dois valores do anotado
tipo, existirá uma ordem válida. O `Ord` trait implementa o método `cmp`,
que retorna um ` Ordering`em vez de um ` Option<Ordering>`porque um valor válido
encomendar sempre será possível. Você só pode aplicar o ` Ord`trait aos tipos
que também implementam ` PartialOrd`e ` Eq`(e ` Eq`requer ` PartialEq`). Quando
derivado em structs e enums, ` cmp`se comporta da mesma maneira que o derivado
implementação para ` partial_cmp`faz com ` PartialOrd`.

Um exemplo de quando `Ord` é necessário é ao armazenar valores em um `BTreeSet<T>`,
uma estrutura de dados que armazena dados com base na ordem de classificação dos valores.

### `Clone` e `Copy` para duplicação de valores

O `Clone` trait permite criar explicitamente uma cópia profunda de um valor e
o processo de duplicação pode envolver a execução de código arbitrário e a cópia de heap
dados. Consulte a seção [“Variáveis e Dados Interagindo com
Clone”][variables-and-data-interacting-with-clone]seção <!-- ignore --> em
Capítulo 4 para obter mais informações sobre `Clone`.

A derivação de `Clone` implementa o método `clone`, que quando implementado para o
tipo inteiro, chama ` clone`em cada uma das partes do tipo. Isto significa que todos os
campos ou valores no tipo também devem implementar ` Clone`para derivar ` Clone`.

Um exemplo de quando `Clone` é necessário é ao chamar o método `to_vec` em um
slice. O slice não possui as instâncias de tipo que contém, mas o vetor
retornado de `to_vec` precisará possuir suas instâncias, então `to_vec` chama
`clone ` em cada item. Assim, o tipo armazenado no slice deve implementar`Clone`.

O `Copy` trait permite duplicar um valor copiando apenas os bits armazenados em
a pilha; nenhum código arbitrário é necessário. Consulte [“Dados somente de pilha:
Copie”][stack-only-data-copy]seção <!-- ignore --> no Capítulo 4 para obter mais
informações sobre `Copy`.

O `Copy` trait não define nenhum método para impedir que os programadores
sobrecarregando esses métodos e violando a suposição de que nenhum código arbitrário
está sendo executado. Dessa forma, todos os programadores podem assumir que copiar um valor será
muito rápido.

Você pode derivar `Copy` em qualquer tipo cujas partes implementem `Copy`. Um tipo que
implementa ` Copy`também deve implementar ` Clone`porque um tipo que implementa
` Copy `possui uma implementação trivial de` Clone `que executa a mesma tarefa que
` Copy`.

O `Copy` trait raramente é necessário; tipos que implementam `Copy` têm
otimizações disponíveis, o que significa que você não precisa chamar `clone`, o que torna
o código mais conciso.

Tudo o que é possível com `Copy` você também pode realizar com `Clone`, mas o
o código pode ser mais lento ou ter que usar ` clone`em alguns lugares.

### `Hash` for Mapping a Value to a Value of Fixed Size

O `Hash` trait permite que você pegue uma instância de um tipo de tamanho arbitrário e
mapeie essa instância para um valor de tamanho fixo usando uma função hash. Derivando
`Hash ` implementa o método`hash `. A implementação derivada do` hash `
método combina o resultado da chamada de` hash `em cada uma das partes do tipo,
o que significa que todos os campos ou valores também devem implementar` Hash `para derivar` Hash`.

An example of when `Hash` is required is in storing keys in a `HashMap<K, V>`
to store data efficiently.

### `Default` para valores padrão

O `Default` trait permite criar um valor padrão para um tipo. Derivando
`Default ` implementa a função`default `. A implementação derivada do
A função` default `chama a função` default `em cada parte do tipo,
o que significa que todos os campos ou valores no tipo também devem implementar` Default `para
derivar` Default`.

A função `Default::default` é comumente usada em combinação com a estrutura
sintaxe de atualização discutida em [“Criando Instâncias a partir de Outras Instâncias com
Atualização de estrutura
Sintaxe”][creating-instances-from-other-instances-with-struct-update-syntax]<!--
ignore --> no Capítulo 5. Você pode personalizar alguns campos de uma estrutura e
em seguida, defina e use um valor padrão para o restante dos campos usando
`..Default::default()`.

O `Default` trait é necessário quando você usa o método `unwrap_or_default` em
Instâncias `Option<T>`, por exemplo. Se ` Option<T>`for ` None`, o método
` unwrap_or_default `retornará o resultado de` Default::default `para o tipo
` T `armazenado no` Option<T>`.

[creating-instances-from-other-instances-with-struct-update-syntax]: ch05-01-defining-structs.html#creating-instances-from-other-instances-with-struct-update-syntax
[stack-only-data-copy]: ch04-01-what-is-ownership.html#stack-only-data-copy
[variables-and-data-interacting-with-clone]: ch04-01-what-is-ownership.html#variables-and-data-interacting-with-clone
[custom-derive-macros]: ch20-05-macros.html#custom-derive-macros

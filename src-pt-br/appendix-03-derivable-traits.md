## Apêndice C: Traits Deriváveis

Em vários lugares do livro, discutimos o atributo `derive`, que
você pode aplicar a uma definição de struct ou enum. O atributo `derive` gera
código que implementará um trait com sua própria implementação padrão no tipo
que você anotou com a sintaxe `derive`.

Neste apêndice, fornecemos uma referência de todos os traits da biblioteca
padrão que você pode usar com `derive`. Cada seção cobre:

- Quais operadores e métodos derivados deste trait permitirão
- O que faz a implementação do trait fornecido pelo `derive`
- O que a implementação do trait significa sobre o tipo
- As condições nas quais você tem permissão ou não para implementar o trait
- Exemplos de operações que requerem o trait

Se desejar um comportamento diferente daquele fornecido pelo atributo `derive`,
consulte a [documentação da biblioteca padrão](../std/index.html)<!-- ignore -->
de cada trait para obter detalhes sobre como implementá-los manualmente.

Os traits listados aqui são os únicos definidos pela biblioteca padrão que
podem ser implementados em seus tipos usando `derive`. Outros traits definidos
na biblioteca padrão não têm um comportamento padrão sensato, então cabe a você
implementá-los da maneira que faça sentido para o que você está tentando
realizar.

Um exemplo de trait que não pode ser derivado é `Display`, que trata da
formatação para usuários finais. Você deve sempre considerar a maneira
apropriada de exibir um tipo para um usuário final. Quais partes do tipo um usuário final
deveria poder ver? Que partes ele consideraria relevantes? Qual formato dos
dados seria mais relevante para ele? O compilador Rust não tem esse insight, então
ele não pode fornecer um comportamento padrão apropriado para você.

A lista de traits deriváveis fornecida neste apêndice não é exaustiva: as
bibliotecas podem implementar `derive` para seus próprios traits, tornando
verdadeiramente aberta a lista de traits com os quais você pode usar
`derive`. Implementar `derive` envolve o uso de uma macro procedural, assunto
abordado na seção [“Macros `derive`
Personalizadas”][custom-derive-macros]<!-- ignore --> no Capítulo 20.

### `Debug` para saída do programador

O trait `Debug` permite formatação de depuração em strings de formato, o que
você indica adicionando `:?` aos placeholders `{}`.

O trait `Debug` permite imprimir instâncias de um tipo para fins de depuração,
de modo que você e outros programadores que usam seu tipo possam inspecionar
uma instância em um ponto específico da execução de um programa.

O trait `Debug` é necessário, por exemplo, ao usar a macro `assert_eq!`. Essa
macro imprime os valores das instâncias fornecidas como argumentos se a
asserção de igualdade falhar, para que os programadores possam ver por que as
duas instâncias não eram iguais.

### `PartialEq` e `Eq` para comparações de igualdade

O trait `PartialEq` permite comparar instâncias de um tipo para verificar
igualdade e permite o uso dos operadores `==` e `!=`.

Derivar `PartialEq` implementa o método `eq`. Quando `PartialEq` é derivado em
structs, duas instâncias são iguais apenas se _todos_ os campos forem iguais, e
as instâncias não são iguais se _qualquer_ campo não for igual. Quando
derivado em enums, cada variante é igual a si mesma e diferente das outras
variantes.

O trait `PartialEq` é necessário, por exemplo, ao usar a macro `assert_eq!`,
que precisa ser capaz de comparar duas instâncias de um tipo quanto à
igualdade.

O trait `Eq` não possui métodos. Seu objetivo é sinalizar que, para cada valor
do tipo anotado, esse valor é igual a si mesmo. O trait `Eq` só pode ser
aplicado a tipos que também implementam `PartialEq`, embora nem todos os tipos
que implementam `PartialEq` possam implementar `Eq`. Um exemplo disso são os
tipos numéricos de ponto flutuante: a implementação de números de ponto
flutuante estabelece que duas instâncias do valor not-a-number (`NaN`) não são
iguais entre si.

Um exemplo de quando `Eq` é necessário é em chaves de `HashMap<K, V>`, para que
o `HashMap<K, V>` consiga determinar se duas chaves são iguais.

### `PartialOrd` e `Ord` para comparações de ordenação

O trait `PartialOrd` permite comparar instâncias de um tipo para fins de
ordenação. Um tipo que implementa `PartialOrd` pode ser usado com os operadores
`<`, `>`, `<=` e `>=`. Você só pode aplicar o trait `PartialOrd` a tipos que
também implementam `PartialEq`.

Derivar `PartialOrd` implementa o método `partial_cmp`, que retorna um
`Option<Ordering>` e será `None` quando os valores fornecidos não produzirem
uma ordenação. Um exemplo de valor que não produz uma ordenação, embora a
maioria dos valores desse tipo possa ser comparada, é o valor de ponto
flutuante `NaN`. Chamar `partial_cmp` com qualquer número de ponto flutuante e
o valor de ponto flutuante `NaN` retornará `None`.

Quando derivado em structs, `PartialOrd` compara duas instâncias comparando o
valor de cada campo na ordem em que os campos aparecem na definição da struct.
Quando derivado em enums, variantes declaradas antes na definição do enum são
consideradas menores do que as variantes listadas depois.

O trait `PartialOrd` é necessário, por exemplo, para o método `gen_range` do
crate `rand`, que gera um valor aleatório no intervalo especificado por uma
expressão de intervalo.

O trait `Ord` permite saber que, para quaisquer dois valores do tipo anotado,
existirá uma ordenação válida. O trait `Ord` implementa o método `cmp`, que
retorna um `Ordering` em vez de um `Option<Ordering>`, porque uma ordenação
válida sempre será possível. Você só pode aplicar o trait `Ord` a tipos que
também implementam `PartialOrd` e `Eq` e, por sua vez, `Eq` requer
`PartialEq`. Quando derivado em structs e enums, `cmp` se comporta da mesma
forma que a implementação derivada de `partial_cmp` se comporta com
`PartialOrd`.

Um exemplo de quando `Ord` é necessário é ao armazenar valores em um `BTreeSet<T>`,
uma estrutura de dados que armazena dados com base na ordem de classificação dos valores.

### `Clone` e `Copy` para duplicação de valores

O trait `Clone` permite criar explicitamente uma cópia profunda de um valor, e
o processo de duplicação pode envolver a execução de código arbitrário e a
cópia de dados na heap. Consulte a seção [“Variáveis e Dados Interagindo com
Clone”][variables-and-data-interacting-with-clone]<!-- ignore --> no Capítulo 4
para obter mais informações sobre `Clone`.

Derivar `Clone` implementa o método `clone`, que, quando implementado para o
tipo inteiro, chama `clone` em cada uma das partes do tipo. Isso significa que
todos os campos ou valores do tipo também devem implementar `Clone` para que
seja possível derivar `Clone`.

Um exemplo de quando `Clone` é necessário é ao chamar o método `to_vec` em um
slice. O slice não possui as instâncias do tipo que contém, mas o vetor
retornado de `to_vec` precisará possuir suas instâncias, então `to_vec` chama
`clone` em cada item. Assim, o tipo armazenado no slice deve implementar
`Clone`.

O trait `Copy` permite duplicar um valor copiando apenas os bits armazenados na
stack; nenhum código arbitrário é necessário. Consulte a seção [“Dados Somente
de Stack: Copy”][stack-only-data-copy]<!-- ignore --> no Capítulo 4 para obter
mais informações sobre `Copy`.

O trait `Copy` não define nenhum método, para impedir que programadores
sobrecarreguem esses métodos e violem a suposição de que nenhum código
arbitrário está sendo executado. Dessa forma, todos podem assumir que copiar um
valor será muito rápido.

Você pode derivar `Copy` em qualquer tipo cujas partes implementem `Copy`. Um
tipo que implementa `Copy` também deve implementar `Clone`, porque um tipo que
implementa `Copy` possui uma implementação trivial de `Clone` que executa a
mesma tarefa que `Copy`.

O trait `Copy` raramente é necessário; tipos que implementam `Copy` têm
otimizações disponíveis, o que significa que você não precisa chamar `clone`,
deixando o código mais conciso.

Tudo o que é possível com `Copy` também pode ser feito com `Clone`, mas o
código pode ser mais lento ou exigir `clone` em alguns pontos.

### `Hash` para mapear um valor para outro de tamanho fixo

O trait `Hash` permite que você pegue uma instância de um tipo de tamanho
arbitrário e a mapeie para um valor de tamanho fixo usando uma função hash.
Derivar `Hash` implementa o método `hash`. A implementação derivada do método
`hash` combina o resultado da chamada de `hash` em cada uma das partes do
tipo, o que significa que todos os campos ou valores também devem implementar
`Hash` para que seja possível derivar `Hash`.

Um exemplo de quando `Hash` é necessário é ao armazenar chaves em um
`HashMap<K, V>` para guardar dados com eficiência.

### `Default` para valores padrão

O trait `Default` permite criar um valor padrão para um tipo. Derivar
`Default` implementa a função `default`. A implementação derivada da função
`default` chama a função `default` em cada parte do tipo, o que significa que
todos os campos ou valores do tipo também devem implementar `Default` para que
seja possível derivar `Default`.

A função `Default::default` é comumente usada em combinação com a sintaxe de
atualização de struct discutida em [“Criando Instâncias a partir de Outras
Instâncias com Sintaxe de Atualização de Struct”][creating-instances-from-other-instances-with-struct-update-syntax]<!--
ignore --> no Capítulo 5. Você pode personalizar alguns campos de uma struct e
depois definir e usar um valor padrão para o restante dos campos usando
`..Default::default()`.

O trait `Default` é necessário quando você usa o método `unwrap_or_default` em
instâncias de `Option<T>`, por exemplo. Se o `Option<T>` for `None`, o método
`unwrap_or_default` retornará o resultado de `Default::default` para o tipo
`T` armazenado no `Option<T>`.

[creating-instances-from-other-instances-with-struct-update-syntax]: ch05-01-defining-structs.html#creating-instances-from-other-instances-with-struct-update-syntax
[stack-only-data-copy]: ch04-01-what-is-ownership.html#stack-only-data-copy
[variables-and-data-interacting-with-clone]: ch04-01-what-is-ownership.html#variables-and-data-interacting-with-clone
[custom-derive-macros]: ch20-05-macros.html#custom-derive-macros

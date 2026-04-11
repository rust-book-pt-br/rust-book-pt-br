## Separando Módulos em Arquivos Diferentes

Até aqui, todos os exemplos deste capítulo definiram vários módulos em um
único arquivo. Quando os módulos ficam grandes, você pode querer mover suas
definições para arquivos separados para tornar o código mais fácil de navegar.

Por exemplo, vamos partir do código da Listagem 7-17, que tinha vários módulos
do restaurante. Vamos extrair módulos para arquivos, em vez de manter todos
eles definidos no arquivo raiz do crate. Neste caso, o arquivo raiz do crate é
_src/lib.rs_, mas esse procedimento também funciona com crates binários cujo
arquivo raiz é _src/main.rs_.

Primeiro, extrairemos o módulo `front_of_house` para seu próprio arquivo.
Remova o código entre chaves do módulo `front_of_house`, deixando apenas a
declaração `mod front_of_house;`, para que _src/lib.rs_ contenha o código
mostrado na Listagem 7-21. Observe que isso ainda não compilará até criarmos o
arquivo _src/front_of_house.rs_, mostrado na Listagem 7-22.

<Listing number="7-21" file-name="src/lib.rs" caption="Declarando o módulo `front_of_house`, cujo corpo ficará em *src/front_of_house.rs*">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-21-and-22/src/lib.rs}}
```

</Listing>

Em seguida, coloque em um novo arquivo chamado _src/front_of_house.rs_ o código
que estava entre chaves, como mostra a Listagem 7-22. O compilador sabe que
deve procurar nesse arquivo porque encontrou, na raiz do crate, a declaração do
módulo com o nome `front_of_house`.

<Listing number="7-22" file-name="src/front_of_house.rs" caption="Definições dentro do módulo `front_of_house` em *src/front_of_house.rs*">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-21-and-22/src/front_of_house.rs}}
```

</Listing>

Observe que você só precisa carregar um arquivo com uma declaração `mod` _uma
vez_ em sua árvore de módulos. Depois que o compilador sabe que o arquivo faz
parte do projeto, e sabe onde o código reside na árvore de módulos por causa de
onde você colocou a instrução `mod`, os demais arquivos do projeto devem se
referir ao código desse arquivo usando um caminho para o local em que ele foi
declarado, como vimos na seção [“Caminhos para Referência a um Item na Árvore
de Módulos”][paths]<!-- ignore -->. Em outras palavras, `mod` _não_ é uma
operação de “inclusão”, como você pode ter visto em outras linguagens de
programação.

Em seguida, extrairemos o módulo `hosting` para seu próprio arquivo. O processo
é um pouco diferente porque `hosting` é um módulo filho de `front_of_house`, e
não do módulo raiz. Colocaremos o arquivo de `hosting` em um novo diretório que
terá o nome de seus ancestrais na árvore de módulos, neste caso
_src/front_of_house_.

Para começar a mover `hosting`, alteramos _src/front_of_house.rs_ para conter
apenas a declaração do módulo `hosting`:

<Listing file-name="src/front_of_house.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/no-listing-02-extracting-hosting/src/front_of_house.rs}}
```

</Listing>

Depois, criamos o diretório _src/front_of_house_ e um arquivo _hosting.rs_ para
conter as definições feitas no módulo `hosting`:

<Listing file-name="src/front_of_house/hosting.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/no-listing-02-extracting-hosting/src/front_of_house/hosting.rs}}
```

</Listing>

Se, em vez disso, colocássemos _hosting.rs_ no diretório _src_, o compilador
esperaria que o código de _hosting.rs_ estivesse em um módulo `hosting`
declarado na raiz do crate, e não declarado como filho do módulo
`front_of_house`. As regras do compilador sobre quais arquivos verificar para o
código de quais módulos fazem com que os diretórios e arquivos reflitam de
perto a árvore de módulos.

> ### Caminhos de Arquivo Alternativos
>
> Até agora, cobrimos os caminhos de arquivo mais idiomáticos usados pelo
> compilador Rust, mas Rust também oferece suporte a um estilo mais antigo de
> caminho de arquivo. Para um módulo chamado `front_of_house` declarado na raiz
> do crate, o compilador procurará o código do módulo em:
>
> - _src/front_of_house.rs_ (o que acabamos de ver)
> - _src/front_of_house/mod.rs_ (estilo mais antigo, ainda suportado)
>
> Para um módulo chamado `hosting`, que é um submódulo de `front_of_house`, o
> compilador procurará o código do módulo em:
>
> - _src/front_of_house/hosting.rs_ (o que acabamos de ver)
> - _src/front_of_house/hosting/mod.rs_ (estilo mais antigo, ainda suportado)
>
> Se você usar os dois estilos para o mesmo módulo, receberá um erro do
> compilador. Misturar os dois estilos em módulos diferentes dentro do mesmo
> projeto é permitido, mas pode ser confuso para quem estiver navegando pelo
> código.
>
> A principal desvantagem do estilo que usa arquivos chamados _mod.rs_ é que o
> projeto pode acabar tendo muitos arquivos com esse mesmo nome, o que pode
> confundir quando vários deles estão abertos ao mesmo tempo no editor.

Movemos o código de cada módulo para um arquivo separado, e a árvore de módulos
permanece a mesma. As chamadas de função em `eat_at_restaurant` funcionarão sem
qualquer modificação, mesmo que as definições estejam agora em arquivos
diferentes. Essa técnica permite mover módulos para novos arquivos à medida que
eles crescem.

Observe que a instrução `pub use crate::front_of_house::hosting` em
_src/lib.rs_ também não mudou, e `use` tampouco tem qualquer impacto sobre
quais arquivos são compilados como parte do crate. A palavra-chave `mod`
declara módulos, e Rust procura em um arquivo com o mesmo nome do módulo o
código que entrará nesse módulo.

## Resumo

Rust permite dividir um pacote em vários crates e um crate em vários módulos,
de modo que você possa se referir a itens definidos em um módulo a partir de
outro módulo. Você pode fazer isso especificando caminhos absolutos ou
relativos. Esses caminhos podem ser trazidos para o escopo com uma instrução
`use`, para que você possa usar um caminho mais curto em usos repetidos daquele
item dentro do mesmo escopo. O código de um módulo é privado por padrão, mas
você pode tornar definições públicas adicionando a palavra-chave `pub`.

No próximo capítulo, veremos algumas estruturas de dados de coleção da
biblioteca padrão que você poderá usar em seu código bem organizado.

[paths]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html

## Separando módulos em arquivos diferentes

Até agora, todos os exemplos deste capítulo definiam vários módulos em um único
arquivo. Quando os módulos ficam grandes, talvez você queira mover suas
definições para arquivos separados, para que o código fique mais fácil de
navegar.

Por exemplo, vamos partir do código da Listagem 7-17, que tinha vários módulos
relacionados ao restaurante. Vamos extrair módulos para arquivos em vez de
manter todos eles definidos no arquivo raiz da crate. Neste caso, o arquivo
raiz da crate é _src/lib.rs_, mas esse procedimento também funciona com crates
binárias cujo arquivo raiz é _src/main.rs_.

Primeiro, vamos extrair o módulo `front_of_house` para seu próprio arquivo.
Remova o código de dentro das chaves do módulo `front_of_house`, deixando
apenas a declaração `mod front_of_house;`, para que _src/lib.rs_ contenha o
código mostrado na Listagem 7-21. Observe que isso ainda não compilará até
criarmos o arquivo _src/front_of_house.rs_ mostrado na Listagem 7-22.

<Listing number="7-21" file-name="src/lib.rs" caption="Declarando o módulo `front_of_house`, cujo corpo ficará em *src/front_of_house.rs*">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-21-and-22/src/lib.rs}}
```

</Listing>

Em seguida, coloque o código que estava entre as chaves em um novo arquivo
chamado _src/front_of_house.rs_, como mostra a Listagem 7-22. O compilador sabe
que deve procurar nesse arquivo porque encontrou, na raiz da crate, a
declaração de módulo com o nome `front_of_house`.

<Listing number="7-22" file-name="src/front_of_house.rs" caption="Definições dentro do módulo `front_of_house` em *src/front_of_house.rs*">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-21-and-22/src/front_of_house.rs}}
```

</Listing>

Observe que você só precisa carregar um arquivo com uma declaração `mod` _uma
vez_ na árvore de módulos. Depois que o compilador sabe que o arquivo faz parte
do projeto, e sabe em que ponto da árvore de módulos aquele código se encontra
por causa do lugar onde você colocou a instrução `mod`, os outros arquivos do
projeto devem se referir ao código carregado usando um caminho até o ponto onde
ele foi declarado, como vimos na seção [“Caminhos para se referir a um item na
árvore de módulos”][paths]<!-- ignore -->. Em outras palavras, `mod` _não_ é
uma operação de “include”, como você pode ter visto em outras linguagens de
programação.

Em seguida, vamos extrair o módulo `hosting` para seu próprio arquivo. O
processo é um pouco diferente porque `hosting` é um módulo filho de
`front_of_house`, e não do módulo raiz. Vamos colocar o arquivo de `hosting` em
um novo diretório nomeado de acordo com seus ancestrais na árvore de módulos;
neste caso, _src/front_of_house_.

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
declarado na raiz da crate, e não como filho do módulo `front_of_house`. As
regras do compilador sobre quais arquivos verificar para o código de quais
módulos fazem com que diretórios e arquivos correspondam de maneira mais
próxima à árvore de módulos.

> ### Caminhos alternativos de arquivo
>
> Até agora, cobrimos os caminhos de arquivo mais idiomáticos que o compilador
> Rust usa, mas Rust também oferece suporte a um estilo mais antigo de caminho
> de arquivo. Para um módulo chamado `front_of_house` declarado na raiz da
> crate, o compilador procurará o código do módulo em:
>
> - _src/front_of_house.rs_ (o que cobrimos)
> - _src/front_of_house/mod.rs_ (estilo mais antigo, ainda suportado)
>
> Para um módulo chamado `hosting`, que é um submódulo de `front_of_house`, o
> compilador procurará o código do módulo em:
>
> - _src/front_of_house/hosting.rs_ (o que cobrimos)
> - _src/front_of_house/hosting/mod.rs_ (estilo mais antigo, ainda suportado)
>
> Se você usar os dois estilos para o mesmo módulo, receberá um erro do
> compilador. Misturar os dois estilos para módulos diferentes dentro do mesmo
> projeto é permitido, mas pode ser confuso para quem estiver navegando pelo
> código.
>
> A principal desvantagem do estilo que usa arquivos chamados _mod.rs_ é que o
> projeto pode acabar com muitos arquivos de mesmo nome, o que pode se tornar
> confuso quando vários deles estão abertos no editor ao mesmo tempo.

Movemos o código de cada módulo para um arquivo separado, e a árvore de
módulos permanece a mesma. As chamadas de função em `eat_at_restaurant`
continuarão funcionando sem nenhuma modificação, mesmo que as definições agora
estejam em arquivos diferentes. Essa técnica permite mover módulos para novos
arquivos à medida que eles crescem.

Observe que a instrução `pub use crate::front_of_house::hosting` em _src/lib.rs_
também não mudou, e `use` tampouco tem qualquer impacto sobre quais arquivos
são compilados como parte da crate. A palavra-chave `mod` declara módulos, e o
Rust procura em um arquivo com o mesmo nome do módulo o código que deve ir para
esse módulo.

## Resumo

Rust permite dividir um pacote em várias crates e uma crate em módulos, para
que você possa se referir a itens definidos em um módulo a partir de outro.
Você pode fazer isso especificando caminhos absolutos ou relativos. Esses
caminhos podem ser trazidos para o escopo com uma instrução `use`, para que
você possa usar um caminho mais curto em múltiplos usos do item naquele
escopo. O código de módulo é privado por padrão, mas você pode tornar
definições públicas adicionando a palavra-chave `pub`.

No próximo capítulo, veremos algumas estruturas de dados de coleção da
biblioteca padrão que você poderá usar no seu código bem organizado.

[paths]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html

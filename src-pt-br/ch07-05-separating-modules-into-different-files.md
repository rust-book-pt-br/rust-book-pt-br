## Separando Módulos em Arquivos Diferentes

Até agora, todos os exemplos neste capítulo definiram vários módulos em um arquivo.
Quando os módulos ficam grandes, você pode querer mover suas definições para um local separado.
arquivo para tornar o código mais fácil de navegar.

Por exemplo, vamos começar com o código da Listagem 7.17 que tinha vários
módulos de restaurante. Extrairemos módulos em arquivos em vez de ter todos os
módulos definidos no arquivo raiz da caixa. Neste caso, o arquivo raiz da caixa é
_src/lib.rs_, mas este procedimento também funciona com caixas binárias cuja raiz da caixa
arquivo é _src/main.rs_.

Primeiro, extrairemos o módulo `front_of_house` para seu próprio arquivo. Remova o
código entre chaves para o módulo `front_of_house`, deixando apenas
a declaração `mod front_of_house;`, para que _src/lib.rs_ contenha o código
mostrado na Listagem 7-21. Observe que isso não será compilado até que criemos o
_src/front_of_house.rs_ na Listagem 7-22.

<Listing number="7-21" file-name="src/lib.rs" caption="Declaring the `front_of_house` module whose body will be in *src/front_of_house.rs*">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-21-and-22/src/lib.rs}}
```

</Listing>

Em seguida, coloque o código que estava entre chaves em um novo arquivo chamado
_src/front_of_house.rs_, conforme mostrado na Listagem 7-22. O compilador sabe olhar
neste arquivo porque se deparou com a declaração do módulo na raiz da caixa
com o nome `front_of_house`.

<Listing number="7-22" file-name="src/front_of_house.rs" caption="Definitions inside the `front_of_house` module in *src/front_of_house.rs*">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/listing-07-21-and-22/src/front_of_house.rs}}
```

</Listing>

Observe que você só precisa carregar um arquivo usando uma declaração `mod` _uma vez_ em seu
árvore de módulos. Uma vez que o compilador saiba que o arquivo faz parte do projeto (e saiba
onde na árvore do módulo o código reside por causa de onde você colocou o `mod`
instrução), outros arquivos em seu projeto devem se referir ao código do arquivo carregado
usando um caminho para onde foi declarado, conforme abordado em [“Caminhos para referência
para um item na seção Árvore de Módulos”][paths]<!-- ignore -->. Em outras palavras,
`mod` _não_ é uma operação de “inclusão” que você pode ter visto em outros
linguagens de programação.

A seguir, extrairemos o módulo `hosting` para seu próprio arquivo. O processo é um pouco
diferente porque `hosting` é um módulo filho de `front_of_house`, não do
módulo raiz. Colocaremos o arquivo `hosting` em um novo diretório que será
nomeado por seus ancestrais na árvore do módulo, neste caso _src/front_of_house_.

Para começar a mover `hosting`, alteramos _src/front_of_house.rs_ para conter apenas
a declaração do módulo `hosting`:

<Listing file-name="src/front_of_house.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/no-listing-02-extracting-hosting/src/front_of_house.rs}}
```

</Listing>

Em seguida, criamos um diretório _src/front_of_house_ e um arquivo _hosting.rs_ para
contém as definições feitas no módulo `hosting`:

<Listing file-name="src/front_of_house/hosting.rs">

```rust,ignore
{{#rustdoc_include ../listings/ch07-managing-growing-projects/no-listing-02-extracting-hosting/src/front_of_house/hosting.rs}}
```

</Listing>

Se, em vez disso, colocarmos _hosting.rs_ no diretório _src_, o compilador
espere que o código _hosting.rs_ esteja em um módulo `hosting` declarado na caixa
root e não declarado como filho do módulo `front_of_house`. O
regras do compilador para quais arquivos verificar o código de quais módulos significam o
diretórios e arquivos correspondem melhor à árvore do módulo.

> ### Caminhos de arquivo alternativos
>
> Até agora, cobrimos os caminhos de arquivo mais idiomáticos que o compilador Rust usa,
> mas Rust também oferece suporte a um estilo mais antigo de caminho de arquivo. Para um módulo chamado
> `front_of_house` declarado na raiz da caixa, o compilador procurará o
> código do módulo em:
>
> - _src/front_of_house.rs_ (o que cobrimos)
> - _src/front_of_house/mod.rs_ (estilo antigo, caminho ainda suportado)
>
> Para um módulo chamado `hosting` que é um submódulo de `front_of_house`, o
> o compilador procurará o código do módulo em:
>
> - _src/front_of_house/hosting.rs_ (o que cobrimos)
> - _src/front_of_house/hosting/mod.rs_ (estilo antigo, caminho ainda suportado)
>
> Se você usar os dois estilos para o mesmo módulo, receberá um erro do compilador.
> Usar uma mistura de ambos os estilos para módulos diferentes no mesmo projeto é
> permitido, mas pode ser confuso para as pessoas que navegam no seu projeto.
>
> A principal desvantagem do estilo que usa arquivos chamados _mod.rs_ é que seu
> projeto pode acabar com muitos arquivos chamados _mod.rs_, o que pode ficar confuso
> quando você os abre em seu editor ao mesmo tempo.

Movemos o código de cada módulo para um arquivo separado e a árvore do módulo permanece
o mesmo. As chamadas de função em `eat_at_restaurant` funcionarão sem qualquer
modificação, mesmo que as definições residam em arquivos diferentes. Esse
técnica permite mover módulos para novos arquivos à medida que aumentam de tamanho.

Observe que a instrução `pub use crate::front_of_house::hosting` em
_src/lib.rs_ também não mudou, nem `use` tem qualquer impacto em quais arquivos
são compilados como parte da caixa. A palavra-chave `mod` declara módulos e Rust
procura em um arquivo com o mesmo nome do módulo o código que entra
esse módulo.

## Resumo

Rust permite dividir um pacote em várias caixas e uma caixa em módulos para que
que você pode consultar itens definidos em um módulo de outro módulo. Você pode
faça isso especificando caminhos absolutos ou relativos. Esses caminhos podem ser trazidos
no escopo com uma instrução `use` para que você possa usar um caminho mais curto para
múltiplos usos do item nesse escopo. O código do módulo é privado por padrão, mas
você pode tornar as definições públicas adicionando a palavra-chave `pub`.

No próximo capítulo, veremos algumas estruturas de coleta de dados no
biblioteca padrão que você pode usar em seu código bem organizado.

[paths]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html

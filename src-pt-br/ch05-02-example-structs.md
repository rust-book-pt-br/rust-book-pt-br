## Um Exemplo de Programa que Usa Structs

Para entender quando podemos querer usar structs, vamos escrever um programa
que calcula a área de um retângulo. Vamos começar com as variáveis individuais
e em seguida, refazer o programa até usar structs em vez das variáveis.

Vamos fazer um novo projeto binário com Cargo, chamado *retângulos*, que terá
o comprimento e a largura do retângulo especificados em pixels e calculará a
área do retângulo. A Listagem 5-8 mostra um programa curto com uma maneira de
fazer isso no nosso projeto *src/main.rs*:

<span class="filename">Filename: src/main.rs</span>

```rust
fn main() {
    let length1 = 50;
    let width1 = 30;

    println!(
        "The area of the rectangle is {} square pixels.",
        area(length1, width1)
    );
}

fn area(length: u32, width: u32) -> u32 {
    length * width
}
```

<span class="caption">Listagem 5-8: Calculando a área de um retângulo
especificado pelo seu comprimento e largura em variáveis separadas</span>

Agora, executamos este programa usando `cargo run`:

```text
The area of the rectangle is 1500 square pixels.
```

### Refazendo com Tuplas

Embora a Listagem 5-8 funcione e descubra a área do retângulo chamando a função
`area` com cada dimensão, podemos fazer melhor. O comprimento e a largura
estão relacionados uns aos outros porque juntos eles descrevem um retângulo.

O problema com este método é evidente na assinatura de `area`:

```rust,ignore
fn area(length: u32, width: u32) -> u32 {
```

A função `area` supostamente calcula a área de um retângulo, mas a função
que escrevemos tem dois parâmetros. Os parâmetros estão relacionados, mas isso
não está indicado em nenhum lugar no nosso programa. Seria mais legível e
mais fácil de manter agrupar comprimento e largura. Já discutimos uma maneira de
fazer isso ao falar sobre tuplas no Capítulo 3. A Listagem 5-9 mostra outra versão do
nosso programa que usa tuplas:

<span class="filename">Filename: src/main.rs</span>

```rust
fn main() {
    let rect1 = (50, 30);

    println!(
        "The area of the rectangle is {} square pixels.",
        area(rect1)
    );
}

fn area(dimensions: (u32, u32)) -> u32 {
    dimensions.0 * dimensions.1
}
```

<span class="caption">Listagem 5-9: Especificando o comprimento e a largura de um
retângulo por meio de uma tupla.</span>

De certa forma, este programa é melhor. As tuplas nos permitem adicionar um pouco
de estrutura, e agora estamos passando apenas um argumento. Mas, de outra forma, esta versão é
menos clara: as tuplas não nomeiam seus elementos, então o cálculo fica
mais confuso porque precisamos indexar as partes da tupla.

Para o cálculo da área, trocar comprimento e largura não faria diferença, mas,
se quisermos desenhar o retângulo na tela, isso já importa! Teríamos de ter em
mente que `comprimento` é o índice `0` da tupla e `largura` é o índice `1`.
Se outra pessoa trabalhar com esse código, também terá de descobrir isso e manter
essa informação em mente. Seria fácil esquecer ou misturar esses valores e causar erros,
porque o significado dos dados não está explícito no código.

### Refatorando com Structs: Adicionando Mais Significado

Usamos structs para dar significado aos dados usando rótulos. Podemos
transformar a tupla que estamos usando em um tipo de dados, com um nome
para o conjunto bem como nomes para as partes, como mostra a Listagem 5-10:

<span class="filename">Filename: src/main.rs</span>

```rust
struct Rectangle {
    length: u32,
    width: u32,
}

fn main() {
    let rect1 = Rectangle { length: 50, width: 30 };

    println!(
        "The area of the rectangle is {} square pixels.",
        area(&rect1)
    );
}

fn area(rectangle: &Rectangle) -> u32 {
    rectangle.length * rectangle.width
}
```

<span class="caption">Listagem 5-10: Definindo uma struct `Rectangle`</span>

Aqui definimos uma struct chamada `Rectangle`. Dentro das chaves,
definimos os campos `length` e `width`, ambos do tipo `u32`.
Em `main`, criamos uma instância específica de `Rectangle` que tem
comprimento 50 e largura 30.

Nossa função `area` agora é definida com um parâmetro, que chamamos
`rectangle`, cujo tipo é um empréstimo imutável de uma instância da struct
`Rectangle`. Como mencionado no Capítulo 4, queremos tomar emprestada a struct,
em vez de tomar posse dela. Dessa forma, `main` mantém a propriedade de `rect1`
e pode continuar usando esse valor, razão pela qual usamos `&` tanto na assinatura
da função quanto na chamada.

A função `area` acessa os campos `length` e `width` da instância
`Rectangle`. A assinatura de `area` agora expressa exatamente o que queremos
dizer: calcular a área de um `Rectangle` usando seus campos `length` e `width`.
Isso transmite que comprimento e largura estão relacionados e dá nomes descritivos
aos valores, em vez de usar os índices `0` e `1` de uma tupla.

### Adicionando Funcionalidade Útil com Traits Derivadas

Seria útil para ser capaz de imprimir uma instância do `Rectangle` enquanto
estamos depurando o nosso programa, a fim de consultar os valores para todos
os seus campos. Lista 5-11 usa a macro 'println!' como temos usado nos 
capítulos anteriores:

<span class="filename">Filename: src/main.rs</span>

```rust,ignore
struct Rectangle {
    length: u32,
    width: u32,
}

fn main() {
    let rect1 = Rectangle { length: 50, width: 30 };

    println!("rect1 is {}", rect1);
}
```

<span class="caption">Lista 5-11: Tentativa de impressão de uma instância
de `Rectangle`</span>

Quando executamos este código, obtemos um erro com esta mensagem interna:

```text
error[E0277]: the trait bound `Rectangle: std::fmt::Display` is not satisfied
```

A macro 'println!' pode fazer muitos tipos de formatação, e por padrão, 
`{}` diz a `println!`, para utilizar a formatação conhecida como `Display`:
saída destinada para consumo do utilizador final. Os tipos primitivos que vimos
até agora implementam `Display` por padrão, porque só há uma maneira que você 
deseja mostrar um `1` ou qualquer outro tipo primitivo para um usuário. Mas com
Structs, a forma como `println!` deve formatar a saída é menos clara, pois 
existem mais possibilidades de exibição: você quer vírgulas ou não? Deseja 
imprimir as chaves `{}`? Todos os campos devem ser mostrados? Devido a esta
ambiguidade, Rust não tenta adivinhar o que queremos e as structs não têm uma 
implementação de `Display`.

Se continuarmos a ler os erros, encontramos esta nota explicativa:

```text
Avisa que `Rectangle` não pode ser formatado com o formato padrão;
Devemos tentar usar `:?` ao invés, se estivermos a usar um formato de string
```

Vamos tentar! A chamada da macro `println!` agora vai ficar como 
`println!("rect1 is {:?}", rect1);`. Colocando o especificador `:?` dentro 
de `{}` diz à `println!` que nós queremos usar um formato de saída chamado 
`Debug`. `Debug` é uma trait (característica) que nos permite imprimir as nossas
structs de uma maneira útil para os desenvolvedores para que possamos ver o seu
valor enquanto estamos a depurar do nosso código.

Executamos o código com esta mudança. Pô! Nós ainda obtemos um erro:

```text
error: the trait bound `Rectangle: std::fmt::Debug` is not satisfied
```

Mas, novamente, o compilador dá-nos uma nota útil:

```text
note: `Rectangle` cannot be formatted using `:?`; if it is defined in your
crate, add `#[derive(Debug)]` or manually implement it
```
nota: `Rectangle` não pode ser formatado usando `:?`; se estiver definido no 
nosso crate, adicionamos `#[derive(Debug)]` ou adicionamos manualmente.


Rust *inclui* funcionalidades para imprimir informações de depuração, mas
temos de inseri-la explicitamente para tornar essa funcionalidade disponível
para nossa struct. Para isso, adicionamos a anotação `#[derive(Debug)]` pouco
antes da definição da struct, como mostrado na Lista 5-12:

<span class="filename">Filename: src/main.rs</span>

```rust
#[derive(Debug)]
struct Rectangle {
    length: u32,
    width: u32,
}

fn main() {
    let rect1 = Rectangle { length: 50, width: 30 };

    println!("rect1 is {:?}", rect1);
}
```

<span class="caption">Lista 5-12: Adicionando a anotação para derivar 
caracteristica`Debug` e imprimir a instância `Rectangle` usando a formatação 
debug</span>

Agora, quando executamos o programa, não teremos quaisquer erros e vamos ver
a seguinte informação:

```text
rect1 is Rectangle { length: 50, width: 30 }
```

Boa! Não é o mais bonito, mas mostra os valores de todos os campos para essa 
instância, que irá ajudar durante a depuração. Quando temos structs maiores, 
é útil ter a informação um pouco mais fácil de ler; nesses casos, podemos usar
`{:#?}` ao invés de `{:?}` na frase `println!`. Quando utilizamos o `{:#?}` no
exemplo, vamos ver a informação como esta:

```text
rect1 is Rectangle {
    length: 50,
    width: 30
}
```

Rust forneceu um número de caracteristicas (traits) para usarmos com a notação 
`derive` que pode adicionar um comportamento útil aos nossos tipos 
personalizados. Esses traits e seus comportamentos estão listadas no Apêndice C.
Abordaremos como implementar estes traits com comportamento personalizado, bem 
como a forma de criar as suas próprias traits (características) no Capítulo 10.

A nossa função `area` é muito específica: ela apenas calcula a área de 
retângulos. Seria útil fixar este comportamento à nossa struc `Rectangle`,
porque não vai funcionar com qualquer outro tipo. Vejamos como podemos 
continuar a refazer este código tornando a função `area` em um *método* `area`
definido no nosso `Rectangle`.

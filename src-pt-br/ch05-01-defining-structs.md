## Definindo e Instanciando Structs

Structs são semelhantes às tuplas, que foram discutidas no Capítulo 3. Como
tuplas, os elementos de uma struct podem ser de tipos diferentes. Ao contrário
das tuplas, em uma struct damos nome a cada pedaço de dado, para que fique
claro o que cada valor representa. Como resultado, structs são mais flexíveis
que tuplas: não precisamos saber a ordem dos dados para especificar ou acessar
os valores de uma instância.

Para definir uma struct, digitamos a palavra-chave `struct` e o nome da struct.
O nome da struct deve descrever o significado dos dados agrupados. Em seguida,
 dentro das chaves (`{}`), definimos os nomes e os tipos dos dados, que chamamos de
*campos*. Por exemplo, a Listagem 5-1 mostra uma struct para armazenar informações
sobre a conta de um usuário:

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}
```
<span class="caption">Listagem 5-1: Definição da struct `User`</span>

Para usar uma struct depois de a definirmos, criamos uma *instância* dessa
struct, especificando valores concretos para cada um dos campos. Criamos uma
instância informando o nome da struct e, depois, entre chaves, adicionando
pares `campo: valor`, em que as chaves são os nomes dos campos e os valores são
os dados que queremos armazenar nesses campos. Não precisamos informar os
campos na mesma ordem em que foram declarados na struct.
Em outras palavras, a definição da struct é como um modelo geral para o tipo,
e as instâncias preenchem esse modelo com dados específicos para criar valores
desse tipo. Por exemplo, podemos declarar um usuário específico como mostrado
na Listagem 5-2:

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
let user1 = User {
    email: String::from("alguem@exemplo.com"),
    username: String::from("algumnome123"),
    active: true,
    sign_in_count: 1,
};
```

<span class="caption">Listagem 5-2: Criando uma instância da struct `User`</span>

Para obter um valor específico de uma struct, podemos usar a notação de
ponto. Se quiséssemos acessar o endereço de email do usuário, poderíamos usar
`user1.email` sempre que quiséssemos esse valor. Para alterar um valor em uma
struct, se a instância for mutável, podemos usar a notação de ponto e atribuir
um novo valor a um campo específico. A Listagem 5-3 mostra como alterar o valor do campo `email`
de uma instância de `User` mutável:

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
let mut user1 = User {
    email: String::from("alguem@exemplo.com"),
    username: String::from("algumnome123"),
    active: true,
    sign_in_count: 1,
};

user1.email = String::from("outroemail@exemplo.com");
```

<span class="caption">Listagem 5-3: Mudando o valor no campo `email` da
instância de `User`</span>


<h3>Usando a Abreviação de Inicialização de Campos</h3>

Se você tiver variáveis com os mesmos nomes dos campos da struct, pode usar o
*field init shorthand* (abreviação de inicialização de campos). Antes, porém,
vejamos a forma mais detalhada de inicializar uma instância de struct.
A função chamada `build_user`, mostrada aqui na Listagem 5-4, tem parâmetros
chamados `email` e `username`. A função cria e retorna uma instância de `User`:

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
fn build_user(email: String, username: String) -> User {
    User {
        email: email,
        username: username,
        active: true,
        sign_in_count: 1,
    }
}
```

<span class="caption">Listagem 5-4: Uma função `build_user` que recebe um endereço
de email e um nome de usuário e retorna uma instância de `User`
</span>

Como os nomes dos parâmetros `email` e `username` são exatamente os mesmos dos
campos da struct `User`, podemos reescrever `build_user` sem repetir `email` e
`username`, como mostrado na Listagem 5-5. Esta versão de `build_user` se
comporta da mesma maneira que a da Listagem 5-4. A sintaxe abreviada torna casos como esse mais curtos de escrever,
especialmente quando structs têm muitos campos.

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
fn build_user(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
        sign_in_count: 1,
    }
}
```

<span class="caption">Listagem 5-5: Uma função `build_user` que usa a abreviação de
inicialização de campos porque os parâmetros `email` e `username` têm o mesmo nome dos
campos da struct</span>

<h3>A Criação de instâncias de outras instâncias com Sintaxe de Atualização da
Struct (Struct Update Syntax)</h3>

É frequentemente útil criar uma nova instância a partir de uma antiga instância, 
usando a maioria dos valores da antiga instância mas mudando alguns. A Lista 5-6
mostra um exemplo da criação de uma nova instância do `user1` em `user2` através
da definição dos valores de `e-mail` e `username` mas usando os mesmos valores 
para o resto dos campos do exemplo `user1` que criamos na Lista 5-2:

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
# let user1 = User {
#     email: String::from("alguem@exemplo.com"),
#     username: String::from("algumnome123"),
#     active: true,
#     sign_in_count: 1,
# };
#
let user2 = User {
    email: String::from("outro@exemplo.com"),
    username: String::from("outronome567"),
    active: user1.active,
    sign_in_count: user1.sign_in_count,
};
```

<span class="caption">Lista 5-6: Criação de uma nova instância do `User`, 
`user2`, e a definição de alguns campos para os valores dos mesmos campos
do `user1`</span>


A *struct update syntax* (Sintaxe de Atualização da Struct) alcança o mesmo 
efeito que o código na Lista 5-6 usando menos código. A sintaxe de atualização
struct usa `..` para especificar que os campos restantes não explicitamente 
configurados devem ter o mesmo valor que os campos na determinada instância. 
O código na Lista 5-7 também cria uma instância no `user2`, que tem um valor
diferente de `e-mail` e `nome de usuário` mas tem os mesmos valores para os 
`active` e `sign_no_count` campos que `user1`:


```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
# let user1 = User {
#     email: String::from("someone@example.com"),
#     username: String::from("someusername123"),
#     active: true,
#     sign_in_count: 1,
# };
#
let user2 = User {
    email: String::from("another@example.com"),
    username: String::from("anotherusername567"),
    ..user1
};
```

<span class="caption"> Lista 5-7: Usando struct update sintax para definir
valores de `email` e `username` de uma nova instância do `User` mas usar o 
resto dos valores dos campos da instância da variável `user1`</span>

### Structs-Tuplas sem Campos Nomeados para Criar Tipos Diferentes

Podemos também definir structs que parecem semelhantes a tuplas, chamadas 
*tuple structs*, que têm o significado que o nome struct fornece, mas não 
têm os nomes associados com os seus campos, apenas os tipos dos campos. 
A definição de uma struct-tupla, ainda começa com a palavra-chave `struct` e o
nome da struct, que é seguida pelos tipos na tupla. Por exemplo, aqui estão
as definições e usos da struct-tupla chamados `Color` e `Point`:

```rust
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

let black = Color(0, 0, 0);
let origin = Point(0, 0, 0);
```

Note que os valores `black` e `origin` são diferentes tipos, uma vez que eles
são de diferentes instâncias struct-tupla. Cada struct que definimos é o seu 
próprio tipo, embora os campos dentro do struct tenham os mesmos tipos. 
No geral as struct-tuplas comportam-se como instâncias de tuplas, que 
discutimos no Capítulo 3.

### Estruturas Unit-Like sem Quaisquer Campos

Podemos também definir structs que não têm quaisquer campos! Estes são chamados
de *unit-like structs* (unidades como structs) porque eles se comportam da mesma
forma que `()`, o tipo unidade. Unit-like structs podem ser úteis em situações,
como quando você precisa implementar um trait de algum tipo, mas você não tem 
quaisquer dados que você deseja armazenar no tipo em si. Traits será discutido 
no Capítulo 10.


### A Propriedade de Dados da Struct

Na definição de struct `User`, na Lista 5-1, utilizamos a propriedade tipo 
`String` em vez de `&str`, uma ‘fatia’ tipo string. Esta é uma escolha 
deliberada, porque queremos que instâncias deste struct possuam todos os seus 
dados e para que os dados sejam válidos por todo o tempo que o struct é válido.

É possível para structs armazenar referências a dados que são propriedade de 
algo diferente, mas para isso requer o uso de *lifetimes* (tempo de vida), 
uma característica de Rust que é discutida no Capítulo 10. Lifetimes garantem
que os dados referenciados por um struct são válidos enquanto struct existir.
Vamos dizer que você tenta armazenar uma referência em um struct sem 
especificar lifetimes, como este:

<span class="filename">Filename: src/main.rs</span>

```rust,ignore
struct User {
   username: &str,
    email: &str,
    sign_in_count: u64,
    active: bool,
}

fn main() {
    let user1 = User {
        email: "someone@example.com",
        username: "someusername123",
        active: true,
        sign_in_count: 1,
    };
}
```

O compilador irá reclamar que é preciso especificar lifetimes:

```text
error[E0106]: missing lifetime specifier
 -->
  |
2 |     username: &str,
  |               ^ expected lifetime parameter

 error[E0106]: missing lifetime specifier
 -->
  |
3 |     email: &str,
  |            ^ expected lifetime parameter
```

Vamos discutir como corrigir estes erros, assim você pode armazenar referências
em structs no Capítulo 10, mas por agora, vamos corrigir erros como estes 
usando tipos de propriedade, utilizando `String` em vez de referências 
como `&str`.

## Apêndice A: Palavras-chave

As listas a seguir contêm palavras-chave reservadas para uso atual ou futuro
na linguagem Rust. Por isso, elas não podem ser usadas como identificadores,
exceto como identificadores raw, como discutimos na seção [“Identificadores
raw”][raw-identifiers]<!-- ignore -->. _Identificadores_ são nomes de funções,
variáveis, parâmetros, campos de struct, módulos, crates, constantes, macros,
valores estáticos, atributos, tipos, traits ou lifetimes.

[raw-identifiers]: #identificadores-raw

### Palavras-chave atualmente em uso

A seguir, está a lista das palavras-chave atualmente em uso, com a descrição
da funcionalidade de cada uma.

- **`as`**: Realiza castings primitivos, desambigua o trait específico que
  contém um item ou renomeia itens em instruções `use`.
- **`async`**: Retorna um `Future` em vez de bloquear a thread atual.
- **`await`**: Suspende a execução até que o resultado de um `Future` esteja
  pronto.
- **`break`**: Sai imediatamente de um loop.
- **`const`**: Define itens constantes ou ponteiros raw constantes.
- **`continue`**: Continua para a próxima iteração do loop.
- **`crate`**: Em um caminho de módulo, refere-se à raiz da crate.
- **`dyn`**: Despacho dinâmico para um trait object.
- **`else`**: Caminho alternativo para as construções de fluxo de controle
  `if` e `if let`.
- **`enum`**: Define uma enumeração.
- **`extern`**: Faz o link de uma função ou variável externa.
- **`false`**: Literal booleano falso.
- **`fn`**: Define uma função ou o tipo de ponteiro de função.
- **`for`**: Itera sobre itens vindos de um iterador, implementa um trait ou
  especifica um lifetime de ordem superior.
- **`if`**: Desvia com base no resultado de uma expressão condicional.
- **`impl`**: Implementa funcionalidade inerente ou de trait.
- **`in`**: Parte da sintaxe do loop `for`.
- **`let`**: Associa uma variável.
- **`loop`**: Executa um loop incondicional.
- **`match`**: Faz match de um valor com padrões.
- **`mod`**: Define um módulo.
- **`move`**: Faz uma closure assumir o ownership de todas as suas capturas.
- **`mut`**: Indica mutabilidade em referências, ponteiros raw ou bindings de
  padrões.
- **`pub`**: Indica visibilidade pública em campos de struct, blocos `impl` ou
  módulos.
- **`ref`**: Faz binding por referência.
- **`return`**: Retorna de uma função.
- **`Self`**: Um alias de tipo para o tipo que estamos definindo ou
  implementando.
- **`self`**: Receptor de método ou módulo atual.
- **`static`**: Variável global ou lifetime que dura durante toda a execução
  do programa.
- **`struct`**: Define uma estrutura.
- **`super`**: Módulo pai do módulo atual.
- **`trait`**: Define um trait.
- **`true`**: Literal booleano verdadeiro.
- **`type`**: Define um alias de tipo ou tipo associado.
- **`union`**: Define uma [union][union]<!-- ignore -->; é palavra-chave
  apenas quando usada em uma declaração de union.
- **`unsafe`**: Indica código, funções, traits ou implementações inseguros.
- **`use`**: Traz símbolos para o escopo.
- **`where`**: Indica cláusulas que restringem um tipo.
- **`while`**: Executa um loop condicional com base no resultado de uma
  expressão.

[union]: ../reference/items/unions.html

### Palavras-chave reservadas para uso futuro

As palavras-chave a seguir ainda não têm funcionalidade, mas são reservadas
pelo Rust para possível uso futuro:

- `abstract`
- `become`
- `box`
- `do`
- `final`
- `gen`
- `macro`
- `override`
- `priv`
- `try`
- `typeof`
- `unsized`
- `virtual`
- `yield`

### Identificadores raw

_Identificadores raw_ são a sintaxe que permite usar palavras-chave em lugares
onde normalmente isso não seria permitido. Você usa um identificador raw ao
prefixar a palavra-chave com `r#`.

Por exemplo, `match` é uma palavra-chave. Se você tentar compilar a função a
seguir, que usa `match` como nome:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
fn match(needle: &str, haystack: &str) -> bool {
    haystack.contains(needle)
}
```

receberá este erro:

```text
error: expected identifier, found keyword `match`
 --> src/main.rs:4:4
  |
4 | fn match(needle: &str, haystack: &str) -> bool {
  |    ^^^^^ expected identifier, found keyword
```

O erro mostra que você não pode usar a palavra-chave `match` como
identificador de função. Para usá-la como nome de função, é preciso recorrer à
sintaxe de identificador raw, assim:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust
fn r#match(needle: &str, haystack: &str) -> bool {
    haystack.contains(needle)
}

fn main() {
    assert!(r#match("foo", "foobar"));
}
```

Esse código compilará sem erros. Observe o prefixo `r#` tanto na definição do
nome da função quanto no ponto em que ela é chamada em `main`.

Identificadores raw permitem usar qualquer palavra como identificador, mesmo
que essa palavra seja uma palavra-chave reservada. Isso nos dá mais liberdade
para escolher nomes de identificadores, além de permitir integração com
programas escritos em linguagens em que essas palavras não são palavras-chave.
Além disso, identificadores raw permitem usar bibliotecas escritas em uma
edição diferente do Rust daquela usada pelo seu crate. Por exemplo, `try` não
é palavra-chave na edição 2015, mas é nas edições 2018, 2021 e 2024. Se você
depender de uma biblioteca escrita na edição 2015 que tenha uma função `try`,
precisará usar a sintaxe de identificador raw, neste caso `r#try`, para
chamar essa função no seu código em edições mais novas. Veja o
[Apêndice E][appendix-e]<!-- ignore --> para mais informações sobre edições.

[appendix-e]: appendix-05-editions.html

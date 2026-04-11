## Apêndice A: Palavras-chave

As listas a seguir contêm palavras-chave reservadas para uso atual ou futuro
pela linguagem Rust. Como tal, elas não podem ser usadas como identificadores
(exceto como identificadores brutos, conforme discutimos na seção
[“Identificadores Brutos”][raw-identifiers]<!-- ignore -->). _Identificadores_ são nomes
de funções, variáveis, parâmetros, campos struct, módulos, crates, constantes,
macros, valores estáticos, atributos, tipos, traits ou lifetimes.

[raw-identifiers]: #raw-identifiers

### Palavras-chave atualmente em uso

A seguir está uma lista de palavras-chave atualmente em uso, com suas
funcionalidades descritas.

- **`as`**: Executa conversão primitiva, desambigua o trait específico que
  contém um item ou renomeia itens em instruções `use`.
- **`async`**: Retorna um `Future` em vez de bloquear a thread atual.
- **`await`**: Suspende a execução até que o resultado de um `Future` esteja
  pronto.
- **`break`**: Sai de um loop imediatamente.
- **`const`**: Define itens constantes ou ponteiros brutos constantes.
- **`continue`**: Continua para a próxima iteração do loop.
- **`crate`**: Em um caminho de módulo, refere-se à raiz do crate.
- **`dyn`**: Despacho dinâmico para um objeto trait.
- **`else`**: Alternativa para construções de fluxo de controle `if` e `if let`.
- **`enum`**: Define uma enumeração.
- **`extern`**: Vincula uma função ou variável externa.
- **`false`**: Literal booleano falso.
- **`fn`**: Define uma função ou o tipo de ponteiro de função.
- **`for`**: Percorre itens de um iterator, implementa um trait ou especifica
  um lifetime de ordem superior.
- **`if`**: Ramifica com base no resultado de uma expressão condicional.
- **`impl`**: Implementa funcionalidade inerente ou de trait.
- **`in`**: Parte da sintaxe do loop `for`.
- **`let`**: Vincula uma variável.
- **`loop`**: Loop incondicional.
- **`match`**: Combina um valor com padrões.
- **`mod`**: Define um módulo.
- **`move`**: Faz um closure tomar ownership de todas as suas capturas.
- **`mut`**: Denota mutabilidade em referências, ponteiros brutos ou bindings
  de padrão.
- **`pub`**: Denota visibilidade pública em campos de struct, blocos `impl` ou
  módulos.
- **`ref`**: Vincula por referência.
- **`return`**: Retorna de uma função.
- **`Self`**: Um alias de tipo para o tipo que estamos definindo ou
  implementando.
- **`self`**: Receptor do método ou módulo atual.
- **`static`**: Variável global ou lifetime que dura toda a execução do
  programa.
- **`struct`**: Define uma struct.
- **`super`**: Módulo pai do módulo atual.
- **`trait`**: Define um trait.
- **`true`**: Literal booleano verdadeiro.
- **`type`**: Define um alias de tipo ou um tipo associado.
- **`union`**: Define uma [union][union]<!-- ignore -->; é uma palavra-chave
  apenas quando usada em uma declaração de union.
- **`unsafe`**: Denota código, funções, traits ou implementações inseguras.
- **`use`**: Traz símbolos para o escopo.
- **`where`**: Denota cláusulas que restringem um tipo.
- **`while`**: Executa um loop condicional com base no resultado de uma
  expressão.

[union]: ../reference/items/unions.html

### Palavras-chave reservadas para uso futuro

As seguintes palavras-chave ainda não possuem nenhuma funcionalidade, mas são
reservadas por Rust para uso potencial no futuro:

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

### Identificadores Brutos

_Identificadores brutos_ são a sintaxe que permite usar palavras-chave onde
normalmente isso não seria permitido. Você usa um identificador bruto
prefixando uma palavra-chave com `r#`.

Por exemplo, `match` é uma palavra-chave. Se você tentar compilar a seguinte
função que usa `match` como nome:

<span class="filename">Filename: src/main.rs</span>

```rust,ignore,does_not_compile
fn match(needle: &str, haystack: &str) -> bool {
    haystack.contains(needle)
}
```

você receberá este erro:

```text
error: expected identifier, found keyword `match`
 --> src/main.rs:4:4
  |
4 | fn match(needle: &str, haystack: &str) -> bool {
  |    ^^^^^ expected identifier, found keyword
```

O erro mostra que você não pode usar a palavra-chave `match` como identificador
de função. Para usar `match` como nome de função, você precisa usar a sintaxe
de identificador bruto, assim:

<span class="filename">Filename: src/main.rs</span>

```rust
fn r#match(needle: &str, haystack: &str) -> bool {
    haystack.contains(needle)
}

fn main() {
    assert!(r#match("foo", "foobar"));
}
```

Esse código compila sem erros. Observe o prefixo `r#` no nome da função em sua
definição, bem como no ponto em que a função é chamada em `main`.

Os identificadores brutos permitem que você use qualquer palavra como
identificador, mesmo que essa palavra seja uma palavra-chave reservada. Isso
nos dá mais liberdade para escolher nomes de identificadores, além de permitir
integração com programas escritos em uma linguagem em que essas palavras não
são palavras-chave. Além disso, os identificadores brutos permitem que você use
bibliotecas escritas em uma edição do Rust diferente daquela usada pelo seu
crate. Por exemplo, `try` não é uma palavra-chave na edição de 2015, mas é nas
edições de 2018, 2021 e 2024. Se você depende de uma biblioteca escrita na
edição de 2015 e ela tem uma função `try`, será preciso usar a sintaxe de
identificador bruto, `r#try`, nesse caso, para chamar essa função a partir do
seu código em edições posteriores.

Consulte [Apêndice E][appendix-e]<!-- ignore --> para obter mais informações sobre edições.

[appendix-e]: appendix-05-editions.html

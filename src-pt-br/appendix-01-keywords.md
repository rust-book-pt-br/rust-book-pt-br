## Apêndice A: Palavras-chave

As listas a seguir contêm palavras-chave reservadas para uso current ou future
usado pela linguagem Rust. Como tal, eles não podem ser usados como identificadores (exceto
como identificadores brutos, conforme discutimos em [“Raw
Identificadores”][raw-identifiers]<!-- ignore -->). _Identificadores_ são nomes
de funções, variáveis, parâmetros, campos struct, módulos, crates, constantes,
macros, valores estáticos, atributos, tipos, traits ou lifetimes.

[raw-identifiers]: #raw-identifiers

### Palavras-chave atualmente em uso

A seguir está uma lista de palavras-chave atualmente em uso, com suas funcionalidades
descrito.

- ** `as` **: Execute a conversão primitiva, desambigua o trait específico
  contendo um item ou renomeie itens em instruções `use`.
- ** ` async`**: Retorna um ` Future`em vez de bloquear o thread atual.
- ** ` await`**: Suspender a execução até que o resultado de um ` Future`esteja pronto.
- ** ` break`**: Sai de um loop imediatamente.
- ** ` const`**: Defina itens constantes ou ponteiros brutos constantes.
- ** ` continue`**: Continue para a próxima iteração do loop.
- ** ` crate`**: Em um caminho de módulo, refere-se à raiz crate.
- ** ` dyn`**: Despacho dinâmico para um objeto trait.
- ** ` else`**: substituto para construções de fluxo de controle ` if`e ` if let`.
- ** ` enum`**: Defina uma enumeração.
- ** ` extern`**: Vincular uma função ou variável externa.
- ** ` false`**: literal booleano falso.
- ** ` fn`**: Defina uma função ou o tipo de ponteiro de função.
- ** ` for`**: Faça um loop sobre itens de um iterator, implemente um trait ou especifique um
  lifetime com classificação mais alta.
- ** ` if`**: Ramificação baseada no resultado de uma expressão condicional.
- ** ` impl`**: Implemente funcionalidade inerente ou trait.
- ** ` in`**: Parte da sintaxe do loop ` for`.
- ** ` let`**: Vincular uma variável.
- ** ` loop`**: Loop incondicional.
- ** ` match`**: Combine um valor com padrões.
- ** ` mod`**: Defina um módulo.
- ** ` move`**: Faça um closure tirar ownership de todas as suas capturas.
- ** ` mut`**: denota mutabilidade em referências, ponteiros brutos ou ligações de padrões.
- ** ` pub`**: denota visibilidade pública em campos struct, blocos ` impl`ou
  módulos.
- ** ` ref`**: vincular por referência.
- ** ` return`**: Retorno da função.
- ** ` Self`**: um alias de tipo para o tipo que estamos definindo ou implementando.
- ** ` self`**: Assunto do método ou módulo atual.
- ** ` static`**: Variável global ou lifetime com duração de todo o programa
  execução.
- ** ` struct`**: Defina uma estrutura.
- ** ` super`**: Módulo pai do módulo atual.
- ** ` trait`**: Defina um trait.
- ** ` true`**: literal verdadeiro booleano.
- ** ` type`**: Defina um alias de tipo ou tipo associado.
- ** ` union`**: Defina uma [união][union]<!-- ignore -->; é uma palavra-chave somente quando
  usado em uma declaração sindical.
- ** ` unsafe`**: denota código, funções, traits ou implementações inseguras.
- ** ` use`**: Coloque os símbolos no escopo.
- ** ` where`**: denotam cláusulas que restringem um tipo.
- ** ` while`**: Loop condicionalmente baseado no resultado de uma expressão.

[union]: ../reference/items/unions.html

### Palavras-chave reservadas para uso do Future

As seguintes palavras-chave ainda não possuem nenhuma funcionalidade, mas são reservadas por
Rust para uso potencial do future:

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

### Raw Identifiers

_Identificadores brutos_ são a sintaxe que permite usar palavras-chave onde não seriam
normalmente será permitido. Você usa um identificador bruto prefixando uma palavra-chave com `r#`.

Por exemplo, `match` é uma palavra-chave. Se você tentar compilar a seguinte função
que usa `match` como nome:

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

O erro mostra que você não pode usar a palavra-chave `match` como função
identificador. Para usar `match` como nome de função, você precisa usar o valor bruto
sintaxe do identificador, assim:

<span class="filename">Filename: src/main.rs</span>

```rust
fn r#match(needle: &str, haystack: &str) -> bool {
    haystack.contains(needle)
}

fn main() {
    assert!(r#match("foo", "foobar"));
}
```

Este código será compilado sem erros. Observe o prefixo `r#` na função
nome em sua definição, bem como onde a função é chamada em `main`.

Os identificadores brutos permitem que você use qualquer palavra escolhida como identificador, mesmo que
essa palavra é uma palavra-chave reservada. Isso nos dá mais liberdade para escolher
nomes de identificadores, bem como nos permite integrar com programas escritos em um
idioma onde essas palavras não são palavras-chave. Além disso, os identificadores brutos permitem
você deve usar bibliotecas escritas em uma edição Rust diferente daquela que seu crate usa.
Por exemplo, `try` não é uma palavra-chave na edição de 2015, mas é na edição de 2018, 2021,
e edições de 2024. Se você depende de uma biblioteca escrita usando o 2015
edição e tem uma função `try`, você precisará usar a sintaxe do identificador bruto,
` r#try`neste caso, para chamar essa função do seu código em edições posteriores.
Consulte [Apêndice E][appendix-e]<!-- ignore --> para obter mais informações sobre edições.

[appendix-e]: appendix-05-editions.html

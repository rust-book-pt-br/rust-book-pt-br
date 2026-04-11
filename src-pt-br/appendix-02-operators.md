## Apêndice B: Operadores e Símbolos

Este apêndice contém um glossário da sintaxe do Rust, incluindo operadores e
outros símbolos que aparecem sozinhos ou no contexto de caminhos, genéricos,
trait bounds, macros, atributos, comentários, tuplas e colchetes.

### Operadores

A Tabela B-1 contém os operadores em Rust, um exemplo de como o operador
aparece em contexto, uma breve explicação e se esse operador pode ser
sobrecarregado. Se um operador puder ser sobrecarregado, o trait relevante para
essa sobrecarga estará listado.

<span class="caption">Tabela B-1: Operadores</span>

| Operador                  | Exemplo                                                 | Explicação                                                            | Sobrecarregável? |
| ------------------------- | ------------------------------------------------------- | --------------------------------------------------------------------- | ---------------- |
| `!`                       | `ident!(...)`, `ident!{...}`, `ident![...]`             | Expansão de macro                                                     |                  |
| `!`                       | `!expr`                                                 | Complemento bit a bit ou lógico                                       | `Not`            |
| `!=`                      | `expr != expr`                                          | Comparação de desigualdade                                            | `PartialEq`      |
| `%`                       | `expr % expr`                                           | Resto aritmético                                                      | `Rem`            |
| `%=` | `var %= expr` | Resto aritmético e atribuição | `RemAssign` |
| `&`                       | `&expr`, `&mut expr`                                    | Borrow                                                                |                  |
| `&`                       | `&type`, `&mut type`, `&'a type`, `&'a mut type`        | Tipo de ponteiro emprestado                                           |                  |
| `&` | `expr & expr` | E bit a bit | `BitAnd` |
| `&=` | `var &= expr` | AND bit a bit e atribuição | `BitAndAssign` |
| `&&` | `expr && expr` | AND lógico com curto-circuito |                |
| `*`                       | `expr * expr`                                           | Multiplicação aritmética                                              | `Mul`          |
| `*=` | `var *= expr` | Multiplicação e atribuição aritmética | `MulAssign` |
| `*`                       | `*expr`                                                 | Dereferência                                                          | `Deref`        |
| `*`                       | `*const type`, `*mut type`                              | Ponteiro bruto                                                        |                |
| `+` | `trait + trait`, ` 'a + trait`| Restrição de tipo composto |                |
| `+`                       | `expr + expr`                                           | Adição aritmética                                                     | `Add`          |
| `+=` | `var += expr` | Adição e atribuição aritmética | `AddAssign` |
| `,` | `expr, expr` | Separador de argumentos e elementos |                |
| `-`                       | `- expr`                                                | Negação aritmética                                                    | `Neg`          |
| `-`                       | `expr - expr`                                           | Subtração aritmética                                                  | `Sub`          |
| `-=` | `var -= expr` | Subtração e atribuição aritmética | `SubAssign` |
| `->`                      | `fn(...) -> type`, <code>&vert;...&vert; -> type</code> | Tipo de retorno de função e closure                                   |                |
| `.`                       | `expr.ident`                                            | Acesso a campo                                                        |                |
| `.`                       | `expr.ident(expr, ...)`                                 | Chamada de método                                                     |                |
| `.` | `expr.0`, `expr.1` e assim por diante | Indexação de tupla |                |
| `..`                      | `..`, `expr..`, `..expr`, `expr..expr`                  | Literal de intervalo exclusivo à direita                              | `PartialOrd`   |
| `..=`                     | `..=expr`, `expr..=expr`                                | Literal de intervalo inclusivo à direita                              | `PartialOrd`   |
| `..`                      | `..expr`                                                | Sintaxe de atualização de literal de struct                           |                |
| `..` | `variant(x, ..)`, `struct_type { x, .. }` | Binding de padrão “e o restante” |                |
| `...` | `expr...expr` | (Obsoleto, use `..=`) Em um padrão: padrão de intervalo inclusivo |                |
| `/`                       | `expr / expr`                                           | Divisão aritmética                                                    | `Div`          |
| `/=` | `var /= expr` | Divisão e atribuição aritmética | `DivAssign` |
| `:`                       | `pat: type`, `ident: type`                              | Restrições                                                            |                |
| `:`                       | `ident: expr`                                           | Inicializador de campo de struct                                      |                |
| `:`                       | `'a: loop {...}`                                        | Rótulo de loop                                                        |                |
| `;` | `expr;` | Terminador de declaração e item |                |
| `;`                       | `[...; len]`                                            | Parte da sintaxe de array de tamanho fixo                             |                |
| `<<`                      | `expr << expr`                                          | Deslocamento à esquerda                                               | `Shl`          |
| `<<=` | `var <<= expr` | Deslocamento à esquerda e atribuição | `ShlAssign` |
| `<`                       | `expr < expr`                                           | Comparação “menor que”                                                | `PartialOrd`   |
| `<=`                      | `expr <= expr`                                          | Comparação “menor ou igual a”                                         | `PartialOrd`   |
| `=`                       | `var = expr`, `ident = type`                            | Atribuição/equivalência                                               |                |
| `==`                      | `expr == expr`                                          | Comparação de igualdade                                               | `PartialEq`    |
| `=>`                      | `pat => expr`                                           | Parte da sintaxe de um braço de `match`                               |                |
| `>`                       | `expr > expr`                                           | Comparação “maior que”                                                | `PartialOrd`   |
| `>=`                      | `expr >= expr`                                          | Comparação “maior ou igual a”                                         | `PartialOrd`   |
| `>>`                      | `expr >> expr`                                          | Deslocamento à direita                                                | `Shr`          |
| `>>=` | `var >>= expr` | Deslocamento à direita e atribuição | `ShrAssign` |
| `@` | `ident @ pat` | Binding de padrão |                |
| `^`                       | `expr ^ expr`                                           | OU exclusivo bit a bit                                                | `BitXor`       |
| `^=` | `var ^= expr` | OR exclusivo bit a bit e atribuição | `BitXorAssign` |
| <code>&vert;</code>       | <code>pat &vert; pat</code>                             | Alternativas de padrão                                                |                |
| <code>&vert;</code>       | <code>expr &vert; expr</code>                           | OU bit a bit                                                          | `BitOr`        |
| <code>&vert;=</code>      | <code>var &vert;= expr</code>                           | OU bit a bit e atribuição                                             | `BitOrAssign`  |
| <code>&vert;&vert;</code> | <code>expr &vert;&vert; expr</code>                     | OU lógico com curto-circuito                                          |                |
| `?`                       | `expr?`                                                 | Propagação de erro                                                    |                |

### Símbolos que não são operadores

As tabelas a seguir contêm todos os símbolos que não funcionam como operadores;
isto é, eles não se comportam como uma chamada de função ou método.

A Tabela B-2 mostra símbolos que aparecem sozinhos e são válidos em diversos
contextos.

<span class="caption">Tabela B-2: Sintaxe independente</span>

| Símbolo                                                                | Explicação                                                             |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `'ident`                                                               | Lifetime nomeado ou rótulo de loop                                     |
| Dígitos seguidos imediatamente por `u8`, `i32`, `f64`, `usize` e assim por diante | Literal numérico de tipo específico                                    |
| `"..."`                                                                | Literal de string                                                      |
| `r"..."`, `r#"..."#`, `r##"..."##`, e assim por diante                 | Literal de string bruta; caracteres de escape não são processados      |
| `b"..."`                                                               | Literal de string de bytes; constrói um array de bytes em vez de uma string |
| `br"..."`, `br#"..."#`, `br##"..."##`, e assim por diante | Literal de string de bytes bruta; combinação de literal bruto e literal de string de bytes |
| `'...'`                                                                | Literal de caractere                                                   |
| `b'...'`                                                               | Literal de byte ASCII                                                  |
| <code>&vert;...&vert; expr</code>                                      | Closure                                                                |
| `!` | Tipo bottom, sempre vazio, para funções divergentes |
| `_`                                                                    | Binding de padrão “ignorado”; também usado para tornar literais inteiros mais legíveis |

A Tabela B-3 mostra símbolos que aparecem no contexto de um caminho pela
hierarquia de módulos até um item.

<span class="caption">Tabela B-3: Sintaxe relacionada a caminhos</span>

| Símbolo                                 | Explicação                                                                                                   |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `ident::ident`                          | Caminho de namespace                                                                                         |
| `::path` | Caminho relativo à raiz do crate (ou seja, um caminho explicitamente absoluto) |
| `self::path` | Caminho relativo ao módulo atual (ou seja, um caminho explicitamente relativo) |
| `super::path` | Caminho relativo ao pai do módulo atual |
| `type::ident`, ` <type as trait>::ident`| Constantes, funções e tipos associados |
| `<type>::...` | Item associado para um tipo que não pode ser nomeado diretamente (por exemplo, `<&T>::...`, `<[T]>::...` e assim por diante) |
| `trait::method(...)` | Desambiguação de uma chamada de método ao nomear o trait que a define |
| `type::method(...)` | Desambiguação de uma chamada de método ao nomear o tipo para o qual ela está definida |
| `<type as trait>::method(...)` | Desambiguação de uma chamada de método ao nomear o trait e o tipo |

A Tabela B-4 mostra símbolos que aparecem no contexto do uso de parâmetros de
tipo genéricos.

<span class="caption">Tabela B-4: Genéricos</span>

| Símbolo                        | Explicação                                                                                                                                          |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `path<...>`                    | Especifica parâmetros para um tipo genérico dentro de um tipo, como em `Vec<u8>`                                                                  |
| `path::<...>`, `method::<...>` | Especifica parâmetros para um tipo genérico, função ou método em uma expressão; frequentemente chamado de _turbofish_, como em `"42".parse::<i32>()` |
| `fn ident<...> ...`            | Define função genérica                                                                                                                              |
| `struct ident<...> ...`        | Define struct genérica                                                                                                                              |
| `enum ident<...> ...`          | Define enum genérico                                                                                                                                |
| `impl<...> ...`                | Define implementação genérica                                                                                                                       |
| `for<...> type` | Limites de lifetime de ordem superior |
| `type<ident=type>`             | Um tipo genérico em que um ou mais tipos associados têm atribuições específicas (por exemplo, `Iterator<Item=T>`)                                       |

A Tabela B-5 mostra símbolos que aparecem no contexto de restringir parâmetros
de tipo genéricos com trait bounds.

<span class="caption">Tabela B-5: Restrições de trait bounds</span>

| Símbolo                       | Explicação                                                                                                                               |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `T: U` | Parâmetro genérico `T` restrito a tipos que implementam `U` |
| `T: 'a` | O tipo genérico `T` deve sobreviver ao lifetime `'a` (o que significa que o tipo não pode conter transitivamente nenhuma referência com lifetimes menor que `'a`) |
| `T: 'static`                  | O tipo genérico `T` não contém referências emprestadas além daquelas com lifetime `'static`                                                                 |
| `'b: 'a`                      | O lifetime genérico `'b` deve durar mais que o lifetime `'a`                                                                                           |
| `T: ?Sized`                   | Permite que o parâmetro de tipo genérico seja um tipo de tamanho dinâmico                                                                                |
| `'a + trait`, ` trait + trait`| Restrição de tipo composto |

A Tabela B-6 mostra símbolos que aparecem no contexto de chamada ou definição
de macros e de especificação de atributos em um item.

<span class="caption">Tabela B-6: Macros e atributos</span>

| Símbolo                                     | Explicação         |
| ------------------------------------------- | ------------------ |
| `#[meta]`                                   | Atributo externo   |
| `#![meta]`                                  | Atributo interno   |
| `$ident`                                    | Substituição de macro |
| `$ident:kind`                               | Metavariável de macro |
| `$(...)...`                                 | Repetição de macro |
| `ident!(...)`, `ident!{...}`, `ident![...]` | Invocação de macro |

A Tabela B-7 mostra símbolos que criam comentários.

<span class="caption">Tabela B-7: Comentários</span>

| Símbolo    | Explicação                    |
| ---------- | ----------------------------- |
| `//`       | Comentário de linha           |
| `//!`      | Comentário interno de documentação em linha |
| `///`      | Comentário externo de documentação em linha |
| `/*...*/`  | Comentário de bloco           |
| `/*!...*/` | Comentário interno de documentação em bloco |
| `/**...*/` | Comentário externo de documentação em bloco |

A Tabela B-8 mostra os contextos em que os parênteses são usados.

<span class="caption">Tabela B-8: Parênteses</span>

| Símbolo                  | Explicação                                                                                  |
| ------------------------ | ------------------------------------------------------------------------------------------- |
| `()` | Tupla vazia (também conhecida como unidade), literal e tipo |
| `(expr)`                 | Expressão entre parênteses                                                                  |
| `(expr,)`                | Expressão de tupla com um único elemento                                                    |
| `(type,)`                | Tipo de tupla com um único elemento                                                         |
| `(expr, ...)`            | Expressão de tupla                                                                          |
| `(type, ...)`            | Tipo de tupla                                                                               |
| `expr(expr, ...)`        | Expressão de chamada de função; também usada para inicializar `struct`s de tupla e variantes de `enum` do tipo tupla |

A Tabela B-9 mostra os contextos em que as chaves são usadas.

<span class="caption">Tabela B-9: Chaves</span>

| Contexto     | Explicação       |
| ------------ | ---------------- |
| `{...}`      | Expressão de bloco |
| `Type {...}` | Literal de struct |

A Tabela B-10 mostra os contextos em que os colchetes são usados.

<span class="caption">Tabela B-10: Colchetes</span>

| Contexto                                           | Explicação                                                                                                                    |
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `[...]`                                            | Literal de array                                                                                                              |
| `[expr; len]`                                      | Literal de array contendo `len` cópias de `expr`                                                                              |
| `[type; len]`                                      | Tipo de array contendo `len` instâncias de `type`                                                                             |
| `expr[expr]`                                       | Indexação de coleção; pode ser sobrecarregada (`Index`, `IndexMut`)                                                           |
| `expr[..]`, `expr[a..]`, `expr[..b]`, `expr[a..b]` | Indexação de coleção simulando o fatiamento da coleção, usando `Range`, `RangeFrom`, `RangeTo` ou `RangeFull` como “índice” |

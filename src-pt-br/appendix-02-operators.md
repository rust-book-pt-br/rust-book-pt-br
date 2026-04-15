## Apêndice B: Operadores e Símbolos

Este apêndice contém um glossário da sintaxe do Rust, incluindo operadores e
outros símbolos que aparecem sozinhos ou no contexto de caminhos, genéricos,
limites de trait, macros, atributos, comentários, tuplas e colchetes.

### Operadores

A Tabela B-1 contém os operadores do Rust, um exemplo de como cada operador
aparece em contexto, uma explicação breve e se esse operador é
sobrecarregável. Se um operador for sobrecarregável, o trait relevante para
fazer essa sobrecarga também será listado.

<span class="caption">Tabela B-1: Operadores</span>

| Operador                  | Exemplo                                                 | Explicação                                                           | Sobrecarregável? |
| ------------------------- | ------------------------------------------------------- | -------------------------------------------------------------------- | ---------------- |
| `!`                       | `ident!(...)`, `ident!{...}`, `ident![...]`             | Expansão de macro                                                    |                  |
| `!`                       | `!expr`                                                 | Complemento bit a bit ou lógico                                      | `Not`            |
| `!=`                      | `expr != expr`                                          | Comparação de desigualdade                                           | `PartialEq`      |
| `%`                       | `expr % expr`                                           | Resto aritmético                                                     | `Rem`            |
| `%=`                      | `var %= expr`                                           | Resto aritmético e atribuição                                        | `RemAssign`      |
| `&`                       | `&expr`, `&mut expr`                                    | Empréstimo                                                           |                  |
| `&`                       | `&type`, `&mut type`, `&'a type`, `&'a mut type`        | Tipo de ponteiro emprestado                                          |                  |
| `&`                       | `expr & expr`                                           | E bit a bit                                                          | `BitAnd`         |
| `&=`                      | `var &= expr`                                           | E bit a bit e atribuição                                             | `BitAndAssign`   |
| `&&`                      | `expr && expr`                                          | E lógico com curto-circuito                                          |                  |
| `*`                       | `expr * expr`                                           | Multiplicação aritmética                                             | `Mul`            |
| `*=`                      | `var *= expr`                                           | Multiplicação aritmética e atribuição                                | `MulAssign`      |
| `*`                       | `*expr`                                                 | Desreferência                                                        | `Deref`          |
| `*`                       | `*const type`, `*mut type`                              | Ponteiro raw                                                         |                  |
| `+`                       | `trait + trait`, `'a + trait`                           | Restrição composta de tipo                                           |                  |
| `+`                       | `expr + expr`                                           | Adição aritmética                                                    | `Add`            |
| `+=`                      | `var += expr`                                           | Adição aritmética e atribuição                                       | `AddAssign`      |
| `,`                       | `expr, expr`                                            | Separador de argumentos e elementos                                  |                  |
| `-`                       | `- expr`                                                | Negação aritmética                                                   | `Neg`            |
| `-`                       | `expr - expr`                                           | Subtração aritmética                                                 | `Sub`            |
| `-=`                      | `var -= expr`                                           | Subtração aritmética e atribuição                                    | `SubAssign`      |
| `->`                      | `fn(...) -> type`, <code>&vert;...&vert; -> type</code> | Tipo de retorno de função e closure                                  |                  |
| `.`                       | `expr.ident`                                            | Acesso a campo                                                       |                  |
| `.`                       | `expr.ident(expr, ...)`                                 | Chamada de método                                                    |                  |
| `.`                       | `expr.0`, `expr.1` e assim por diante                   | Indexação de tupla                                                   |                  |
| `..`                      | `..`, `expr..`, `..expr`, `expr..expr`                  | Literal de intervalo exclusivo à direita                             | `PartialOrd`     |
| `..=`                     | `..=expr`, `expr..=expr`                                | Literal de intervalo inclusivo à direita                             | `PartialOrd`     |
| `..`                      | `..expr`                                                | Sintaxe de atualização de literal de struct                          |                  |
| `..`                      | `variant(x, ..)`, `struct_type { x, .. }`               | Binding de padrão “e o restante”                                     |                  |
| `...`                     | `expr...expr`                                           | (Obsoleto; use `..=`) Em um padrão: padrão de intervalo inclusivo    |                  |
| `/`                       | `expr / expr`                                           | Divisão aritmética                                                   | `Div`            |
| `/=`                      | `var /= expr`                                           | Divisão aritmética e atribuição                                      | `DivAssign`      |
| `:`                       | `pat: type`, `ident: type`                              | Restrições                                                           |                  |
| `:`                       | `ident: expr`                                           | Inicializador de campo de struct                                     |                  |
| `:`                       | `'a: loop {...}`                                        | Rótulo de loop                                                       |                  |
| `;`                       | `expr;`                                                 | Terminador de instrução e item                                       |                  |
| `;`                       | `[...; len]`                                            | Parte da sintaxe de array de tamanho fixo                            |                  |
| `<<`                      | `expr << expr`                                          | Deslocamento à esquerda                                              | `Shl`            |
| `<<=`                     | `var <<= expr`                                          | Deslocamento à esquerda e atribuição                                 | `ShlAssign`      |
| `<`                       | `expr < expr`                                           | Comparação “menor que”                                               | `PartialOrd`     |
| `<=`                      | `expr <= expr`                                          | Comparação “menor que ou igual a”                                    | `PartialOrd`     |
| `=`                       | `var = expr`, `ident = type`                            | Atribuição/equivalência                                              |                  |
| `==`                      | `expr == expr`                                          | Comparação de igualdade                                              | `PartialEq`      |
| `=>`                      | `pat => expr`                                           | Parte da sintaxe de um braço de `match`                              |                  |
| `>`                       | `expr > expr`                                           | Comparação “maior que”                                               | `PartialOrd`     |
| `>=`                      | `expr >= expr`                                          | Comparação “maior que ou igual a”                                    | `PartialOrd`     |
| `>>`                      | `expr >> expr`                                          | Deslocamento à direita                                               | `Shr`            |
| `>>=`                     | `var >>= expr`                                          | Deslocamento à direita e atribuição                                  | `ShrAssign`      |
| `@`                       | `ident @ pat`                                           | Binding de padrão                                                    |                  |
| `^`                       | `expr ^ expr`                                           | OU exclusivo bit a bit                                               | `BitXor`         |
| `^=`                      | `var ^= expr`                                           | OU exclusivo bit a bit e atribuição                                  | `BitXorAssign`   |
| <code>&vert;</code>       | <code>pat &vert; pat</code>                             | Alternativas de padrão                                               |                  |
| <code>&vert;</code>       | <code>expr &vert; expr</code>                           | OU bit a bit                                                         | `BitOr`          |
| <code>&vert;=</code>      | <code>var &vert;= expr</code>                           | OU bit a bit e atribuição                                            | `BitOrAssign`    |
| <code>&vert;&vert;</code> | <code>expr &vert;&vert; expr</code>                     | OU lógico com curto-circuito                                         |                  |
| `?`                       | `expr?`                                                 | Propagação de erro                                                   |                  |

### Símbolos não operadores

As tabelas a seguir contêm todos os símbolos que não funcionam como
operadores; isto é, eles não se comportam como chamadas de função ou de
método.

A Tabela B-2 mostra símbolos que aparecem sozinhos e são válidos em vários
lugares.

<span class="caption">Tabela B-2: Sintaxe independente</span>

| Símbolo                                                                | Explicação                                                            |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------- |
| `'ident`                                                               | Lifetime nomeado ou rótulo de loop                                    |
| Dígitos imediatamente seguidos por `u8`, `i32`, `f64`, `usize` etc.    | Literal numérico de um tipo específico                                |
| `"..."`                                                                | Literal de string                                                     |
| `r"..."`, `r#"..."#`, `r##"..."##` etc.                                | Literal de string raw; caracteres de escape não são processados       |
| `b"..."`                                                               | Literal de string de bytes; constrói um array de bytes em vez de uma string |
| `br"..."`, `br#"..."#`, `br##"..."##` etc.                             | Literal de string raw de bytes; combinação de literal raw e literal de string de bytes |
| `'...'`                                                                | Literal de caractere                                                  |
| `b'...'`                                                               | Literal de byte ASCII                                                 |
| <code>&vert;...&vert; expr</code>                                      | Closure                                                               |
| `!`                                                                    | Tipo bottom sempre vazio para funções divergentes                     |
| `_`                                                                    | Binding de padrão “ignorado”; também usado para tornar literais inteiros mais legíveis |

A Tabela B-3 mostra símbolos que aparecem no contexto de um caminho pela
hierarquia de módulos até um item.

<span class="caption">Tabela B-3: Sintaxe relacionada a caminhos</span>

| Símbolo                                  | Explicação                                                                                                        |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `ident::ident`                           | Caminho de namespace                                                                                              |
| `::path`                                 | Caminho relativo à raiz da crate (isto é, um caminho explicitamente absoluto)                                    |
| `self::path`                             | Caminho relativo ao módulo atual (isto é, um caminho explicitamente relativo)                                    |
| `super::path`                            | Caminho relativo ao pai do módulo atual                                                                           |
| `type::ident`, `<type as trait>::ident`  | Constantes, funções e tipos associados                                                                            |
| `<type>::...`                            | Item associado de um tipo que não pode ser nomeado diretamente (por exemplo, `<&T>::...`, `<[T]>::...` etc.)    |
| `trait::method(...)`                     | Desambiguar uma chamada de método nomeando o trait que a define                                                   |
| `type::method(...)`                      | Desambiguar uma chamada de método nomeando o tipo para o qual ela está definida                                   |
| `<type as trait>::method(...)`           | Desambiguar uma chamada de método nomeando o trait e o tipo                                                       |

A Tabela B-4 mostra símbolos que aparecem no contexto do uso de parâmetros de
tipos genéricos.

<span class="caption">Tabela B-4: Genéricos</span>

| Símbolo                         | Explicação                                                                                                                                           |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `path<...>`                    | Especifica parâmetros para um tipo genérico em um tipo (por exemplo, `Vec<u8>`)                                                                    |
| `path::<...>`, `method::<...>` | Especifica parâmetros para um tipo, função ou método genérico em uma expressão; isso é frequentemente chamado de _turbofish_ (por exemplo, `"42".parse::<i32>()`) |
| `fn ident<...> ...`            | Define uma função genérica                                                                                                                           |
| `struct ident<...> ...`        | Define uma struct genérica                                                                                                                           |
| `enum ident<...> ...`          | Define um enum genérico                                                                                                                              |
| `impl<...> ...`                | Define uma implementação genérica                                                                                                                    |
| `for<...> type`                | Limites de lifetime de ordem superior                                                                                                                |
| `type<ident=type>`             | Um tipo genérico em que um ou mais tipos associados têm atribuições específicas (por exemplo, `Iterator<Item=T>`)                                  |

A Tabela B-5 mostra símbolos que aparecem no contexto de restringir parâmetros de
tipos genéricos com limites de trait.

<span class="caption">Tabela B-5: Restrições de limites de trait</span>

| Símbolo                        | Explicação                                                                                                                                |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `T: U`                        | Parâmetro genérico `T` restrito a tipos que implementam `U`                                                                              |
| `T: 'a`                       | O tipo genérico `T` precisa sobreviver ao lifetime `'a` (isto é, o tipo não pode conter, de forma transitiva, referências com lifetimes menores que `'a`) |
| `T: 'static`                  | O tipo genérico `T` não contém referências emprestadas além de referências `'static`                                                     |
| `'b: 'a`                      | O lifetime genérico `'b` precisa sobreviver ao lifetime `'a`                                                                              |
| `T: ?Sized`                   | Permite que o parâmetro de tipo genérico seja um tipo de tamanho dinâmico                                                                |
| `'a + trait`, `trait + trait` | Restrição composta de tipo                                                                                                                |

A Tabela B-6 mostra símbolos que aparecem no contexto de chamar ou definir
macros e de especificar atributos em um item.

<span class="caption">Tabela B-6: Macros e atributos</span>

| Símbolo                                      | Explicação        |
| ------------------------------------------- | ----------------- |
| `#[meta]`                                   | Atributo externo  |
| `#![meta]`                                  | Atributo interno  |
| `$ident`                                    | Substituição de macro |
| `$ident:kind`                               | Metavariável de macro |
| `$(...)...`                                 | Repetição de macro |
| `ident!(...)`, `ident!{...}`, `ident![...]` | Invocação de macro |

A Tabela B-7 mostra símbolos que criam comentários.

<span class="caption">Tabela B-7: Comentários</span>

| Símbolo     | Explicação                    |
| ---------- | ----------------------------- |
| `//`       | Comentário de linha           |
| `//!`      | Comentário interno de documentação em linha |
| `///`      | Comentário externo de documentação em linha |
| `/*...*/`  | Comentário de bloco           |
| `/*!...*/` | Comentário interno de documentação em bloco |
| `/**...*/` | Comentário externo de documentação em bloco |

A Tabela B-8 mostra os contextos em que parênteses são usados.

<span class="caption">Tabela B-8: Parênteses</span>

| Símbolo                   | Explicação                                                                                  |
| ------------------------ | -------------------------------------------------------------------------------------------- |
| `()`                     | Tupla vazia (também chamada de unit), tanto como literal quanto como tipo                   |
| `(expr)`                 | Expressão entre parênteses                                                                   |
| `(expr,)`                | Expressão de tupla de um único elemento                                                      |
| `(type,)`                | Tipo de tupla de um único elemento                                                           |
| `(expr, ...)`            | Expressão de tupla                                                                           |
| `(type, ...)`            | Tipo de tupla                                                                                |
| `expr(expr, ...)`        | Expressão de chamada de função; também usada para inicializar `struct`s de tupla e variantes de enum em forma de tupla |

A Tabela B-9 mostra os contextos em que chaves são usadas.

<span class="caption">Tabela B-9: Chaves</span>

| Contexto      | Explicação      |
| ------------ | ---------------- |
| `{...}`      | Expressão de bloco |
| `Type {...}` | Literal de struct |

A Tabela B-10 mostra os contextos em que colchetes são usados.

<span class="caption">Tabela B-10: Colchetes</span>

| Contexto                                            | Explicação                                                                                                                    |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `[...]`                                            | Literal de array                                                                                                               |
| `[expr; len]`                                      | Literal de array contendo `len` cópias de `expr`                                                                               |
| `[type; len]`                                      | Tipo de array contendo `len` instâncias de `type`                                                                              |
| `expr[expr]`                                       | Indexação de coleção; sobrecarregável (`Index`, `IndexMut`)                                                                    |
| `expr[..]`, `expr[a..]`, `expr[..b]`, `expr[a..b]` | Indexação de coleção simulando fatiamento, usando `Range`, `RangeFrom`, `RangeTo` ou `RangeFull` como “índice”               |

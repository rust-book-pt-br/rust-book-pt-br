## Apêndice B: Operadores e Símbolos

Este apêndice contém um glossário da sintaxe do Rust, incluindo operadores e
outros símbolos que aparecem sozinhos ou no contexto de caminhos, genéricos,
Limites trait, macros, atributos, comentários, tuplas e colchetes.

### Operators

A Tabela B-1 contém os operadores em Rust, um exemplo de como o operador
aparecem no contexto, uma breve explicação e se esse operador é
sobrecarregável. Se um operador for sobrecarregável, o trait relevante a ser usado para
sobrecarga que o operador está listado.

<span class="caption">Tabela B-1: Operadores</span>

| Operator                  | Example                                                 | Explanation                                                           | Overloadable?  |
| ------------------------- | ------------------------------------------------------- | --------------------------------------------------------------------- | -------------- |
| `!`                       | `ident!(...)`, `ident!{...}`, `ident![...]`             | Macro expansion                                                       |                |
| `!`                       | `!expr`                                                 | Bitwise or logical complement                                         | `Not`          |
| `!=`                      | `expr != expr`                                          | Nonequality comparison                                                | `PartialEq`    |
| `%`                       | `expr % expr`                                           | Arithmetic remainder                                                  | `Rem`          |
| `%=` | `var %= expr` | Resto aritmético e atribuição | `RemAssign` |
| `&`                       | `&expr`, `&mut expr`                                    | Borrow                                                                |                |
| `&`                       | `&type`, `&mut type`, `&'a type`, `&'a mut type`        | Borrowed pointer type                                                 |                |
| `&` | `expr & expr` | E bit a bit | `BitAnd` |
| `&=` | `var &= expr` | AND bit a bit e atribuição | `BitAndAssign` |
| `&&` | `expr && expr` | Curto-circuito lógico AND |                |
| `*`                       | `expr * expr`                                           | Arithmetic multiplication                                             | `Mul`          |
| `*=` | `var *= expr` | Multiplicação e atribuição aritmética | `MulAssign` |
| `*`                       | `*expr`                                                 | Dereference                                                           | `Deref`        |
| `*`                       | `*const type`, `*mut type`                              | Raw pointer                                                           |                |
| `+` | `trait + trait`, ` 'a + trait`| Restrição de tipo composto |                |
| `+`                       | `expr + expr`                                           | Arithmetic addition                                                   | `Add`          |
| `+=` | `var += expr` | Adição e atribuição aritmética | `AddAssign` |
| `,` | `expr, expr` | Separador de argumentos e elementos |                |
| `-`                       | `- expr`                                                | Arithmetic negation                                                   | `Neg`          |
| `-`                       | `expr - expr`                                           | Arithmetic subtraction                                                | `Sub`          |
| `-=` | `var -= expr` | Subtração e atribuição aritmética | `SubAssign` |
| `->`                      | `fn(...) -> type`, <code>&vert;...&vert; -> type</code> | Function and closure return type                                      |                |
| `.`                       | `expr.ident`                                            | Field access                                                          |                |
| `.`                       | `expr.ident(expr, ...)`                                 | Method call                                                           |                |
| `.` | `expr.0`, ` expr.1`e assim por diante | Indexação de tupla |                |
| `..`                      | `..`, `expr..`, `..expr`, `expr..expr`                  | Right-exclusive range literal                                         | `PartialOrd`   |
| `..=`                     | `..=expr`, `expr..=expr`                                | Right-inclusive range literal                                         | `PartialOrd`   |
| `..`                      | `..expr`                                                | Struct literal update syntax                                          |                |
| `..` | `variant(x,..)`, ` struct_type { x,.. }`| Encadernação de padrão “E o resto” |                |
| `...` | `expr...expr` | (Obsoleto, use `..=`) Em um padrão: padrão de intervalo inclusivo |                |
| `/`                       | `expr / expr`                                           | Arithmetic division                                                   | `Div`          |
| `/=` | `var /= expr` | Divisão e atribuição aritmética | `DivAssign` |
| `:`                       | `pat: type`, `ident: type`                              | Constraints                                                           |                |
| `:`                       | `ident: expr`                                           | Struct field initializer                                              |                |
| `:`                       | `'a: loop {...}`                                        | Loop label                                                            |                |
| `;` | `expr;` | Terminador de declaração e item |                |
| `;`                       | `[...; len]`                                            | Part of fixed-size array syntax                                       |                |
| `<<`                      | `expr << expr`                                          | Left-shift                                                            | `Shl`          |
| `<<=` | `var <<= expr` | Deslocamento à esquerda e atribuição | `ShlAssign` |
| `<`                       | `expr < expr`                                           | Less than comparison                                                  | `PartialOrd`   |
| `<=`                      | `expr <= expr`                                          | Less than or equal to comparison                                      | `PartialOrd`   |
| `=`                       | `var = expr`, `ident = type`                            | Assignment/equivalence                                                |                |
| `==`                      | `expr == expr`                                          | Equality comparison                                                   | `PartialEq`    |
| `=>`                      | `pat => expr`                                           | Part of match arm syntax                                              |                |
| `>`                       | `expr > expr`                                           | Greater than comparison                                               | `PartialOrd`   |
| `>=`                      | `expr >= expr`                                          | Greater than or equal to comparison                                   | `PartialOrd`   |
| `>>`                      | `expr >> expr`                                          | Right-shift                                                           | `Shr`          |
| `>>=` | `var >>= expr` | Deslocamento à direita e atribuição | `ShrAssign` |
| `@` | `ident @ pat` | Encadernação de padrão |                |
| `^`                       | `expr ^ expr`                                           | Bitwise exclusive OR                                                  | `BitXor`       |
| `^=` | `var ^= expr` | OR exclusivo bit a bit e atribuição | `BitXorAssign` |
| <code>&vert;</code>       | <code>pat &vert; pat</code>                             | Pattern alternatives                                                  |                |
| <code>&vert;</code>       | <code>expr &vert; expr</code>                           | Bitwise OR                                                            | `BitOr`        |
| <code>&vert;=</code>      | <code>var &vert;= expr</code>                           | Bitwise OR and assignment                                             | `BitOrAssign`  |
| <code>&vert;&vert;</code> | <code>expr &vert;&vert; expr</code>                     | Short-circuiting logical OR                                           |                |
| `?`                       | `expr?`                                                 | Error propagation                                                     |                |

### Non-operator Symbols

As tabelas a seguir contêm todos os símbolos que não funcionam como operadores; isso
isto é, eles não se comportam como uma chamada de função ou método.

A Tabela B-2 mostra símbolos que aparecem sozinhos e são válidos em uma variedade de
locais.

<span class="caption">Tabela B-2: Sintaxe independente</span>

| Symbol                                                                 | Explanation                                                            |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `'ident`                                                               | Named lifetime or loop label                                           |
| Digits immediately followed by `u8`, `i32`, `f64`, `usize`, and so on  | Numeric literal of specific type                                       |
| `"..."`                                                                | String literal                                                         |
| `r"..."`, `r#"..."#`, `r##"..."##`, and so on                          | Raw string literal; escape characters not processed                    |
| `b"..."`                                                               | Byte string literal; constructs an array of bytes instead of a string  |
| `br"..."`, ` br#"..."#`, ` br##"..."##`e assim por diante | Literal de string de bytes brutos; combinação de literal bruto e de string de bytes |
| `'...'`                                                                | Character literal                                                      |
| `b'...'`                                                               | ASCII byte literal                                                     |
| <code>&vert;...&vert; expr</code>                                      | Closure                                                                |
| `!` | Tipo de fundo sempre vazio para funções divergentes |
| `_`                                                                    | “Ignored” pattern binding; also used to make integer literals readable |

A Tabela B-3 mostra símbolos que aparecem no contexto de um caminho através do módulo
hierarquia para um item.

<span class="caption">Tabela B-3: Sintaxe relacionada a caminhos</span>

| Symbol                                  | Explanation                                                                                                  |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------|
| `ident::ident`                          | Namespace path                                                                                               |
| `::path` | Caminho relativo à raiz crate (ou seja, um caminho explicitamente absoluto) |
| `self::path` | Caminho relativo ao módulo atual (ou seja, um caminho explicitamente relativo) |
| `super::path` | Caminho relativo ao pai do módulo atual |
| `type::ident`, ` <type as trait>::ident`| Constantes, funções e tipos associados |
| `<type>::...` | Item associado para um tipo que não pode ser nomeado diretamente (por exemplo, `<&T>::...`, ` <[T]>::...`e assim por diante) |
| `trait::method(...)` | Desambiguando uma chamada de método nomeando trait que a define |
| `type::method(...)` | Desambiguando uma chamada de método nomeando o tipo para o qual ela está definida |
| `<type as trait>::method(...)` | Desambiguando uma chamada de método nomeando trait e digitando |

A Tabela B-4 mostra símbolos que aparecem no contexto do uso de tipos genéricos
parâmetros.

<span class="caption">Tabela B-4: Genéricos</span>

| Symbol                         | Explanation                                                                                                                                         |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `path<...>`                    | Specifies parameters to a generic type in a type (for example, `Vec<u8>`)                                                                           |
| `path::<...>`, `method::<...>` | Specifies parameters to a generic type, function, or method in an expression; often referred to as _turbofish_ (for example, `"42".parse::<i32>()`) |
| `fn ident<...> ...`            | Define generic function                                                                                                                             |
| `struct ident<...> ...`        | Define generic structure                                                                                                                            |
| `enum ident<...> ...`          | Define generic enumeration                                                                                                                          |
| `impl<...> ...`                | Define generic implementation                                                                                                                       |
| `for<...> type` | Limites lifetime com classificação mais alta |
| `type<ident=type>`             | A generic type where one or more associated types have specific assignments (for example, `Iterator<Item=T>`)                                       |

A Tabela B-5 mostra símbolos que aparecem no contexto de restrição de tipo genérico
parâmetros com limites trait.

<span class="caption">Tabela B-5: Restrições de trait bounds</span>

| Symbol                        | Explanation                                                                                                                                |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `T: U` | Parâmetro genérico `T` restrito a tipos que implementam `U` |
| `T: 'a` | O tipo genérico `T` deve sobreviver ao lifetime `'a` (o que significa que o tipo não pode conter transitivamente nenhuma referência com lifetimes menor que `'a`) |
| `T: 'static`                  | Generic type `T` contains no borrowed references other than `'static` ones                                                                 |
| `'b: 'a`                      | Generic lifetime `'b` must outlive lifetime `'a`                                                                                           |
| `T: ?Sized`                   | Allow generic type parameter to be a dynamically sized type                                                                                |
| `'a + trait`, ` trait + trait`| Restrição de tipo composto |

A Tabela B-6 mostra símbolos que aparecem no contexto de chamada ou definição
macros e especificação de atributos em um item.

<span class="caption">Tabela B-6: Macros e atributos</span>

| Symbol                                      | Explanation        |
| ------------------------------------------- | ------------------ |
| `#[meta]`                                   | Outer attribute    |
| `#![meta]`                                  | Inner attribute    |
| `$ident`                                    | Macro substitution |
| `$ident:kind`                               | Macro metavariable |
| `$(...)...`                                 | Macro repetition   |
| `ident!(...)`, `ident!{...}`, `ident![...]` | Macro invocation   |

A Tabela B-7 mostra símbolos que criam comentários.

<span class="caption">Tabela B-7: Comentários</span>

| Symbol     | Explanation             |
| ---------- | ----------------------- |
| `//`       | Line comment            |
| `//!`      | Inner line doc comment  |
| `///`      | Outer line doc comment  |
| `/*...*/`  | Block comment           |
| `/*!...*/` | Inner block doc comment |
| `/**...*/` | Outer block doc comment |

A Tabela B-8 mostra os contextos em que os parênteses são usados.

<span class="caption">Tabela B-8: Parênteses</span>

| Symbol                   | Explanation                                                                                 |
| ------------------------ | ------------------------------------------------------------------------------------------- |
| `()` | Tupla vazia (também conhecida como unidade), literal e tipo |
| `(expr)`                 | Parenthesized expression                                                                    |
| `(expr,)`                | Single-element tuple expression                                                             |
| `(type,)`                | Single-element tuple type                                                                   |
| `(expr, ...)`            | Tuple expression                                                                            |
| `(type, ...)`            | Tuple type                                                                                  |
| `expr(expr, ...)`        | Function call expression; also used to initialize tuple `struct`s and tuple `enum` variants |

A Tabela B-9 mostra os contextos em que as chaves são usadas.

<span class="caption">Tabela B-9: Chaves</span>

| Context      | Explanation      |
| ------------ | ---------------- |
| `{...}`      | Block expression |
| `Type {...}` | Struct literal   |

A Tabela B-10 mostra os contextos em que os colchetes são usados.

<span class="caption">Tabela B-10: Colchetes</span>

| Context                                            | Explanation                                                                                                                   |
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `[...]`                                            | Array literal                                                                                                                 |
| `[expr; len]`                                      | Array literal containing `len` copies of `expr`                                                                               |
| `[type; len]`                                      | Array type containing `len` instances of `type`                                                                               |
| `expr[expr]`                                       | Collection indexing; overloadable (`Index`, `IndexMut`)                                                                       |
| `expr[..]`, ` expr[a..]`, ` expr[..b]`, ` expr[a..b]`| Indexação de coleção fingindo ser fatiamento de coleção, usando ` Range`, ` RangeFrom`, ` RangeTo`ou ` RangeFull`como “índice” |

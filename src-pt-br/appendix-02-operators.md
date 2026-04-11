## Apêndice B: Operadores e Símbolos

Este apêndice contém um glossário da sintaxe do Rust, incluindo operadores e
outros símbolos que aparecem sozinhos ou no contexto de caminhos, genéricos,
limites de características, macros, atributos, comentários, tuplas e colchetes.

### Operadores

A Tabela B-1 contém os operadores em Rust, um exemplo de como o operador seria
aparecem no contexto, uma breve explicação e se esse operador é
sobrecarregável. Se um operador for sobrecarregável, a característica relevante a ser usada para
sobrecarga que o operador está listado.

<span class="caption">Tabela B-1: Operadores</span>

| Operador| Exemplo| Explicação| Sobrecarregável?|
| ------------------------- | ------------------------------------------------------- | --------------------------------------------------------------------- | -------------- |
| `!`| `ident!(...)`, `ident!{...}`, `ident![...]`| Expansão macro|                |
| `!`| `!expr`| Complemento bit a bit ou lógico| `Not`|
| `!=`| `expr != expr`| Comparação de nenhuma qualidade| `PartialEq`|
| `%`| `expr % expr`| Resto aritmético| `Rem`|
| `%=`| `var %= expr`| Resto aritmético e atribuição| `RemAssign`|
| `&`| `&expr`, `&mut expr`| Emprestar|                |
| `&`| `&type`, `&mut type`, `&'a type`, `&'a mut type`| Tipo de ponteiro emprestado|                |
| `&`| `expr & expr`| E bit a bit| `BitAnd`|
| `&=`| `var &= expr`| AND bit a bit e atribuição| `BitAndAssign`|
| `&&`| `expr && expr`| Curto-circuito AND lógico|                |
| `*`| `expr * expr`| Multiplicação aritmética| `Mul`|
| `*=`| `var *= expr`| Multiplicação e atribuição aritmética| `MulAssign`|
| `*`| `*expr`| Desreferência| `Deref`|
| `*`| `*const type`, `*mut type`| Ponteiro bruto|                |
| `+`| `trait + trait`, `'a + trait`| Restrição de tipo composto|                |
| `+`| `expr + expr`| Adição aritmética| `Add`|
| `+=`| `var += expr`| Adição e atribuição aritmética| `AddAssign`|
| `,`| `expr, expr`| Argumento e separador de elemento|                |
| `-`| `- expr`| Negação aritmética| `Neg`|
| `-`| `expr - expr`| Subtração aritmética| `Sub`|
| `-=`| `var -= expr`| Subtração e atribuição aritmética| `SubAssign`|
| `->`| `fn(...) -> type`, <code>&vert;...&vert; -> digite</code>| Função e tipo de retorno de fechamento|                |
| `.`| `expr.ident`| Acesso ao campo|                |
| `.`| `expr.ident(expr, ...)`| Chamada de método|                |
| `.`| `expr.0`, `expr.1` e assim por diante| Indexação de tupla|                |
| `..`| `..`, `expr..`, `..expr`, `expr..expr`| Literal de intervalo exclusivo à direita| `PartialOrd`|
| `..=`| `..=expr`, `expr..=expr`| Literal de intervalo inclusivo à direita| `PartialOrd`|
| `..`| `..expr`| Sintaxe de atualização literal estrutural|                |
| `..`| `variant(x, ..)`, `struct_type { x, .. }`| Encadernação de padrão “E o resto”|                |
| `...`| `expr...expr`| (Obsoleto, use `..=` em vez disso) Em um padrão: padrão de intervalo inclusivo|                |
| `/`| `expr / expr`| Divisão aritmética| `Div`|
| `/=`| `var /= expr`| Divisão aritmética e atribuição| `DivAssign`|
| `:`| `pat: type`, `ident: type`| Restrições|                |
| `:`| `ident: expr`| Inicializador de campo estrutural|                |
| `:`| `'a: loop {...}`| Etiqueta de loop|                |
| `;`| `expr;`| Terminador de declaração e item|                |
| `;`| `[...; len]`| Parte da sintaxe de array de tamanho fixo|                |
| `<<`| `expr << expr`| Deslocamento para a esquerda| `Shl`|
| `<<=`| `var <<= expr`| Deslocamento à esquerda e atribuição| `ShlAssign`|
| `<`| `expr < expr`| Menos que comparação| `PartialOrd`|
| `<=`| `expr <= expr`| Menor ou igual à comparação| `PartialOrd`|
| `=`| `var = expr`, `ident = type`| Atribuição/equivalência|                |
| `==`| `expr == expr`| Comparação de igualdade| `PartialEq`|
| `=>`| `pat => expr`| Parte da sintaxe do match arm|                |
| `>`| `expr > expr`| Maior que a comparação| `PartialOrd`|
| `>=`| `expr >= expr`| Maior ou igual à comparação| `PartialOrd`|
| `>>`| `expr >> expr`| Mudança para a direita| `Shr`|
| `>>=`| `var >>= expr`| Deslocamento para a direita e atribuição| `ShrAssign`|
| `@`| `ident @ pat`| Encadernação de padrão|                |
| `^`| `expr ^ expr`| OR exclusivo bit a bit| `BitXor`|
| `^=`| `var ^= expr`| OR exclusivo bit a bit e atribuição| `BitXorAssign`|
| <code>&vert;</code>| <code>pat &vert; pat</code>| Alternativas de padrão|                |
| <code>&vert;</code>| <code>expr &vert; expr</code>| OU bit a bit| `BitOr`|
| <code>&vert;=</code>| <code>var &vert;= expr</code>| OR bit a bit e atribuição| `BitOrAssign`|
| <code>&vert;&vert;</code>| <code>expr &vert;&vert; expr</code>| OU lógico em curto-circuito|                |
| `?`| `expr?`| Propagação de erro|                |

### Símbolos não-operadores

As tabelas a seguir contêm todos os símbolos que não funcionam como operadores; que
isto é, eles não se comportam como uma chamada de função ou método.

A Tabela B-2 mostra símbolos que aparecem sozinhos e são válidos em uma variedade de
locais.

<span class="caption">Tabela B-2: Sintaxe Independente</span>

| Símbolo| Explicação|
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `'ident`| Tempo de vida nomeado ou rótulo de loop|
| Dígitos imediatamente seguidos por `u8`, `i32`, `f64`, `usize` e assim por diante| Literal numérico de tipo específico|
| `"..."`| Literal de string|
| `r"..."`, `r#"..."#`, `r##"..."##` e assim por diante| Literal de string bruta; caracteres de escape não processados|
| `b"..."`| Literal de cadeia de bytes; constrói uma matriz de bytes em vez de uma string|
| `br"..."`, `br#"..."#`, `br##"..."##` e assim por diante| Literal de string de bytes brutos; combinação de literal bruto e de string de bytes|
| `'...'`| Literal de caractere|
| `b'...'`| Literal de byte ASCII|
| <code>&vert;...&vert; expr</code>| Encerramento|
| `!`| Tipo de fundo sempre vazio para funções divergentes|
| `_`| Vinculação de padrão “ignorada”; também usado para tornar literais inteiros legíveis|

A Tabela B-3 mostra símbolos que aparecem no contexto de um caminho através do módulo
hierarquia para um item.

<span class="caption">Tabela B-3: Sintaxe Relacionada ao Caminho</span>

| Símbolo| Explicação|
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------|
| `ident::ident`| Caminho do namespace|
| `::path`| Caminho relativo à raiz da caixa (ou seja, um caminho explicitamente absoluto)|
| `self::path`| Caminho relativo ao módulo atual (ou seja, um caminho explicitamente relativo)|
| `super::path`| Caminho relativo ao pai do módulo atual|
| `type::ident`, `<type as trait>::ident`| Constantes, funções e tipos associados|
| `<type>::...`| Item associado a um tipo que não pode ser nomeado diretamente (por exemplo, `<&T>::...`, `<[T]>::...` e assim por diante)|
| `trait::method(...)`| Desambiguando uma chamada de método nomeando a característica que a define|
| `type::method(...)`| Desambiguando uma chamada de método nomeando o tipo para o qual ela está definida|
| `<type as trait>::method(...)`| Desambiguando uma chamada de método nomeando a característica e o tipo|

A Tabela B-4 mostra símbolos que aparecem no contexto do uso de tipos genéricos
parâmetros.

<span class="caption">Tabela B-4: Genéricos</span>

| Símbolo| Explicação|
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `path<...>`| Especifica parâmetros para um tipo genérico em um tipo (por exemplo, `Vec<u8>`)|
| `path::<...>`, `method::<...>`| Especifica parâmetros para um tipo, função ou método genérico em uma expressão; frequentemente referido como _turbofish_ (por exemplo, `"42".parse::<i32>()`)|
| `fn ident<...> ...`| Definir função genérica|
| `struct ident<...> ...`| Definir estrutura genérica|
| `enum ident<...> ...`| Definir enumeração genérica|
| `impl<...> ...`| Definir implementação genérica|
| `for<...> type`| Limites de tempo de vida com classificação mais alta|
| `type<ident=type>`| Um tipo genérico onde um ou mais tipos associados possuem atribuições específicas (por exemplo, `Iterator<Item=T>`)|

A Tabela B-5 mostra símbolos que aparecem no contexto de restrição de tipo genérico
parâmetros com limites de características.

<span class="caption">Tabela B-5: Restrições vinculadas a características</span>

| Símbolo| Explicação|
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `T: U`| Parâmetro genérico `T` restrito a tipos que implementam `U`|
| `T: 'a`| O tipo genérico `T` deve sobreviver ao tempo de vida `'a` (o que significa que o tipo não pode conter transitivamente quaisquer referências com tempos de vida inferiores a `'a`)|
| `T: 'static`| O tipo genérico `T` não contém referências emprestadas além de `'static`|
| `'b: 'a`| A vida útil genérica `'b` deve durar mais que a vida útil `'a`|
| `T: ?Sized`| Permitir que o parâmetro de tipo genérico seja um tipo de tamanho dinâmico|
| `'a + trait`, `trait + trait`| Restrição de tipo composto|

A Tabela B-6 mostra símbolos que aparecem no contexto de chamada ou definição
macros e especificação de atributos em um item.

<span class="caption">Tabela B-6: Macros e Atributos</span>

| Símbolo| Explicação|
| ------------------------------------------- | ------------------ |
| `#[meta]`| Atributo externo|
| `#![meta]`| Atributo interno|
| `$ident`| Substituição de macro|
| `$ident:kind`| Metavariável macro|
| `$(...)...`| Repetição de macro|
| `ident!(...)`, `ident!{...}`, `ident![...]`| Invocação de macro|

A Tabela B-7 mostra símbolos que criam comentários.

<span class="caption">Tabela B-7: Comentários</span>

| Símbolo| Explicação|
| ---------- | ----------------------- |
| `//`| Comentário de linha|
| `//!`| Comentário do documento da linha interna|
| `///`| Comentário do documento da linha externa|
| `/*...*/`| Bloquear comentário|
| `/*!...*/`| Comentário do documento do bloco interno|
| `/**...*/`| Comentário do documento do bloco externo|

A Tabela B-8 mostra os contextos em que os parênteses são usados.

<span class="caption">Tabela B-8: Parênteses</span>

| Símbolo| Explicação|
| ------------------------ | ------------------------------------------------------------------------------------------- |
| `()`| Tupla vazia (também conhecida como unidade), tanto literal quanto de tipo|
| `(expr)`| Expressão entre parênteses|
| `(expr,)`| Expressão de tupla de elemento único|
| `(type,)`| Tipo de tupla de elemento único|
| `(expr, ...)`| Expressão de tupla|
| `(type, ...)`| Tipo de tupla|
| `expr(expr, ...)`| Expressão de chamada de função; também usado para inicializar variantes da tupla `struct`s e da tupla `enum`|

A Tabela B-9 mostra os contextos em que as chaves são usadas.

<span class="caption">Tabela B-9: Colchetes</span>

| Contexto| Explicação|
| ------------ | ---------------- |
| `{...}`| Expressão de bloco|
| `Type {...}`| Estrutura literal|

A Tabela B-10 mostra os contextos em que os colchetes são usados.

<span class="caption">Tabela B-10: Colchetes</span>

| Contexto| Explicação|
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `[...]`| Literal de matriz|
| `[expr; len]`| Literal de matriz contendo `len` cópias de `expr`|
| `[type; len]`| Tipo de matriz contendo `len` instâncias de `type`|
| `expr[expr]`| Indexação de coleções; sobrecarregável (`Index`, `IndexMut`)|
| `expr[..]`, `expr[a..]`, `expr[..b]`, `expr[a..b]`| Indexação de coleção fingindo ser um fatiamento de coleção, usando `Range`, `RangeFrom`, `RangeTo` ou `RangeFull` como o “índice”|

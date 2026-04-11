## Trabalhando com Variáveis de Ambiente

Vamos melhorar o binário `minigrep` adicionando um recurso extra: uma opção
para busca sem diferenciação entre maiúsculas e minúsculas que a pessoa usuária
pode ativar por meio de uma variável de ambiente. Poderíamos transformar esse
recurso em uma opção de linha de comando e exigir que a pessoa o informe toda
vez que quisesse usá-lo, mas, ao torná-lo uma variável de ambiente, permitimos
que ela a configure uma única vez e tenha todas as buscas daquela sessão de
terminal feitas sem distinção entre maiúsculas e minúsculas.

<!-- Old headings. Do not remove or links may break. -->
<a id="writing-a-failing-test-for-the-case-insensitive-search-function"></a>

### Escrevendo um Teste que Falha para a Função de Busca sem Diferenciar Maiúsculas

Primeiro, vamos adicionar uma nova função `search_case_insensitive` à
biblioteca `minigrep`, que será chamada quando a variável de ambiente estiver
definida. Continuaremos seguindo o processo de TDD, então o primeiro passo é,
novamente, escrever um teste que falha. Vamos adicionar um novo teste para a
nova função `search_case_insensitive` e renomear o teste antigo de
`one_result` para `case_sensitive` para deixar clara a diferença entre os dois,
como mostrado na Listagem 12-20.

<Listing number="12-20" file-name="src/lib.rs" caption="Adicionando um novo teste que falha para a função sem diferenciação entre maiúsculas e minúsculas que estamos prestes a adicionar">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-20/src/lib.rs:here}}
```

</Listing>

Observe que também editamos o `contents` do teste antigo. Adicionamos uma nova
linha com o texto `"Duct tape."`, com `D` maiúsculo, que não deve corresponder
à consulta `"duct"` quando a busca for sensível a maiúsculas e minúsculas.
Alterar o teste antigo dessa maneira ajuda a garantir que não quebraremos
acidentalmente a funcionalidade de busca sensível a maiúsculas e minúsculas que
já implementamos. Esse teste deve passar agora e deve continuar passando
enquanto trabalhamos na busca sem diferenciação entre maiúsculas e minúsculas.

O novo teste para a busca _insensitive_ usa `"rUsT"` como consulta. Na função
`search_case_insensitive` que estamos prestes a adicionar, a consulta `"rUsT"`
deve corresponder à linha contendo `"Rust:"`, com `R` maiúsculo, e também à
linha `"Trust me."`, embora ambas tenham capitalização diferente da consulta.
Esse é o nosso teste que falha, e ele não compilará porque ainda não definimos
`search_case_insensitive`. Se quiser, você pode adicionar uma implementação
esqueleto que sempre retorne um vetor vazio, de modo semelhante ao que fizemos
com `search` na Listagem 12-16, para ver o teste compilar e falhar.

### Implementando a Função `search_case_insensitive`

A função `search_case_insensitive`, mostrada na Listagem 12-21, será quase
igual à função `search`. A única diferença é que vamos converter para minúsculas
`query` e cada `line`, para que, independentemente da capitalização dos
argumentos de entrada, ambos fiquem no mesmo formato quando verificarmos se a
linha contém a consulta.

<Listing number="12-21" file-name="src/lib.rs" caption="Definindo a função `search_case_insensitive` para converter consulta e linha em minúsculas antes de compará-las">

```rust,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-21/src/lib.rs:here}}
```

</Listing>

Primeiro, convertemos a string `query` para minúsculas e a armazenamos em uma
nova variável com o mesmo nome, sombreando a original. Chamar `to_lowercase`
na consulta é necessário para que, independentemente de a pessoa ter digitado
`"rust"`, `"RUST"`, `"Rust"` ou `"rUsT"`, tratemos a consulta como se fosse
`"rust"` e não nos importemos com a capitalização. Embora `to_lowercase`
trate o básico de Unicode, ele não é cem por cento preciso. Se estivéssemos
escrevendo uma aplicação real, faríamos um pouco mais de trabalho aqui, mas
esta seção trata de variáveis de ambiente, não de Unicode, então vamos parar
por aqui.

Observe que `query` agora é uma `String`, e não mais uma fatia de string,
porque chamar `to_lowercase` cria novos dados em vez de referenciar dados
existentes. Suponha, por exemplo, que a consulta seja `"rUsT"`: essa fatia de
string não contém um `u` ou `t` minúsculos prontos para usarmos, então temos de
alocar uma nova `String` contendo `"rust"`. Quando agora passamos `query` como
argumento para `contains`, precisamos adicionar um e comercial porque a
assinatura de `contains` foi definida para receber uma fatia de string.

Em seguida, adicionamos uma chamada a `to_lowercase` em cada `line` para
converter todos os caracteres para minúsculas. Agora que convertemos `line` e
`query` para minúsculas, encontraremos correspondências independentemente da
capitalização da consulta.

Vamos ver se essa implementação passa nos testes:

```console
{{#include ../listings/ch12-an-io-project/listing-12-21/output.txt}}
```

Ótimo! Eles passaram. Agora vamos chamar a nova função
`search_case_insensitive` a partir da função `run`. Primeiro, adicionaremos
uma opção de configuração à struct `Config` para alternar entre busca sensível
e não sensível a maiúsculas e minúsculas. Adicionar esse campo causará erros de
compilação, porque ainda não o inicializamos em lugar nenhum:

<span class="filename">Arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-22/src/main.rs:here}}
```

Adicionamos o campo `ignore_case`, que armazena um Booleano. Em seguida,
precisamos que a função `run` verifique o valor de `ignore_case` e use isso
para decidir se deve chamar `search` ou `search_case_insensitive`, como mostra
a Listagem 12-22. Isso ainda não compilará.

<Listing number="12-22" file-name="src/main.rs" caption="Chamando `search` ou `search_case_insensitive` com base no valor de `config.ignore_case`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-22/src/main.rs:there}}
```

</Listing>

Por fim, precisamos verificar a variável de ambiente. As funções para
trabalhar com variáveis de ambiente estão no módulo `env` da biblioteca
padrão, que já está no escopo no topo de _src/main.rs_. Usaremos a função
`var` do módulo `env` para verificar se algum valor foi definido para uma
variável de ambiente chamada `IGNORE_CASE`, como na Listagem 12-23.

<Listing number="12-23" file-name="src/main.rs" caption="Verificando se existe qualquer valor definido em uma variável de ambiente chamada `IGNORE_CASE`">

```rust,ignore,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-23/src/main.rs:here}}
```

</Listing>

Aqui, criamos uma nova variável, `ignore_case`. Para definir seu valor,
chamamos `env::var` e passamos o nome da variável de ambiente `IGNORE_CASE`. A
função `env::var` retorna um `Result`: ela será um `Ok` contendo o valor da
variável de ambiente se ela estiver definida com qualquer valor, e retornará
`Err` se a variável não estiver definida.

Estamos usando o método `is_ok` em `Result` para verificar se a variável de
ambiente está definida, o que significa que o programa deve fazer uma busca sem
diferenciação entre maiúsculas e minúsculas. Se `IGNORE_CASE` não estiver
definida, `is_ok` retornará `false`, e o programa fará uma busca sensível a
maiúsculas e minúsculas. Não nos importamos com o _valor_ da variável de
ambiente, apenas com o fato de ela estar definida ou não, por isso usamos
`is_ok`, em vez de `unwrap`, `expect` ou qualquer outro método de `Result` que
já vimos.

Passamos o valor da variável `ignore_case` para a instância de `Config`, para
que a função `run` possa lê-lo e decidir se chama `search_case_insensitive` ou
`search`, como implementamos na Listagem 12-22.

Vamos experimentar! Primeiro, executaremos o programa sem definir a variável de
ambiente e com a consulta `to`, que deve corresponder a qualquer linha que
contenha a palavra _to_ inteiramente em minúsculas:

```console
{{#include ../listings/ch12-an-io-project/listing-12-23/output.txt}}
```

Parece que continua funcionando! Agora vamos executar o programa com
`IGNORE_CASE` definido como `1`, mas usando a mesma consulta `to`:

```console
$ IGNORE_CASE=1 cargo run -- to poem.txt
```

Se você estiver usando PowerShell, precisará definir a variável de ambiente e
executar o programa como comandos separados:

```console
PS> $Env:IGNORE_CASE=1; cargo run -- to poem.txt
```

Isso fará com que `IGNORE_CASE` permaneça definido pelo restante da sessão do
shell. Você pode removê-lo com o cmdlet `Remove-Item`:

```console
PS> Remove-Item Env:IGNORE_CASE
```

Devemos então obter linhas que contenham _to_ e talvez tenham letras
maiúsculas:

<!-- manual-regeneration
cd listings/ch12-an-io-project/listing-12-23
IGNORE_CASE=1 cargo run -- to poem.txt
can't extract because of the environment variable
-->

```console
Are you nobody, too?
How dreary to be somebody!
To tell your name the livelong day
To an admiring bog!
```

Excelente, também obtivemos linhas que contêm _To_! Nosso programa `minigrep`
agora pode fazer buscas sem diferenciação entre maiúsculas e minúsculas,
controladas por uma variável de ambiente. Agora você sabe como gerenciar
opções definidas por argumentos de linha de comando ou por variáveis de
ambiente.

Alguns programas permitem tanto argumentos quanto variáveis de ambiente para a
mesma configuração. Nesses casos, o programa decide qual dos dois tem
precedência. Como exercício, tente controlar a sensibilidade a maiúsculas e
minúsculas tanto por um argumento de linha de comando quanto por uma variável
de ambiente. Decida se o argumento ou a variável deve ter precedência quando o
programa for executado com um indicando busca sensível e o outro indicando
busca sem diferenciação entre maiúsculas e minúsculas.

O módulo `std::env` contém muitos outros recursos úteis para lidar com
variáveis de ambiente: vale a pena consultar sua documentação para ver o que
está disponível.

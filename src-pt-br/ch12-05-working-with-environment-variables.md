## Trabalhando com variáveis ​​de ambiente

Melhoraremos o binário `minigrep` adicionando um recurso extra: uma opção para
pesquisa sem distinção entre maiúsculas e minúsculas que o usuário pode ativar por meio de um ambiente
variável. Poderíamos tornar esse recurso uma opção de linha de comando e exigir que
os usuários o inserem sempre que desejam aplicá-lo, mas, em vez disso, tornam-no um
variável de ambiente, permitimos que nossos usuários definam a variável de ambiente uma vez
e fazer com que todas as suas pesquisas não façam distinção entre maiúsculas e minúsculas nessa sessão de terminal.

<!-- Old headings. Do not remove or links may break. -->
<a id="writing-a-failing-test-for-the-case-insensitive-search-function"></a>

### Escrevendo um teste com falha para pesquisa sem distinção entre maiúsculas e minúsculas

Primeiro adicionamos uma nova função `search_case_insensitive` à biblioteca `minigrep`
que será chamado quando a variável de ambiente tiver um valor. Nós continuaremos
para seguir o processo TDD, então o primeiro passo é escrever novamente um teste com falha.
Adicionaremos um novo teste para a nova função `search_case_insensitive` e renomearemos
nosso antigo teste de `one_result` a `case_sensitive` para esclarecer as diferenças
entre os dois testes, conforme mostrado na Listagem 12-20.

<Listing number="12-20" file-name="src/lib.rs" caption="Adding a new failing test for the case-insensitive function we’re about to add">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-20/src/lib.rs:here}}
```

</Listing>

Observe que editamos `contents` do teste antigo também. Adicionamos uma nova linha
com o texto `"Duct tape."` usando _D_ maiúsculo que não deve corresponder à consulta
`"duct"` quando pesquisamos diferenciando maiúsculas de minúsculas. Mudando o teste antigo
desta forma ajuda a garantir que não quebramos acidentalmente a distinção entre maiúsculas e minúsculas
funcionalidade de pesquisa que já implementamos. Este teste deve passar agora
e deve continuar a passar enquanto trabalhamos na pesquisa que não diferencia maiúsculas de minúsculas.

O novo teste para a pesquisa case-_insensitive_ usa `"rUsT"` como sua consulta. Em
a função `search_case_insensitive` que estamos prestes a adicionar, a consulta `"rUsT"`
deve corresponder à linha que contém `"Rust:"` com _R_ maiúsculo e corresponder ao
linha `"Trust me."` mesmo que ambos tenham maiúsculas e minúsculas diferentes da consulta. Esse
é o nosso teste que falhou e não será compilado porque ainda não definimos
a função `search_case_insensitive`. Sinta-se à vontade para adicionar um esqueleto
implementação que sempre retorna um vetor vazio, semelhante ao que fizemos
para a função `search` na Listagem 12-16 para ver o teste ser compilado e falhar.

### Implementando a função `search_case_insensitive`

A função `search_case_insensitive`, mostrada na Listagem 12-21, será quase
o mesmo que a função `search`. A única diferença é que colocaremos letras minúsculas
o `query` e cada `line` para que seja qual for o caso dos argumentos de entrada,
eles serão o mesmo caso quando verificarmos se a linha contém a consulta.

<Listing number="12-21" file-name="src/lib.rs" caption="Defining the `search_case_insensitive` function to lowercase the query and the line before comparing them">

```rust,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-21/src/lib.rs:here}}
```

</Listing>

Primeiro, colocamos a string `query` em minúscula e a armazenamos em uma nova variável com o
mesmo nome, sombreando o original `query`. Chamando `to_lowercase` na consulta
é necessário para que não importa se a consulta do usuário é `"rust"`, `"RUST"`,
`"Rust"` ou `"rUsT"`, trataremos a consulta como se fosse `"rust"` e seremos
insensível ao caso. Embora `to_lowercase` lide com Unicode básico, ele
não será 100% preciso. Se estivéssemos escrevendo um aplicativo real, gostaríamos
para trabalhar um pouco mais aqui, mas esta seção é sobre variáveis ​​de ambiente,
não Unicode, então vamos deixar por isso mesmo aqui.

Observe que `query` agora é `String` em vez de uma fatia de string porque chamar
`to_lowercase` cria novos dados em vez de fazer referência aos dados existentes. Diga o
consulta é `"rUsT"`, por exemplo: essa fatia de string não contém letras minúsculas
`u` ou `t` para usarmos, então temos que alocar um novo `String` contendo
`"rust"`. Quando passamos `query` como argumento para o método `contains` agora, nós
precisa adicionar um e comercial porque a assinatura de `contains` está definida para receber
uma fatia de barbante.

Em seguida, adicionamos uma chamada para `to_lowercase` em cada `line` para colocar tudo em minúscula
personagens. Agora que convertemos `line` e `query` para letras minúsculas, vamos
encontre correspondências, independentemente do caso da consulta.

Vamos ver se esta implementação passa nos testes:

```console
{{#include ../listings/ch12-an-io-project/listing-12-21/output.txt}}
```

Ótimo! Eles passaram. Agora vamos chamar a nova função `search_case_insensitive`
da função `run`. Primeiro, adicionaremos uma opção de configuração ao `Config`
struct para alternar entre pesquisa com e sem distinção entre maiúsculas e minúsculas. Adicionando
este campo causará erros do compilador porque não estamos inicializando este campo
em qualquer lugar ainda:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-22/src/main.rs:here}}
```

Adicionamos o campo `ignore_case` que contém um booleano. Em seguida, precisamos do `run`
função para verificar o valor do campo `ignore_case` e usá-lo para decidir
se deve chamar a função `search` ou `search_case_insensitive`
função, conforme mostrado na Listagem 12-22. Isso ainda não será compilado.

<Listing number="12-22" file-name="src/main.rs" caption="Calling either `search` or `search_case_insensitive` based on the value in `config.ignore_case`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-22/src/main.rs:there}}
```

</Listing>

Finalmente, precisamos verificar a variável de ambiente. As funções para
trabalhar com variáveis ​​de ambiente estão no módulo `env` no padrão
biblioteca, que já está no escopo no topo de _src/main.rs_. Usaremos o
Função `var` do módulo `env` para verificar se algum valor foi definido
para uma variável de ambiente chamada `IGNORE_CASE`, conforme mostrado na Listagem 12-23.

<Listing number="12-23" file-name="src/main.rs" caption="Checking for any value in an environment variable named `IGNORE_CASE`">

```rust,ignore,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-23/src/main.rs:here}}
```

</Listing>

Aqui, criamos uma nova variável, `ignore_case`. Para definir seu valor, chamamos
`env::var` e passe o nome do ambiente `IGNORE_CASE`
variável. A função `env::var` retorna um `Result` que será o
variante `Ok` bem-sucedida que contém o valor da variável de ambiente se
a variável de ambiente é definida com qualquer valor. Ele retornará a variante `Err`
se a variável de ambiente não estiver definida.

Estamos usando o método `is_ok` em `Result` para verificar se o ambiente
variável está definida, o que significa que o programa deve fazer uma pesquisa sem distinção entre maiúsculas e minúsculas.
Se a variável de ambiente `IGNORE_CASE` não estiver definida como nada, `is_ok` irá
retorne `false` e o programa realizará uma pesquisa com distinção entre maiúsculas e minúsculas. Nós não
se preocupa com o _valor_ da variável de ambiente, apenas se ela está definida ou
não definido, então estamos verificando `is_ok` em vez de usar `unwrap`, `expect` ou qualquer
dos outros métodos que vimos em `Result`.

Passamos o valor na variável `ignore_case` para a instância `Config` então
que a função `run` pode ler esse valor e decidir se deve chamar
`search_case_insensitive` ou `search`, conforme implementamos na Listagem 12-22.

Vamos tentar! Primeiro, executaremos nosso programa sem o meio ambiente
variável definida e com a consulta `to`, que deve corresponder a qualquer linha que contenha
a palavra _to_ em letras minúsculas:

```console
{{#include ../listings/ch12-an-io-project/listing-12-23/output.txt}}
```

Parece que ainda funciona! Agora vamos executar o programa com `IGNORE_CASE` set
para `1` mas com a mesma consulta `to`:

```console
$ IGNORE_CASE=1 cargo run -- to poem.txt
```

Se estiver usando o PowerShell, você precisará definir a variável de ambiente e
execute o programa como comandos separados:

```console
PS> $Env:IGNORE_CASE=1; cargo run -- to poem.txt
```

Isso fará com que `IGNORE_CASE` persista pelo restante da sessão do shell.
Ele pode ser desabilitado com o cmdlet `Remove-Item`:

```console
PS> Remove-Item Env:IGNORE_CASE
```

Devemos obter linhas que contenham _to_ que possam ter letras maiúsculas:

<!-- manual-regeneration
listagens de cd/ch12-an-io-project/listing-12-23
IGNORE_CASE=1 carga executada -- para poema.txt
não é possível extrair por causa da variável de ambiente
-->

```console
Are you nobody, too?
How dreary to be somebody!
To tell your name the livelong day
To an admiring bog!
```

Excelente, também temos linhas contendo _To_! Nosso programa `minigrep` agora pode fazer
pesquisa sem distinção entre maiúsculas e minúsculas controlada por uma variável de ambiente. Agora você sabe
como gerenciar opções definidas usando argumentos de linha de comando ou ambiente
variáveis.

Alguns programas permitem argumentos _e_ variáveis ​​de ambiente para o mesmo
configuração. Nesses casos, os programas decidem que um ou outro leva
precedência. Para outro exercício por conta própria, tente controlar a distinção entre maiúsculas e minúsculas
por meio de um argumento de linha de comando ou de uma variável de ambiente. Decidir
se o argumento da linha de comando ou a variável de ambiente deve levar
precedência se o programa for executado com uma definida como sensível a maiúsculas e minúsculas e outra definida como
ignore o caso.

O módulo `std::env` contém muitos outros recursos úteis para lidar com
variáveis ​​de ambiente: Confira sua documentação para ver o que está disponível.

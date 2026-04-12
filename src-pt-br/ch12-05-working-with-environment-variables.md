## Trabalhando com variáveis de ambiente

Vamos melhorar o binário `minigrep` adicionando um recurso extra: uma opção de
busca sem distinção entre maiúsculas e minúsculas, que o usuário pode ativar
por meio de uma variável de ambiente. Poderíamos transformar isso em uma opção
de linha de comando e exigir que o usuário a informe toda vez que quiser usá-la.
Mas, ao fazê-la ser uma variável de ambiente, permitimos que a pessoa a defina
uma vez e tenha todas as suas buscas sem distinção entre maiúsculas e minúsculas
naquela sessão do terminal.

<!-- Old headings. Do not remove or links may break. -->
<a id="writing-a-failing-test-for-the-case-insensitive-search-function"></a>

### Escrevendo um teste que falha para a busca sem distinção entre maiúsculas e minúsculas

Primeiro, adicionamos uma nova função `search_case_insensitive` à biblioteca
`minigrep`, que será chamada quando a variável de ambiente tiver algum valor.
Vamos continuar seguindo o processo de TDD, então o primeiro passo é, mais uma
vez, escrever um teste que falha. Adicionaremos um novo teste para a função
`search_case_insensitive` e renomearemos o teste anterior de `one_result` para
`case_sensitive`, para deixar mais clara a diferença entre os dois testes, como
mostra a Listagem 12-20.

<Listing number="12-20" file-name="src/lib.rs" caption="Adicionando um novo teste com falha para a função de busca sem distinção entre maiúsculas e minúsculas que estamos prestes a criar">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-20/src/lib.rs:here}}
```

</Listing>

Observe que também editamos o `contents` do teste antigo. Adicionamos uma nova
linha com o texto `"Duct tape."`, usando `D` maiúsculo, que não deve
corresponder à consulta `"duct"` quando estivermos fazendo uma busca sensível a
maiúsculas e minúsculas. Alterar o teste antigo dessa forma ajuda a garantir
que não quebraremos por acidente a funcionalidade de busca sensível a
maiúsculas e minúsculas que já implementamos. Esse teste deve passar agora e
deve continuar passando enquanto trabalhamos na busca insensível a maiúsculas e
minúsculas.

O novo teste para a busca case-_insensitive_ usa `"rUsT"` como consulta. Na
função `search_case_insensitive` que estamos prestes a adicionar, a consulta
`"rUsT"` deve corresponder à linha que contém `"Rust:"`, com `R` maiúsculo, e
também à linha `"Trust me."`, embora ambas usem capitalização diferente da
consulta. Esse é o nosso teste com falha, e ele não compilará porque ainda não
definimos a função `search_case_insensitive`. Se quiser, você pode adicionar
uma implementação esqueleto que sempre retorna um vetor vazio, semelhante ao
que fizemos com a função `search` na Listagem 12-16, para ver o teste compilar
e falhar.

### Implementando a função `search_case_insensitive`

A função `search_case_insensitive`, mostrada na Listagem 12-21, será quase
igual à função `search`. A única diferença é que colocaremos `query` e cada
`line` em minúsculas, para que, independentemente da capitalização dos
argumentos de entrada, ambos estejam no mesmo formato quando verificarmos se a
linha contém a consulta.

<Listing number="12-21" file-name="src/lib.rs" caption="Definindo a função `search_case_insensitive` para colocar `query` e cada linha em minúsculas antes de compará-las">

```rust,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-21/src/lib.rs:here}}
```

</Listing>

Primeiro, convertemos a string `query` para minúsculas e a armazenamos em uma
nova variável com o mesmo nome, sombreando a `query` original. Chamar
`to_lowercase` na consulta é necessário para que, não importa se a pessoa
digite `"rust"`, `"RUST"`, `"Rust"` ou `"rUsT"`, tratemos a consulta como se
fosse `"rust"` e a busca fique insensível à capitalização. Embora
`to_lowercase` lide com Unicode básico, ela não será 100% precisa. Se
estivéssemos escrevendo uma aplicação real, provavelmente precisaríamos de
mais trabalho aqui, mas esta seção trata de variáveis de ambiente, não de
Unicode, então vamos deixar assim.

Observe que agora `query` é uma `String`, e não mais um string slice, porque
chamar `to_lowercase` cria novos dados em vez de apenas referenciar os dados
existentes. Suponha, por exemplo, que a consulta seja `"rUsT"`: esse string
slice não contém um `u` minúsculo nem um `t` minúsculo que possamos reutilizar,
então precisamos alocar uma nova `String` contendo `"rust"`. Quando passamos
`query` como argumento ao método `contains`, agora precisamos adicionar um
`&`, porque a assinatura de `contains` espera um string slice.

Em seguida, adicionamos uma chamada a `to_lowercase` em cada `line` para
converter todos os caracteres para minúsculas. Agora que convertemos `line` e
`query`, encontraremos correspondências independentemente da capitalização da
consulta.

Vamos ver se essa implementação passa nos testes:

```console
{{#include ../listings/ch12-an-io-project/listing-12-21/output.txt}}
```

Ótimo! Eles passaram. Agora vamos chamar a nova função
`search_case_insensitive` a partir de `run`. Primeiro, adicionaremos uma opção
de configuração à struct `Config` para alternar entre busca sensível e
insensível a maiúsculas e minúsculas. Adicionar esse campo causará erros de
compilação, porque ainda não estamos inicializando esse campo em nenhum lugar:

<span class="filename">Nome do arquivo: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-22/src/main.rs:here}}
```

Adicionamos o campo `ignore_case`, que armazena um booleano. Em seguida,
precisamos que a função `run` verifique o valor desse campo para decidir se
deve chamar `search` ou `search_case_insensitive`, como mostra a Listagem
12-22. Isso ainda não compilará.

<Listing number="12-22" file-name="src/main.rs" caption="Chamando `search` ou `search_case_insensitive` com base no valor de `config.ignore_case`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-22/src/main.rs:there}}
```

</Listing>

Por fim, precisamos verificar a variável de ambiente. As funções para trabalhar
com variáveis de ambiente ficam no módulo `env` da biblioteca padrão, que já
está em escopo no topo de _src/main.rs_. Usaremos a função `var` do módulo
`env` para verificar se algum valor foi definido para uma variável de ambiente
chamada `IGNORE_CASE`, como mostra a Listagem 12-23.

<Listing number="12-23" file-name="src/main.rs" caption="Verificando se existe algum valor definido na variável de ambiente `IGNORE_CASE`">

```rust,ignore,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-23/src/main.rs:here}}
```

</Listing>

Aqui criamos uma nova variável, `ignore_case`. Para definir seu valor, chamamos
`env::var` e passamos o nome da variável de ambiente `IGNORE_CASE`. A função
`env::var` retorna um `Result`: será a variante `Ok`, com o valor da variável
de ambiente, se ela estiver definida com qualquer valor; e será a variante
`Err` se ela não estiver definida.

Estamos usando o método `is_ok` de `Result` para verificar se a variável de
ambiente está definida, o que significa que o programa deve fazer uma busca sem
distinção entre maiúsculas e minúsculas. Se a variável `IGNORE_CASE` não
estiver definida, `is_ok` retornará `false`, e o programa fará uma busca
sensível a maiúsculas e minúsculas. Não nos importamos com o _valor_ da
variável de ambiente, apenas se ela está definida ou não; por isso usamos
`is_ok` em vez de `unwrap`, `expect` ou qualquer outro método que já vimos em
`Result`.

Passamos o valor da variável `ignore_case` para a instância de `Config`, para
que a função `run` possa ler esse valor e decidir se deve chamar
`search_case_insensitive` ou `search`, como implementamos na Listagem 12-22.

Vamos testar! Primeiro, executaremos nosso programa sem a variável de ambiente
definida e com a consulta `to`, que deve corresponder a qualquer linha que
contenha a palavra _to_ em minúsculas:

```console
{{#include ../listings/ch12-an-io-project/listing-12-23/output.txt}}
```

Parece que continua funcionando! Agora vamos executar o programa com
`IGNORE_CASE` definido como `1`, mas com a mesma consulta `to`:

```console
$ IGNORE_CASE=1 cargo run -- to poem.txt
```

Se você estiver usando PowerShell, precisará definir a variável de ambiente e
executar o programa como comandos separados:

```console
PS> $Env:IGNORE_CASE=1; cargo run -- to poem.txt
```

Isso fará com que `IGNORE_CASE` permaneça definido pelo restante da sua sessão
de shell. Você pode removê-lo com o cmdlet `Remove-Item`:

```console
PS> Remove-Item Env:IGNORE_CASE
```

Devemos obter linhas que contenham _to_, incluindo aquelas em que a palavra
aparece com letras maiúsculas:

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

Excelente, também obtivemos linhas contendo _To_! Nosso programa `minigrep`
agora consegue fazer busca sem distinção entre maiúsculas e minúsculas,
controlada por uma variável de ambiente. Agora você sabe como gerenciar opções
definidas usando argumentos de linha de comando ou variáveis de ambiente.

Alguns programas aceitam _tanto_ argumentos quanto variáveis de ambiente para a
mesma configuração. Nesses casos, eles decidem que um ou outro tem
precedência. Como exercício extra, tente controlar a sensibilidade a maiúsculas
e minúsculas por meio de um argumento de linha de comando ou de uma variável de
ambiente. Decida se o argumento da linha de comando ou a variável de ambiente
deve ter precedência se o programa for executado com um configurado para busca
sensível e o outro para ignorar a capitalização.

O módulo `std::env` contém muitos outros recursos úteis para lidar com
variáveis de ambiente. Consulte a documentação para ver o que está disponível.

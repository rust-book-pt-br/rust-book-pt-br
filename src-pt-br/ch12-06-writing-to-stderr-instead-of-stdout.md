<!-- Old headings. Do not remove or links may break. -->

<a id="writing-error-messages-to-standard-error-instead-of-standard-output"></a>

## Redirecionando erros para erro padrão

No momento, estamos escrevendo toda a nossa saída no terminal usando o
`println!` macro. Na maioria dos terminais, existem dois tipos de saída: _padrão
output_ (`stdout`) para informações gerais e _standard error_ (`stderr`) para
mensagens de erro. Esta distinção permite que os usuários escolham direcionar o
saída bem-sucedida de um programa para um arquivo, mas ainda imprime mensagens de erro no
tela.

A macro `println!` só é capaz de imprimir na saída padrão, então temos
usar outra coisa para imprimir com erro padrão.

### Verificando onde os erros são escritos

Primeiro, vamos observar como o conteúdo impresso por `minigrep` está sendo atualmente
gravado na saída padrão, incluindo quaisquer mensagens de erro que desejamos gravar
erro padrão em vez disso. Faremos isso redirecionando o fluxo de saída padrão
para um arquivo enquanto causa um erro intencionalmente. Não redirecionaremos o padrão
fluxo de erros, portanto, qualquer conteúdo enviado para erro padrão continuará a ser exibido em
a tela.

Espera-se que os programas de linha de comando enviem mensagens de erro para o erro padrão
stream para que ainda possamos ver mensagens de erro na tela, mesmo se
redirecione o fluxo de saída padrão para um arquivo. Nosso programa não está atualmente
bem comportado: estamos prestes a ver que ele salva a saída da mensagem de erro em um
arquivo em vez disso!

Para demonstrar esse comportamento, executaremos o programa com `>` e o caminho do arquivo,
_output.txt_, para o qual queremos redirecionar o fluxo de saída padrão. Nós não vamos
passe quaisquer argumentos, o que deve causar um erro:

```console
$ cargo run > output.txt
```

A sintaxe `>` diz ao shell para escrever o conteúdo da saída padrão em
_output.txt_ em vez da tela. Não vimos a mensagem de erro que estávamos
esperando impresso na tela, então isso significa que deve ter acabado no
arquivo. Isto é o que _output.txt_ contém:

```text
Problem parsing arguments: not enough arguments
```

Sim, nossa mensagem de erro está sendo impressa na saída padrão. É muito mais
útil para que mensagens de erro como esta sejam impressas no erro padrão para que
apenas os dados de uma execução bem-sucedida terminam no arquivo. Vamos mudar isso.

### Imprimindo erros para erro padrão

Usaremos o código da Listagem 12.24 para alterar a forma como as mensagens de erro são impressas.
Devido à refatoração que fizemos anteriormente neste capítulo, todo o código que
imprime mensagens de erro em uma função, `main`. A biblioteca padrão fornece
a macro `eprintln!` que imprime no fluxo de erros padrão, então vamos mudar
os dois lugares que estávamos chamando `println!` para imprimir erros para usar `eprintln!`
em vez de.

<Listing number="12-24" file-name="src/main.rs" caption="Writing error messages to standard error instead of standard output using `eprintln!`">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-24/src/main.rs:here}}
```

</Listing>

Vamos agora executar o programa novamente da mesma maneira, sem argumentos e
redirecionando a saída padrão com `>`:

```console
$ cargo run > output.txt
Problem parsing arguments: not enough arguments
```

Agora vemos o erro na tela e _output.txt_ não contém nada, que é o
comportamento que esperamos dos programas de linha de comando.

Vamos executar o programa novamente com argumentos que não causam erro, mas ainda assim
redirecione a saída padrão para um arquivo, assim:

```console
$ cargo run -- to poem.txt > output.txt
```

Não veremos nenhuma saída para o terminal e _output.txt_ conterá nosso
resultados:

<span class="filename">Nome do arquivo: saída.txt</span>

```text
Are you nobody, too?
How dreary to be somebody!
```

Isso demonstra que agora estamos usando saída padrão para uma saída bem-sucedida
e erro padrão para saída de erro, conforme apropriado.

## Resumo

Este capítulo recapitulou alguns dos principais conceitos que você aprendeu até agora e
abordou como realizar operações de E/S comuns em Rust. Usando linha de comando
argumentos, arquivos, variáveis ​​de ambiente e a macro `eprintln!` para impressão
erros, agora você está preparado para escrever aplicativos de linha de comando. Combinado com
os conceitos dos capítulos anteriores, seu código estará bem organizado, armazenará dados
efetivamente nas estruturas de dados apropriadas, lidar bem com erros e ser
bem testado.

A seguir, exploraremos alguns recursos do Rust que foram influenciados por funções funcionais.
linguagens: fechamentos e iteradores.

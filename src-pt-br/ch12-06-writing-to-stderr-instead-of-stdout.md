<!-- Old headings. Do not remove or links may break. -->

<a id="writing-error-messages-to-standard-error-instead-of-standard-output"></a>

## Redirecionando Erros para a Saída de Erro Padrão

Neste momento, estamos escrevendo toda a saída no terminal usando a macro
`println!`. Na maioria dos terminais, existem dois tipos de saída: _saída
padrão_ (`stdout`) para informações gerais e _saída de erro padrão_ (`stderr`)
para mensagens de erro. Essa distinção permite que as pessoas direcionem a
saída bem-sucedida de um programa para um arquivo e, ainda assim, vejam as
mensagens de erro na tela.

A macro `println!` só consegue imprimir em `stdout`, então precisamos usar
outra coisa para imprimir em `stderr`.

### Verificando para Onde os Erros Estão Sendo Escritos

Primeiro, vamos observar como o conteúdo impresso por `minigrep` está sendo
gravado atualmente em `stdout`, incluindo as mensagens de erro que gostaríamos
de enviar a `stderr` no lugar. Faremos isso redirecionando o fluxo de saída
padrão para um arquivo enquanto causamos um erro de propósito. Não
redirecionaremos o fluxo de erro padrão, então qualquer conteúdo enviado para
`stderr` continuará aparecendo na tela.

Espera-se que programas de linha de comando enviem mensagens de erro para o
fluxo de erro padrão, para que ainda possamos vê-las na tela mesmo que
redirecionemos `stdout` para um arquivo. Nosso programa ainda não está se
comportando bem: estamos prestes a ver que ele salva a mensagem de erro no
arquivo em vez disso!

Para demonstrar esse comportamento, vamos executar o programa com `>` e o
caminho do arquivo _output.txt_, para o qual queremos redirecionar `stdout`.
Não passaremos nenhum argumento, o que deve causar um erro:

```console
$ cargo run > output.txt
```

A sintaxe `>` instrui o shell a gravar o conteúdo de `stdout` em
_output.txt_ em vez de mostrá-lo na tela. Como não vimos a mensagem de erro
aparecer no terminal, isso significa que ela deve ter ido parar no arquivo.
Veja o conteúdo de _output.txt_:

```text
Problem parsing arguments: not enough arguments
```

Isso mesmo: a mensagem de erro está sendo impressa em `stdout`. É muito mais
útil que mensagens de erro como essa sejam impressas em `stderr`, para que
apenas os dados de uma execução bem-sucedida terminem no arquivo. Vamos mudar
isso.

### Imprimindo Erros em `stderr`

Usaremos o código da Listagem 12-24 para alterar a forma como as mensagens de
erro são impressas. Por causa da refatoração feita anteriormente neste
capítulo, todo o código que imprime mensagens de erro está concentrado em uma
única função, `main`. A biblioteca padrão fornece a macro `eprintln!`, que
imprime no fluxo de erro padrão, então vamos trocar os dois pontos em que
estávamos chamando `println!` para imprimir erros e passar a usar `eprintln!`.

<Listing number="12-24" file-name="src/main.rs" caption="Escrevendo mensagens de erro na saída de erro padrão em vez da saída padrão com `eprintln!`">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-24/src/main.rs:here}}
```

</Listing>

Agora vamos executar o programa novamente da mesma forma, sem argumentos e
redirecionando `stdout` com `>`:

```console
$ cargo run > output.txt
Problem parsing arguments: not enough arguments
```

Agora vemos o erro na tela, e _output.txt_ não contém nada, que é exatamente o
comportamento esperado de programas de linha de comando.

Vamos executar o programa outra vez com argumentos que não causam erro, mas
ainda redirecionando `stdout` para um arquivo:

```console
$ cargo run -- to poem.txt > output.txt
```

Não veremos nenhuma saída no terminal, e _output.txt_ conterá nossos
resultados:

<span class="filename">Nome do arquivo: output.txt</span>

```text
Are you nobody, too?
How dreary to be somebody!
```

Isso demonstra que agora estamos usando `stdout` para a saída bem-sucedida e
`stderr` para a saída de erro, como deve ser.

## Resumo

Este capítulo recapitula alguns dos principais conceitos que você aprendeu até
agora e mostra como realizar operações comuns de E/S em Rust. Com argumentos de
linha de comando, arquivos, variáveis de ambiente e a macro `eprintln!` para
imprimir erros, você agora está preparado para escrever aplicações de linha de
comando. Combinado aos conceitos dos capítulos anteriores, seu código ficará
bem organizado, armazenará dados de forma eficiente nas estruturas apropriadas,
lidará bem com erros e será bem testado.

A seguir, exploraremos alguns recursos de Rust influenciados por linguagens
funcionais: closures e iteradores.

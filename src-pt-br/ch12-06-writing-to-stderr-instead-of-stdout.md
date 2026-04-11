<!-- Old headings. Do not remove or links may break. -->

<a id="writing-error-messages-to-standard-error-instead-of-standard-output"></a>

## Redirecionando Erros para a Saída de Erro Padrão

No momento, estamos escrevendo toda a nossa saída no terminal usando a macro
`println!`. Na maioria dos terminais, há dois tipos de saída: a _saída padrão_
(`stdout`) para informações gerais e a _saída de erro padrão_ (`stderr`) para
mensagens de erro. Essa distinção permite que a pessoa usuária direcione a
saída bem-sucedida de um programa para um arquivo, ao mesmo tempo em que ainda
vê as mensagens de erro na tela.

A macro `println!` só é capaz de imprimir na saída padrão, então precisamos
usar outra coisa para imprimir na saída de erro padrão.

### Verificando Onde os Erros Estão Sendo Escritos

Primeiro, vamos observar como o conteúdo impresso por `minigrep` está sendo
escrito atualmente na saída padrão, incluindo as mensagens de erro que
queremos, em vez disso, enviar para a saída de erro padrão. Faremos isso
redirecionando o fluxo de saída padrão para um arquivo enquanto provocamos um
erro intencionalmente. Não redirecionaremos o fluxo de erro padrão, então tudo
o que for enviado para ele continuará aparecendo na tela.

Espera-se que programas de linha de comando enviem mensagens de erro para a
saída de erro padrão, para que possamos continuar vendo mensagens de erro na
tela mesmo quando redirecionamos a saída padrão para um arquivo. Nosso programa
não está se comportando bem neste momento: veremos que ele salva a mensagem de
erro em um arquivo!

Para demonstrar esse comportamento, executaremos o programa com `>` e o caminho
do arquivo, _output.txt_, para o qual queremos redirecionar a saída padrão. Não
passaremos nenhum argumento, o que deve causar um erro:

```console
$ cargo run > output.txt
```

A sintaxe `>` diz ao shell para escrever o conteúdo da saída padrão em
_output.txt_, em vez de mostrá-lo na tela. Como não vimos a mensagem de erro
que esperávamos ver na tela, isso significa que ela deve ter ido parar no
arquivo. Isto é o que _output.txt_ contém:

```text
Problem parsing arguments: not enough arguments
```

Exatamente: nossa mensagem de erro está sendo impressa na saída padrão. É muito
mais útil que mensagens de erro como essa sejam impressas na saída de erro
padrão, de modo que apenas os dados de uma execução bem-sucedida acabem no
arquivo. Vamos mudar isso.

### Imprimindo Erros na Saída de Erro Padrão

Usaremos o código da Listagem 12-24 para alterar a forma como as mensagens de
erro são impressas. Por causa da refatoração que fizemos anteriormente neste
capítulo, todo o código que imprime mensagens de erro está em uma única função,
`main`. A biblioteca padrão fornece a macro `eprintln!`, que imprime na saída
de erro padrão, então vamos substituir as duas chamadas a `println!` que
imprimem erros por `eprintln!`.

<Listing number="12-24" file-name="src/main.rs" caption="Escrevendo mensagens de erro na saída de erro padrão, em vez da saída padrão, com `eprintln!`">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-24/src/main.rs:here}}
```

</Listing>

Agora vamos executar o programa da mesma forma novamente, sem nenhum argumento
e redirecionando a saída padrão com `>`:

```console
$ cargo run > output.txt
Problem parsing arguments: not enough arguments
```

Agora vemos o erro na tela, e _output.txt_ não contém nada, que é exatamente o
comportamento esperado de programas de linha de comando.

Vamos executar o programa mais uma vez, agora com argumentos que não causem
erro, mas ainda redirecionando a saída padrão para um arquivo, assim:

```console
$ cargo run -- to poem.txt > output.txt
```

Não veremos nenhuma saída no terminal, e _output.txt_ conterá os nossos
resultados:

<span class="filename">Arquivo: output.txt</span>

```text
Are you nobody, too?
How dreary to be somebody!
```

Isso demonstra que agora estamos usando a saída padrão para a saída
bem-sucedida e a saída de erro padrão para as mensagens de erro, como deveria
ser.

## Resumo

Este capítulo retomou alguns dos conceitos mais importantes vistos até aqui e
mostrou como realizar operações comuns de E/S em Rust. Usando argumentos de
linha de comando, arquivos, variáveis de ambiente e a macro `eprintln!` para
imprimir erros, você agora está pronta ou pronto para escrever aplicações de
linha de comando. Combinado aos conceitos dos capítulos anteriores, seu código
estará bem organizado, armazenará dados de forma eficaz nas estruturas de dados
apropriadas, tratará erros de maneira elegante e será bem testado.

A seguir, exploraremos alguns recursos de Rust influenciados por linguagens
funcionais: closures e iteradores.

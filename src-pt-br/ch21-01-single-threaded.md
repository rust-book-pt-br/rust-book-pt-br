## Construindo um servidor web single-threaded

Começaremos fazendo um servidor web single-threaded funcionar. Antes de começarmos,
vamos ver rapidamente os protocolos envolvidos na construção de servidores web.
Os detalhes desses protocolos estão além do escopo deste livro, mas
uma breve visão geral fornecerá as informações de que você precisa.

Os dois principais protocolos envolvidos em servidores web são _Hypertext Transfer
Protocol_ _(HTTP)_ e _Transmission Control Protocol_ _(TCP)_. Ambos os protocolos
são protocolos de _requisição e resposta_, o que significa que um _cliente_ inicia requisições e um
_server_ escuta essas solicitações e fornece uma resposta ao cliente. O
conteúdo dessas solicitações e respostas é definido pelos protocolos.

TCP é o protocolo de nível inferior que descreve os detalhes de como as informações
vão de uma máquina para outra, mas não especifica quais são essas informações.
O HTTP se baseia no TCP, definindo o conteúdo das solicitações e
respostas. É tecnicamente possível usar HTTP com outros protocolos, mas, na
grande maioria dos casos, ele envia seus dados por TCP. Trabalharemos com os
bytes brutos de solicitações e respostas TCP e HTTP.

### Escutando a conexão TCP

Nosso servidor web precisa escutar uma conexão TCP, então essa é a primeira parte
com a qual vamos trabalhar. A biblioteca padrão oferece um módulo `std::net` que nos permite fazer
isso. Vamos fazer um novo projeto da maneira usual:

```console
$ cargo new hello
     Created binary (application) `hello` project
$ cd hello
```

Agora insira o código da Listagem 21-1 em _src/main.rs_ para começar. Esse código irá
escutar no endereço local `127.0.0.1:7878` por streams TCP de entrada. Quando
receber um stream, ele imprimirá `Connection established!`.

<Listing number="21-1" file-name="src/main.rs" caption="Escutando streams de entrada e imprimindo uma mensagem quando recebemos um stream">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-01/src/main.rs}}
```

</Listing>

Usando `TcpListener`, podemos escutar conexões TCP no endereço
`127.0.0.1:7878`. Nesse endereço, a parte antes dos dois pontos é um endereço IP
que representa o seu computador (ele é o mesmo em todos os computadores e não
representa especificamente o computador dos autores), e `7878` é a porta. Nós
escolhemos essa porta por dois motivos: HTTP normalmente não usa essa porta, então
é improvável que nosso servidor entre em conflito com algum outro servidor web que você tenha
rodando na máquina; além disso, 7878 corresponde a _rust_ digitado em um telefone.

A função `bind`, nesse cenário, funciona como a função `new`, pois
retorna uma nova instância de `TcpListener`. A função se chama `bind`
porque, em redes, conectar-se a uma porta para escutá-la é conhecido como “fazer bind
em uma porta”.

A função `bind` retorna um `Result<T, E>`, o que indica que
o bind pode falhar, por exemplo, se executarmos duas instâncias do nosso
programa e acabarmos com dois programas escutando a mesma porta. Como estamos
escrevendo um servidor básico apenas para fins de aprendizado, não vamos nos preocupar em
tratar esse tipo de erro; em vez disso, usamos `unwrap` para interromper o programa se
algum erro acontecer.

O método `incoming` em `TcpListener` retorna um iterator que nos fornece uma
sequência de streams (mais especificamente, streams do tipo `TcpStream`). Um único
_stream_ representa uma conexão aberta entre o cliente e o servidor.
_Conexão_ é o nome do processo completo de solicitação e resposta no qual um
cliente se conecta ao servidor, o servidor gera uma resposta e o servidor
fecha a conexão. Assim, leremos o `TcpStream` para ver o que
o cliente enviou e depois escreveremos nossa resposta no stream para enviar os dados de volta
ao cliente. No geral, esse loop `for` processará cada conexão por vez e
produzirá uma série de streams para tratarmos.

Por enquanto, nosso tratamento do stream consiste em chamar `unwrap` para encerrar
nosso programa se o stream apresentar algum erro; se não houver erros, o
programa imprime uma mensagem. Adicionaremos mais funcionalidades para o caso de sucesso na
próxima listagem. O motivo pelo qual podemos receber erros do método `incoming`
quando um cliente se conecta ao servidor é que não estamos realmente iterando
conexões. Em vez disso, estamos iterando sobre _tentativas de conexão_. A
conexão pode não ser bem-sucedida por vários motivos, muitos deles
específicos do sistema operacional. Por exemplo, muitos sistemas operacionais têm um limite para
o número de conexões abertas simultâneas que podem suportar; novas
tentativas de conexão acima desse limite produzirão erro até que algumas das
conexões abertas sejam fechadas.

Vamos tentar executar esse código! Invoque `cargo run` no terminal e carregue
_127.0.0.1:7878_ em um navegador. O navegador deve mostrar uma mensagem de erro
como “Redefinição de conexão” porque o servidor não está enviando de volta nenhum
dados. Mas, ao olhar para o terminal, você verá várias mensagens
impressas quando o navegador se conectou ao servidor.

```text
     Running `target/debug/hello`
Connection established!
Connection established!
Connection established!
```

Às vezes, você verá várias mensagens impressas para uma única solicitação do navegador; o
motivo pode ser que o navegador esteja fazendo uma solicitação para a página, bem como uma
solicitação de outros recursos, como o ícone _favicon.ico_ que aparece na
aba do navegador.

Também pode ser que o navegador esteja tentando se conectar ao servidor várias
vezes porque o servidor não está respondendo com nenhum dado. Quando `stream` sai
do escopo e é descartado no final do loop, a conexão é fechada como
parte da implementação de `drop`. Os navegadores às vezes lidam com
conexões fechadas tentando novamente, pois o problema pode ser temporário.

Às vezes, os navegadores também abrem múltiplas conexões com o servidor sem enviar
quaisquer solicitações para que, se eles *fizerem* solicitações depois, essas solicitações possam
acontecer mais rapidamente. Quando isso ocorrer, nosso servidor verá cada conexão,
independentemente de haver alguma solicitação nela. Muitas
versões de navegadores baseados no Chrome fazem isso, por exemplo; você pode desabilitar essa
otimização usando o modo de navegação privada ou um navegador diferente.

O importante é que conseguimos lidar com uma
conexão TCP.

Lembre-se de parar o programa pressionando <kbd>ctrl</kbd>-<kbd>C</kbd> quando
você terminar de executar uma versão específica do código. Em seguida, reinicie o programa
invocando o comando `cargo run` depois de cada conjunto de alterações no código
para ter certeza de que você está executando o código mais recente.

### Lendo a solicitação

Vamos implementar a funcionalidade de leitura da solicitação do navegador. Para
separar as responsabilidades de primeiro obter uma conexão e depois tomar alguma ação
com ela, criaremos uma nova função para processar conexões. Nessa
nova função `handle_connection`, leremos os dados do stream TCP e
os imprimiremos para que possamos ver o que está sendo enviado pelo navegador. Altere o
código para se parecer com a Listagem 21-2.

<Listing number="21-2" file-name="src/main.rs" caption="Lendo do `TcpStream` e imprimindo os dados">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-02/src/main.rs}}
```

</Listing>

Colocamos `std::io::BufReader` e `std::io::prelude` no escopo para obter acesso
a traits e tipos que nos permitem ler e escrever no stream. No
loop `for` da função `main`, em vez de imprimir uma mensagem dizendo que recebemos uma
conexão, agora chamamos a nova função `handle_connection` e passamos o
`stream` para ela.

Na função `handle_connection`, criamos uma nova instância de `BufReader` que
envolve uma referência a `stream`. O `BufReader` adiciona buffering ao gerenciar
as chamadas aos métodos da trait `std::io::Read` para nós.

Criamos uma variável chamada `http_request` para coletar as linhas da solicitação
que o navegador envia ao nosso servidor. Indicamos que queremos coletar essas
linhas em um vetor adicionando a anotação de tipo `Vec<_>`.

`BufReader` implementa a trait `std::io::BufRead`, que fornece o método `lines`.
O método `lines` retorna um iterator de `Result<String, std::io::Error>`,
dividindo o stream de dados sempre que encontra um byte de nova linha. Para obter cada
`String`, aplicamos `map` e `unwrap` a cada `Result`. O `Result`
pode conter erro se os dados não forem UTF-8 válidos ou se houver algum problema
de leitura do stream. Novamente, um programa de produção deveria tratar esses erros
de forma mais elegante, mas estamos optando por interromper o programa em caso de erro por
simplicidade.

O navegador sinaliza o fim de uma solicitação HTTP enviando dois caracteres de
nova linha em sequência; portanto, para obter uma solicitação do stream, pegamos linhas até
encontrarmos uma linha que seja a string vazia. Depois de coletarmos as linhas no
vetor, nós as imprimimos usando uma formatação de debug mais legível para que possamos
examinar as instruções que o navegador está enviando ao nosso servidor.

Vamos testar esse código. Inicie o programa e faça uma solicitação em um navegador
novamente. Observe que ainda receberemos uma página de erro no navegador, mas a
saída do programa no terminal agora será semelhante a esta:

<!-- manual-regeneration
cd listings/ch21-web-server/listing-21-02
cargo run
make a request to 127.0.0.1:7878
Can't automate because the output depends on making requests
-->

```console
$ cargo run
   Compiling hello v0.1.0 (file:///projects/hello)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.42s
     Running `target/debug/hello`
Request: [
    "GET / HTTP/1.1",
    "Host: 127.0.0.1:7878",
    "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:99.0) Gecko/20100101 Firefox/99.0",
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    "Accept-Language: en-US,en;q=0.5",
    "Accept-Encoding: gzip, deflate, br",
    "DNT: 1",
    "Connection: keep-alive",
    "Upgrade-Insecure-Requests: 1",
    "Sec-Fetch-Dest: document",
    "Sec-Fetch-Mode: navigate",
    "Sec-Fetch-Site: none",
    "Sec-Fetch-User: ?1",
    "Cache-Control: max-age=0",
]
```

Dependendo do seu navegador, você poderá obter resultados ligeiramente diferentes. Agora que
estamos imprimindo os dados da solicitação, podemos ver por que obtemos várias conexões
de uma solicitação do navegador observando o caminho após `GET` na primeira linha
da solicitação. Se todas as conexões repetidas solicitarem _/_, sabemos que
o navegador está tentando buscar _/_ repetidamente porque não está obtendo resposta
do nosso programa.

Vamos analisar esses dados da solicitação para entender o que o navegador está pedindo ao
nosso programa.

<!-- Old headings. Do not remove or links may break. -->

<a id="a-closer-look-at-an-http-request"></a>
<a id="looking-closer-at-an-http-request"></a>

### Analisando mais de perto uma requisição HTTP

HTTP é um protocolo baseado em texto e uma solicitação assume este formato:

```text
Method Request-URI HTTP-Version CRLF
headers CRLF
message-body
```

A primeira linha é a _linha de solicitação_ que contém informações sobre o que o
cliente está solicitando. A primeira parte da linha de solicitação indica o método
em uso, como `GET` ou `POST`, que descreve como o cliente está fazendo
essa solicitação. Nosso cliente usou uma requisição `GET`, o que significa que está solicitando
informação.

A próxima parte da linha de solicitação é _/_, que indica o _uniform resource
identifier_ _(URI)_ solicitado pelo cliente. Um URI é quase, mas não exatamente,
o mesmo que um _uniform resource locator_ _(URL)_. A diferença entre URIs
e URLs não é importante para nossos propósitos neste capítulo, mas a especificação HTTP
usa o termo _URI_, então podemos substituir mentalmente _URL_ por _URI_ aqui.

A última parte é a versão HTTP usada pelo cliente e, em seguida, a linha de solicitação
termina em uma sequência CRLF. (_CRLF_ significa _carriage return_ e _line feed_,
termos da época das máquinas de escrever.) A sequência CRLF também pode ser
escrita como `\r\n`, em que `\r` é um carriage return e `\n` é um line feed. A
sequência CRLF separa a linha de solicitação do restante dos dados da requisição.
Observe que, quando o CRLF é impresso, vemos o início de uma nova linha em vez de `\r\n`.

Observando os dados da linha de solicitação que recebemos ao executar nosso programa até agora,
vemos que `GET` é o método, _/_ é o URI da solicitação e `HTTP/1.1` é a
versão.

Após a linha de solicitação, as linhas restantes a partir de `Host:` são
cabeçalhos. As solicitações `GET` não possuem corpo.

Tente fazer uma solicitação usando um navegador diferente ou pedindo um
endereço diferente, como _127.0.0.1:7878/test_, para ver como os dados da solicitação mudam.

Agora que sabemos o que o navegador está pedindo, vamos enviar alguns dados!

### Escrevendo uma resposta

Vamos implementar o envio de dados em resposta a uma requisição do cliente.
As respostas têm o seguinte formato:

```text
HTTP-Version Status-Code Reason-Phrase CRLF
headers CRLF
message-body
```

A primeira linha é uma _linha de status_ que contém a versão HTTP usada na
resposta, um código de status numérico que resume o resultado da solicitação e
uma reason phrase que fornece uma descrição textual do código de status. Depois da
sequência CRLF vêm os cabeçalhos, outra sequência CRLF e o corpo da
resposta.

Aqui está um exemplo de resposta que usa HTTP versão 1.1 e tem código de status
200, a reason phrase OK, sem cabeçalhos e sem corpo:

```text
HTTP/1.1 200 OK\r\n\r\n
```

O código de status 200 é a resposta padrão de sucesso. Esse texto forma uma pequena
resposta HTTP bem-sucedida. Vamos escrevê-la no stream como resposta a uma
solicitação bem-sucedida. Na função `handle_connection`, remova o
`println!` que estava imprimindo os dados da solicitação e substitua-o pelo código da
Listagem 21-3.

<Listing number="21-3" file-name="src/main.rs" caption="Escrevendo uma pequena resposta HTTP de sucesso no stream">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-03/src/main.rs:here}}
```

</Listing>

A primeira linha nova define a variável `response`, que contém os dados da
mensagem de sucesso. Em seguida, chamamos `as_bytes` em `response` para converter a
string em bytes. O método `write_all` em `stream` recebe um `&[u8]` e
envia esses bytes diretamente pela conexão. Como a operação `write_all`
pode falhar, usamos `unwrap` em qualquer erro, como antes. Novamente, em
uma aplicação real, você adicionaria tratamento de erros aqui.

Com essas alterações, vamos executar nosso código e fazer uma solicitação. Já não estamos
imprimindo dados no terminal, então não veremos nenhuma saída além da
saída do Cargo. Ao carregar _127.0.0.1:7878_ em um navegador, você deve
obter uma página em branco em vez de um erro. Você acabou de implementar manualmente o recebimento de uma
solicitação HTTP e o envio de uma resposta.

### Retornando HTML de verdade

Vamos implementar a funcionalidade de retornar mais do que uma página em branco. Crie
o novo arquivo _hello.html_ na raiz do diretório do seu projeto, não no
diretório _src_. Você pode colocar qualquer HTML que desejar; a Listagem 21-4 mostra uma
possibilidade.

<Listing number="21-4" file-name="hello.html" caption="Um arquivo HTML de exemplo para retornar em uma resposta">

```html
{{#include ../listings/ch21-web-server/listing-21-05/hello.html}}
```

</Listing>

Esse é um documento HTML5 mínimo com um título e algum texto. Para devolvê-lo
do servidor quando uma solicitação for recebida, modificaremos `handle_connection`, como
mostrado na Listagem 21-5, para ler o arquivo HTML, adicioná-lo à resposta como corpo
e enviá-lo.

<Listing number="21-5" file-name="src/main.rs" caption="Enviando o conteúdo de *hello.html* como corpo da resposta">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-05/src/main.rs:here}}
```

</Listing>

Adicionamos `fs` à instrução `use` para trazer para o escopo o
módulo de sistema de arquivos da biblioteca padrão. O código para ler o conteúdo de um arquivo para uma
string deve parecer familiar; nós o usamos quando lemos o conteúdo de um arquivo para
nosso projeto de E/S na Listagem 12-4.

Em seguida, usamos `format!` para adicionar o conteúdo do arquivo como corpo da
resposta de sucesso. Para garantir uma resposta HTTP válida, adicionamos o cabeçalho `Content-Length`,
que é definido com o tamanho do nosso corpo de resposta; neste caso, o tamanho de
`hello.html`.

Execute esse código com `cargo run` e carregue _127.0.0.1:7878_ no navegador; você
deve ver seu HTML renderizado.

Atualmente, estamos ignorando os dados da solicitação em `http_request` e apenas enviando
de volta o conteúdo do arquivo HTML incondicionalmente. Isso significa que, se você tentar
solicitar _127.0.0.1:7878/something-else_ no navegador, ainda receberá
essa mesma resposta HTML. No momento, nosso servidor é muito limitado e
não faz o que a maioria dos servidores web faz. Queremos personalizar nossas respostas
dependendo da solicitação e enviar o arquivo HTML apenas para uma
solicitação bem-formada para _/_.

### Validando a solicitação e respondendo seletivamente

Neste momento, nosso servidor web retornará o HTML do arquivo, não importa o que o
cliente tenha solicitado. Vamos adicionar funcionalidade para verificar se o navegador está
solicitando _/_ antes de retornar o arquivo HTML e retornar um erro se o
navegador solicitar qualquer outra coisa. Para isso, precisamos modificar `handle_connection`,
conforme mostrado na Listagem 21-6. Este novo código verifica o conteúdo da solicitação
recebida em relação ao que sabemos ser uma solicitação para _/_ e adiciona blocos `if`
e `else` para tratar requisições de maneira diferente.

<Listing number="21-6" file-name="src/main.rs" caption="Tratando requisições para */* de forma diferente das demais requisições">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-06/src/main.rs:here}}
```

</Listing>

Vamos olhar apenas para a primeira linha da solicitação HTTP; então, em vez de
ler a solicitação inteira em um vetor, chamamos `next` para obter o
primeiro item do iterator. O primeiro `unwrap` cuida do `Option` e
interrompe o programa se o iterator não tiver itens. O segundo `unwrap` lida com o
`Result` e tem o mesmo efeito que o `unwrap` que estava no `map` adicionado na
Listagem 21-2.

Em seguida, verificamos se `request_line` é igual à linha de solicitação de uma requisição GET
para o caminho _/_. Se for esse o caso, o bloco `if` retorna o conteúdo do nosso
arquivo HTML.

Se `request_line` _não_ for igual à requisição GET para o caminho _/_,
isso significa que recebemos alguma outra solicitação. Daqui a pouco adicionaremos
código ao bloco `else` para responder a todas as outras requisições.

Execute esse código agora e solicite _127.0.0.1:7878_; você deve obter o HTML
de _hello.html_. Se fizer qualquer outra solicitação, como
_127.0.0.1:7878/something-else_, receberá um erro de conexão como aqueles que você
viu ao executar o código das Listagens 21-1 e 21-2.

Agora vamos adicionar o código da Listagem 21-7 ao bloco `else` para retornar uma resposta
com o código de status 404, que sinaliza que o conteúdo solicitado
não foi encontrado. Também retornaremos algum HTML para que uma página seja renderizada no navegador,
indicando a resposta ao usuário final.

<Listing number="21-7" file-name="src/main.rs" caption="Respondendo com código de status 404 e uma página de erro se qualquer coisa diferente de */* for requisitada">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-07/src/main.rs:here}}
```

</Listing>

Aqui, nossa resposta tem uma linha de status com o código 404 e a reason phrase
`NOT FOUND`. O corpo da resposta será o HTML do arquivo _404.html_.
Você precisará criar um arquivo _404.html_ ao lado de _hello.html_ para a
página de erro; novamente, fique à vontade para usar qualquer HTML que desejar ou o HTML de exemplo da
Listagem 21-8.

<Listing number="21-8" file-name="404.html" caption="Conteúdo de exemplo para a página enviada em qualquer resposta 404">

```html
{{#include ../listings/ch21-web-server/listing-21-07/404.html}}
```

</Listing>

Com essas alterações, execute seu servidor novamente. Solicitar _127.0.0.1:7878_ deve
retornar o conteúdo de _hello.html_, e qualquer outra solicitação, como
_127.0.0.1:7878/foo_, deve retornar a página de erro em _404.html_.

<!-- Old headings. Do not remove or links may break. -->

<a id="a-touch-of-refactoring"></a>

### Refatorando

No momento, os blocos `if` e `else` têm muita repetição: ambos
leem arquivos e escrevem seu conteúdo no stream. As
únicas diferenças são a linha de status e o nome do arquivo. Vamos tornar o código mais
conciso, separando essas diferenças em ramos `if` e `else` que
atribuirão os valores da linha de status e do nome do arquivo a variáveis;
então poderemos usar essas variáveis incondicionalmente no código que lê o arquivo
e escreve a resposta. A Listagem 21-9 mostra o código resultante após substituir
os grandes blocos `if` e `else`.

<Listing number="21-9" file-name="src/main.rs" caption="Refatorando os blocos `if` e `else` para conter apenas o código que difere entre os dois casos">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-09/src/main.rs:here}}
```

</Listing>

Agora os blocos `if` e `else` retornam apenas os valores apropriados para a
linha de status e o nome do arquivo em uma tupla; então usamos desestruturação para atribuir esses
dois valores a `status_line` e `filename`, usando um padrão na
instrução `let`, como discutido no Capítulo 19.

O código anteriormente duplicado agora está fora dos blocos `if` e `else` e
usa as variáveis `status_line` e `filename`. Isso torna mais fácil ver
a diferença entre os dois casos e significa que temos apenas um lugar para
atualizar o código caso queiramos mudar a forma como a leitura do arquivo e a escrita da resposta
funcionam. O comportamento do código da Listagem 21-9 é o mesmo do código da
Listagem 21-7.

Incrível! Agora temos um servidor web simples em aproximadamente 40 linhas de código Rust
que responde a uma solicitação com uma página de conteúdo e responde a todas as outras
solicitações com uma resposta 404.

Atualmente, nosso servidor roda em uma única thread, o que significa que ele só pode atender uma
requisição por vez. Vamos examinar como isso pode se tornar um problema simulando algumas
requisições lentas. Depois, vamos corrigir isso para que nosso servidor possa lidar com vários
pedidos ao mesmo tempo.

## Construindo um servidor web de thread único

Começaremos fazendo com que um web server de thread único funcione. Antes de começarmos,
vamos dar uma rápida visão geral dos protocolos envolvidos na construção da web
servidores. Os detalhes desses protocolos estão além do escopo deste livro, mas
uma breve visão geral fornecerá as informações de que você precisa.

Os dois principais protocolos envolvidos em web servers são _Hypertext Transfer
Protocolo_ _(HTTP)_ e _Protocolo de controle de transmissão_ _(TCP)_. Ambos os protocolos
são protocolos _solicitação-resposta_, o que significa que um _cliente_ inicia solicitações e um
_server_ escuta as solicitações e fornece uma resposta ao cliente. O
o conteúdo dessas solicitações e respostas é definido pelos protocolos.

TCP é o protocolo de nível inferior que descreve os detalhes de como as informações
vai de um servidor para outro, mas não especifica quais são essas informações.
O HTTP se baseia no TCP, definindo o conteúdo das solicitações e
respostas. É tecnicamente possível usar HTTP com outros protocolos, mas em
na grande maioria dos casos, o HTTP envia seus dados por TCP. Trabalharemos com o
bytes brutos de solicitações e respostas TCP e HTTP.

### Ouvindo a conexão TCP

Nosso web server precisa escutar uma conexão TCP, então essa é a primeira parte
vamos trabalhar. A biblioteca padrão oferece um módulo `std::net` que nos permite fazer
isso. Vamos fazer um novo projeto da maneira usual:

```console
$ cargo new hello
     Created binary (application) `hello` project
$ cd hello
```

Agora insira o código da Listagem 21-1 em _src/main.rs_ para começar. Este código irá
escute no endereço local `127.0.0.1:7878` o TCP de entrada streams. Quando
recebe um stream de entrada, ele imprimirá `Connection established!`.

<Listing number="21-1" file-name="src/main.rs" caption="Escutando streams de entrada e imprimindo uma mensagem quando recebemos um stream">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-01/src/main.rs}}
```

</Listing>

Usando `TcpListener`, podemos escutar conexões TCP no endereço
` 127.0.0.1:7878 `. No endereço, a seção antes dos dois pontos é um endereço IP
representando o seu computador (é o mesmo em todos os computadores e não
representam especificamente o computador dos autores) e` 7878`é a porta. Nós temos
escolhi esta porta por dois motivos: HTTP normalmente não é aceito nesta porta, então
é improvável que nosso servidor entre em conflito com qualquer outro web server que você possa ter
rodando em sua máquina e 7878 é digitado _rust_ em um telefone.

A função `bind` neste cenário funciona como a função `new`, pois
retornará uma nova instância ` TcpListener`. A função é chamada ` bind`
porque, em rede, conectar-se a uma porta para escutar é conhecido como “ligação
para um porto.”

A função `bind` retorna um `Result<T, E>`, que indica que é
possível que a ligação falhe, por exemplo, se executarmos duas instâncias do nosso
programa e então tinha dois programas ouvindo a mesma porta. Porque estamos
escrevendo um servidor básico apenas para fins de aprendizagem, não nos preocuparemos
lidar com esses tipos de erros; em vez disso, usamos ` unwrap`para parar o programa se
erros acontecem.

O método `incoming` em `TcpListener` retorna um iterator que nos dá um
sequência de streams (mais especificamente, streams do tipo `TcpStream`). Um único
_stream_ representa uma conexão aberta entre o cliente e o servidor.
_Conexão_ é o nome do processo completo de solicitação e resposta no qual um
cliente se conecta ao servidor, o servidor gera uma resposta e o servidor
fecha a conexão. Como tal, leremos o ` TcpStream`para ver o que
o cliente enviou e então escrevemos nossa resposta para o stream para enviar os dados de volta para
o cliente. No geral, este loop ` for`processará cada conexão por vez e
produza uma série de streams para nós manusearmos.

Por enquanto, nosso tratamento do stream consiste em chamar `unwrap` para encerrar
nosso programa se o stream apresentar algum erro; se não houver erros, o
programa imprime uma mensagem. Adicionaremos mais funcionalidades para o caso de sucesso em
a próxima listagem. O motivo pelo qual podemos receber erros do método `incoming`
quando um cliente se conecta ao servidor é que não estamos realmente iterando
conexões. Em vez disso, estamos iterando _tentativas de conexão_. O
a conexão pode não ser bem-sucedida por vários motivos, muitos deles
específico do sistema operacional. Por exemplo, muitos sistemas operacionais têm um limite para
o número de conexões abertas simultâneas que podem suportar; nova conexão
tentativas além desse número produzirão um erro até que algumas das portas abertas
as conexões estão fechadas.

Vamos tentar executar este código! Invoque `cargo run` no terminal e carregue
_127.0.0.1:7878_ em um navegador da web. O navegador deve mostrar uma mensagem de erro
como “Redefinição de conexão” porque o servidor não está enviando de volta nenhum
dados. Mas quando você olha para o seu terminal, você verá várias mensagens que
foram impressos quando o navegador se conectou ao servidor!

```text
     Running `target/debug/hello`
Connection established!
Connection established!
Connection established!
```

Às vezes, você verá várias mensagens impressas para uma solicitação do navegador; o
o motivo pode ser que o navegador esteja fazendo uma solicitação para a página, bem como um
solicitação de outros recursos, como o ícone _favicon.ico_ que aparece no
guia do navegador.

Também pode ser que o navegador esteja tentando se conectar ao servidor várias vezes.
vezes porque o servidor não está respondendo com nenhum dado. Quando `stream` apaga
do escopo e é descartado no final do loop, a conexão é fechada como
parte da implementação `drop`. Os navegadores às vezes lidam com
conexões tentando novamente, pois o problema pode ser temporário.

Às vezes, os navegadores também abrem múltiplas conexões com o servidor sem enviar
quaisquer solicitações para que, se eles *fizerem* solicitações posteriormente, essas solicitações possam
acontecer mais rapidamente. Quando isso ocorrer, nosso servidor verá cada conexão,
independentemente de haver alguma solicitação nessa conexão. Muitos
versões de navegadores baseados no Chrome fazem isso, por exemplo; você pode desabilitar isso
otimização usando o modo de navegação privada ou usando um navegador diferente.

O fator importante é que conseguimos lidar com um TCP
conexão!

Lembre-se de parar o programa pressionando <kbd>ctrl</kbd>-<kbd>C</kbd> quando
você concluiu a execução de uma versão específica do código. Em seguida, reinicie o programa
invocando o comando `cargo run` depois de fazer cada conjunto de alterações de código
para ter certeza de que você está executando o código mais recente.

### Lendo a solicitação

Vamos implementar a funcionalidade de leitura da solicitação do navegador! Para
separe as preocupações de primeiro obter uma conexão e depois tomar alguma ação
com a conexão, iniciaremos uma nova função para processamento de conexões. Em
esta nova função `handle_connection`, leremos os dados do TCP stream e
imprima-o para que possamos ver os dados que estão sendo enviados do navegador. Alterar o
código para se parecer com a Listagem 21-2.

<Listing number="21-2" file-name="src/main.rs" caption="Lendo do `TcpStream` e imprimindo os dados">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-02/src/main.rs}}
```

</Listing>

Colocamos `std::io::BufReader` e `std::io::prelude` no escopo para obter acesso
para traits e tipos que nos permitem ler e gravar no stream. No `for`
loop na função ` main`, em vez de imprimir uma mensagem dizendo que fizemos um
conexão, agora chamamos a nova função ` handle_connection`e passamos o
` stream`para ele.

Na função `handle_connection`, criamos uma nova instância ` BufReader`que
envolve uma referência ao ` stream`. O ` BufReader`adiciona buffer gerenciando
chamadas para os métodos ` std::io::Read`trait para nós.

Criamos uma variável chamada `http_request` para coletar as linhas da solicitação
o navegador envia para o nosso servidor. Indicamos que queremos coletar esses
linhas em um vetor adicionando a anotação de tipo `Vec<_>`.

`BufReader ` implementa o`std::io::BufRead ` trait, que fornece o`lines `
método. O método` lines `retorna um iterator de` Result<String,
std::io::Error> `dividindo o stream de dados sempre que vê uma nova linha
byte. Para obter cada` String `, nós` map `e` unwrap `cada` Result `. O` Result`
pode haver um erro se os dados não forem UTF-8 válidos ou se houver um problema
lendo do stream. Novamente, um programa de produção deve lidar com esses erros
mais graciosamente, mas estamos optando por parar o programa no caso de erro para
simplicidade.

O navegador sinaliza o fim de uma solicitação HTTP enviando duas novas linhas
caracteres seguidos, portanto, para obter uma solicitação do stream, pegamos linhas até
obtemos uma linha que é a string vazia. Depois de coletarmos as linhas no
vetor, estamos imprimindo-os usando uma formatação bastante depurada para que possamos
dê uma olhada nas instruções que o navegador da web está enviando ao nosso servidor.

Vamos tentar este código! Inicie o programa e faça uma solicitação em um navegador da web
novamente. Observe que ainda receberemos uma página de erro no navegador, mas nosso
a saída do programa no terminal agora será semelhante a esta:

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

Dependendo do seu navegador, você poderá obter resultados ligeiramente diferentes. Agora isso
estamos imprimindo os dados da solicitação, podemos ver por que obtemos várias conexões
de uma solicitação do navegador observando o caminho após `GET` na primeira linha
do pedido. Se todas as conexões repetidas solicitarem _/_, sabemos o
o navegador está tentando buscar _/_ repetidamente porque não está obtendo resposta
do nosso programa.

Vamos analisar esses dados de solicitação para entender o que o navegador está solicitando
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
sendo usado, como `GET` ou `POST`, que descreve como o cliente está fazendo
este pedido. Nosso cliente usou uma solicitação ` GET`, o que significa que está solicitando
informação.

A próxima parte da linha de solicitação é _/_, que indica o recurso _uniform
identificador_ _(URI)_ que o cliente está solicitando: um URI é quase, mas não exatamente,
o mesmo que um _localizador uniforme de recursos_ _(URL)_. A diferença entre URIs
e URLs não são importantes para nossos propósitos neste capítulo, mas a especificação HTTP
usa o termo _URI_, então podemos substituir mentalmente _URL_ por _URI_ aqui.

A última parte é a versão HTTP que o cliente usa e, em seguida, a linha de solicitação
termina em uma sequência CRLF. (_CRLF_ significa _retorno de carro_ e _alimentação de linha_,
que são termos da época da máquina de escrever!) A sequência CRLF também pode ser
escrito como `\r\n`, onde ` \r`é um retorno de carro e ` \n`é um avanço de linha. O
_Sequência CRLF_ separa a linha de solicitação do restante dos dados da solicitação.
Observe que quando o CRLF é impresso, vemos o início de uma nova linha em vez de ` \r\n`.

Observando os dados da linha de solicitação que recebemos ao executar nosso programa até agora,
vemos que `GET` é o método, _/_ é o URI da solicitação e `HTTP/1.1` é o
versão.

Após a linha de solicitação, as linhas restantes a partir de `Host:` são
cabeçalhos. As solicitações `GET` não possuem corpo.

Tente fazer uma solicitação de um navegador diferente ou solicitar um navegador diferente.
endereço, como _127.0.0.1:7878/test_, para ver como os dados da solicitação mudam.

Agora que sabemos o que o navegador está pedindo, vamos enviar alguns dados!

### Escrevendo uma resposta

Vamos implementar o envio de dados em resposta a uma requisição do cliente.
As respostas têm o seguinte formato:

```text
HTTP-Version Status-Code Reason-Phrase CRLF
headers CRLF
message-body
```

A primeira linha é uma _linha de status_ que contém a versão HTTP usada no
resposta, um código de status numérico que resume o resultado da solicitação e
uma frase de motivo que fornece uma descrição de texto do código de status. Depois do
A sequência CRLF são quaisquer cabeçalhos, outra sequência CRLF e o corpo do
resposta.

Aqui está um exemplo de resposta que usa HTTP versão 1.1 e tem um código de status de
200, uma frase de motivo OK, sem cabeçalhos e sem corpo:

```text
HTTP/1.1 200 OK\r\n\r\n
```

O código de status 200 é a resposta padrão de sucesso. O texto é um pequeno
resposta HTTP bem-sucedida. Vamos escrever isso no stream como nossa resposta a um
solicitação bem sucedida! Na função `handle_connection`, remova o
` println!`que estava imprimindo os dados da solicitação e substitua-os pelo código em
Listagem 21-3.

<Listing number="21-3" file-name="src/main.rs" caption="Escrevendo uma pequena resposta HTTP de sucesso no stream">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-03/src/main.rs:here}}
```

</Listing>

A primeira nova linha define a variável `response` que contém o sucesso
dados da mensagem. Então, chamamos `as_bytes` em nosso `response` para converter o
dados de string em bytes. O método `write_all` em `stream` usa um `&[u8]` e
envia esses bytes diretamente pela conexão. Porque o `write_all`
operação pode falhar, usamos ` unwrap`em qualquer resultado de erro como antes. Novamente, em
um aplicativo real, você adicionaria tratamento de erros aqui.

Com essas alterações, vamos executar nosso código e fazer uma solicitação. Já não estamos
imprimindo quaisquer dados no terminal, então não veremos nenhuma saída além do
saída de Cargo. Ao carregar _127.0.0.1:7878_ em um navegador da web, você deve
obtenha uma página em branco em vez de um erro. Você acabou de codificar manualmente o recebimento de um HTTP
solicitar e enviar uma resposta!

### Retornando HTML de verdade

Vamos implementar a funcionalidade para retornar mais que uma página em branco. Criar
o novo arquivo _hello.html_ na raiz do diretório do seu projeto, não no
diretório _src_. Você pode inserir qualquer HTML que desejar; A Listagem 21-4 mostra um
possibilidade.

<Listing number="21-4" file-name="hello.html" caption="Um arquivo HTML de exemplo para retornar em uma resposta">

```html
{{#include ../listings/ch21-web-server/listing-21-05/hello.html}}
```

</Listing>

Este é um documento HTML5 mínimo com um título e algum texto. Para devolver isso
do servidor quando uma solicitação for recebida, modificaremos `handle_connection` como
mostrado na Listagem 21-5 para ler o arquivo HTML, adicione-o à resposta como um corpo,
e envie.

<Listing number="21-5" file-name="src/main.rs" caption="Enviando o conteúdo de *hello.html* como corpo da resposta">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-05/src/main.rs:here}}
```

</Listing>

Adicionamos `fs` à instrução `use` para trazer a biblioteca padrão
módulo do sistema de arquivos no escopo. O código para ler o conteúdo de um arquivo para um
string deve parecer familiar; usamos quando lemos o conteúdo de um arquivo para
nosso projeto de E/S na Listagem 12-4.

A seguir, usamos `format!` para adicionar o conteúdo do arquivo como o corpo do sucesso
resposta. Para garantir uma resposta HTTP válida, adicionamos o cabeçalho `Content-Length`,
que é definido para o tamanho do nosso corpo de resposta - neste caso, o tamanho do
` hello.html`.

Execute este código com `cargo run` e carregue _127.0.0.1:7878_ em seu navegador; você
deve ver seu HTML renderizado!

Atualmente, estamos ignorando os dados da solicitação em `http_request` e apenas enviando
devolver o conteúdo do arquivo HTML incondicionalmente. Isso significa que se você tentar
solicitando _127.0.0.1:7878/something-else_ em seu navegador, você ainda receberá
de volta esta mesma resposta HTML. No momento, nosso servidor é muito limitado e
não faz o que a maioria dos web servers faz. Queremos personalizar nossas respostas
dependendo da solicitação e apenas enviar de volta o arquivo HTML para um arquivo bem formado
solicitação para _/_.

### Validando a solicitação e respondendo seletivamente

Neste momento, nosso web server retornará o HTML do arquivo, não importa qual seja o
cliente solicitou. Vamos adicionar funcionalidade para verificar se o navegador está
solicitando _/_ antes de retornar o arquivo HTML e retornar um erro se o
navegador solicita qualquer outra coisa. Para isso precisamos modificar `handle_connection`,
conforme mostrado na Listagem 21-6. Este novo código verifica o conteúdo da solicitação
recebido em relação ao que sabemos que é uma solicitação de _/_ e adiciona ` if`e
Blocos ` else`para tratar solicitações de maneira diferente.

<Listing number="21-6" file-name="src/main.rs" caption="Tratando requisições para */* de forma diferente das demais requisições">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-06/src/main.rs:here}}
```

</Listing>

Veremos apenas a primeira linha da solicitação HTTP, então, em vez disso,
do que ler toda a solicitação em um vetor, estamos chamando `next` para obter o
primeiro item do iterator. O primeiro `unwrap` cuida do `Option` e
interrompe o programa se o iterator não tiver itens. O segundo `unwrap` lida com o
`Result ` e tem o mesmo efeito que o`unwrap ` que estava no`map` adicionado em
Listagem 21-2.

A seguir, verificamos `request_line` para ver se ele é igual à linha de solicitação de um GET
solicitação para o caminho _/_. Se isso acontecer, o bloco `if` retorna o conteúdo do nosso
Arquivo HTML.

Se `request_line` _não_ for igual à solicitação GET para o caminho _/_, ele
significa que recebemos alguma outra solicitação. Adicionaremos código ao bloco `else` em
um momento para responder a todos os outros pedidos.

Execute este código agora e solicite _127.0.0.1:7878_; você deve obter o HTML
_olá.html_. Se você fizer qualquer outra solicitação, como
_127.0.0.1:7878/something-else_, você receberá um erro de conexão como aqueles que você
vi ao executar o código na Listagem 21-1 e na Listagem 21-2.

Agora vamos adicionar o código da Listagem 21-7 ao bloco `else` para retornar uma resposta
com o código de status 404, que sinaliza que o conteúdo da solicitação foi
não encontrado. Também retornaremos algum HTML para uma página ser renderizada no navegador
indicando a resposta ao usuário final.

<Listing number="21-7" file-name="src/main.rs" caption="Respondendo com código de status 404 e uma página de erro se qualquer coisa diferente de */* for requisitada">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-07/src/main.rs:here}}
```

</Listing>

Aqui, nossa resposta tem uma linha de status com o código de status 404 e a frase de motivo
`NOT FOUND`. O corpo da resposta será o HTML do arquivo _404.html_.
Você precisará criar um arquivo _404.html_ próximo a _hello.html_ para o erro
página; novamente, sinta-se à vontade para usar qualquer HTML que desejar ou usar o HTML de exemplo em
Listagem 21-8.

<Listing number="21-8" file-name="404.html" caption="Conteúdo de exemplo para a página enviada em qualquer resposta 404">

```html
{{#include ../listings/ch21-web-server/listing-21-07/404.html}}
```

</Listing>

Com essas alterações, execute seu servidor novamente. Solicitar _127.0.0.1:7878_ deve
retornar o conteúdo de _hello.html_ e qualquer outra solicitação, como
_127.0.0.1:7878/foo_, deve retornar o erro HTML de _404.html_.

<!-- Old headings. Do not remove or links may break. -->

<a id="a-touch-of-refactoring"></a>

### Refactoring

No momento, os blocos `if` e `else` têm muita repetição: são
tanto lendo arquivos quanto gravando o conteúdo dos arquivos no stream. O
as únicas diferenças são a linha de status e o nome do arquivo. Vamos tornar o código mais
conciso, separando essas diferenças em linhas `if` e `else` separadas
isso atribuirá os valores da linha de status e o nome do arquivo às variáveis;
podemos então usar essas variáveis incondicionalmente no código para ler o arquivo
e escreva a resposta. A Listagem 21-9 mostra o código resultante após a substituição
os grandes blocos `if` e `else`.

<Listing number="21-9" file-name="src/main.rs" caption="Refatorando os blocos `if` e `else` para conter apenas o código que difere entre os dois casos">

```rust,no_run
{{#rustdoc_include ../listings/ch21-web-server/listing-21-09/src/main.rs:here}}
```

</Listing>

Agora os blocos `if` e `else` retornam apenas os valores apropriados para o
linha de status e nome do arquivo em uma tupla; então usamos a desestruturação para atribuir esses
dois valores para `status_line` e `filename` usando um padrão no `let`
declaração, conforme discutido no Capítulo 19.

O código anteriormente duplicado agora está fora dos blocos `if` e `else` e
usa as variáveis `status_line` e `filename`. Isso torna mais fácil ver
a diferença entre os dois casos, e isso significa que temos apenas um lugar para
atualize o código se quisermos alterar a forma como a leitura do arquivo e a escrita da resposta
trabalho. O comportamento do código na Listagem 21-9 será o mesmo daquele em
Listagem 21-7.

Incrível! Agora temos um web server simples em aproximadamente 40 linhas de código Rust
que responde a uma solicitação com uma página de conteúdo e responde a todas as outras
solicitações com uma resposta 404.

Atualmente, nosso servidor roda em um único thread, o que significa que ele só pode servir um
solicite por vez. Vamos examinar como isso pode ser um problema simulando alguns
solicitações lentas. Então, vamos consertar isso para que nosso servidor possa lidar com vários
pedidos de uma só vez.

## Instalação

O primeiro passo é instalar o Rust. Vamos baixar o Rust por meio do `rustup`,
uma ferramenta de linha de comando para gerenciar versões do Rust e
ferramentas associadas. Você precisará de uma conexão com a internet para o
download.

> Nota: Se por algum motivo você preferir não usar `rustup`, consulte a página
> [Other Rust Installation Methods][otherinstall] para ver outras opções.

Os passos a seguir instalam a versão estável mais recente do compilador Rust.
As garantias de estabilidade do Rust asseguram que todos os exemplos do livro
que compilam continuarão compilando em versões mais novas do Rust. A saída pode
variar um pouco entre versões, porque Rust frequentemente melhora mensagens de
erro e avisos. Em outras palavras, qualquer versão estável mais nova que você
instalar seguindo estes passos deve funcionar como esperado com o conteúdo
deste livro.

> ### Notação de Linha de Comando
>
> Neste capítulo e ao longo do livro, mostraremos alguns comandos usados no
> terminal. Linhas que você deve digitar em um terminal sempre começam com
> `$`. Você não precisa digitar o caractere `$`; ele é apenas o prompt de
> comando, mostrado para indicar o início de cada comando. Linhas que não
> começam com `$` normalmente mostram a saída do comando anterior. Além disso,
> exemplos específicos do PowerShell usarão `>` em vez de `$`.

### Instalando o `rustup` no Linux ou no macOS

Se você estiver usando Linux ou macOS, abra um terminal e digite o seguinte
comando:

```console
$ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

O comando baixa um script e inicia a instalação da ferramenta `rustup`, que
instala a versão estável mais recente do Rust. Você pode ser solicitado a
informar sua senha. Se a instalação for bem-sucedida, a seguinte linha
aparecerá:

```text
Rust is installed now. Great!
```

Você também precisará de um _linker_, que é um programa que o Rust usa para
juntar a saída compilada em um único arquivo. É provável que você já tenha um.
Se receber erros de linker, deve instalar um compilador C, que normalmente já
inclui um linker. Um compilador C também é útil porque alguns pacotes comuns do
Rust dependem de código C e precisarão de um compilador desse tipo.

No macOS, você pode obter um compilador C executando:

```console
$ xcode-select --install
```

Usuários de Linux normalmente devem instalar GCC ou Clang, de acordo com a
documentação de sua distribuição. Por exemplo, se você usa Ubuntu, pode
instalar o pacote `build-essential`.

### Instalando o `rustup` no Windows

No Windows, acesse [https://www.rust-lang.org/tools/install][install]<!-- ignore
--> e siga as instruções de instalação do Rust. Em algum momento do processo,
será solicitado que você instale o Visual Studio. Isso fornece um linker e as
bibliotecas nativas necessárias para compilar programas. Se precisar de mais
ajuda nessa etapa, veja
[https://rust-lang.github.io/rustup/installation/windows-msvc.html][msvc]<!--
ignore -->.

O restante deste livro usa comandos que funcionam tanto no _cmd.exe_ quanto no
PowerShell. Se houver diferenças específicas, explicaremos qual usar.

### Solucionando problemas

Para verificar se o Rust foi instalado corretamente, abra um shell e execute a
seguinte linha:

```console
$ rustc --version
```

Você deverá ver o número da versão, o hash do commit e a data do commit da
versão estável mais recente lançada, no seguinte formato:

```text
rustc x.y.z (abcabcabc yyyy-mm-dd)
```

Se você vir essas informações, o Rust foi instalado com sucesso! Se não
aparecerem, verifique se o Rust está na variável de sistema `%PATH%`, assim:

No CMD do Windows, use:

```console
> echo %PATH%
```

No PowerShell, use:

```powershell
> echo $env:Path
```

No Linux e no macOS, use:

```console
$ echo $PATH
```

Se isso estiver correto e o Rust ainda assim não funcionar, há vários lugares
em que você pode conseguir ajuda. Descubra como entrar em contato com outros
rustaceanos (um apelido brincalhão que usamos para nós mesmos) na [página da
comunidade][community].

### Atualizando e desinstalando

Depois que o Rust estiver instalado via `rustup`, atualizar para uma versão
nova é simples. No shell, execute o seguinte script de atualização:

```console
$ rustup update
```

Para desinstalar Rust e `rustup`, execute o seguinte script no shell:

```console
$ rustup self uninstall
```

<!-- Old headings. Do not remove or links may break. -->
<a id="local-documentation"></a>

### Lendo a documentação local

A instalação do Rust também inclui uma cópia local da documentação, para que
você possa lê-la offline. Execute `rustup doc` para abrir essa documentação no
seu navegador.

Sempre que um tipo ou função for fornecido pela biblioteca padrão e você não
tiver certeza do que faz ou como usar, recorra à documentação da interface de
programação de aplicações (API)!

<!-- Old headings. Do not remove or links may break. -->
<a id="text-editors-and-integrated-development-environments"></a>

### Usando editores de texto e IDEs

Este livro não faz suposições sobre quais ferramentas você usa para escrever
código Rust. Praticamente qualquer editor de texto dá conta do recado! Ainda
assim, muitos editores de texto e ambientes de desenvolvimento integrados
(IDEs) têm suporte embutido para Rust. Você sempre pode encontrar uma lista
razoavelmente atualizada de vários editores e IDEs na [página de
ferramentas][tools] do site do Rust.

### Trabalhando offline com este livro

Em vários exemplos, usaremos pacotes Rust além da biblioteca padrão. Para
acompanhar esses exemplos, você precisará ter conexão com a internet ou já ter
baixado essas dependências com antecedência. Para baixar as dependências antes,
você pode executar os comandos a seguir. Mais tarde explicaremos em detalhes o
que é `cargo` e o que cada um desses comandos faz.

```console
$ cargo new get-dependencies
$ cd get-dependencies
$ cargo add rand@0.8.5 trpl@0.2.0
```

Isso fará cache dos downloads desses pacotes, então você não precisará
baixá-los depois. Depois de executar esse comando, você não precisa manter a
pasta `get-dependencies`. Se tiver executado esse comando, poderá usar a flag
`--offline` com todos os comandos `cargo` no restante do livro para utilizar
essas versões em cache em vez de tentar acessar a rede.

[otherinstall]: https://forge.rust-lang.org/infra/other-installation-methods.html
[install]: https://www.rust-lang.org/tools/install
[msvc]: https://rust-lang.github.io/rustup/installation/windows-msvc.html
[community]: https://www.rust-lang.org/community
[tools]: https://www.rust-lang.org/tools

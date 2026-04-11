<!-- Old headings. Do not remove or links may break. -->
<a id="developing-the-librarys-functionality-with-test-driven-development"></a>

## Adicionando funcionalidade com desenvolvimento orientado a testes

Agora que temos a lógica de pesquisa em _src/lib.rs_ separada do `main`
função, é muito mais fácil escrever testes para a funcionalidade principal do nosso
código. Podemos chamar funções diretamente com vários argumentos e verificar o retorno
valores sem ter que chamar nosso binário na linha de comando.

Nesta seção, adicionaremos a lógica de pesquisa ao programa `minigrep` usando
o processo de desenvolvimento orientado a testes (TDD) com as seguintes etapas:

1. Escreva um teste que falhe e execute-o para ter certeza de que ele falha pelo motivo que você
esperar.
2. Escreva ou modifique apenas o código suficiente para fazer o novo teste passar.
3. Refatore o código que você acabou de adicionar ou alterar e certifique-se de que os testes continuem
para passar.
4. Repita a partir do passo 1!

Embora seja apenas uma das muitas maneiras de escrever software, o TDD pode ajudar a impulsionar o código
projeto. Escrevendo o teste antes de escrever o código que faz o teste passar
ajuda a manter uma alta cobertura de teste durante todo o processo.

Testaremos a implementação da funcionalidade que realmente funcionará
a busca pela string de consulta no conteúdo do arquivo e produzir uma lista de
linhas que correspondem à consulta. Adicionaremos essa funcionalidade em uma função chamada
`search`.

### Escrevendo um teste com falha

Em _src/lib.rs_, adicionaremos um módulo `tests` com uma função de teste, como fizemos em
[Capítulo 11][ch11-anatomy]<!-- ignore -->. A função de teste especifica o
comportamento que queremos que a função `search` tenha: Será necessária uma consulta e o
texto a ser pesquisado e retornará apenas as linhas do texto que contêm
a consulta. A Listagem 12-15 mostra esse teste.

<Listing number="12-15" file-name="src/lib.rs" caption="Creating a failing test for the `search` function for the functionality we wish we had">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-15/src/lib.rs:here}}
```

</Listing>

Este teste procura a string `"duct"`. O texto que estamos pesquisando é três
linhas, das quais apenas uma contém `"duct"` (observe que a barra invertida após o
abrir aspas duplas diz a Rust para não colocar um caractere de nova linha no início
do conteúdo desta string literal). Afirmamos que o valor retornado de
a função `search` contém apenas a linha que esperamos.

Se executarmos este teste, ele irá falhar porque a macro `unimplemented!`
entra em pânico com a mensagem “não implementado”. De acordo com os princípios do TDD,
daremos um pequeno passo para adicionar código suficiente para que o teste não entre em pânico
ao chamar a função definindo a função `search` para sempre retornar um
vetor vazio, conforme mostrado na Listagem 12-16. Então, o teste deve compilar e falhar
porque um vetor vazio não corresponde a um vetor contendo a linha `"safe,
rápido, produtivo."`.

<Listing number="12-16" file-name="src/lib.rs" caption="Defining just enough of the `search` function so that calling it won’t panic">

```rust,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-16/src/lib.rs:here}}
```

</Listing>

Agora vamos discutir por que precisamos definir um tempo de vida explícito `'a` no
assinatura de `search` e use esse tempo de vida com o argumento `contents` e
o valor de retorno. Lembre-se no [Capítulo 10][ch10-lifetimes]<!-- ignore --> que
os parâmetros de tempo de vida especificam qual tempo de vida do argumento está conectado ao
vida útil do valor de retorno. Neste caso, indicamos que o valor devolvido
o vetor deve conter fatias de string que fazem referência a fatias do argumento
`contents` (em vez do argumento `query`).

Em outras palavras, dizemos ao Rust que os dados retornados pela função `search`
viverá enquanto os dados passados ​​para a função `search` no
`contents` argumento. Isto é importante! Os dados referenciados _por_ uma fatia precisam
ser válido para que a referência seja válida; se o compilador assumir que estamos fazendo
fatias de string de `query` em vez de `contents`, ele fará sua verificação de segurança
incorretamente.

Se esquecermos as anotações de tempo de vida e tentarmos compilar esta função, iremos
receba este erro:

```console
{{#include ../listings/ch12-an-io-project/output-only-02-missing-lifetimes/output.txt}}
```

Rust não consegue saber qual dos dois parâmetros precisamos para a saída, então precisamos
para contá-lo explicitamente. Observe que o texto de ajuda sugere especificar o mesmo
parâmetro de vida útil para todos os parâmetros e o tipo de saída, que é
incorreto! Porque `contents` é o parâmetro que contém todo o nosso texto
e queremos retornar as partes desse texto que correspondem, sabemos que `contents` é
o único parâmetro que deve ser conectado ao valor de retorno usando o
sintaxe vitalícia.

Outras linguagens de programação não exigem que você conecte argumentos para retornar
valores na assinatura, mas essa prática ficará mais fácil com o tempo. Você pode
deseja comparar este exemplo com os exemplos no [“Validando Referências
com vidas”][validating-references-with-lifetimes]<!-- ignore --> seção
no Capítulo 10.

### Escrevendo código para passar no teste

Atualmente, nosso teste está falhando porque sempre retornamos um vetor vazio. Para consertar
isso e implementar `search`, nosso programa precisa seguir estas etapas:

1. Itere em cada linha do conteúdo.
2. Verifique se a linha contém nossa string de consulta.
3. Em caso afirmativo, adicione-o à lista de valores que estamos retornando.
4. Se não, não faça nada.
5. Retorne a lista de resultados correspondentes.

Vamos trabalhar em cada etapa, começando pela iteração das linhas.

#### Iterando através de linhas com o método `lines`

Rust tem um método útil para lidar com a iteração de strings linha por linha,
convenientemente chamado `lines`, que funciona conforme mostrado na Listagem 12-17. Observe que
isso ainda não será compilado.

<Listing number="12-17" file-name="src/lib.rs" caption="Iterating through each line in `contents`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-17/src/lib.rs:here}}
```

</Listing>

O método `lines` retorna um iterador. Falaremos sobre iteradores em profundidade em
[Capítulo 13][ch13-iterators]<!-- ignore -->. Mas lembre-se que você viu desta forma
de usar um iterador na [Listagem 3-5][ch3-iter]<!-- ignore -->, onde usamos um
`for` loop com um iterador para executar algum código em cada item de uma coleção.

#### Pesquisando cada linha para a consulta

A seguir, verificaremos se a linha atual contém nossa string de consulta.
Felizmente, strings têm um método útil chamado `contains` que faz isso para
nós! Adicione uma chamada ao método `contains` na função `search`, conforme mostrado em
Listagem 12-18. Observe que isso ainda não será compilado.

<Listing number="12-18" file-name="src/lib.rs" caption="Adding functionality to see whether the line contains the string in `query`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-18/src/lib.rs:here}}
```

</Listing>

No momento, estamos construindo funcionalidades. Para fazer o código compilar, nós
precisamos retornar um valor do corpo como indicamos que faríamos na função
assinatura.

#### Armazenando linhas correspondentes

Para finalizar esta função, precisamos de uma forma de armazenar as linhas correspondentes que queremos
para retornar. Para isso, podemos fazer um vetor mutável antes do loop `for` e
chame o método `push` para armazenar um `line` no vetor. Após o ciclo `for`,
retornamos o vetor, conforme mostrado na Listagem 12-19.

<Listing number="12-19" file-name="src/lib.rs" caption="Storing the lines that match so that we can return them">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-19/src/lib.rs:here}}
```

</Listing>

Agora a função `search` deve retornar apenas as linhas que contêm `query`,
e nosso teste deve passar. Vamos fazer o teste:

```console
{{#include ../listings/ch12-an-io-project/listing-12-19/output.txt}}
```

Nosso teste passou, então sabemos que funciona!

Neste ponto, poderíamos considerar oportunidades para refatorar o
implementação da função de pesquisa enquanto mantém os testes passando para
manter a mesma funcionalidade. O código na função de pesquisa não é tão ruim,
mas não aproveita alguns recursos úteis dos iteradores. Bem
retorne a este exemplo no [Capítulo 13][ch13-iterators]<!-- ignore -->, onde
exploraremos os iteradores em detalhes e veremos como melhorá-los.

Agora todo o programa deve funcionar! Vamos experimentar, primeiro com uma palavra que
deve retornar exatamente uma linha do poema de Emily Dickinson: _frog_.

```console
{{#include ../listings/ch12-an-io-project/no-listing-02-using-search-in-run/output.txt}}
```

Legal! Agora vamos tentar uma palavra que corresponda a várias linhas, como _body_:

```console
{{#include ../listings/ch12-an-io-project/output-only-03-multiple-matches/output.txt}}
```

E, finalmente, vamos ter certeza de que não teremos nenhuma linha quando procurarmos por um
palavra que não está em nenhum lugar do poema, como _monomorfização_:

```console
{{#include ../listings/ch12-an-io-project/output-only-04-no-matches/output.txt}}
```

Excelente! Construímos nossa própria versão mini de uma ferramenta clássica e aprendemos muito
sobre como estruturar aplicativos. Também aprendemos um pouco sobre entrada de arquivo
e saída, tempos de vida, testes e análise de linha de comando.

Para completar este projeto, demonstraremos brevemente como trabalhar com
variáveis ​​de ambiente e como imprimir com erro padrão, sendo que ambos são
útil quando você está escrevendo programas de linha de comando.

[validating-references-with-lifetimes]: ch10-03-lifetime-syntax.html#validating-references-with-lifetimes
[ch11-anatomy]: ch11-01-writing-tests.html#the-anatomy-of-a-test-function
[ch10-lifetimes]: ch10-03-lifetime-syntax.html
[ch3-iter]: ch03-05-control-flow.html#looping-through-a-collection-with-for
[ch13-iterators]: ch13-02-iterators.html

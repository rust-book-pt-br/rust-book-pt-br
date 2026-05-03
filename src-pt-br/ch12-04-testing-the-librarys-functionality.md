<!-- Old headings. Do not remove or links may break. -->
<a id="developing-the-librarys-functionality-with-test-driven-development"></a>

## Adicionando Funcionalidade com Desenvolvimento Orientado a Testes

Agora que temos a lógica de busca em _src/lib.rs_ separada da função `main`,
fica muito mais fácil escrever testes para a funcionalidade central do nosso
código. Podemos chamar funções diretamente com vários argumentos e verificar os
valores retornados sem precisar invocar o binário pela linha de comando.

Nesta seção, vamos adicionar a lógica de busca ao programa `minigrep` usando o
processo de desenvolvimento orientado a testes (TDD) com os seguintes passos:

1. Escrever um teste que falha e executá-lo para confirmar que ele falha pelo
   motivo esperado.
2. Escrever ou modificar apenas o código suficiente para fazer o novo teste
   passar.
3. Refatorar o código que você acabou de adicionar ou alterar e garantir que os
   testes continuem passando.
4. Repetir a partir do passo 1.

Embora seja apenas uma entre muitas formas de escrever software, TDD pode
ajudar a orientar o design do código. Escrever o teste antes do código que o
faz passar ajuda a manter uma boa cobertura de testes ao longo de todo o
processo.

Vamos orientar por testes a implementação da funcionalidade que de fato fará a
busca pela string de consulta no conteúdo do arquivo e produzirá uma lista das
linhas que correspondem à consulta. Adicionaremos essa funcionalidade em uma
função chamada `search`.

### Escrevendo um Teste que Falha

Em _src/lib.rs_, adicionaremos um módulo `tests` com uma função de teste, como
fizemos no [Capítulo 11][ch11-anatomy]<!-- ignore -->. A função de teste
especifica o comportamento que queremos para `search`: ela receberá uma
consulta e o texto onde será feita a busca, e retornará apenas as linhas do
texto que contêm a consulta. A Listagem 12-15 mostra esse teste.

<Listing number="12-15" file-name="src/lib.rs" caption="Criando um teste com falha para a função `search` referente à funcionalidade que queremos ter">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-15/src/lib.rs:here}}
```

</Listing>

Esse teste procura pela string `"duct"`. O texto em que estamos pesquisando tem
três linhas, e apenas uma delas contém `"duct"`; observe que a barra invertida
após a aspa dupla de abertura instrui Rust a não colocar um caractere de nova
linha no começo do conteúdo dessa string literal. Verificamos que o valor
retornado pela função `search` contém apenas a linha que esperamos.

Se executarmos esse teste agora, ele falhará porque a macro `unimplemented!`
entra em pânico com a mensagem “not implemented”. De acordo com os princípios
de TDD, vamos dar um pequeno passo: adicionar apenas o código necessário para
que o teste deixe de entrar em pânico ao chamar a função, definindo `search`
para sempre retornar um vetor vazio, como mostrado na Listagem 12-16. Então o
teste deverá compilar e falhar, porque um vetor vazio não corresponde a um
vetor contendo a linha `"safe, fast, productive."`.

<Listing number="12-16" file-name="src/lib.rs" caption="Definindo o mínimo da função `search` para que chamá-la não provoque pânico">

```rust,noplayground
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-16/src/lib.rs:here}}
```

</Listing>

Agora vamos discutir por que precisamos definir um lifetime explícito `'a` na
assinatura de `search` e usar esse lifetime com o argumento `contents` e com o
valor de retorno. Lembre-se do [Capítulo 10][ch10-lifetimes]<!-- ignore -->:
os parâmetros de lifetime especificam qual lifetime de argumento está ligado ao
lifetime do valor retornado. Neste caso, indicamos que o vetor retornado deve
conter string slices que referenciam slices do argumento `contents`, e não do
argumento `query`.

Em outras palavras, estamos dizendo ao Rust que os dados retornados pela função
`search` viverão tanto quanto os dados passados à função pelo argumento
`contents`. Isso é importante! Os dados referenciados _por_ um slice precisam
ser válidos para que a referência também seja válida. Se o compilador assumir
que estamos criando string slices de `query` em vez de `contents`, ele fará a
verificação de segurança incorretamente.

Se esquecermos as anotações de lifetime e tentarmos compilar essa função,
receberemos o seguinte erro:

```console
{{#include ../listings/ch12-an-io-project/output-only-02-missing-lifetimes/output.txt}}
```

Rust não consegue saber de qual dos dois parâmetros precisamos para a saída,
então precisamos informar isso explicitamente. Observe que o texto de ajuda
sugere especificar o mesmo parâmetro de lifetime para todos os parâmetros e
para o tipo de saída, mas isso está incorreto! Como `contents` é o parâmetro que
contém todo o texto e queremos retornar partes desse texto que correspondem à
busca, sabemos que `contents` é o único parâmetro que deve ser ligado ao valor
de retorno usando a sintaxe de lifetimes.

Outras linguagens de programação não exigem que você conecte argumentos e
valores de retorno na assinatura, mas essa prática fica mais natural com o
tempo. Talvez você queira comparar este exemplo com os exemplos da seção
[“Validando Referências com Lifetimes”][validating-references-with-lifetimes]<!--
ignore --> do Capítulo 10.

### Escrevendo Código para Fazer o Teste Passar

No momento, nosso teste falha porque sempre retornamos um vetor vazio. Para
corrigir isso e implementar `search`, nosso programa precisa seguir estes
passos:

1. Iterar por cada linha do conteúdo.
2. Verificar se a linha contém a string de busca.
3. Se contiver, adicioná-la à lista de valores que vamos retornar.
4. Se não contiver, não fazer nada.
5. Retornar a lista de resultados correspondentes.

Vamos trabalhar em cada um desses passos, começando pela iteração sobre as
linhas.

#### Iterando pelas Linhas com o Método `lines`

Rust tem um método útil para iterar sobre strings linha a linha, chamado
apropriadamente de `lines`, que funciona como mostrado na Listagem 12-17.
Observe que isso ainda não compilará.

<Listing number="12-17" file-name="src/lib.rs" caption="Iterando por cada linha em `contents`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-17/src/lib.rs:here}}
```

</Listing>

O método `lines` retorna um iterador. Falaremos sobre iteradores em
profundidade no [Capítulo 13][ch13-iterators]<!-- ignore -->. Mas lembre-se de
que você já viu esse modo de usar iteradores na [Listagem 3-5][ch3-iter]<!--
ignore -->, em que usamos um laço `for` com um iterador para executar
código sobre cada item de uma coleção.

#### Procurando a Consulta em Cada Linha

Em seguida, vamos verificar se a linha atual contém a nossa string de busca.
Felizmente, strings têm um método útil chamado `contains` que faz isso por
nós. Adicione uma chamada ao método `contains` na função `search`, como mostra
a Listagem 12-18. Observe que isso ainda não vai compilar.

<Listing number="12-18" file-name="src/lib.rs" caption="Adicionando funcionalidade para verificar se a linha contém a string em `query`">

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-18/src/lib.rs:here}}
```

</Listing>

Neste momento, estamos montando a funcionalidade por partes. Para o código
compilar, precisamos retornar um valor do corpo da função, como indicamos na
assinatura.

#### Armazenando as Linhas Correspondentes

Para concluir essa função, precisamos de uma maneira de armazenar as linhas
correspondentes que queremos retornar. Para isso, podemos criar um vetor
mutável antes do laço `for` e chamar o método `push` para armazenar cada
`line` no vetor. Depois do laço `for`, retornamos o vetor, como mostra a
Listagem 12-19.

<Listing number="12-19" file-name="src/lib.rs" caption="Armazenando as linhas correspondentes para que possamos retorná-las">

```rust,ignore
{{#rustdoc_include ../listings/ch12-an-io-project/listing-12-19/src/lib.rs:here}}
```

</Listing>

Agora a função `search` deve retornar apenas as linhas que contêm `query`, e
nosso teste deve passar. Vamos executá-lo:

```console
{{#include ../listings/ch12-an-io-project/listing-12-19/output.txt}}
```

Nosso teste passou, então sabemos que funciona!

Neste ponto, poderíamos pensar em oportunidades de refatorar a implementação
da função de busca mantendo os testes passando e preservando a mesma
funcionalidade. O código dessa função não está ruim, mas ainda não aproveita
alguns recursos úteis dos iteradores. Voltaremos a este exemplo no
[Capítulo 13][ch13-iterators]<!-- ignore -->, onde exploraremos iteradores em
detalhe e veremos como melhorá-lo.

Agora o programa inteiro já deve funcionar! Vamos testá-lo primeiro com uma
palavra que deve retornar exatamente uma linha do poema de Emily Dickinson:
_frog_.

```console
{{#include ../listings/ch12-an-io-project/no-listing-02-using-search-in-run/output.txt}}
```

Legal! Agora vamos tentar uma palavra que corresponda a várias linhas, como
_body_:

```console
{{#include ../listings/ch12-an-io-project/output-only-03-multiple-matches/output.txt}}
```

E, por fim, vamos garantir que não obteremos nenhuma linha quando buscarmos uma
palavra que não aparece em lugar nenhum do poema, como
_monomorphization_:

```console
{{#include ../listings/ch12-an-io-project/output-only-04-no-matches/output.txt}}
```

Excelente! Construímos nossa própria versão mini de uma ferramenta clássica e
aprendemos bastante sobre como estruturar aplicações. Também aprendemos um
pouco sobre entrada e saída de arquivos, lifetimes, testes e análise de linha
de comando.

Para completar este projeto, vamos demonstrar brevemente como trabalhar com
variáveis de ambiente e como imprimir em `stderr`, ambos muito úteis quando
você escreve programas de linha de comando.

[validating-references-with-lifetimes]: ch10-03-lifetime-syntax.html#validating-references-with-lifetimes
[ch11-anatomy]: ch11-01-writing-tests.html#the-anatomy-of-a-test-function
[ch10-lifetimes]: ch10-03-lifetime-syntax.html
[ch3-iter]: ch03-05-control-flow.html#looping-through-a-collection-with-for
[ch13-iterators]: ch13-02-iterators.html

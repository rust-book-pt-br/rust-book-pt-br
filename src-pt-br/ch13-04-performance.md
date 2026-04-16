<!-- Old headings. Do not remove or links may break. -->

<a id="comparing-performance-loops-vs-iterators"></a>

## Desempenho em Laços versus Iteradores

Para decidir se deve usar laços ou iteradores, você precisa saber qual
implementação é mais rápida: a versão da função `search` com um laço `for`
explícito ou a versão com iteradores.

Executamos um benchmark carregando todo o conteúdo de _The Adventures of
Sherlock Holmes_, de Sir Arthur Conan Doyle, em uma `String` e procurando a
palavra _the_ nesse conteúdo. Aqui estão os resultados do benchmark para a
versão de `search` que usa o laço `for` e para a versão que usa iteradores:

```text
test bench_search_for  ... bench:  19,620,300 ns/iter (+/- 915,700)
test bench_search_iter ... bench:  19,234,900 ns/iter (+/- 657,200)
```

As duas implementações têm desempenho semelhante! Não vamos explicar o código
do benchmark aqui, porque o objetivo não é provar que as duas versões são
equivalentes, mas ter uma noção geral de como essas duas implementações se
comparam em termos de desempenho.

Para um benchmark mais abrangente, você deveria testar vários textos, de vários
tamanhos, como `contents`, diferentes palavras e palavras de comprimentos
variados como `query`, além de muitos outros tipos de variação. O ponto é o
seguinte: iteradores, embora sejam uma abstração de alto nível, são compilados
para algo muito próximo do mesmo código que você escreveria manualmente em um
nível mais baixo. Iteradores são uma das _abstrações de custo zero_ de Rust,
isto é, usar a abstração não impõe nenhuma sobrecarga adicional em tempo de
execução. Isso é análogo à forma como Bjarne Stroustrup, o projetista e
implementador original de C++, define sobrecarga zero em sua palestra de 2012
na ETAPS, “Foundations of C++”:

> Em geral, as implementações de C++ obedecem ao princípio da sobrecarga zero:
> o que você não usa, você não paga. E mais: o que você usa, você não conseguiria
> codificar manualmente de forma melhor.

Em muitos casos, o código Rust que usa iteradores é compilado para o mesmo
assembly que você escreveria à mão. Otimizações como desenrolamento de laço e
eliminação da checagem de limites em acessos a arrays se aplicam e tornam o
código resultante extremamente eficiente. Agora que você sabe disso, pode usar
iteradores e closures sem medo! Eles fazem o código parecer mais de alto
nível, mas não impõem penalidade de desempenho em tempo de execução.

## Resumo

Closures e iteradores são recursos de Rust inspirados em ideias de linguagens
de programação funcional. Eles contribuem para a capacidade de Rust de
expressar com clareza ideias de alto nível com desempenho de baixo nível. As
implementações de closures e iteradores são feitas de tal forma que o
desempenho em tempo de execução não é afetado. Isso faz parte do objetivo de
Rust de oferecer abstrações de custo zero.

Agora que melhoramos a expressividade do nosso projeto de E/S, vamos dar uma
olhada em mais alguns recursos do `cargo` que nos ajudarão a compartilhar esse
projeto com o mundo.

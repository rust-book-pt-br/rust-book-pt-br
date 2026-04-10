<!-- Old headings. Do not remove or links may break. -->

<a id="comparing-performance-loops-vs-iterators"></a>

## Performance in Loops vs. Iterators

Para determinar se deve usar loops ou iterators, você precisa saber qual
a implementação é mais rápida: a versão da função `search` com um explícito
Loop `for` ou a versão com iterators.

Executamos um benchmark carregando todo o conteúdo de _The Adventures of
Sherlock Holmes_ de Sir Arthur Conan Doyle em um `String` e procurando o
palavra _the_ no conteúdo. Aqui estão os resultados do benchmark sobre o
versão de `search` usando o loop `for` e a versão usando iterators:

```text
test bench_search_for  ... bench:  19,620,300 ns/iter (+/- 915,700)
test bench_search_iter ... bench:  19,234,900 ns/iter (+/- 657,200)
```

As duas implementações têm desempenho semelhante! Não vamos explicar o
código de referência aqui porque o objetivo não é provar que as duas versões
são equivalentes, mas para ter uma noção geral de como essas duas implementações
compare em termos de desempenho.

Para uma referência mais abrangente, você deve verificar usando vários textos de
vários tamanhos como o `contents`, palavras diferentes e palavras de comprimentos diferentes
como o ` query`e todos os tipos de outras variações. A questão é esta:
Iteradores, embora sejam uma abstração de alto nível, são compilados aproximadamente até o
mesmo código como se você mesmo tivesse escrito o código de nível inferior. Iteradores são um
das _abstrações de custo zero_ do Rust, com o que queremos dizer que usar a abstração
não impõe nenhuma sobrecarga adicional de tempo de execução. Isso é análogo a como Bjarne
Stroustrup, o designer e implementador original de C++, define
sobrecarga zero em sua apresentação principal da ETAPS de 2012 “Foundations of C++”:

> Em geral, as implementações C++ obedecem ao princípio de sobrecarga zero: o que você
> não use, você não paga. E mais: o que você usa, você não poderia entregar
> codifique melhor.

Em muitos casos, o código Rust usando iterators é compilado no mesmo assembly que você
escreva à mão. Otimizações como desenrolamento de loop e eliminação de limites
a verificação do acesso ao array se aplica e torna o código resultante extremamente eficiente.
Agora que você sabe disso, pode usar iterators e closures sem medo! Eles
faça o código parecer de nível superior, mas não imponha um desempenho de tempo de execução
penalidade por fazer isso.

## Resumo

Closures e iterators são recursos Rust inspirados na programação funcional
ideias de linguagem. Eles contribuem para a capacidade do Rust de expressar claramente
ideias de alto nível com desempenho de baixo nível. As implementações de closures e
iterators são tais que o desempenho do tempo de execução não é afetado. Isso faz parte
O objetivo do Rust é se esforçar para fornecer abstrações de custo zero.

Agora que melhoramos a expressividade do nosso projeto de I/O, vamos dar uma olhada
mais alguns recursos do `cargo` que nos ajudarão a compartilhar o projeto com o
mundo.

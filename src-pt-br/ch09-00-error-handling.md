# Tratamento de Erros

Erros são um fato da vida no software, então Rust oferece vários recursos para
lidar com situações em que algo dá errado. Em muitos casos, Rust exige que
você reconheça a possibilidade de erro e tome alguma ação antes que seu código
compile. Esse requisito torna o programa mais robusto, garantindo que você
descubra e trate os erros adequadamente antes de colocá-lo em produção!

Rust agrupa os erros em duas grandes categorias: erros recuperáveis e
irrecuperáveis. Para um _erro recuperável_, como _arquivo não encontrado_, o
mais provável é que queiramos apenas informar o problema à pessoa usuária e
tentar novamente a operação. Já _erros irrecuperáveis_ são sempre sintomas de
bugs, como tentar acessar uma posição além do fim de um array, então queremos
interromper imediatamente o programa.

A maioria das linguagens não distingue entre esses dois tipos de erro e trata
ambos da mesma forma, usando mecanismos como exceções. Rust não tem exceções.
Em vez disso, ele tem o tipo `Result<T, E>` para erros recuperáveis e a macro
`panic!`, que interrompe a execução quando o programa encontra um erro
irrecuperável. Neste capítulo, veremos primeiro chamadas a `panic!` e depois
falaremos sobre retornar valores `Result<T, E>`. Além disso, exploraremos
critérios para decidir se é melhor tentar se recuperar de um erro ou encerrar a
execução.

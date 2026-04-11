# Tratamento de Erros

O compromisso do Rust com a segurança se estende ao tratamento de erros. Erros
são um fato da vida em software, portanto Rust possui vários *recursos*
para lidar com situações em que algo dá errado. Em vários casos, Rust requer que
você reconheça a possibilidade de um erro acontecer e aja preventivamente antes
que seu código compile. Esse requisito torna seu programa mais robusto ao assegurar
que você irá descobrir erros e lidar com eles apropriadamente antes de mandar seu
código para produção!

Rust agrupa erros em duas categorias principais: *recuperáveis* e *irrecuperáveis*.
Erros recuperáveis são situações em que é razoável reportar o problema ao usuário
e tentar a operação novamente, como um erro de arquivo não encontrado. Erros 
irrecuperáveis são sempre sintomas de bugs, como tentar acessar uma localização
além do fim de um *array*.

A maioria das linguagens não distingue esses dois tipos de erros e lida
com ambos da mesma maneira usando mecanismos como exceções. Rust não tem
exceções. Em vez disso, ele tem o valor `Result<T, E>` para erros recuperáveis
e a macro `panic!` que para a execução ao encontrar um erro irrecuperável. Esse
capítulo cobre primeiro como chamar `panic!` e depois fala sobre retornar valores
`Result<T, E>`. Além disso, vamos explorar o que levar em consideração
ao decidir entre tentar se recuperar de um erro ou parar a execução.

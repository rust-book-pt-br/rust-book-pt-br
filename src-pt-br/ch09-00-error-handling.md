# Tratamento de erros

Erros são uma realidade no software, então Rust tem vários recursos para
lidar com situações em que algo dá errado. Em muitos casos, Rust requer
você reconheça a possibilidade de um erro e tome alguma ação antes de seu
o código será compilado. Este requisito torna seu programa mais robusto, garantindo
que você descobrirá erros e os tratará adequadamente antes de implantar seu
código para produção!

Rust agrupa os erros em duas categorias principais: recuperáveis ​​e irrecuperáveis
erros. Para um _erro recuperável_, como um erro de _arquivo não encontrado_, nós mais
provavelmente deseja apenas relatar o problema ao usuário e tentar novamente a operação.
_Erros irrecuperáveis_ são sempre sintomas de bugs, como tentar acessar um
localização além do final de uma matriz e, portanto, queremos interromper imediatamente o
programa.

A maioria das linguagens não distingue entre esses dois tipos de erros e lida com
ambos da mesma forma, utilizando mecanismos como exceções. Ferrugem não tem
exceções. Em vez disso, tem o tipo `Result<T, E>` para erros recuperáveis ​​e
a macro `panic!` que interrompe a execução quando o programa encontra um
erro irrecuperável. Este capítulo cobre ligar para `panic!` primeiro e depois falar
sobre como retornar valores `Result<T, E>`. Além disso, exploraremos
considerações ao decidir se deve tentar se recuperar de um erro ou parar
execução.

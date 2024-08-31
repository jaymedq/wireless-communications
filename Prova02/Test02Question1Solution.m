%{ 
Prova 02
CSF0084 - Comunicações Sem Fio
Jayme de Queiroz
CPGEI , UTFPR 
%}

%% Questão 1
%{
Quais as formas mais eficazes de melhorar o desempenho da comunicação sem 
fio nos canais de desvanecimento rápido e desvanecimento lento, 
respectivamente? Cite as principais técnicas, apresentando vantagens 
e desvantagens.
%}
%{
Para canais de desvanecimento rápido, as técnicas mais eficazes incluem 
codigos corretores de erro, modulação multiportadora e Diversidade espacial.

Codificação de canal melhora a resiliência ao desvanecimento, permitindo a 
correção de erros, mas pode aumentar a complexidade e a latência.

Modulação multiportadora (como OFDM) distribui os dados em várias 
subportadoras, reduzindo o impacto do desvanecimento de frequência 
seletiva, embora exija maior largura de banda e sincronismo preciso.

MIMO explora a diversidade espacial para mitigar o desvanecimento ao 
combinar sinais de várias antenas, aumentando a capacidade e a 
confiabilidade, mas também introduz complexidade adicional e processamento 
intensivo, especialmente em cenários dinâmicos.

Para canais de desvanecimento lento, diversidade espacial(MRC) e 
entrelaçamento são técnicas essenciais. 

Diversidade espacial (MRC) usa múltiplas antenas para explorar diferentes 
caminhos de propagação, aumentando a taxa de dados e a confiabilidade, 
diminuindo a probabilidade de outage mas requer hardware mais complexo 
e maior processamento. 

O entrelaçamento (interleaving) melhora a comunicação no canal lento a 
partir do  entrelaçador em tempo de coerência organiza os dados de forma 
a mitigar os efeitos de erros correlacionados ao longo do tempo, 
aproveitando a estabilidade relativamente maior do canal para melhorar a 
correção de erros. Ao simular um canal rápido, o entrelaçamento distribui 
os bits de dados de forma que imita as condições variáveis do canal 
rápido, permitindo que técnicas de correção de erros sejam utilizados. 
No entanto, essa técnica também tem desvantagens: pode introduzir um 
atraso adicional na comunicação e adicionar complexidade ao sistema, 
exigindo mais processamento e hardware.
%}
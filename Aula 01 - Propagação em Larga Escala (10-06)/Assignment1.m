%{ 
Aula 01 - Propagação em Larga Escala
CSF0084 - Comunicações Sem Fio
Jayme de Queiroz
CPGEI , UTFPR 
%}

%% Questão 1
%{
Considere um sistema de comunicações sem fio operando a 900 MHz, com 
células de 10 m de raio, e antenas com ganho unitário, de acordo com o 
ilustrado na figura abaixo.

Considerando o modelo de propagação do Espaço-Livre, qual a potência de 
transmissão necessária no ponto de acesso (em dB)  tal que a potência 
mínima recebida por um terminal seja de 10μW?
%}
c = 3e8;
fc1 = 900e6;
lambda1 = c/fc1;
Gt1 = 1;
Gr1 = 1;
Pr1 = 10e-6;
d1 = 10;

%Pr = Pt*Gt*Gr*(lambda^2)/(4*pi*d)^2;
Pt1 = Pr1 / (Gt1*Gr1*(lambda1^2)/(4*pi*d1)^2);
PtdB1 = 10*log10(Pt1)

%% Questão 2
%{
No mesmo cenário anterior, qual a potência de transmissão necessária 
(em dB) se a portadora for de 5 GHz?
%}
fc2 = 5e9;
lambda2 = c/fc2;
Gt2 = 1;
Gr2 = 1;
Pr2 = 10e-6;
d2 = 10;

%Pr = Pt*Gt*Gr*(lambda^2)/(4*pi*d)^2;
Pt2 = Pr2 / (Gt2*Gr2*(lambda2^2)/(4*pi*d2)^2);
PtdB2 = 10*log10(Pt2)

%% Questão 3
%{
Suponha o seguinte conjunto de medidas, em que d0 = 1 m, Pt = 1 mW e 
fc = 900 MHz. 

Distância Pr
(m)       (dBm)
10	      -70
20	      -75
50	      -90
100	      -110
300	      -125

Com base nas medidas acima, obtenha um modelo de perda de percurso 
log-distância, determine e preenche no espaço de respostas abaixo uma 
estimativa para Pr (em dBm) em d = 200 m. Suponha espaço-livre 
para determinar P0.

%}
%Pr = Pt*Gt*Gr*(lambda^2)/(4*pi*d)^2;
d03 = 10;
Pt3 = 1e-3;
Pt3dBm = 10*log10(Pt3)+30
fc3 = 900e6;
lambda3 = c/fc3;
d3 = [10,20,30,40,50,70,80,90,100];
Pr_dBm_3 = [-43,-59,-65,-72,-77,-80,-82,-85,-89];

Pl_D0_dB_3 = -43;

%{
F(n) = (Mmedido(di) − Mmodelo(di))^2
PL(d0) =  31,54dB
Mmodelo(di) = −PL(d0) − 10n log10(di)

d3 = [10,20,50,100,300];
Pr_dBm_3 = [-70,-75,-90,-110,-125];

f = (-Pl_D0_dB_3 - 10*n*log10(d3.))^2
%}
% Definindo a variável simbólica n
syms n;
f = 0; % Inicializando a função de erro quadrático médio

% Somando o erro quadrático para todas as medições
for i = 1:length(d3)
    Mmodelo = -Pl_D0_dB_3 - 10*n*log10(d3(i));
    f = f + (Pr_dBm_3(i) - Mmodelo)^2;
end

f;

% Derivada da função de erro quadrático médio em relação a n
df = diff(f, n)

% Solucionando a derivada para encontrar o valor de n que minimiza o erro
n_opt = 4.3;

% Calculando a função modelo usando o valor ótimo de n
n_opt = double(n_opt) % Convertendo para valor numérico
syms d Pr_dBm_model(d);
Pr_dBm_model(d) = Pt3dBm-Pl_D0_dB_3 - 10 * n_opt * log10(d/d03);
Pr_dB_200m = Pr_dBm_model(200)

%% Questão 4
%{
Trace uma curva (em escala log-log) para o modelo obtido na questão 
anterior e anexe o resultado (em formato PDF ou PNG) abaixo. 
%}
d_plot = logspace(0, 3, 100); % Distâncias de 1 a 1000 metros
Pr_dBm_plot = Pr_dBm_model(d_plot);
% Plotando a curva
figure;
semilogx(d_plot, Pr_dBm_plot, 'b-', 'LineWidth', 2);
hold on;
semilogx(d3, Pr_dBm_3, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlabel('Distância (m)');
ylabel('Pr (dBm)');
title('Modelo de Perda de Percurso Log-Distância');
legend('Modelo', 'Medições', 'Location', 'Best');
grid on;
hold off;

% Salvando a figura em formato PNG
saveas(gcf, 'modelo_perda_percurso_log_distancia.png');

% Exibindo o valor de n
fprintf('O valor ótimo de n é: %.3f\n', n_opt);
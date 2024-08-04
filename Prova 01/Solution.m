%% Questão 1
%{
Analisando o grafico podemos concluir que o expoente de perda de propagação
N é maior que 4 devido a queda de mais de 40dB por decada.
(-43dBm em d = 10 e -86dBm em d = 100).
%}
clear;
disp('Questão 1');
disp(['Analisando o grafico podemos concluir que o expoente de perda de ' 'propagação N é maior que 4 devido a queda de mais de 40dB por decada.' '(-43dBm em d = 10 e -86dBm em d = 100)']);

%% Informação
%{
Para cada um dos cenários das três questões a seguir, classifique o desvanecimento quando à sua seletividade temporal (lento ou rápido) e seletividade em frequência (plano ou seletivo em frequência).
Considere στ=2μs e usuários móveis sujeitos a um espalhamento Doppler
BD=200 Hz.
%}

%% Questões 2, 3 e 4
clear;
disp('Questões 2, 3 e 4');
sigma = 2e-6;
BD = 200;
Rb = [500e3 5e3 10];
M = 2; % N simbolos, para binaria M = 2.
Nb = log2(M);
Rs = Rb./Nb;
Bs = Rs./2;
Ts = 1./Rs;
fm = BD;
Tc = 1/fm;
Bc = 1/(5*sigma);

for i = 1:length(Rb)
    fprintf('O desvanescimento para Rb = %d é ', Rb(i))
    if(Ts(i)>Tc)
        fprintf('Rapido ');
    else
        fprintf('Lento ');
    end
    fprintf('Em tempo e ');
    if(Bs(i)>Bc)
        fprintf('Seletivo ');
    else
        fprintf('Plano ');
    end
    fprintf('Em frequência\n');
end

%% Questões 5 e 6
disp('Questões 5 e 6');
%{
A capacidade com outage se aplica a canais de desvanecimento lento, em que 
o tempo de coerência do canal é muito maior que o tempo de símbolo do 
sinal, de forma que a SNR instantânea γ permanece constante durante várias
 transmissões. Nessa situação, supondo que o transmissor não possui 
conhecimento do canal e transmite com uma taxa fixa, há uma probabilidade
da SNR instantânea estar abaixo da mínima SNR necessária para decodificação, 
γmin. Essa probabilidade é chamada de probabilidade de outage, e para o 
caso de desvanecimento Rayleigh é igual a 
Pout = 1-exp(-SnrMin/Snr)
em que SnrMed corresponde à SNR média. Considerando uma banda unitária, a 
capacidade com outage (em bps/Hz), então, é dada por
Co=(1−Pout)log2(1+SnrMin)
Percebe-se que a SNR limiar SnrMin apresenta uma influência não trivial em 
Co: Se por um lado aumentar SnrMin aumenta log2(1+SnrMin), por outro lado o 
aumento de SnrMin aumenta Pout, reduzindo Co. Espera-se, portanto, que a 
capacidade com outage varie com  SnrMin de uma forma semelhante à apresentada
 na figura abaixo, existindo um valor de  γmin que maximiza Co.
Dessa forma, assumindo SnrMed=20 dB e banda unitária, determine qual o 
valor de SnrMin  (em dB) que maximiza a capacidade com outage Co.
%}
% Definindo a SNR média
clear;
SNR_med_dB = 20;
SNR_med = 10^(SNR_med_dB / 10);

SNR_min_values = linspace(0, SNR_med, 1000); % 1000 valores entre 0 e medio
Co_values = zeros(size(SNR_min_values));

%Pout = 1-exp(-SnrMin/SnrMed)
%Co=(1−Pout)*log2(1+SnrMin)
for i = 1:length(SNR_min_values)
    SNR_min = SNR_min_values(i);
    Pout = 1-exp(-SNR_min/SNR_med); % Calculando Pout
    Co_values(i) = (1-Pout)*log2(1+SNR_min); % Calculando Co
end

% Encontrando o valor de SNR_min que maximiza Co
[Co_max, idx_max] = max(Co_values);
SNR_min_opt = SNR_min_values(idx_max);

% Convertendo SNR_min_opt para dB
SNR_min_opt_dB = 10 * log10(SNR_min_opt);

% Exibindo os resultados
fprintf('O valor de SNR_min que maximiza a capacidade com outage é %.4f dB\n', SNR_min_opt_dB);
%{
Para o mesmo cenário do exercício anterior, qual o valor máximo para a 
capacidade com outage Co  (em bps/Hz)?
%}
fprintf('A capacidade com outage máxima é %.4f bps/Hz\n', Co_max);

%% Questão 7
disp('Questão 7');
%{
A probabilidade de erro de bit de uma modulação coerente em canal com 
desvanecimento Rayleigh rápido pode ser aproximada por:
Pb=alfa/2*(-(sqrt((0.5*beta*SNR_Med)/(1+0.5*beta*SNR_Med)) 
~~ alfa/(2*beta*SNR_Med)
em que γ¯=Eb/N0 é a SNR de bit, e α e β variam dependendo da ordem da 
modulação. Assim sendo, considerando um valor de Eb/N0=20 dB e apenas 
modulações do tipo M-PSK coerentes como opção, determine qual o maior 
valor de M que pode ser adotado de forma que Pb≤10−2.
%}
clear;
M = [2 4 8 16 32 64];
EbN0_dB = 20;
EbN0 = 10^(EbN0_dB/10);
alfa = 2./(log2(M));
beta = 2*log2(M).*(sin(pi./M)).^2;
Pb = zeros(size(M));
for i=1:length(M)
    Pb(i) = alfa(i)./(2*beta(i)*EbN0);
    fprintf('M = %d: Pb = %.4f', M(i), Pb(i));
    if(Pb(i)<=1e-2)
        fprintf(' pode ser usado\n')
    else
        fprintf(' não pode ser usado\n')
    end
end

%% Questão 8
disp('Questão 8');
%{
Com o valor de M obtido na questão anterior, continue considerando que 
Eb/N0=20 dB e Pb≤10−2, e obtenha qual a taxa de transmissão de símbolos 
Rs (em kilo símbolos/s), dados:
Modelo de propagação log-distância, com expoente de n igual a 3
Pr(d0)=0 dBm
d0=1 m
Distância entre tx e rx: 100 metros
N0=−164 dB
%}
clear;
M = 16;
EbN0_dB = 20;
EbN0 = 10^(EbN0_dB/10);
Pb = 0.0082;
n = 3;
PrD0_dBm = 0;
PrD0 = 10^((PrD0_dBm-30)/10);
d0 = 1;
d = 100;
N0_dB = -164;
N0 = 10^(N0_dB/10);
%PrN0 = EbN0*Rb
Pr = PrD0*((d0/d)^n);
PrN0 = Pr/N0;
Rb = PrN0/EbN0;
Nb = log2(M);
Rs = Rb/Nb;
fprintf('A taxa de transmissão de símbolos é %.3fks/s\n', Rs/1000);

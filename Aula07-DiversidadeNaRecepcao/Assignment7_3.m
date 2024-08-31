clear all; close all; clc; format compact;

% Definição de parâmetros
Pt = 4e-3;                % Potência de transmissão em W
PtdB = 10*log10(Pt);      % Potência de transmissão em dB
Gtx = 5;                  % Ganho das antenas de transmissão em dB
Grx = 8;                  % Ganho das antenas de recepção em dB
PL = 100;                 % Perda de caminho em dB
Margem = 5;               % Margem em dB
N0_dB = -204;             % Densidade espectral de potência de ruído em dBW/Hz
N0 = 10^(N0_dB/10);       % Convertendo para W/Hz
BER = 0.001;              % BER requerida
B = 5e6;                  % Banda do canal em Hz
alpha = 0.25;             % Fator de excesso de faixa

% Taxa de símbolos
Rs = B / (1 + alpha);

% Calcula a potência recebida em dB
PrdB = PtdB - PL + Gtx + Grx - Margem;

% Calcula a relação sinal-ruído por bit
EsN0 = (10^(PrdB/10) / N0) / Rs;

% Modulações M-PSK
M = [4 8 16 32];

% Numero de antenas
L = [1 2 3]

% Calcula Eb/N0 para cada modulação
EbN0 = EsN0 ./ log2(M);

% Calcula a probabilidade de erro de bit e taxa de bits máxima
for i = 1:length(M)
    % BER para modulação M-PSK em canal AWGN
    Pb(i) = (1 / log2(M(i))) * 2 * qfunc(sqrt(2 * EbN0(i)) * sin(pi / M(i)));
    disp(['Pb (M=' num2str(M(i)) ') = ' num2str(Pb(i))]);

    for j = 1:length(L)
        Pb_mrc = (1 / log2(M(i))) * 2 * qfunc(sqrt(2 * EbN0(i)*L(j)) * sin(pi / M(i)));
        disp(['Pb_mrc (M=' num2str(M(i)) ', L=' num2str(L(j)) ') = ' num2str(Pb_mrc)]);
    end
    
    % Taxa de bits em kbps
    Rb = Rs * log2(M(i)) / 1e3;
    disp(['Rb (M=' num2str(M(i)) ') = ' num2str(Rb) ' kbps']);
end
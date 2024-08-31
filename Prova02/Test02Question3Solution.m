% Definição de parâmetros
clear; clc; clearvars;
% Número de antenas
M_values = [1, 2, 3]; 

% Limiar de SNR em dB
gamma_th_dB = 10; 
% Limiar de SNR linear
gamma_th = 10^(gamma_th_dB / 10); 
SNR_dB = [10, 15, 20];

% SNR em escala linear
SNR = 10.^(SNR_dB / 10); 

% Cálculo da probabilidade de outage para SC e MRC
for idx = 1:length(M_values)
    M = M_values(idx);
    % Probabilidade de outage para Selection Combining (SC)
    Current_Pout_SC = 1;
    for i = 1:M
        Current_Pout_SC = Current_Pout_SC*(1 - exp(-gamma_th / SNR(i)));
    end
    fprintf("Pout para M = %d, %.4f\n",M,Current_Pout_SC);
end

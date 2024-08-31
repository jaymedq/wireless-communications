% Parametros
R = 0.1;
Pcirc = 200;
n = 0.35;
eta = 0.35;
M = 4;
N0 = 1;

% Probabilidades de outage
outage_probs = [10^-2, 10^-3];

% Inicializa vetores para armazenar resultados
P_TX_SC = zeros(1, length(outage_probs));
P_total_SC = zeros(1, length(outage_probs));
P_TX_MRC = zeros(1, length(outage_probs));
P_total_MRC = zeros(1, length(outage_probs));

% Loop para calcular os valores para cada probabilidade de outage
for i = 1:length(outage_probs)
    % Probabilidade de outage SC
    O_SC = outage_probs(i);
    
    % Cálculo de P_TX para SC
    P_TX_SC(i) = -log(1 - O_SC^(1/M)) / (2 * R);
    
    % Potência total SC
    P_total_SC(i) = (1 / eta) * P_TX_SC(i) + Pcirc;
    
    % Probabilidade de outage MRC
    O_MRC = outage_probs(i);
    
    % Cálculo de P_TX para MRC
    a = M;
    b = 2 * R * P_TX_SC(i);
    gamma_approx = (a ^ b) / a;
    O_MRC_calc = gamma_approx / factorial(M - 1);
    
    % Ajusta P_TX para MRC
    P_TX_MRC(i) = -log(O_MRC / (O_MRC_calc)) / (2 * R);
    
    % Potência total MRC
    P_total_MRC(i) = (1 / eta) * P_TX_MRC(i) + M * Pcirc;
end

% Printa resultados
fprintf('Resultados para probabilidade de outage de 10^-2 e 10^-3:\n');
for i = 1:length(outage_probs)
    fprintf('\nPara probabilidade de outage = %.1e:\n', outage_probs(i));
    fprintf('Selection Combining (SC):\n');
    fprintf('  Potência necessária (P_TX_SC): %.4f mW\n', P_TX_SC(i));
    fprintf('  Potência total (P_total_SC): %.4f mW\n', P_total_SC(i));
    fprintf('Maximal Ratio Combining (MRC):\n');
    fprintf('  Potência necessária (P_TX_MRC): %.4f mW\n', P_TX_MRC(i));
    fprintf('  Potência total (P_total_MRC): %.4f mW\n', P_total_MRC(i));
end

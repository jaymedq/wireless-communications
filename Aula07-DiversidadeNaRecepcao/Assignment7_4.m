% Definição de parâmetros
M_values = [1, 2, 4, 8];      % Número de antenas
gamma_th_dB = 10;             % Limiar de SNR em dB
gamma_th = 10^(gamma_th_dB / 10); % Limiar de SNR linear
SNR_dB = -12.5:1:20;          % Vetor de SNR em dB
SNR = 10.^(SNR_dB / 10);      % SNR em escala linear

% Inicialização dos vetores de probabilidade de outage
P_out_SC = zeros(length(M_values), length(SNR));
P_out_MRC = zeros(length(M_values), length(SNR));

% Cálculo da probabilidade de outage para SC e MRC
for idx = 1:length(M_values)
    M = M_values(idx);
    
    % Probabilidade de outage para Selection Combining (SC)
    P_out_SC(idx, :) = (1 - exp(-gamma_th ./ SNR)).^M;

    % Probabilidade de outage para Maximal Ratio Combining (MRC)
    sum_terms = zeros(size(SNR));
    for k = 0:(M-1)
        sum_terms = sum_terms + (1 / factorial(k)) .* ((gamma_th ./ SNR).^k);
    end
    P_out_MRC(idx, :) = 1 - sum_terms .* exp(-gamma_th ./ SNR);
end

% Plotagem dos resultados
figure;
hold on;

% Configuração das cores para diferentes linhas
colors = lines(length(M_values)); % Gera um conjunto de cores distintas

% Função para plotagem
for idx = 1:length(M_values)
    % Plot SC
    plot(SNR_dB, P_out_SC(idx, :), 'Color', colors(idx, :), 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', ['M=' num2str(M_values(idx)) ' (SC)']);
    
    % Plot MRC
    plot(SNR_dB, P_out_MRC(idx, :), 'Color', colors(idx, :), 'LineStyle', '--', 'Marker', 'o', 'LineWidth', 1.5, 'DisplayName', ['M=' num2str(M_values(idx)) ' (MRC)']);
end

% Configurações do gráfico
hold off;
xlabel('SNR (dB)');
ylabel('Probabilidade de Outage');
title('Probabilidade de Outage');
legend('Location', 'west');
grid on;
set(gca, 'YScale', 'log');
xlim([-12.5, 20]);
ylim([1e-4, 1]);

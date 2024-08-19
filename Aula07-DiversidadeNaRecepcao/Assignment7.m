%--------------------------------------------------------------------------
% Parâmetros:
%--------------------------------------------------------------------------
SNRdB = -3:20;  % Relação sinal-ruído (SNR) em dB
SNR = 10.^(SNRdB/10);   % SNR linear
K = 1000;  % Número de bits transmitidos
m = 2;  % Parâmetro Nakagami-m
L = [1, 2, 4];  % Número de antenas receptoras

% Inicializando variáveis de BER
ber_nakagami_SC = zeros(length(L), length(SNR));
ber_nakagami_MRC = zeros(length(L), length(SNR));
ber_awgn_SC = zeros(length(L), length(SNR));
ber_awgn_MRC = zeros(length(L), length(SNR));

for l = 1:length(L)
    num_antenas = L(l);

    for i = 1:length(SNR)
        gamma = SNR(i);
        n_errors_nakagami_SC = 0;
        n_errors_nakagami_MRC = 0;
        n_errors_awgn_SC = 0;
        n_errors_awgn_MRC = 0;

        for k = 1:K
            % Geração de bits aleatórios
            bits = randi([0 1], 1, 1);
            x = 2 * bits - 1;  % Modulação BPSK

            % Canal Nakagami-m
            h_nakagami = sqrt(sum((1/sqrt(2)) * (randn(m, num_antenas) + 1i * randn(m, num_antenas)), 1));
            n = (1/sqrt(2)) * (randn(num_antenas, 1) + 1i*randn(num_antenas, 1));
            y_nakagami = h_nakagami.' * x + n / sqrt(2 * gamma);

            % SC - Nakagami-m
            [~, idx_sc] = max(abs(h_nakagami));  % Seleciona a antena com maior ganho
            y_sc = y_nakagami(idx_sc) / h_nakagami(idx_sc);
            bits_sc = real(y_sc) > 0;
            n_errors_nakagami_SC = n_errors_nakagami_SC + (bits_sc ~= bits);

            % MRC - Nakagami-m
            y_mrc = sum(conj(h_nakagami.') .* y_nakagami);
            bits_mrc = real(y_mrc) > 0;
            n_errors_nakagami_MRC = n_errors_nakagami_MRC + (bits_mrc ~= bits);

            % Canal AWGN (sem desvanecimento)
            h_awgn = ones(num_antenas, 1);
            y_awgn = h_awgn * x + n / sqrt(2 * gamma);

            % SC - AWGN
            y_sc_awgn = y_awgn(1);  % Apenas a primeira antena é usada em SC
            bits_sc_awgn = real(y_sc_awgn) > 0;
            n_errors_awgn_SC = n_errors_awgn_SC + (bits_sc_awgn ~= bits);

            % MRC - AWGN
            y_mrc_awgn = sum(conj(h_awgn) .* y_awgn);
            bits_mrc_awgn = real(y_mrc_awgn) > 0;
            n_errors_awgn_MRC = n_errors_awgn_MRC + (bits_mrc_awgn ~= bits);
        end
    
        % Calculando BER
        ber_nakagami_SC(l, i) = n_errors_nakagami_SC / K;
        ber_nakagami_MRC(l, i) = n_errors_nakagami_MRC / K;
        ber_awgn_SC(l, i) = n_errors_awgn_SC / K;
        ber_awgn_MRC(l, i) = n_errors_awgn_MRC / K;
    end
end

%--------------------------------------------------------------------------
% Plotagem dos resultados - SC AWGN
%--------------------------------------------------------------------------
figure;
for l = 1:length(L)
    semilogy(SNRdB, ber_awgn_SC(l,:), 's--', 'DisplayName', ['SC AWGN, L = ' num2str(L(l))]);
    hold on;
end
xlabel('SNR por Antena [dB]');
ylabel('Taxa de Erro de Bit (BER)');
title('BER vs. SNR para BPSK - SC (Selection Combining) - AWGN');
legend('Location', 'SouthWest');
grid on;
saveas(gcf, 'BER_SC_AWGN.png');  % Salva a imagem como PNG

%--------------------------------------------------------------------------
% Plotagem dos resultados - SC Nakagami-m
%--------------------------------------------------------------------------
figure;
for l = 1:length(L)
    semilogy(SNRdB, ber_nakagami_SC(l,:), 'o-', 'DisplayName', ['SC Nakagami, L = ' num2str(L(l))]);
    hold on;
end
xlabel('SNR por Antena [dB]');
ylabel('Taxa de Erro de Bit (BER)');
title('BER vs. SNR para BPSK - SC (Selection Combining) - Nakagami-m');
legend('Location', 'SouthWest');
grid on;
saveas(gcf, 'BER_SC_Nakagami.png');  % Salva a imagem como PNG

%--------------------------------------------------------------------------
% Plotagem dos resultados - MRC AWGN
%--------------------------------------------------------------------------
figure;
for l = 1:length(L)
    semilogy(SNRdB, ber_awgn_MRC(l,:), 'd--', 'DisplayName', ['MRC AWGN, L = ' num2str(L(l))]);
    hold on;
end
xlabel('SNR por Antena [dB]');
ylabel('Taxa de Erro de Bit (BER)');
title('BER vs. SNR para BPSK - MRC (Maximal Ratio Combining) - AWGN');
legend('Location', 'SouthWest');
grid on;
saveas(gcf, 'BER_MRC_AWGN.png');  % Salva a imagem como PNG

%--------------------------------------------------------------------------
% Plotagem dos resultados - MRC Nakagami-m
%--------------------------------------------------------------------------
figure;
for l = 1:length(L)
    semilogy(SNRdB, ber_nakagami_MRC(l,:), 'x-', 'DisplayName', ['MRC Nakagami, L = ' num2str(L(l))]);
    hold on;
end
xlabel('SNR por Antena [dB]');
ylabel('Taxa de Erro de Bit (BER)');
title('BER vs. SNR para BPSK - MRC (Maximal Ratio Combining) - Nakagami-m');
legend('Location', 'SouthWest');
grid on;
saveas(gcf, 'BER_MRC_Nakagami.png');  % Salva a imagem como PNG

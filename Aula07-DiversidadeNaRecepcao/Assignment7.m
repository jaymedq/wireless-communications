%--------------------------------------------------------------------------
% Parâmetros:
%--------------------------------------------------------------------------
SNRdB = -3:20;  % Relação sinal-ruído (SNR) em dB
SNR = 10.^(SNRdB/10);   % SNR linear
K = 10000;  % Número de bits transmitidos por simulação
Eb = 1; % Energia de bit
m = 1; % Parâmetro Nakagami-m
L = [1, 2, 4, 8, 64]; % Número de antenas receptoras
N = 100;  % Número de simulações (Monte Carlo)

% Inicializando variáveis de BER
ber_nakagami_SC = zeros(length(L), length(SNR));
ber_nakagami_MRC = zeros(length(L), length(SNR));
ber_awgn_SC = zeros(length(L), length(SNR));
ber_awgn_MRC = zeros(length(L), length(SNR));

% Monte Carlo loop
for n = 1:N
    for l = 1:length(L)
        num_antenas = L(l);

        for i = 1:length(SNR)
            N0 = Eb / SNR(i);  % SNR = Eb/N0 ==> N0 = Eb/SNR

            % Gera sequência aleatória de bits
            message = rand(1, K) > 0.5;
            x = 2 * message - 1; % BPSK

            % Canal Nakagami-m
            h_nakagami = sqrt(gamrnd(m, 1, num_antenas, 1));  % Canal com desvanecimento Nakagami-m
            n_nakagami = sqrt(N0/2) * (randn(num_antenas, K) + 1i*randn(num_antenas, K));
            y_nakagami = h_nakagami * x + n_nakagami;

            % SC - Nakagami-m
            [~, idx_sc] = max(abs(h_nakagami));  % Seleciona a antena com maior ganho
            y_sc = y_nakagami(idx_sc, :) ./ h_nakagami(idx_sc);
            bits_sc = real(y_sc) > 0;
            n_errors_nakagami_SC = sum(bits_sc ~= message);

            % MRC - Nakagami-m
            if num_antenas == 1
                y_mrc = y_nakagami ./ h_nakagami;  % Não há soma;
            else
                y_mrc = sum(conj(h_nakagami) .* y_nakagami);  % Combinação MRC
            end
            bits_mrc = real(y_mrc) > 0;
            n_errors_nakagami_MRC = sum(bits_mrc ~= message);

            % Canal AWGN (sem desvanecimento)
            h_awgn = ones(num_antenas, 1);  % Sem desvanecimento (apenas ruído)
            n_awgn = sqrt(N0/2) * (randn(num_antenas, K) + 1i*randn(num_antenas, K));
            y_awgn = h_awgn * x + n_awgn;

            % SC - AWGN
            y_sc_awgn = y_awgn(1, :);  % Apenas a primeira antena é usada em SC
            bits_sc_awgn = real(y_sc_awgn) > 0;
            n_errors_awgn_SC = sum(bits_sc_awgn ~= message);

            % MRC - AWGN
            if num_antenas == 1
                y_mrc_awgn = y_awgn ./ h_awgn;
            else
                y_mrc_awgn = sum(conj(h_awgn) .* y_awgn);
            end
            
            bits_mrc_awgn = real(y_mrc_awgn) > 0;
            n_errors_awgn_MRC = sum(bits_mrc_awgn ~= message);

            % Acumulando BER para esta simulação
            ber_nakagami_SC(l, i) = ber_nakagami_SC(l, i) + n_errors_nakagami_SC / K;
            ber_nakagami_MRC(l, i) = ber_nakagami_MRC(l, i) + n_errors_nakagami_MRC / K;
            ber_awgn_SC(l, i) = ber_awgn_SC(l, i) + n_errors_awgn_SC / K;
            ber_awgn_MRC(l, i) = ber_awgn_MRC(l, i) + n_errors_awgn_MRC / K;
        end
    end
end

% Média dos resultados de BER ao longo das simulações
ber_nakagami_SC = ber_nakagami_SC / N;
ber_nakagami_MRC = ber_nakagami_MRC / N;
ber_awgn_SC = ber_awgn_SC / N;
ber_awgn_MRC = ber_awgn_MRC / N;

%--------------------------------------------------------------------------
% Plotagem dos resultados - SC
%--------------------------------------------------------------------------
figure;
for l = 1:length(L)
    semilogy(SNRdB, ber_nakagami_SC(l,:), 'o-', 'DisplayName', ['SC Nakagami, L = ' num2str(L(l))]);
    hold on;
    semilogy(SNRdB, ber_awgn_SC(l,:), 's--', 'DisplayName', ['SC AWGN, L = ' num2str(L(l))]);
end

xlabel('SNR por Antena [dB]');
ylabel('Taxa de Erro de Bit (BER)');
title('BER vs. SNR para BPSK - SC (Selection Combining)');
legend('Location', 'SouthWest');
grid on;
saveas(gcf, 'BER_SC.png');  % Salva a imagem como PNG

%--------------------------------------------------------------------------
% Plotagem dos resultados - MRC
%--------------------------------------------------------------------------
figure;
for l = 1:length(L)
    semilogy(SNRdB, ber_nakagami_MRC(l,:), 'x-', 'DisplayName', ['MRC Nakagami, L = ' num2str(L(l))]);
    hold on;
    semilogy(SNRdB, ber_awgn_MRC(l,:), 'd--', 'DisplayName', ['MRC AWGN, L = ' num2str(L(l))]);
end

xlabel('SNR por Antena [dB]');
ylabel('Taxa de Erro de Bit (BER)');
title('BER vs. SNR para BPSK - MRC (Maximal Ratio Combining)');
legend('Location', 'SouthWest');
grid on;
saveas(gcf, 'BER_MRC.png');  % Salva a imagem como PNG

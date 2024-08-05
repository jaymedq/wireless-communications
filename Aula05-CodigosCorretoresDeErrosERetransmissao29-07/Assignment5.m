clc; clear; close all;
rand('state',0);
randn('state',0);

%--------------------------------------------------------------------------
% Parâmetros:
%--------------------------------------------------------------------------
SNRdB = -3:20;  % relação sinal-ruído (SNR) em dB
nFrames = 1000;   % número de blocos de dados (frames) transmitidos
K = 1000;        % número de bits por bloco
Eb = 1;          % energia de bit

%-------------------------------------------------------------------------
SNR = 10.^(SNRdB/10);   % SNR linear
fer_no_retx = zeros(1, length(SNR));
fer_one_retx = zeros(1, length(SNR));
fer_two_retx = zeros(1, length(SNR));
nn = (randn(1, K) + 1i*randn(1, K)); % ruído para um bloco

% Definição do código convolucional
trellis = poly2trellis(3, [6 7]); % Define a treliça
tbdepth = 2; % Profundidade da traceback

for i = 1:length(SNR)
    disp(['SNR = [' num2str(SNRdB(i)) '/' num2str(max(SNRdB)) '] (dB)']);
    N0 = Eb / SNR(i);  % SNR = Eb/N0 ==> N0 = Eb/SNR
    
    % Inicializa contadores de erro
    errors_no_retx = 0;
    errors_one_retx = 0;
    errors_two_retx = 0;
    
    for frame = 1:nFrames
        % Gera sequência aleatória de bits
        m = rand(1, K) > 0.5;
        n = sqrt(0.5 * N0) * nn;
        % Codificação
        m_cc = convenc(m, trellis); % Codifica a mensagem
        nn_cc = (randn(1, length(m_cc)) + 1i*randn(1, length(m_cc))); % Cria array base do ruído
        n_cc = sqrt(0.5 * N0) * nn_cc; % Ruído branco aleatório
        x_cc = 2 * m_cc - 1; % BPSK
        
        % Sem retransmissões
        h_slow = sqrt(1/2) * (randn + 1i*randn); % Canal de desvanecimento lento
        y_slow = h_slow * x_cc + n_cc;
        y_slow_eq = y_slow / h_slow; % Equalização
        w_slow = real(y_slow_eq > 0);
        decodedData_slow = vitdec(w_slow, trellis, tbdepth, 'trunc', 'hard');
        err_slow = sum(decodedData_slow ~= m);
        if err_slow > 0
            errors_no_retx = errors_no_retx + 1;
        end
        
        % Com possibilidade de até uma retransmissão (HARQ simples)
        for attempt = 1:2
            h_slow = sqrt(1/2) * (randn + 1i*randn);
            y_slow = h_slow * x_cc + n_cc;
            y_slow_eq = y_slow / h_slow;
            w_slow = real(y_slow_eq > 0);
            decodedData_slow = vitdec(w_slow, trellis, tbdepth, 'trunc', 'hard');
            err_slow = sum(decodedData_slow ~= m);
            if err_slow == 0
                break;
            end
        end
        if err_slow > 0
            errors_one_retx = errors_one_retx + 1;
        end
        
        % Com possibilidade de até duas retransmissões (HARQ simples)
        for attempt = 1:3
            h_slow = sqrt(1/2) * (randn + 1i*randn);
            y_slow = h_slow * x_cc + n_cc;
            y_slow_eq = y_slow / h_slow;
            w_slow = real(y_slow_eq > 0);
            decodedData_slow = vitdec(w_slow, trellis, tbdepth, 'trunc', 'hard');
            err_slow = sum(decodedData_slow ~= m);
            if err_slow == 0
                break;
            end
        end
        if err_slow > 0
            errors_two_retx = errors_two_retx + 1;
        end
    end
    
    % Cálculo da FER
    fer_no_retx(i) = errors_no_retx / nFrames;
    fer_one_retx(i) = errors_one_retx / nFrames;
    fer_two_retx(i) = errors_two_retx / nFrames;
end

% Plot FER
figure
semilogy(SNRdB, fer_no_retx, 'r-', 'LineWidth', 2);
hold on;
semilogy(SNRdB, fer_one_retx, 'g-', 'LineWidth', 2);
semilogy(SNRdB, fer_two_retx, 'b-', 'LineWidth', 2);

xlabel('E_b/N_0 (dB)');
ylabel('FER');
legend({'Sem Retransmissão', '1 Retransmissão', '2 Retransmissões'}, 'FontSize', 12);
axis([-3 20 10^-5 1]);
grid on;

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
ber_rayleigh = zeros(1, length(SNR));
ber_no_retx = zeros(1, length(SNR));
ber_fast = zeros(1, length(SNR));
fer_rayleigh = zeros(1, length(SNR));
fer_no_retx = zeros(1, length(SNR));
fer_fast = zeros(1, length(SNR));
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
    bit_errors_rayleigh = 0;
    bit_errors_slow = 0;
    bit_errors_fast = 0;
    frame_errors_rayleigh = 0;
    frame_errors_no_retx = 0;
    frame_errors_fast = 0;
    frame_errors_one_retx = 0;
    frame_errors_two_retx = 0;
    
    for frame = 1:nFrames
        % Gera sequência aleatória de bits
        m = rand(1, K) > 0.5;
        % Codificação
        m_cc = convenc(m, trellis); % Codifica a mensagem
        R = 1/2;
        n_cc = sqrt((0.5/R) * N0) * (randn(1, length(m_cc)) + 1i*randn(1, length(m_cc))); % Cria array base do ruído
        x_cc = 2 * m_cc - 1; % BPSK
        
        % Sem retransmissões
        h = sqrt(1/2) * (randn(1, length(m)) + 1i*randn(1, length(m))); % Canal de desvanecimento lento
        x = 2 * m - 1; %BPSK
        n = sqrt((0.5/R) * N0) * (randn(1, length(m)) + 1i*randn(1, length(m))); % Cria array base do ruído
        y = h .* x + n;
        y_eq = y ./ h; % Equalização
        w = real(y_eq > 0);
        frame_bit_errors_rayleigh = sum(w ~= m);
        if frame_bit_errors_rayleigh > 0
            frame_errors_rayleigh = frame_errors_rayleigh + 1;
            bit_errors_rayleigh = bit_errors_rayleigh + frame_errors_rayleigh;
        end

        % Sem retransmissões
        h_slow = sqrt(1/2) * (randn + 1i*randn); % Canal de desvanecimento lento
        y_slow = h_slow * x_cc + n_cc;
        y_slow_eq = y_slow / h_slow; % Equalização
        w_slow = real(y_slow_eq > 0);
        decodedData_slow = vitdec(w_slow, trellis, tbdepth, 'trunc', 'hard');
        frame_bit_errors = sum(decodedData_slow ~= m);
        if frame_bit_errors > 0
            frame_errors_no_retx = frame_errors_no_retx + 1;
            bit_errors_slow = bit_errors_slow + frame_bit_errors;
        end
        
        % Sem retransmissões
        h_fast = sqrt(1/2) * (randn(1, length(m_cc)) + 1i*randn(1, length(m_cc))); % Canal de desvanecimento lento
        y_fast = h_fast .* x_cc + n_cc;
        y_fast_eq = y_fast ./ h_fast; % Equalização
        w_fast = real(y_fast_eq > 0);
        decodedData_fast = vitdec(w_fast, trellis, tbdepth, 'trunc', 'hard');
        frame_bit_errors_fast = sum(decodedData_fast ~= m);
        if frame_bit_errors_fast > 0
            frame_errors_fast = frame_errors_fast + 1;
            bit_errors_fast = bit_errors_fast + frame_bit_errors_fast;
        end
        
        % % Com possibilidade de até uma retransmissão (HARQ simples)
        % for attempt = 1:2
        %     h_slow = sqrt(1/2) * (randn + 1i*randn);
        %     y_slow = h_slow * x_cc + n_cc;
        %     y_slow_eq = y_slow / h_slow;
        %     w_slow = real(y_slow_eq > 0);
        %     decodedData_slow = vitdec(w_slow, trellis, tbdepth, 'trunc', 'hard');
        %     frame_bit_errors = sum(decodedData_slow ~= m);
        %     if frame_bit_errors == 0
        %         break;
        %     end
        % end
        % if frame_bit_errors > 0
        %     frame_errors_one_retx = frame_errors_one_retx + 1;
        % end
        
        % % Com possibilidade de até duas retransmissões (HARQ simples)
        % for attempt = 1:3
        %     h_slow = sqrt(1/2) * (randn + 1i*randn);
        %     y_slow = h_slow * x_cc + n_cc;
        %     y_slow_eq = y_slow / h_slow;
        %     w_slow = real(y_slow_eq > 0);
        %     decodedData_slow = vitdec(w_slow, trellis, tbdepth, 'trunc', 'hard');
        %     frame_bit_errors = sum(decodedData_slow ~= m);
        %     if frame_bit_errors == 0
        %         break;
        %     end
        % end
        % if frame_bit_errors > 0
        %     frame_errors_two_retx = frame_errors_two_retx + 1;
        % end
    end
    
    % Cálculo da FER
    ber_rayleigh(i) = bit_errors_rayleigh / (K*nFrames);
    ber_no_retx(i) = bit_errors_slow / (K*nFrames);
    ber_fast(i) = bit_errors_fast / (K*nFrames);
    fer_rayleigh(i) = frame_errors_rayleigh / nFrames;
    fer_no_retx(i) = frame_errors_no_retx / nFrames;
    fer_fast(i) = frame_errors_fast / nFrames;
    % fer_one_retx(i) = frame_errors_one_retx / nFrames;
    % fer_two_retx(i) = frame_errors_two_retx / nFrames;
end

% Plot BER
figure
semilogy(SNRdB, ber_rayleigh, 'r-', 'LineWidth', 2);
hold on;
semilogy(SNRdB, ber_no_retx, 'g-', 'LineWidth', 2);
semilogy(SNRdB, ber_fast, 'b-', 'LineWidth', 2);

xlabel('E_b/N_0 (dB)');
ylabel('BER');
legend({'Rayleigh no code', 'Slow fading CC', 'Fast fading CC'}, 'FontSize', 12);
axis([-3 20 10^-5 1]);
grid on;

% Plot FER
figure
semilogy(SNRdB, fer_rayleigh, 'r-', 'LineWidth', 2);
hold on;
semilogy(SNRdB, fer_no_retx, 'g-', 'LineWidth', 2);
semilogy(SNRdB, fer_fast, 'b-', 'LineWidth', 2);
% semilogy(SNRdB, fer_one_retx, 'g-', 'LineWidth', 2);
% semilogy(SNRdB, fer_two_retx, 'b-', 'LineWidth', 2);

xlabel('E_b/N_0 (dB)');
ylabel('FER');
legend({'Rayleigh no code', 'Slow fading', 'Fast fading'}, 'FontSize', 12);
% legend({'Sem Retransmissão', '1 Retransmissão', '2 Retransmissões'}, 'FontSize', 12);
axis([-3 20 10^-5 2]);
grid on;

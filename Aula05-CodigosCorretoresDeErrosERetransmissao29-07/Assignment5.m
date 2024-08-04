clc; clear; close all;
rand('state',0);
randn('state',0);
%--------------------------------------------------------------------------
% Parâmetros:
%--------------------------------------------------------------------------
SNRdB = 0:1:12;  % relação sinal-ruído (SNR) em dB
SNRdB
nBits = 10^4;    % quantidade de bits transmitidos
Eb = 1;          % energia de bit   
%-------------------------------------------------------------------------
SNR = 10.^(SNRdB/10);   % SNR linear;
ber_awgn = zeros(1,length(SNR));
ber_awgn_cc = zeros(1,length(SNR));
nn = (randn(1,nBits)+1i*randn(1,nBits));
for i=1:length(SNR)   
    disp(['SNR = [' num2str(SNRdB(i)) '/' num2str(max(SNRdB)) '] (dB)']);
    N0 =  Eb./SNR(i);       % SNR = Eb/N0 ==> N0 = Eb/SNR
    m = rand(1,nBits)>0.5;  % gera sequência aleatória de bits
    n = sqrt(0.5*N0)*nn;             
    
    %% AWGN
    x = 2*m-1; % BPSK
    y = x + n;
    err = sum(real(y>0)~= m);
    ber_awgn(i) = err/nBits;
    %% Convolutional AWGN
    % Código Convolutional
    trellis = poly2trellis(7,[171 133]); % Define treliça.
    % Codificação
    m_cc = convenc(m,trellis); %Codifica mensagem
    nn_cc = (randn(1,length(m_cc))+1i*randn(1,length(m_cc))); % Cria array base do ruido
    n_cc = sqrt(0.5*N0)*nn_cc; % Ruido branco aleatorio
    x_cc = 2*m_cc-1;% BPSK
    y_cc = x_cc + n_cc; % Aplica ruido
    w_cc = real(y_cc>0); %Decisao BPSK
    tbdepth = 2;
    decodedData = vitdec(w_cc,trellis,tbdepth,'trunc','hard');
    % Cálculo de erro
    err_cc = sum(decodedData~=m);
    ber_awgn_cc(i) = err_cc/nBits;
end
SNR
ber_awgn
ber_awgn_cc
Pb = qfunc(sqrt(2*SNR));
figure
semilogy(SNRdB, ber_awgn,'r*',...
    'linewidth',2.0, 'markersize',6,'MarkerFaceColor', [0.5 1 1])
legend({'Não Codificado'},'fontsize',12)
hold on;
semilogy(SNRdB, Pb,'r--',...
    'linewidth',2.0, 'markersize',6,'MarkerFaceColor', [0.5 1 1])
hold on;
semilogy(SNRdB, ber_awgn_cc, 'b-', 'linewidth',2.0, 'markersize',6,'MarkerFaceColor', [0.5 0.5 1])
xlabel('E_b/N_0 (dB)')
ylabel('BER')
legend({'Não Codificado', 'Teórico', 'Codificado'},'fontsize',12)
ylim([100/nBits 1])
grid

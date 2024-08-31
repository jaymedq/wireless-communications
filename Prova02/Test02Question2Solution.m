%% Questão 2
%{
Considere um canal de comunicações sem o onde a potência recebida é dada por:

Pr[dB]=Pt[dB]+30log10(d0/d)−40[dB],

onde d0 = 1 m, a banda é de B = 1 MHz, N0 = -170 dBm/Hz, Rb = 1 Mbps e Pt = 30 dBm.
Determine:
%}
close all; clearvars; clc;
%Parametros
d0 = 1;
B = 1e6;
N0_dBm = -170;
N0_dB = N0_dBm - 30;
N0 = 10^(N0_dB/10);
Rb = 1e6;
Pt_dBm = 30;
Pt_dB = Pt_dBm - 30;

%(a) Encontre a capacidade em Mbits/s deste canal supondo d = 1 km.
d = 1e3;
Pr_dB=Pt_dB+30*log10(d0/d)-40;
Pr = 10^(Pr_dB/10);
SNR = Pr/(N0*B);
C = B*log2(1+SNR)
fprintf('A capacidade em Mbits/s deste canal supondo d = 1 km é: %.3f\n', C/1e6);

%(b) De quanto aumentaria a capacidade (em %) se dobrarmos Pt?
Pr_dB_2Pt=(Pt_dB+3)+30*log10(d0/d)-40;
Pr_2Pt = 10^(Pr_dB_2Pt/10);
SNR_2Pt = Pr_2Pt/(N0*B);
C_2Pt = B*log2(1+SNR_2Pt)
PercentualDeAumento_2Pt = (C_2Pt/C)*100;
fprintf('Dobrando Pt, aumenta em: %.3f%% \n', PercentualDeAumento_2Pt);

%(c) De quanto aumentaria a capacidade original (com Pt = 30 dBm) se considerarmos N = 2 antenas no transmissor, M = 2 antenas no receptor, usando diversidade?
% Numero de antenas
% C = log2 (1 + MNγ)
N = 2;
M = 2;
C_Diversidade = B*log2(1 + M*N*SNR)
PercentualDeAumento_Diversidade = (C_Diversidade/C)*100;
fprintf('Usando diversidade com N = %d e M = %d: %.3f%% \n',M,N,PercentualDeAumento_Diversidade);


%(d) De quanto aumentaria a capacidade original (com Pt = 30 dBm) se considerarmos N = 2 antenas no transmissor, M = 2 antenas no receptor, usando multiplexação espacial?
% C = Q log2 (1 + γ)
Q = min(M,N);
C_Mux = B*Q*log2(1 + SNR)
PercentualDeAumento_Mux = (C_Mux/C)*100;
fprintf('Usando multiplexação espacial com N = %d e M = %d: %.3f%% \n',M,N,PercentualDeAumento_Mux);
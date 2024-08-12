close all; clearvars; clc

% Channel_functions.m
ch_func = Channel_functions();

%% Physical Layer Specifications
B       = 20e6;     % OFDM bandwidth (Hz)
nFFT    = 64;       % FFT size
nSym    = 50;       % Number of symbols within one frame
BN      = B/nFFT;   % Bandwidth for each subcarrier - include all used and unused subcarriers
K_cp    = 16;       % Number of symbols allocated to cyclic prefix

nBitPerSym_values = [1, 4, 6]; % BPSK, 16-QAM, 64-QAM
mod_schemes = {'BPSK', '16QAM', '64QAM'};
M_values = 2.^nBitPerSym_values;
%% ------ BPSK Modulation ------------------------------------------
Pow         = 1;

%% ----------------- Vehicular Channel Model Parameters (Example) --------------------------
ChType      = 'VTV_UC';         % Channel model
fs          = nFFT*BN;          % Sampling frequency in Hz
fc          = 5.9e9;            % Carrier Frequecy in Hz
v           = 50;               % Moving speed of user in km/h
c           = 3e8;              % Speed of Light in m/s
fD          = (v/3.6)/c*fc;     % Doppler freq in Hz

% Coherence Time
Tc = 1/fD;
rchan = ch_func.GenFadingChannel(ChType, fD, fs);
release(rchan);

%% --------- Noise Ratio ------------------%
EbN0dB      = 0:5:20;
EbN0Lin     = 10.^(EbN0dB/10);
N0 = 10.^(-EbN0Lin/10);

%% Simulation Parameters
N_CH                    = 100; % number of channel realizations
N_SNR                   = length(EbN0Lin); % SNR length

% Bit error rate (BER) vectors
Ber_vector               = zeros(N_SNR,1);
BER_OFDM               = zeros(length(nBitPerSym_values),N_SNR);

for idx_mod = 1:length(nBitPerSym_values)
    %% Simulation Loop
    for n_snr = 1:N_SNR
        disp(['Running Simulation, SNR = ', num2str(EbN0dB(n_snr))]);

        for n_ch = 1:N_CH % loop over channel realizations

            % Bits Stream Generation
            Bits_Stream = randi(2, nFFT * nSym  * nBitPerSym_values(idx_mod), 1) - 1;

            % Bits Mapping: BPSK Modulation
            TxBits = reshape(Bits_Stream, nFFT, nSym, nBitPerSym_values(idx_mod));
            if strcmp(mod_schemes{idx_mod}, 'BPSK')
                Modulated_Bits = pskmod(TxBits, M_values(idx_mod));
            else
                Modulated_Bits = 1/sqrt(Pow)*qammod(TxData, M_values(idx_mod));
            end
            TxData = zeros(nFFT ,nSym);
            for m = 1 : nBitPerSym_values(idx_mod)
               TxData = TxData + TxBits(:,:,m)*2^(m-1);
            end

            % time domain
            IFFT_Data = ifft(Modulated_Bits);

            % normalization to ensure unit power of the signal
            norm_factor = sqrt(sum(abs(IFFT_Data(:).^2))./length(IFFT_Data(:)));
            IFFT_Data_compensated = IFFT_Data/norm_factor;
            pRMS = rms(IFFT_Data_compensated);  % pRMS must be 1 after normalization

            % Appending cylic prefix
            CP = IFFT_Data_compensated((nFFT - K_cp +1):nFFT,:);
            IFFT_Data_CP = [CP; IFFT_Data_compensated];

            % wireless channel
            release(rchan);
            [ h, y ] = ch_func.ApplyChannel(rchan, IFFT_Data_CP, K_cp);
            release(rchan);
            rchan.Seed = rchan.Seed+1;

            % Remove CP
            y  = y((K_cp+1):end,:);

            % frequency domain
            yFD = sqrt(1/nFFT)*fft(y);

            h = h((K_cp+1):end,:);
            hf = fft(h); % Fd channel

            % add noise
            noise_OFDM_Symbols = sqrt(N0(n_snr))*ch_func.GenRandomNoise([nFFT,size(yFD,2)], 1);
            y_r   = yFD + noise_OFDM_Symbols;

            %%%%%%%%
            % ZF Equalization (RX knows hf perfectly)
            y_eq = y_r ./ hf;

            % BPKS Demodulation
            De_Mapped = pskdemod(y_eq, M_values(idx_mod));

            % Bits Extraction
            Bits_RX = zeros(nFFT, nSym, nBitPerSym_values(idx_mod));
            for b = 1:nSym
                Bits_RX(:,b,:) = de2bi(De_Mapped(:,b));
            end

            % BER calculation
            ber_aux = biterr(Bits_RX(:), Bits_Stream);

            Ber_vector(n_snr) = Ber_vector(n_snr) + ber_aux;
        end
    end
    BER_OFDM(idx_mod,:) = Ber_vector/(N_CH * nSym * nFFT * nBitPerSym_values(idx_mod))
end
%% Bit Error Rate (BER)
figure
semilogy(EbN0dB, BER_OFDM(1,:), 'r-', 'LineWidth',2);
hold on;
semilogy(EbN0dB, BER_OFDM(2,:), 'g-', 'LineWidth',2);
semilogy(EbN0dB, BER_OFDM(3,:), 'b-', 'LineWidth',2);
legend({'BPSK', '16QAM', '64QAM'}, 'FontSize', 12);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
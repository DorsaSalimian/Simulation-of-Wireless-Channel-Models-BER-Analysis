clear all; close all; clc;


N = 1e5;               
SNR_dB = 0:2:20;   
K_factor = 3;         


mod_types = {'BPSK', 'QPSK', '16-QAM'};
M_values = [2, 4, 16];

figure('Color', 'w');


for m = 1:length(mod_types)
    M = M_values(m);
    k = log2(M);
    
    ber_awgn = zeros(1, length(SNR_dB));
    ber_rayleigh = zeros(1, length(SNR_dB));
    ber_rician = zeros(1, length(SNR_dB));
    
    for i = 1:length(SNR_dB)
        % 1. تولید داده‌های تصادفی
        data = randi([0 M-1], N, 1);
        
        % 2. مدولاسیون
        tx_sig = qammod(data, M, 'UnitAveragePower', true);
        
        % --- ۳. اعمال کانال‌ها ---
        
        % الف) کانال AWGN
        rx_awgn = awgn(tx_sig, SNR_dB(i) + 10*log10(k), 'measured');
        
        % ب) کانال Rayleigh
        h_ray = (randn(N,1) + 1i*randn(N,1))/sqrt(2);
        rx_ray = h_ray .* tx_sig;
        rx_ray = awgn(rx_ray, SNR_dB(i) + 10*log10(k), 'measured');
        
        s = sqrt(K_factor/(K_factor+1)); 
        sigma = sqrt(1/(2*(K_factor+1))); 
        h_ric = (s + sigma*randn(N,1)) + 1i*(sigma*randn(N,1));
        rx_ric = h_ric .* tx_sig;
        rx_ric = awgn(rx_ric, SNR_dB(i) + 10*log10(k), 'measured');
        
        
        data_awgn = qamdemod(rx_awgn, M, 'UnitAveragePower', true);
        

        data_ray = qamdemod(rx_ray ./ h_ray, M, 'UnitAveragePower', true);
        
  
        data_ric = qamdemod(rx_ric ./ h_ric, M, 'UnitAveragePower', true);
        

        [~, ber_awgn(i)] = biterr(data, data_awgn);
        [~, ber_rayleigh(i)] = biterr(data, data_ray);
        [~, ber_rician(i)] = biterr(data, data_ric);
    end
    
  
    subplot(1, 3, m);
    semilogy(SNR_dB, ber_awgn, 'b-o', 'LineWidth', 1.5); hold on;
    semilogy(SNR_dB, ber_rayleigh, 'r-s', 'LineWidth', 1.5);
    semilogy(SNR_dB, ber_rician, 'g-d', 'LineWidth', 1.5);
    
    grid on;
    title(['Performance of ', mod_types{m}]);
    xlabel('Eb/No (dB)');
    ylabel('Bit Error Rate (BER)');
    if m == 1, legend('AWGN', 'Rayleigh', 'Rician'); end
end
function [SNR] = get_snr(Signal, noise)
    amp_Signal = mean(abs(Signal));
    amp_noise = mean(abs(noise));
    SNR = 20*log10(amp_Signal/amp_noise);
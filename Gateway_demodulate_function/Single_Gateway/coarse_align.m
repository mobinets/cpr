function [coarse_value] = coarse_align(G0, lora_set, downchirp)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Preamble_length = lora_set.Preamble_length;
    zeropadding_size = 8;

    samples = G0(1:dine);
    samples_dechirp = samples .* downchirp;
    samples_fft = abs(fft(samples_dechirp, dine*zeropadding_size));
    samples_fft_merge = samples_fft(1:fft_x*zeropadding_size) + samples_fft(dine*zeropadding_size-fft_x*zeropadding_size+1:dine*zeropadding_size);

    [~, coarse_value] = max(samples_fft_merge);
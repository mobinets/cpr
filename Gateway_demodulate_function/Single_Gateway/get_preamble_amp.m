function [preamble_amp_ref] = get_preamble_amp(G0, lora_set, downchirp)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;

    samples = G0(1:dine);
    samples_dechirp = samples .* downchirp;
    samples_fft = abs(fft(samples_dechirp, dine));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];

    [preamble_amp_ref, ~] = max(samples_fft_merge);
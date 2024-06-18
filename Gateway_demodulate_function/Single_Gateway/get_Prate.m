function [peak_rate, peak_noise_rate] = get_Prate(G0, lora_set, downchirp)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;

    samples = G0(dine+1:dine*2);   % 第二个窗口
    samples_dechirp = samples .* downchirp;
    samples_fft = abs(fft(samples_dechirp, dine));
    samples_fft_merge = [samples_fft(1:fft_x/2) + samples_fft(dine-fft_x+1:dine-fft_x/2), samples_fft(dine-fft_x/2+1:dine) + samples_fft(fft_x/2+1:fft_x)];

    [peak, pos] = max(samples_fft_merge);
    % 找到fft_x*leakage_width1范围内的旁瓣
    condition_1 = abs(pos-[1:fft_x]) < fft_x*0.05;   
    condition_2 = abs(pos-[1:fft_x]) > fft_x*0.95;
    samples_fft_merge(condition_1 | condition_2) = 0; 

    peak_mean = mean(samples_fft_merge);
    noise_max = max(samples_fft_merge);
    peak_rate = peak / peak_mean;
    peak_noise_rate = peak / noise_max;
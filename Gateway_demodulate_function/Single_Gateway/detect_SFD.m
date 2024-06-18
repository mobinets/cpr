function [SFD_pos] = detect_SFD(G0, lora_set, upchirp, preamble_amp_ref)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Preamble_length = lora_set.Preamble_length;
    SFD_pos = 11;

    samples = reshape(G0(1 : Preamble_length*2*dine), [dine, Preamble_length*2]).';
    samples_dechirp = samples .* upchirp;
    samples_fft = abs(fft(samples_dechirp, dine, 2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    
    [fft_amp_max, ~] = max(samples_fft_merge, [], 2);    % 获得FFT中的主峰的峰值强度和位置
    for i = 1:Preamble_length*2
        if fft_amp_max(i) > preamble_amp_ref*0.5
            SFD_pos = i;
            break;
        end
    end


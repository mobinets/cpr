function [SFD_pos] = detect_pkg2_SFD_cor(G0, lora_set, upchirp, preamble_amp_ref, conflict_pos, Pkg2_winmobi)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Preamble_length = lora_set.Preamble_length;
    SFD_pos = conflict_pos + 10;

    idealchirp = [upchirp, upchirp, upchirp(1:dine*0.25)];
    for i = 1:1:dine*4
        windows = G0((conflict_pos+7)*dine+i : (conflict_pos+8)*dine+i-1);
        cor(i) = abs(xcorr(windows, idealchirp, 0));
    end
    
    [~, cor_max] = max(cor, [], 2);    % 获得FFT中的主峰的峰值强度和位置
    i = 1;
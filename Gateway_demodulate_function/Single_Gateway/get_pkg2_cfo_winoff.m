function [cfo, windows_offset] = get_pkg2_cfo_winoff(G0, lora_set, downchirp, upchirp)
    % 计算主峰的CFO(需要补零操作)
    % 对Preamble阶段的FFT峰值进行排序，得到前filter的峰
    zeropadding_size = 8;                   % 设置补零的数量，这里的8表示，补上7倍窗口的零，计算FFT时一共是8倍的窗口（7+1）
    d_sf = lora_set.sf;
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    filter_num = lora_set.filter_num;
    Preamble_length = lora_set.Preamble_length;
    leakage_width1 = lora_set.leakage_width1;
    leakage_width2 = lora_set.leakage_width2;
    samples = reshape(G0(1:Preamble_length*dine),[dine,Preamble_length]).';
    samples_fft = abs(fft(samples .* downchirp, dine*zeropadding_size*2^(10-d_sf),2));
    samples_fft_merge = [samples_fft(:,1:4096) + samples_fft(:,57345:61440) , samples_fft(:,61441:65536) + samples_fft(:,4097:8192)];
    samples_fft_merge(:, 6553 : 58982) = 0;
    [~, Peak_pos] = max(samples_fft_merge, [], 2);

    upchirp_peak = mode(Peak_pos);

    % 已知downchirp的位置，得到downchirp的bin
    SFD_samples = reshape(G0((Preamble_length+2)*dine+1:(Preamble_length+4)*dine),[dine,2]).';
    SFD_samples_fft = abs(fft(SFD_samples .* upchirp, dine*zeropadding_size*2^(10-d_sf),2));
    samples_fft_merge = [SFD_samples_fft(:,1:4096) + SFD_samples_fft(:,57345:61440) , SFD_samples_fft(:,61441:65536) + SFD_samples_fft(:,4097:8192)];
    [~,SFD_pos_max] = max(samples_fft_merge,[],2);
    downchirp_peak = SFD_pos_max(1);
    
    % 计算CFO和窗口偏移量
    if upchirp_peak + downchirp_peak < 8192*0.5
        cfo_bin = upchirp_peak + downchirp_peak - 2;
        cfo = -cfo_bin/2/8192 * d_bw;
        windows_offset = (downchirp_peak - upchirp_peak) / 2^(11-d_sf);
    elseif upchirp_peak + downchirp_peak > 8192*1.5
        cfo_bin = upchirp_peak + downchirp_peak - 8192*2 - 2;
        cfo = -cfo_bin/2/8192 * d_bw;
        windows_offset = (downchirp_peak - upchirp_peak) / 2^(11-d_sf);
    else
        cfo_bin = upchirp_peak + downchirp_peak - 8192 - 2;
        cfo = -cfo_bin/2/8192 * d_bw;
        windows_offset = (8192 - (upchirp_peak - downchirp_peak)) / 2^(11-d_sf);
    end
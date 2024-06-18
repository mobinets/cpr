function [cfo, windows_offset] = get_cfo_win_tmp(G0, lora_set, downchirp, upchirp, SFD_pos)
    zeropadding_size = 8;                   % 设置补零的数量，这里的8表示，补上7倍窗口的零，计算FFT时一共是8倍的窗口（7+1）
    d_sf = lora_set.sf;
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    filter_num = lora_set.filter_num;
    Preamble_length = lora_set.Preamble_length;
    leakage_width1 = lora_set.leakage_width1;
    leakage_width2 = lora_set.leakage_width2;

    samples = G0((SFD_pos-1)*dine+1 : SFD_pos*dine);
    samples_fft = abs(fft(samples .* downchirp, dine*zeropadding_size*2^(10-d_sf)));
    samples_fft_merge = [samples_fft(1:4096) + samples_fft(57345:61440) , samples_fft(61441:65536) + samples_fft(4097:8192)];
    samples_fft_merge_tmp = samples_fft_merge(1:(16+4)*8*2^(10-d_sf));  % sync word + 4
    samples_fft_merge_tmp(1:(16-4)*8*2^(10-d_sf)) = 0; % sync word -4
    [~, upchirp_bin] = max(samples_fft_merge_tmp);

    samples = G0(SFD_pos*dine+1 : (SFD_pos+1)*dine);
    samples_fft = abs(fft(samples .* upchirp, dine*zeropadding_size*2^(10-d_sf)));
    samples_fft_merge = [samples_fft(1:4096) + samples_fft(57345:61440) , samples_fft(61441:65536) + samples_fft(4097:8192)];    
    [~, downchirp_bin] = max(samples_fft_merge);
    
    % 计算CFO和窗口偏移量
    cfo_bin = upchirp_bin + downchirp_bin - 8192 - 2 - 128*2^(11-d_sf);
    cfo = -cfo_bin/2/8192 * d_bw;
    windows_offset = (8192 - (upchirp_bin - downchirp_bin)) / 2^(11-d_sf);
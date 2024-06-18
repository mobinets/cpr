function [] = see_zeropaddingfft(G0, lora_set)
    d_sf = lora_set.sf;
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Preamble_length = lora_set.Preamble_length;
    zeropadding_size = 8;

    cmx = 1+1*1i;
    pre_dir = 2*pi;
    f0 = d_bw/2;                           % 设置理想upchirp和downchirp的初始频率
    d_symbols_per_second = d_bw / fft_x; 
    T = -0.5 * d_bw * d_symbols_per_second;  
    d_samples_per_second = 1000000;        % sdr-rtl的采样率
    d_dt = 1/d_samples_per_second;         % 采样点间间隔的时间
    t = d_dt*(0:1:dine-1);

    % 计算理想downchirp和upchirp存入d_downchirp和d_upchirp数组中（复数形式）
    d_downchirp = cmx * (cos(pre_dir .* t .* (f0 + T * t)) + sin(pre_dir .* t .* (f0 + T * t))*1i);
    d_upchirp = cmx * (cos(pre_dir .* t .* (f0 + T * t) * -1) + sin(pre_dir .* t .* (f0 + T * t) * -1)*1i);

    samples = reshape(G0(1:(Preamble_length+2)*dine),[dine,(Preamble_length+2)]).';
    samples_dechirp = samples .* d_downchirp;
    samples_fft = abs(fft(samples_dechirp, dine*zeropadding_size*2^(10-d_sf), 2));

    samples_fft_merge = [samples_fft(:, 1:4096) + samples_fft(:, 57345:61440) , samples_fft(:, 61441:65536) + samples_fft(:, 4097:8192)];
    % samples_fft_merge_tmp = samples_fft_merge(1:160);
    % samples_fft_merge_tmp(1:96) = 0;
    [~, upchirp_bin] = max(samples_fft_merge, [], 2);
    i = 1;
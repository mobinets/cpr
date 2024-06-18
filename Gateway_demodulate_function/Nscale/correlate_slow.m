function [algin_windows, detect_flag, pkg1_cor] = correlate_slow(G0, lora_set)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    detect_flag = 1;
    pkg1_cor = Inf;

    cmx = 1+1*1i;
    pre_dir = 2*pi;
    f0 = lora_set.bw/2;                           % 设置理想upchirp和downchirp的初始频率
    d_symbols_per_second = lora_set.bw / lora_set.fft_x; 
    T = -0.5 * lora_set.bw * d_symbols_per_second;  
    d_samples_per_second = 1000000;        % sdr-rtl的采样率
    d_dt = 1/d_samples_per_second;         % 采样点间间隔的时间
    t = d_dt*(0:1:lora_set.dine-1);
    % 计算理想downchirp和upchirp存入d_downchirp和d_upchirp数组中（复数形式）
    d_downchirp = cmx * (cos(pre_dir .* t .* (f0 + T * t)) + sin(pre_dir .* t .* (f0 + T * t))*1i);
    d_upchirp = cmx * (cos(pre_dir .* t .* (f0 + T * t) * -1) + sin(pre_dir .* t .* (f0 + T * t) * -1)*1i);

    windows = G0(1:dine);
    cor = abs(xcorr(windows, d_upchirp, dine, 'normalized'));
    [~, max_pos_cor] = max(cor(dine+1 : dine*2));
    windows = G0(max_pos_cor : max_pos_cor+dine-1);
    cor = abs(xcorr(windows, d_upchirp, 0, 'normalized'));

    if cor > 0.5
        cor_array = zeros(1,8);
        for i = 0:7
            cor_array(i+1) = abs(xcorr(G0(max_pos_cor+dine*i : max_pos_cor+dine*(i+1)-1), d_upchirp, 0, 'normalized'));
        end
        condition2 = find(cor_array > 0.5);
        if length(condition2) == 8
            algin_windows = max_pos_cor;
            pkg1_cor = mean(cor_array);
        else
            detect_flag = 0;
            algin_windows = 0;
        end
    else
        detect_flag = 0;
        algin_windows = 0;
    end

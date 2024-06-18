function [algin_windows, detect_flag, pkg1_cor, cor_floor] = correlate(G0, lora_set)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    detect_flag = 1;
    pkg1_cor = Inf;
    leakage_width1 = lora_set.leakage_width1;

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

%     cor_tmp = zeros(1,dine*2);
%     for i = 1:1:dine*2
%         windows = G0(i:i+dine-1);
%         cor_tmp(i) = abs(xcorr(windows, d_upchirp, 0, 'normalized'));
%     end
    windows = G0(1:dine*2);
    cor = abs(xcorr(windows, d_upchirp, dine*2));
    [max_value_cor, max_pos_cor] = max(cor(dine*2+1:dine*4));

    % 将包1的cor值清零
    cor_tmp = cor(dine*2+1:dine*4);
    for j = 0:1
        reset_zoom = max_pos_cor - dine*(leakage_width1-j) : max_pos_cor + dine*(j+leakage_width1);
        reset_zoom(round(reset_zoom)<=0 ) = 1;
        cor_tmp(round(reset_zoom)) = 0;
    end
    cor_floor = max(cor_tmp) * 3.5;
%     plot(cor(dine*2+1:dine*4), 'r');
%     [max_value_cor, max_pos_cor] = max(cor);
    if max_value_cor > mean(cor) * 2
        if max_pos_cor > dine  % 如果对齐的值大于一个窗口，则其前一个窗口可能还存在一个preamble
            cor_array = zeros(1,8);
            for i = -1:6
                cor_array(i+2) = abs(xcorr(G0(max_pos_cor+dine*i : max_pos_cor+dine*(i+1)), d_upchirp, 0));
            end
            condition1 = find(cor_array > max_value_cor * 0.5);
            if length(condition1) == 8
                algin_windows = max_pos_cor - dine;
                pkg1_cor = mean(cor_array);
            elseif length(condition1) == 7
                algin_windows = max_pos_cor;
                pkg1_cor = mean(cor_array(2:8));
            else
                detect_flag = 0;
                algin_windows = 0;
            end
        else    % 对齐的值小于一个窗口，则需要找到连续八个preamble的cor大于某一个值
            cor_array = zeros(1,8);
            for i = 0:7
                cor_array(i+1) = abs(xcorr(G0(max_pos_cor+dine*i : max_pos_cor+dine*(i+1)), d_upchirp, 0));
            end
            condition2 = find(cor_array > max_value_cor * 0.5);
            if length(condition2) == 8
                algin_windows = max_pos_cor;
                pkg1_cor = mean(cor_array);
            else
                detect_flag = 0;
                algin_windows = 0;
            end
        end
    else
        detect_flag = 0;
        algin_windows = 0;
    end

function [pkg2_algin_windows, conflict_flag] = nscale_correlate_pkg2_slow(G0, lora_set, pkg1_cor, pkg1_algin_windows)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Preamble_length = lora_set.Preamble_length;
    Pkg_length = lora_set.Pkg_length;
    leakage_width1 = lora_set.leakage_width1;
    conflict_flag = 0;
    pkg2_algin_windows = 0;

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

    for i = 1:Pkg_length
        windows = G0((i-1)*dine+1 : i*dine);
        cor = abs(xcorr(windows, d_upchirp, dine, 'normalized'));
        cor = cor(dine+1:dine*2);
        if i <= 8
            pos = mod(pkg1_algin_windows, dine);
            reset_zoom = pos - dine*leakage_width1 : pos + dine*leakage_width1;
            reset_zoom(round(reset_zoom)<=0 ) = 1;
            cor(round(reset_zoom)) = 0;
        end
        for k = 1:1:dine
            if cor(k) > 0.3
                cor_array = zeros(1,8);
                for j = 0:7
                    windows = G0((i-1)*dine+k+dine*j : (i-1)*dine+k+dine*(j+1)-1);
                    cor_array(j+1) = abs(xcorr(windows, d_upchirp, 0, 'normalized'));
                end
                condition1 = find(cor_array > 0.3);
                if length(condition1) >= 7
                    pkg2_algin_windows_tmp = (i-1)*dine+k;
                    conflict_flag = 1;
                    break;
                end
            end
        end
        if conflict_flag == 1
            break;
        end
    end    
    % 在特定范围内找最大值
    if conflict_flag == 1
        cor_tmp = zeros(1,fix(dine*leakage_width1)+1);
        for i = 0:fix(dine*leakage_width1)
            windows = G0(pkg2_algin_windows_tmp+i : pkg2_algin_windows_tmp+dine+i-1);
            cor_tmp(i+1) = abs(xcorr(windows, d_upchirp, 0, 'normalized'));
        end
        [~, max_pos] = max(cor_tmp);
        pkg2_algin_windows = pkg2_algin_windows_tmp + max_pos - 1;
    end
    

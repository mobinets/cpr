function [pkg2_algin_windows, conflict_flag] = nscale_correlate_pkg2(G0, lora_set, pkg1_cor, cor_floor, pkg1_algin_windows)
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

    windows = G0(1:2*dine*(Pkg_length+Preamble_length));
    cor = abs(xcorr(windows, d_upchirp, dine*(Pkg_length+Preamble_length)));
    cor = cor(dine*(Pkg_length+Preamble_length)+1 : 2*dine*(Pkg_length+Preamble_length));
    % 将包1的cor值清零
    for j = 0:7
        reset_zoom = pkg1_algin_windows - dine*(leakage_width1-j) : pkg1_algin_windows + dine*(j+leakage_width1);
        reset_zoom(round(reset_zoom)<=0 ) = 1;
        cor(round(reset_zoom)) = 0;
    end
    for i = 1:1:dine*Pkg_length
        if cor(i) > cor_floor
            % continue_flag = 0;
            % for j = 0:7  % 先检查是否为包1的preamble
            %     if i >= pkg1_algin_windows - dine*(leakage_width1-j) && i <= pkg1_algin_windows + dine*(j+leakage_width1)
            %         continue_flag = 1;
            %         continue;
            %     end
            % end
            % if continue_flag == 1
            %     continue;
            % end

            % cor_array = zeros(1,8);
            % for k = 0:7  % 查看后7个窗口是否也存在类似的cor值
            %     cor_array(k+1) = abs(xcorr(G0(i+dine*k : i+dine*(k+1)), d_upchirp, 0));
            % end
            % min_pos = min([i+7*dine, length(cor)]);
            % cor_array = cor(i : dine : min_pos);

            cor_array = cor(i : dine : i+dine*7);
            % cor_array_tmp = abs(xcorr(G0(i : i+dine*8), d_upchirp, dine*8));
            % cor_array = cor_array_tmp(dine*8+1 : dine :dine*15+1);
            condition1 = find(cor_array > cor_floor);
            if length(condition1) == 8
                pkg2_algin_windows_tmp = i;
                conflict_flag = 1;
                break;
            end
        end
    end
    if conflict_flag == 1
        windows = G0(pkg2_algin_windows_tmp : fix(pkg2_algin_windows_tmp + dine*leakage_width1)+dine-1);
        cor_tmp = abs(xcorr(windows, d_upchirp, fix(dine*leakage_width1)));
        cor_tmp = cor_tmp(fix(dine*leakage_width1)+1:end);
        [~, max_pos] = max(cor_tmp);
        pkg2_algin_windows = i + max_pos - 1;
    end
    

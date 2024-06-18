function [peak_rate, G_processing, cfo] = Function_Single_Gateway_align_accuracy(G0, lora_set, Verification_path, offset)
    fclose all;
    leakage_width_array = [0.05,0.01,0.015,0.001];
    lora_set.filter_num = lora_set.Preamble_length*2 + 2;
    lora_set.leakage_width1 = leakage_width_array(lora_set.sf-6);
    lora_set.leakage_width2 = 1-lora_set.leakage_width1;
    if lora_set.sf == 7
        lora_set.filter_num = lora_set.Preamble_length*2 - 6;
    end

    % conflict_arg参数内容
    % 第1行：左边斜率
    % 第2行：右边斜率      
    % 第3行：左边斜线残值
    % 第4行：右边斜线残值
    % 第5行：峰值连续出现的窗口次数
    % 第6行：叠加后最高峰与窗口均值之比
    % 第7行：包2preamble的峰与窗口均值之比
    % 初始化输出参数
    conflict_flag = 0;                     % 判断冲突是否存在
    conflict_pos = 0;                      % 冲突发生的位置
    Pkg1_ture = 0;                         % 包1正确的数目
    Pkg2_ture = 0;                         % 包2正确的数目
    pkg2_pre_bin = 0;
    conflict_pos_tmp = 0;
    conflict_arg = zeros(1,7);

    % 根据已知的SF和BW信息来生成理想的upchirp和downchirp信号，用于解调（根据gr-lora的生成方式来实现的）
    [d_downchirp, d_upchirp] = build_idealchirp(lora_set);
    
    % 检测Preamble
    [Preamble_start_pos] = detect_preamble(G0, lora_set, d_downchirp);
    if Preamble_start_pos == 999
        disp("can't detect preamble!\n");
        return;
    elseif Preamble_start_pos ~= 1
        G0 = circshift(G0, -(Preamble_start_pos-1) * lora_set.dine);
    end
    
    % 计算主峰的cfo和winoff(需要补零操作)
    [cfo, windows_offset] = get_cfo_winoff(G0, lora_set, d_downchirp, d_upchirp);
    [d_downchirp_cfo, d_upchirp_cfo] = rebuild_idealchirp_cfo(lora_set, cfo);   % 重新调整理想upchirp和downchirp
    G0 = circshift(G0,-round(windows_offset));                                  % 对齐主峰窗口
    
    % 找到冲突发生的下一个窗口，获得峰值与噪声阈值的比
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    conflict_pos = ceil(offset / dine);
    pkg1_bin_array = [ones(1,8), 9, 17, 1, 1, load(Verification_path)'];
    pkg1_bin = pkg1_bin_array(conflict_pos + 1);
    if conflict_pos < 12
        pkg2_bin = fft_x - mod(offset, dine)/8;
        samples = G0(conflict_pos*dine+1 : (conflict_pos+1)*dine);
        samples_dechirp = samples .* d_downchirp_cfo;
        samples_fft = abs(fft(samples_dechirp,dine));
        samples_fft_merge = [samples_fft(1:fft_x/2) + samples_fft(dine-fft_x+1:dine-fft_x/2), samples_fft(dine-fft_x/2+1:dine) + samples_fft(fft_x/2+1:fft_x)];
        condition_1 = abs(pkg2_bin-[1:fft_x]) < fft_x*0.05;   % 找到fft_x*leakage_width1范围内的旁瓣
        condition_2 = abs(pkg2_bin-[1:fft_x]) > fft_x*0.95;
        peak = max(samples_fft_merge(condition_1 | condition_2));
        % fft_plot(samples_fft_merge, lora_set, 1);
        samples_fft_merge(condition_1 | condition_2) = 0;   
        condition_1 = abs(pkg1_bin-[1:fft_x]) < fft_x*0.05;   % 找到fft_x*leakage_width1范围内的旁瓣
        condition_2 = abs(pkg1_bin-[1:fft_x]) > fft_x*0.95; 
        samples_fft_merge(condition_1 | condition_2) = 0;   
        noise_threshold = max(samples_fft_merge);
%         tmp_index = samples_fft_merge > 0;
%         noise_threshold = mean(samples_fft_merge(tmp_index));
        peak_rate = peak/noise_threshold;
        % fft_plot(samples_fft_merge, lora_set, 1);
    else
        pkg2_bin = fft_x - mod(offset - dine*0.25, dine)/8;
        samples = G0(conflict_pos*dine+dine*0.25+1 : (conflict_pos+1.25)*dine);
        samples_dechirp = samples .* d_downchirp_cfo;
        samples_fft = abs(fft(samples_dechirp,dine));
        samples_fft_merge = [samples_fft(1:fft_x/2) + samples_fft(dine-fft_x+1:dine-fft_x/2), samples_fft(dine-fft_x/2+1:dine) + samples_fft(fft_x/2+1:fft_x)];
        condition_1 = abs(pkg2_bin-[1:fft_x]) < fft_x*0.05;   % 找到fft_x*leakage_width1范围内的旁瓣
        condition_2 = abs(pkg2_bin-[1:fft_x]) > fft_x*0.95;
        peak = max(samples_fft_merge(condition_1 | condition_2));
        % fft_plot(samples_fft_merge, lora_set, 1);
        samples_fft_merge(condition_1 | condition_2) = 0;   
        condition_1 = abs(pkg1_bin-[1:fft_x]) < fft_x*0.05;   % 找到fft_x*leakage_width1范围内的旁瓣
        condition_2 = abs(pkg1_bin-[1:fft_x]) > fft_x*0.95; 
        samples_fft_merge(condition_1 | condition_2) = 0;   
        noise_threshold = max(samples_fft_merge);
%         tmp_index = samples_fft_merge > 0;
%         noise_threshold = mean(samples_fft_merge(tmp_index));
        peak_rate = peak/noise_threshold;
        % fft_plot(samples_fft_merge, lora_set, 1);
    end

    % 记录为输出参数，用于多网关解码
    G_processing = G0;

    fclose all;
% 使用论文中提出的方法将冲突的LoRa信号分别解码，获得其bin值，并与正确的bin值对比得到正确率

function [Pkg1_ture, Pkg2_ture, conflict_pos_cal, conflict_pos, conflict_flag, pkg2_pre_bin, conflict_arg, G_processing, cfo, Peak_rate_full, G_noise] = Function_Single_Gateway_addnoise(G0, lora_set, Verification_path, SNR)
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
    Peak_rate_full = 0;
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

    % 粗对齐
    % [coarse_value] = coarse_align(G0, lora_set, d_downchirp);
    % G0 = circshift(G0, -coarse_value);
    % % 获得preamble的FFT峰值，用来作为寻找SFD的参考值
    % [preamble_amp_ref] = get_preamble_amp(G0, lora_set, d_downchirp);
    % % 找到downchirp
    % [SFD_pos] = detect_SFD(G0, lora_set, d_upchirp, preamble_amp_ref);
    
    % 计算主峰的cfo和winoff(需要补零操作)
    % [cfo, windows_offset] = get_cfo_win_tmp(G0, lora_set, d_downchirp, d_upchirp, SFD_pos);
    [cfo, windows_offset] = get_cfo_winoff(G0, lora_set, d_downchirp, d_upchirp);
    [d_downchirp_cfo, d_upchirp_cfo] = rebuild_idealchirp_cfo(lora_set, cfo);   % 重新调整理想upchirp和downchirp
    % 生成带噪声的原始信号
    amp_G0 = mean(abs(G0(abs(round(windows_offset))+1 : abs(round(windows_offset))+lora_set.dine)));
    amp_noise = amp_G0/10^(SNR/20);        % 计算噪声幅值均值
    noise = (amp_noise/sqrt(2) * randn([1 length(G0)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G0)]));
    G_noise = G0 + noise;

    G0 = circshift(G0, -round(windows_offset));                                  % 对齐主峰窗口
    % [pkg1_SFD_pos] = detect_SFD(G0, lora_set, d_upchirp_cfo, preamble_amp_ref);   % 获取完全对齐后SFD的位置
    
    % 发现冲突，并找到冲突开始的位置
    [conflict_flag, conflict_pos, pkg2_pre_bin, conflict_arg_tmp] = find_conflict(G0, lora_set, d_downchirp_cfo, 2);
    conflict_arg(1:6) = conflict_arg_tmp(1:6);
    [conflict_pos_tmp, conflict_pos_cal] = fix_conflict_pos(G0, lora_set, d_downchirp, conflict_pos, pkg2_pre_bin, Preamble_start_pos, windows_offset);
    if conflict_pos_tmp > lora_set.Pkg_length - 3 || conflict_pos_tmp < 2
        conflict_flag = 0;
        conflict_pos = 0;
    else
        conflict_pos = conflict_pos_tmp;
    end
    
    % 比较包1和包2的峰值强度,并获得峰值比
    if conflict_flag == 3   % 如果发现了冲突的话
        % 计算峰值比
        [Peak_rate_full, conflict_arg_tmp, Pkg2_Peak_ref] = get_peak_rate(G0, lora_set, d_downchirp_cfo, conflict_pos, pkg2_pre_bin);
        conflict_arg(7) = conflict_arg_tmp(7);
    end

    % 补零对齐包2窗口
    if conflict_flag == 3
        [Pkg2_winmobi] = algin_pkg2(G0, lora_set, d_downchirp_cfo, conflict_pos, pkg2_pre_bin);
        % 计算包2SFD的位置
        % [pkg2_SFD_pos] = detect_pkg2_SFD(G0, lora_set, d_upchirp_cfo, conflict_pos, Pkg2_winmobi);
        % % [SFD_pos] = detect_pkg2_SFD_cor(G0, lora_set, d_upchirp, preamble_amp_ref, conflict_pos, Pkg2_winmobi);
        % conflict_pos_tmp = ceil((pkg2_SFD_pos*lora_set.dine + Pkg2_winmobi + coarse_value + windows_offset)/lora_set.dine);
    end

    % time_plot(G0, lora_set, d_downchirp_cfo, 40);
    
    % 根据是否冲突解码包1和包2的bin
    if conflict_flag == 3
        % 获得FFT矩阵
        [Pkg1_samples_fft_merge, Pkg2_samples_fft_merge] = get_fft(G0, lora_set, d_downchirp_cfo, d_upchirp_cfo, conflict_pos, Pkg2_winmobi);
%         fft_plot(Pkg2_samples_fft_merge, lora_set, 30);
        % 获得两个包的bin
        [Pkg1_bin, Pkg2_bin] = get_bin(lora_set, Pkg1_samples_fft_merge, Pkg2_samples_fft_merge, Peak_rate_full, conflict_pos, pkg2_pre_bin);
    else    % 没有发现冲突
        [Pkg1_bin] = get_bin_single(G0, lora_set, d_downchirp_cfo, d_upchirp_cfo);
    end

    % 根据是否冲突判断包1和包2的正确率
    if conflict_flag == 3
        [Pkg1_ture, Pkg2_ture] = get_accuracy(lora_set, Pkg1_bin, Pkg2_bin, Verification_path);
    else
        [Pkg1_ture] = get_accuracy_single(lora_set, Pkg1_bin, Verification_path);
    end
    % 记录为输出参数，用于多网关解码

    G_processing = G0 + noise;

    fclose all;
function [Pkg1_ture, Pkg2_ture, conflict_arg, conflict_pos, pkg2_pre_bin] = Function_Multi_Gateway_addGW(G_processing, lora_set, CFO, Verification_path)
    fclose all;
    leakage_width_array = [0.05,0.01,0.015,0.001];
    lora_set.filter_num = lora_set.Preamble_length*2 + 2;
    lora_set.leakage_width1 = leakage_width_array(lora_set.sf-6);
    lora_set.leakage_width2 = 1-lora_set.leakage_width1;
    if lora_set.sf == 7
        lora_set.filter_num = lora_set.Preamble_length*2 - 6;
    end
    GW_num = size(G_processing,1);      % 读取输入信号采样值的行数

    % 初始化输出参数
    % conflict_flag = 3;                     % 判断冲突是否存在
    Pkg1_ture = 0;                         % 包1正确的数目
    Pkg2_ture = 0;                         % 包2正确的数目
    conflict_arg = zeros(1,7);

    % 生成处理CFO的idealchirp
    [d_downchirp_cfo_array, d_upchirp_cfo_array] = rebuild_idealchirp_cfo_multi(lora_set, CFO, GW_num);
    
    % 获取归一化参数
    [snr_rate_array] = normalize_fft(G_processing, lora_set, d_downchirp_cfo_array);

    % 发现冲突
    [conflict_flag, conflict_pos, pkg2_pre_bin, conflict_arg_tmp] = find_conflict_multi(G_processing, lora_set, d_downchirp_cfo_array, d_upchirp_cfo_array, snr_rate_array);
    conflict_arg(1:6) = conflict_arg_tmp(1:6);

    % 比较包1和包2的峰值强度,并获得峰值比
    if conflict_flag == 3   % 如果发现了冲突的话
        [Peak_rate_full, conflict_arg_tmp] = get_peak_rate_multi(G_processing, lora_set, d_downchirp_cfo_array, d_upchirp_cfo_array, conflict_pos, pkg2_pre_bin, snr_rate_array);
        conflict_arg(7) = conflict_arg_tmp(7);
    end

     % 补零对齐包2窗口
     if conflict_flag == 3
        [Pkg2_winmobi] = align_pkg2_multi(G_processing, lora_set, d_downchirp_cfo_array, d_upchirp_cfo_array, conflict_pos, pkg2_pre_bin, snr_rate_array);
    end

    if conflict_flag == 3
        [Pkg1_samples_fft_merge, Pkg2_samples_fft_merge] = get_fft_multi(G_processing, lora_set, d_downchirp_cfo_array, d_upchirp_cfo_array, conflict_pos, Pkg2_winmobi, snr_rate_array);
        % [Pkg1_bin, Pkg2_bin] = get_bin_multi(lora_set, Pkg1_samples_fft_merge, Pkg2_samples_fft_merge, Peak_rate_full, conflict_pos, pkg2_pre_bin);
        [Pkg1_bin, Pkg2_bin] = get_bin(lora_set, Pkg1_samples_fft_merge, Pkg2_samples_fft_merge, Peak_rate_full, conflict_pos, pkg2_pre_bin);
    else    % 没有发现冲突
        [Pkg1_bin] = get_bin_single_multi(G_processing, lora_set, d_downchirp_cfo_array, d_upchirp_cfo_array, snr_rate_array);
    end

    % 根据是否冲突判断包1和包2的正确率
    if conflict_flag == 3
        [Pkg1_ture, Pkg2_ture] = get_accuracy(lora_set, Pkg1_bin, Pkg2_bin, Verification_path);
    else
        [Pkg1_ture] = get_accuracy_single(lora_set, Pkg1_bin, Verification_path);
    end

    fclose all;
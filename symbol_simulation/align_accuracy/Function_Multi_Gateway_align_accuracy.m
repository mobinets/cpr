function [peak_rate] = Function_Multi_Gateway_align_accuracy(G_processing, lora_set, CFO, Verification_path, offset)
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
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    conflict_pos = ceil(offset / dine);
    pkg1_bin_array = [ones(1,8), 9, 17, 1, 1, load(Verification_path)'];
    pkg1_bin = pkg1_bin_array(conflict_pos + 1);
    if conflict_pos < 12
        pkg2_bin = fft_x - mod(offset, dine)/8;
        GW_num = size(G_processing,1);      % 读取输入信号采样值的行数
        samples_fft_merge = zeros(0);      % 保存冲突发现所需要的FFT
        for GW_count = 1:GW_num
            d_downchirp_cfo = d_downchirp_cfo_array(GW_count, :);
            d_upchirp_cfo = d_upchirp_cfo_array(GW_count, :);
            samples = G_processing(GW_count, conflict_pos*dine+1 : (conflict_pos+1)*dine);
            samples_dechirp = samples .* d_downchirp_cfo;
            samples_fft = abs(fft(samples_dechirp,dine));
            samples_fft_merge_tmp = [samples_fft(1:fft_x/2) + samples_fft(dine-fft_x+1:dine-fft_x/2), samples_fft(dine-fft_x/2+1:dine)+samples_fft(fft_x/2+1:fft_x)];
            samples_fft_merge_tmp = normalize(samples_fft_merge_tmp, 2, 'range');
            if GW_count == 1
                samples_fft_merge = samples_fft_merge_tmp .* snr_rate_array(GW_count);
            else
                samples_fft_merge = samples_fft_merge + samples_fft_merge_tmp .* snr_rate_array(GW_count);
            end
        end
        condition_1 = abs(pkg2_bin-[1:fft_x]) < fft_x*0.05;   % 找到fft_x*leakage_width1范围内的旁瓣
        condition_2 = abs(pkg2_bin-[1:fft_x]) > fft_x*0.95;
        peak = max(samples_fft_merge(condition_1 | condition_2));
        % fft_plot(samples_fft_merge, lora_set, 1);
        samples_fft_merge(condition_1 | condition_2) = 0;   
        condition_1 = abs(pkg1_bin-[1:fft_x]) < fft_x*0.05;   % 找到fft_x*leakage_width1范围内的旁瓣
        condition_2 = abs(pkg1_bin-[1:fft_x]) > fft_x*0.95; 
        samples_fft_merge(condition_1 | condition_2) = 0;   
        noise_threshold = max(samples_fft_merge);
        peak_rate = peak/noise_threshold;
        % fft_plot(samples_fft_merge, lora_set, 1);
    else
        pkg2_bin = fft_x - mod(offset - dine*0.25, dine)/8;
        GW_num = size(G_processing,1);      % 读取输入信号采样值的行数
        samples_fft_merge = zeros(0);      % 保存冲突发现所需要的FFT
        for GW_count = 1:GW_num
            d_downchirp_cfo = d_downchirp_cfo_array(GW_count, :);
            d_upchirp_cfo = d_upchirp_cfo_array(GW_count, :);
            samples = G_processing(GW_count, conflict_pos*dine+dine*0.25+1 : (conflict_pos+1.25)*dine);
            samples_dechirp = samples .* d_downchirp_cfo;
            samples_fft = abs(fft(samples_dechirp,dine));
            samples_fft_merge_tmp = [samples_fft(1:fft_x/2) + samples_fft(dine-fft_x+1:dine-fft_x/2), samples_fft(dine-fft_x/2+1:dine)+samples_fft(fft_x/2+1:fft_x)];
            samples_fft_merge_tmp = normalize(samples_fft_merge_tmp, 2, 'range');
            if GW_count == 1
                samples_fft_merge = samples_fft_merge_tmp .* snr_rate_array(GW_count);
            else
                samples_fft_merge = samples_fft_merge + samples_fft_merge_tmp .* snr_rate_array(GW_count);
            end
        end
        condition_1 = abs(pkg2_bin-[1:fft_x]) < fft_x*0.05;   % 找到fft_x*leakage_width1范围内的旁瓣
        condition_2 = abs(pkg2_bin-[1:fft_x]) > fft_x*0.95;
        peak = max(samples_fft_merge(condition_1 | condition_2));
        % fft_plot(samples_fft_merge, lora_set, 1);
        samples_fft_merge(condition_1 | condition_2) = 0;   
        condition_1 = abs(pkg1_bin-[1:fft_x]) < fft_x*0.05;   % 找到fft_x*leakage_width1范围内的旁瓣
        condition_2 = abs(pkg1_bin-[1:fft_x]) > fft_x*0.95; 
        samples_fft_merge(condition_1 | condition_2) = 0;   
        noise_threshold = max(samples_fft_merge);
        peak_rate = peak/noise_threshold;
        % fft_plot(samples_fft_merge, lora_set, 1);
    end

    fclose all;
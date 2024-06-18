function [snr_rate_array] = normalize_fft(G_processing, lora_set, d_downchirp_cfo_array)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;

    GW_num = size(G_processing,1);      % 读取输入信号采样值的行数
    for GW_count = 1:GW_num
        d_downchirp_cfo = d_downchirp_cfo_array(GW_count, :);
        G0 = G_processing(GW_count,1:dine);
        conflict_dechirp = G0 .* d_downchirp_cfo;
        conflict_fft = abs(fft(conflict_dechirp,dine));
        conflict_fft_merge_tmp = [conflict_fft(:,1:fft_x/2) + conflict_fft(:,dine-fft_x+1:dine-fft_x/2), conflict_fft(:,dine-fft_x/2+1:dine)+conflict_fft(:,fft_x/2+1:fft_x)];
        max_value = max(conflict_fft_merge_tmp);
        snr_rate_array(GW_count) = max_value / (sum(conflict_fft_merge_tmp) - max_value);
    end
    snr_rate_array = snr_rate_array ./ sum(snr_rate_array);
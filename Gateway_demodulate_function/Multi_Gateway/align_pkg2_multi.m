function [Pkg2_winmobi] = align_pkg2_multi(G_processing, lora_set, d_downchirp_cfo_array, d_upchirp_cfo_array, conflict_pos, pkg2_pre_bin, snr_rate_array)
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    GW_num = size(G_processing,1);      % 读取输入信号采样值的行数
    zeropadding_size = 8;

    Pkg2_samples_align_fft_merge = zeros(0);
    for GW_count = 1:GW_num
        d_downchirp_cfo = d_downchirp_cfo_array(GW_count, :);
        d_upchirp_cfo = d_upchirp_cfo_array(GW_count, :);

        G0 = G_processing(GW_count,:);
        Pkg2_samples_align = G0(conflict_pos*dine+1:(conflict_pos+1)*dine);
        Pkg2_samples_align_fft = abs(fft(Pkg2_samples_align .* d_downchirp_cfo, dine*zeropadding_size, 2));
        Pkg2_samples_align_fft_merge_tmp = [Pkg2_samples_align_fft(1:dine/2) + Pkg2_samples_align_fft(dine*(zeropadding_size-1)+1:dine*(zeropadding_size-0.5)), ...
            Pkg2_samples_align_fft(dine*(zeropadding_size-0.5)+1:dine*zeropadding_size) + Pkg2_samples_align_fft(dine/2+1:dine)];
        Pkg2_samples_align_fft_merge_tmp = normalize(Pkg2_samples_align_fft_merge_tmp, 2, 'range');
        if GW_count == 1
            Pkg2_samples_align_fft_merge = Pkg2_samples_align_fft_merge_tmp .* snr_rate_array(GW_count);
        else
            Pkg2_samples_align_fft_merge = Pkg2_samples_align_fft_merge + Pkg2_samples_align_fft_merge_tmp .* snr_rate_array(GW_count);
        end
    end
    [~,Pkg2_bin_ac] = max(Pkg2_samples_align_fft_merge(max(1,pkg2_pre_bin*zeropadding_size-16):min(dine,pkg2_pre_bin*zeropadding_size)));
    Pkg2_winmobi = dine - (pkg2_pre_bin*zeropadding_size-16+Pkg2_bin_ac-2);
function [Peak_rate_full, conflict_arg] = get_peak_rate_multi(G_processing, lora_set, d_downchirp_cfo_array, d_upchirp_cfo_array, conflict_pos, pkg2_pre_bin, snr_rate_array)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    leakage_width1 = lora_set.leakage_width1;
    leakage_width2 = lora_set.leakage_width2;
    GW_num = size(G_processing,1);      % 读取输入信号采样值的行数

    Pkg_fft_merge = zeros(0);
    for GW_count = 1:GW_num
        d_downchirp_cfo = d_downchirp_cfo_array(GW_count, :);
        d_upchirp_cfo = d_upchirp_cfo_array(GW_count, :);

        G0 = G_processing(GW_count,:);
        Pkg_samples = [reshape(G0(dine+1:2*dine),[dine,1]).'; reshape(G0(conflict_pos*dine+1:(conflict_pos+1)*dine),[dine,1]).'];
        Pkg_dechirp = Pkg_samples .* d_downchirp_cfo;
        Pkg_fft = abs(fft(Pkg_dechirp,dine,2));
        Pkg_fft_merge_tmp = [Pkg_fft(:,1:fft_x/2)+Pkg_fft(:,dine-fft_x+1:dine-fft_x/2), Pkg_fft(:,dine-fft_x/2+1:dine)+Pkg_fft(:,fft_x/2+1:fft_x)];
        % Pkg_fft_merge_tmp = normalize(Pkg_fft_merge_tmp, 2, 'range');
        if GW_count == 1
            Pkg_fft_merge = Pkg_fft_merge_tmp;  % .* snr_rate_array(GW_count);
        else
            Pkg_fft_merge = Pkg_fft_merge + Pkg_fft_merge_tmp;  % .* snr_rate_array(GW_count);
        end
    end
    Pkg1_Peak = max([Pkg_fft_merge(1,1:fix(fft_x*0.05)), Pkg_fft_merge(1,fix(fft_x*0.95):fft_x)]);
    Pkg2_Peak = max(Pkg_fft_merge(2,max(1,pkg2_pre_bin-2): min(pkg2_pre_bin+2,fft_x)));
    Peak_rate_full = Pkg1_Peak / Pkg2_Peak;                 % 窗口全覆盖下，包1和包2的峰值比
    conflict_arg(7) = Pkg2_Peak/mean(Pkg_fft_merge(2,:));  % 获得包2的窗口FFT的均值比
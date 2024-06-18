function [Pkg1_samples_fft_merge, Pkg2_samples_fft_merge] = get_fft_multi(G_processing, lora_set, d_downchirp_cfo_array, d_upchirp_cfo_array, conflict_pos, Pkg2_winmobi, snr_rate_array)
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Pkg_length = lora_set.Pkg_length;
    Preamble_length = lora_set.Preamble_length;
    GW_num = size(G_processing,1);      % 读取输入信号采样值的行数
    
    % 对齐包1，获得包1的bin
    Pkg1_samples_fft_merge = zeros(0);
    for GW_count = 1:GW_num
        d_downchirp_cfo = d_downchirp_cfo_array(GW_count, :);
        d_upchirp_cfo = d_upchirp_cfo_array(GW_count, :);

        G0 = G_processing(GW_count,:);
        Pkg1_samples_pre = reshape(G0(1:(Preamble_length+4)*dine),[dine,Preamble_length+4]).';
        Pkg1_samples_pay = reshape(G0((Preamble_length+4)*dine+dine*0.25+1:(Pkg_length+Preamble_length+4)*dine+dine*0.25),[dine,Pkg_length]).';
        Pkg1_samples = [Pkg1_samples_pre; Pkg1_samples_pay];
        dechirp = [repmat(d_downchirp_cfo,Preamble_length+2,1);repmat(d_upchirp_cfo,2,1);repmat(d_downchirp_cfo, Pkg_length, 1)];
        Pkg1_samples_dechirp = Pkg1_samples .* dechirp;
        Pkg1_samples_fft = abs(fft(Pkg1_samples_dechirp,dine,2));
        Pkg1_samples_fft_merge_tmp = [Pkg1_samples_fft(:,1:fft_x/2) + Pkg1_samples_fft(:,dine-fft_x+1:dine-fft_x/2), Pkg1_samples_fft(:,dine-fft_x/2+1:dine)+Pkg1_samples_fft(:,fft_x/2+1:fft_x)];
        Pkg1_samples_fft_merge_tmp = normalize(Pkg1_samples_fft_merge_tmp, 2, 'range');
        if GW_count == 1
            Pkg1_samples_fft_merge = Pkg1_samples_fft_merge_tmp .* snr_rate_array(GW_count);
        else
            Pkg1_samples_fft_merge = Pkg1_samples_fft_merge + Pkg1_samples_fft_merge_tmp .* snr_rate_array(GW_count);
        end
    end

    Pkg2_samples_fft_merge = zeros(0);
    for GW_count = 1:GW_num
        d_downchirp_cfo = d_downchirp_cfo_array(GW_count, :);
        d_upchirp_cfo = d_upchirp_cfo_array(GW_count, :);

        G0 = G_processing(GW_count,:);
        Pkg2_samples_pre = reshape(G0((conflict_pos-1)*dine+Pkg2_winmobi+1:(conflict_pos+Preamble_length+3)*dine+Pkg2_winmobi),[dine,Preamble_length+4]).';
        Pkg2_samples_pay = reshape(G0((conflict_pos+Preamble_length+3)*dine+dine*0.25+Pkg2_winmobi+1:(conflict_pos+Pkg_length+Preamble_length+3)*dine+dine*0.25+Pkg2_winmobi),[dine,Pkg_length]).';
        Pkg2_samples = [Pkg2_samples_pre; Pkg2_samples_pay];
        dechirp = [repmat(d_downchirp_cfo,Preamble_length+2,1);repmat(d_upchirp_cfo,2,1);repmat(d_downchirp_cfo,Pkg_length,1)];
        Pkg2_samples_dechirp = Pkg2_samples .* dechirp;
        Pkg2_samples_fft = abs(fft(Pkg2_samples_dechirp,dine,2));
        Pkg2_samples_fft_merge_tmp = [Pkg2_samples_fft(:,1:fft_x/2) + Pkg2_samples_fft(:,dine-fft_x+1:dine-fft_x/2), Pkg2_samples_fft(:,dine-fft_x/2+1:dine)+Pkg2_samples_fft(:,fft_x/2+1:fft_x)];
        Pkg2_samples_fft_merge_tmp = normalize(Pkg2_samples_fft_merge_tmp, 2, 'range');
        if GW_count == 1
            Pkg2_samples_fft_merge = Pkg2_samples_fft_merge_tmp .* snr_rate_array(GW_count);
        else
            Pkg2_samples_fft_merge = Pkg2_samples_fft_merge + Pkg2_samples_fft_merge_tmp .* snr_rate_array(GW_count);
        end
    end
function [correct] = nscale_correct(G0, lora_set, cfo)
    d_sf = lora_set.sf;
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Preamble_length = lora_set.Preamble_length;
    leakage_width1 = lora_set.leakage_width1;
    leakage_width2 = lora_set.leakage_width2;
    correct = 0;
    
    cmx = 1+1*1i;
    pre_dir = 2*pi;
    f0 = d_bw/2;                           % 设置理想upchirp和downchirp的初始频率
    d_symbols_per_second = d_bw / fft_x; 
    T = -0.5 * d_bw * d_symbols_per_second;  
    d_samples_per_second = 1000000;        % sdr-rtl的采样率
    d_dt = 1/d_samples_per_second;         % 采样点间间隔的时间
    t = d_dt*(0:1:dine-1);
    f0 = lora_set.bw/2+cfo;                % downchirp和upchirp收到CFO的影响是相反的，所以要重新设置两个的初始频率
    f1 = lora_set.bw/2-cfo;

    % 计算理想downchirp和upchirp存入d_downchirp和d_upchirp数组中（复数形式）
    d_downchirp_cfo = cmx * (cos(pre_dir .* t .* (f0 + T * t)) + sin(pre_dir .* t .* (f0 + T * t))*1i);
    d_upchirp_cfo = cmx * (cos(pre_dir .* t .* (f1 + T * t) * -1) + sin(pre_dir .* t .* (f1 + T * t) * -1)*1i);

    samples = reshape(G0(1:Preamble_length*dine),[dine,Preamble_length]).';
    samples_dechirp = samples .* d_downchirp_cfo;
    samples_fft = abs(fft(samples_dechirp,dine,2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    samples_fft_merge_tmp = samples_fft_merge;
    samples_fft_merge_tmp(:, fix(fft_x*leakage_width1) : fix(leakage_width2*fft_x)) = 0;
    [~, max_pos] = max(samples_fft_merge_tmp, [], 2);
    preamble_bin = mode(max_pos);

    if preamble_bin ~= 1   % need to correct
        if preamble_bin > fft_x * 0.5
            correct = (fft_x + 1 - preamble_bin) * 8;
        else
            correct = (1 - preamble_bin) * 8;
        end
    end
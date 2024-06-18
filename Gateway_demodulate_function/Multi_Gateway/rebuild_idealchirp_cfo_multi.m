function [d_downchirp_cfo_array, d_upchirp_cfo_array] = rebuild_idealchirp_cfo_multi(lora_set, CFO, GW_num)
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    d_downchirp_cfo_array = zeros(GW_num, dine);
    d_upchirp_cfo_array = zeros(GW_num, dine);
    
    cmx = 1+1*1i;
    pre_dir = 2*pi;
    f0 = d_bw/2;                           % 设置理想upchirp和downchirp的初始频率
    d_symbols_per_second = d_bw / fft_x; 
    T = -0.5*d_bw*d_symbols_per_second;  
    d_samples_per_second = 1000000;        % sdr-rtl的采样率
    d_dt = 1/d_samples_per_second;         % 采样点间间隔的时间
    t = d_dt*(0:1:dine-1);

    for GW_count = 1:GW_num
        f1 = d_bw/2+CFO(GW_count);                      % downchirp和upchirp收到CFO的影响是相反的，所以要重新设置两个的初始频率
        f2 = d_bw/2-CFO(GW_count);
        d_downchirp_cfo_array(GW_count,:) = cmx * (cos(pre_dir .* t .* (f1 + T * t)) + sin(pre_dir .* t .* (f1 + T * t))*1i);
        d_upchirp_cfo_array(GW_count,:) = cmx * (cos(pre_dir .* t .* (f2 + T * t) * -1) + sin(pre_dir .* t .* (f2 + T * t) * -1)*1i);
    end
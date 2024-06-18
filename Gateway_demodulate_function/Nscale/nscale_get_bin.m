function [pkg_bin] = nscale_get_bin(G0, lora_set, cfo, scale_factor_mean)
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Pkg_length = lora_set.Pkg_length;
    filter_num = lora_set.filter_num;
    leakage_width1 = lora_set.leakage_width1;
    leakage_width2 = lora_set.leakage_width2;
    Preamble_length = lora_set.Preamble_length;

    cmx = 1+1*1i;
    pre_dir = 2*pi;
    f0 = d_bw/2;                           % 设置理想upchirp和downchirp的初始频率
    d_symbols_per_second = d_bw / fft_x; 
    T = -0.5 * d_bw * d_symbols_per_second;  
    d_samples_per_second = 1000000;        % sdr-rtl的采样率
    d_dt = 1/d_samples_per_second;         % 采样点间间隔的时间
    t = d_dt*(0:1:dine-1);
    f0 = lora_set.bw/2+cfo;                      % downchirp和upchirp收到CFO的影响是相反的，所以要重新设置两个的初始频率
    f1 = lora_set.bw/2-cfo;
    scale_factor = 1+0.4/sqrt(2) : 0.4/sqrt(2) : 1+(0.4/sqrt(2))*dine;

    % 计算理想downchirp和upchirp存入d_downchirp和d_upchirp数组中（复数形式）
    d_downchirp_cfo = cmx * (cos(pre_dir .* t .* (f0 + T * t)) + sin(pre_dir .* t .* (f0 + T * t))*1i);
    d_upchirp_cfo = cmx * (cos(pre_dir .* t .* (f1 + T * t) * -1) + sin(pre_dir .* t .* (f1 + T * t) * -1)*1i);
    d_downchirp_nscale = d_downchirp_cfo .* scale_factor;
    d_upchirp_nscale = d_upchirp_cfo .* scale_factor;

    samples = reshape(G0((Preamble_length+4.25)*dine+1 : (Pkg_length+0.25)*dine),[dine,Pkg_length-Preamble_length-4]).';
    samples_dechirp = samples .* d_downchirp_cfo;
    samples_fft = abs(fft(samples_dechirp,dine,2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    [peak,pos] = sort(samples_fft_merge,2,'descend');         % 对FFT进行排序
    Peak1_pos = zeros(size(pos,1),filter_num);
    Peak1_amp = zeros(size(peak,1),filter_num);
    Peak1_pos(:,1) = pos(:,1);
    Peak1_amp(:,1) = peak(:,1);
    for row = 1:size(pos,1)
        temp_array = ones(1,size(pos,2));
        for list = 1:filter_num
            temp_array = temp_array & (abs(Peak1_pos(row,list) - pos(row,:)) > fft_x*leakage_width1 & abs(Peak1_pos(row,list) - pos(row,:)) < fft_x*leakage_width2);
            temp_num = find(temp_array==1,1,'first');
            Peak1_pos(row,list+1) = pos(row,temp_num);
            Peak1_amp(row,list+1) = peak(row,temp_num);
        end
    end
    
%     fft_plot(samples_fft_merge, lora_set, 20);

    samples = reshape(G0((Preamble_length+4.25)*dine+1 : (Pkg_length+0.25)*dine),[dine,Pkg_length-Preamble_length-4]).';
    samples_dechirp = samples .* d_downchirp_nscale;
    samples_fft = abs(fft(samples_dechirp,dine,2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    nscale_factor = zeros(Pkg_length-Preamble_length-4, size(Peak1_pos, 2));
    for windows = 1 : size(Peak1_pos, 1)
        for bin = 1 : size(Peak1_pos, 2)
            nscale_factor(windows, bin) = samples_fft_merge(windows, Peak1_pos(windows, bin)) / Peak1_amp(windows, bin);
        end
    end
    nscale_factor = abs(nscale_factor - scale_factor_mean);
    [~, min_pos] = min(nscale_factor, [], 2);
    pkg_bin = zeros(1,length(min_pos));
    for windows = 1:length(min_pos)
        pkg_bin(windows) = Peak1_pos(windows, min_pos(windows));
    end
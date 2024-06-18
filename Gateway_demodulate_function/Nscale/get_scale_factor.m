function [scale_factor_mean, scale_factor_var] = get_scale_factor(G0, lora_set, cfo)
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
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

    samples = reshape(G0(1:Preamble_length*dine),[dine,Preamble_length]).';
    samples_dechirp = samples .* d_downchirp_cfo;
    samples_fft = abs(fft(samples_dechirp,dine,2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    samples_fft_merge_tmp = samples_fft_merge;
    samples_fft_merge_tmp(:, fix(fft_x*leakage_width1) : fix(leakage_width2*fft_x)) = 0;
    [ideal_fft, ideal_fft_pos] = max(samples_fft_merge_tmp, [], 2);
    
    samples = reshape(G0(1:Preamble_length*dine),[dine,Preamble_length]).';
    samples_dechirp = samples .* d_downchirp_nscale;
    samples_fft = abs(fft(samples_dechirp,dine,2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    % scale_fft = max([samples_fft_merge(:,1:fix(fft_x*leakage_width1)), samples_fft_merge(:,fix(leakage_width2*fft_x:fft_x))],[],2);
    scale_fft = zeros(1, length(ideal_fft_pos));
    for i = 1 : length(ideal_fft_pos)
        scale_fft(i) = samples_fft_merge(i, ideal_fft_pos(i));
    end
    scale_factor = scale_fft ./ ideal_fft';
    scale_factor_var = var(scale_factor);  scale_factor_mean = mean(scale_factor);
    i = 1;
    % nscale_factor = zeros(Preamble_length, size(Peak1_pos, 2));
    % for windows = 1 : Preamble_length
    %     for bin = 1 : size(Peak1_pos, 2)
    %         nscale_factor(windows, bin) = samples_fft_merge(windows, Peak1_pos(windows, bin)) / Peak1_amp(windows, bin);
    %     end
    % end
    % i = 1;

    % 用理想downchirp作dechirp得到FFT的值
    % % 用nscale downchirp作dechirp得到FFT的值
    % samples = reshape(G0(1:Preamble_length*dine),[dine,Preamble_length]).';
    % samples_dechirp = samples .* d_downchirp_nscale;
    % samples_fft = abs(fft(samples_dechirp,dine,2));
    % samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    % [peak_nscale,pos_nscale] = sort(samples_fft_merge,2,'descend');         % 对FFT进行排序
    % Peak1_pos_nscale = zeros(size(pos_nscale,1),filter_num);
    % Peak1_amp_nscale = zeros(size(peak_nscale,1),filter_num);
    % Peak1_pos_nscale(:,1) = pos_nscale(:,1);
    % Peak1_amp_nscale(:,1) = peak_nscale(:,1);
    % for row = 1:size(pos_nscale,1)
    %     temp_array = ones(1,size(pos_nscale,2));
    %     for list = 1:filter_num
    %         temp_array = temp_array & (abs(Peak1_pos_nscale(row,list) - pos_nscale(row,:)) > fft_x*leakage_width1 & abs(Peak1_pos_nscale(row,list) - pos_nscale(row,:)) < fft_x*leakage_width2);
    %         temp_num = find(temp_array==1,1,'first');
    %         Peak1_pos_nscale(row,list+1) = pos_nscale(row,temp_num);
    %         Peak1_amp_nscale(row,list+1) = peak_nscale(row,temp_num);
    %     end
    % end
    % i = 1;
    
    



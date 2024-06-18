function [Preamble_start_pos] = detect_preamble(G0, lora_set, idealchirp)
    % 检测Preamble
    % 获取Preamble，dechirp，计算FFT并合并FFT
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Preamble_length = lora_set.Preamble_length;
    samples = reshape(G0(1:Preamble_length*2*dine), [dine, Preamble_length*2]).';
    samples_dechirp = samples .* idealchirp;
    samples_fft = abs(fft(samples_dechirp, dine, 2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    
    [fft_amp_max,fft_pos_max] = max(samples_fft_merge,[],2);    % 获得FFT中的主峰的峰值强度和位置
    % 找到Preamble开始位置，如果不等于1，要将窗口位移
    Preamble_start_pos = find((fft_amp_max > 3*mean(samples_fft_merge,2)) == 1,1,'first');
    if Preamble_start_pos == []
        fprintf("Can't detect preamble!\n");
        Preamble_start_pos = 999;
        return;
    end

    % 测试(测试完后要删去)
    samples_fft_tmp = fft(samples_dechirp, dine, 2);
    [amp_tmp,pos_tmp] = max(samples_fft_tmp,[],2);
    i = 1;

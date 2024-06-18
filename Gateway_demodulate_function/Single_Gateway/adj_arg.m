% 使用论文中提出的方法将冲突的LoRa信号分别解码，获得其bin值，并与正确的bin值对比得到正确率

function [conflict_arg] = adj_arg(G0, cfo, lora_set, con_pos, pkg2_bin)
    leakage_width_array = [0.05,0.01,0.015,0.001];
    lora_set.filter_num = lora_set.Preamble_length*2 + 2;
    lora_set.leakage_width1 = leakage_width_array(lora_set.sf-6);
    lora_set.leakage_width2 = 1-lora_set.leakage_width1;
    if lora_set.sf == 7
        lora_set.filter_num = lora_set.Preamble_length*2 - 6;
    end
    
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Pkg_length = lora_set.Pkg_length;
    Preamble_length = lora_set.Preamble_length;
    % conflict_arg参数内容
    % 第1行：左边斜率
    % 第2行：右边斜率      
    % 第3行：左边斜线残值
    % 第4行：右边斜线残值
    
    [d_downchirp_cfo, d_upchirp_cfo] = rebuild_idealchirp_cfo(lora_set, cfo);   % 重新调整理想upchirp和downchirp
    
    % 叠加连续FFT窗口，获取冲突发现参数
    conflict_samples = reshape(G0(1:Pkg_length*2*dine),[dine,Pkg_length*2]).';
    conflict_dechirp = conflict_samples .* d_downchirp_cfo;
    conflict_fft = abs(fft(conflict_dechirp,dine,2));
    conflict_fft_merge = [conflict_fft(:,1:fft_x/2) + conflict_fft(:,dine-fft_x+1:dine-fft_x/2), conflict_fft(:,dine-fft_x/2+1:dine)+conflict_fft(:,fft_x/2+1:fft_x)];
    % 叠加FFT窗口
    conflict_superimpose = [zeros(Preamble_length-1,size(conflict_fft_merge,2));conflict_fft_merge;zeros(Preamble_length-1,size(conflict_fft_merge,2))]; % 设置储存叠加FFT后
    for i = 1:size(conflict_superimpose,1)-(Preamble_length-1)      % 移动叠加窗口，一直到倒数第八个窗口
        for j = 1:Preamble_length-1                                 % 叠加8个窗口，记录在原数组中
            conflict_superimpose(i,:) = conflict_superimpose(i,:) + conflict_superimpose(i+j,:);
        end
    end
    peak_array = conflict_superimpose(con_pos:con_pos+(Preamble_length-1)*2, pkg2_bin);
    x_1 = 1:8;
    x_2 = 8:15;
    p_1 = polyfit(x_1,peak_array(x_1),1);
    p_2 = polyfit(x_2,peak_array(x_2),1);
    residual_1 = sum(abs(peak_array(x_1)' - polyval(p_1,x_1)))/length(x_1);
    residual_2 = sum(abs(peak_array(x_2)' - polyval(p_2,x_2)))/length(x_2);
    conflict_arg = [p_1(1), p_2(1), residual_1, residual_2];

    fclose all;
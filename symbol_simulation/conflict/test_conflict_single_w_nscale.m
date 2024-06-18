fclose all;     %关闭所有matlab打开的文件
tic;            % 打开计时器

% sf_array = ["sf7", "sf8", "sf9", "sf10"];
% sir_array = ["sir_5", "sir0", "sir5"];
sf_array = ["sf10"];
sir_array = ["sir5"];
for SF_count = 1:length(sf_array)
    file_name = strcat('node1_', sf_array(SF_count));
    Verification_name = strcat(file_name, '.txt');
    setting_name = strcat(file_name, '.json');

    Config_Path = '.\config\';                                       % 设置配置文件所在路径
    Verification_path = strcat(Config_Path, Verification_name);        % bin值验证文件
    Setting_File = dir(fullfile(Config_Path, setting_name));     % 配置文件
    Setting_File_Path = strcat(Config_Path, Setting_File.name);
    Setting_file = fopen(Setting_File_Path,'r');
    setting = jsondecode(fscanf(Setting_file,'%s'));                % 解析json格式变量
    lora_set.bw = setting.captures.lora_bw;                         % 设置接收数据包的lora_set.bw
    lora_set.sf = setting.captures.lora_sf;                                  % 设置接收数据包的lora_set.sf
    lora_set.sample_rate = setting.global.core_sample_rate;                  % 设置接收数据包的采样率
    lora_set.Pkg_length = setting.captures.lora_pkg_length;                  % 设置接收数据包的长度
    lora_set.dine = 1000000*bitshift(1,lora_set.sf)/lora_set.bw;                               % 根据lora_set.sf和lora_set.bw计算出一个chirp包含的采样点个数
    lora_set.fft_x = lora_set.dine/8;                                                 % 根据lora_set.dine计算出包含lora_set.bw所需的FFT点数
    lora_set.Preamble_length = 8;

    times = 1000;                  % 设置实验次数
%     SIR_array = [-5, 0, 5];
    SIR_array = [5];
    for SIR_count = 1:length(SIR_array)
        disp(sf_array(SF_count));  disp(sir_array(SIR_count));
        SIR = SIR_array(SIR_count);
        conflict_result_array = zeros(5,times);  % 第1行SNR, 第2行单网关是否正确, 第3行单网关冲突发现差值, 第4行Nscale是否正确, 第5行Nscale冲突发现差值,  
        accuracy_result_array = zeros(5,times);  % 第1行SNR, 第2行单网关包1正确数目, 第3行单网关包2正确数目, 第4行Nscale包1正确数目, 第5行Nscale包2正确数目,  
        for i = 1:times                 % 循环times次实验
            % 每循环100次，输出当前进度
            if mod(i,100) == 0          
                fprintf("The time is %d\n",i);
                toc;
            end
            % 随机挑选rtl收集的信号
            [G0, G1] = select_samples(lora_set, 'D:\align_windows\');
            rtl_select = ceil(rand*7);
            G0 = G0(rtl_select, :);
            G1 = G1(rtl_select, :);
            % 计算信号的幅值均值
            amp_G0 = mean(abs(G0(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G0信号的幅值均值
            amp_G1 = mean(abs(G1(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G1信号的幅值均值
            % 根据SIR调整G1的信号强度
            amp = amp_G0/(10^(SIR/20))/amp_G1;
            G1 = amp*G1;
            % 随机生成冲突位置和SNR
            offset = round(rand()*(lora_set.Pkg_length-6)*lora_set.dine + 3*lora_set.dine);        % 随机窗口偏移   
            SNR = -45 + floor(rand*13)*5;           % 随机SNR
            conflict_result_array(1, i) = SNR;
            accuracy_result_array(1, i) = SNR;
            % 生成带噪声的合成信号
            G1_tmp = G1;
            amp_G1_tmp = mean(abs(G1_tmp(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine))); % 计算衰减后G1信号的幅值均值
            G0_tmp = [G0, zeros(1, lora_set.dine*lora_set.Pkg_length)];       % 信号补零，保证后续处理正常进行
            G1_tmp = [G1_tmp, zeros(1, lora_set.dine*lora_set.Pkg_length)];   % 信号补零，保证后续处理正常进行
            % 对G1进行信号偏移
            G1_tmp = circshift(G1_tmp, offset);             % 将包2位移到冲突发生的位置
            % 根据SNR生成噪声
            amp_noise = amp_G0/10^(SNR/20);                 % 计算噪声幅值均值
            noise = (amp_noise/sqrt(2) * randn([1 length(G0_tmp)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G0_tmp)]));   % 生成噪声
            % 合成冲突信号与噪声
            GX = G0_tmp + G1_tmp + noise;                   % 合成信号
            % time_plot(GX, lora_set, d_downchirp, 2);
            conflict_pos = ceil((offset)/lora_set.dine);    % 计算正确的冲突位置
            % 单网关处理信号
            [Pkg1_ture,Pkg2_ture,conflict_pos_cal,conflict_pos_val,conflict_flag,pkg2_pre_bin,conflict_arg,G_processing,CFO] = Function_Single_Gateway(GX, lora_set, Verification_path);
            accuracy_result_array(2, i) = Pkg1_ture;
            accuracy_result_array(3, i) = Pkg2_ture;
            if conflict_flag == 3    % 发现冲突
                if conflict_pos_cal == conflict_pos % 如果冲突发现的位置和ground truth相同
                    conflict_result_array(2,i) = 1;
                else
                    conflict_result_array(3,i) = conflict_pos - conflict_pos_cal;    % 计算位置差值
                end
            else
                conflict_result_array(3,i) = 1000;   % 未发现冲突，记录一个很大的值
            end
            % Nscale处理信号
            GX = [zeros(1, lora_set.dine*0.25), GX];
            conflict_pos = ceil((offset + lora_set.dine*0.25)/lora_set.dine);
            [Pkg1_ture, Pkg2_ture, conflict_pos_nscale] = Nscale(GX, lora_set, Verification_path);
            accuracy_result_array(4, i) = Pkg1_ture;
            accuracy_result_array(5, i) = Pkg2_ture;
            if conflict_pos_nscale == conflict_pos % 如果冲突发ss现的位置和ground truth相同
                conflict_result_array(4,i) = 1;
            else
                conflict_result_array(5,i) = conflict_pos - conflict_pos_nscale;    % 计算位置差值
            end
        end
        conflict_result_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_conflict_result'));
        accuracy_result_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_accuracy_result'));
        eval( [conflict_result_name, '= conflict_result_array;']);
        eval( [accuracy_result_name, '= accuracy_result_array;']);
    end
end
save('.\conflict_test.mat');

toc;
fclose all;
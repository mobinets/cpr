fclose all;     %关闭所有matlab打开的文件
tic;            % 打开计时器

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
    GW_num = 7;                  % 网关的数量

    times = 10;                  % 设置实验次数
    SIR_array = [5];
    for SIR_count = 1:length(SIR_array)
        disp(sf_array(SF_count));  disp(sir_array(SIR_count));
        SIR = SIR_array(SIR_count);
        a_sinGW_true = zeros(0);    % 记录所有实验的单网关正确率
        a_Nscale_true = zeros(0);   % 记录所有实验的Nscale正确率
        a_argGW_arr = zeros(0);     % 记录所有实验的冲突发现参数
        a_binGW_arr = zeros(0);     % 记录所有冲突发现得到的bin值
        a_posGW_arr = zeros(0);     % 记录所有实验的冲突发现位置
        a_SNR_arr = zeros(0);       % 记录所有实验的SNR
        a_mulGW_true = zeros(GW_num, times*100);    % 记录所有实验的多网关正确率
        a_mulGW_num = zeros(GW_num, 1);   % 记录所有实验的的实验次数
        a_mulGW_state = zeros(GW_num, times*100); 

        for i = 1:times                 % 循环times次实验
            if mod(i,10) == 0           % 每循环100次，输出当前进度
                fprintf("The time is %d\n",i);
            end
            [G0, G1] = select_samples(lora_set, 'E:\align_windows\');
            % 计算信号的幅值均值
            amp_G0 = mean(abs(G0(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G0信号的幅值均值
            amp_G1 = mean(abs(G1(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G1信号的幅值均值
            % 根据SIR调整G1的信号强度
            amp = amp_G0/(10^(SIR/20))/amp_G1;
            % G1 = amp/sqrt(2)*G1;
            G1 = amp*G1;
            % 随机生成冲突位置
            offset = round(rand()*(lora_set.Pkg_length-6)*lora_set.dine + 3*lora_set.dine);        % 随机窗口偏移                          
            % 对G0和G1进行信号补零，偏移G1信号
            G1_tmp = G1;
            amp_G1_tmp = mean(abs(G1_tmp(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine))); % 计算衰减后G1信号的幅值均值
            G0_tmp = [G0, zeros(1, lora_set.dine*lora_set.Pkg_length)];       % 信号补零，保证后续处理正常进行
            G1_tmp = [G1_tmp, zeros(1, lora_set.dine*lora_set.Pkg_length)];   % 信号补零，保证后续处理正常进行
            G1_tmp = circshift(G1_tmp, offset);              % 将包2位移到冲突发生的位置
            
            % 设置参数记录单网关的输出结果
            MG_processing = zeros(GW_num, lora_set.dine*lora_set.Pkg_length*3); % 记录单次实验的单网关处理后的信号数据
            CFO_array = zeros(1, GW_num);   % 保存单网关CFO结果
            conflict_pos_array = zeros(1, GW_num);  % 保存单网关冲突检测位置结果
            pkg2_pre_bin_array = zeros(1, GW_num);  % 保存单网关pkg2_bin的结果
            conflict_arg_array = zeros(GW_num, 9);  % 保存单网关冲突参数
            single_true_array = zeros(1, GW_num*2); % 保存单网关正确率结果
            Nscale_true_array = zeros(1, GW_num*2);
            SNR_array = zeros(1, GW_num);
            for GW_count = 1:GW_num
                SNR = -30 + floor(rand*4)*5;           % 随机SNR-30到-10
                amp_noise = amp_G0/10^(SNR/20);        % 计算噪声幅值均值
                % 计算G1的SNR
                amp_G0 = mean(abs(G0(4*lora_set.dine: lora_set.Pkg_length*lora_set.dine)));
                SNR_G0 = 20*log10(amp_G0/amp_noise);
                amp_G1 = mean(abs(G1(4*lora_set.dine: lora_set.Pkg_length*lora_set.dine)));
                SNR_G1 = 20*log10(amp_G1/amp_noise);
                % 合成冲突加噪声信号
                noise = (amp_noise/sqrt(2) * randn([1 length(G0_tmp)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G0_tmp)]));   % 生成噪声
                GX = G0_tmp + G1_tmp + noise;                   % 合成信号

                % 单网关处理信号
                [Pkg1_ture, Pkg2_ture, conflict_pos_cal, conflict_pos_val, conflict_flag, pkg2_pre_bin, conflict_arg, MG_processing_tmp, cfo] = Function_Single_Gateway(GX, lora_set, Verification_path);
                MG_processing(GW_count, 1:size(MG_processing_tmp,2)) = MG_processing_tmp;
                CFO_array(GW_count) = cfo;
                conflict_pos_array(GW_count) = conflict_pos_val;
                pkg2_pre_bin_array(GW_count) = pkg2_pre_bin;
                conflict_arg_array(GW_count, 1:7) = conflict_arg;
                conflict_arg_array(GW_count, 8:9) = [SNR_G0, SNR_G1]; 
                single_true_array(GW_count*2-1) = Pkg1_ture;    single_true_array(GW_count*2) = Pkg2_ture;
                SNR_array(GW_count) = SNR;

                % Nscale信号处理
                GX_tmp = [zeros(1, lora_set.dine*0.25), GX];
                [Pkg1_ture, Pkg2_ture, conflict_pos_nscale] = Nscale(GX_tmp, lora_set, Verification_path);
                Nscale_true_array(GW_count*2-1) = Pkg1_ture;    Nscale_true_array(GW_count*2) = Pkg2_ture;
            end
            % 记录每次实验单网关的数据结果
            a_SNR_arr = [a_SNR_arr; SNR_array];
            a_posGW_arr = [a_posGW_arr; conflict_pos_array];
            a_binGW_arr = [a_binGW_arr; pkg2_pre_bin_array];
            a_argGW_arr = [a_argGW_arr; conflict_arg_array];
            a_sinGW_true = [a_sinGW_true, single_true_array];
            a_Nscale_true = [a_Nscale_true, Nscale_true_array];
            % 遍历多网关叠加
            tol_num = 2^GW_num - 1;
            for composition_count = 1:tol_num
                composition = bitget(composition_count, 1:GW_num);
                if sum(composition) < 1
                    continue;
                elseif sum(composition) == 1
                    GW_sel_num = sum(composition);
                    a_mulGW_num(GW_sel_num) = a_mulGW_num(GW_sel_num) + 1;
                    single_sel = log2(composition_count) + 1;
                    a_mulGW_true(GW_sel_num, a_mulGW_num(GW_sel_num)*2-1) = single_true_array(single_sel*2-1);
                    a_mulGW_true(GW_sel_num, a_mulGW_num(GW_sel_num)*2) = single_true_array(single_sel*2); 
                    a_mulGW_state(GW_sel_num, a_mulGW_num(GW_sel_num)) = composition_count;
                else
                    G_index = find(composition > 0);
                    G_processing = MG_processing(G_index, :);
                    CFO = CFO_array(G_index);
                    [Pkg1_ture, Pkg2_ture] = Function_Multi_Gateway_addGW(G_processing, lora_set, CFO, Verification_path);
                    GW_sel_num = sum(composition);
                    a_mulGW_num(GW_sel_num) = a_mulGW_num(GW_sel_num) + 1;
                    a_mulGW_true(GW_sel_num, a_mulGW_num(GW_sel_num)*2-1) = Pkg1_ture;
                    a_mulGW_true(GW_sel_num, a_mulGW_num(GW_sel_num)*2) = Pkg2_ture; 
                    a_mulGW_state(GW_sel_num, a_mulGW_num(GW_sel_num)) = composition_count;
                end
            end
        end
        sinGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_sinGW_true'));
        SNR_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_SNR_arr'));
        posGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_posGW_arr'));
        binGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_binGW_arr'));
        argGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_argGW_arr'));
        Nscale_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_Nscale_true'));
        mulGW_num_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_num'));
        mulGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_true'));
        mulGW_state_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_state'));
        eval( [sinGW_true_name, '= a_sinGW_true;']);
        eval( [SNR_arr_name, '= a_SNR_arr;']);
        eval( [posGW_arr_name, '= a_posGW_arr;']);
        eval( [binGW_arr_name, '= a_binGW_arr;']);
        eval( [argGW_arr_name, '= a_argGW_arr;']);
        eval( [Nscale_true_name, '= a_Nscale_true;']);
        eval( [mulGW_num_name, '= a_mulGW_num;']);
        eval( [mulGW_true_name, '= a_mulGW_true;']);
        eval( [mulGW_state_name, '= a_mulGW_state;']);
    end
end
save('.\MG_add.mat');

toc;
fclose all;
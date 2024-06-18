fclose all;     %关闭所有matlab打开的文件
tic;            % 打开计时器

% sf_array = ["sf7", "sf8", "sf9", "sf10"];
% sir_array = ["sir_5", "sir0", "sir5"];
sf_array = ["sf8", "sf9", "sf10"];
sir_array = ["sir5"];
for SF_count = 1:length(sf_array)
    file_name = strcat('node1_', sf_array(SF_count));
    Verification_name = strcat(file_name, '.txt');
    setting_name = strcat(file_name, '.json');

    Config_Path = '.\config\';                                       % 设置配置文件所在路径
    Verification_path = strcat(Config_Path, Verification_name);      % bin值验证文件
    Setting_File = dir(fullfile(Config_Path, setting_name));         % 配置文件
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

    times = 100;                  % 设置实验次数
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
        a_off_arr = zeros(0);       % 记录所有实验的对齐参数
        a_mulGW_true = zeros(0);    % 记录所有实验的多网关正确率
        a_mulGW_state = zeros(0); 
        a_mulGW_conpos = zeros(0);
        a_mulGW_bin = zeros(0);

        for i = 1:times                 % 循环times次实验
            if mod(i,10) == 0           % 每循环100次，输出当前进度
                fprintf("The time is %d\n",i);
                toc;
            end
            [G0_array, G1_array] = select_samples(lora_set, 'D:\align_windows\');
            % 随机生成冲突位置
            offset = round(rand()*(lora_set.Pkg_length-6)*lora_set.dine + 3*lora_set.dine);        % 随机窗口偏移
            G0_tmp_array = zeros(0);
            G1_tmp_array = zeros(0);
            amp_G0 = zeros(1,GW_num);
            amp_G1 = zeros(1,GW_num);
            for G_count = 1:GW_num
                % 计算信号的幅值均值
                amp_G0(G_count) = mean(abs(G0_array(G_count, 4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G0信号的幅值均值
                amp_G1(G_count) = mean(abs(G1_array(G_count, 4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G1信号的幅值均值
                % 根据SIR调整G1的信号强度
                amp = amp_G0(G_count)/(10^(SIR/20))/amp_G1(G_count);
                G1_array(G_count, :) = amp*G1_array(G_count, :);       
                % 对G0和G1进行信号补零，偏移G1信号
                G1_tmp = G1_array(G_count, :);
                G0_tmp = [G0_array(G_count, :), zeros(1, lora_set.dine*lora_set.Pkg_length)];       % 信号补零，保证后续处理正常进行
                G1_tmp = [G1_tmp, zeros(1, lora_set.dine*lora_set.Pkg_length)];   % 信号补零，保证后续处理正常进行
                G1_tmp = circshift(G1_tmp, offset);              % 将包2位移到冲突发生的位置
                G0_tmp_array = [G0_tmp_array; G0_tmp];
                G1_tmp_array = [G1_tmp_array; G1_tmp];
            end
            
            % 设置参数记录单网关的输出结果
            MG_processing = zeros(GW_num, lora_set.dine*lora_set.Pkg_length*3); % 记录单次实验的单网关处理后的信号数据
            CFO_array = zeros(1, GW_num);   % 保存单网关CFO结果
            conflict_pos_array = zeros(1, GW_num);  % 保存单网关冲突检测位置结果
            pkg2_pre_bin_array = zeros(1, GW_num);  % 保存单网关pkg2_bin的结果
            conflict_arg_array = zeros(GW_num, 9);  % 保存单网关冲突参数
            single_true_array = zeros(1, GW_num*2); % 保存单网关正确率结果
            Nscale_true_array = zeros(1, GW_num*2);
            single_off_array = zeros(1, GW_num);
            SNR_array = zeros(1, GW_num);
            for GW_count = 1:GW_num
                if sf_array(SF_count) == "sf10"
                    SNR = -26 + rand*5;   % 随机SNR-30到-20
                elseif sf_array(SF_count) == "sf9"
                    SNR = -24 + rand*5;
                else
                    SNR = -20 + rand*5;   % 随机SNR-25到-15
                end

                amp_noise = amp_G0(GW_count)/10^(SNR/20);        % 计算噪声幅值均值
                % 计算G1的SNR
                amp_G0_tmp = mean(abs(G0_tmp_array(GW_count, 4*lora_set.dine: lora_set.Pkg_length*lora_set.dine)));
                SNR_G0 = 20*log10(amp_G0_tmp/amp_noise);
                amp_G1_tmp = mean(abs(G1_tmp_array(GW_count, 4*lora_set.dine: lora_set.Pkg_length*lora_set.dine)));
                SNR_G1 = 20*log10(amp_G1_tmp/amp_noise);
                % 合成冲突加噪声信号
                noise = (amp_noise/sqrt(2) * randn([1 length(G0_tmp_array(GW_count, :))]) + 1i*amp_noise/sqrt(2) * randn([1 length(G0_tmp_array(GW_count, :))]));   % 生成噪声
                GX = G0_tmp_array(GW_count, :) + G1_tmp_array(GW_count, :) + noise;                   % 合成信号

                % 单网关处理信号
                [Pkg1_ture, Pkg2_ture, conflict_pos_cal, conflict_pos_val, conflict_flag, pkg2_pre_bin, conflict_arg, MG_processing_tmp, cfo, ~, windows_offset, ~] = Function_Single_Gateway(GX, lora_set, Verification_path);
                MG_processing(GW_count, 1:size(MG_processing_tmp,2)) = MG_processing_tmp;
                CFO_array(GW_count) = cfo;
                single_off_array(GW_count) = windows_offset;
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
            [con_mode, bin_mode, GW_add_flag] = get_conflict_posbin_tmp(conflict_pos_array, pkg2_pre_bin_array);
            if GW_add_flag == 0
                [~, arg_index] = sort(conflict_arg_array(:, 6));
                arg_index_count = 0;
                while con_mode == 0 || bin_mode == 0
                    arg_index_count = arg_index_count + 1;
                    con_mode = conflict_pos_array(arg_index(arg_index_count));
                    bin_mode = pkg2_pre_bin_array(arg_index(arg_index_count));
                end
            end
            conflict_arg_tmp = zeros(GW_num, 4);
            for adj_count = 1:GW_num
                conflict_arg_tmp(adj_count, :) = adj_arg(MG_processing(adj_count, :), CFO_array(adj_count), lora_set, con_mode, bin_mode);
            end
            conflict_arg_array = [conflict_arg_array, conflict_arg_tmp];
            % 记录每次实验单网关的数据结果
            a_SNR_arr = [a_SNR_arr; SNR_array];
            a_posGW_arr = [a_posGW_arr; conflict_pos_array];
            a_binGW_arr = [a_binGW_arr; pkg2_pre_bin_array];
            a_argGW_arr = [a_argGW_arr; conflict_arg_array];
            a_sinGW_true = [a_sinGW_true; single_true_array];
            a_Nscale_true = [a_Nscale_true; Nscale_true_array];
            a_off_arr = [a_off_arr; single_off_array];
            % 遍历多网关叠加
            mulGW_num = zeros(GW_num, 1);       % 记录单次实验的的实验次数
            mulGW_true = zeros(GW_num, 35*2);   % 记录单次实验的多网关正确率
            mulGW_state = zeros(GW_num, 35);    % 记录单次实验的多网关对应网关
            mulGW_conpos = zeros(GW_num, 35);   % 记录单次实验的多网关冲突发现位置
            mulGW_bin = zeros(GW_num, 35);      % 记录单次实验的多网关冲突发现bin

            tol_num = 2^GW_num - 1;
            for composition_count = 1:tol_num
                composition = bitget(composition_count, 1:GW_num);
                if sum(composition) < 1
                    continue;
                elseif sum(composition) == 1
                    GW_sel_num = sum(composition);
                    mulGW_num(GW_sel_num) = mulGW_num(GW_sel_num) + 1;
                    single_sel = log2(composition_count) + 1;
                    mulGW_true(GW_sel_num, mulGW_num(GW_sel_num)*2-1) = single_true_array(single_sel*2-1);
                    mulGW_true(GW_sel_num, mulGW_num(GW_sel_num)*2) = single_true_array(single_sel*2); 
                    mulGW_state(GW_sel_num, mulGW_num(GW_sel_num)) = composition_count;
                    mulGW_conpos(GW_sel_num, mulGW_num(GW_sel_num)) = conflict_pos_array(single_sel);
                    mulGW_bin(GW_sel_num, mulGW_num(GW_sel_num)) = pkg2_pre_bin_array(single_sel);
                else
                    G_index = find(composition > 0);
                    G_processing = MG_processing(G_index, :);
                    CFO = CFO_array(G_index);
%                     [Pkg1_ture, Pkg2_ture, ~, mul_conpos, mul_bin] = Function_Multi_Gateway_addGW(G_processing, lora_set, CFO, Verification_path);
                    [Pkg1_ture, Pkg2_ture] = Function_Multi_Gateway_GT(G_processing, lora_set, CFO, Verification_path, con_mode, bin_mode);
                    GW_sel_num = sum(composition);
                    mulGW_num(GW_sel_num) = mulGW_num(GW_sel_num) + 1;
                    mulGW_true(GW_sel_num, mulGW_num(GW_sel_num)*2-1) = Pkg1_ture;
                    mulGW_true(GW_sel_num, mulGW_num(GW_sel_num)*2) = Pkg2_ture; 
                    mulGW_state(GW_sel_num, mulGW_num(GW_sel_num)) = composition_count;
%                     mulGW_conpos(GW_sel_num, mulGW_num(GW_sel_num)) = mul_conpos;
%                     mulGW_bin(GW_sel_num, mulGW_num(GW_sel_num)) = mul_bin;
                    mulGW_conpos(GW_sel_num, mulGW_num(GW_sel_num)) = con_mode;
                    mulGW_bin(GW_sel_num, mulGW_num(GW_sel_num)) = bin_mode;
                end
            end
            a_mulGW_true = [a_mulGW_true; mulGW_true];
            a_mulGW_state = [a_mulGW_state; mulGW_state];
            a_mulGW_conpos = [a_mulGW_conpos; mulGW_conpos];
            a_mulGW_bin = [a_mulGW_bin; mulGW_bin];
        end
        sinGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_sinGW_true'));
        SNR_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_SNR_arr'));
        posGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_posGW_arr'));
        binGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_binGW_arr'));
        argGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_argGW_arr'));
        Nscale_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_Nscale_true'));
        sin_off_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_sin_off'));
        mulGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_true'));
        mulGW_state_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_state'));
        mulGW_conpos_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_conpos'));
        mulGW_bin_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_bin'));
        eval( [sinGW_true_name, '= a_sinGW_true;']);
        eval( [SNR_arr_name, '= a_SNR_arr;']);
        eval( [posGW_arr_name, '= a_posGW_arr;']);
        eval( [binGW_arr_name, '= a_binGW_arr;']);
        eval( [argGW_arr_name, '= a_argGW_arr;']);
        eval( [Nscale_true_name, '= a_Nscale_true;']);
        eval( [sin_off_name, '= a_off_arr;']);
        eval( [mulGW_true_name, '= a_mulGW_true;']);
        eval( [mulGW_state_name, '= a_mulGW_state;']);
        eval( [mulGW_conpos_name, '= a_mulGW_conpos;']);
        eval( [mulGW_bin_name, '= a_mulGW_bin;']);
    end
end
save('.\MG_choice_zkw400t_sfall.mat');

toc;
fclose all;
% 对实验数据添加噪声处理，计算各种情况的正确率（2，3，4网关代码与网关基本相同）
fclose all;     %关闭所有matlab打开的文件
tic;            % 打开计时器

Config_Path = '.\config\';                                       % 设置配置文件所在路径
Verification_path = strcat(Config_Path,'node1_sf10.txt');        % bin值验证文件
Setting_File = dir(fullfile(Config_Path,'node1_sf10.json'));     % 配置文件
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
GW_num = 5;   % 网关数目
add_all = 0;

Samples_Path = "E:\1_17indoor\";% 打开存放实验数据的目录
File_1 = dir(fullfile(Samples_Path,'FFT_jun\*.sigmf-data'));    % 读取文件夹下的所有满足规则的文件，网关1
File_2 = dir(fullfile(Samples_Path,'FFT_xiong\*.sigmf-data'));  % 读取文件夹下的所有满足规则的文件，网关2
File_3 = dir(fullfile(Samples_Path,'FFT_liang\*.sigmf-data'));  % 读取文件夹下的所有满足规则的文件，网关3
File_4 = dir(fullfile(Samples_Path,'FFT_fei\*.sigmf-data'));    % 读取文件夹下的所有满足规则的文件，网关4
File_5 = dir(fullfile(Samples_Path,'FFT_kevin\*.sigmf-data'));  % 读取文件夹下的所有满足规则的文件，网关5
% 获得装有每个文件时间的数组
% 先建立空数组
File1_time = zeros(1,length(File_1));
File2_time = zeros(1,length(File_2));
File3_time = zeros(1,length(File_3));
File4_time = zeros(1,length(File_4));
File5_time = zeros(1,length(File_5));
% 根据文件记录时间计算文件时间(精确到秒)
for file_count = 1:length(File_1)
    name = strsplit(File_1(file_count).name, {'_','.'});   % 根据文件名转换成时间
    date_tmp = str2double(name(1))*3600 + str2double(name(2))*60 + str2double(name(3)); % 读取其秒分时计算在一天中的秒
    File1_time(file_count) = date_tmp;                          % 将时间记录到数组中，下面四次都是对不同四个网关实现相同功能
end
for file_count = 1:length(File_2)
    name = strsplit(File_2(file_count).name, {'_','.'});   % 根据文件名转换成时间
    date_tmp = str2double(name(1))*3600 + str2double(name(2))*60 + str2double(name(3)); % 读取其秒分时计算在一天中的秒
    File2_time(file_count) = date_tmp;                          % 将时间记录到数组中，下面四次都是对不同四个网关实现相同功能
end
for file_count = 1:length(File_3)
    name = strsplit(File_3(file_count).name, {'_','.'});   % 根据文件名转换成时间
    date_tmp = str2double(name(1))*3600 + str2double(name(2))*60 + str2double(name(3)); % 读取其秒分时计算在一天中的秒
    File3_time(file_count) = date_tmp;                          % 将时间记录到数组中，下面四次都是对不同四个网关实现相同功能
end
for file_count = 1:length(File_4)
    name = strsplit(File_4(file_count).name, {'_','.'});   % 根据文件名转换成时间
    date_tmp = str2double(name(1))*3600 + str2double(name(2))*60 + str2double(name(3)); % 读取其秒分时计算在一天中的秒
    File4_time(file_count) = date_tmp;                          % 将时间记录到数组中，下面四次都是对不同四个网关实现相同功能
end
for file_count = 1:length(File_5)
    name = strsplit(File_5(file_count).name, {'_','.'});   % 根据文件名转换成时间
    date_tmp = str2double(name(1))*3600 + str2double(name(2))*60 + str2double(name(3)); % 读取其秒分时计算在一天中的秒
    File5_time(file_count) = date_tmp;                          % 将时间记录到数组中，下面四次都是对不同四个网关实现相同功能
end
GW_num_ary = zeros(1,length(File3_time));   % 设置数组，用来保存每次实验接收到相同数据包的网关数目
times = 1000;
% 遍历所有网关3的采样值文件
a_sinGW_true = zeros(0);                    % 记录所有实验的单网关正确率
a_Nscale_true = zeros(0);                   % 记录所有实验的Nscale正确率
a_Nscale_pos = zeros(0);                    % 记录所有实验的Nscale冲突发现位置
a_multrue_arr = zeros(0);                     % 记录所有实验的多网关正确率
a_argGW_arr = zeros(0);                     % 记录所有实验的冲突发现参数
a_binGW_arr = zeros(0);                     % 记录所有实验得到的bin值
a_posGW_arr = zeros(0);                     % 记录所有实验的冲突发现位置
a_MGchoice_arr = zeros(0);                  % 记录所有实验的网关选择
a_mularg_arr = zeros(0);                    
a_mulpos_arr = zeros(0);
a_mulbin_arr = zeros(0);
a_SNR_arr = zeros(1,times*13);                       % 记录所有实验的SNR
a_sin_binrec_arr = zeros(0);
a_mulbinrec_arr = zeros(0);

for SNR = -45:5:15
% for SNR = 15:15
%     for File_count = 1:length(File3_time)       % 遍历网关3的所有文件
    for File_count = 1:times       % 遍历网关3的所有文件
        a_SNR_arr(times*(SNR+45)/5+File_count) = SNR;
        if mod(File_count,10) == 0             % 每循环100次，输出当前进度
            fprintf("SNR is %d, File_count is %d\n",SNR, File_count);
            toc;
        end
        MG_true = zeros(1,GW_num*2);            % 记录单次实验的单网关正确率
        Nscale_true = zeros(1, GW_num*2);       % 记录Nscale正确率
        Nscale_pos = zeros(1, GW_num);          % 记录NScale发现冲突位置
        MG_con_pos = zeros(1,GW_num);           % 记录单次实验的单网关冲突发生位置
        MG_con_flag = zeros(1,GW_num);          % 记录单次实验的单网关冲突发生标志
        MG_pkg2_bin = zeros(1,GW_num);          % 记录单次实验的单网关bin
        MG_con_ag = zeros(GW_num,7);            % 记录单次实验的单网关冲突发现参数
        MG_processing = zeros(GW_num, lora_set.dine * lora_set.Pkg_length * 10);       % 记录单次实验的单网关处理后的信号数据
        MG_CFO = zeros(1,GW_num);               % 记录单次实验的单网关得到的CFO
        MG_choice = zeros(1,GW_num);            % 记录单次实验的多网关选择
        MG_Peak_rate_full = zeros(1, GW_num);
        MG_bin_rec = zeros(GW_num*2, lora_set.Pkg_length-lora_set.Preamble_length-4);
    
        % 查找每个网关中与当前网关的该文件相差一秒的文件
        File1_datedif = File1_time - File3_time(File_count);    % 计算网关1的每个文件与网关3当前文件的时间差，下同
        File2_datedif = File2_time - File3_time(File_count);
        File4_datedif = File4_time - File3_time(File_count);
        File5_datedif = File5_time - File3_time(File_count);
        Find_File1 = find( abs(File1_datedif) <= 1 );           % 找到网关1所有文件中与网关3当前文件时间相差1s的文件，下同
        Find_File2 = find( abs(File2_datedif) <= 1 );
        Find_File4 = find( abs(File4_datedif) <= 1 );
        Find_File5 = find( abs(File5_datedif) <= 1 );
        % 记录所有网关时间差小于1s的网关数目
        GW_num_ary(File_count) = length(Find_File1) + length(Find_File2) + length(Find_File4) + length(Find_File5) + 1;
        
        % 对网关3采样值进行读取
        File3_Path = strcat(Samples_Path, 'FFT_liang\', File_3(File_count).name);   % 补全该文件的完整路径
        fid_3=fopen(File3_Path,'rb');   % 读取文件
        [A_3]=fread(fid_3,'float32')';
        A_3_length = size(A_3,2);
        G3 = A_3(1:2:A_3_length-1) + A_3(2:2:A_3_length)*1i;        % 将float数组转换成复数数组
        % 添加噪声
        amp_G3 = mean(abs(G3(3*lora_set.dine : 5*lora_set.dine)));
        amp_noise = amp_G3/10^(SNR/20);
        noise = (amp_noise/sqrt(2) * randn([1 length(G3)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G3)]));   % 生成噪声
        G3_noise = G3 + noise;
    
        % [MG_true(3*2-1), MG_true(3*2), MG_con_pos(3), ~, MG_con_flag(3), MG_pkg2_bin(3), MG_con_ag(3,:), MG_processing_tmp, MG_CFO(3), MG_Peak_rate_full(3), G3] = Function_Single_Gateway_addnoise(G3, lora_set, Verification_path, SNR);
        [MG_true(3*2-1), MG_true(3*2), ~, MG_con_pos(3), MG_con_flag(3), MG_pkg2_bin(3), MG_con_ag(3,:), MG_processing_tmp, MG_CFO(3), MG_Peak_rate_full(3),~,~,MG_bin_rec(3*2-1, :), MG_bin_rec(3*2, :)] = Function_Single_Gateway(G3_noise, lora_set, Verification_path);
%         [Nscale_true(3*2-1), Nscale_true(3*2), Nscale_pos(3)] = Nscale(G3_noise, lora_set, Verification_path);
        MG_processing(3,1:size(MG_processing_tmp,2)) = MG_processing_tmp;           % 记录单网关处理后的信号
        MG_choice(3) = 1;       % 记录下网关3存在相同时间点的数据包（一定存在，因为以网关3是参考值）
    
        % 如果网关1接收到了同样的包，则对包进行处理，与上面代码相同
        if length(Find_File1) == 1
            File1_Path = strcat(Samples_Path, 'FFT_jun\', File_1(Find_File1(1)).name);
            fid_1=fopen(File1_Path,'rb');
            [A_1]=fread(fid_1,'float32')';
            A_1_length = size(A_1,2);
            G1 = A_1(1:2:A_1_length-1) + A_1(2:2:A_1_length)*1i;
            % 添加噪声
            amp_G1 = mean(abs(G1(3*lora_set.dine : 5*lora_set.dine)));
            amp_noise = amp_G1/10^(SNR/20);
            noise = (amp_noise/sqrt(2) * randn([1 length(G1)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G1)]));   % 生成噪声
            G1_noise = G1 + noise;
    
            % [MG_true(1*2-1), MG_true(1*2), MG_con_pos(1), ~, MG_con_flag(1), MG_pkg2_bin(1), MG_con_ag(1,:), MG_processing_tmp, MG_CFO(1), MG_Peak_rate_full(1), G1] = Function_Single_Gateway_addnoise(G1, lora_set, Verification_path, SNR);
            [MG_true(1*2-1), MG_true(1*2), ~, MG_con_pos(1), MG_con_flag(1), MG_pkg2_bin(1), MG_con_ag(1,:), MG_processing_tmp, MG_CFO(1), MG_Peak_rate_full(1),~,~,MG_bin_rec(1*2-1, :), MG_bin_rec(1*2, :)] = Function_Single_Gateway(G1_noise, lora_set, Verification_path);
%             [Nscale_true(1*2-1), Nscale_true(1*2), Nscale_pos(1)] = Nscale(G1_noise, lora_set, Verification_path);
            MG_processing(1,1:size(MG_processing_tmp,2)) = MG_processing_tmp;
            MG_choice(1) = 1;
        end
    
        % 如果网关2接收到了同样的包，则对包进行处理，同上
        if length(Find_File2) == 1
            File2_Path = strcat(Samples_Path, 'FFT_xiong\', File_2(Find_File2(1)).name);
            fid_2=fopen(File2_Path,'rb');
            [A_2]=fread(fid_2,'float32')';
            A_2_length = size(A_2,2);
            G2 = A_2(1:2:A_2_length-1) + A_2(2:2:A_2_length)*1i;
            % 添加噪声
            amp_G2 = mean(abs(G2(3*lora_set.dine : 5*lora_set.dine)));
            amp_noise = amp_G2/10^(SNR/20);
            noise = (amp_noise/sqrt(2) * randn([1 length(G2)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G2)]));   % 生成噪声
            G2_noise = G2 + noise;
    
            % [MG_true(2*2-1), MG_true(2*2), MG_con_pos(2), ~, MG_con_flag(2), MG_pkg2_bin(2), MG_con_ag(2,:), MG_processing_tmp, MG_CFO(2), MG_Peak_rate_full(2), G2] = Function_Single_Gateway_addnoise(G2, lora_set, Verification_path, SNR);
            [MG_true(2*2-1), MG_true(2*2), ~, MG_con_pos(2), MG_con_flag(2), MG_pkg2_bin(2), MG_con_ag(2,:), MG_processing_tmp, MG_CFO(2), MG_Peak_rate_full(2),~,~,MG_bin_rec(2*2-1, :), MG_bin_rec(2*2, :)] = Function_Single_Gateway(G2_noise, lora_set, Verification_path);
%             [Nscale_true(2*2-1), Nscale_true(2*2), Nscale_pos(2)] = Nscale(G2_noise, lora_set, Verification_path);
            MG_processing(2,1:size(MG_processing_tmp,2)) = MG_processing_tmp;
            MG_choice(2) = 1;
        end
    
        % 如果网关4接收到了同样的包，则对包进行处理，同上
        if length(Find_File4) == 1
            File4_Path = strcat(Samples_Path, 'FFT_fei\', File_4(Find_File4(1)).name);
            fid_4=fopen(File4_Path,'rb');
            [A_4]=fread(fid_4,'float32')';
            A_4_length = size(A_4,2);
            G4 = A_4(1:2:A_4_length-1) + A_4(2:2:A_4_length)*1i;
            % 添加噪声
            amp_G4 = mean(abs(G4(3*lora_set.dine : 5*lora_set.dine)));
            amp_noise = amp_G4/10^(SNR/20);
            noise = (amp_noise/sqrt(2) * randn([1 length(G4)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G4)]));   % 生成噪声
            G4_noise = G4 + noise;
    
            % [MG_true(4*2-1), MG_true(4*2), MG_con_pos(4), ~, MG_con_flag(4), MG_pkg2_bin(4), MG_con_ag(4,:), MG_processing_tmp, MG_CFO(4), MG_Peak_rate_full(4), G4] = Function_Single_Gateway_addnoise(G4, lora_set, Verification_path, SNR);
            [MG_true(4*2-1), MG_true(4*2), ~, MG_con_pos(4), MG_con_flag(4), MG_pkg2_bin(4), MG_con_ag(4,:), MG_processing_tmp, MG_CFO(4), MG_Peak_rate_full(4),~,~,MG_bin_rec(4*2-1, :), MG_bin_rec(4*2, :)] = Function_Single_Gateway(G4_noise, lora_set, Verification_path);
%             [Nscale_true(4*2-1), Nscale_true(4*2), Nscale_pos(4)] = Nscale(G4_noise, lora_set, Verification_path);
            MG_processing(4,1:size(MG_processing_tmp,2)) = MG_processing_tmp;
            MG_choice(4) = 1;
        end
    
        % 如果网关5接收到了同样的包，则对包进行处理，同上
        if length(Find_File5) == 1
            File5_Path = strcat(Samples_Path, 'FFT_kevin\', File_5(Find_File5(1)).name);
            fid_5=fopen(File5_Path,'rb');
            [A_5]=fread(fid_5,'float32')';
            A_5_length = size(A_5, 2);
            G5 = A_5(1:2:A_5_length-1) + A_5(2:2:A_5_length)*1i;
            % 添加噪声
            amp_G5 = mean(abs(G5(3*lora_set.dine : 5*lora_set.dine)));
            amp_noise = amp_G5/10^(SNR/20);
            noise = (amp_noise/sqrt(2) * randn([1 length(G5)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G5)]));   % 生成噪声
            G5_noise = G5 + noise;
    
            % [MG_true(5*2-1), MG_true(5*2), MG_con_pos(5), ~, MG_con_flag(5), MG_pkg2_bin(5), MG_con_ag(5,:), MG_processing_tmp, MG_CFO(5), MG_Peak_rate_full(5), G5] = Function_Single_Gateway_addnoise(G5, lora_set, Verification_path, SNR);
            [MG_true(5*2-1), MG_true(5*2), ~, MG_con_pos(5), MG_con_flag(5), MG_pkg2_bin(5), MG_con_ag(5,:), MG_processing_tmp, MG_CFO(5), MG_Peak_rate_full(5),~,~,MG_bin_rec(5*2-1, :), MG_bin_rec(5*2, :)] = Function_Single_Gateway(G5_noise, lora_set, Verification_path);
%             [Nscale_true(5*2-1), Nscale_true(5*2), Nscale_pos(5)] = Nscale(G5_noise, lora_set, Verification_path);
            MG_processing(5,1:size(MG_processing_tmp,2)) = MG_processing_tmp;
            MG_choice(5) = 1;
        end
    
        % 记录网关处理结果
        a_sinGW_true = [a_sinGW_true; MG_true];
        a_argGW_arr = [a_argGW_arr; MG_con_ag];
        a_binGW_arr = [a_binGW_arr; MG_pkg2_bin];
        a_posGW_arr = [a_posGW_arr; MG_con_pos];
        a_MGchoice_arr = [a_MGchoice_arr; MG_choice];
        a_Nscale_true = [a_Nscale_true; Nscale_true];
        a_Nscale_pos = [a_Nscale_pos; Nscale_pos];
        a_sin_binrec_arr = [a_sin_binrec_arr; MG_bin_rec];
    
        % 2网关
        Multi_true = zeros(3, 4);
        Multi_arg = zeros(4, 7);
        Multi_pos = zeros(1, 4);
        Multi_bin = zeros(1, 4);
        Multi_binrec = zeros(4*2, lora_set.Pkg_length-lora_set.Preamble_length-4);
    
        k_residual_result = 0.55;
        if MG_choice(1) == 1
            Multi_true(1, 1) = 1; % 记录2网关运行
            choice_ref = [1,3];
            [con_mode, bin_mode, GW_add_flag] = get_conflict_posbin_tmp(MG_con_pos(choice_ref), MG_pkg2_bin(choice_ref));
            if GW_add_flag == 0
                [~, arg_index] = sort(MG_con_ag(choice_ref, 6));
                arg_index_count = 0;
                while_count = 0;
                while con_mode == 0 || bin_mode == 0
                    arg_index_count = arg_index_count + 1;
                    con_mode = MG_con_pos(arg_index(arg_index_count));
                    bin_mode = MG_pkg2_bin(arg_index(arg_index_count));
                    while_count = while_count + 1;
                    if while_count == 2
                        break;
                    end
                end
            end
            if con_mode ~= 0 && bin_mode ~= 0 % 投票达成共识
                conflict_arg_tmp = zeros(2, 4);
                for adj_count = 1:length(choice_ref)
                    conflict_arg_tmp(adj_count, :) = adj_arg(MG_processing(choice_ref(adj_count), :), MG_CFO(choice_ref(adj_count)), lora_set, con_mode, bin_mode);
                end
                arg_fin = (conflict_arg_tmp(:, 3) + conflict_arg_tmp(:, 4)) ./ (conflict_arg_tmp(:, 1) - conflict_arg_tmp(:, 2));
                % 挑选网关
                arg_find_index = find((arg_fin <= k_residual_result) & (arg_fin >= 0));
                % 多网关处理
                if length(arg_find_index) > 1  % 如果挑选网关数目大于1
                    [Multi_true(2, 1), Multi_true(3, 1), Multi_binrec(1*2-1,:), Multi_binrec(1*2,:)] = Function_Multi_Gateway_GT(MG_processing(choice_ref(arg_find_index), :), lora_set, MG_CFO(arg_find_index), Verification_path, con_mode, bin_mode);
                else                        % 挑选网关数目小于等于1
                    [Multi_true(2, 1), index] = max(MG_true(choice_ref.*2-1));
                    index = choice_ref(index);
                    Multi_binrec(1*2-1,:) = MG_bin_rec(index*2-1, :);
                    [Multi_true(3, 1), index] = max(MG_true(choice_ref.*2));
                    index = choice_ref(index);
                    Multi_binrec(1*2,:) = MG_bin_rec(index*2, :);
                end
            else    % 投票无共识
                [Multi_true(2, 1), index] = max(MG_true(choice_ref.*2-1));
                index = choice_ref(index);
                Multi_binrec(1*2-1,:) = MG_bin_rec(index*2-1, :);
                Multi_true(3, 1) = 0;
            end
            
        end
        % 3网关
        if MG_choice(1) == 1 && MG_choice(2) == 1
            Multi_true(1, 2) = 1; % 记录2网关运行
            choice_ref = [1,2,3];
            [con_mode, bin_mode, GW_add_flag] = get_conflict_posbin_tmp(MG_con_pos(choice_ref), MG_pkg2_bin(choice_ref));
            if GW_add_flag == 0
                [~, arg_index] = sort(MG_con_ag(choice_ref, 6));
                arg_index_count = 0;
                while_count = 0;
                while con_mode == 0 || bin_mode == 0
                    arg_index_count = arg_index_count + 1;
                    con_mode = MG_con_pos(arg_index(arg_index_count));
                    bin_mode = MG_pkg2_bin(arg_index(arg_index_count));
                    while_count = while_count + 1;
                    if while_count == 3
                        break;
                    end
                end
            end
            if con_mode ~= 0 && bin_mode ~= 0 % 投票达成共识
                conflict_arg_tmp = zeros(3, 4);
                for adj_count = 1:length(choice_ref)
                    conflict_arg_tmp(adj_count, :) = adj_arg(MG_processing(choice_ref(adj_count), :), MG_CFO(choice_ref(adj_count)), lora_set, con_mode, bin_mode);
                end
                arg_fin = (conflict_arg_tmp(:, 3) + conflict_arg_tmp(:, 4)) ./ (conflict_arg_tmp(:, 1) - conflict_arg_tmp(:, 2));
                % 挑选网关
                arg_find_index = find((arg_fin <= k_residual_result) & (arg_fin >= 0));
                % 多网关处理
                if length(arg_find_index) > 1  % 如果挑选网关数目大于1
                    [Multi_true(2, 2), Multi_true(3, 2), Multi_binrec(2*2-1,:), Multi_binrec(2*2,:)] = Function_Multi_Gateway_GT(MG_processing(choice_ref(arg_find_index), :), lora_set, MG_CFO(arg_find_index), Verification_path, con_mode, bin_mode);
                else                        % 挑选网关数目小于等于1
                    [Multi_true(2, 2), index] = max(MG_true(choice_ref.*2-1));
                    index = choice_ref(index);
                    Multi_binrec(2*2-1,:) = MG_bin_rec(index*2-1, :);
                    [Multi_true(3, 2), index] = max(MG_true(choice_ref.*2));
                    index = choice_ref(index);
                    Multi_binrec(2*2,:) = MG_bin_rec(index*2, :);
                end
            else    % 投票无共识
                [Multi_true(2, 2), index] = max(MG_true(choice_ref.*2-1));
                index = choice_ref(index);
                Multi_binrec(2*2-1,:) = MG_bin_rec(index*2-1, :);
                Multi_true(3, 2) = 0;
            end
        end
        % 4网关
        if MG_choice(1) == 1 && MG_choice(2) == 1 && MG_choice(4) == 1
            Multi_true(1, 3) = 1; % 记录2网关运行
            choice_ref = [1,2,3,4];
            [con_mode, bin_mode, GW_add_flag] = get_conflict_posbin_tmp(MG_con_pos(choice_ref), MG_pkg2_bin(choice_ref));
            if GW_add_flag == 0
                [~, arg_index] = sort(MG_con_ag(choice_ref, 6));
                arg_index_count = 0;
                while_count = 0;
                while con_mode == 0 || bin_mode == 0
                    arg_index_count = arg_index_count + 1;
                    con_mode = MG_con_pos(arg_index(arg_index_count));
                    bin_mode = MG_pkg2_bin(arg_index(arg_index_count));
                    while_count = while_count + 1;
                    if while_count == 4
                        break;
                    end
                end
            end
            if con_mode ~= 0 && bin_mode ~= 0 % 投票达成共识
                conflict_arg_tmp = zeros(4, 4);
                for adj_count = 1:length(choice_ref)
                    conflict_arg_tmp(adj_count, :) = adj_arg(MG_processing(choice_ref(adj_count), :), MG_CFO(choice_ref(adj_count)), lora_set, con_mode, bin_mode);
                end
                arg_fin = (conflict_arg_tmp(:, 3) + conflict_arg_tmp(:, 4)) ./ (conflict_arg_tmp(:, 1) - conflict_arg_tmp(:, 2));
                % 挑选网关
                arg_find_index = find((arg_fin <= k_residual_result) & (arg_fin >= 0));
                % 多网关处理
                if length(arg_find_index) > 1  % 如果挑选网关数目大于1
                    [Multi_true(2, 3), Multi_true(3, 3), Multi_binrec(3*2-1,:), Multi_binrec(3*2,:)] = Function_Multi_Gateway_GT(MG_processing(choice_ref(arg_find_index), :), lora_set, MG_CFO(arg_find_index), Verification_path, con_mode, bin_mode);
                else                        % 挑选网关数目小于等于1
                    [Multi_true(2, 3), index] = max(MG_true(choice_ref.*2-1));
                    index = choice_ref(index);
                    Multi_binrec(3*2-1,:) = MG_bin_rec(index*2-1, :);
                    [Multi_true(3, 3), index] = max(MG_true(choice_ref.*2));
                    index = choice_ref(index);
                    Multi_binrec(3*2,:) = MG_bin_rec(index*2, :);
                end
            else    % 投票无共识
                [Multi_true(2, 3), index] = max(MG_true(choice_ref.*2-1));
                index = choice_ref(index);
                Multi_binrec(3*2-1,:) = MG_bin_rec(index*2-1, :);
                Multi_true(3, 3) = 0;
            end
        end
        % 5网关
        if MG_choice(1) == 1 && MG_choice(2) == 1 && MG_choice(4) == 1 && MG_choice(5) == 1
            Multi_true(1, 4) = 1; % 记录2网关运行
            choice_ref = [1,2,3,4,5];
            [con_mode, bin_mode, GW_add_flag] = get_conflict_posbin_tmp(MG_con_pos(choice_ref), MG_pkg2_bin(choice_ref));
            if GW_add_flag == 0
                [~, arg_index] = sort(MG_con_ag(choice_ref, 6));
                arg_index_count = 0;
                while_count = 0;
                while con_mode == 0 || bin_mode == 0
                    arg_index_count = arg_index_count + 1;
                    con_mode = MG_con_pos(arg_index(arg_index_count));
                    bin_mode = MG_pkg2_bin(arg_index(arg_index_count));
                    while_count = while_count + 1;
                    if while_count == 5
                        break;
                    end
                end
            end
            if con_mode ~= 0 && bin_mode ~= 0 % 投票达成共识
                conflict_arg_tmp = zeros(5, 4);
                for adj_count = 1:length(choice_ref)
                    conflict_arg_tmp(adj_count, :) = adj_arg(MG_processing(choice_ref(adj_count), :), MG_CFO(choice_ref(adj_count)), lora_set, con_mode, bin_mode);
                end
                arg_fin = (conflict_arg_tmp(:, 3) + conflict_arg_tmp(:, 4)) ./ (conflict_arg_tmp(:, 1) - conflict_arg_tmp(:, 2));
                % 挑选网关
                arg_find_index = find((arg_fin <= k_residual_result) & (arg_fin >= 0));
                % 多网关处理
                if length(arg_find_index) > 1  % 如果挑选网关数目大于1
                    [Multi_true(2, 4), Multi_true(3, 4), Multi_binrec(4*2-1,:), Multi_binrec(4*2,:)] = Function_Multi_Gateway_GT(MG_processing(choice_ref(arg_find_index), :), lora_set, MG_CFO(arg_find_index), Verification_path, con_mode, bin_mode);
                else                        % 挑选网关数目小于等于1
                    [Multi_true(2, 4), index] = max(MG_true(choice_ref.*2-1));
                    index = choice_ref(index);
                    Multi_binrec(4*2-1,:) = MG_bin_rec(index*2-1, :);
                    [Multi_true(3, 4), index] = max(MG_true(choice_ref.*2));
                    index = choice_ref(index);
                    Multi_binrec(4*2,:) = MG_bin_rec(index*2, :);
                end
            else    % 投票无共识
                [Multi_true(2, 4), index] = max(MG_true(choice_ref.*2-1));
                index = choice_ref(index);
                Multi_binrec(4*2-1,:) = MG_bin_rec(index*2-1, :);
                Multi_true(3, 4) = 0;
            end
        end
        a_multrue_arr = [a_multrue_arr; Multi_true];
        a_mularg_arr = [a_mularg_arr; Multi_arg];
        a_mulpos_arr = [a_mulpos_arr; Multi_pos];
        a_mulbin_arr = [a_mulbin_arr; Multi_bin];
        a_mulbinrec_arr = [a_mulbinrec_arr; Multi_binrec];
        fclose all;   % 每次循环结束都要关闭已打开的文件
    end
end
save('./exp_5gw_binrec.mat', 'a_SNR_arr', 'a_sinGW_true', 'a_Nscale_true', 'a_multrue_arr', 'a_argGW_arr', 'a_binGW_arr', 'a_posGW_arr', 'a_MGchoice_arr', 'a_Nscale_pos', 'a_mularg_arr', 'a_mulpos_arr', 'a_mulbin_arr', 'a_sin_binrec_arr', 'a_mulbinrec_arr');

toc;        % 计时结束
fclose all; %关闭所有matlab打开的文件
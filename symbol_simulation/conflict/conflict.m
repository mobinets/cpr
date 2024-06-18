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
leakage_width_array = [0.02,0.01,0.015,0.001];
lora_set.filter_num = lora_set.Preamble_length*2 + 2;
% lora_set.filter_num = 2;
lora_set.leakage_width1 = leakage_width_array(lora_set.sf-6);
lora_set.leakage_width2 = 1-lora_set.leakage_width1;

Samples_Path = '.\samples\';                                    % 设置采样值文件所在路径
File_1 = dir(fullfile(Samples_Path,'SF10_PACK1_A.*'));          % 读取文件夹下满足规则的采样值文件1
File_2 = dir(fullfile(Samples_Path,'SF10_PACK2_A.*'));          % 读取文件夹下满足规则的采样值文件2
File_Path_1 = strcat(Samples_Path, File_1.name);
File_Path_2 = strcat(Samples_Path, File_2.name);
fid_1=fopen(File_Path_1,'rb');
fid_2=fopen(File_Path_2,'rb');
[A_1]=fread(fid_1,'float32')';
[A_2]=fread(fid_2,'float32')';
A_1_length = size(A_1,2);
A_2_length = size(A_2,2);
G0 = A_1(1:2:A_1_length-1) + A_1(2:2:A_1_length)*1i;            % 将float数组转换成复数数组
G1 = A_2(1:2:A_2_length-1) + A_2(2:2:A_2_length)*1i;

times = 4000;                  % 设置实验次数
result_array = zeros(5,times);  % 第一行SNR_G0, 第二行SNR_G1, 第三行min(SNR_G0,SNR_G1), 第四行是否正确, 第五行冲突发现差值  
amp_G0 = mean(abs(G0(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G0信号的幅值均值
amp_G1 = mean(abs(G1(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G1信号的幅值均值
% 根据SIR调整G1的强度
SIR = 5;
amp = amp_G0/(10^(SIR/20))/amp_G1;
% G1 = amp/sqrt(2)*G1;
G1 = amp*G1;
for i = 1:times                 % 循环times次实验
    if mod(i,100) == 0          % 每循环100次，输出当前进度
        fprintf("The time is %d\n",i);
    end
    offset = round(rand()*(lora_set.Pkg_length-6)*lora_set.dine + 3*lora_set.dine);        % 随机窗口偏移                             
    SNR = -45 + floor(rand*13)*5;           % 随机SNR
%     SNR = 0 + floor(rand*4)*5;
    % 生成带噪声的合成信号
    G1_tmp = G1;
    amp_G1_tmp = mean(abs(G1_tmp(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine))); % 计算衰减后G1信号的幅值均值
    G0_tmp = [G0, zeros(1, lora_set.dine*lora_set.Pkg_length)];       % 信号补零，保证后续处理正常进行
    G1_tmp = [G1_tmp, zeros(1, lora_set.dine*lora_set.Pkg_length)];   % 信号补零，保证后续处理正常进行
    
    G1_tmp = circshift(G1_tmp, offset);              % 将包2位移到冲突发生的位置
    amp_noise = amp_G0/10^(SNR/20);                 % 计算噪声幅值均值
    noise = (amp_noise/sqrt(2) * randn([1 length(G0_tmp)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G0_tmp)]));   % 生成噪声

    GX = G0_tmp + G1_tmp + noise;                   % 合成信号
    % 计算SNR_G0和SNR_G1
    SNR_G0 = 20*log10(amp_G0/amp_noise);    result_array(1,i) = SNR_G0; % 计算得到包1SNR
    SNR_G1 = 20*log10(amp_G1_tmp/amp_noise);    result_array(2,i) = SNR_G1; % 计算得到包2SNR
    result_array(3,i) = min(SNR_G0, SNR_G1); % 计算得到两个包SNR的最小值
    % 给最后的合成信号后面补零，防止数值索引出错
    % conflict_pos = ceil((offset+10*lora_set.dine)/lora_set.dine);       % 计算正确的冲突位置
    conflict_pos = ceil((offset)/lora_set.dine);       % 计算正确的冲突位置
%     disp(conflict_pos);
    % 单网关处理信号
    [Pkg1_ture,Pkg2_ture,conflict_pos_cal,conflict_pos_val,conflict_flag,pkg2_pre_bin,conflict_arg,G_processing,CFO] = Function_Single_Gateway(GX, lora_set, Verification_path);
    % [Pkg1_ture,Pkg2_ture,conflict_pos_cal,conflict_flag,pkg2_pre_bin,conflict_arg,G_processing,CFO] = Function_Single_Gateway_test(GX,lora_set.sf,lora_set.bw,Verification_path,lora_set.Pkg_length);
    if conflict_flag == 3    % 发现冲突
        if conflict_pos_cal == conflict_pos % 如果冲突发现的位置和ground truth相同
            result_array(4,i) = 1;
        else
            result_array(5,i) = conflict_pos - conflict_pos_cal;    % 计算位置差值
        end
    else
        result_array(5,i) = 1000;   % 未发现冲突，记录一个很大的值
    end
end

toc;
fclose all;
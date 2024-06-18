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

    times = 1000;                  % 设置实验次数
    SIR_array = [5];
    for SIR_count = 1:length(SIR_array)
        disp(sf_array(SF_count));  disp(sir_array(SIR_count));
        SIR = SIR_array(SIR_count);
        prtrue_array = zeros(times, GW_num+2);
        for i = 1:times                 % 循环times次实验
            if mod(i,100) == 0           % 每循环100次，输出当前进度
                fprintf("The time is %d\n",i);
            end
            [G0, G1] = select_samples(lora_set, 'E:\align_windows\');
            % 计算信号的幅值均值
            amp_G0 = mean(abs(G0(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G0信号的幅值均值
            amp_G1 = mean(abs(G1(4*lora_set.dine : lora_set.Pkg_length*lora_set.dine)));    % 计算G1信号的幅值均值
            % 根据SIR调整G1的信号强度
            amp = amp_G0/(10^(SIR/20))/amp_G1;
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
            single_pr_array = zeros(1, GW_num);

            SNR = -45 + floor(rand*13)*5;  % 设置SNR值
            prtrue_array(i, 1) = SNR;
            for GW_count = 1:GW_num
                amp_noise = amp_G0/10^(SNR/20);     % 计算噪声幅值均值
                % 合成冲突加噪声信号
                noise = (amp_noise/sqrt(2) * randn([1 length(G0_tmp)]) + 1i*amp_noise/sqrt(2) * randn([1 length(G0_tmp)]));   % 生成噪声
                GX = G0_tmp + G1_tmp + noise;       % 合成信号

                % 单网关处理信号
                [peak_rate, MG_processing_tmp, cfo] = Function_Single_Gateway_align_accuracy(GX, lora_set, Verification_path, offset);
                MG_processing(GW_count, 1:size(MG_processing_tmp,2)) = MG_processing_tmp;
                CFO_array(GW_count) = cfo;
                % a_single_pr_true(i, GW_count) = peak_rate;
                prtrue_array(i, GW_count+1) = peak_rate;
            end
            % 多网关叠加
            [peak_rate] = Function_Multi_Gateway_align_accuracy(MG_processing, lora_set, CFO_array, Verification_path, offset);
            prtrue_array(i, end) = peak_rate;
        end
        prtrue_result_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_prtrue_result'));
        eval( [prtrue_result_name, '= prtrue_array;']);
    end
end

toc;
fclose all;
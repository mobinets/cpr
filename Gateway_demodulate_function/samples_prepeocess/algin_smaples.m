fclose all;     %关闭所有matlab打开的文件
tic;            % 打开计时器

Config_Path = '.\config\';                                      % 设置配置文件所在路径
Verification_path = strcat(Config_Path,'node1_sf7.txt');       % bin值验证文件
Setting_File = dir(fullfile(Config_Path,'node1_sf7.json'));    % 配置文件
Setting_File_Path = strcat(Config_Path, Setting_File.name);
Setting_file = fopen(Setting_File_Path,'r');
setting = jsondecode(fscanf(Setting_file,'%s'));                % 解析json格式变量
lora_set.bw = setting.captures.lora_bw;                         % 设置接收数据包的lora_set.bw
lora_set.sf = setting.captures.lora_sf;                         % 设置接收数据包的lora_set.sf
lora_set.sample_rate = setting.global.core_sample_rate;         % 设置接收数据包的采样率
lora_set.Pkg_length = setting.captures.lora_pkg_length;         % 设置接收数据包的长度
lora_set.dine = 1000000*bitshift(1,lora_set.sf)/lora_set.bw;    % 根据lora_set.sf和lora_set.bw计算出一个chirp包含的采样点个数
lora_set.fft_x = lora_set.dine/8;                               % 根据lora_set.dine计算出包含lora_set.bw所需的FFT点数
lora_set.Preamble_length = 8;
leakage_width_array = [0.02,0.01,0.015,0.001];
lora_set.filter_num = lora_set.Preamble_length*2 + 2;
% lora_set.filter_num = 2;
lora_set.leakage_width1 = leakage_width_array(lora_set.sf-6);
lora_set.leakage_width2 = 1-lora_set.leakage_width1;

Samples_Path = 'Z:\LoRa_symbol_emulation\FFT_zkw\SF7_zkw\';                                    % 设置采样值文件所在路径
File_1 = dir(fullfile(Samples_Path,'*.sigmf-data'));          % 读取文件夹下满足规则的采样值文件1
[d_downchirp, d_upchirp] = build_idealchirp(lora_set);
for i = 1:length(File_1)
    File1_Path = strcat(Samples_Path, File_1(i).name);
    fid_1=fopen(File1_Path,'rb');
    [A_1]=fread(fid_1,'float32')';
    A_1_length = size(A_1,2);
    G0 = A_1(1:2:A_1_length-1) + A_1(2:2:A_1_length)*1i;
    [cfo, windows_offset] = get_cfo_winoff(G0, lora_set, d_downchirp, d_upchirp);
    [d_downchirp_cfo, d_upchirp_cfo] = rebuild_idealchirp_cfo(lora_set, cfo);   % 重新调整理想upchirp和downchirp
    G0 = circshift(G0, -round(windows_offset));                                  % 对齐主峰窗口
    
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    samples = G0(1:dine);
    samples_dechirp = samples .* d_downchirp_cfo;
    samples_fft = abs(fft(samples_dechirp, dine));
    samples_fft_merge = [samples_fft(1:fft_x/2) + samples_fft(dine-fft_x+1:dine-fft_x/2), samples_fft(dine-fft_x/2+1:dine)+samples_fft(fft_x/2+1:fft_x)];
    
    max_value = max(samples_fft_merge);
    man_mean = (sum(samples_fft_merge) - max_value)/length(samples_fft_merge);
    if max_value < 50*man_mean
        G0 = circshift(G0, -round(dine));
    end

    G0_samples = zeros(1, A_1_length);
    G0_real = real(G0);   G0_imag = imag(G0);
    G0_samples(1:2:A_1_length-1) = G0_real;
    G0_samples(2:2:A_1_length) = G0_imag;
    write_dir = 'Z:\LoRa_symbol_emulation\align_windows\FFT_rtl7\SF7\';
    tmp = strcat('samples_' , string(i));
    tmp = strcat(tmp, '.sigmf-data');
    write_Path = strcat(write_dir, tmp);
    fid_3=fopen(write_Path,'wb');
    fwrite(fid_3, G0_samples, 'float32');
end
disp(Samples_Path);
disp(write_dir);


toc;
fclose all;
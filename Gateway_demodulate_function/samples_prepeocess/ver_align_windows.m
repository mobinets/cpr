fclose all;     %关闭所有matlab打开的文件
tic;            % 打开计时器

Config_Path = '.\config\';                                      % 设置配置文件所在路径
Verification_path = strcat(Config_Path,'node1_sf10.txt');       % bin值验证文件
Setting_File = dir(fullfile(Config_Path,'node1_sf10.json'));    % 配置文件
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
lora_set.leakage_width1 = leakage_width_array(lora_set.sf-6);
lora_set.leakage_width2 = 1-lora_set.leakage_width1;

Samples_Path = 'D:\align_windows\FFT_rtl7\SF10\node2\';     % 设置采样值文件所在路径
File_1 = dir(fullfile(Samples_Path,'*.sigmf-data'));          % 读取文件夹下满足规则的采样值文件1
disp(length(File_1));
[d_downchirp, d_upchirp] = build_idealchirp(lora_set);
for i = 1:length(File_1)
    File1_Path = strcat(Samples_Path, File_1(i).name);
    fid_1=fopen(File1_Path,'rb');
    [A_1]=fread(fid_1,'float32')';
    A_1_length = size(A_1,2);
    G0 = A_1(1:2:A_1_length-1) + A_1(2:2:A_1_length)*1i;
    [cfo, windows_offset] = get_cfo_winoff(G0, lora_set, d_downchirp, d_upchirp);
%     disp(windows_offset);
%     G0 = circshift(G0, -round(windows_offset)); 
    [d_downchirp_cfo, d_upchirp_cfo] = rebuild_idealchirp_cfo(lora_set, cfo);   % 重新调整理想upchirp和downchirp

    fft_x = lora_set.fft_x;
    dine = lora_set.dine;
    samples = reshape(G0(12.25*dine+1:(lora_set.Pkg_length+0.25)*dine), [dine,lora_set.Pkg_length-12]).';
    samples_dechirp = samples .* d_downchirp_cfo;
    samples_fft = abs(fft(samples_dechirp, dine, 2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine)+samples_fft(:,fft_x/2+1:fft_x)];

    [~, Pkg1_bin] = max(samples_fft_merge, [], 2);
    Pkg1_Verification = load(Verification_path)';
    Pkg1_bin = Pkg1_bin';
    a = sum(Pkg1_Verification == Pkg1_bin);
    
    if a ~= lora_set.Pkg_length-12
        disp(File_1(i).name);
%         disp(windows_offset);
    end
end

toc;
fclose all;
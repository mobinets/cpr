fclose all;     %关闭所有matlab打开的文件
tic;            % 打开计时器

sf_array = ["sf7", "sf8", "sf9", "sf10"];
sir_array = ["sir_5", "sir0", "sir5"];
% sf_array = ["sf10"];
% sir_array = ["sir5"];
Config_Path = '.\config\';                                       % 设置配置文件所在路径
for SIR_count = 1:length(sir_array)
    figure(SIR_count);
    for SF_count = 1:length(sf_array)
        accuracy_result_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_accuracy_result'));
        tmp_array = eval(accuracy_result_name);
        single_true1 = zeros(1,20);
        single_true2 = zeros(1,20);
        Nscale_true1 = zeros(1,20);
        Nscale_true2 = zeros(1,20);
        SNR_num = zeros(1,20);
        
        file_name = strcat('node1_', sf_array(SF_count));
        setting_name = strcat(file_name, '.json');
        Setting_File = dir(fullfile(Config_Path, setting_name));     % 配置文件
        Setting_File_Path = strcat(Config_Path, Setting_File.name);
        Setting_file = fopen(Setting_File_Path,'r');
        setting = jsondecode(fscanf(Setting_file,'%s'));                % 解析json格式变量
        payload_length = setting.captures.lora_pkg_length - 12;
        
        Nscale_true1_tmp = zeros(0);
        Nscale_true2_tmp = zeros(0);
        for i = 1:size(tmp_array, 2)
            SNR = tmp_array(1, i);
            SNR_num(round((60 + SNR)/5)) = SNR_num(round((60 + SNR)/5)) + payload_length;
            single_true1(round((60 + SNR)/5)) = single_true1(round((60 + SNR)/5)) + tmp_array(2, i);
            single_true2(round((60 + SNR)/5)) = single_true2(round((60 + SNR)/5)) + tmp_array(3, i);
            Nscale_true1(round((60 + SNR)/5)) = Nscale_true1(round((60 + SNR)/5)) + tmp_array(4, i);
            Nscale_true2(round((60 + SNR)/5)) = Nscale_true2(round((60 + SNR)/5)) + tmp_array(5, i);
            if SNR >= 10
                Nscale_true1_tmp = [Nscale_true1_tmp, tmp_array(4, i)];
                Nscale_true2_tmp = [Nscale_true2_tmp, tmp_array(5, i)];
            end
        end
%         subplot(2,1,1);
%         plot(Nscale_true1_tmp,'*');
%         subplot(2,1,2);
%         plot(Nscale_true2_tmp,'*');
        x = -55 : 5 : -60 + 5*20;
        subplot(2,2,SF_count);
        plot(x, single_true1./SNR_num,'b'); hold on;
        plot(x, Nscale_true1./SNR_num,'r'); hold on;
        plot(x, single_true2./SNR_num,'b--'); hold on;
        plot(x, Nscale_true2./SNR_num,'r--'); hold on;
    end
    legend('Single-true1','Nscale-true1','Single-true2','Nscale-true2');
end

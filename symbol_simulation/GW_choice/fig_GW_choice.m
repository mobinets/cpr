% 寻找多网关选择策略阈值
sf_array = ["sf7", "sf8", "sf9", "sf10"];
sir_array = ["sir_5", "sir0", "sir5"];
times = 100;
for SIR_count = 1:length(sir_array)
    figure(SIR_count);
    for SF_count = 1:length(sf_array)
        sinGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_sinGW_true'));
        SNR_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_SNR_arr'));
        posGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_posGW_arr'));
        binGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_binGW_arr'));
        argGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_argGW_arr'));
        Nscale_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_Nscale_true'));
        mulGW_num_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_num'));
        mulGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_true'));
        mulGW_state_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_state'));
        a_sinGW_true = eval(sinGW_true_name);
        a_SNR_arr = eval(SNR_arr_name);
        a_posGW_arr = eval(posGW_arr_name);
        a_binGW_arr = eval(binGW_arr_name);
        a_argGW_arr = eval(argGW_arr_name);
        a_Nscale_true = eval(Nscale_true_name);
        a_mulGW_num = eval(mulGW_num_name);
        a_mulGW_true = eval(mulGW_true_name);
        a_mulGW_state = eval(mulGW_state_name);
        [GW_choice_2_result, GW_choice_3_result, GW_choice_4_result, GW_choice_5_result, GW_choice_6_result, GW_choice_7_result] = get_choice_result(a_mulGW_state, a_mulGW_true, a_argGW_arr, times);
        [GW_opt_2_result, GW_opt_3_result, GW_opt_4_result, GW_opt_5_result, GW_opt_6_result, GW_opt_7_result, single_opt_2_result, single_opt_3_result, single_opt_4_result, single_opt_5_result, single_opt_6_result, single_opt_7_result] = get_opt_single_result(a_mulGW_state, a_mulGW_true, a_Nscale_true, times);
        % 最优策略
        file_name = strcat('node1_', sf_array(SF_count));
        setting_name = strcat(file_name, '.json');
        Config_Path = '.\config\';                                       % 设置配置文件所在路径
        Setting_File = dir(fullfile(Config_Path, setting_name));     % 配置文件
        Setting_File_Path = strcat(Config_Path, Setting_File.name);
        Setting_file = fopen(Setting_File_Path,'r');
        setting = jsondecode(fscanf(Setting_file,'%s'));                % 解析json格式变量
        payload_num = setting.captures.lora_pkg_length - 12;                  % 设置接收数据包的长度
        GW2 = mean(GW_opt_2_result) / payload_num;
        GW3 = mean(GW_opt_3_result) / payload_num;
        GW4 = mean(GW_opt_4_result) / payload_num;
        GW5 = mean(GW_opt_5_result) / payload_num;
        GW6 = mean(GW_opt_6_result) / payload_num;
        GW7 = mean(GW_opt_7_result) / payload_num;
        subplot(2,2,SF_count);
        plot(2:7, [GW2, GW3, GW4, GW5, GW6, GW7], 'r');  hold on;
        % 全叠加策略
        % GW2_add = sum(a_mulGW_true(2,1:21:21*times)) / times / 2 / payload_num;
        % GW3_add = sum(a_mulGW_true(3,1:31:31*times)) / times / 2 / payload_num;
        % GW4_add = sum(a_mulGW_true(4,1:31:31*times)) / times / 2 / payload_num;
        % GW5_add = sum(a_mulGW_true(5,1:21:21*times)) / times / 2 / payload_num;
        % GW6_add = sum(a_mulGW_true(6,1:7:7*times)) / times / 2 / payload_num;
        % GW7_add = sum(a_mulGW_true(7,:)) / times / 2 / payload_num;
        GW2_add = sum(a_mulGW_true(2:7:7*(times-1)+2, 1)) / times / 2 / payload_num;
        GW3_add = sum(a_mulGW_true(3:7:7*(times-1)+3, 1)) / times / 2 / payload_num;
        GW4_add = sum(a_mulGW_true(4:7:7*(times-1)+4, 1)) / times / 2 / payload_num;
        GW5_add = sum(a_mulGW_true(5:7:7*(times-1)+5, 1)) / times / 2 / payload_num;
        GW6_add = sum(a_mulGW_true(6:7:7*(times-1)+6, 1)) / times / 2 / payload_num;
        GW7_add = sum(a_mulGW_true(7:7:7*(times-1)+7, 1)) / times / 2 / payload_num;
        subplot(2,2,SF_count);
        plot(2:7, [GW2_add, GW3_add, GW4_add, GW5_add, GW6_add, GW7_add], 'b');  hold on;
        % 单网关最优
        single2 = mean(single_opt_2_result) / payload_num;
        single3 = mean(single_opt_3_result) / payload_num;
        single4 = mean(single_opt_4_result) / payload_num;
        single5 = mean(single_opt_5_result) / payload_num;
        single6 = mean(single_opt_6_result) / payload_num;
        single7 = mean(single_opt_7_result) / payload_num;
        subplot(2,2,SF_count);
        plot(2:7, [single2, single3, single4, single5, single6, single7], 'g');  hold on;
        % 选择策略
        choice2 = mean(GW_choice_2_result) / payload_num;
        choice3 = mean(GW_choice_3_result) / payload_num;
        choice4 = mean(GW_choice_4_result) / payload_num;
        choice5 = mean(GW_choice_5_result) / payload_num;
        choice6 = mean(GW_choice_6_result) / payload_num;
        choice7 = mean(GW_choice_7_result) / payload_num;
        subplot(2,2,SF_count);
        plot(2:7, [choice2, choice3, choice4, choice5, choice6, choice7], 'k');  hold on;
    end
    legend('opt','strawman','Nscale','choice');
end
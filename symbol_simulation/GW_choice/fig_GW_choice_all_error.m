% 寻找多网关选择策略阈值
% pkg_array = ["pkg1", "pkg2"];
% sf_array = ["sf7", "sf8", "sf9", "sf10"];
% sir_array = ["sir_5", "sir0", "sir5"];
pkg_array = ["pkg2"];
sf_array = ["sf10"];
sir_array = ["sir5"];
times = 590;
for pkg_count = 1:length(pkg_array)
    for SIR_count = 1:length(sir_array)
        figure(SIR_count + 3*(pkg_count-1));
        for SF_count = 1:length(sf_array)
%             sinGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_sinGW_true'));
%             SNR_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_SNR_arr'));
%             posGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_posGW_arr'));
%             binGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_binGW_arr'));
%             argGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_argGW_arr'));
%             Nscale_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_Nscale_true'));
%             mulGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_true'));
%             mulGW_state_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_state'));
%             a_sinGW_true = eval(sinGW_true_name);
%             a_SNR_arr = eval(SNR_arr_name);
%             a_posGW_arr = eval(posGW_arr_name);
%             a_binGW_arr = eval(binGW_arr_name);
%             a_argGW_arr = eval(argGW_arr_name);
%             a_Nscale_true = eval(Nscale_true_name);
%             a_mulGW_true = eval(mulGW_true_name);
%             a_mulGW_state = eval(mulGW_state_name);
            % [GW_choice_result] = get_choice_result(a_mulGW_state, a_mulGW_true, a_argGW_arr, times, SIR_count);
%             [GW_opt_result, Nscale_opt_result, single_opt_result, GW_opt_choice_result] = get_opt_single_result(a_mulGW_state, a_mulGW_true, a_Nscale_true, a_sinGW_true, times, pkg_array(pkg_count));
            [GW_opt_result, single_opt_result, GW_opt_choice_result] = get_opt_GT(a_mulGW_state, a_mulGW_true, a_sinGW_true, times, pkg_array(pkg_count));
            % 最优策略
            file_name = strcat('node1_', sf_array(SF_count));
            setting_name = strcat(file_name, '.json');
            Config_Path = '.\config\';                                       % 设置配置文件所在路径
            Setting_File = dir(fullfile(Config_Path, setting_name));     % 配置文件
            Setting_File_Path = strcat(Config_Path, Setting_File.name);
            Setting_file = fopen(Setting_File_Path,'r');
            setting = jsondecode(fscanf(Setting_file,'%s'));                % 解析json格式变量
            payload_num = setting.captures.lora_pkg_length - 12;                  % 设置接收数据包的长度
            SNR_example = zeros(0);
            pos_example = zeros(0);
            bin_example = zeros(0);
            true1_example = zeros(0);
            true1_example_gt = zeros(0);
            true2_example = zeros(0);
            true2_example_gt = zeros(0);
%             a_argGW_arr = normalize(a_argGW_arr, 1, 'range');
            for SNR_count = 1:times
                tmp = GW_opt_choice_result(6, SNR_count);
                GW_bin = bitget(tmp, 1:7);
                tmp_tmp = sum(GW_bin);
                if sum(GW_bin) > 1
                    boost_num = GW_opt_result(6, SNR_count) - single_opt_result(6, SNR_count);
                    if boost_num > 5
                        SNR_example = [SNR_example, (GW_bin .* a_SNR_arr(SNR_count, :))'];
                        pos_example = [pos_example, (GW_bin .* a_posGW_arr(SNR_count, :))'];
                        bin_example = [bin_example, (GW_bin .* a_binGW_arr(SNR_count, :))'];
                        true1_example = [true1_example, (GW_bin .* a_sinGW_true(SNR_count, 1:2:14-1))'];
                        true1_example_gt = [true1_example_gt, a_sinGW_true(SNR_count, 1:2:14-1)'];
                        true2_example = [true2_example, (GW_bin .* a_sinGW_true(SNR_count, 2:2:14))'];
                        true2_example_gt = [true2_example_gt, a_sinGW_true(SNR_count, 2:2:14)'];
                    end
                end
            end
            subplot(2,2,SF_count);
            plot(1:size(SNR_example, 2), SNR_example, '.');
        end
    end
end
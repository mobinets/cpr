% 寻找多网关选择策略阈值
% pkg_array = ["pkg1", "pkg2"];
% sf_array = ["sf7", "sf8", "sf9", "sf10"];
% sir_array = ["sir_5", "sir0", "sir5"];
pkg_array = ["pkg2"];
sf_array = ["sf8", "sf9", "sf10"];
sir_array = ["sir5"];
times = 1000;
DEBUG = false;
result_array = zeros(6, 12);
for pkg_count = 1:length(pkg_array)
    for SIR_count = 1:length(sir_array)
        figure(SIR_count + 3*(pkg_count-1));
        for SF_count = 1:length(sf_array)
%             for arg_test = 0.0:0.05:1
%                 arg_test = 0.65;
                if sf_array(SF_count) == "sf8"
                    arg_test = 0.65;
                else
                    arg_test = 0.55;
                end
                sinGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_sinGW_true'));
                SNR_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_SNR_arr'));
                posGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_posGW_arr'));
                binGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_binGW_arr'));
                mulGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_true'));
                mulGW_state_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_state'));
                argGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_argGW_arr'));
                a_sinGW_true = eval(sinGW_true_name);
                a_SNR_arr = eval(SNR_arr_name);
                a_posGW_arr = eval(posGW_arr_name);
                a_binGW_arr = eval(binGW_arr_name);
                a_mulGW_true = eval(mulGW_true_name);
                a_mulGW_state = eval(mulGW_state_name);
                a_argGW_arr = eval(argGW_arr_name);
                for i = 1:times
                    a_argGW_arr(7*(i-1)+1: 7*i, 14) = a_posGW_arr(i, 1:7);
                    a_argGW_arr(7*(i-1)+1: 7*i, 15) = a_binGW_arr(i, 1:7);
                end
    
                % 最优策略
                [GW_choice_result] = get_choice_result(a_mulGW_state, a_mulGW_true, a_argGW_arr, times, sir_array(SIR_count), pkg_array(pkg_count), arg_test);
                % [GW_opt_result, GW_opt_choice_result] = get_opt_GT(a_mulGW_state, a_mulGW_true, a_sinGW_true, times, pkg_array(pkg_count));
    
                % 获得参数
                file_name = strcat('node1_', sf_array(SF_count));
                setting_name = strcat(file_name, '.json');
                Config_Path = '.\config\';                                       % 设置配置文件所在路径
                Setting_File = dir(fullfile(Config_Path, setting_name));     % 配置文件
                Setting_File_Path = strcat(Config_Path, Setting_File.name);
                Setting_file = fopen(Setting_File_Path,'r');
                setting = jsondecode(fscanf(Setting_file,'%s'));                % 解析json格式变量
                payload_num = setting.captures.lora_pkg_length - 12;                  % 设置接收数据包的长度
                
                % debug
                payload_num = payload_num - 1;
                % 多网关最优
                if pkg_array(pkg_count) == "pkg1"
                    GW2 = mean(max([a_sinGW_true(1:times, 1:2:3), a_mulGW_true(2:7:7*(times-1)+2, 1)], [], 2));
                    GW3 = mean(max([a_sinGW_true(1:times, 1:2:5), a_mulGW_true(2:7:7*(times-1)+2, 1:2:1*3), a_mulGW_true(3:7:7*(times-1)+3, 1)], [], 2));
                    GW4 = mean(max([a_sinGW_true(1:times, 1:2:7), a_mulGW_true(2:7:7*(times-1)+2, 1:2:1*6), a_mulGW_true(3:7:7*(times-1)+3, 1:2:1*4), a_mulGW_true(4:7:7*(times-1)+4, 1)], [], 2));
                    GW5 = mean(max([a_sinGW_true(1:times, 1:2:9), a_mulGW_true(2:7:7*(times-1)+2, 1:2:1*10), a_mulGW_true(3:7:7*(times-1)+3, 1:2:1*10), a_mulGW_true(4:7:7*(times-1)+4, 1:2:1*5), a_mulGW_true(5:7:7*(times-1)+5, 1)], [], 2));
                    GW6 = mean(max([a_sinGW_true(1:times, 1:2:11), a_mulGW_true(2:7:7*(times-1)+2, 1:2:1*15), a_mulGW_true(3:7:7*(times-1)+3, 1:2:1*20), a_mulGW_true(4:7:7*(times-1)+4, 1:2:1*15), a_mulGW_true(5:7:7*(times-1)+5, 1:2:1*6), a_mulGW_true(6:7:7*(times-1)+6, 1)], [], 2));
                    GW7 = mean(max([a_sinGW_true(1:times, 1:2:13), a_mulGW_true(2:7:7*(times-1)+2, 1:2:1*21), a_mulGW_true(3:7:7*(times-1)+3, 1:2:1*35), a_mulGW_true(4:7:7*(times-1)+4, 1:2:1*35), a_mulGW_true(5:7:7*(times-1)+5, 1:2:1*21), a_mulGW_true(6:7:7*(times-1)+6, 1:2:1*7), a_mulGW_true(7:7:7*(times-1)+7, 1)], [], 2));

                elseif pkg_array(pkg_count) == "pkg2"
                    GW2 = mean(max([a_sinGW_true(1:times, 2:2:4), a_mulGW_true(2:7:7*(times-1)+2, 2)], [], 2) >= payload_num);
                    GW3 = mean(max([a_sinGW_true(1:times, 2:2:6), a_mulGW_true(2:7:7*(times-1)+2, 2:2:2*3), a_mulGW_true(3:7:7*(times-1)+3, 2)], [], 2) >= payload_num);
                    GW4 = mean(max([a_sinGW_true(1:times, 2:2:8), a_mulGW_true(2:7:7*(times-1)+2, 2:2:2*6), a_mulGW_true(3:7:7*(times-1)+3, 2:2:2*4), a_mulGW_true(4:7:7*(times-1)+4, 2)], [], 2) >= payload_num);
                    GW5 = mean(max([a_sinGW_true(1:times, 2:2:10), a_mulGW_true(2:7:7*(times-1)+2, 2:2:2*10), a_mulGW_true(3:7:7*(times-1)+3, 2:2:2*10), a_mulGW_true(4:7:7*(times-1)+4, 2:2:2*5), a_mulGW_true(5:7:7*(times-1)+5, 2)], [], 2) >= payload_num);
                    GW6 = mean(max([a_sinGW_true(1:times, 2:2:12), a_mulGW_true(2:7:7*(times-1)+2, 2:2:2*15), a_mulGW_true(3:7:7*(times-1)+3, 2:2:2*20), a_mulGW_true(4:7:7*(times-1)+4, 2:2:2*15), a_mulGW_true(5:7:7*(times-1)+5, 2:2:2*6), a_mulGW_true(6:7:7*(times-1)+6, 2)], [], 2) >= payload_num);
                    GW7 = mean(max([a_sinGW_true(1:times, 2:2:14), a_mulGW_true(2:7:7*(times-1)+2, 2:2:2*21), a_mulGW_true(3:7:7*(times-1)+3, 2:2:2*35), a_mulGW_true(4:7:7*(times-1)+4, 2:2:2*35), a_mulGW_true(5:7:7*(times-1)+5, 2:2:2*21), a_mulGW_true(6:7:7*(times-1)+6, 2:2:2*7), a_mulGW_true(7:7:7*(times-1)+7, 2)], [], 2) >= payload_num);

%                     GW2 = sum(max([a_sinGW_true(1:times, 2:2:4), a_mulGW_true(2:7:7*(times-1)+2, 2)], [], 2)) / times / payload_num;
%                     GW3 = sum(max([a_sinGW_true(1:times, 2:2:6), a_mulGW_true(3:7:7*(times-1)+3, 2)], [], 2)) / times / payload_num;
%                     GW4 = sum(max([a_sinGW_true(1:times, 2:2:8), a_mulGW_true(4:7:7*(times-1)+4, 2)], [], 2)) / times / payload_num;
%                     GW5 = sum(max([a_sinGW_true(1:times, 2:2:10), a_mulGW_true(5:7:7*(times-1)+5, 2)], [], 2)) / times / payload_num;
%                     GW6 = sum(max([a_sinGW_true(1:times, 2:2:12), a_mulGW_true(6:7:7*(times-1)+6, 2)], [], 2)) / times / payload_num;
%                     GW7 = sum(max([a_sinGW_true(1:times, 2:2:14), a_mulGW_true(7:7:7*(times-1)+7, 2)], [], 2)) / times / payload_num;
                else
                    GW2 = sum(max([a_sinGW_true(1:times, 1:4), a_mulGW_true(2:7:7*(times-1)+2, 2)], [], 2)) / times / payload_num;
                    GW3 = sum(max([a_sinGW_true(1:times, 1:6), a_mulGW_true(3:7:7*(times-1)+3, 2)], [], 2)) / times / payload_num;
                    GW4 = sum(max([a_sinGW_true(1:times, 1:8), a_mulGW_true(4:7:7*(times-1)+4, 2)], [], 2)) / times / payload_num;
                    GW5 = sum(max([a_sinGW_true(1:times, 1:10), a_mulGW_true(5:7:7*(times-1)+5, 2)], [], 2)) / times / payload_num;
                    GW6 = sum(max([a_sinGW_true(1:times, 1:12), a_mulGW_true(6:7:7*(times-1)+6, 2)], [], 2)) / times / payload_num;
                    GW7 = sum(max([a_sinGW_true(1:times, 1:14), a_mulGW_true(7:7:7*(times-1)+7, 2)], [], 2)) / times / payload_num;
                end
                if DEBUG == false
                    subplot(2,2,SF_count);
                    plot(2:7, [GW2, GW3, GW4, GW5, GW6, GW7], 'r');  hold on;
                end
    
                % 全叠加策略
                if pkg_array(pkg_count) == "pkg1"
                    GW2_add = sum(a_mulGW_true(2:7:7*(times-1)+2, 1)) / times / payload_num;
                    GW3_add = sum(a_mulGW_true(3:7:7*(times-1)+3, 1)) / times / payload_num;
                    GW4_add = sum(a_mulGW_true(4:7:7*(times-1)+4, 1)) / times / payload_num;
                    GW5_add = sum(a_mulGW_true(5:7:7*(times-1)+5, 1)) / times / payload_num;
                    GW6_add = sum(a_mulGW_true(6:7:7*(times-1)+6, 1)) / times / payload_num;
                    GW7_add = sum(a_mulGW_true(7:7:7*(times-1)+7, 1)) / times / payload_num;
                elseif pkg_array(pkg_count) == "pkg2"
                    GW2_add = sum(a_mulGW_true(2:7:7*(times-1)+2, 2) >= payload_num) / times;
                    GW3_add = sum(a_mulGW_true(3:7:7*(times-1)+3, 2) >= payload_num) / times;
                    GW4_add = sum(a_mulGW_true(4:7:7*(times-1)+4, 2) >= payload_num) / times;
                    GW5_add = sum(a_mulGW_true(5:7:7*(times-1)+5, 2) >= payload_num) / times;
                    GW6_add = sum(a_mulGW_true(6:7:7*(times-1)+6, 2) >= payload_num) / times;
                    GW7_add = sum(a_mulGW_true(7:7:7*(times-1)+7, 2) >= payload_num) / times;

%                     GW2_add = sum(a_mulGW_true(2:7:7*(times-1)+2, 2)) / times / payload_num;
%                     GW3_add = sum(a_mulGW_true(3:7:7*(times-1)+3, 2)) / times / payload_num;
%                     GW4_add = sum(a_mulGW_true(4:7:7*(times-1)+4, 2)) / times / payload_num;
%                     GW5_add = sum(a_mulGW_true(5:7:7*(times-1)+5, 2)) / times / payload_num;
%                     GW6_add = sum(a_mulGW_true(6:7:7*(times-1)+6, 2)) / times / payload_num;
%                     GW7_add = sum(a_mulGW_true(7:7:7*(times-1)+7, 2)) / times / payload_num;
                else
                    GW2_add = sum(a_mulGW_true(2:7:7*(times-1)+2, [1,2])) / times / 2 / payload_num;
                    GW3_add = sum(a_mulGW_true(3:7:7*(times-1)+3, [1,2])) / times / 2 / payload_num;
                    GW4_add = sum(a_mulGW_true(4:7:7*(times-1)+4, [1,2])) / times / 2 / payload_num;
                    GW5_add = sum(a_mulGW_true(5:7:7*(times-1)+5, [1,2])) / times / 2 / payload_num;
                    GW6_add = sum(a_mulGW_true(6:7:7*(times-1)+6, [1,2])) / times / 2 / payload_num;
                    GW7_add = sum(a_mulGW_true(7:7:7*(times-1)+7, [1,2])) / times / 2 / payload_num;
                end 
                if DEBUG == false
                    subplot(2,2,SF_count);
                    plot(2:7, [GW2_add, GW3_add, GW4_add, GW5_add, GW6_add, GW7_add], 'b');  hold on;
                end
    
                % 单网关最优
                if pkg_array(pkg_count) == "pkg1"
                    single2 = mean(max(a_sinGW_true(1:times, 1:2:3), [], 2)) / payload_num;
                    single3 = mean(max(a_sinGW_true(1:times, 1:2:5), [], 2)) / payload_num;
                    single4 = mean(max(a_sinGW_true(1:times, 1:2:7), [], 2)) / payload_num;
                    single5 = mean(max(a_sinGW_true(1:times, 1:2:9), [], 2)) / payload_num;
                    single6 = mean(max(a_sinGW_true(1:times, 1:2:11), [], 2)) / payload_num;
                    single7 = mean(max(a_sinGW_true(1:times, 1:2:13), [], 2)) / payload_num;
                elseif pkg_array(pkg_count) == "pkg2"
                    single2 = mean(max(a_sinGW_true(1:times, 2:2:4), [], 2) >= payload_num);
                    single3 = mean(max(a_sinGW_true(1:times, 2:2:6), [], 2) >= payload_num);
                    single4 = mean(max(a_sinGW_true(1:times, 2:2:8), [], 2) >= payload_num);
                    single5 = mean(max(a_sinGW_true(1:times, 2:2:10), [], 2) >= payload_num);
                    single6 = mean(max(a_sinGW_true(1:times, 2:2:12), [], 2) >= payload_num);
                    single7 = mean(max(a_sinGW_true(1:times, 2:2:14), [], 2) >= payload_num);
                    
%                     single2 = mean(max(a_sinGW_true(1:times, 2:2:4), [], 2)) / payload_num;
%                     single3 = mean(max(a_sinGW_true(1:times, 2:2:6), [], 2)) / payload_num;
%                     single4 = mean(max(a_sinGW_true(1:times, 2:2:8), [], 2)) / payload_num;
%                     single5 = mean(max(a_sinGW_true(1:times, 2:2:10), [], 2)) / payload_num;
%                     single6 = mean(max(a_sinGW_true(1:times, 2:2:12), [], 2)) / payload_num;
%                     single7 = mean(max(a_sinGW_true(1:times, 2:2:14), [], 2)) / payload_num;
                else
                    single2 = mean(max(a_sinGW_true(1:times, 1:4), [], 2)) / payload_num / 2;
                    single3 = mean(max(a_sinGW_true(1:times, 1:6), [], 2)) / payload_num / 2;
                    single4 = mean(max(a_sinGW_true(1:times, 1:8), [], 2)) / payload_num / 2;
                    single5 = mean(max(a_sinGW_true(1:times, 1:10), [], 2)) / payload_num / 2;
                    single6 = mean(max(a_sinGW_true(1:times, 1:12), [], 2)) / payload_num / 2;
                    single7 = mean(max(a_sinGW_true(1:times, 1:14), [], 2)) / payload_num / 2;
                end 
                if DEBUG == false
                    subplot(2,2,SF_count);
                    plot(2:7, [single2, single3, single4, single5, single6, single7], 'p');  hold on;
                end

                choice2 = mean(GW_choice_result(1, :) >= payload_num);
                choice3 = mean(GW_choice_result(2, :) >= payload_num);
                choice4 = mean(GW_choice_result(3, :) >= payload_num);
                choice5 = mean(GW_choice_result(4, :) >= payload_num);
                choice6 = mean(GW_choice_result(5, :) >= payload_num);
                choice7 = mean(GW_choice_result(6, :) >= payload_num);
                
%                 choice2 = mean(GW_choice_result(1, :)) / payload_num;
%                 choice3 = mean(GW_choice_result(2, :)) / payload_num;
%                 choice4 = mean(GW_choice_result(3, :)) / payload_num;
%                 choice5 = mean(GW_choice_result(4, :)) / payload_num;
%                 choice6 = mean(GW_choice_result(5, :)) / payload_num;
%                 choice7 = mean(GW_choice_result(6, :)) / payload_num;
                if DEBUG == false
                    subplot(2,2,SF_count);
                    plot(2:7, [choice2, choice3, choice4, choice5, choice6, choice7], 'k');  hold on;
                end
                if DEBUG == true
                    dif_sum = sum(choice7 - single7);
                    disp([arg_test, dif_sum]);
                end
                result_array(:, 4*(SF_count-1)+1) = [GW2, GW3, GW4, GW5, GW6, GW7];
                result_array(:, 4*(SF_count-1)+2) = [GW2_add, GW3_add, GW4_add, GW5_add, GW6_add, GW7_add];
                result_array(:, 4*(SF_count-1)+3) = [single2, single3, single4, single5, single6, single7];
                result_array(:, 4*(SF_count-1)+4) = [choice2, choice3, choice4, choice5, choice6, choice7];
%             end
        end
        legend('opt', 'starman', 'single','choice');
        xlabel('网关数目');
        ylabel('SER');
    end
end
function [GW_opt_result, single_opt_result, GW_opt_choice_result, GW_opt_conpos_result, GW_opt_bin_result] = get_opt_GT(a_mulGW_state, a_mulGW_true, a_mulGW_conpos, a_mulGW_bin, a_sinGW_true, times, pkg_name)
    % 多网关最优策略结果记录
    GW_opt_2_result = zeros(0);
    GW_opt_3_result = zeros(0);
    GW_opt_4_result = zeros(0);
    GW_opt_5_result = zeros(0);
    GW_opt_6_result = zeros(0);
    GW_opt_7_result = zeros(0);
    % 多网关最优策略选择结果记录
    GW_opt_choice_2_result = zeros(0);
    GW_opt_choice_3_result = zeros(0);
    GW_opt_choice_4_result = zeros(0);
    GW_opt_choice_5_result = zeros(0);
    GW_opt_choice_6_result = zeros(0);
    GW_opt_choice_7_result = zeros(0);
    % 单网关最优策略结果记录
    single_opt_2_result = zeros(0);
    single_opt_3_result = zeros(0);
    single_opt_4_result = zeros(0);
    single_opt_5_result = zeros(0);
    single_opt_6_result = zeros(0);
    single_opt_7_result = zeros(0);
    % 多网关最优策略conpos记录
    GW_opt_conpos_2_result = zeros(0);
    GW_opt_conpos_3_result = zeros(0);
    GW_opt_conpos_4_result = zeros(0);
    GW_opt_conpos_5_result = zeros(0);
    GW_opt_conpos_6_result = zeros(0);
    GW_opt_conpos_7_result = zeros(0);
    % 多网关最优策略bin记录
    GW_opt_bin_2_result = zeros(0);
    GW_opt_bin_3_result = zeros(0);
    GW_opt_bin_4_result = zeros(0);
    GW_opt_bin_5_result = zeros(0);
    GW_opt_bin_6_result = zeros(0);
    GW_opt_bin_7_result = zeros(0);
    for exp_time = 1:times
        mulGW_state_tmp = zeros(7, 35);
        mulGW_conpos_tmp = zeros(7, 35);
        mulGW_bin_tmp = zeros(7, 35);
        mulGW_true_tmp = zeros(7,35);
        single_true_tmp = zeros(1,7);
        % 提取单次实验的state数据
        mulGW_state_tmp(1, 1:7) = a_mulGW_state(7*(exp_time-1)+1, 1:7);
        mulGW_state_tmp(2, 1:21) = a_mulGW_state(7*(exp_time-1)+2, 1:21);
        mulGW_state_tmp(3, 1:35) = a_mulGW_state(7*(exp_time-1)+3, 1:35);
        mulGW_state_tmp(4, 1:35) = a_mulGW_state(7*(exp_time-1)+4, 1:35);
        mulGW_state_tmp(5, 1:21) = a_mulGW_state(7*(exp_time-1)+5, 1:21);
        mulGW_state_tmp(6, 1:7) = a_mulGW_state(7*(exp_time-1)+6, 1:7);
        mulGW_state_tmp(7, 1) = a_mulGW_state(7*(exp_time-1)+7, 1);
        % 提取单次实验的vonpos数据
        mulGW_conpos_tmp(1, 1:7) = a_mulGW_conpos(7*(exp_time-1)+1, 1:7);
        mulGW_conpos_tmp(2, 1:21) = a_mulGW_conpos(7*(exp_time-1)+2, 1:21);
        mulGW_conpos_tmp(3, 1:35) = a_mulGW_conpos(7*(exp_time-1)+3, 1:35);
        mulGW_conpos_tmp(4, 1:35) = a_mulGW_conpos(7*(exp_time-1)+4, 1:35);
        mulGW_conpos_tmp(5, 1:21) = a_mulGW_conpos(7*(exp_time-1)+5, 1:21);
        mulGW_conpos_tmp(6, 1:7) = a_mulGW_conpos(7*(exp_time-1)+6, 1:7);
        mulGW_conpos_tmp(7, 1) = a_mulGW_conpos(7*(exp_time-1)+7, 1);
        % 提取单次实验的bin数据
        mulGW_bin_tmp(1, 1:7) = a_mulGW_bin(7*(exp_time-1)+1, 1:7);
        mulGW_bin_tmp(2, 1:21) = a_mulGW_bin(7*(exp_time-1)+2, 1:21);
        mulGW_bin_tmp(3, 1:35) = a_mulGW_bin(7*(exp_time-1)+3, 1:35);
        mulGW_bin_tmp(4, 1:35) = a_mulGW_bin(7*(exp_time-1)+4, 1:35);
        mulGW_bin_tmp(5, 1:21) = a_mulGW_bin(7*(exp_time-1)+5, 1:21);
        mulGW_bin_tmp(6, 1:7) = a_mulGW_bin(7*(exp_time-1)+6, 1:7);
        mulGW_bin_tmp(7, 1) = a_mulGW_bin(7*(exp_time-1)+7, 1);
        
        if pkg_name == "pkg1"
            mulGW_true_tmp(1, 1:7) = a_mulGW_true(7*(exp_time-1)+1, 1:2:7*2-1);
            mulGW_true_tmp(2, 1:21) = a_mulGW_true(7*(exp_time-1)+2, 1:2:21*2-1);
            mulGW_true_tmp(3, 1:35) = a_mulGW_true(7*(exp_time-1)+3, 1:2:35*2-1);
            mulGW_true_tmp(4, 1:35) = a_mulGW_true(7*(exp_time-1)+4, 1:2:35*2-1);
            mulGW_true_tmp(5, 1:21) = a_mulGW_true(7*(exp_time-1)+5, 1:2:21*2-1);
            mulGW_true_tmp(6, 1:7) = a_mulGW_true(7*(exp_time-1)+6, 1:2:7*2-1);
            mulGW_true_tmp(7, 1) = a_mulGW_true(7*(exp_time-1)+7, 1);
            single_true_tmp(1:7) = a_sinGW_true(exp_time, 1:2:2*7-1);
        elseif pkg_name == "pkg2"
            mulGW_true_tmp(1, 1:7) =  a_mulGW_true(7*(exp_time-1)+1, 2:2:7*2);
            mulGW_true_tmp(2, 1:21) = a_mulGW_true(7*(exp_time-1)+2, 2:2:21*2);
            mulGW_true_tmp(3, 1:35) = a_mulGW_true(7*(exp_time-1)+3, 2:2:35*2);
            mulGW_true_tmp(4, 1:35) = a_mulGW_true(7*(exp_time-1)+4, 2:2:35*2);
            mulGW_true_tmp(5, 1:21) = a_mulGW_true(7*(exp_time-1)+5, 2:2:21*2);
            mulGW_true_tmp(6, 1:7) =  a_mulGW_true(7*(exp_time-1)+6, 2:2:7*2);
            mulGW_true_tmp(7, 1) = a_mulGW_true(7*(exp_time-1)+7, 2);
            single_true_tmp(1:7) = a_sinGW_true(exp_time, 2:2:2*7);
        else
            mulGW_true_tmp(1, 1:7) = (a_mulGW_true(7*(exp_time-1)+1, 1:2:7*2-1) + a_mulGW_true(7*(exp_time-1)+1, 2:2:7*2))/2;
            mulGW_true_tmp(2, 1:21) = (a_mulGW_true(7*(exp_time-1)+2, 1:2:21*2-1) + a_mulGW_true(7*(exp_time-1)+2, 2:2:21*2))/2;
            mulGW_true_tmp(3, 1:35) = (a_mulGW_true(7*(exp_time-1)+3, 1:2:35*2-1) + a_mulGW_true(7*(exp_time-1)+3, 2:2:35*2))/2;
            mulGW_true_tmp(4, 1:35) = (a_mulGW_true(7*(exp_time-1)+4, 1:2:35*2-1) + a_mulGW_true(7*(exp_time-1)+4, 2:2:35*2))/2;
            mulGW_true_tmp(5, 1:21) = (a_mulGW_true(7*(exp_time-1)+5, 1:2:21*2-1) + a_mulGW_true(7*(exp_time-1)+5, 2:2:21*2))/2;
            mulGW_true_tmp(6, 1:7) = (a_mulGW_true(7*(exp_time-1)+6, 1:2:7*2-1) + a_mulGW_true(7*(exp_time-1)+6, 2:2:7*2))/2;
            mulGW_true_tmp(7, 1) = (a_mulGW_true(7*(exp_time-1)+7, 1) + a_mulGW_true(7*(exp_time-1)+7, 2))/2;
            single_true_tmp(1:7) = (a_sinGW_true(exp_time, 1:2:2*7-1) + a_sinGW_true(exp_time, 2:2:2*7))/2;
        end
        
        % 2网关最优
        GW_opt_2 = zeros(2, 21);
        GW_opt_2_choice = zeros(1, 21);
        GW_opt_2_conpos = zeros(1, 21); % 记录多网关冲突发现位置
        GW_opt_2_bin = zeros(1, 21); % 记录多网关冲突发现bin
        single_opt_2 = zeros(1,21);
        for i = 1:21
            GW_bin = bitget(mulGW_state_tmp(2, i),1:7);
            a = find(GW_bin > 0);
            result = [mulGW_true_tmp(1, a)];
            choice_can = [mulGW_state_tmp(1, a), mulGW_state_tmp(2, i)];  % 提取符合这次网关的所有选择
            conpos_can = [mulGW_conpos_tmp(1, a), mulGW_conpos_tmp(2, i)];  % 提取符合这次网关的所有conpos
            bin_can = [mulGW_bin_tmp(1, a), mulGW_bin_tmp(1, a)]; % 提取符合这次网关的所有bin
            [GW_opt_2(2,i), choice_pos] = max([result, mulGW_true_tmp(2, i)]);  % 找到正确率最高的结果
            
            GW_opt_2_choice(i) = choice_can(choice_pos);    % 记录正确率最高的选择
            GW_opt_2_conpos(i) = conpos_can(choice_pos);    % 记录正确率最高的conpos
            GW_opt_2_bin(i) = bin_can(choice_pos);  % 记录正确率最高的bin
            GW_opt_2(1,i) = mulGW_state_tmp(2, i);
            single_opt_2(i) = max(single_true_tmp(a));
        end

        % 3网关最优
        GW_opt_3 = zeros(2, 35);
        GW_opt_3_choice = zeros(1, 35);
        GW_opt_3_conpos = zeros(1, 35); % 记录多网关冲突发现位置
        GW_opt_3_bin = zeros(1, 35); % 记录多网关冲突发现bin
        single_opt_3 = zeros(1, 35);
        for i = 1:35
            GW_bin = bitget(mulGW_state_tmp(3, i),1:7);
            a = find(GW_bin == 0);
            result = zeros(0);
            result_pos = zeros(0);
            result_conpos = zeros(0);
            result_bin = zeros(0);
            result_pos = [result_pos, mulGW_state_tmp(3, i)];
            result_conpos = [result_conpos, mulGW_conpos_tmp(3, i)];
            result_bin = [result_bin, mulGW_bin_tmp(3, i)];
            for j = 1:size(GW_opt_2, 2)
                bin = bitget(GW_opt_2(1, j), 1:7);
                if bin(a) == 0
                    result = [result, GW_opt_2(2, j)];
                    result_pos = [result_pos, GW_opt_2_choice(j)];  % 记录位置
                    result_conpos = [result_conpos, GW_opt_2_conpos(j)];
                    result_bin = [result_bin, GW_opt_2_bin(j)];
                end
            end
            [GW_opt_3(2,i), choice_pos] = max([mulGW_true_tmp(3, i), result]);
            GW_opt_3_choice(i) = result_pos(choice_pos);    % 记录正确率最高的选择
            GW_opt_3_conpos(i) = result_conpos(choice_pos);    % 记录正确率最高的conpos
            GW_opt_3_bin(i) = result_bin(choice_pos);  % 记录正确率最高的bin
            GW_opt_3(1,i) = mulGW_state_tmp(3, i);
            % 单网关
            b = find(GW_bin > 0);
            single_opt_3(i) = max(single_true_tmp(b));
        end

        % 4网关最优
        GW_opt_4 = zeros(2, 35);
        GW_opt_4_choice = zeros(1, 35);
        GW_opt_4_conpos = zeros(1, 35); % 记录多网关冲突发现位置
        GW_opt_4_bin = zeros(1, 35); % 记录多网关冲突发现bin
        single_opt_4 = zeros(1, 35);
        for i = 1:35
            GW_bin = bitget(mulGW_state_tmp(4, i),1:7);
            a = find(GW_bin == 0);
            result = zeros(0);
            result_pos = zeros(0);
            result_conpos = zeros(0);
            result_bin = zeros(0);
            result_pos = [result_pos, mulGW_state_tmp(4, i)];
            result_conpos = [result_conpos, mulGW_conpos_tmp(4, i)];
            result_bin = [result_bin, mulGW_bin_tmp(4, i)];
            for j = 1:size(GW_opt_3, 2)
                bin = bitget(GW_opt_3(1, j), 1:7);
                if bin(a) == 0
                    result = [result, GW_opt_3(2, j)];
                    result_pos = [result_pos, GW_opt_3_choice(j)];  % 记录位置
                    result_conpos = [result_conpos, GW_opt_3_conpos(j)];
                    result_bin = [result_bin, GW_opt_3_bin(j)];
                end
            end
            
            [GW_opt_4(2,i), choice_pos] = max([mulGW_true_tmp(4, i), result]);
            GW_opt_4_choice(i) = result_pos(choice_pos);    % 记录正确率最高的选择
            GW_opt_4_conpos(i) = result_conpos(choice_pos);    % 记录正确率最高的conpos
            GW_opt_4_bin(i) = result_bin(choice_pos);  % 记录正确率最高的bin
            GW_opt_4(1,i) = mulGW_state_tmp(4, i);
            % 单网关
            b = find(GW_bin > 0);
            single_opt_4(i) = max(single_true_tmp(b));
        end

        % 5网关最优
        GW_opt_5 = zeros(2, 21);
        GW_opt_5_choice = zeros(1, 21);
        GW_opt_5_conpos = zeros(1, 21); % 记录多网关冲突发现位置
        GW_opt_5_bin = zeros(1, 21); % 记录多网关冲突发现bin
        single_opt_5 = zeros(1, 21);
        for i = 1:21
            GW_bin = bitget(mulGW_state_tmp(5, i),1:7);
            a = find(GW_bin == 0);
            result = zeros(0);
            result_pos = zeros(0);
            result_conpos = zeros(0);
            result_bin = zeros(0);
            result_pos = [result_pos, mulGW_state_tmp(5, i)];
            result_conpos = [result_conpos, mulGW_conpos_tmp(5, i)];
            result_bin = [result_bin, mulGW_bin_tmp(5, i)];
            for j = 1:size(GW_opt_4, 2)
                bin = bitget(GW_opt_4(1, j), 1:7);
                if bin(a) == 0
                    result = [result, GW_opt_4(2, j)];
                    result_pos = [result_pos, GW_opt_4_choice(j)];  % 记录位置
                    result_conpos = [result_conpos, GW_opt_4_conpos(j)];
                    result_bin = [result_bin, GW_opt_4_bin(j)];
                end
            end
            
            [GW_opt_5(2,i), choice_pos] = max([mulGW_true_tmp(5, i), result]);
            GW_opt_5_choice(i) = result_pos(choice_pos);    % 记录正确率最高的选择
            GW_opt_5_conpos(i) = result_conpos(choice_pos);    % 记录正确率最高的conpos
            GW_opt_5_bin(i) = result_bin(choice_pos);  % 记录正确率最高的bin
            GW_opt_5(1,i) = mulGW_state_tmp(5, i);
            % 单网关
            b = find(GW_bin > 0);
            single_opt_5(i) = max(single_true_tmp(b));
        end

        % 6网关最优
        GW_opt_6 = zeros(2, 7);
        GW_opt_6_choice = zeros(1, 7);
        GW_opt_6_conpos = zeros(1, 7); % 记录多网关冲突发现位置
        GW_opt_6_bin = zeros(1, 7); % 记录多网关冲突发现bin
        single_opt_6 = zeros(1, 7);
        for i = 1:7
            GW_bin = bitget(mulGW_state_tmp(6, i),1:7);
            a = find(GW_bin == 0);
            result = zeros(0);
            result_pos = zeros(0);
            result_conpos = zeros(0);
            result_bin = zeros(0);
            result_pos = [result_pos, mulGW_state_tmp(6, i)];
            result_conpos = [result_conpos, mulGW_conpos_tmp(6, i)];
            result_bin = [result_bin, mulGW_bin_tmp(6, i)];
            for j = 1:size(GW_opt_5, 2)
                bin = bitget(GW_opt_5(1, j), 1:7);
                if bin(a) == 0
                    result = [result, GW_opt_5(2, j)];
                    result_pos = [result_pos, GW_opt_5_choice(j)];  % 记录位置
                    result_conpos = [result_conpos, GW_opt_5_conpos(j)];
                    result_bin = [result_bin, GW_opt_5_bin(j)];
                end
            end
            
            [GW_opt_6(2,i), choice_pos] = max([mulGW_true_tmp(6, i), result]);
            GW_opt_6_choice(i) = result_pos(choice_pos);    % 记录正确率最高的选择
            GW_opt_6_conpos(i) = result_conpos(choice_pos);    % 记录正确率最高的conpos
            GW_opt_6_bin(i) = result_bin(choice_pos);  % 记录正确率最高的bin
            GW_opt_6(1,i) = mulGW_state_tmp(6, i);
            % 单网关
            b = find(GW_bin > 0);
            single_opt_6(i) = max(single_true_tmp(b));
        end

        GW_opt_7 = zeros(2, 1);
        GW_opt_7_choice = zeros(1, 1);
        GW_opt_7_conpos = zeros(1, 1); % 记录多网关冲突发现位置
        GW_opt_7_bin = zeros(1, 1); % 记录多网关冲突发现bin
        GW_opt_7(1) = mulGW_state_tmp(7,1);
        choice_can = [mulGW_state_tmp(7,1), GW_opt_6_choice];
        conpos_can = [mulGW_conpos_tmp(7,1), GW_opt_6_conpos];
        bin_can = [mulGW_bin_tmp(7,1), GW_opt_6_bin];
        [GW_opt_7(2), choice_pos] = max([mulGW_true_tmp(7, 1), GW_opt_6(2, :)]);
        GW_opt_7_choice = choice_can(choice_pos);
        GW_opt_7_conpos = conpos_can(choice_pos);
        GW_opt_7_bin = bin_can(choice_pos);

        single_opt_7 = max(single_true_tmp);
        single_opt_2_result = [single_opt_2_result, single_opt_2(1)];   % 只取其中的一组
        single_opt_3_result = [single_opt_3_result, single_opt_3(1)];
        single_opt_4_result = [single_opt_4_result, single_opt_4(1)];
        single_opt_5_result = [single_opt_5_result, single_opt_5(1)];
        single_opt_6_result = [single_opt_6_result, single_opt_6(1)];
        single_opt_7_result = [single_opt_7_result, single_opt_7];

        GW_opt_2_result = [GW_opt_2_result, GW_opt_2(2,1)];  % 只取其中的一组
        GW_opt_3_result = [GW_opt_3_result, GW_opt_3(2,1)];
        GW_opt_4_result = [GW_opt_4_result, GW_opt_4(2,1)];
        GW_opt_5_result = [GW_opt_5_result, GW_opt_5(2,1)];
        GW_opt_6_result = [GW_opt_6_result, GW_opt_6(2,1)];
        GW_opt_7_result = [GW_opt_7_result, GW_opt_7(2)];

        GW_opt_choice_2_result = [GW_opt_choice_2_result, GW_opt_2_choice(1)];  % 只取其中的一组
        GW_opt_choice_3_result = [GW_opt_choice_3_result, GW_opt_3_choice(1)];
        GW_opt_choice_4_result = [GW_opt_choice_4_result, GW_opt_4_choice(1)];
        GW_opt_choice_5_result = [GW_opt_choice_5_result, GW_opt_5_choice(1)];
        GW_opt_choice_6_result = [GW_opt_choice_6_result, GW_opt_6_choice(1)];
        GW_opt_choice_7_result = [GW_opt_choice_7_result, GW_opt_7_choice(1)];

        GW_opt_conpos_2_result = [GW_opt_conpos_2_result, GW_opt_2_conpos(1)];  % 只取其中的一组
        GW_opt_conpos_3_result = [GW_opt_conpos_3_result, GW_opt_3_conpos(1)];
        GW_opt_conpos_4_result = [GW_opt_conpos_4_result, GW_opt_4_conpos(1)];
        GW_opt_conpos_5_result = [GW_opt_conpos_5_result, GW_opt_5_conpos(1)];
        GW_opt_conpos_6_result = [GW_opt_conpos_6_result, GW_opt_6_conpos(1)];
        GW_opt_conpos_7_result = [GW_opt_conpos_7_result, GW_opt_7_conpos(1)];

        GW_opt_bin_2_result = [GW_opt_bin_2_result, GW_opt_2_bin(1)];  % 只取其中的一组
        GW_opt_bin_3_result = [GW_opt_bin_3_result, GW_opt_3_bin(1)];
        GW_opt_bin_4_result = [GW_opt_bin_4_result, GW_opt_4_bin(1)];
        GW_opt_bin_5_result = [GW_opt_bin_5_result, GW_opt_5_bin(1)];
        GW_opt_bin_6_result = [GW_opt_bin_6_result, GW_opt_6_bin(1)];
        GW_opt_bin_7_result = [GW_opt_bin_7_result, GW_opt_7_bin(1)];
    end
    GW_opt_result = [GW_opt_2_result; GW_opt_3_result; GW_opt_4_result; GW_opt_5_result; GW_opt_6_result; GW_opt_7_result];
    GW_opt_choice_result = [GW_opt_choice_2_result; GW_opt_choice_3_result; GW_opt_choice_4_result; GW_opt_choice_5_result; GW_opt_choice_6_result; GW_opt_choice_7_result];
    single_opt_result = [single_opt_2_result; single_opt_3_result; single_opt_4_result; single_opt_5_result; single_opt_6_result; single_opt_7_result];
    GW_opt_conpos_result = [GW_opt_conpos_2_result; GW_opt_conpos_3_result; GW_opt_conpos_4_result; GW_opt_conpos_5_result; GW_opt_conpos_6_result; GW_opt_conpos_7_result];
    GW_opt_bin_result = [GW_opt_bin_2_result; GW_opt_bin_3_result; GW_opt_bin_4_result; GW_opt_bin_5_result; GW_opt_bin_6_result; GW_opt_bin_7_result];
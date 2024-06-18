function [GW_opt_result, Nscale_opt_result, single_opt_result, GW_opt_choice_result] = get_opt_single_result(a_mulGW_state, a_mulGW_true, a_Nscale_true, a_sinGW_true, times, pkg_name)
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
    % Nscale最优策略结果记录
    Nscale_opt_2_result = zeros(0);
    Nscale_opt_3_result = zeros(0);
    Nscale_opt_4_result = zeros(0);
    Nscale_opt_5_result = zeros(0);
    Nscale_opt_6_result = zeros(0);
    Nscale_opt_7_result = zeros(0);
    % 单网关最优策略结果记录
    single_opt_2_result = zeros(0);
    single_opt_3_result = zeros(0);
    single_opt_4_result = zeros(0);
    single_opt_5_result = zeros(0);
    single_opt_6_result = zeros(0);
    single_opt_7_result = zeros(0);
    for exp_time = 1:times
        mulGW_state_tmp = zeros(7, 35);
        mulGW_true_tmp = zeros(7,35);
        Nscale_true_tmp = zeros(1,7);
        single_true_tmp = zeros(1,7);
        mulGW_state_tmp(1, 1:7) = a_mulGW_state(7*(exp_time-1)+1, 1:7);
        mulGW_state_tmp(2, 1:21) = a_mulGW_state(7*(exp_time-1)+2, 1:21);
        mulGW_state_tmp(3, 1:35) = a_mulGW_state(7*(exp_time-1)+3, 1:35);
        mulGW_state_tmp(4, 1:35) = a_mulGW_state(7*(exp_time-1)+4, 1:35);
        mulGW_state_tmp(5, 1:21) = a_mulGW_state(7*(exp_time-1)+5, 1:21);
        mulGW_state_tmp(6, 1:7) = a_mulGW_state(7*(exp_time-1)+6, 1:7);
        mulGW_state_tmp(7, 1) = a_mulGW_state(7*(exp_time-1)+7, 1);
        
        if pkg_name == "pkg1"
            mulGW_true_tmp(1, 1:7) = a_mulGW_true(7*(exp_time-1)+1, 1:2:7*2-1);
            mulGW_true_tmp(2, 1:21) = a_mulGW_true(7*(exp_time-1)+2, 1:2:21*2-1);
            mulGW_true_tmp(3, 1:35) = a_mulGW_true(7*(exp_time-1)+3, 1:2:35*2-1);
            mulGW_true_tmp(4, 1:35) = a_mulGW_true(7*(exp_time-1)+4, 1:2:35*2-1);
            mulGW_true_tmp(5, 1:21) = a_mulGW_true(7*(exp_time-1)+5, 1:2:21*2-1);
            mulGW_true_tmp(6, 1:7) = a_mulGW_true(7*(exp_time-1)+6, 1:2:7*2-1);
            mulGW_true_tmp(7, 1) = a_mulGW_true(7*(exp_time-1)+7, 1);
            Nscale_true_tmp(1:7) = a_Nscale_true(exp_time, 1:2:2*7-1);
            single_true_tmp(1:7) = a_sinGW_true(exp_time, 1:2:2*7-1);
        elseif pkg_name == "pkg2"
            mulGW_true_tmp(1, 1:7) =  a_mulGW_true(7*(exp_time-1)+1, 2:2:7*2);
            mulGW_true_tmp(2, 1:21) = a_mulGW_true(7*(exp_time-1)+2, 2:2:21*2);
            mulGW_true_tmp(3, 1:35) = a_mulGW_true(7*(exp_time-1)+3, 2:2:35*2);
            mulGW_true_tmp(4, 1:35) = a_mulGW_true(7*(exp_time-1)+4, 2:2:35*2);
            mulGW_true_tmp(5, 1:21) = a_mulGW_true(7*(exp_time-1)+5, 2:2:21*2);
            mulGW_true_tmp(6, 1:7) =  a_mulGW_true(7*(exp_time-1)+6, 2:2:7*2);
            mulGW_true_tmp(7, 1) = a_mulGW_true(7*(exp_time-1)+7, 2);
            Nscale_true_tmp(1:7) = a_Nscale_true(exp_time, 2:2:2*7);
            single_true_tmp(1:7) = a_sinGW_true(exp_time, 2:2:2*7);
        else
            mulGW_true_tmp(1, 1:7) = (a_mulGW_true(7*(exp_time-1)+1, 1:2:7*2-1) + a_mulGW_true(7*(exp_time-1)+1, 2:2:7*2))/2;
            mulGW_true_tmp(2, 1:21) = (a_mulGW_true(7*(exp_time-1)+2, 1:2:21*2-1) + a_mulGW_true(7*(exp_time-1)+2, 2:2:21*2))/2;
            mulGW_true_tmp(3, 1:35) = (a_mulGW_true(7*(exp_time-1)+3, 1:2:35*2-1) + a_mulGW_true(7*(exp_time-1)+3, 2:2:35*2))/2;
            mulGW_true_tmp(4, 1:35) = (a_mulGW_true(7*(exp_time-1)+4, 1:2:35*2-1) + a_mulGW_true(7*(exp_time-1)+4, 2:2:35*2))/2;
            mulGW_true_tmp(5, 1:21) = (a_mulGW_true(7*(exp_time-1)+5, 1:2:21*2-1) + a_mulGW_true(7*(exp_time-1)+5, 2:2:21*2))/2;
            mulGW_true_tmp(6, 1:7) = (a_mulGW_true(7*(exp_time-1)+6, 1:2:7*2-1) + a_mulGW_true(7*(exp_time-1)+6, 2:2:7*2))/2;
            mulGW_true_tmp(7, 1) = (a_mulGW_true(7*(exp_time-1)+7, 1) + a_mulGW_true(7*(exp_time-1)+7, 2))/2;
            Nscale_true_tmp(1:7) = (a_Nscale_true(exp_time, 1:2:2*7-1) + a_Nscale_true(exp_time, 2:2:2*7))/2;
            single_true_tmp(1:7) = (a_sinGW_true(exp_time, 1:2:2*7-1) + a_sinGW_true(exp_time, 2:2:2*7))/2;
        end
        
        % 2网关最优
        GW_opt_2 = zeros(2, 21);
        GW_opt_2_choice = zeros(1, 21);
        Nscale_opt_2 = zeros(1,21);
        single_opt_2 = zeros(1,21);
        for i = 1:21
            GW_bin = bitget(mulGW_state_tmp(2, i),1:7);
            a = find(GW_bin > 0);
            result = [mulGW_true_tmp(1, a)];
            choice_can = [mulGW_state_tmp(1, a), mulGW_state_tmp(2, i)];
            [GW_opt_2(2,i), choice_pos] = max([result, mulGW_true_tmp(2, i)]);  % 找到正确率最高的结果
            
            GW_opt_2_choice(i) = choice_can(choice_pos);    % 记录正确率最高的选择
            GW_opt_2(1,i) = mulGW_state_tmp(2, i);
            % 单网关
            Nscale_opt_2(i) = max(Nscale_true_tmp(a));
            single_opt_2(i) = max(single_true_tmp(a));
        end

        % 3网关最优
        GW_opt_3 = zeros(2, 35);
        GW_opt_3_choice = zeros(1, 35);
        Nscale_opt_3 = zeros(1, 35);
        single_opt_3 = zeros(1, 35);
        for i = 1:35
            GW_bin = bitget(mulGW_state_tmp(3, i),1:7);
            a = find(GW_bin == 0);
            result = zeros(0);
            result_pos = zeros(0);
            for j = 1:size(GW_opt_2, 2)
                bin = bitget(GW_opt_2(1, j), 1:7);
                if bin(a) == 0
                    result = [result, GW_opt_2(2, j)];
                    result_pos = [result_pos, GW_opt_2_choice(j)];  % 记录位置
                end
            end
            result_pos = [result_pos, mulGW_state_tmp(3, i)];
            [GW_opt_3(2,i), choice_pos] = max([result, mulGW_true_tmp(3, i)]);
            GW_opt_3_choice(i) = result_pos(choice_pos);    % 记录正确率最高的选择
            GW_opt_3(1,i) = mulGW_state_tmp(3, i);
            % 单网关
            b = find(GW_bin > 0);
            Nscale_opt_3(i) = max(Nscale_true_tmp(b));
            single_opt_3(i) = max(single_true_tmp(b));
        end

        % 4网关最优
        GW_opt_4 = zeros(2, 35);
        GW_opt_4_choice = zeros(1, 35);
        Nscale_opt_4 = zeros(1, 35);
        single_opt_4 = zeros(1, 35);
        for i = 1:35
            GW_bin = bitget(mulGW_state_tmp(4, i),1:7);
            a = find(GW_bin == 0);
            result = zeros(0);
            result_pos = zeros(0);
            for j = 1:size(GW_opt_3, 2)
                bin = bitget(GW_opt_3(1, j), 1:7);
                if bin(a) == 0
                    result = [result, GW_opt_3(2, j)];
                    result_pos = [result_pos, GW_opt_3_choice(j)];  % 记录位置
                end
            end
            result_pos = [result_pos, mulGW_state_tmp(4, i)];
            [GW_opt_4(2,i), choice_pos] = max([result, mulGW_true_tmp(4, i)]);
            GW_opt_4_choice(i) = result_pos(choice_pos);    % 记录正确率最高的选择
            GW_opt_4(1,i) = mulGW_state_tmp(4, i);
            % 单网关
            b = find(GW_bin > 0);
            Nscale_opt_4(i) = max(Nscale_true_tmp(b));
            single_opt_4(i) = max(single_true_tmp(b));
        end

        % 5网关最优
        GW_opt_5 = zeros(2, 21);
        GW_opt_5_choice = zeros(1, 35);
        Nscale_opt_5 = zeros(1, 21);
        single_opt_5 = zeros(1, 21);
        for i = 1:21
            GW_bin = bitget(mulGW_state_tmp(5, i),1:7);
            a = find(GW_bin == 0);
            result = zeros(0);
            result_pos = zeros(0);
            for j = 1:size(GW_opt_4, 2)
                bin = bitget(GW_opt_4(1, j), 1:7);
                if bin(a) == 0
                    result = [result, GW_opt_4(2, j)];
                    result_pos = [result_pos, GW_opt_4_choice(j)];  % 记录位置
                end
            end
            result_pos = [result_pos, mulGW_state_tmp(5, i)];
            [GW_opt_5(2,i), choice_pos] = max([result, mulGW_true_tmp(5, i)]);
            GW_opt_5_choice(i) = result_pos(choice_pos);    % 记录正确率最高的选择
            GW_opt_5(1,i) = mulGW_state_tmp(5, i);
            % 单网关
            b = find(GW_bin > 0);
            Nscale_opt_5(i) = max(Nscale_true_tmp(b));
            single_opt_5(i) = max(single_true_tmp(b));
        end

        % 6网关最优
        GW_opt_6 = zeros(2, 7);
        GW_opt_6_choice = zeros(1, 35);
        Nscale_opt_6 = zeros(1, 7);
        single_opt_6 = zeros(1, 7);
        for i = 1:7
            GW_bin = bitget(mulGW_state_tmp(6, i),1:7);
            a = find(GW_bin == 0);
            result = zeros(0);
            result_pos = zeros(0);
            for j = 1:size(GW_opt_5, 2)
                bin = bitget(GW_opt_5(1, j), 1:7);
                if bin(a) == 0
                    result = [result, GW_opt_5(2, j)];
                    result_pos = [result_pos, GW_opt_5_choice(j)];  % 记录位置
                end
            end
            result_pos = [result_pos, mulGW_state_tmp(6, i)];
            [GW_opt_6(2,i), choice_pos] = max([result, mulGW_true_tmp(6, i)]);
            GW_opt_6_choice(i) = result_pos(choice_pos);    % 记录正确率最高的选择
            GW_opt_6(1,i) = mulGW_state_tmp(6, i);
            % 单网关
            b = find(GW_bin > 0);
            Nscale_opt_6(i) = max(Nscale_true_tmp(b));
            single_opt_6(i) = max(single_true_tmp(b));
        end

        GW_opt_7 = zeros(2, 1);
        GW_opt_7_choice = zeros(1, 1);
        GW_opt_7(1) = mulGW_state_tmp(7,1);
        choice_can = [GW_opt_6_choice, mulGW_state_tmp(7,1)];
        [GW_opt_7(2), choice_pos] = max([GW_opt_6(2, :), mulGW_true_tmp(7, 1)]);
        GW_opt_7_choice = choice_can(choice_pos);

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

        Nscale_opt_7 = max(Nscale_true_tmp);
        single_opt_7 = max(single_true_tmp);
        Nscale_opt_2_result = [Nscale_opt_2_result, Nscale_opt_2(1)];   % 只取其中的一组
        Nscale_opt_3_result = [Nscale_opt_3_result, Nscale_opt_3(1)];
        Nscale_opt_4_result = [Nscale_opt_4_result, Nscale_opt_4(1)];
        Nscale_opt_5_result = [Nscale_opt_5_result, Nscale_opt_5(1)];
        Nscale_opt_6_result = [Nscale_opt_6_result, Nscale_opt_6(1)];
        Nscale_opt_7_result = [Nscale_opt_7_result, Nscale_opt_7];
        single_opt_2_result = [single_opt_2_result, single_opt_2(1)];   % 只取其中的一组
        single_opt_3_result = [single_opt_3_result, single_opt_3(1)];
        single_opt_4_result = [single_opt_4_result, single_opt_4(1)];
        single_opt_5_result = [single_opt_5_result, single_opt_5(1)];
        single_opt_6_result = [single_opt_6_result, single_opt_6(1)];
        single_opt_7_result = [single_opt_7_result, single_opt_7];
        
    end
    GW_opt_result = [GW_opt_2_result; GW_opt_3_result; GW_opt_4_result; GW_opt_5_result; GW_opt_6_result; GW_opt_7_result];
    GW_opt_choice_result = [GW_opt_choice_2_result; GW_opt_choice_3_result; GW_opt_choice_4_result; GW_opt_choice_5_result; GW_opt_choice_6_result; GW_opt_choice_7_result];
    Nscale_opt_result = [Nscale_opt_2_result; Nscale_opt_3_result; Nscale_opt_4_result; Nscale_opt_5_result; Nscale_opt_6_result; Nscale_opt_7_result];
    single_opt_result = [single_opt_2_result; single_opt_3_result; single_opt_4_result; single_opt_5_result; single_opt_6_result; single_opt_7_result];
    
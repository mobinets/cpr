function [GW_choice_result] = get_choice_GT(a_mulGW_state, a_mulGW_true, a_sinGW_true, times, sir, pkg_name)
    % con_k_residual = zeros(0);
    % for exp_time = 1:times
    %     mulGW_state_tmp = zeros(7, 35);
    %     mulGW_state_tmp(1, 1:7) = a_mulGW_state(1, 7*(exp_time-1)+1 : 7*exp_time);
    %     mulGW_state_tmp(2, 1:21) = a_mulGW_state(2, 21*(exp_time-1)+1 : 21*exp_time);
    %     mulGW_state_tmp(3, 1:35) = a_mulGW_state(3, 35*(exp_time-1)+1 : 35*exp_time);
    %     mulGW_state_tmp(4, 1:35) = a_mulGW_state(4, 35*(exp_time-1)+1 : 35*exp_time);
    %     mulGW_state_tmp(5, 1:21) = a_mulGW_state(5, 21*(exp_time-1)+1 : 21*exp_time);
    %     mulGW_state_tmp(6, 1:7) = a_mulGW_state(6, 7*(exp_time-1)+1 : 7*exp_time);
    %     mulGW_state_tmp(7, 1) = a_mulGW_state(7, exp_time);
    %     mulGW_true_tmp = zeros(7,35);
    %     mulGW_true_tmp(1, 1:7) = (a_mulGW_true(1, 7*2*(exp_time-1)+1 : 2 : 7*2*exp_time-1) + a_mulGW_true(1, 7*2*(exp_time-1)+2 : 2 : 7*2*exp_time))/2;
    %     mulGW_true_tmp(2, 1:21) = (a_mulGW_true(2, 21*2*(exp_time-1)+1 : 2 : 21*2*exp_time-1) + a_mulGW_true(2, 21*2*(exp_time-1)+2 : 2 : 21*2*exp_time))/2;
    %     mulGW_true_tmp(3, 1:35) = (a_mulGW_true(3, 35*2*(exp_time-1)+1 : 2 : 35*2*exp_time-1) + a_mulGW_true(3, 35*2*(exp_time-1)+2 : 2 : 35*2*exp_time))/2;
    %     mulGW_true_tmp(4, 1:35) = (a_mulGW_true(4, 35*2*(exp_time-1)+1 : 2 : 35*2*exp_time-1) + a_mulGW_true(4, 35*2*(exp_time-1)+2 : 2 : 35*2*exp_time))/2;
    %     mulGW_true_tmp(5, 1:21) = (a_mulGW_true(5, 21*2*(exp_time-1)+1 : 2 : 21*2*exp_time-1) + a_mulGW_true(5, 21*2*(exp_time-1)+2 : 2 : 21*2*exp_time))/2;
    %     mulGW_true_tmp(6, 1:7) = (a_mulGW_true(6, 7*2*(exp_time-1)+1 : 2 : 7*2*exp_time-1) + a_mulGW_true(6, 7*2*(exp_time-1)+2 : 2 : 7*2*exp_time))/2;
    %     mulGW_true_tmp(7, 1) = (a_mulGW_true(7, 2*exp_time-1) + a_mulGW_true(7, 2*exp_time))/2;
    %     mulGW_arg_tmp = a_argGW_arr(7*(exp_time-1)+1 : 7*exp_time, :);
    %     mulGW_arg_tmp = normalize(mulGW_arg_tmp, 1, 'range');
        
    %     % 2网关最优
    %     GW_opt_2 = zeros(3, 21);
    %     for i = 1:21
    %         GW_bin = bitget(mulGW_state_tmp(2, i), 1:7);
    %         GW_opt_2(1,i) = mulGW_state_tmp(2, i);
    %         a = find(GW_bin > 0);
    %         [GW_opt_2(2,i), tmp] = max([mulGW_true_tmp(1, a), mulGW_true_tmp(2, i)]);
    %         if tmp <= 2
    %             k = abs(mulGW_arg_tmp(a(tmp), 1)) + abs(mulGW_arg_tmp(a(tmp), 2));
    %             residual = abs(mulGW_arg_tmp(a(tmp), 3)) + abs(mulGW_arg_tmp(a(tmp), 4));
    %             con = mulGW_arg_tmp(a(tmp), 5);
    %             GW_opt_2(3,i) = k * con / residual;
    %             % GW_opt_2(3,i) = con;
    %         else
    %             k = abs(mulGW_arg_tmp(a, 1)) + abs(mulGW_arg_tmp(a, 2));
    %             residual = abs(mulGW_arg_tmp(a, 3)) + abs(mulGW_arg_tmp(a, 4));
    %             con = mulGW_arg_tmp(a, 5);
    %             GW_opt_2(3,i) = mean(k .* con ./ residual, 'omitnan');
    %             % GW_opt_2(3,i) = mean(con, 'omitnan');
    %         end
    %     end

    %     % 3网关最优
    %     GW_opt_3 = zeros(3, 35);
    %     for i = 1:35
    %         GW_bin = bitget(mulGW_state_tmp(3, i),1:7);
    %         a = find(GW_bin == 0);
    %         result = zeros(0);
    %         result_pos = zeros(0);
    %         for j = 1:size(GW_opt_2, 2)
    %             bin = bitget(GW_opt_2(1, j), 1:7);
    %             if bin(a) == 0
    %                 result = [result, GW_opt_2(2, j)];
    %                 result_pos = [result_pos, GW_opt_2(1, j)];
    %             end
    %         end
    %         [GW_opt_3(2,i), tmp] = max([result, mulGW_true_tmp(3, i)]);
    %         GW_opt_3(1,i) = mulGW_state_tmp(3, i);
    %         if tmp < length(result_pos) - 1
    %             tmp = find( GW_opt_2(1,:) == result_pos(tmp));
    %             GW_opt_3(3,i) = GW_opt_2(3,tmp);
    %         else
    %             b = find(GW_bin > 0);
    %             k = abs(mulGW_arg_tmp(b, 1)) + abs(mulGW_arg_tmp(b, 2));
    %             residual = abs(mulGW_arg_tmp(b, 3)) + abs(mulGW_arg_tmp(b, 4));
    %             con = mulGW_arg_tmp(b, 5);
    %             GW_opt_3(3,i) = mean(k .* con ./ residual, 'omitnan');
    %             % GW_opt_3(3,i) = mean(con, 'omitnan');
    %         end
    %     end

    %     % 4网关最优
    %     GW_opt_4 = zeros(3, 35);
    %     for i = 1:35
    %         GW_bin = bitget(mulGW_state_tmp(4, i),1:7);
    %         a = find(GW_bin == 0);
    %         result = zeros(0);
    %         result_pos = zeros(0);
    %         for j = 1:size(GW_opt_3, 2)
    %             bin = bitget(GW_opt_3(1, j), 1:7);
    %             if bin(a) == 0
    %                 result = [result, GW_opt_3(2, j)];
    %                 result_pos = [result_pos, GW_opt_3(1, j)];
    %             end
    %         end
    %         [GW_opt_4(2,i), tmp] = max([result, mulGW_true_tmp(4, i)]);
    %         GW_opt_4(1,i) = mulGW_state_tmp(4, i);
    %         if tmp < length(result_pos) - 1
    %             tmp = find( GW_opt_3(1,:) == result_pos(tmp));
    %             GW_opt_4(3,i) = GW_opt_3(3,tmp);
    %         else
    %             b = find(GW_bin > 0);
    %             k = abs(mulGW_arg_tmp(b, 1)) + abs(mulGW_arg_tmp(b, 2));
    %             residual = abs(mulGW_arg_tmp(b, 3)) + abs(mulGW_arg_tmp(b, 4));
    %             con = mulGW_arg_tmp(b, 5);
    %             GW_opt_4(3,i) = mean(k .* con ./ residual, 'omitnan');
    %             % GW_opt_4(3,i) = mean(con, 'omitnan');
    %         end
    %     end

    %     % 5网关最优
    %     GW_opt_5 = zeros(3, 21);
    %     for i = 1:21
    %         GW_bin = bitget(mulGW_state_tmp(5, i),1:7);
    %         a = find(GW_bin == 0);
    %         result = zeros(0);
    %         result_pos = zeros(0);
    %         for j = 1:size(GW_opt_4, 2)
    %             bin = bitget(GW_opt_4(1, j), 1:7);
    %             if bin(a) == 0
    %                 result = [result, GW_opt_4(2, j)];
    %                 result_pos = [result_pos, GW_opt_4(1, j)];
    %             end
    %         end
    %         [GW_opt_5(2,i), tmp] = max([result, mulGW_true_tmp(5, i)]);
    %         GW_opt_5(1,i) = mulGW_state_tmp(5, i);
    %         if tmp < length(result_pos) - 1
    %             tmp = find( GW_opt_4(1,:) == result_pos(tmp));
    %             GW_opt_5(3,i) = GW_opt_4(3,tmp);
    %         else
    %             b = find(GW_bin > 0);
    %             k = abs(mulGW_arg_tmp(b, 1)) + abs(mulGW_arg_tmp(b, 2));
    %             residual = abs(mulGW_arg_tmp(b, 3)) + abs(mulGW_arg_tmp(b, 4));
    %             con = mulGW_arg_tmp(b, 5);
    %             GW_opt_5(3,i) = mean(k .* con ./ residual, 'omitnan');
    %             % GW_opt_5(3,i) = mean(con, 'omitnan');
    %         end
    %     end

    %     % 6网关最优
    %     GW_opt_6 = zeros(3, 7);
    %     for i = 1:7
    %         GW_bin = bitget(mulGW_state_tmp(6, i),1:7);
    %         a = find(GW_bin == 0);
    %         result = zeros(0);
    %         result_pos = zeros(0);
    %         for j = 1:size(GW_opt_5, 2)
    %             bin = bitget(GW_opt_5(1, j), 1:7);
    %             if bin(a) == 0
    %                 result = [result, GW_opt_5(2, j)];
    %                 result_pos = [result_pos, GW_opt_5(1, j)];
    %             end
    %         end
    %         [GW_opt_6(2,i), tmp] = max([result, mulGW_true_tmp(6, i)]);
    %         GW_opt_6(1,i) = mulGW_state_tmp(6, i);
    %         if tmp < length(result_pos) - 1
    %             tmp = find( GW_opt_5(1,:) == result_pos(tmp));
    %             GW_opt_6(3,i) = GW_opt_5(3,tmp);
    %         else
    %             b = find(GW_bin > 0);
    %             k = abs(mulGW_arg_tmp(b, 1)) + abs(mulGW_arg_tmp(b, 2));
    %             residual = abs(mulGW_arg_tmp(b, 3)) + abs(mulGW_arg_tmp(b, 4));
    %             con = mulGW_arg_tmp(b, 5);
    %             GW_opt_6(3,i) = mean(k .* con ./ residual, 'omitnan');
    %             % GW_opt_6(3,i) = mean(con, 'omitnan');
    %         end
    %     end

    %     GW_opt_7 = zeros(3, 1);
    %     GW_opt_7(1) = mulGW_state_tmp(7,1);
    %     [GW_opt_7(2), tmp]  = max([GW_opt_6(2, :), mulGW_true_tmp(7, 1)]);
    %     if tmp < length(result_pos) - 1
    %         GW_opt_7(3) = GW_opt_6(3,tmp);
    %     else
    %         k = abs(mulGW_arg_tmp(:, 1)) + abs(mulGW_arg_tmp(:, 2));
    %         residual = abs(mulGW_arg_tmp(:, 3)) + abs(mulGW_arg_tmp(:, 4));
    %         con = mulGW_arg_tmp(:, 5);
    %         GW_opt_7(3) = mean(k .* con ./ residual, 'omitnan');
    %         % GW_opt_7(3) = mean(con, 'omitnan');
    %     end
    %     con_k_residual = [con_k_residual, GW_opt_2(3,:), GW_opt_3(3,:), GW_opt_4(3,:), GW_opt_5(3,:), GW_opt_6(3,:), GW_opt_7(3)];
    % end
    % con_k_residual_result = mean(con_k_residual, 'omitnan');
    % con_k_residual_result = mean(con_k_residual(con_k_residual > 10 & con_k_residual < 100), 'omitnan');
    % con_k_residual_result = mean(con_k_residual(con_k_residual >= 0 & con_k_residual < 10), 'omitnan');
    if sir == "sir_5" 
        con_k_residual_result = 15.09;
    elseif sir == "sir0"
        con_k_residual_result = 0.59;
    else  % SIR == 5
        % con_k_residual_result = 0.79;
        con_k_residual_result = 1.39;
    end

    GW_choice_2_result = zeros(0);
    GW_choice_3_result = zeros(0);
    GW_choice_4_result = zeros(0);
    GW_choice_5_result = zeros(0);
    GW_choice_6_result = zeros(0);
    GW_choice_7_result = zeros(0);
    for exp_time = 1:times
        mulGW_state_tmp = zeros(7, 35);
        % mulGW_state_tmp(1, 1:7) = a_mulGW_state(1, 7*(exp_time-1)+1 : 7*exp_time);
        % mulGW_state_tmp(2, 1:21) = a_mulGW_state(2, 21*(exp_time-1)+1 : 21*exp_time);
        % mulGW_state_tmp(3, 1:35) = a_mulGW_state(3, 35*(exp_time-1)+1 : 35*exp_time);
        % mulGW_state_tmp(4, 1:35) = a_mulGW_state(4, 35*(exp_time-1)+1 : 35*exp_time);
        % mulGW_state_tmp(5, 1:21) = a_mulGW_state(5, 21*(exp_time-1)+1 : 21*exp_time);
        % mulGW_state_tmp(6, 1:7) = a_mulGW_state(6, 7*(exp_time-1)+1 : 7*exp_time);
        % mulGW_state_tmp(7, 1) = a_mulGW_state(7, exp_time);
        mulGW_state_tmp(1, 1:7) = a_mulGW_state(7*(exp_time-1)+1, 1:7);
        mulGW_state_tmp(2, 1:21) = a_mulGW_state(7*(exp_time-1)+2, 1:21);
        mulGW_state_tmp(3, 1:35) = a_mulGW_state(7*(exp_time-1)+3, 1:35);
        mulGW_state_tmp(4, 1:35) = a_mulGW_state(7*(exp_time-1)+4, 1:35);
        mulGW_state_tmp(5, 1:21) = a_mulGW_state(7*(exp_time-1)+5, 1:21);
        mulGW_state_tmp(6, 1:7) = a_mulGW_state(7*(exp_time-1)+6, 1:7);
        mulGW_state_tmp(7, 1) = a_mulGW_state(7*(exp_time-1)+7, 1);
        mulGW_true_tmp = zeros(7,35);
        if pkg_name == "pkg1"
            mulGW_true_tmp(1, 1:7) = a_mulGW_true(7*(exp_time-1)+1, 1:2:7*2-1);
            mulGW_true_tmp(2, 1:21) = a_mulGW_true(7*(exp_time-1)+2, 1:2:21*2-1);
            mulGW_true_tmp(3, 1:35) = a_mulGW_true(7*(exp_time-1)+3, 1:2:35*2-1);
            mulGW_true_tmp(4, 1:35) = a_mulGW_true(7*(exp_time-1)+4, 1:2:35*2-1);
            mulGW_true_tmp(5, 1:21) = a_mulGW_true(7*(exp_time-1)+5, 1:2:21*2-1);
            mulGW_true_tmp(6, 1:7) = a_mulGW_true(7*(exp_time-1)+6, 1:2:7*2-1);
            mulGW_true_tmp(7, 1) = a_mulGW_true(7*(exp_time-1)+7, 1);
        elseif pkg_name == "pkg2"
            mulGW_true_tmp(1, 1:7) =  a_mulGW_true(7*(exp_time-1)+1, 2:2:7*2);
            mulGW_true_tmp(2, 1:21) = a_mulGW_true(7*(exp_time-1)+2, 2:2:21*2);
            mulGW_true_tmp(3, 1:35) = a_mulGW_true(7*(exp_time-1)+3, 2:2:35*2);
            mulGW_true_tmp(4, 1:35) = a_mulGW_true(7*(exp_time-1)+4, 2:2:35*2);
            mulGW_true_tmp(5, 1:21) = a_mulGW_true(7*(exp_time-1)+5, 2:2:21*2);
            mulGW_true_tmp(6, 1:7) =  a_mulGW_true(7*(exp_time-1)+6, 2:2:7*2);
            mulGW_true_tmp(7, 1) = a_mulGW_true(7*(exp_time-1)+7, 2);
        else
            mulGW_true_tmp(1, 1:7) = (a_mulGW_true(7*(exp_time-1)+1, 1:2:7*2-1) + a_mulGW_true(7*(exp_time-1)+1, 2:2:7*2))/2;
            mulGW_true_tmp(2, 1:21) = (a_mulGW_true(7*(exp_time-1)+2, 1:2:21*2-1) + a_mulGW_true(7*(exp_time-1)+2, 2:2:21*2))/2;
            mulGW_true_tmp(3, 1:35) = (a_mulGW_true(7*(exp_time-1)+3, 1:2:35*2-1) + a_mulGW_true(7*(exp_time-1)+3, 2:2:35*2))/2;
            mulGW_true_tmp(4, 1:35) = (a_mulGW_true(7*(exp_time-1)+4, 1:2:35*2-1) + a_mulGW_true(7*(exp_time-1)+4, 2:2:35*2))/2;
            mulGW_true_tmp(5, 1:21) = (a_mulGW_true(7*(exp_time-1)+5, 1:2:21*2-1) + a_mulGW_true(7*(exp_time-1)+5, 2:2:21*2))/2;
            mulGW_true_tmp(6, 1:7) = (a_mulGW_true(7*(exp_time-1)+6, 1:2:7*2-1) + a_mulGW_true(7*(exp_time-1)+6, 2:2:7*2))/2;
            mulGW_true_tmp(7, 1) = (a_mulGW_true(7*(exp_time-1)+7, 1) + a_mulGW_true(7*(exp_time-1)+7, 2))/2;
        end
        % mulGW_arg_tmp = a_argGW_arr(7*(exp_time-1)+1 : 7*exp_time, :);
        % mulGW_arg_tmp = normalize(mulGW_arg_tmp, 1, 'range');
        % k = abs(mulGW_arg_tmp(:, 1)) + abs(mulGW_arg_tmp(:, 2));
        % residual = abs(mulGW_arg_tmp(:, 3)) + abs(mulGW_arg_tmp(:, 4));
        % con = mulGW_arg_tmp(:, 5);
        % con_k_residual_array_tmp = k .* con ./ residual;
        % try
        con_k_residual_array_tmp = a_sinGW_true(exp_time, 1:2:14-1);
        con_k_residual_result = 26;
        
        % 2网关选择策略结果
        GW_choice_2 = zeros(1, 21);
        for i = 1:21
            GW_bin = bitget(mulGW_state_tmp(2, i), 1:7);
            a = find(GW_bin > 0);
            % tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            if length(tmp) <= 1
                GW_choice_2(i) = max(mulGW_true_tmp(1, a));
            else
                GW_choice_2(i) = mulGW_true_tmp(2, i);
            end
            % disp(a(tmp));
        end

        % 3网关选择策略结果
        GW_choice_3 = zeros(1, 35);
        for i = 1:35
            GW_bin = bitget(mulGW_state_tmp(3, i),1:7);
            a = find(GW_bin > 0);
            % tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            if length(tmp) <= 1
                GW_choice_3(i) = max(mulGW_true_tmp(1, a));
            else
                choice_tmp = zeros(1, 7);
                choice_tmp(a(tmp)) = 1;
                choice_tmp = fliplr(choice_tmp);
                choice_t = bin2dec(num2str(choice_tmp));
                choice = find(mulGW_state_tmp(length(tmp), :) == choice_t);
                GW_choice_3(i) = mulGW_true_tmp(length(tmp), choice);
            end
            % disp(a(tmp));
            % disp(choice_tmp);
        end

        % 4网关选择策略结果
        GW_choice_4 = zeros(1, 35);
        for i = 1:35
            GW_bin = bitget(mulGW_state_tmp(4, i),1:7);
            a = find(GW_bin > 0);
            % tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            if length(tmp) <= 1
                GW_choice_4(i) = max(mulGW_true_tmp(1, a));
            else
                choice_tmp = zeros(1, 7);
                choice_tmp(a(tmp)) = 1;
                choice_tmp = fliplr(choice_tmp);
                choice_t = bin2dec(num2str(choice_tmp));
                choice = find(mulGW_state_tmp(length(tmp), :) == choice_t);
                GW_choice_4(i) = mulGW_true_tmp(length(tmp), choice);
            end
            % disp(a(tmp));
        end

        % 5网关选择策略结果
        GW_choice_5 = zeros(1, 21);
        for i = 1:21
            GW_bin = bitget(mulGW_state_tmp(5, i),1:7);
            a = find(GW_bin > 0);
            % tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            if length(tmp) <= 1
                GW_choice_5(i) = max(mulGW_true_tmp(1, a));
            else
                choice_tmp = zeros(1, 7);
                choice_tmp(a(tmp)) = 1;
                choice_tmp = fliplr(choice_tmp);
                choice_t = bin2dec(num2str(choice_tmp));
                choice = find(mulGW_state_tmp(length(tmp), :) == choice_t);
                GW_choice_5(i) = mulGW_true_tmp(length(tmp), choice);
            end
        end

        % 6网关选择策略结果
        GW_choice_6 = zeros(1, 7);
        for i = 1:7
            GW_bin = bitget(mulGW_state_tmp(6, i),1:7);
            a = find(GW_bin > 0);
            % tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
            if length(tmp) <= 1
                GW_choice_6(i) = max(mulGW_true_tmp(1, a));
            else
                choice_tmp = zeros(1, 7);
                choice_tmp(a(tmp)) = 1;
                choice_tmp = fliplr(choice_tmp);
                choice_t = bin2dec(num2str(choice_tmp));
                choice = find(mulGW_state_tmp(length(tmp), :) == choice_t);
                GW_choice_6(i) = mulGW_true_tmp(length(tmp), choice);
            end
        end

        GW_choice_7 = zeros(1, 1);
        GW_bin = bitget(mulGW_state_tmp(7, 1),1:7);
        a = find(GW_bin > 0);
        % tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
        tmp = find(con_k_residual_array_tmp(a) >= con_k_residual_result);
        if length(tmp) <= 1
            GW_choice_7 = max(mulGW_true_tmp(1, :));
        else
            choice_tmp = zeros(1, 7);
            choice_tmp(a(tmp)) = 1;
            choice_tmp = fliplr(choice_tmp);
            choice_t = bin2dec(num2str(choice_tmp));
            choice = find(mulGW_state_tmp(length(tmp), :) == choice_t);
            GW_choice_7 = mulGW_true_tmp(length(tmp), choice);
        end
        GW_choice_2_result = [GW_choice_2_result, GW_choice_2(1)]; % 只取其中一组
        GW_choice_3_result = [GW_choice_3_result, GW_choice_3(1)];
        GW_choice_4_result = [GW_choice_4_result, GW_choice_4(1)];
        GW_choice_5_result = [GW_choice_5_result, GW_choice_5(1)];
        GW_choice_6_result = [GW_choice_6_result, GW_choice_6(1)];
        GW_choice_7_result = [GW_choice_7_result, GW_choice_7];
    end
    GW_choice_result = [GW_choice_2_result; GW_choice_3_result; GW_choice_4_result; GW_choice_5_result; GW_choice_6_result; GW_choice_7_result];
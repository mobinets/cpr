times = 1000;
con_k_residual = zeros(0);
value_array_2_result = zeros(0);
value_array_3_result = zeros(0);
value_array_4_result = zeros(0);
value_array_5_result = zeros(0);
value_array_6_result = zeros(0);
value_array_7_result = zeros(0);
value_array_2_none_result = zeros(0);
SNR_result_array = zeros(0);
for exp_time = 1:times
    mulGW_state_tmp = zeros(7, 35);
    mulGW_state_tmp(1, 1:7) = a_mulGW_state(1, 7*(exp_time-1)+1 : 7*exp_time);
    mulGW_state_tmp(2, 1:21) = a_mulGW_state(2, 21*(exp_time-1)+1 : 21*exp_time);
    mulGW_state_tmp(3, 1:35) = a_mulGW_state(3, 35*(exp_time-1)+1 : 35*exp_time);
    mulGW_state_tmp(4, 1:35) = a_mulGW_state(4, 35*(exp_time-1)+1 : 35*exp_time);
    mulGW_state_tmp(5, 1:21) = a_mulGW_state(5, 21*(exp_time-1)+1 : 21*exp_time);
    mulGW_state_tmp(6, 1:7) = a_mulGW_state(6, 7*(exp_time-1)+1 : 7*exp_time);
    mulGW_state_tmp(7, 1) = a_mulGW_state(7, exp_time);
    mulGW_true_tmp = zeros(7,35);
    mulGW_true_tmp(1, 1:7) = (a_mulGW_true(1, 7*2*(exp_time-1)+1 : 2 : 7*2*exp_time-1) + a_mulGW_true(1, 7*2*(exp_time-1)+2 : 2 : 7*2*exp_time))/2;
    mulGW_true_tmp(2, 1:21) = (a_mulGW_true(2, 21*2*(exp_time-1)+1 : 2 : 21*2*exp_time-1) + a_mulGW_true(2, 21*2*(exp_time-1)+2 : 2 : 21*2*exp_time))/2;
    mulGW_true_tmp(3, 1:35) = (a_mulGW_true(3, 35*2*(exp_time-1)+1 : 2 : 35*2*exp_time-1) + a_mulGW_true(3, 35*2*(exp_time-1)+2 : 2 : 35*2*exp_time))/2;
    mulGW_true_tmp(4, 1:35) = (a_mulGW_true(4, 35*2*(exp_time-1)+1 : 2 : 35*2*exp_time-1) + a_mulGW_true(4, 35*2*(exp_time-1)+2 : 2 : 35*2*exp_time))/2;
    mulGW_true_tmp(5, 1:21) = (a_mulGW_true(5, 21*2*(exp_time-1)+1 : 2 : 21*2*exp_time-1) + a_mulGW_true(5, 21*2*(exp_time-1)+2 : 2 : 21*2*exp_time))/2;
    mulGW_true_tmp(6, 1:7) = (a_mulGW_true(6, 7*2*(exp_time-1)+1 : 2 : 7*2*exp_time-1) + a_mulGW_true(6, 7*2*(exp_time-1)+2 : 2 : 7*2*exp_time))/2;
    mulGW_true_tmp(7, 1) = (a_mulGW_true(7, 2*exp_time-1) + a_mulGW_true(7, 2*exp_time))/2;
    mulGW_arg_tmp = a_argGW_arr(7*(exp_time-1)+1 : 7*exp_time, :);
    SNR_result_array = [SNR_result_array, mulGW_arg_tmp(:,9)];
   
    % 2网关最优
    GW_opt_2 = zeros(3, 21);
    value_array_2 = zeros(2,21);
    for i = 1:21
        GW_bin = bitget(mulGW_state_tmp(2, i), 1:7);
        GW_opt_2(1,i) = mulGW_state_tmp(2, i);
        a = find(GW_bin > 0);
        [GW_opt_2(2,i), tmp] = max([mulGW_true_tmp(1, a), mulGW_true_tmp(2, i)]);
        if tmp <= 2
            % k = abs(mulGW_arg_tmp(a(tmp), 1)) + abs(mulGW_arg_tmp(a(tmp), 2));
            % residual = abs(mulGW_arg_tmp(a(tmp), 3)) + abs(mulGW_arg_tmp(a(tmp), 4));
            % con = mulGW_arg_tmp(a(tmp), 5);
            % GW_opt_2(3,i) = k * con / residual;
            GW_opt_2(3,i) = mulGW_arg_tmp(a(tmp), 9);
            value_array_2(1,i) = GW_opt_2(3,i);
        else
            % k = abs(mulGW_arg_tmp(a, 1)) + abs(mulGW_arg_tmp(a, 2));
            % residual = abs(mulGW_arg_tmp(a, 3)) + abs(mulGW_arg_tmp(a, 4));
            % con = mulGW_arg_tmp(a, 5);
            % GW_opt_2(3,i) = mean(k .* con ./ residual, 'omitnan');
            % value_array_2(:,i) = k .* con ./ residual;
            % GW_opt_2(3,i) = mulGW_arg_tmp(a, 9);
            value_array_2(:,i) = mulGW_arg_tmp(a, 9);
        end
    end

    % 3网关最优
    GW_opt_3 = zeros(3, 35);
    value_array_3 = zeros(3,21);
    for i = 1:35
        GW_bin = bitget(mulGW_state_tmp(3, i),1:7);
        a = find(GW_bin == 0);
        result = zeros(0);
        result_pos = zeros(0);
        for j = 1:size(GW_opt_2, 2)
            bin = bitget(GW_opt_2(1, j), 1:7);
            if bin(a) == 0
                result = [result, GW_opt_2(2, j)];
                result_pos = [result_pos, GW_opt_2(1, j)];
            end
        end
        [GW_opt_3(2,i), tmp] = max([result, mulGW_true_tmp(3, i)]);
        GW_opt_3(1,i) = mulGW_state_tmp(3, i);
        if tmp < length(result_pos) - 1
            tmp = find( GW_opt_2(1,:) == result_pos(tmp));
            GW_opt_3(3,i) = GW_opt_2(3,tmp);
            value_array_3(1:2,i) = value_array_2(:,tmp);
        else
            b = find(GW_bin > 0);
            k = abs(mulGW_arg_tmp(b, 1)) + abs(mulGW_arg_tmp(b, 2));
            residual = abs(mulGW_arg_tmp(b, 3)) + abs(mulGW_arg_tmp(b, 4));
            con = mulGW_arg_tmp(b, 5);
            GW_opt_3(3,i) = mean(k .* con ./ residual, 'omitnan');
            value_array_3(:,i) = k .* con ./ residual;
        end
    end

    % 4网关最优
    GW_opt_4 = zeros(3, 35);
    value_array_4 = zeros(4,21);
    for i = 1:35
        GW_bin = bitget(mulGW_state_tmp(4, i),1:7);
        a = find(GW_bin == 0);
        result = zeros(0);
        result_pos = zeros(0);
        for j = 1:size(GW_opt_3, 2)
            bin = bitget(GW_opt_3(1, j), 1:7);
            if bin(a) == 0
                result = [result, GW_opt_3(2, j)];
                result_pos = [result_pos, GW_opt_3(1, j)];
            end
        end
        [GW_opt_4(2,i), tmp] = max([result, mulGW_true_tmp(4, i)]);
        GW_opt_4(1,i) = mulGW_state_tmp(4, i);
        if tmp < length(result_pos) - 1
            tmp = find( GW_opt_3(1,:) == result_pos(tmp));
            GW_opt_4(3,i) = GW_opt_3(3,tmp);
            value_array_4(1:3,i) = value_array_3(:,tmp);
        else
            b = find(GW_bin > 0);
            k = abs(mulGW_arg_tmp(b, 1)) + abs(mulGW_arg_tmp(b, 2));
            residual = abs(mulGW_arg_tmp(b, 3)) + abs(mulGW_arg_tmp(b, 4));
            con = mulGW_arg_tmp(b, 5);
            GW_opt_4(3,i) = mean(k .* con ./ residual, 'omitnan');
            value_array_4(:,i) = k .* con ./ residual;
        end
    end

    % 5网关最优
    GW_opt_5 = zeros(3, 21);
    value_array_5 = zeros(5,21);
    for i = 1:21
        GW_bin = bitget(mulGW_state_tmp(5, i),1:7);
        a = find(GW_bin == 0);
        result = zeros(0);
        result_pos = zeros(0);
        for j = 1:size(GW_opt_4, 2)
            bin = bitget(GW_opt_4(1, j), 1:7);
            if bin(a) == 0
                result = [result, GW_opt_4(2, j)];
                result_pos = [result_pos, GW_opt_4(1, j)];
            end
        end
        [GW_opt_5(2,i), tmp] = max([result, mulGW_true_tmp(5, i)]);
        GW_opt_5(1,i) = mulGW_state_tmp(5, i);
        if tmp < length(result_pos) - 1
            tmp = find( GW_opt_4(1,:) == result_pos(tmp));
            GW_opt_5(3,i) = GW_opt_4(3,tmp);
            value_array_5(1:4,i) = value_array_4(:,tmp);
        else
            b = find(GW_bin > 0);
            k = abs(mulGW_arg_tmp(b, 1)) + abs(mulGW_arg_tmp(b, 2));
            residual = abs(mulGW_arg_tmp(b, 3)) + abs(mulGW_arg_tmp(b, 4));
            con = mulGW_arg_tmp(b, 5);
            GW_opt_5(3,i) = mean(k .* con ./ residual, 'omitnan');
            value_array_5(:,i) = k .* con ./ residual;
        end
    end

    % 6网关最优
    GW_opt_6 = zeros(3, 7);
    value_array_6 = zeros(6, 21);
    for i = 1:7
        GW_bin = bitget(mulGW_state_tmp(6, i),1:7);
        a = find(GW_bin == 0);
        result = zeros(0);
        result_pos = zeros(0);
        for j = 1:size(GW_opt_5, 2)
            bin = bitget(GW_opt_5(1, j), 1:7);
            if bin(a) == 0
                result = [result, GW_opt_5(2, j)];
                result_pos = [result_pos, GW_opt_5(1, j)];
            end
        end
        [GW_opt_6(2,i), tmp] = max([result, mulGW_true_tmp(6, i)]);
        GW_opt_6(1,i) = mulGW_state_tmp(6, i);
        if tmp < length(result_pos) - 1
            tmp = find( GW_opt_5(1,:) == result_pos(tmp));
            GW_opt_6(3,i) = GW_opt_5(3,tmp);
            value_array_6(1:5,i) = value_array_5(:,tmp);
        else
            b = find(GW_bin > 0);
            k = abs(mulGW_arg_tmp(b, 1)) + abs(mulGW_arg_tmp(b, 2));
            residual = abs(mulGW_arg_tmp(b, 3)) + abs(mulGW_arg_tmp(b, 4));
            con = mulGW_arg_tmp(b, 5);
            GW_opt_6(3,i) = mean(k .* con ./ residual, 'omitnan');
            value_array_6(:,i) = k .* con ./ residual;
        end
    end

    GW_opt_7 = zeros(3, 1);
    value_array_7 = zeros(7);
    GW_opt_7(1) = mulGW_state_tmp(7,1);
    [GW_opt_7(2), tmp]  = max([GW_opt_6(2, :), mulGW_true_tmp(7, 1)]);
    if tmp < length(result_pos) - 1
        GW_opt_7(3) = GW_opt_6(3,tmp);
        value_array_7(1:6) = value_array_6(:,tmp);
    else
        k = abs(mulGW_arg_tmp(:, 1)) + abs(mulGW_arg_tmp(:, 2));
        residual = abs(mulGW_arg_tmp(:, 3)) + abs(mulGW_arg_tmp(:, 4));
        con = mulGW_arg_tmp(:, 5);
        GW_opt_7(3) = mean(k .* con ./ residual, 'omitnan');
        value_array_7 = k .* con ./ residual;
    end
    con_k_residual = [con_k_residual, GW_opt_2(3,:), GW_opt_3(3,:), GW_opt_4(3,:), GW_opt_5(3,:), GW_opt_6(3,:), GW_opt_7(3)];
    value_array_2_result = [value_array_2_result, value_array_2];
    value_array_3_result = [value_array_3_result, value_array_3];
    value_array_4_result = [value_array_4_result, value_array_4];
    value_array_5_result = [value_array_5_result, value_array_5];
    value_array_6_result = [value_array_6_result, value_array_6];
    value_array_7_result = [value_array_7_result, value_array_7];
end
figure(1);
plot(1:100,value_array_2_result(:,1:100),'.r'); hold on;
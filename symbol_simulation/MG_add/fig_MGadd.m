% 多网关最优策略结果记录
GW_opt_2_result = zeros(0);
GW_opt_3_result = zeros(0);
GW_opt_4_result = zeros(0);
GW_opt_5_result = zeros(0);
GW_opt_6_result = zeros(0);
GW_opt_7_result = zeros(0);
% 单网关最优策略结果记录
single_opt_2_result = zeros(0);
single_opt_3_result = zeros(0);
single_opt_4_result = zeros(0);
single_opt_5_result = zeros(0);
single_opt_6_result = zeros(0);
single_opt_7_result = zeros(0);
for exp_time = 1:20
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
    Nscale_true_tmp = zeros(1,7);
    Nscale_true_tmp(1:7) = (a_Nscale_true(7*2*(exp_time-1)+1 : 2 : 7*2*exp_time-1) + a_Nscale_true(7*2*(exp_time-1)+2 : 2 : 7*2*exp_time))/2;
    
    % 2网关最优
    GW_opt_2 = zeros(2, 21);
    single_opt_2 = zeros(1,21);
    for i = 1:21
        GW_bin = bitget(mulGW_state_tmp(2, i),1:7);
        a = find(GW_bin > 0);
        result = [mulGW_true_tmp(1, a)];
        GW_opt_2(2,i) = max([result, mulGW_true_tmp(2, i)]);
        GW_opt_2(1,i) = mulGW_state_tmp(2, i);
        % 单网关
        single_opt_2(i) = max(Nscale_true_tmp(a));
    end

    % 3网关最优
    GW_opt_3 = zeros(2, 35);
    single_opt_3 = zeros(1, 35);
    for i = 1:35
        GW_bin = bitget(mulGW_state_tmp(3, i),1:7);
        a = find(GW_bin == 0);
        result = zeros(0);
        for j = 1:size(GW_opt_2, 2)
            bin = bitget(GW_opt_2(1, j), 1:7);
            if bin(a) == 0
                result = [result, GW_opt_2(2, j)];
            end
        end
        GW_opt_3(2,i) = max([result, mulGW_true_tmp(3, i)]);
        GW_opt_3(1,i) = mulGW_state_tmp(3, i);
        % 单网关
        b = find(GW_bin > 0);
        single_opt_3(i) = max(Nscale_true_tmp(b));
    end

    % 4网关最优
    GW_opt_4 = zeros(2, 35);
    single_opt_4 = zeros(1, 35);
    for i = 1:35
        GW_bin = bitget(mulGW_state_tmp(4, i),1:7);
        a = find(GW_bin == 0);
        result = zeros(0);
        for j = 1:size(GW_opt_3, 2)
            bin = bitget(GW_opt_3(1, j), 1:7);
            if bin(a) == 0
                result = [result, GW_opt_3(2, j)];
            end
        end
        GW_opt_4(2,i) = max([result, mulGW_true_tmp(4, i)]);
        GW_opt_4(1,i) = mulGW_state_tmp(4, i);
        % 单网关
        b = find(GW_bin > 0);
        single_opt_4(i) = max(Nscale_true_tmp(b));
    end

    % 5网关最优
    GW_opt_5 = zeros(2, 21);
    single_opt_5 = zeros(1, 21);
    for i = 1:21
        GW_bin = bitget(mulGW_state_tmp(5, i),1:7);
        a = find(GW_bin == 0);
        result = zeros(0);
        for j = 1:size(GW_opt_4, 2)
            bin = bitget(GW_opt_4(1, j), 1:7);
            if bin(a) == 0
                result = [result, GW_opt_4(2, j)];
            end
        end
        GW_opt_5(2,i) = max([result, mulGW_true_tmp(5, i)]);
        GW_opt_5(1,i) = mulGW_state_tmp(5, i);
        % 单网关
        b = find(GW_bin > 0);
        single_opt_5(i) = max(Nscale_true_tmp(b));
    end

    % 6网关最优
    GW_opt_6 = zeros(2, 7);
    single_opt_6 = zeros(1, 7);
    for i = 1:7
        GW_bin = bitget(mulGW_state_tmp(6, i),1:7);
        a = find(GW_bin == 0);
        result = zeros(0);
        for j = 1:size(GW_opt_5, 2)
            bin = bitget(GW_opt_5(1, j), 1:7);
            if bin(a) == 0
                result = [result, GW_opt_5(2, j)];
            end
        end
        GW_opt_6(2,i) = max([result, mulGW_true_tmp(6, i)]);
        GW_opt_6(1,i) = mulGW_state_tmp(6, i);
        % 单网关
        b = find(GW_bin > 0);
        single_opt_6(i) = max(Nscale_true_tmp(b));
    end

    GW_opt_7 = zeros(2, 1);
    GW_opt_7(1) = mulGW_state_tmp(7,1);
    GW_opt_7(2) = max([GW_opt_6(2, :), mulGW_true_tmp(7, 1)]);
    GW_opt_2_result = [GW_opt_2_result, GW_opt_2(2,:)];
    GW_opt_3_result = [GW_opt_3_result, GW_opt_3(2,:)];
    GW_opt_4_result = [GW_opt_4_result, GW_opt_4(2,:)];
    GW_opt_5_result = [GW_opt_5_result, GW_opt_5(2,:)];
    GW_opt_6_result = [GW_opt_6_result, GW_opt_6(2,:)];
    GW_opt_7_result = [GW_opt_7_result, GW_opt_7(2)];

    single_opt_7 = max(Nscale_true_tmp);
    single_opt_2_result = [single_opt_2_result, single_opt_2];
    single_opt_3_result = [single_opt_3_result, single_opt_3];
    single_opt_4_result = [single_opt_4_result, single_opt_4];
    single_opt_5_result = [single_opt_5_result, single_opt_5];
    single_opt_6_result = [single_opt_6_result, single_opt_6];
    single_opt_7_result = [single_opt_7_result, single_opt_7];
    
end
% 最优策略
GW2 = mean(GW_opt_2_result) / 33;
GW3 = mean(GW_opt_3_result) / 33;
GW4 = mean(GW_opt_4_result) / 33;
GW5 = mean(GW_opt_5_result) / 33;
GW6 = mean(GW_opt_6_result) / 33;
GW7 = mean(GW_opt_7_result) / 33;
plot(2:7, [GW2, GW3, GW4, GW5, GW6, GW7], 'r');  hold on;
% 全叠加策略
GW2_add = sum(a_mulGW_true(2,:)) / a_mulGW_num(2) / 2 / 33;
GW3_add = sum(a_mulGW_true(3,:)) / a_mulGW_num(3) / 2 / 33;
GW4_add = sum(a_mulGW_true(4,:)) / a_mulGW_num(4) / 2 / 33;
GW5_add = sum(a_mulGW_true(5,:)) / a_mulGW_num(5) / 2 / 33;
GW6_add = sum(a_mulGW_true(6,:)) / a_mulGW_num(6) / 2 / 33;
GW7_add = sum(a_mulGW_true(7,:)) / a_mulGW_num(7) / 2 / 33;
plot(2:7, [GW2_add, GW3_add, GW4_add, GW5_add, GW6_add, GW7_add], 'b');  hold on;
% 单网关最优
single2 = mean(single_opt_2_result) / 33;
single3 = mean(single_opt_3_result) / 33;
single4 = mean(single_opt_4_result) / 33;
single5 = mean(single_opt_5_result) / 33;
single6 = mean(single_opt_6_result) / 33;
single7 = mean(single_opt_7_result) / 33;
plot(2:7, [single2, single3, single4, single5, single6, single7], 'g');  hold on;
legend('opt','strawman','Nscale');
ylabel('mean-BER');
xlabel('GW-num');
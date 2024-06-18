% 寻找多网关选择策略阈值
tic;
% pkg_array = ["pkg1", "pkg2"];
% sf_array = ["sf7", "sf8", "sf9", "sf10"];
% sir_array = ["sir_5", "sir0", "sir5"];
pkg_array = ["pkg2"];
sf_array = ["sf8"];
sir_array = ["sir5"];
times = 200;
for pkg_count = 1:length(pkg_array)
    for SIR_count = 1:length(sir_array)
%         figure(SIR_count + 3*(pkg_count-1));
        for SF_count = 1:length(sf_array)

                sinGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_sinGW_true'));
                SNR_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_SNR_arr'));
                posGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_posGW_arr'));
                binGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_binGW_arr'));
                mulGW_true_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_true'));
                mulGW_state_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_state'));
                argGW_arr_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_argGW_arr'));
                sin_off_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_sin_off'));
                mulGW_conpos_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_conpos'));
                mulGW_bin_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_mulGW_bin'));
                a_sin_off = eval(sin_off_name);
                a_sinGW_true = eval(sinGW_true_name);
                a_SNR_arr = eval(SNR_arr_name);
                a_posGW_arr = eval(posGW_arr_name);
                a_binGW_arr = eval(binGW_arr_name);
                a_mulGW_true = eval(mulGW_true_name);
                a_mulGW_state = eval(mulGW_state_name);
                a_argGW_arr = eval(argGW_arr_name);
                a_mulGW_conpos = eval(mulGW_conpos_name);
                a_mulGW_bin = eval(mulGW_bin_name);
    
                % 最优策略
%                 [GW_choice_result] = get_choice_result(a_mulGW_state, a_mulGW_true, a_argGW_arr, times, sir_array(SIR_count), pkg_array(pkg_count), arg_test);
                [GW_opt_result, ~, GW_opt_choice_result, GW_opt_conpos_result, GW_opt_bin_result] = get_opt_GT(a_mulGW_state, a_mulGW_true, a_mulGW_conpos, a_mulGW_bin, a_sinGW_true, times, pkg_array(pkg_count));
                
                result_analyze = zeros(0);
                for GW_count = 1:times
                    GW_bin = bitget(GW_opt_choice_result(6, GW_count),1:7);
                    GW_posbin = [GW_opt_conpos_result(6, GW_count), GW_opt_bin_result(6, GW_count), GW_opt_result(6, GW_count), zeros(1,4)];
                    result_analyze = [result_analyze; a_argGW_arr(7*(GW_count-1)+1:7*GW_count,:), GW_bin', GW_posbin'];
                end
        end
        % legend('opt','strawman','Nscale','single','choice');
        % legend('opt','single','choice');
    end
end
% sin_max1_flag = zeros(7*times,1);
% sin_max2_flag = zeros(7*times,1);
sin_pos_flag = zeros(7*times,1);
sin_bin_flag = zeros(7*times,1);
sin_off_flag = zeros(7*times,1);
for i = 1:times
%     tmp = a_sinGW_true(i, 1:2:13);
%     max_value = max(tmp);
%     max_pos = find(tmp == max_value);
%     sin_tmp = zeros(7,1);
%     sin_tmp(max_pos) = 1;
%     sin_max1_flag(7*(i-1)+1:7*i) = sin_tmp;
% 
%     tmp = a_sinGW_true(i, 2:2:14);
%     max_value = max(tmp);
%     max_pos = find(tmp == max_value);
%     sin_tmp = zeros(7,1);
%     sin_tmp(max_pos) = 1;
%     sin_max2_flag(7*(i-1)+1:7*i) = sin_tmp;
% 
    sin_pos_flag(7*(i-1)+1:7*i) = a_posGW_arr(i, :);
    sin_bin_flag(7*(i-1)+1:7*i) = a_binGW_arr(i, :);
    sin_off_flag(7*(i-1)+1:7*i) = a_sin_off(i, :);
end

result_analyze(:, 21) = result_analyze(:, 14);  % 19行保存最优挑选结果
result_analyze(:, 22) = result_analyze(:, 15);  % 19行保存最优挑选结果
% result_analyze(:, 10) = sin_max1_flag;
% result_analyze(:, 11) = sin_max2_flag;
result_analyze(:, 14) = sin_pos_flag;   % 14行保存单网关冲突发现位置
result_analyze(:, 15) = sin_bin_flag;   % 15行保存单网关冲突发现bin
result_analyze(:, 20) = sin_off_flag;   % 21行保存单网关对齐值
MG_sel_flag = zeros(7*times,1);
MG_sel_tmp_flag = zeros(7*times,1);
choice_true = zeros(7*times,1);
for i = 1:times
    % 两个k之间必须异号
    k_tmp = result_analyze(7*(i-1)+1:7*i, 10:11);
    con_1 = ones(1,7);
    for count = 1:7
        if sign(k_tmp(count, 1)) == sign(k_tmp(count, 2)) || sign(k_tmp(count, 1)) <= 0
            con_1(count) = 0;
        end
    end
    arg_tmp = result_analyze(7*(i-1)+1:7*i, 10:13);
    k = abs(arg_tmp(:, 1)) + abs(arg_tmp(:, 2));
    residual = abs(arg_tmp(:, 3)) + abs(arg_tmp(:, 4));
    arg_fin = k ./ residual;
    arg_fin = normalize(arg_fin,'range'); % 归一化
    
    % 投票挑选
    tmp = result_analyze(7*(i-1)+1:7*i, 14:15);
    [MG_sel, ~] = get_conflict_posbin(tmp(:, 1), tmp(:, 2));
    MG_sel_flag(7*(i-1)+1:7*i) = bitand(MG_sel', con_1);
    % 根据参数选择网关
    find_tmp = find(arg_fin >= 0.4);
    bin_index = zeros(1,7);
    bin_index(find_tmp) = 1;
    MG_sel_tmp_flag(7*(i-1)+1:7*i) = bitand(bin_index, con_1);
    % 拿到选择结果对应的包正确率
    tmp = MG_sel_tmp_flag(7*(i-1)+1:7*i)';
    if sum(tmp) > 0
        choice_tmp = fliplr(tmp);
        choice_t = bin2dec(num2str(choice_tmp));
        mulGW_state_tmp = a_mulGW_state(7*(i-1)+1:7*i, :);
        mulGW_true_tmp = a_mulGW_true(7*(i-1)+1:7*i, 2:2:35*2);
        mulGW_compos_tmp = a_mulGW_conpos(7*(i-1)+1:7*i, :);
        mulGW_bin_tmp = a_mulGW_bin(7*(i-1)+1:7*i, :);
        choice = find(mulGW_state_tmp(sum(tmp), :) == choice_t);
        choice_true(7*(i-1)+1:7*(i-1)+3) = [mulGW_compos_tmp(sum(tmp), choice), mulGW_bin_tmp(sum(tmp), choice), mulGW_true_tmp(sum(tmp), choice)];
    else
        mulGW_true_tmp = a_mulGW_true(7*(i-1)+1:7*i, 2:2:35*2);
        mulGW_compos_tmp = a_mulGW_conpos(7*(i-1)+1:7*i, :);
        mulGW_bin_tmp = a_mulGW_bin(7*(i-1)+1:7*i, :);
        [choice_true(7*(i-1)+3), max_index] = max(mulGW_true_tmp(1, :));
        choice_true(7*(i-1)+1) = mulGW_compos_tmp(1, max_index);
        choice_true(7*(i-1)+2) = mulGW_bin_tmp(1, max_index);
    end
end
result_analyze(:, 16) = MG_sel_flag;  % 16行保存网关投票结果
result_analyze(:, 17) = MG_sel_tmp_flag;  % 17行保存参数挑选结果
result_analyze(:, 23) = choice_true;

arg_tmp = result_analyze(:, 10:13);
arg_tmp = abs(arg_tmp) ./ sum(abs(arg_tmp), 2);
k = abs(arg_tmp(:, 1)) + abs(arg_tmp(:, 2));
residual = abs(arg_tmp(:, 3)) + abs(arg_tmp(:, 4));
arg_tmp = k ./ residual;
result_analyze(:, 18) = arg_tmp; % 18行保存整合参数
for i = 1:times
    tmp = arg_tmp(7*(i-1)+1:7*i);
    arg_tmp(7*(i-1)+1:7*i) = normalize(tmp,'range');
end
result_analyze(:, 19) = arg_tmp; % 19行保存归一化参数值
% 找到与最优正确率相同的所有情况
for i = 1:times
    opt_true = GW_opt_result(6,i);
    mulGW_true_tmp = a_mulGW_true(7*(i-1)+1:7*i, 2:2:35*2);
    mulGW_state_tmp = a_mulGW_state(7*(i-1)+1:7*i, :);
    tmp_index = find(mulGW_true_tmp == opt_true);
    if ~isempty(tmp_index)
        tmp = mulGW_state_tmp(tmp_index);
        GW_bin = zeros(0);
        for count = 1:length(tmp)
            GW_bin_tmp = bitget(tmp(count), 1:7)';
            GW_bin = [GW_bin, GW_bin_tmp];
        end
        result_analyze(7*(i-1)+1:7*i, 25:25+length(tmp)-1) = GW_bin;
    end
end
% 输出单网关正确率情况
for i = 1:times
    result_analyze(7*(i-1)+1:7*i, 24) = a_sinGW_true(i, 2:2:14);
end
% 统计conpos和bin的正确率
vote_rate = zeros(1, times);
cho_rate = zeros(1, times);
for i = 1:times
    tmp = result_analyze(7*(i-1)+1:7*i, 14:15);
    [~, vote_conpos, vote_bin, ~] = get_conflict_posbin(tmp(:, 1), tmp(:, 2));
    opt_con = result_analyze(7*(i-1)+1, 22);
    opt_bin = result_analyze(7*(i-1)+2, 22);
    cho_con = result_analyze(7*(i-1)+1, 23);
    cho_bin = result_analyze(7*(i-1)+2, 23);
    if vote_conpos == opt_con && vote_bin == opt_bin
        vote_rate(i) = 1;
    end
    if cho_con == opt_con && cho_bin == opt_bin
        cho_rate(i) = 1;
    end
end
disp(mean(vote_rate));
disp(mean(cho_rate));
% 统计有投票结果下的正确率与无投票结果下的正确率
vote_rate = zeros(0);
same_rate = zeros(0);
for i = 1:times
    tmp = result_analyze(7*(i-1)+1:7*i, 14:15);
    [~, vote_conpos, vote_bin, vote_flag] = get_conflict_posbin(tmp(:, 1), tmp(:, 2));
    opt_con = result_analyze(7*(i-1)+1, 22);
    opt_bin = result_analyze(7*(i-1)+2, 22);
    sin_con = result_analyze(7*(i-1)+1:7*i, 14);
    sin_bin = result_analyze(7*(i-1)+1:7*i, 15);
    if vote_flag == 1 % 有共识
        if vote_conpos == opt_con && vote_bin == opt_bin
            vote_rate = [vote_rate, 1];
        else
            vote_rate = [vote_rate, 0];
        end
    else % 无共识
        same_con_index = find(sin_con == opt_con);
        if length(same_con_index) > 1
            same_bin_index = find(sin_bin(same_con_index) == opt_bin);
            if length(same_bin_index) > 1
                same_rate = [same_rate, 1];
            else
                same_rate = [same_rate, 0];
            end
        else
            same_rate = [same_rate, 0];
        end
    end
end
disp(length(vote_rate)/times);
disp(mean(vote_rate));
disp(length(same_rate)/times);
disp(mean(same_rate));
% 统计多网关冲突发现和最优相同的情况下 最优 多网关 单网关最优SER
opt_true = zeros(1, times);
sinmax_true = zeros(1, times);
choice_true = zeros(0);
for i = 1:times
    opt_true(i) = result_analyze(7*(i-1)+3, 22);
    sinmax_true(i) = max(a_sinGW_true(i, 2:2:14));
    if result_analyze(7*(i-1)+1, 22) == result_analyze(7*(i-1)+1, 23) && result_analyze(7*(i-1)+2, 22) == result_analyze(7*(i-1)+2, 23)
        choice_true = [choice_true, result_analyze(7*(i-1)+3, 23)];
    end
end
disp('统计多网关冲突发现和最优相同的情况下 最优 多网关 单网关最优SER');
disp(mean(opt_true)/38);
disp(mean(sinmax_true)/38);
disp(mean(choice_true)/38);
% num1 = sum(result_analyze(:, 15));
% num2 = sum((result_analyze(:, 15) == 1) & (result_analyze(:, 15) == result_analyze(:, 16)));
% disp(num2/num1);

% tmp = sum(abs(result_analyze(:, 1:4)), 2);
% data_all = abs(result_analyze(:, 1:4)) ./ tmp;
% data_all = mean(abs(data_all(:, 1:2)), 2) ./ mean(abs(data_all(:, 3:4)), 2) .* result_analyze(:, 5);
% data_all = [data_all, result_analyze(:, 15)];

% x_sim = (abs(data_all(:,1)) + abs(data_all(:,2)))/2;
% y_sim = (abs(data_all(:,3)) + abs(data_all(:,4)))/2;
% plot(x_sim, y_sim, 'b.');
% z_sim = result_analyze(:,10);
% data = [x_sim, y_sim];
% result = z_sim;
% SVMModel = fitcsvm(data,result);
% CVSVMModel = crossval(SVMModel);   %分类器的交叉验证
% classLoss = kfoldLoss(CVSVMModel);%  样本内错误率
% disp(classLoss);

% [~, score] = predict(SVMModel, data(5001:end, :));%; %样本外的数据进行分类预测
% [label,scorePred] = kfoldPredict(CVSVMModel); %样本外的数据进行分类预测结果，
% x_sim = (abs(result_analyze(:,1)) + abs(result_analyze(:,2)))/2;
% y_sim = (abs(result_analyze(:,3)) + abs(result_analyze(:,4)))/2;
% data = [x_sim, y_sim];
% select = zeros(0);
% select_none = zeros(0);
% for i = 1:7000
%     if z_sim(i) == 1
%         select = [select; data(i,:)];
%     else
%         select_none = [select_none; data(i,:)];
%     end
% end
% plot(select(:,1),select(:,2),'r.'); hold on;
% plot(select_none(:,1),select_none(:,2),'b.');
% toc;

%     % 投票挑选
%     tmp = result_analyze(7*(i-1)+1:7*i, 14:15);
%     [MG_sel, ~] = get_conflict_posbin(tmp(:, 1), tmp(:, 2));
%     % 对投票挑选结果进行筛选
%     arg_tmp = result_analyze(7*(i-1)+1:7*i, 10:13);
%     k = abs(arg_tmp(:, 1)) + abs(arg_tmp(:, 2));
%     residual = abs(arg_tmp(:, 3)) + abs(arg_tmp(:, 4));
%     arg_fin = k ./ residual;
%     arg_fin = normalize(arg_fin,'range'); % 归一化
%     find_tmp = find(arg_fin >= 0.4);
%     bin_index = zeros(1,7);
%     bin_index(find_tmp) = 1;
%     % 投票挑选最终结果
%     MG_sel_flag(7*(i-1)+1:7*i) = bitand(bitand(MG_sel', bin_index), con_1);
%     % 对投票未选上的网关进行筛选
%     tmp = find(MG_sel == 0);
%     if ~isempty(tmp)
%         arg_tmp = result_analyze(7*(i-1)+1:7*i, 10:13);
%         k = abs(arg_tmp(:, 1)) + abs(arg_tmp(:, 2));
%         residual = abs(arg_tmp(:, 3)) + abs(arg_tmp(:, 4));
%         arg_fin = k ./ residual;
%         arg_fin = normalize(arg_fin,'range'); % 归一化
%         find_tmp = find(arg_fin(tmp) >= 0.2);
%         bin_index = zeros(1,7);
%         bin_index(tmp(find_tmp)) = 1;
%         result_analyze(7*(i-1)+1:7*i, 17) = bitand(bitor(bin_index, MG_sel_flag(7*(i-1)+1:7*i)'), con_1);
%     end


function [conflict_flag, conflict_pos, pkg2_pre_bin, conflict_arg] = find_conflict_tmp(G0, lora_set, d_downchirp_cfo, times)
    d_sf = lora_set.sf;
    d_bw = lora_set.bw;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    filter_num = lora_set.filter_num;
    Pkg_length = lora_set.Pkg_length;
    leakage_width1 = lora_set.leakage_width1;
    leakage_width2 = lora_set.leakage_width2;
    Preamble_length = lora_set.Preamble_length;
    conflict_flag = 0;
    conflict_pos = 0;
    pkg2_pre_bin = 0;
    conflict_arg = zeros(1,6);

    % 对齐，处理CFO的窗口进行FFT
    conflict_samples = reshape(G0(1:Pkg_length*2*dine),[dine,Pkg_length*2]).';
    conflict_dechirp = conflict_samples .* d_downchirp_cfo;
    conflict_fft = abs(fft(conflict_dechirp,dine,2));
    conflict_fft_merge = [conflict_fft(:,1:fft_x/2) + conflict_fft(:,dine-fft_x+1:dine-fft_x/2), conflict_fft(:,dine-fft_x/2+1:dine)+conflict_fft(:,fft_x/2+1:fft_x)];
    
    % 找出每个FFT窗口前filter_num数目的峰
    [peak,pos] = sort(conflict_fft_merge,2,'descend');         % 对FFT进行排序
    Peak_pos = zeros(size(pos,1),filter_num);
    Peak_amp = zeros(size(peak,1),filter_num);
    Peak_pos(:,1) = pos(:,1);
    Peak_amp(:,1) = peak(:,1);
    for row = 1:size(pos,1)
        temp_array = ones(1,size(pos,2));
        for list = 1:filter_num
            temp_array = temp_array & (abs(Peak_pos(row,list) - pos(row,:)) > fft_x*leakage_width1 & abs(Peak_pos(row,list) - pos(row,:)) < fft_x*leakage_width2);
            temp_num = find(temp_array==1,1,'first');
            Peak_pos(row,list+1) = pos(row,temp_num);
            Peak_amp(row,list+1) = peak(row,temp_num);
        end
    end

    % 把对齐的第一个包的Preamble的峰给除去
    conflict_fft_merge(1:Preamble_length,1:fix(fft_x*leakage_width1)) = 0;     % 去除包1的Preamble峰值
    conflict_fft_merge(1:Preamble_length,fix(fft_x*leakage_width2):fft_x) = 0;
    
    % 叠加FFT窗口
    conflict_superimpose = [zeros(Preamble_length-1,size(conflict_fft_merge,2));conflict_fft_merge;zeros(Preamble_length-1,size(conflict_fft_merge,2))]; % 设置储存叠加FFT后
    for i = 1:size(conflict_superimpose,1)-(Preamble_length-1)      % 移动叠加窗口，一直到倒数第八个窗口
        for j = 1:Preamble_length-1                                 % 叠加8个窗口，记录在原数组中
            conflict_superimpose(i,:) = conflict_superimpose(i,:) + conflict_superimpose(i+j,:);
        end
    end
    
    % fft_plot(conflict_superimpose, lora_set, 40);

    % 对叠加后的FFT取前filter_num的峰
    [peak,pos] = sort(conflict_superimpose(1:size(conflict_superimpose,1)-(Preamble_length-1),:),2,'descend');         % 对FFT进行排序
    Peak_pos = pos(:,1:filter_num);
    Peak_amp = peak(:,1:filter_num);
    
    % 获得每个峰值重复出现的次数
    counter_array = zeros(1,fft_x);
    counter_result_tmp = zeros(1,fft_x);
    counter_result = zeros(2,fft_x);
    counter_array(Peak_pos(1,:)) = 1;
%     for col = 2:size(Peak_pos,1)
    for col = 2:Pkg_length+Preamble_length+2
%     for col = 2:Pkg_length+Preamble_length*2
        counter_array(Peak_pos(col,:)) = counter_array(Peak_pos(col,:)) + 1;
        counter_result_tmp = counter_array;
        condition_1 = find(counter_result_tmp > 9);
        if length(condition_1) >= 1
            for i = 1:length(condition_1)
                if counter_result_tmp(condition_1(i)) > counter_result(1,condition_1(i))
                    counter_result(1,condition_1(i)) = counter_result_tmp(condition_1(i));
                    if sum(condition_1(i) == Peak_pos(col,:))
                        counter_result(2,condition_1(i)) = col;
                    else
                        counter_result(2,condition_1(i)) = col - 1;
                    end
                end
            end
        end
        counter_result_tmp = zeros(1,fft_x);
        counter_result_tmp(Peak_pos(col,:)) = counter_array(Peak_pos(col,:));
        counter_array = counter_result_tmp;
    end
    
    % 找到满足重复次数9以上的叠加峰，并且满足上升后下降的趋势
    [repeat_count,repeat_bin] = sort(counter_result(1,:),'descend');
    conflict_maybe = find(repeat_count > 9);
    conflict_alter = zeros(10,length(conflict_maybe));   % 第一行flag，第二行冲突位置，第三行重复出现的bin，第四行最高峰的值和最大残差的比值，第五行第六行系数k，第七行第八行残差，第九行重复出现次数
    for i = 1:length(conflict_maybe)
        superimpose_pos = counter_result(2,repeat_bin(i));
        superimpose_count = counter_result(1,repeat_bin(i));
        condition_1 = (Peak_pos == repeat_bin(i));
        condition_1 = condition_1(superimpose_pos-superimpose_count+1:superimpose_pos,:);
        condition_2 = Peak_amp(superimpose_pos-superimpose_count+1:superimpose_pos,:);
%         condition_3 = condition_2(condition_1);
        condition_3 = zeros(size(condition_1,1),1);   % 重复出现峰的峰值强度数组
        for i_tmp = 1:size(condition_1,1)
            condition_3(i_tmp) = condition_2(i_tmp,find(condition_1(i_tmp,:) > 0));
        end
        [~, max_pos] = max(condition_3);
        max_pos_mean = mean(conflict_superimpose(superimpose_pos-superimpose_count+max_pos));
        if max_pos >= 2 && max_pos <= length(condition_3)-1
            x_1 = 1:max_pos;
            x_2 = max_pos:length(condition_3);
            p_1 = polyfit(x_1,condition_3(x_1),1);
            p_2 = polyfit(x_2,condition_3(x_2),1);
            residual_1 = sum(abs(condition_3(x_1)' - polyval(p_1,x_1)))/length(x_1);
            residual_2 = sum(abs(condition_3(x_2)' - polyval(p_2,x_2)))/length(x_2);
            con_1 = max_pos >= 3 && max_pos <= length(condition_3) - 2;   % 最大值发现在第3个和倒数第2个之间
            con_2 = p_1(1)*3.5 > residual_1;                                 % 系数k和残差的比较
            con_3 = abs(p_2(1)*3.5) > residual_2;
            con_4 = abs(p_1(1) + p_2(1)) < max(p_1(1),abs(p_2(1)))*0.4;   % 两个k值比较
        else
            con_1 = 0;  con_2 = 0; con_3 = 0; con_4 = 0;
        end
        if con_1 && (con_2 || con_3) && con_4
            conflict_start_pos = superimpose_pos - superimpose_count + 1;
            highest_superimpose_pos = max_pos;
            highest_superimpose = conflict_start_pos + highest_superimpose_pos - 1;
            if repeat_bin(i) > fft_x * 0.5
                conflict_pos = highest_superimpose - 7;
            else
                conflict_pos = highest_superimpose - 8;
            end
            condition_1_1 = abs(repeat_bin(i) - fft_x*0.5) < fft_x*0.05;   % bin值在中间范围内
            condition_1_2 = abs( condition_3(max_pos)-condition_3(max_pos-1) ) < condition_3(max_pos)*leakage_width1;    % 最大峰值和左边一个窗口峰值接近
            condition_1_3 = abs( condition_3(max_pos)-condition_3(max_pos+1) ) < condition_3(max_pos)*leakage_width1;    % 最大峰值和右边一个窗口峰值接近
            if condition_1_1 && condition_1_2 
                conflict_pos = highest_superimpose - 8;
            elseif condition_1_1 && condition_1_3 
                conflict_pos = highest_superimpose - 7;
            end
            if conflict_pos >= 3 && conflict_pos <= Pkg_length - 3
%             if conflict_pos >= 3 && conflict_pos <= Pkg_length
                conflict_alter(1,i) = 1;    % 第一行：flag
                conflict_alter(2,i) = conflict_pos;               % 第二行：冲突位置
                conflict_alter(3,i) = repeat_bin(i);              % 第三行：重复出现的bin
                conflict_alter(4,i) = condition_3(max_pos);       % 第四行：最高峰的值
                conflict_alter(5,i) = p_1(1);                     % 第五行：左边斜率
                conflict_alter(6,i) = p_2(1);                     % 第六行：右边斜率      
                conflict_alter(7,i) = residual_1;                 % 第七行：左边斜线残值
                conflict_alter(8,i) = residual_2;                 % 第八行：右边斜线残值
                conflict_alter(9,i) = superimpose_count;          % 第九行：峰值连续出现的窗口次数
                conflict_alter(10,i) = condition_3(max_pos)/max_pos_mean;          % 第十行：叠加后最高峰与窗口均值之比
            end
        end
    end
    alter_index = find(conflict_alter(1,:)==1);
    if size(alter_index,2) < 1
        conflict_flag = 0;
         %TODO 循环位移
        if times == 2
            [conflict_flag, conflict_pos, pkg2_pre_bin, conflict_arg] = find_conflict(circshift(G0,2), lora_set, d_downchirp_cfo, 1);
        elseif times == 1
            [conflict_flag, conflict_pos, pkg2_pre_bin, conflict_arg] = find_conflict(circshift(G0,-4), lora_set, d_downchirp_cfo, 0);
        end
    elseif size(alter_index,2) == 1
        conflict_flag = 3;
        conflict_pos = conflict_alter(2,alter_index);
        pkg2_pre_bin = conflict_alter(3,alter_index);
        conflict_arg(1:6) = conflict_alter(5:10,alter_index)';
    else
        alter_index_t = conflict_alter(:,alter_index(1));
        for i = 2:size(alter_index,2)
            alter_index_t = [alter_index_t,conflict_alter(:,alter_index(i))];
        end
        [~,max_pos] = max(alter_index_t(4,:));
        conflict_flag = 3;
        conflict_pos = alter_index_t(2,max_pos);
        pkg2_pre_bin = alter_index_t(3,max_pos);
        conflict_arg(1:6) = alter_index_t(5:10,max_pos)';
    end
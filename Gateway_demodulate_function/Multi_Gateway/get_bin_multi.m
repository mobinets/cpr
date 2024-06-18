function [Pkg1_bin, Pkg2_bin] = get_bin_multi(lora_set, Pkg1_samples_fft_merge, Pkg2_samples_fft_merge, Peak_rate_full, conflict_pos, pkg2_pre_bin)
    fft_x = lora_set.fft_x;
    filter_num = lora_set.filter_num;
    Pkg_length = lora_set.Pkg_length;
    leakage_width1 = lora_set.leakage_width1;
    leakage_width2 = lora_set.leakage_width2;
    Preamble_length = lora_set.Preamble_length;
    
    if Peak_rate_full >= 1 % 包1峰比包2峰高
        % 对包1的bin值排序，找到前filter_num的峰值，消除频谱泄露
        [peak,pos] = sort(Pkg1_samples_fft_merge,2,'descend');         % 对FFT进行排序
        Peak1_pos = zeros(size(pos,1),filter_num);
        Peak1_amp = zeros(size(peak,1),filter_num);
        Peak1_pos(:,1) = pos(:,1);
        Peak1_amp(:,1) = peak(:,1);
        for row = 1:size(pos,1)
            temp_array = ones(1,size(pos,2));
            for list = 1:filter_num
                temp_array = temp_array & (abs(Peak1_pos(row,list) - pos(row,:)) > fft_x*leakage_width1 & abs(Peak1_pos(row,list) - pos(row,:)) < fft_x*leakage_width2);
                temp_num = find(temp_array==1,1,'first');
                Peak1_pos(row,list+1) = pos(row,temp_num);
                Peak1_amp(row,list+1) = peak(row,temp_num);
            end
        end
        Pkg1_bin = Peak1_pos(:,1);                      % 保存了从preamble到payload的所有信息
        % 根据preamble对齐bin
        Pkg1_pre_bin_tmp = mode(Pkg1_bin(1:8));
        Pkg1_pre_bin_num = length(find( Pkg1_bin(1:8)==Pkg1_pre_bin_tmp ));
        if Pkg1_pre_bin_num >= 4
            Pkg1_bin = mod(Pkg1_bin+fft_x+1-Pkg1_pre_bin_tmp,fft_x);
            spe_tmp = find( Pkg1_bin == 0);
            Pkg1_bin(spe_tmp) = fft_x;
        end
        Pkg1_map_Pkg2 = zeros(1,length(Pkg1_bin));      % 转换成对齐包2窗口时的bin值
        if conflict_pos >= Preamble_length+5
            Pkg1_map_Pkg2(conflict_pos:conflict_pos+Preamble_length+3) = mod(Pkg1_bin(conflict_pos:conflict_pos+Preamble_length+3) + fft_x+1 - pkg2_pre_bin - fft_x*0.25, fft_x+1);   % 转换成对齐包1窗口时的bin值
            Pkg1_map_Pkg2(conflict_pos+Preamble_length+4:end) = mod(Pkg1_bin(conflict_pos+Preamble_length+4:end) + fft_x+1 - pkg2_pre_bin, fft_x+1); 
        else
            Pkg1_map_Pkg2(conflict_pos:Preamble_length+4) = mod(Pkg1_bin(conflict_pos:Preamble_length+4) + pkg2_pre_bin - 1, fft_x+1);
            Pkg1_map_Pkg2(Preamble_length+5:conflict_pos+Preamble_length+3) = mod(Pkg1_bin(Preamble_length+5:conflict_pos+Preamble_length+3) + fft_x+1 - pkg2_pre_bin - fft_x*0.25, fft_x+1);
            Pkg1_map_Pkg2(conflict_pos+Preamble_length+4:end) = mod(Pkg1_bin(conflict_pos+Preamble_length+4:end) + fft_x+1 - pkg2_pre_bin, fft_x+1); 
        end

        for col = conflict_pos:Pkg_length-1              % 循环到倒数第二行
            for row = 0:1
                condition_1 = abs(Pkg1_map_Pkg2(col+row)-[1:fft_x]) < fft_x*leakage_width1;   % 找到fft_x*leakage_width1范围内的所有包1的峰
                condition_2 = abs(Pkg1_map_Pkg2(col+row)-[1:fft_x]) > fft_x*leakage_width2;
                sidelobe_index = condition_1 | condition_2;
                Pkg2_samples_fft_merge(col-conflict_pos+1,sidelobe_index) = 0;
            end
        end
        % 最后一行单独处理
        condition_1 = abs(Pkg1_map_Pkg2(Pkg_length)-[1:fft_x]) < fft_x*leakage_width1;   % 找到fft_x*leakage_width1范围内的所有包1的峰
        condition_2 = abs(Pkg1_map_Pkg2(Pkg_length)-[1:fft_x]) > fft_x*leakage_width2;
        sidelobe_index = condition_1 | condition_2;
        Pkg2_samples_fft_merge(end-conflict_pos+1,sidelobe_index) = 0;
        % 对包2的峰进行排序，找到前filter_num的峰值，消除频谱泄露
        [peak,pos] = sort(Pkg2_samples_fft_merge,2,'descend');         % 对FFT进行排序
        Peak2_pos = zeros(size(pos,1),filter_num);
        Peak2_amp = zeros(size(peak,1),filter_num);
        Peak2_pos(:,1) = pos(:,1);
        Peak2_amp(:,1) = peak(:,1);
        for row = 1:size(pos,1)
            temp_array = ones(1,size(pos,2));
            for list = 1:filter_num
                temp_array = temp_array & (abs(Peak2_pos(row,list) - pos(row,:)) > fft_x*leakage_width1 & abs(Peak2_pos(row,list) - pos(row,:)) < fft_x*leakage_width2);
                temp_num = find(temp_array==1,1,'first');
                Peak2_pos(row,list+1) = pos(row,temp_num);
                Peak2_amp(row,list+1) = peak(row,temp_num);
            end
        end
        Pkg2_bin = Peak2_pos(:,1);    % 保存了从preamble到payload的所有信息
        Pkg2_pre_bin_tmp = mode(Pkg2_bin(1:8));
        Pkg2_pre_bin_num = length(find( Pkg2_bin(1:8)==Pkg2_pre_bin_tmp ));
        if Pkg2_pre_bin_num >= 4
            Pkg2_bin = mod(Pkg2_bin+fft_x+1-Pkg2_pre_bin_tmp,fft_x);
            spe_tmp = find( Pkg2_bin == 0);
            Pkg2_bin(spe_tmp) = fft_x;
        end
        i = 1;
    else
        % 对包2的峰进行排序，找到前filter_num的峰值，消除频谱泄露
        [peak,pos] = sort(Pkg2_samples_fft_merge,2,'descend');         % 对FFT进行排序
        Peak2_pos = zeros(size(pos,1),filter_num);
        Peak2_amp = zeros(size(peak,1),filter_num);
        Peak2_pos(:,1) = pos(:,1);
        Peak2_amp(:,1) = peak(:,1);
        for row = 1:size(pos,1)
            temp_array = ones(1,size(pos,2));
            for list = 1:filter_num
                temp_array = temp_array & (abs(Peak2_pos(row,list) - pos(row,:)) > fft_x*leakage_width1 & abs(Peak2_pos(row,list) - pos(row,:)) < fft_x*leakage_width2);
                temp_num = find(temp_array==1,1,'first');
                Peak2_pos(row,list+1) = pos(row,temp_num);
                Peak2_amp(row,list+1) = peak(row,temp_num);
            end
        end
        Pkg2_bin = Peak2_pos(:,1);    % 保存了从preamble到payload的所有信息
        Pkg2_pre_bin_tmp = mode(Pkg2_bin(1:8));
        Pkg2_pre_bin_num = length(find( Pkg2_bin(1:8)==Pkg2_pre_bin_tmp ));
        if Pkg2_pre_bin_num >= 4
            Pkg2_bin = mod(Pkg2_bin+fft_x+1-Pkg2_pre_bin_tmp,fft_x);
            spe_tmp = find( Pkg2_bin == 0);
            Pkg2_bin(spe_tmp) = fft_x;
        end
        Pkg2_map_Pkg1 = zeros(1,length(Pkg2_bin));
        if conflict_pos >= Preamble_length+5
            Pkg2_map_Pkg1(1:Preamble_length+4) = mod(Pkg2_bin(1:Preamble_length+4) + pkg2_pre_bin + fft_x*0.25 - 1, fft_x+1);   % 转换成对齐包1窗口时的bin值
            Pkg2_map_Pkg1(Preamble_length+5:end) = mod(Pkg2_bin(Preamble_length+5:end) + pkg2_pre_bin - 1, fft_x+1); 
        else
            Pkg2_map_Pkg1(1:Preamble_length+5-conflict_pos) = mod(Pkg2_bin(1:Preamble_length+5-conflict_pos) + pkg2_pre_bin - 1, fft_x+1);
            Pkg2_map_Pkg1(Preamble_length+5-conflict_pos+1:Preamble_length+4) = mod(Pkg2_bin(Preamble_length+5-conflict_pos+1:Preamble_length+4) + pkg2_pre_bin + fft_x*0.25 - 1, fft_x+1);
            Pkg2_map_Pkg1(Preamble_length+5:end) = mod(Pkg2_bin(Preamble_length+5:end) + pkg2_pre_bin - 1, fft_x+1); 
        end
        
        % 第一行单独处理
        condition_1 = abs(Pkg2_map_Pkg1(1)-[1:fft_x]) < fft_x*leakage_width1;   % 找到fft_x*leakage_width1范围内的所有包1的峰
        condition_2 = abs(Pkg2_map_Pkg1(1)-[1:fft_x]) > fft_x*leakage_width2;
        sidelobe_index = condition_1 | condition_2;
        Pkg1_samples_fft_merge(conflict_pos,sidelobe_index) = 0;
        for col = 2:Pkg_length - conflict_pos + 1           % 循环到包1结束
            for row = -1:0
                condition_1 = abs(Pkg2_map_Pkg1(col+row)-[1:fft_x]) < fft_x*leakage_width1;   % 找到fft_x*leakage_width1范围内的所有包1的峰
                condition_2 = abs(Pkg2_map_Pkg1(col+row)-[1:fft_x]) > fft_x*leakage_width2;
                sidelobe_index = condition_1 | condition_2;
                Pkg1_samples_fft_merge(conflict_pos+col-1,sidelobe_index) = 0;
            end
        end
        % 对包1的bin值排序，找到前filter_num的峰值，消除频谱泄露
        [peak,pos] = sort(Pkg1_samples_fft_merge,2,'descend');         % 对FFT进行排序
        Peak1_pos = zeros(size(pos,1),filter_num);
        Peak1_amp = zeros(size(peak,1),filter_num);
        Peak1_pos(:,1) = pos(:,1);
        Peak1_amp(:,1) = peak(:,1);
        for row = 1:size(pos,1)
            temp_array = ones(1,size(pos,2));
            for list = 1:filter_num
                temp_array = temp_array & (abs(Peak1_pos(row,list) - pos(row,:)) > fft_x*leakage_width1 & abs(Peak1_pos(row,list) - pos(row,:)) < fft_x*leakage_width2);
                temp_num = find(temp_array==1,1,'first');
                Peak1_pos(row,list+1) = pos(row,temp_num);
                Peak1_amp(row,list+1) = peak(row,temp_num);
            end
        end
        Pkg1_bin = Peak1_pos(:,1);    % 保存了从preamble到payload的所有信息
        Pkg1_pre_bin_tmp = mode(Pkg1_bin(1:8));
        Pkg1_pre_bin_num = length(find( Pkg1_bin(1:8)==Pkg1_pre_bin_tmp ));
        if Pkg1_pre_bin_num >= 4
            Pkg1_bin = mod(Pkg1_bin+fft_x+1-Pkg1_pre_bin_tmp,fft_x);
            spe_tmp = find( Pkg1_bin == 0);
            Pkg1_bin(spe_tmp) = fft_x;
        end
    end
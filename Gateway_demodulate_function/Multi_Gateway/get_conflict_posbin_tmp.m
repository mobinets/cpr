function [con_mode, bin_mode, detect_flag] = get_conflict_posbin_tmp(conflict_pos, pkg2_pre_bin)
    detect_flag = 0;
    con_mode = 0;
    bin_mode = 0;
    nz_index = (pkg2_pre_bin ~= 0) & (conflict_pos ~= 0);  % 先找出两个数组中的非零值
    conflict_pos = conflict_pos(nz_index);
    pkg2_pre_bin = pkg2_pre_bin(nz_index);
    [bin_mode_tmp, pick_num] = mode(pkg2_pre_bin);  % 找出重复出现次数最多的bin值和出现次数
    if pick_num > 1
        rec_flag = 1;
    else
        rec_flag = 0;
        detect_flag = 0;
    end
    
    while rec_flag == 1       % 出现次数超过1
        con_pick_bin = conflict_pos(pkg2_pre_bin == bin_mode_tmp);  % 找到重复最多bin对应的conflict_pos
        con_mode_tmp = mode(con_pick_bin);  % 在这些conpos里面找到重复次数最多的conpos
        con_pick_num = sum((con_pick_bin > con_mode_tmp-2) & (con_pick_bin < con_mode_tmp+2));  % 找到相近conpos的数目
        if con_pick_num > 1 % 找到相近的conpos数目大于1，则投票成功
            con_mode = con_mode_tmp;
            bin_mode = bin_mode_tmp;
            detect_flag = 1;
            rec_flag = 0;
        else % 投票失败
            conflict_pos = conflict_pos(pkg2_pre_bin ~= bin_mode_tmp);
            pkg2_pre_bin = pkg2_pre_bin(pkg2_pre_bin ~= bin_mode_tmp);
            [bin_mode_tmp, pick_num] = mode(pkg2_pre_bin);  % 在这些bin里面找到重复次数最多的bin和次数
            if pick_num > 1
                rec_flag = 1;
            else
                rec_flag = 0;
            end
        end
    end
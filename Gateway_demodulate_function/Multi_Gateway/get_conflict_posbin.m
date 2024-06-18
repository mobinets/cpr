function [MG_sel, con_mode, bin_mode, GW_add_flag] = get_conflict_posbin(conflict_pos, pkg2_pre_bin)
    con_mode = mode(conflict_pos);
    pik_num = sum(conflict_pos == con_mode);
    if con_mode == 0 && pik_num > 1 % 如果冲突位置最多的是0
        con_nzero_flag = conflict_pos ~= con_mode;
        if length(con_nzero_flag) == length(conflict_pos)
            GW_add_flag = 0;
            return;
        end
        con_nzero = conflict_pos(con_nzero);
        con_mode = mode(con_nzero);
        con_sel_flag = conflict_pos == con_mode;
        bin_sel = pkg2_pre_bin(con_sel_flag);
        bin_mode = mode(bin_sel);
        pik_num = sum(pkg2_pre_bin(con_sel_flag) == bin_mode);
        if pik_num > 1
            MG_sel = (pkg2_pre_bin <= bin_mode+2) & (pkg2_pre_bin >= bin_mode-2);
            GW_add_flag = 1;
        else
            MG_sel = zeros(7, 1);
            GW_add_flag = 0;
            con_mode = 0;
            bin_mode = 0;
        end
    elseif pik_num > 1    % 如果冲突位置最多的不是0
        con_sel_flag = conflict_pos == con_mode;
        bin_sel = pkg2_pre_bin(con_sel_flag);
        bin_mode = mode(bin_sel);
        pik_num = sum(pkg2_pre_bin(con_sel_flag) == bin_mode);
        if pik_num > 1
            MG_sel = (pkg2_pre_bin <= bin_mode+2) & (pkg2_pre_bin >= bin_mode-2);
            GW_add_flag = 1;
        else
            MG_sel = zeros(7, 1);
            GW_add_flag = 0;
            con_mode = 0;
            bin_mode = 0;
        end
    else
        MG_sel = zeros(7, 1);
        GW_add_flag = 0;
        con_mode = 0;
        bin_mode = 0;
    end

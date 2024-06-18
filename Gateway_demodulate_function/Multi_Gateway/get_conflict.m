function [G_processing, CFO, conflict_pos_MG, pkg2_pre_bin_MG, GW_add_flag] = get_conflict(G0, cfo, conflict_pos, pkg2_pre_bin)
    con_mode = mode(conflict_pos);
    if con_mode == 0  % 如果冲突位置最多的是0
        con_nzero_flag = conflict_pos ~= con_mode;
        if length(con_nzero_flag) == length(conflict_pos);
            GW_add_flag = 0;
            return;
        end
        con_nzero = conflict_pos(con_nzero);
        con_mode = mode(con_nzero);
        con_sel_flag = conflict_pos == con_mode;
        bin_sel = pkg2_pre_bin(con_sel_flag);
        bin_mode = mode(bin_sel);
        MG_sel = pkg2_pre_bin == bin_mode;
        G_processing = G0(MG_sel, :);
        CFO = cfo(MG_sel);
        conflict_pos_MG = con_mode;
        pkg2_pre_bin_MG = bin_mode;
        GW_add_flag = 1;
    else    % 如果冲突位置最多的不是0
        con_sel_flag = conflict_pos == con_mode;
        bin_sel = pkg2_pre_bin(con_sel_flag);
        bin_mode = mode(bin_sel);
        MG_sel = pkg2_pre_bin == bin_mode;
        G_processing = G0(MG_sel, :);
        CFO = cfo(MG_sel);
        conflict_pos_MG = con_mode;
        pkg2_pre_bin_MG = bin_mode;
        GW_add_flag = 1;
    end

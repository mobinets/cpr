function [conpos_result, pkg2bin_result] = get_conpos_pkg2bin(conpos, pkg2bin, conflict_arg)
    % 获取冲突发现位置
    [M, F] = mode(conpos);  
    if M == 0
        array_tmp = find(conpos > 0);
        array_tmp = conpos(array_tmp);
        [M, F] = mode(array_tmp);
    end
    if F == 1
        conflict_arg_tmp = conflict_arg(:, 6);
        [~, max_pos] = max(conflict_arg_tmp);
        conpos_result = conpos(max_pos);
        pkg2bin_result = pkg2bin(max_pos);
        return;
    else
        conpos_result = M;
    end
    
    % 获取pkg2_bin
    find_array = find(conpos == conpos_result);
    pkg2bin_array = pkg2bin(find_array);
    [M, F] = mode(pkg2bin_array); 
    if F == 1
        conflict_arg_tmp = conflict_arg(find_array, 6);
        [~, max_pos] = max(conflict_arg_tmp);
        pkg2bin_result = pkg2bin_array(max_pos);
        return;
    else
        pkg2bin_result = M;
    end
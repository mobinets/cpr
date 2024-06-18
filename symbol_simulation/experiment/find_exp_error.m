multi_num = zeros(1, 4);
pos_true = zeros(1, 4);
for i = 1:size(a_multrue_arr, 1)/4
    multi_ch = a_multrue_arr(3*(i-1)+1:3*i, :);
    if multi_ch(1, 1) == 1
        find_tmp = find(a_sinGW_true(i, [2,6]) >= 32);
        if ~isempty(find_tmp)
            multi_num(1) = multi_num(1) + 1;
            ref = [1,3];
            index = ref(find_tmp(1));
            if a_posGW_arr(i, index) == a_mulpos_arr(i, 1)
                pos_true(1) = pos_true(1) + 1;
            end
        end
    end
    if multi_ch(1, 2) == 1
        find_tmp = find(a_sinGW_true(i, 2:2:6) >= 32);
        if ~isempty(find_tmp)
            multi_num(2) = multi_num(2) + 1;
            index = find_tmp(1);
            if a_posGW_arr(i, index) == a_mulpos_arr(i, 2)
                pos_true(2) = pos_true(2) + 1;
            end
        end
    end
    if multi_ch(1, 3) == 1
        find_tmp = find(a_sinGW_true(i, 2:2:8) >= 32);
        if ~isempty(find_tmp)
            multi_num(3) = multi_num(3) + 1;
            index = find_tmp(1);
            if a_posGW_arr(i, index) == a_mulpos_arr(i, 3)
                pos_true(3) = pos_true(3) + 1;
            end
        end
    end
    if multi_ch(1, 4) == 1
        find_tmp = find(a_sinGW_true(i, 2:2:10) >= 32);
        if ~isempty(find_tmp)
            multi_num(4) = multi_num(4) + 1;
            index = find_tmp(1);
            if a_posGW_arr(i, index) == a_mulpos_arr(i, 4)
                pos_true(4) = pos_true(4) + 1;
            end
        end
    end
end
plot(pos_true./multi_num, 'r');
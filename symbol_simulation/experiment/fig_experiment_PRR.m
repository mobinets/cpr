multi_true = zeros(13, 4*2);
multi_num = zeros(13, 4);
times = 1000;
payload_num = 33 - 1;
for i = 1:length(a_SNR_arr)
    multi_ch = a_multrue_arr(3*(i-1)+1:3*i, :);
    SNR = a_SNR_arr(i);
    SNR_index = (SNR+45)/5 + 1;
    if multi_ch(1, 1) == 1  % 2网关
        if multi_ch(2, 1) >= payload_num
            multi_true(SNR_index, 1) = multi_true(SNR_index, 1) + 1;
        end
        if multi_ch(3, 1) >= payload_num
            multi_true(SNR_index, 2) = multi_true(SNR_index, 2) + 1;
        end
        multi_num(SNR_index, 1) = multi_num(SNR_index, 1) + 1;
    end
    if multi_ch(1, 2) == 1
        if multi_ch(2, 2) >= payload_num
            multi_true(SNR_index, 3) = multi_true(SNR_index, 3) + 1;
        end
        if multi_ch(3, 2) >= payload_num
            multi_true(SNR_index, 4) = multi_true(SNR_index, 4) + 1;
        end
        multi_num(SNR_index, 2) = multi_num(SNR_index, 2) + 1;
    end
    if multi_ch(1, 3) == 1
        if multi_ch(2, 3) >= payload_num
            multi_true(SNR_index, 5) = multi_true(SNR_index, 5) + 1;
        end
        if multi_ch(3, 3) >= payload_num
            multi_true(SNR_index, 6) = multi_true(SNR_index, 6) + 1;
        end
        multi_num(SNR_index, 3) = multi_num(SNR_index, 3) + 1;
    end
    if multi_ch(1, 4) == 1
        if multi_ch(2, 4) >= payload_num
            multi_true(SNR_index, 7) = multi_true(SNR_index, 7) + 1;
        end
        if multi_ch(3, 4) >= payload_num
            multi_true(SNR_index, 8) = multi_true(SNR_index, 8) + 1;
        end
        multi_num(SNR_index, 4) = multi_num(SNR_index, 4) + 1;
    end
end
GW_true_pkg2 = multi_true(:, 2:2:8)./multi_num;
result_array = GW_true_pkg2(:,[1,2,4]);
plot(-45:5:15, GW_true_pkg2(:, 1), 'k');  hold on;
plot(-45:5:15, GW_true_pkg2(:, 2), 'r');  hold on;
plot(-45:5:15, GW_true_pkg2(:, 4), 'p');  hold on;
legend('2GW','3GW','5GW');
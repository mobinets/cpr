multi_true = zeros(13, 4*2);
multi_num = zeros(13, 4);
Config_Path = '.\config\';                                       % 设置配置文件所在路径
Verification_path = strcat(Config_Path,'node1_sf10.txt');        % bin值验证文件
Pkg_Verification = load(Verification_path)';
sf = 10;
times = 1000;
for i = length(a_SNR_arr)-1*100:length(a_SNR_arr)
    multi_ch = a_multrue_arr(3*(i-1)+1:3*i, :);
    bin_record = a_mulbinrec_arr(8*(i-1)+1:8*i, :);
    SNR = a_SNR_arr(i);
    SNR_index = (SNR+45)/5 + 1;
    if multi_ch(1, 1) == 1  % 2网关
        pkg1_bin = bin_record(1, :);
        pkg2_bin = bin_record(2, :);
        pkg1_result = 0;
        pkg2_result = 0;
        for symbol_index = 1:length(Pkg_Verification)
            pkg1_bit = bitget(pkg1_bin(symbol_index), 1:sf);
            pkg2_bit = bitget(pkg2_bin(symbol_index), 1:sf);
            ver_bit = bitget(Pkg_Verification(symbol_index), 1:sf);
            pkg1_result = pkg1_result + sum(pkg1_bit == ver_bit);
            pkg2_result = pkg2_result + sum(pkg2_bit == ver_bit);
        end
        multi_true(SNR_index, 1) = multi_true(SNR_index, 1) + pkg1_result;
        multi_true(SNR_index, 2) = multi_true(SNR_index, 2) + pkg2_result;
        multi_num(SNR_index, 1) = multi_num(SNR_index, 1) + length(Pkg_Verification)*sf;
    end
    if multi_ch(1, 2) == 1
        pkg1_bin = bin_record(3, :);
        pkg2_bin = bin_record(4, :);
        pkg1_result = 0;
        pkg2_result = 0;
        for symbol_index = 1:length(Pkg_Verification)
            pkg1_bit = bitget(pkg1_bin(symbol_index), 1:sf);
            pkg2_bit = bitget(pkg2_bin(symbol_index), 1:sf);
            ver_bit = bitget(Pkg_Verification(symbol_index), 1:sf);
            pkg1_result = pkg1_result + sum(pkg1_bit == ver_bit);
            pkg2_result = pkg2_result + sum(pkg2_bit == ver_bit);
        end
        multi_true(SNR_index, 3) = multi_true(SNR_index, 3) + pkg1_result;
        multi_true(SNR_index, 4) = multi_true(SNR_index, 4) + pkg2_result;
        multi_num(SNR_index, 2) = multi_num(SNR_index, 2) + length(Pkg_Verification)*sf;
    end
    if multi_ch(1, 3) == 1
        pkg1_bin = bin_record(5, :);
        pkg2_bin = bin_record(6, :);
        pkg1_result = 0;
        pkg2_result = 0;
        for symbol_index = 1:length(Pkg_Verification)
            pkg1_bit = bitget(pkg1_bin(symbol_index), 1:sf);
            pkg2_bit = bitget(pkg2_bin(symbol_index), 1:sf);
            ver_bit = bitget(Pkg_Verification(symbol_index), 1:sf);
            pkg1_result = pkg1_result + sum(pkg1_bit == ver_bit);
            pkg2_result = pkg2_result + sum(pkg2_bit == ver_bit);
        end
        multi_true(SNR_index, 5) = multi_true(SNR_index, 5) + pkg1_result;
        multi_true(SNR_index, 6) = multi_true(SNR_index, 6) + pkg2_result;
        multi_num(SNR_index, 3) = multi_num(SNR_index, 3) + length(Pkg_Verification)*sf;
    end
    if multi_ch(1, 4) == 1
        pkg1_bin = bin_record(7, :);
        pkg2_bin = bin_record(8, :);
        pkg1_result = 0;
        pkg2_result = 0;
        for symbol_index = 1:length(Pkg_Verification)
            pkg1_bit = bitget(pkg1_bin(symbol_index), 1:sf);
            pkg2_bit = bitget(pkg2_bin(symbol_index), 1:sf);
            ver_bit = bitget(Pkg_Verification(symbol_index)-1, 1:sf);
            pkg1_result = pkg1_result + sum(pkg1_bit == ver_bit);
            pkg2_result = pkg2_result + sum(pkg2_bit == ver_bit);
        end
        multi_true(SNR_index, 7) = multi_true(SNR_index, 7) + pkg1_result;
        multi_true(SNR_index, 8) = multi_true(SNR_index, 8) + pkg2_result;
        multi_num(SNR_index, 4) = multi_num(SNR_index, 4) + length(Pkg_Verification)*sf;
    end
end
GW_true_pkg2 = multi_true(:, 2:2:8)./multi_num;
result_array = GW_true_pkg2(:,[1,2,4]);
plot(-45:5:15, GW_true_pkg2(:, 1), 'k');  hold on;
plot(-45:5:15, GW_true_pkg2(:, 2), 'r');  hold on;
plot(-45:5:15, GW_true_pkg2(:, 4), 'p');  hold on;
legend('2GW','3GW','5GW');
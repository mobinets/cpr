multi_true = zeros(13, 4*2);
multi_num = zeros(13, 4);
times = 1000;
Config_Path = '.\config\';                                       % 设置配置文件所在路径
Verification_path = strcat(Config_Path,'node1_sf10.txt');        % bin值验证文件
Pkg_Verification = load(Verification_path)';
sf = 10;
for i = 1:length(a_SNR_arr)
% for i = 12*1000+1:length(a_SNR_arr)
    multi_ch = a_multrue_arr(3*(i-1)+1:3*i, :);
    bin_record = a_mulbinrec_arr(8*(i-1)+1:8*i, :);
    SNR = a_SNR_arr(i);
    SNR_index = (SNR+45)/5 + 1;
    for multi_count = 1:4  % 遍历 2-5网关
        if multi_ch(1, multi_count) == 1  % 判断网关情况是否存在
            pkg1_bin = bin_record(multi_count*2-1, :);
            pkg2_bin = bin_record(multi_count*2, :);
            pkg1_result = 0;
            pkg2_result = 0;
            for symbol_index = 1:length(Pkg_Verification)
                pkg1_bit = bitget(pkg1_bin(symbol_index), 1:sf);
                pkg2_bit = bitget(pkg2_bin(symbol_index), 1:sf);
                ver_bit = bitget(Pkg_Verification(symbol_index), 1:sf);
                pkg1_result = pkg1_result + sum(pkg1_bit == ver_bit);
                pkg2_result = pkg2_result + sum(pkg2_bit == ver_bit);
            end
%             pkg1_result = pkg1_result;
%             pkg2_result = pkg2_result;
            multi_true(SNR_index, multi_count*2-1) = multi_true(SNR_index, multi_count*2-1) + pkg1_result;
            multi_true(SNR_index, multi_count*2) = multi_true(SNR_index, multi_count*2) + pkg2_result;
            multi_num(SNR_index, multi_count) = multi_num(SNR_index, multi_count) + length(Pkg_Verification)*sf;
        end
    end
end
GW_true_pkg2 = multi_true(:, 2:2:8)./multi_num;
GW_true_pkg2 = 1 - GW_true_pkg2;
result_array = GW_true_pkg2(:,[1,2,4]);
plot(-45:5:15, GW_true_pkg2(:, 1), 'k');  hold on;
plot(-45:5:15, GW_true_pkg2(:, 2), 'r');  hold on;
plot(-45:5:15, GW_true_pkg2(:, 4), 'p');  hold on;
legend('2GW','3GW','5GW');
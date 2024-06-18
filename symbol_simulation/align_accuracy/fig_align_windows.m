diff_con = zeros(1,20);
SNR_num = zeros(1,20);
GW_num = 7;
for i = 1:size(a_sf10_sir5_prtrue_result, 1)
    SNR = a_sf10_sir5_prtrue_result(i, 1);
    SNR_num(round((60 + SNR)/5)) = SNR_num(round((60 + SNR)/5)) + 1;
    diff_con(round((60 + SNR)/5)) = diff_con(round((60 + SNR)/5)) + (a_sf10_sir5_prtrue_result(i, end) - max(a_sf10_sir5_prtrue_result(i, 2:end-1))/max(a_sf10_sir5_prtrue_result(i, 2:end-1)));
end
x = -55 : 5 : -60 + 5*20;
plot(x, diff_con./SNR_num,'b');
ylabel('peak-rate-diff');
xlabel('SNR');
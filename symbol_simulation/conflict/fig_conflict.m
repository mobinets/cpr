single_con = zeros(1,20);
Nscale_con = zeros(1,20);
SNR_num = zeros(1,20);
for i = 1:size(conflict_result_array, 2)
    SNR = conflict_result_array(1, i);
    SNR_num(round((60 + SNR)/5)) = SNR_num(round((60 + SNR)/5)) + 1;
    if conflict_result_array(2, i) == 1
        single_con(round((60 + SNR)/5)) = single_con(round((60 + SNR)/5)) + 1;
    end
    if conflict_result_array(4, i) == 1
        Nscale_con(round((60 + SNR)/5)) = Nscale_con(round((60 + SNR)/5)) + 1;
    end
end
x = -55 : 5 : -60 + 5*20;
plot(x, single_con./SNR_num,'b'); hold on;
plot(x, Nscale_con./SNR_num,'r'); hold on;
legend('Single','Nscale');
ylabel('conflict');
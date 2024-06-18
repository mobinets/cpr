sf_array = ["sf7", "sf8", "sf9", "sf10"];
sir_array = ["sir_5", "sir0", "sir5"];
plot_array = zeros(20, 6*4*3);
for SIR_count = 1:length(sir_array)
    figure(SIR_count);
    for SF_count = 1:length(sf_array)
        conflict_result_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_prtrue_result'));
        tmp_array = eval(conflict_result_name);
        diff_con = zeros(6,20);
        SNR_num = zeros(6,20);
        for i = 1:size(tmp_array, 1)
            SNR = tmp_array(i, 1);
            SNR_num(:, round((60 + SNR)/5)) = SNR_num(:, round((60 + SNR)/5)) + 1;
            diff_con(1, round((60 + SNR)/5)) = diff_con(1, round((60 + SNR)/5)) + ( (tmp_array(i, 9) - max(tmp_array(i, 2:3))) /max(tmp_array(i, 2:3)));
            diff_con(2, round((60 + SNR)/5)) = diff_con(2, round((60 + SNR)/5)) + ((tmp_array(i, 10) - max(tmp_array(i, 2:4)))/max(tmp_array(i, 2:4)));
            diff_con(3, round((60 + SNR)/5)) = diff_con(3, round((60 + SNR)/5)) + ((tmp_array(i, 11) - max(tmp_array(i, 2:5)))/max(tmp_array(i, 2:5)));
            diff_con(4, round((60 + SNR)/5)) = diff_con(4, round((60 + SNR)/5)) + ((tmp_array(i, 12) - max(tmp_array(i, 2:6)))/max(tmp_array(i, 2:6)));
            diff_con(5, round((60 + SNR)/5)) = diff_con(5, round((60 + SNR)/5)) + ((tmp_array(i, 13) - max(tmp_array(i, 2:7)))/max(tmp_array(i, 2:7)));
            diff_con(6, round((60 + SNR)/5)) = diff_con(6, round((60 + SNR)/5)) + ((tmp_array(i, 14) - max(tmp_array(i, 2:8)))/max(tmp_array(i, 2:8)));
        end
        x = -55 : 5 : -60 + 5*20;
        subplot(2,2,SF_count);
        result = diff_con./SNR_num;
        plot(x, result(1, :), 'b'); hold on;
        plot(x, result(2, :), 'g'); hold on;
        plot(x, result(3, :), 'p'); hold on;
        plot(x, result(4, :), 'r'); hold on;
        plot(x, result(5, :), '.-'); hold on;
        plot(x, result(6, :), '.'); hold on;
        legend('GW2', 'GW3', 'GW4', 'GW5', 'GW6', 'GW7');
        tmp = result.';
        plot_array(:,(SIR_count-1)*24+(SF_count-1)*6+1:(SIR_count-1)*24+(SF_count-1)*6+6) = tmp;
%         xxx = 1;
    end
end
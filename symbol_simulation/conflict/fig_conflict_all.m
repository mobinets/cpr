sf_array = ["sf8", "sf9", "sf10"];
sir_array = ["sir_5", "sir0", "sir5"];
% sf_array = ["sf10"];
% sir_array = ["sir5"];
plot_array = zeros(20,2*9);
for SIR_count = 1:length(sir_array)
    figure(SIR_count);
    for SF_count = 1:length(sf_array)
        conflict_result_name = cell2mat(strcat('a_', sf_array(SF_count), '_', sir_array(SIR_count), '_conflict_result'));
        tmp_array = eval(conflict_result_name);
        SNR_num = zeros(1, 20);
        single_con = zeros(1, 20);
        Nscale_con = zeros(1, 20);
        for i = 1:size(tmp_array, 2)
            SNR = tmp_array(1, i);
            SNR_num(round((60 + SNR)/5)) = SNR_num(round((60 + SNR)/5)) + 1;
            if tmp_array(2, i) == 1
                single_con(round((60 + SNR)/5)) = single_con(round((60 + SNR)/5)) + 1;
            end
            if tmp_array(4, i) == 1
                Nscale_con(round((60 + SNR)/5)) = Nscale_con(round((60 + SNR)/5)) + 1;
            end
        end
        x = -55 : 5 : -60 + 5*20;
        subplot(2,2,SF_count);
        plot(x, single_con./SNR_num, 'b'); hold on;
        plot(x, Nscale_con./SNR_num, 'r'); hold on;
%         tmp = [Nscale_con./SNR_num; single_con./SNR_num].';
%         plot_array(:,(SIR_count-1)*6+(SF_count-1)*2+1:(SIR_count-1)*6+(SF_count-1)*2+2) = tmp;
%         xxx = 1;
    end
end

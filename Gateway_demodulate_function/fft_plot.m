function [] = fft_plot(samples_fft_merge, lora_set, fft_windows)
    fft_x = lora_set.fft_x;

    count_a = 1;
    count_b = 0;
    for samples_list = 1 : fft_windows
        count_b = count_b + 1;
        if(count_b > 9)
            count_a = count_a + 1;
            count_b = 1;
        end
        figure(count_a);
%         set(gcf,'Position',get(0,'ScreenSize'));
        subplot(3,3,count_b);
        plot(1:fft_x, samples_fft_merge(samples_list,:),'');
    end

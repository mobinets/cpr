function [] = time_plot(G0, lora_set, d_downchirp, fft_windows)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;

    samples = reshape(G0(1:fft_windows*dine),[dine, fft_windows]).';
    samples_dechirp = samples .* d_downchirp;
    samples_fft = abs(fft(samples_dechirp,dine,2));
    samples_fft_merge = [samples_fft(:,1:fft_x/2) + samples_fft(:,dine-fft_x+1:dine-fft_x/2), samples_fft(:,dine-fft_x/2+1:dine) + samples_fft(:,fft_x/2+1:fft_x)];
    [~, max_pos] = max(samples_fft_merge, [], 2);

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

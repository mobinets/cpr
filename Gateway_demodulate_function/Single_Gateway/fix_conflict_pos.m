function [conflict_pos_tmp, conflict_pos_cal] = fix_conflict_pos(G0, lora_set, d_downchirp, conflict_pos, pkg2_pre_bin, Preamble_start_pos, windows_offset)
    fft_x = lora_set.fft_x;
    dine = lora_set.dine;
    % SFD = [d_downchirp, d_downchirp, d_downchirp(1:dine*0.25)];
    % cor first downchirp
    samples = G0(conflict_pos*dine+7*dine+1 : conflict_pos*dine + 12*dine);
    cor = xcorr(samples, d_downchirp, 5*dine);
    cor_1 = abs(cor(5*dine+1 : 10*dine));
    % cor second downchirp
    samples = G0(conflict_pos*dine+8*dine+1 : conflict_pos*dine + 13*dine);
    cor = xcorr(samples, d_downchirp, 5*dine);
    cor_2 = abs(cor(5*dine+1 : 10*dine));
    % cor 0.25 SFD
    samples = G0(conflict_pos*dine+9*dine+1 : conflict_pos*dine + 14*dine);
    cor = xcorr(samples, d_downchirp, 5*dine);
    cor_3 = abs(cor(5*dine+1 : 10*dine));
    % cor = xcorr(samples, SFD, 5*dine);
    % cor = abs(cor(5*dine+1 : 10*dine));
    cor = cor_1./rms(cor_1) + cor_2./rms(cor_2) + 0.25*cor_3./rms(cor_3);
%     plot(cor);
%     figure(2);
%     plot(cor_1./max(cor_1) ,'r'); hold on; 
%     figure(3);
%     plot(cor_2./max(cor_2) ,'b'); hold on; 
%     figure(4);
%     plot(cor_3./max(cor_3),'g'); hold on;  
    if conflict_pos <= 4
        cor(1:dine*(5 - conflict_pos)) = 0;
    end
    [~, max_pos] = max(cor);
    decimal = max_pos/dine - fix(max_pos/dine);
    if decimal < 0.05 || decimal > 0.95
        if decimal < 0.05 && pkg2_pre_bin < fft_x * 0.05
            max_pos = max_pos - dine*0.05;
        elseif decimal > 0.95 && pkg2_pre_bin > fft_x * 0.95
            max_pos = max_pos + dine*0.05;
        end
    end
    conflict_pos_tmp = conflict_pos + fix(max_pos/dine) + 8 - 10;
    if Preamble_start_pos >= 1
        conflict_pos_cal = conflict_pos + floor((max_pos-(Preamble_start_pos-1)*dine-windows_offset)/dine) - 2;
    else
        conflict_pos_cal = conflict_pos + floor((max_pos-windows_offset)/dine) - 2;
    end
function [conflict_pos_tmp, conflict_pos_cal] = fix_conflict_pos_slow(G0, lora_set, d_downchirp, conflict_pos, pkg2_pre_bin, Preamble_start_pos, windows_offset)
    fft_x = lora_set.fft_x;
    dine = lora_set.dine;
    % cor SFD
    cor = zeros(1, dine*7);
    for i = 1:7*dine
        windows = G0(conflict_pos*dine+7*dine+i : conflict_pos*dine+8*dine+i-1);
        cor(i) = abs(xcorr(windows, d_downchirp, 0, 'normalized'));
    end
    cor = cor(1:5*dine) + cor(dine+1:6*dine) + cor(dine*2+1:7*dine);

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
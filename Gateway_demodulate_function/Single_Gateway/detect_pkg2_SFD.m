function [SFD_pos] = detect_pkg2_SFD(G0, lora_set, upchirp, conflict_pos, Pkg2_winmobi)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Preamble_length = lora_set.Preamble_length;
    SFD_pos = conflict_pos + 10;

    idealchirp = [upchirp, upchirp, upchirp(1:dine*0.25)];
    max_amp = zeros(1,4);
    for i = 1:4
        samples = G0((conflict_pos+6+i)*dine+Pkg2_winmobi+1 : (conflict_pos+8+i+0.25)*dine+Pkg2_winmobi);
        samples_dechirp = samples .* idealchirp;
        samples_fft = abs(fft(samples_dechirp, dine*2.25));
        samples_fft_merge = samples_fft(1:fft_x*2.25) + samples_fft(dine*2.25-fft_x*2.25+1:dine*2.25);
        max_amp(i) = max(samples_fft_merge);
    end
    [~, max_pos] = max(max_amp);
    SFD_pos = conflict_pos+6+max_pos;
function [Pkg2_winmobi] = algin_pkg2(G0, lora_set, d_downchirp_cfo, conflict_pos, pkg2_pre_bin)
    zeropadding_size = 8;
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;

    Pkg2_samples_align = G0(conflict_pos*dine+1:(conflict_pos+1)*dine);
    Pkg2_samples_align_fft = abs(fft(Pkg2_samples_align .* d_downchirp_cfo, dine*zeropadding_size, 2));
    Pkg2_samples_align_fft_merge = [Pkg2_samples_align_fft(1:dine/2) + Pkg2_samples_align_fft(dine*(zeropadding_size-1)+1:dine*(zeropadding_size-0.5)), ...
        Pkg2_samples_align_fft(dine*(zeropadding_size-0.5)+1:dine*zeropadding_size) + Pkg2_samples_align_fft(dine/2+1:dine)];
    [~,Pkg2_bin_ac] = max(Pkg2_samples_align_fft_merge(max(1,pkg2_pre_bin*zeropadding_size-16):min(dine,pkg2_pre_bin*zeropadding_size)));
    Pkg2_winmobi = dine - (pkg2_pre_bin*zeropadding_size-16+Pkg2_bin_ac-2);
function [Pkg1_ture, Pkg2_ture, conflict_pos] = Nscale_slow(G0, lora_set, Verification_path)
    leakage_width_array = [0.01,0.005,0.03,0.005];
    lora_set.filter_num = 2;
    lora_set.leakage_width1 = leakage_width_array(lora_set.sf-6);
    lora_set.leakage_width2 = 1-lora_set.leakage_width1;
    
    Pkg1_ture = 0;
    Pkg2_ture = 0;
    % cor pkg1
    [algin_windows, detect_flag, pkg1_cor] = correlate_slow(G0, lora_set);
    
    % cor pkg2
    [pkg2_algin_windows, conflict_flag] = nscale_correlate_pkg2_slow(G0, lora_set, pkg1_cor, algin_windows);
    conflict_pos = ceil(pkg2_algin_windows/lora_set.dine);
    % align pkg1 windows roughly
    if detect_flag == 1
        G_pkg1 = circshift(G0,-round(algin_windows));
    else
        return;
    end

    % get pkg1 winoff and cfo
    [cfo, windows_offset] = nscale_get_cfo_winoff(G_pkg1, lora_set);
    % align pkg1 windows accurately
    G_pkg1 = circshift(G_pkg1,-round(windows_offset));
    if windows_offset > lora_set.dine * 0.5
        lora_set.Preamble_length = 7;
    end

    [scale_factor_mean, scale_factor_var] = get_scale_factor(G_pkg1, lora_set, cfo);
    [pkg_bin] = nscale_get_bin_pkg1(G_pkg1, lora_set, cfo, scale_factor_mean, algin_windows, pkg2_algin_windows);
    [Pkg1_ture] = nscale_accuracy(lora_set, pkg_bin, Verification_path);

    % decode pkg2
    if conflict_flag == 1
        G_pkg2 = circshift(G0,-round(pkg2_algin_windows));
    else
        return;
    end
    % get pkg1 winoff and cfo
    lora_set.Preamble_length = 8;
    [cfo, windows_offset] = nscale_get_cfo_winoff(G_pkg2, lora_set);
    % align pkg2 windows accurately
    G_pkg2 = circshift(G_pkg2,-round(windows_offset));

    if windows_offset > lora_set.dine * 0.5
        lora_set.Preamble_length = 7;
    end

    [scale_factor_mean, scale_factor_var] = get_scale_factor(G_pkg2, lora_set, cfo);
    [pkg_bin] = nscale_get_bin(G_pkg2, lora_set, cfo, scale_factor_mean);
    [Pkg2_ture] = nscale_accuracy(lora_set, pkg_bin, Verification_path);
function [Peak_rate_full, conflict_arg, Pkg2_Peak] = get_peak_rate(G0, lora_set, d_downchirp_cfo, conflict_pos, pkg2_pre_bin)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    
    Pkg_samples = [reshape(G0(dine+1:2*dine),[dine,1]).'; reshape(G0(conflict_pos*dine+1:(conflict_pos+1)*dine),[dine,1]).'];
    Pkg_dechirp = Pkg_samples .* d_downchirp_cfo;
    Pkg_fft = abs(fft(Pkg_dechirp,dine,2));
    Pkg_fft_merge = [Pkg_fft(:,1:fft_x/2)+Pkg_fft(:,dine-fft_x+1:dine-fft_x/2), Pkg_fft(:,dine-fft_x/2+1:dine)+Pkg_fft(:,fft_x/2+1:fft_x)];
    Pkg1_Peak = max([Pkg_fft_merge(1,1:fix(fft_x*0.05)), Pkg_fft_merge(1,fix(fft_x*0.95):fft_x)]);
    Pkg2_Peak = max(Pkg_fft_merge(2,max(1,pkg2_pre_bin-2): min(pkg2_pre_bin+2,fft_x)));
    Peak_rate_full = Pkg1_Peak / Pkg2_Peak;                 % 窗口全覆盖下，包1和包2的峰值比
    conflict_arg(7) = Pkg2_Peak/mean(Pkg_fft_merge(2,:));
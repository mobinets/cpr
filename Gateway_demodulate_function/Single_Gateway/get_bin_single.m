function [Pkg1_bin] = get_bin_single(G0, lora_set, d_downchirp_cfo, d_upchirp_cfo)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Pkg_length = lora_set.Pkg_length;
    Preamble_length = lora_set.Preamble_length;

    Pkg1_samples_pre = reshape(G0(1:(Preamble_length+4)*dine),[dine,Preamble_length+4]).';
    Pkg1_samples_pay = reshape(G0((Preamble_length+4)*dine+dine*0.25+1:(Pkg_length+Preamble_length+4)*dine+dine*0.25),[dine,Pkg_length]).';
    Pkg1_samples = [Pkg1_samples_pre; Pkg1_samples_pay];
    dechirp = [repmat(d_downchirp_cfo,Preamble_length+2,1); repmat(d_upchirp_cfo,2,1); repmat(d_downchirp_cfo,Pkg_length,1)];
    Pkg1_samples_dechirp = Pkg1_samples .* dechirp;
    Pkg1_samples_fft = abs(fft(Pkg1_samples_dechirp,dine,2));
    Pkg1_samples_fft_merge = [Pkg1_samples_fft(:,1:fft_x/2) + Pkg1_samples_fft(:,dine-fft_x+1:dine-fft_x/2), Pkg1_samples_fft(:,dine-fft_x/2+1:dine)+Pkg1_samples_fft(:,fft_x/2+1:fft_x)];
    [~,Pkg1_bin] = max(Pkg1_samples_fft_merge,[],2);
    Pkg1_bin = Pkg1_bin(1:end);
    Pkg1_pre_bin_tmp = mode(Pkg1_bin(1:8));
    Pkg1_pre_bin_num = length(find( Pkg1_bin(1:8)==Pkg1_pre_bin_tmp ));
    if Pkg1_pre_bin_num >= 4
        Pkg1_bin = mod(Pkg1_bin+fft_x+1-Pkg1_pre_bin_tmp,fft_x);
        spe_tmp = find( Pkg1_bin == 0);
        Pkg1_bin(spe_tmp) = fft_x;
    end
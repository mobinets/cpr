function [Pkg1_samples_fft_merge, Pkg2_samples_fft_merge] = get_fft(G0, lora_set, d_downchirp_cfo, d_upchirp_cfo, conflict_pos, Pkg2_winmobi)
    dine = lora_set.dine;
    fft_x = lora_set.fft_x;
    Pkg_length = lora_set.Pkg_length;
    Preamble_length = lora_set.Preamble_length;

    % 对齐包1，获得包1的bin
    Pkg1_samples_pre = reshape(G0(1:(Preamble_length+4)*dine),[dine,Preamble_length+4]).';
    Pkg1_samples_pay = reshape(G0((Preamble_length+4)*dine+dine*0.25+1:(Pkg_length+Preamble_length+4)*dine+dine*0.25),[dine,Pkg_length]).';
    Pkg1_samples = [Pkg1_samples_pre; Pkg1_samples_pay];
    dechirp = [repmat(d_downchirp_cfo,Preamble_length+2,1);repmat(d_upchirp_cfo,2,1);repmat(d_downchirp_cfo, Pkg_length, 1)];
    Pkg1_samples_dechirp = Pkg1_samples .* dechirp;
    Pkg1_samples_fft = abs(fft(Pkg1_samples_dechirp,dine,2));
    Pkg1_samples_fft_merge = [Pkg1_samples_fft(:,1:fft_x/2) + Pkg1_samples_fft(:,dine-fft_x+1:dine-fft_x/2), Pkg1_samples_fft(:,dine-fft_x/2+1:dine)+Pkg1_samples_fft(:,fft_x/2+1:fft_x)];

    Pkg2_samples_pre = reshape(G0((conflict_pos-1)*dine+Pkg2_winmobi+1:(conflict_pos+Preamble_length+3)*dine+Pkg2_winmobi),[dine,Preamble_length+4]).';
    Pkg2_samples_pay = reshape(G0((conflict_pos+Preamble_length+3)*dine+dine*0.25+Pkg2_winmobi+1:(conflict_pos+Pkg_length+Preamble_length+3)*dine+dine*0.25+Pkg2_winmobi),[dine,Pkg_length]).';
    Pkg2_samples = [Pkg2_samples_pre; Pkg2_samples_pay];
    dechirp = [repmat(d_downchirp_cfo,Preamble_length+2,1);repmat(d_upchirp_cfo,2,1);repmat(d_downchirp_cfo,Pkg_length,1)];
    Pkg2_samples_dechirp = Pkg2_samples .* dechirp;
    Pkg2_samples_fft = abs(fft(Pkg2_samples_dechirp,dine,2));
    Pkg2_samples_fft_merge = [Pkg2_samples_fft(:,1:fft_x/2) + Pkg2_samples_fft(:,dine-fft_x+1:dine-fft_x/2), Pkg2_samples_fft(:,dine-fft_x/2+1:dine)+Pkg2_samples_fft(:,fft_x/2+1:fft_x)];

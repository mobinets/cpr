function [Pkg1_ture, Pkg2_ture, Pkg1_bin_rec, Pkg2_bin_rec] = get_accuracy(lora_set, Pkg1_bin, Pkg2_bin, Verification_path)
    Preamble_length = lora_set.Preamble_length;
    
    Pkg1_Verification = load(Verification_path)';
    Pkg1_bin = Pkg1_bin';
    Pkg1_ture_array = Pkg1_bin(Preamble_length+5:length(Pkg1_Verification)+Preamble_length+4) == Pkg1_Verification;
    Pkg1_bin_rec = Pkg1_bin(Preamble_length+5:length(Pkg1_Verification)+Preamble_length+4);
    Pkg1_ture = sum(Pkg1_ture_array==1);
    Pkg2_bin = Pkg2_bin';
    if length(Pkg2_bin) < length(Pkg1_Verification)+Preamble_length+4
        Pkg2_bin = [Pkg2_bin, zeros(1,length(Pkg1_Verification)+Preamble_length+4 - length(Pkg2_bin))];
    end
    Pkg2_ture_array = Pkg2_bin(Preamble_length+5:length(Pkg1_Verification)+Preamble_length+4) == Pkg1_Verification;
    Pkg2_bin_rec = Pkg2_bin(Preamble_length+5:length(Pkg1_Verification)+Preamble_length+4);
    Pkg2_ture = sum(Pkg2_ture_array==1);
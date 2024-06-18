function [Pkg1_ture, Pkg1_bin_rec] = get_accuracy_single(lora_set, Pkg1_bin, Verification_path)
    Preamble_length = lora_set.Preamble_length;
    Pkg1_Verification = load(Verification_path)';
    x = Pkg1_bin(Preamble_length+5:size(Pkg1_Verification,2))';
    Pkg1_ture_array = Pkg1_bin(Preamble_length+5:Preamble_length+4 + size(Pkg1_Verification,2))' == Pkg1_Verification;
    Pkg1_bin_rec = Pkg1_bin(Preamble_length+5:Preamble_length+4 + size(Pkg1_Verification,2))';
    Pkg1_ture = sum(Pkg1_ture_array==1);
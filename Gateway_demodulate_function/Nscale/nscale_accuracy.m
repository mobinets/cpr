function [Pkg1_ture] = nscale_accuracy(lora_set, Pkg1_bin, Verification_path)
    Preamble_length = lora_set.Preamble_length;
    Pkg1_Verification = load(Verification_path)';
    Pkg1_ture_array = Pkg1_bin(1 : size(Pkg1_Verification,2)) == Pkg1_Verification;
    Pkg1_ture = sum(Pkg1_ture_array==1);
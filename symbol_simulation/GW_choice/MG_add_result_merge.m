MG_add_tmp_1 = who('-file','MG_choice_xiong600t_sfall.mat');
MG_add_tmp_2 = who('-file','MG_choice_zkw400t_sfall.mat');
data_1 = matfile('MG_choice_xiong600t_sfall.mat');
data_2 = matfile('MG_choice_zkw400t_sfall.mat');
for i = 1:length(MG_add_tmp_1)
    name_1 = MG_add_tmp_1{i}; %读取第i个变量名
    name_2 = MG_add_tmp_2{i};
    var_1 = data_1.(name_1);  %读取对应的变量
    var_2 = data_2.(name_2);
    eval([name_1, ' = [var_1; var_2];']);
end
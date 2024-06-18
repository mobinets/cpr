MG_add_tmp_1 = who('-file','align_accuracy_714.mat');
MG_add_tmp_2 = who('-file','align_accuracy_7142.mat');
data_1 = matfile('align_accuracy_714.mat');
data_2 = matfile('align_accuracy_7142.mat');
for i = 1:length(MG_add_tmp_1)
    name_1 = MG_add_tmp_1{i}; %读取第i个变量名
    name_2 = MG_add_tmp_2{i};
    var_1 = data_1.(name_1);  %读取对应的变量
    var_2 = data_2.(name_2);
    eval([name_1, ' = [var_1; var_2];']);
end
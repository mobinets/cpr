function [G0_array, G1_array] = select_samples(lora_set, Samples_dir)
    sf = lora_set.sf;
    dir_array = ['FFT_rtl1\';'FFT_rtl2\';'FFT_rtl3\';'FFT_rtl4\';'FFT_rtl5\';'FFT_rtl6\';'FFT_rtl7\'];
    node_path = ['\node1\';'\node2\'];
    G0_array = zeros(0);
    G1_array = zeros(0);
    
    for rtl_count = 1:7
        full_path = strcat(Samples_dir, dir_array(rtl_count, :));
        full_path = strcat(full_path, 'SF');
        full_path = strcat(full_path, string(sf));
        full_path_1 = strcat(full_path, node_path(1, :));
        full_path_2 = strcat(full_path, node_path(2, :));
        File_1 = dir(fullfile(full_path_1, '*.sigmf-data'));
        File_2 = dir(fullfile(full_path_2, '*.sigmf-data'));
    
        if rtl_count == 1
            node_select_1 = ceil(rand*length(File_1));
            node_select_2 = ceil(rand*length(File_2));
        end
        File_Path_1 = strcat(full_path_1, File_1(node_select_1).name);
        File_Path_2 = strcat(full_path_2, File_2(node_select_2).name);
        fid_1=fopen(File_Path_1,'rb');
        fid_2=fopen(File_Path_2,'rb');
        [A_1]=fread(fid_1,'float32')';
        [A_2]=fread(fid_2,'float32')';
        A_1_length = size(A_1,2);
        A_2_length = size(A_2,2);
        G0 = A_1(1:2:A_1_length-1) + A_1(2:2:A_1_length)*1i;            % 将float数组转换成复数数组
        G1 = A_2(1:2:A_2_length-1) + A_2(2:2:A_2_length)*1i;
        G0_array = [G0_array; G0];
        G1_array = [G1_array; G1];
    end
    fclose all;
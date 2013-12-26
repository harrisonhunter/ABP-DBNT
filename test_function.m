function [same] = test_function(file_1)
    file_2 = 'test_compare';
    same = 1;
    fid = fopen(file_1);
    fid_2 = fopen(file_2);
    tline = fgets(fid);
    tline_2 = fgets(fid_2);
    while ischar(tline)
        try 
            if tline ~= tline_2
               fprintf('failing');
               same = 0;
               break
            end
        catch 
            same = 0;
        end
        tline = fgets(fid);
        tline_2 = fgets(fid_2);
    end
    fclose(fid);
    fclose(fid_2);
end
    


function compress( file )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    fileName = strcat('compression','_',num2str(file(length(file)-5:length(file)-4)),'.txt');
    ftemp = fopen(fileName,'w' );
    fid = fopen(file);
    tline = fgets(fid);
    while ischar(tline)
        count = 0;
        tline = strread(tline,'%s','delimiter',' ');
        patientID = tline{1};
        len = length(tline);
        s1 = '';
        for i = 3:len-1
            if mod(i-2,7) == 1 %&& num2str(tline{i}) ~= ''
%                 tline{i}
                count = count + 1;
                s1 = strcat(s1,num2str(tline{i}));
            end
        end
        %tline{i}
        [codice, code_bin, code_book] = lempel_ziv(['0':'9'],s1);
%         length(lemp)
        if count ~= 0
            fprintf(ftemp, '%s %d %d %d %d', patientID, length(code_book), length(codice), count, (length(code_book)*1.0)/count);
        end
        fprintf(ftemp, '\n');
        tline = fgets(fid);
    end
    fclose(fid);
    fclose(ftemp);
end


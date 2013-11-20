function persistence(file, lead)
    fileName = strcat('persistence','_',num2str(file(length(file)-5:length(file)-4)),'.txt');
    ftemp = fopen(fileName,'w' );
    for k=1:length(lead)
        fid = fopen(file);
        tline = fgets(fid);
        while ischar(tline)
            sum = 0;
            counter = 0;
            numWrong = 0;
            C = strsplit(tline);
            patientID = C{1};
            for i=3:(length(C)-7*lead(k)-1)
               if mod(i-2,7) == 1
                   counter = counter + 1;
                   if str2double(C{i}) ~= str2double(C{i+7*lead(k)})
                      numWrong = numWrong + 1;
                      sum = sum + abs(str2num(C{i}) - str2num(C{i+7*lead(k)}));
                   end
               end
            end
            fprintf(ftemp, '%s %d %d %d %d', patientID, lead(k), sum, numWrong, counter);
            fprintf(ftemp, '\n');
            tline = fgets(fid);
        end
        fclose(fid);
    end
    fclose(ftemp);
end
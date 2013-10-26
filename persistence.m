function persistence(file, lead)
    fileName = strcat('persistence','_',num2str(file(length(file)-5:length(file)-4)),'.txt');
    ftemp = fopen(fileName,'w' );
    for k=1:length(lead)
        fid = fopen(file);
        tline = fgets(fid);
        lead(k)
        patientID = '1';
        counter = 0;
        sum = 0;
        numWrong = 0;
        while ischar(tline)
            C = strsplit(tline);
            if str2double(C{1}) ~= str2double(patientID) && counter ~= 0
                fprintf(ftemp, '%s %d %d %d %d', patientID, lead(k), sum, numWrong, counter);
                fprintf(ftemp, '\n');
                counter = 0;
                sum = 0;
                numWrong = 0;
            end 
            patientID = C{1};
            D = C(10:7:length(C));
            for i=1:length(D)-lead(k)
               counter = counter + 1;
               if str2double(D{i}) ~= str2double(D{i+lead(k)})
                  numWrong = numWrong + 1;
                  sum = sum + abs(str2double(D{i}) - str2double(D{i+lead(k)}));
               end
            end
            tline = fgets(fid);
        end
        fclose(fid);
    end
    fclose(ftemp);
end
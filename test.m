function persistence(file, n, patients)
    %'data_10_12_20_20.txt'
    fid = fopen(file);
    tline = fgets(fid);
    patientID = '1';
    counter = 0;
    sum = 0;
    numWrong = 0;
    while ischar(tline)
        C = strsplit(tline);
        counter = counter + 1;
        if str2double(C{1}) ~= str2double(patientID)
            if isKey(patients, patientID)
                patients(patientID) = [patients(patientID), [sum, numWrong counter, n]];
            else 
                patients(patientID) = [sum, numWrong counter, n];
            end
            patientID = C{1};
            counter = 1;
            sum = 0;
            numWrong = 0;
        end 
        D = C(10:7:length(C));
        for i=1:length(D)-n
           if str2double(D{i}) ~= str2double(D{i+n})
               numWrong = numWrong + 1;
              sum = sum + abs(str2double(D{i}) - str2double(D{i+n}));
           end
        end
        tline = fgets(fid);
    end
    patients.remove('1');
    fclose(fid);
    patients
end
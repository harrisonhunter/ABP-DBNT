function [patientData] = new_mim(patientPointer, dataPath, patientNames)
    %three cases, patient data could be a cell of data
    %the entry path path/patientName{i} could refer to a folder
    %the entry path path/patientName{i} could refer to a .mat file
    patientData = [];
%     patients = patientNames;
    try
%         if patientPointer > length(patients)
%             patientData = [];
%         elseif isa(patients{patientPointer},'double')
%             patientData = patients{patientPointer};
%         elseif ischar(patients{patientPointer}) && ...
%                 exist([dataPath,'/', patientNames{patientPointer}]) == 2
%             patientData = load([dataPath,'/',patientNames{patientPointer}]);
%             patientData = patientData.patientData;
        if ischar(patientNames{patientPointer}) && ...
                exist([dataPath,'/',patientNames{patientPointer}]) == 7;
%             disp(patientNames{patientPointer})
            meanValues = load([dataPath,'/',patientNames{patientPointer},'/mean.txt']);
            validationValues = load([dataPath,'/',patientNames{patientPointer},'/validation.txt']);
%             if(size(validationValues,2) ==3)
%                 validationValues = validationValues(:,3);
%             end
            durationValues = load([dataPath,'/',patientNames{patientPointer},'/duration.txt']);
            patientData = [meanValues,durationValues,validationValues];
        else
            error(['cannot read ', patientNames{patientPointer}]);
        end
    catch
    end

end
        















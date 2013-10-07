classdef MIMIC_data_loader < handle
    properties(SetAccess = private)
        patientPointer;
        patients;
        dataPath;
    end
    
    properties(SetAccess = public)
        patientNames;
        meanColumn;
        beatDurationColumn;
        validityColumn;
        featureNames;
        beatFeaturesColumns;
    end
        
    
    methods
        
        function obj = MIMIC_data_loader(dataPath)
            obj.dataPath = dataPath;
            obj.patientPointer = 1;
            
            %the following parameters have been hardcoded. Once we gather
            %more features a better method should be used
            obj.featureNames = {'Mean','Duration','Validity'};
            obj.meanColumn = 1;
            obj.beatDurationColumn = 2;
            obj.validityColumn = 3;
            obj.beatFeaturesColumns = 1;
            %---------------------------------------------
            %pause(1);
            if (exist(dataPath) == 7)
                patientDirectories = dir(dataPath);
                patientDirectories = {patientDirectories().name};
                patientDirectories(ismember(patientDirectories,{'.','..','.svn'})) = [];
                obj.patientNames = patientDirectories;
                obj.patients = patientDirectories;
            end
            
            assert(~isempty(obj.patientNames),[' could not determine patient names from ',dataPath])
            
        end
        
        
        function patientData = getNextPatient(obj)
            %three cases, patient data could be a cell of data
            %the entry path path/patientName{i} could refer to a folder
            %the entry path path/patientName{i} could refer to a .mat file
            
            if obj.patientPointer > length(obj.patients)
                patientData = [];
            elseif isa(obj.patients{obj.patientPointer},'double')
                patientData = obj.patients{obj.patientPointer};
                obj.patientPointer = obj.patientPointer+1;
            elseif ischar(obj.patients{obj.patientPointer}) && ...
                    exist([obj.dataPath,'/',obj.patientNames{obj.patientPointer}]) == 2
                patientData = load([obj.dataPath,'/',obj.patientNames{obj.patientPointer}]);
                patientData = patientData.patientData;
                obj.patientPointer = obj.patientPointer + 1;
            elseif ischar(obj.patients{obj.patientPointer}) && ...
                    exist([obj.dataPath,'/',obj.patientNames{obj.patientPointer}]) == 7;
                disp(obj.patientNames{obj.patientPointer})
                meanValues = load([obj.dataPath,'/',obj.patientNames{obj.patientPointer},'/mean.txt']);
                validationValues = load([obj.dataPath,'/',obj.patientNames{obj.patientPointer},'/validation.txt']);
                if(size(validationValues,2) ==3)
                    validationValues = validationValues(:,3);
                end
                durationValues = load([obj.dataPath,'/',obj.patientNames{obj.patientPointer},'/duration.txt']);
                patientData = [meanValues,durationValues,validationValues];
                obj.patientPointer = obj.patientPointer + 1;
            else
                error(['cannot read ', obj.patients{obj.patientPointer}]);
            end
            
        end
        
        function cachePatients(obj, pathToDirectory)
            patientPointerLocation = obj.patientPointer;
            obj.patientPointer = 1;
            for i = 1:length(obj.patientNames)
                patientData = obj.getNextPatient();
                save([pathToDirectory,'/',obj.patientNames{i},'.mat'],'patientData');
            end
            obj.patientPointer = patientPointerLocation;
        end   
    end
end
















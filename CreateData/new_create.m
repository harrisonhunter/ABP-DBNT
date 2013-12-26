function new_create()
    %clear
    t1 = now;
    fprintf('creating data.\n');
    % load config file
    D = create_data_config;
  
    labelSeparators = D.labelSeperators;

    % load MIMIC data
%     dataLoader = new_mim(D.dataPath);
  
    % data column values
    meanColumn = 1;
    beatDurationColumn = 2;
    validityColumn = 3;

    % init segments list
    segments = {}; 
    
    patientDirectories = dir(D.dataPath);
    patientDirectories = {patientDirectories().name};
    patientDirectories(ismember(patientDirectories,{'.','..','.svn'})) = [];
    patientNames = patientDirectories;
    patients = patientDirectories;
        
    % create patient data
    %if (RUN_DISTRIBUTED==1)
    %    disp(' opening pool ')
    %    matlabpool 
    %    matlabpool size
    %end
    for i = 1:length(patientNames)
%         fprintf('creating patient %i from %i patients\n', i, ...
%             length(dataLoader.patientNames));
        patientData = new_mim(i, D.dataPath, patientNames);
        if(isempty(patientData))
            continue
        end

        % create new patient object
        mimic_segments = new_pat(patientData, ...
            patientNames{i}, ...
            beatDurationColumn,validityColumn, ...
            D.lagUnitLengthMinutes, ...
            D.overlapAmount);
        % get patient segments
        patientSegments = getSegments(patientNames{i}, meanColumn, ...
            beatDurationColumn, ...
            validityColumn, ...
            D.numberOfLagUnits, ...
            labelSeparators, ...
            D.cutOffClass, mimic_segments);
        % put patient segments into segment list
        for j = 1:length(patientSegments)
            if length(unique(patientSegments{j}.lagUnitLabels)) > 1
                segments{end+1} = patientSegments{j};
            end
        end
    end

    discretizedSegments = cell(1,length(segments));

    %if RUN_DISTRIBUTED==1
    %    parfor i=1:length(segments)
    %        discretizedSegments{i} = segments{i}.getDiscretizedAggregationFeatures(meanColumn,D.labelSeperators);
    %    end
    %else
    for i=1:length(segments)
%         fprintf('discretizing patient %i \n', i)
        discretizedSegments{i} = segments{i}.getDiscretizedAggregationFeatures(meanColumn,D.labelSeperators);   
    end
    fileName = strcat('data','_',num2str(D.overlapAmount),'_',num2str(D.numberOfLagUnits),'_',num2str(D.lagUnitLengthMinutes),'_',num2str(D.timeSliceSize),'.txt');
    ftemp = fopen(fileName,'w' );
    dataMat = [];
    patientMap = containers.Map('KeyType', 'int32', 'valuetype', 'int32');
    for i=1:length(discretizedSegments)
%         fprintf('formatting patient %i \n', i)
        ID = str2num(segments{i}.patientID);
        if patientMap.isKey(ID)
            obv = patientMap(ID) + 1;
            patientMap(ID) = obv;
        else
            obv = 0;
            patientMap(ID) = 0;
        end
        sizeSeg = size(discretizedSegments{i});
        dataMat(i,1) = ID; %Place Holder for patient id
        dataMat(i,2) = obv; %place Holder for order id
        for j=1:sizeSeg(1);
            for k=1:sizeSeg(2);
                dataMat(i,(((j-1) * sizeSeg(2)) + k + 2)) = discretizedSegments{i}(j,k);
            end
        end
    end
    for i=1:length(discretizedSegments)
%         fprintf('writing patient %i \n', i)
        fprintf(ftemp, '%d ', dataMat(i,:));
        fprintf(ftemp, '\n');
    end
    t2 = now;
    fprintf('total running time for 3 patients')
    diff = t2 - t1
    fclose(ftemp);
end

% function create_data2()
%     % load config file
%     C = create_data_config;
%   
%     labelSeparators = C.labelSeperators;
% 
%     % load MIMIC data
%     dataLoader = MIMIC_data_loader(C.dataPath);
%   
%     % data column values
%     beatDurationColumn = dataLoader.beatDurationColumn;
%     validityColumn = dataLoader.validityColumn;
%     meanColumn = dataLoader.meanColumn;
% 
%     % init segments list
%     segments = {}; 
% 
%     % create patient data
%     for i = 1:length(dataLoader.patientNames)
%         fprintf('creating patient %i from %i patients\n', i, ...
%             length(dataLoader.patientNames));
%         patientData = dataLoader.getNextPatient();
%         if(isempty(patientData))
%             continue
%         end
%         
%         % create new patient object
%         patient = patientClass(patientData, ...
%             dataLoader.patientNames{i}, ...
%             beatDurationColumn,validityColumn, ...
%             C.lagUnitLengthMinutes, ...
%             C.overlapAmount);
%         % get patient segments
%         patientSegments = patient.getSegments(meanColumn, ...
%             beatDurationColumn, ...
%             validityColumn, ...
%             C.numberOfLagUnits, ...
%             labelSeparators, ...
%             C.cutOffClass);
%         % put patient segments into segment list
%         for j = 1:length(patientSegments)
%             if length(unique(patientSegments{j}.lagUnitLabels)) > 1
%                 segments{end+1} = patientSegments{j};
%             end
%         end
%     end
% 
%     % permute segments and save them along with other vals
% %     permutations = randperm(length(segments));
% %     TotalNumberOfSegments = length(segments);
% %     save([C.tmpDir C.segmentsFileName], ...
% %         'segments', ...
% %         'labelSeparators', ...
% %         'meanColumn', ...
% %         'validityColumn', ...
% %         'beatDurationColumn', ...
% %         'TotalNumberOfSegments', ...
% %         '-v7.3')
%     
%     beatDurationColumn = dataLoader.beatDurationColumn;
%     validityColumn = dataLoader.validityColumn;
%     meanColumn = dataLoader.meanColumn;
% 
%     % MDW: what are discretized segments?
%     discretizedSegments = cell(1,length(segments));
%     
%     for i=1:length(segments)
%         fprintf('discretizing patient %i \n', i)
%         discretizedSegments{i} = segments{i}.getDiscretizedAggregationFeatures(meanColumn,C.labelSeperators);
%     end
    
%     fileName = strcat('data','_',num2str(D.overlapAmount),'_',num2str(D.numberOfLagUnits),'_',num2str(D.lagUnitLengthMinutes),'_',num2str(D.timeSliceSize),'.txt');
%     ftemp = fopen(fileName,'w' );
% end

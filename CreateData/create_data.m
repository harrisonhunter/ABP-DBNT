function create_data()
    %clear
    fprintf('creating data.\n');
    % load config file
    D = create_data_config;

    % add necessary path to dependencies
    %addpath('HMM'); 
  
    labelSeparators = D.labelSeperators;

    % load MIMIC data
    dataLoader = MIMIC_data_loader(D.dataPath);
  
    % data column values
    beatDurationColumn = dataLoader.beatDurationColumn;
    validityColumn = dataLoader.validityColumn;
    meanColumn = dataLoader.meanColumn;

    % init segments list
    segments = {}; 

    % create patient data
    for i = 1:length(dataLoader.patientNames)
        fprintf('creating patient %i from %i patients\n', i, ...
            length(dataLoader.patientNames));
        patientData = dataLoader.getNextPatient();
        if(isempty(patientData))
            continue
        end
        
        % create new patient object
        patient = patientClass(patientData, ...
            dataLoader.patientNames{i}, ...
            beatDurationColumn,validityColumn, ...
            D.lagUnitLengthMinutes, ...
            D.overlapAmount);
        % get patient segments
        patientSegments = patient.getSegments(meanColumn, ...
            beatDurationColumn, ...
            validityColumn, ...
            D.numberOfLagUnits, ...
            labelSeparators, ...
            D.cutOffClass);
        % put patient segments into segment list
        for j = 1:length(patientSegments)
            if length(unique(patientSegments{j}.lagUnitLabels)) > 1
                segments{end+1} = patientSegments{j};
            end
        end
    end

    % permute segments and save them along with other vals
    permutations = randperm(length(segments));
    TotalNumberOfSegments = length(segments);
    save([D.tmpDir D.segmentsFileName], ...
        'segments', ...
        'labelSeparators', ...
        'meanColumn', ...
        'validityColumn', ...
        'beatDurationColumn', ...
        'TotalNumberOfSegments', ...
        '-v7.3')
    
    
    
    % load the config file
    D = create_data_config;
    
    % load segmented data
    load([D.tmpDir D.segmentsFileName]);
    
    %global RUN_DISTRIBUTED;
    %RUN_DISTRIBUTED = D.runDistributed;

    % add paths with dependencies
    %PROB_PATH = '../../Probability/';
    %addpath([PROB_PATH 'StateSpaceModels/DBNT/']);
    %addpath(genpath([PROB_PATH 'EVOLearningStructureBranch/MatlabLearning/bnt/']));
    %addpath(genpath('../../AlexanderWaldinThesis/Code/HMM/PSOCode/'));

    %disp('resetting Global Stream')
    reset(RandStream.getGlobalStream)
    %if (RUN_DISTRIBUTED==1) 
    %   printf('Running as a distributed process\n'); 
    %end

    % load MIMIC data
    dataLoader = MIMIC_data_loader(D.dataPath);
    beatDurationColumn = dataLoader.beatDurationColumn;
    validityColumn = dataLoader.validityColumn;
    meanColumn = dataLoader.meanColumn;

    % MDW: what are discretized segments?
    discretizedSegments = cell(1,length(segments));
    
    %if (RUN_DISTRIBUTED==1)
    %    disp(' opening pool ')
    %    matlabpool 
    %    matlabpool size
    %end

    %if RUN_DISTRIBUTED==1
    %    parfor i=1:length(segments)
    %        discretizedSegments{i} = segments{i}.getDiscretizedAggregationFeatures(meanColumn,D.labelSeperators);
    %    end
    %else
    for i=1:length(segments)
        discretizedSegments{i} = segments{i}.getDiscretizedAggregationFeatures(meanColumn,D.labelSeperators);   
    end
    fileName = strcat('data','_',num2str(D.overlapAmount),'_',num2str(D.numberOfLagUnits),'_',num2str(D.lagUnitLengthMinutes),'_',num2str(D.timeSliceSize),'.txt');
    ftemp = fopen(fileName,'w' );
    dataMat = [];
    patientMap = containers.Map('KeyType', 'int32', 'valuetype', 'int32');
    for i=1:length(discretizedSegments)
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
                dataMat(i,j * sizeSeg + k + 2) = discretizedSegments{i}(j,k);
            end
        end
    end
    
    for i=1:length(discretizedSegments)
        fprintf(ftemp, '%d ', dataMat(i,:));
        fprintf(ftemp, '\n');
    end
    fclose(ftemp);
    'Whoo Whoo Done!'
end
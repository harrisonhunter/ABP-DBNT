function D_out = create_data_config

persistent D;

if isempty(D)

    % data creation parameters
    D.cachePath = 'debugData/cachedData';
    D.dataPath = 'debugData/data';
    D.tmpDir = 'debugData/tmp';
    
    % file names for cached results
    D.segmentsFileName = 'segments.mat';
    D.learnedModelFileName = 'learnedmodel.mat';
    D.postProcessFileName = 'postprocessresults.mat';
    D.predictionFileName = 'predictions.mat';
    
    D.overlapAmount = 10;
    D.labelSeperators = [50 55 60 65 70 75 80 85 90]';
    D.cutOffClass = 3;
    D.numberOfLagUnits = 12;
    D.lagUnitLengthMinutes = 20;
    D.timeSliceSize = 20;
    %D.runDistributed = 0;
end

D_out = D;
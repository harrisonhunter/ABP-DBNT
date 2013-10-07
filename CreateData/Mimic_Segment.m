classdef Mimic_Segment < handle
    
    properties(SetAccess = private)
        segmentData;
        segmentPointer;
        lagUnitLength;
        timeColumn;
    end
    
    methods
        function obj = Mimic_Segment(data, lagUnitLengthMinutes, beatDurationColumn)
            %creates a mimic segment
            %Arguments:
            %data: A continuous block of data from a patient
            %lagUnitLengthMinutes: If you want to get lag units from this
            %segment. 
            %beatDurationColumn Index of the column with the beat duration
            assert(~isempty(data),'cannot create an empty segment');
            
            obj.segmentData = data;
            obj.lagUnitLength = lagUnitLengthMinutes*60*125;
            obj.timeColumn = cumsum(data(:,beatDurationColumn));
            obj.segmentPointer = 1;
        end
        
        function lagUnitData = getLagUnit(obj)
            nextLagUnitEndTime = obj.timeColumn(obj.segmentPointer) + obj.lagUnitLength;
            if(nextLagUnitEndTime > obj.timeColumn(end))
                lagUnitData = [];
            else
                nextSegmentPointer = BinarySearch.floor(nextLagUnitEndTime,obj.timeColumn);
                lagUnitData = obj.segmentData(obj.segmentPointer:nextSegmentPointer,:);
                obj.segmentPointer = nextSegmentPointer;
            end
        end
        
        function b = hasAnotherSegment(obj)
            nextLagUnitEndTime = obj.timeColumn(obj.segmentPointer) + obj.lagUnitLength;
            if(nextLagUnitEndTime > obj.timeColumn(end))
                b = false;
            else
                b = true;
            end
        end
        
        function [scaleClassificationProblems, labels] = getScaleClassificationSamples(obj,MeanColumn,...
                validityColumn, beatFeaturesColumns, lagTimeMinutes, leadTimeMinutes, predictionTimeMinutes, movingWindowMinutes,seperators)
            scaleClassificationProblems = {};
            labels = {};
            pointer = 1;
            lagTime = lagTimeMinutes * 60 * 125;
            leadTime = leadTimeMinutes * 60 * 125;
            predictionTime = predictionTimeMinutes * 60 * 125;
            movingWindowTime = movingWindowMinutes * 60 * 125;
            
            
            while pointer < length(obj.timeColumn)
                dataEndPointer = BinarySearch.floor(obj.timeColumn(pointer)+lagTime,obj.timeColumn);
                predictionStartPointer = BinarySearch.floor(obj.timeColumn(pointer)+lagTime+leadTime,obj.timeColumn);
                predictionEndPointer = BinarySearch.floor(obj.timeColumn(pointer)+lagTime+leadTime+predictionTime,obj.timeColumn);
                if predictionEndPointer == -1
                    break;
                end 
                data = obj.segmentData(pointer:dataEndPointer,:);
                predictionData = obj.segmentData(predictionStartPointer:predictionEndPointer,:);
                pointer = BinarySearch.floor(obj.timeColumn(pointer) + movingWindowTime,obj.timeColumn);
                
                validityIndices = find(data(:,validityColumn) == 1);
                predictionValidityIndices = find(predictionData(:,validityColumn) == 1);
                if length(validityIndices) < (size(data,1)/2) || ...
                        length(predictionValidityIndices) < (size(predictionData,1)/2) 
                    %if half the beats are invalid, skip this segment
                    continue
                end
                
                aggregationFeatures = [];
                
                for i = 1:length(beatFeaturesColumns)
                    aggregationFeatures = [aggregationFeatures, ...
                        AggregationFeatures.createAggregationFeatures(data(validityIndices),beatFeaturesColumns(i),obj.timeColumn(validityIndices))];
                end
                
                scaleClassificationProblems{end+1} = aggregationFeatures;
                labels{end+1} = map2classes(mean(predictionData(predictionValidityIndices,MeanColumn)),seperators);
                
            end
        end
        
        function resetSegment(obj)
            obj.segmentPointer = 1;
        end
            
            
                    
    end
end

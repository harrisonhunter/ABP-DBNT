classdef HMMSegment < handle
    
    properties(SetAccess = public)
        patientID;
        complete;
        valid;
        numberOfLagUnits;
        lagUnits;
        lagUnitLabels;
        labelSeperators;
        validityIndices;
        cumulativeBeats;
        cutOffClass;
        volatility_index;
        discretizedAggregationFeatures;
        aggregationFeatures;
        numberOfClassesBelowCutOff;
    end
    
%     properties(SetAccess = private)
%         discretizedAggregationFeatures;
%         aggregationFeatures;
%         numberOfClassesBelowCutOff;
%     end
    
    methods
        function obj = HMMSegment(patientID, numberOfLagUnits, labelSeperators, cutOffClass)
            assert(numberOfLagUnits>0)
            obj.patientID = patientID;
            obj.numberOfLagUnits = numberOfLagUnits;
            obj.labelSeperators = labelSeperators;
            obj.complete = false;
            obj.cutOffClass = cutOffClass;
            obj.lagUnits = {};
            obj.lagUnitLabels = [];
            obj.valid = true;
            obj.numberOfClassesBelowCutOff = 0;
            obj.validityIndices = {};
            obj.cumulativeBeats = {};
            obj.aggregationFeatures = {};
            obj.discretizedAggregationFeatures = {};
        end
        
        function complete = isComplete(obj)
            complete = obj.complete;
        end
        
        function valid = isValid(obj)
            valid = obj.valid;
        end
        
        function addLagUnit(obj,lagUnitData, meanColumn, validityColumnIndex, beatDurationColumn)
            %lag unit must be valid, that is at least 50% of all beats must
            %be valid
            if obj.complete
                return
            end
            
            if ~obj.valid
                return
            end
            
            % ensure that we have enough valid data to consider this
            % segment a useful segment
            if sum(lagUnitData(:,validityColumnIndex)) < length(lagUnitData(:,validityColumnIndex))/2
                obj.valid = false;
                return
            end
                
            obj.lagUnits{end+1} = lagUnitData;
            obj.validityIndices{end+1} = find(lagUnitData(:,validityColumnIndex)==1);
            obj.cumulativeBeats{end+1} = cumsum(lagUnitData(:,beatDurationColumn));
            
            % create column of class labels
            label = map2classes(mean(lagUnitData(obj.validityIndices{end},meanColumn)),obj.labelSeperators);
            obj.lagUnitLabels(end+1,1) = label;
            if label < obj.cutOffClass
                obj.numberOfClassesBelowCutOff = obj.numberOfClassesBelowCutOff + 1;
            end
            
            if length(obj.lagUnits) >= obj.numberOfLagUnits
                obj.complete = true;
            end
            
            % create a new column that indicates the volatility of the data
            obj.volatility_index = sum(abs(diff(obj.lagUnitLabels)))/(length(obj.labelSeperators)*obj.numberOfLagUnits) + ...
               2*(obj.numberOfClassesBelowCutOff/obj.numberOfLagUnits);
            
        end
            
        function aggregationFeatures = getAggregationFeatures(obj,meanColumnIndex)
            if ~obj.complete
                error('HMM Segment must be complete to call getAggregationFeatures')
            end
            
            if isempty(obj.aggregationFeatures)
            
                obj.aggregationFeatures = zeros(length(obj.lagUnits),length(AggregationFeatures.aggregationFeatureNames));
                for i = 1:length(obj.lagUnits)
                    obj.aggregationFeatures(i,:) = AggregationFeatures.createAggregationFeatures(...
                        obj.lagUnits{i}(obj.validityIndices{i},meanColumnIndex),obj.cumulativeBeats{i}(obj.validityIndices{i}));
                end
            end
            
            aggregationFeatures = obj.aggregationFeatures;
        end

        function discretizedAggregationFeatures = getDiscretizedAggregationFeatures(obj,meanColumnIndex,meanABPSeperators,varargin)
           
           aggregationFeatures = obj.getAggregationFeatures(meanColumnIndex);
           discretizedAggregationFeatures = zeros(size(aggregationFeatures));
           
           if nargin == 3
               seperators = AggregationFeatures.getAggregationFeatureSeperators({obj},meanColumnIndex,6);
               seperators = {meanABPSeperators,seperators{2:end}};
           elseif nargin == 4
               seperators = varargin{1};
           else
               error('Third argument should be seperators');
           end
           for i = 1:size(discretizedAggregationFeatures,1)
               for j = 1:size(discretizedAggregationFeatures,2)
                   X = seperators{j};
                   ind = find(X > aggregationFeatures(i,j), 1 );
                   if size(ind,2) == 0 || size(ind,1) == 0
                       ind = 10;
                   end
%                    i, j, ind, aggregationFeatures(i,j),seperators{j}
                   discretizedAggregationFeatures(i,j) = ind;
               end
           end
%            discretizedAggregationFeatures(:,1) = map2classes(aggregationFeatures(:,1),meanABPSeperators);
%            for i = 2:size(aggregationFeatures,2)
%                discretizedAggregationFeatures(:,i) = map2classes(aggregationFeatures(:,i),seperators{i}');
%            end
                  
        end   
    end
end

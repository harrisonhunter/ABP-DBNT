classdef AggregationFeatures
    properties(Constant)
        aggregationFeatureNames = {'Mean','Std','Trend','Kurtosis','Skew','Median Velocity','Median Acceleartion'};
    
    end
    
    
    methods(Static)
        
        function aggregationFeatures = createAggregationFeatures(beatFeatureToAggregate,cumulitiveBeats)
            % note that you should only pass in valid beatFeatures
            dataMean = mean(beatFeatureToAggregate);
            dataStd = std(beatFeatureToAggregate);
            dataKurtosis = kurtosis(beatFeatureToAggregate);
            dataSkew = skewness(beatFeatureToAggregate);
            
            polyResult = polyfit(cumulitiveBeats,beatFeatureToAggregate,1);
            Trend = polyResult(1);
            
            firstDerivative = diff(beatFeatureToAggregate)./diff(cumulitiveBeats);     
            %disp(firstDerivative)
	    secondDerivative = diff(firstDerivative)./diff(cumulitiveBeats(2:end));
            
            medianVelocitiy = median(firstDerivative);
            medianAcceleration = median(secondDerivative);
            
            aggregationFeatures = [dataMean,dataStd,Trend, dataKurtosis,dataSkew,medianVelocitiy,medianAcceleration];
            
            
        end
        
        function separators = getAggregationFeatureSeperators(segments, beatFeatureColumn, unitsUsedForBinning)
            
            block = [];
            for i = 1:length(segments)
                block = [block;segments{i}.getAggregationFeatures(beatFeatureColumn)];
            end
            
            separators = cell(1,length(AggregationFeatures.aggregationFeatureNames));
            
            unitsUsedForBinning = min(unitsUsedForBinning, size(block, 1));
            [me,sigma] = normfit(block(1:unitsUsedForBinning,:));
            
            for i = 1:size(me,2)
                separators{i} = linspace(me(i)-2*sigma(i),me(i)+2*sigma(i),9);
            end
           
           
           
        end

    end
end


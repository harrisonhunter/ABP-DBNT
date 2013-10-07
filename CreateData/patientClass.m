classdef patientClass < handle
    %a patient instance contains all data belonging to a patient. It has
    %two properties of interest: The segment property contains all
    %experiment-segments. Experiment segments are made up of several
    %sequential lag_units. Each lag_unit has at least 50% valid beats.
    %Experimental-segments may overlap in time.
    %
    %The other property of interest are the MIMIC_segments. These are
    %continuous blocks of signal collected in the mimic_segment class.
    %These have useful functions, such as get unit segment and create
    %classifier problem
    %
    %Note that patient classes can get very large. Having many of them
    %maybe very memory intensive so it can make sense to create them
    %sequentially, create the data needed from them and throw the patinet
    %instance away.
    

    
    properties(SetAccess = public)
        mimic_segments;
        patientID;
    end
    
    methods
        function obj = patientClass(patientData,patientID, beatDurationColumn,...
                validityColumnIndex, lagUnitLengthMinutes, overlapAmount)
            assert(~isempty(patientData),['no patient data for patient ',patientID])
            
            obj.patientID = patientID;
            
            %------create mimic segments---------
            %find the parts of the data that belong to each other. Remember
            %that segments are divided by a 2 in the validity Column. There
            %will be a total of length(mimicSegmentIndices) + 1 mimic
            %segments.
            mimicSegmentIndices = find(patientData(:,validityColumnIndex) == 2);
            
            obj.mimic_segments = {};

            segmentStart = 1;
            for i = 1:(length(mimicSegmentIndices)+1)
                
                if i > length(mimicSegmentIndices)
                    %we are at the final segment. This mimicsegment lasts from
                    %segment start to the end of the data
                    segmentEnd = size(patientData,1);
                else
                    %we are not at the final segment. This mimic segment
                    %lasts from segment start to the the next index
                    segmentEnd = mimicSegmentIndices(i)-1;
                end

                if segmentStart < segmentEnd
                    %only create a segment if segment start is less than
                    %segment End. In border cases (last entry in patient is
                    %a jump for example) segmentStart could be equal to
                    %segment End and we don't want to create a segment with
                    %no data. 
                    
                    % decrease the actual segment start used by the
                    % specified overlap amount if there is enough data to
                    % do so
                    if (segmentStart>overlapAmount)
                        actualSegmentStart = segmentStart-overlapAmount;
                    else
                        actualSegmentStart = segmentStart;
                    end
                    obj.mimic_segments{end+1} = ...
                        Mimic_Segment(...
                            patientData(...
                                actualSegmentStart:segmentEnd,:), ...
                                lagUnitLengthMinutes, ...
                                beatDurationColumn);
                end
                
                if i <= length(mimicSegmentIndices)
                    %as long as segments are left update the segment start
                    %to the start of the next segment. 
                    segmentStart = mimicSegmentIndices(i)+1;
                end
            end
            
            
            %assert(~isempty(obj.mimic_segments),sprintf('patient %s has no segments',patientID))

        end
        
        function segments = getSegments(obj,meanColumn, beatDurationColumn, validityColumn, numberOfLagUnits, labelSeperators, cutOffClass)
              
            %create segments. A segment consists of several consecutive 
            %unit segments. Every time we get a new unit segment from the 
            %mimic segment, we create a new segment. We then add the unit  
            %segment we just got to every segment. At the end we go through
            %all created segments and check if they are valid. A segment is
            %valid if all unit segments it is made up of are valid (>50% of
            %beats are valid) and if it contains the specified number of
            %unit segments (i.e. it's not too small). 
            segments = {};
            for i = 1:length(obj.mimic_segments)
                HMMSegments = {};
                obj.mimic_segments{i}.resetSegment()
                while(obj.mimic_segments{i}.hasAnotherSegment)
                    lagUnitData = obj.mimic_segments{i}.getLagUnit();
                    %create a new segment
                    HMMSegments{end+1} = HMMSegment(obj.patientID, numberOfLagUnits, labelSeperators, cutOffClass);
                    for j = 1:length(HMMSegments)
                        %
                        HMMSegments{j}.addLagUnit(lagUnitData, meanColumn, validityColumn, beatDurationColumn)
                    end
                end
                for j = 1:length(HMMSegments)
                    if(HMMSegments{j}.isValid() && HMMSegments{j}.isComplete())
                        segments{end+1} = HMMSegments{j};
                    end
                end
            end

            %sort obj.segments by number of classes below class cutoff
            numberOfClassesArray = zeros(1,length(segments));
            for i = 1:length(segments)
                numberOfClassesArray(i) = segments{i}.volatility_index;
            end

            [~,idx] = sort(numberOfClassesArray);
            segments = segments(idx);               
        end
                
            
    end
end

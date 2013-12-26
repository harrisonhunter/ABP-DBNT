function mimic_segments = new_pat(patientData,patientID, beatDurationColumn,...
        validityColumnIndex, lagUnitLengthMinutes, overlapAmount)
    assert(~isempty(patientData),['no patient data for patient ',patientID])

    %------create mimic segments---------
    %find the parts of the data that belong to each other. Remember
    %that segments are divided by a 2 in the validity Column. There
    %will be a total of length(mimicSegmentIndices) + 1 mimic
    %segments.
    mimicSegmentIndices = find(patientData(:,validityColumnIndex) == 2);

    mimic_segments = {};

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
            mimic_segments{end+1} = ...
                new_mim_seg(...
                    patientData(actualSegmentStart:segmentEnd,:), ...
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
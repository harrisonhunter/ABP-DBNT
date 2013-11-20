function [ labels ] = map2classes( mapVector, separators, varargin )
%% MAP2CLASSES casts raw MAP values to classes based on criterion 
%   Give this function a MAP vector and a vector of separators (sorted, positive)
%
%       separators = [12, 45, 76, 89]'
%
%   And this function will return a vector of same size as the MAP vector with 
%   class labels. 
%
%   NOTE: You can adjust the starting index for the classes with the
%   'startingClassIndex' parameter!

    % parse input
    p = inputParser;
    p.addOptional('startingClassIndex',1,@isscalar);
    p.parse(varargin{:});

    % configure if classes indices are 0-based, 1-based or other
    % constrained now to go up in stepsize of 1
    START_CLASS_LABELS_FROM = p.Results.startingClassIndex;

    %======= ASSERT DATA IN PROPER FORMAT
    % ensure our separators are sorted
%     sortedSeps = sort(separators, 'ascend');
%     assert( isEqual(sortedSeps, separators), 'Separators vector MUST be sorted in ascending order');
    
    % ensure all postive and non-empty
%     assert(~isempty(sortedSeps), 'Must have at least one separator in separator list.');
    %validateattributes(sortedSeps,{'numeric'});%,{'positive'});
    
    % and right shape
%     dims = size(sortedSeps);
%     if ~dims(2) == 1
%         separators = separators';
%     end
    %=======
    
    % allocate room for class vector output
    labels = zeros(size(mapVector));
    
    % for each MAP value
    for i = 1 : length(mapVector)
        
        % mark that no value is entered yet
        % and grab raw MAP value
        classSet = false;
        map = mapVector(i);
        
        % for each separator threshold
        for c = 1 : length(separators)
            
            % if this MAP was lower than sep, then it goes in the class
            if map < separators(c)
                labels(i) = c + START_CLASS_LABELS_FROM - 1;
                classSet = true;
                break;
            end
            
        end
        
        % if this MAP value was higher than our last separator
        if ~classSet
            labels(i) = length(separators) + START_CLASS_LABELS_FROM;
        end
        
    end

end

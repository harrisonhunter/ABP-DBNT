% MDW: attempt at filling in the missing map2classes function
function [sep_idx] = map2classes(map_val, class_separators)
    sep_idx = 1;
    while sep_idx <= length(class_separators)
        if map_val < class_separators(sep_idx)  
            return;
        end
        sep_idx = sep_idx+1;
    end
end
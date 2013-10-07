classdef BinarySearch
    methods(Static)
        function index = floor(key, sortedArray)
           if isempty(sortedArray)
               index = -1;
               return
           elseif key < sortedArray(1)
               index = -1;
               return
           else
               lo = 1; 
               hi = length(sortedArray);
               while(lo <= hi)
                   mid = lo+floor((hi-lo)/2);
                   
                   if key == sortedArray(mid)
                       index = mid;
                       return
                   elseif key < sortedArray(mid)
                       %check if the one value below is smaller than key if
                       %it is that is the floor else we search in low and
                       %mid-1
                       if(key > sortedArray(mid-1))
                           index = mid-1;
                           return
                       else
                           hi = mid-1;
                       end
                   else
                       lo = mid+1;
                   end
               end
           end
           index = -1;
           return
                           
        end
    end
end
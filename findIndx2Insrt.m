% findIndx2Insrt
%
% returns the index where val is to be inserted into the vector
% This function is recursive.
% The initial call will be: findIndx2Insrt(vec,val,1,size(vec,2)+1)
%
% Parameters:
% - vec: a horizontal list of numbers sorted in ascending order
% - val: a value to be inserted
% - i_strt: the first index of the range to search
% - i_last: the last index of the range to search + 1
%

function index = findIndx2Insrt(vec,val,first,last)

if(val < vec(first))
  index = 1;
elseif(vec(last-1)<=val)
  index = last;
else
  i_mid = first + floor((last - first)/2);
  while(first != i_mid)
    if(val < vec(i_mid))
      last = i_mid;
    else
      first = i_mid;
    end
    i_mid = first + floor((last - first)/2);
  end

  index = i_mid + 1;
end

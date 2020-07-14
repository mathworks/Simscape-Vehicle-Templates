function sm_car_open_chrome(url_address)
% Copyright 2018-2020 The MathWorks, Inc.

if(ispc)
    eval(['!start chrome "' url_address '"']);
elseif(ismac)
    eval(['!open -a "Google Chrome" ''' url_address '''']);
end

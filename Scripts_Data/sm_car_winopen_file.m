function sm_car_winopen_file(filename)
% Copyright 2016-2020 The MathWorks, Inc.

% Opens files using different commands depending on operating system.

if (exist(filename))
    if(ispc)
        winopen(filename)
    elseif(ismac)
        eval(['!open ' filename]);
    end
else
    msgbox(['File ' filename ' is not on your path.  It may have been excluded to reduce the size of the folder containing all the supporting files for this example.'],'File not provided');
end


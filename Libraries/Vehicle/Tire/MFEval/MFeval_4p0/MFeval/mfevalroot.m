function loc = mfevalroot()
%mfevalroot()  Root folder.
%
%  loc = mfevalroot() returns the name of the folder where this software is
%  installed. Use mfevalroot() to create a path that does not depend on a
%  specific installation location.
%
%  See also: matlabroot

    loc = fileparts(mfilename('fullpath'));
    
end
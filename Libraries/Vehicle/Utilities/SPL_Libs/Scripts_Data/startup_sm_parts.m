% Copyright 2012-2021 The MathWorks, Inc.

SPL_libname = 'Multibody_Parts_Lib';
load_system(SPL_libname);
disp(get_param(SPL_libname,'Description'));
which(SPL_libname)

tempNumCFLLibs = which(SPL_libname,'-all');
if (length(tempNumCFLLibs)>1)
    tempCFLwarnStr = sprintf('Multiple copies of the Simscape Multibody Parts Library are on the MATLAB path. It is recommended you only have one copy on your path. Please consider adjusting your MATLAB path so that only one copy is present.\n\nLocations of Simscape Multibody Parts Library on your path:\n');
    tempCFLLibStr = sprintf('%s\n',tempNumCFLLibs{:});
    warning([tempCFLwarnStr tempCFLLibStr])
end
clear tempNumCFLLibs tempCFLwarnStr SPL_libname

% Only open documentation if it exists
% Documentation is not copied when a copy is produced by
% Multibody_Parts_SaveLibsOnly.m
if (exist('Multibody_Parts_Library_Demo_Script.html','file'))
    web('Multibody_Parts_Library_Demo_Script.html');
end

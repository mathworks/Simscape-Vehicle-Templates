function startup_Contact_Forces

% Startup for Simscape Multibody Contact Force Library
% Copyright 2014-2022 The MathWorks, Inc.

% Load library and display version to Command Window
CFL_libname = 'Contact_Forces_Lib';
load_system(CFL_libname);
disp(get_param(CFL_libname,'Description'));
which(CFL_libname)

% Check for shadowed versions on the path
tempNumCFLLibs = which(CFL_libname,'-all');
if (length(tempNumCFLLibs)>1)
    tempCFLwarnStr = sprintf('Multiple copies of the Simscape Multibody Contact Force Library are on the MATLAB path. It is recommended you only have one copy on your path. Please consider adjusting your MATLAB path so that only one copy is present.\n\nLocations of Simscape Multibody Contact Force Library on your path:\n');
    tempCFLLibStr = sprintf('%s\n',tempNumCFLLibs{:});
    warning([tempCFLwarnStr tempCFLLibStr])
end
clear tempNumCFLLibs tempCFLwarnStr CFL_libname


% Check for shadowed versions on the path
if(exist('Contact_Forces_Demo_Script.html','file'))
    web('Contact_Forces_Demo_Script.html');
else
    this_project = simulinkproject;
    if(this_project.Information.TopLevel == 1)
        web('Contact_Forces_Demo_Script_Library_Only.html');
    end
end

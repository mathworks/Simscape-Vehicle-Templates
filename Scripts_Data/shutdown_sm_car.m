function shutdown_sm_car
% Startup file for sm_car.slx Example
% Copyright 2019-2020 The MathWorks, Inc.

curr_proj = simulinkproject;

TNOtbx6p2_pth=GetTNODelftTyrePath;
if exist(TNOtbx6p2_pth,'dir')
    rmpath(TNOtbx6p2_pth)
    DelftTyrePathstr = sm_car_DelftTyrePath(TNOtbx6p2_pth);
    rmpath(DelftTyrePathstr)
    rmpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'Delft' filesep 'Delft_6p2']);
else
    rmpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'Delft' filesep 'Delft_None']);
end

MFSwifttbx_folders = evalin('base','MFSwifttbx_folders');
if (~isempty(MFSwifttbx_folders))
    disp('Removing MF-Swift from path');
    for mfs_i = 1:length(MFSwifttbx_folders)
        rmpath(MFSwifttbx_folders{mfs_i})
    end
else
    rmpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_None']);
end

% Remove folders with Simscape Multibody tire subsystem to path 
% if MATLAB version R2021b or higher
if verLessThan('matlab', '9.11')
    rmpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFMbody' filesep 'MFMbody_None']);
else
    rmpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFMbody' filesep 'MFMbody']);
end

custom_code = dir('**/custom_abs.ssc');
cd(custom_code.folder)
cd('..')
bdclose all
pause(1)
ssc_clean Custom
cd(fileparts(which('sm_car.slx')))

%% Reset solver settings - patch from development
limitDerivativePerturbations([])
daesscSetMultibody([])

%% Close app
try
   evalin('base','sm_car_vehcfg_uifigure.UIFigure.delete');
catch
end

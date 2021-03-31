% Script to publish all optimization results for each track
% Copyright 2020-2021 The MathWorks, Inc.

warning('off','Simulink:Engine:MdlFileShadowedByFile');
warning('off','Simulink:Harness:WarnABoutNameShadowingOnActivation');

% Ensure MATLAB returns to Overview folder between optimization runs
cd(fileparts(which(mfilename)))
Overview_Optim_Dir = pwd;
cd(Overview_Optim_Dir)

% Find publish scripts
%filelist_m=dir('*.m');
%filenames_m = {filelist_m.name};
filenames_m ={...
    'sm_car_optim_traj_vx_regen_results_overview.m';...
    'sm_car_optim_traj_vx_regen_results_mallory_park.m';...
    'sm_car_optim_traj_vx_regen_results_kyalami_f.m';...
%    'sm_car_optim_traj_vx_regen_results_suzuka_f.m';...
%    'sm_car_optim_traj_vx_regen_results_nurburgring_f.m'...
    };

% Turn off unnecessary warnings
warning('off','Simulink:Engine:MdlFileShadowedByFile');
warning('off','Simulink:Harness:WarnABoutNameShadowingOnActivation');

% Ensure model is open
%open_system('sm_car');

% Loop to publish
for i=1:length(filenames_m)
    if ~(contains(filenames_m{i},'publish_all'))
        publish(filenames_m{i},'showCode',false)
        %disp(filenames_m{i});
    end
    cd(Overview_Optim_Dir)
end

bdclose all
function sm_car_plot3d_save_data(logsout,Maneuver,fileName)
% sm_car_plot3d_save_data  Save data from Simscape Vehicle Templates to file
%    sm_car_plot3d_save_data(logsout,Maneuver,fileName)
%    This file extracts key data from Simscape Vehicle Templates simulation
%    results for the Vehicle Results 3D Plotter and saves them to a mat
%    file.  This file can be loaded later into the 3D Plotter for
%    post-processing.
%
%    logsout    Simulaton results
%    Maneuver   Manuever.Type is used to determine suitable scene data
%    fileName   Name of file where results should be saved
%
% Copyright 2025 The MathWorks, Inc.

% Extract key data from simulation results
[simTime, tireFx, tireFy, tireFz, ...
    wheelAngles, wheelCamber, posVeh, psiVeh, velVeh,...
    tirePx, tirePy, tirePz] = sm_car_plot3d_get_data(logsout);

% Obtain scene name based on Maneuver.Type
sceneName = sm_car_plot3d_manv_to_scene(Maneuver);

% Save results to file
fileName = strrep(fileName,'.mat','');
save([fileName '.mat'],'simTime','tireFx','tireFy','tireFz',...
    'wheelAngles','wheelCamber','posVeh','psiVeh','velVeh',...
    'tirePx','tirePy','tirePz','sceneName');



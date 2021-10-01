function sm_car_05_setup_bump_dlc(mdl)
% Load the default Vehicle configuration data.
if verLessThan('matlab', '9.11')
    sm_car_load_vehicle_data(mdl,'139'); % MFeval tire
else
    sm_car_load_vehicle_data(mdl,'189'); % Multibody tire, R21b and higher
end

% Configure the model, maneuver, trailer and other event options.
sm_car_config_maneuver(mdl,'Double Lane Change');
sm_car_config_vehicle('sm_car');

%% Add bump to double lane change maneuver
% Create road data for bump
[x_road, y_road]=sm_car_05_road_bump;

% Swap bump road data for RDF Rough Road event
Scene = evalin('base','Scene');
Scene.RDF_Rough_Road.Road.extr_data_R = [x_road, y_road];
Scene.RDF_Rough_Road.Road.extr_data_L = Scene.RDF_Rough_Road.Road.extr_data_R.*[1 0];
assignin('base','Scene',Scene);

% Enable road profile based on RDF Rough Road data
set_param([mdl '/Road/Road Surface Height'],'LabelModeActiveChoice','Rough_Road');

end

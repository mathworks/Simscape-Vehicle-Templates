function sm_car_load_vehicle_data(mdl,carDataIndex)
% sm_car_load_vehicle_data  Load vehicle data and optionally trigger
% variant selection
%
%    mdl:           Model name, specify 'none' to load data only.
%    carDataIndex:  Index of vehicle data
% 
% Copyright 2019-2020 The MathWorks, Inc

% Load desired vehicle data into variable Vehicle
load(['Vehicle_' carDataIndex]);
assignin('base','Vehicle',eval(['Vehicle_' carDataIndex]));

% If a model name is specified, trigger variant selection
if(~strcmpi(mdl,'none'))
    sm_car_config_vehicle(mdl);
end

end

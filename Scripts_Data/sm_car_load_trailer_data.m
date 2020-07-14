function sm_car_load_trailer_data(mdl,trailerDataIndex)
% sm_car_load_vehicle_data  Load vehicle data and optionally trigger
% variant selection
%
%    mdl:           Model name, specify 'none' to load data only.
%    carDataIndex:  Index of vehicle data
%
% Copyright 2019-2020 The MathWorks, Inc

% Load desired vehicle data into variable Vehicle
if(strcmpi(trailerDataIndex,'none'))
    trl_state = get_param([mdl '/Vehicle'],'popup_trailer');
%    disp(['Trailer: ' trl_state]);
    set_param([mdl '/Vehicle'],'popup_trailer','Off');
%    disp('Turned Trailer Off');
else
    load(['Trailer_' trailerDataIndex]);
    assignin('base','Trailer',eval(['Trailer_' trailerDataIndex]));
    
    % If a model name is specified, trigger variant selection
    if(~strcmpi(mdl,'none'))
        set_param([mdl '/Vehicle'],'popup_trailer','On');
        sm_car_config_vehicle(mdl);
    end
end


end

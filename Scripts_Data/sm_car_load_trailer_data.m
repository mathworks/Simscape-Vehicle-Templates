function sm_car_load_trailer_data(mdl,trailerDataIndex)
% sm_car_load_trailer_data  Load trailer data 
%
%    mdl:               Model name, specify 'none' to load data only
%    trailerDataIndex:  Index of vehicle data
%                       Specify 'none' to turn off trailer
%
% Copyright 2019-2020 The MathWorks, Inc

% Load desired vehicle data into variable Vehicle
if(strcmpi(trailerDataIndex,'none'))
    if(bdIsLoaded(mdl))
        trl_state = get_param([mdl '/Vehicle'],'popup_trailer');
        %    disp(['Trailer: ' trl_state]);
        set_param([mdl '/Vehicle'],'popup_trailer','Off');
        %    disp('Turned Trailer Off');
    end
else
    load(['Trailer_' trailerDataIndex]);
    assignin('base','Trailer',eval(['Trailer_' trailerDataIndex]));
    
    % If a model name is specified, trigger variant selection
    if(~strcmpi(mdl,'none'))
        if(bdIsLoaded(mdl))
            set_param([mdl '/Vehicle'],'popup_trailer','On');
            sm_car_config_vehicle(mdl);
            trl_body = sm_car_vehcfg_getTrailerType(mdl);
            evalin('base',['Init_Trailer = IDatabase.Flat.Trailer_' trl_body ';']);
        end
    end
end


end

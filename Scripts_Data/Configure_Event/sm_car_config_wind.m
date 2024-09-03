function sm_car_config_wind(modelname,onCar,onTrailer)
%sm_car_config_wind  Configure wind for Simscape Vehicle Model
%   sm_car_config_wind(modelname,onCar,onTrailer)
%
%   This function configures the wind input to the car and trailer.
%
% Copyright 2018-2024 The MathWorks, Inc.

% Find variant subsystems for settings
f=Simulink.FindOptions('LookUnderMasks','all');
fWindCar_h=Simulink.findBlocks(modelname,'Name','Input fWindCar',f);
fWindTrl_h=Simulink.findBlocks(modelname,'Name','Input fWindTrailer',f);

if(onCar)
    set_param(fWindCar_h,'fWind','[0 1000 0]','dWind','10');
else
    set_param(fWindCar_h,'fWind','[0 0 0]','dWind','30000');
end

if(onTrailer)
    set_param(fWindTrl_h,'fWind','[0 1000 0]','dWind','10');
else
    set_param(fWindTrl_h,'fWind','[0 0 0]','dWind','30000');
end

end

function sm_car_check_tire_model(modelname)
%sm_car_check_tire_model  Check if tire software is available for selected tire
%   sm_car_check_tire_model(modelname)
%
% Copyright 2018-2020 The MathWorks, Inc.

f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'Variants','ActiveVariants');
h=Simulink.findBlocks(modelname,'tireModelUnavailable','.*',f);

if(~isempty(h))
    error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
        'The selected tire model is unavailable.',...
        'Please configure your Vehicle data structure to use a different tire model.');
    errordlg(error_str,'Tire Model Unavailable')
end

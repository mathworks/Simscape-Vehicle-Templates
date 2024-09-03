function sm_car_check_tire_model(modelname)
%sm_car_check_tire_model  Check if tire software is available for selected tire
%   sm_car_check_tire_model(modelname)
%
% Copyright 2018-2024 The MathWorks, Inc.

% Find "tireModelUnavailable" by searching active variants only
% Syntax changes with release
if(isMATLABReleaseOlderThan("R2022a"))
    evalin('base','warning off Simulink:Commands:FindSystemVariantsOptionRemoval');
    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'Variants','ActiveVariants');
elseif(isMATLABReleaseOlderThan("R2023b"))
    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
else
    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'MatchFilter',@Simulink.match.legacy.filterOutInactiveVariantSubsystemChoices);
end

% Look for subsystems indicating tire block is not available
h=Simulink.findBlocks(modelname,'tireModelUnavailable','.*',f);

% Show error message if block not available
if(~isempty(h))
    error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
        'The selected tire model is unavailable.',...
        'Please configure your Vehicle data structure to use a different tire model.');
    errordlg(error_str,'Tire Model Unavailable')
end

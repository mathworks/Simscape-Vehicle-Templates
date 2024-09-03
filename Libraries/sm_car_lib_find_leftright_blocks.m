function h = sm_car_lib_find_leftright_blocks(curblk)
% Find other left/right blocks
%
% Copyright 2018-2024 The MathWorks, Inc.

% Search active variants only
% Syntax changes with release
if(isMATLABReleaseOlderThan("R2022a"))
    evalin('base','warning off Simulink:Commands:FindSystemVariantsOptionRemoval');
    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'SearchDepth',1,'Variants','ActiveVariants');
elseif(isMATLABReleaseOlderThan("R2023b"))
    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
else
    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'MatchFilter',@Simulink.match.legacy.filterOutInactiveVariantSubsystemChoices);
end

% Find blocks with popup named "popup_leftRight"
h=Simulink.findBlocks(curblk,'popup_leftRight','.*',f);

function h = sm_car_lib_find_leftright_blocks(curblk)
% Find other left/right blocks
%
% Copyright 2018-2024 The MathWorks, Inc.

%if(verLessThan('matlab','9.10'))
%    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'SearchDepth',1,'Variants','ActiveVariants');
%else
    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'SearchDepth',1,'MatchFilter',@Simulink.match.activeVariants);
%end

h=Simulink.findBlocks(curblk,'popup_leftRight','.*',f);

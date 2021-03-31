function sm_car_lib_maskInitTrigger(curblk)
% Find other blocks to trigger
%if(verLessThan('matlab','9.10'))
    evalin('base','warning off Simulink:Commands:FindSystemVariantsOptionRemoval');
    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'Variants','ActiveVariants');
%else
%    f=Simulink.FindOptions('FollowLinks',1,'RegExp',1,'MatchFilter',@Simulink.match.activeVariants);
%end

h=Simulink.findBlocks(curblk,'InitTriggerDropdown','.*',f);

%disp(curblk);
% Set up array to track systems that need to be triggered
trigger_set = {getfullname(h) ones(size(h))};

% Loop through set to find subsystems that are children using block path
if (size(trigger_set{1},1)>2)
    for sys_i=1:(size(trigger_set{1},1)-1)
        if(trigger_set{2}(sys_i) == 1)
            parentStr = trigger_set{1}(sys_i);
            for sys_i_rest=(sys_i+1):(size(trigger_set{1},1))
                % If subsystem is a child...
                if startsWith(trigger_set{1}(sys_i_rest),parentStr)
                    % ... set array item to 0 to remove it from list
                    trigger_set{2}(sys_i_rest) = 0;
                end
            end
        end
    end
end
% Only keep systems where second array item is 1
h = h(find(trigger_set{2})); %#ok<FNDSB>

% Trigger mask initialization
if(~isempty(h))
    for i=1:length(h)
        set_param(h(i),'InitTriggerDropdown',get_param(curblk,'InitTriggerDropdown'));
        %disp([curblk ': Succeeded for ' getfullname(h(i))]);
    end
end

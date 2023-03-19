function CFL_visual_setOnOff(mdlname,visOnOff)
% Show or hide all contact surfaces in all contact force blocks in a model
% from Simscape Multibody Contact Force Library. Pass the name of the model
% as an argument to this function

% Copyright 2014-2023 The MathWorks, Inc.

CF_bpth=find_system(mdlname,'RegExp','on','LookUnderMasks','on','FollowLinks','on','vis_on','.*');
CF_bpth_box2box=find_system(mdlname,'RegExp','on','LookUnderMasks','on','FollowLinks','on','vis_on_box2box','.*');
CF_bpth_box2belt=find_system(mdlname,'RegExp','on','LookUnderMasks','on','FollowLinks','on','vis_on_pla2pla','.*');
CF_bpth_sph2belt=find_system(mdlname,'RegExp','on','LookUnderMasks','on','FollowLinks','on','vis_on_sph2bel','.*');

if(~isempty(CF_bpth))
    for i=1:length(CF_bpth)
        within_composite_force = 0;
        
        % Check if force is part of a composite force
        % In that case, adjust the setting in the top level mask
        if(~isempty(CF_bpth_box2box))
            for j=1:length(CF_bpth_box2box)
                if (strfind(char(CF_bpth(i)),char(CF_bpth_box2box(j))))
                    within_composite_force = 1;
                end
            end
        end
        
        if(~isempty(CF_bpth_box2belt))
            for k=1:length(CF_bpth_box2belt)
                if (strfind(char(CF_bpth(i)),char(CF_bpth_box2belt(k))))
                    within_composite_force = 1;
                end
            end
        end
        if(~isempty(CF_bpth_sph2belt))
            for k=1:length(CF_bpth_sph2belt)
                if (strfind(char(CF_bpth(i)),char(CF_bpth_sph2belt(k))))
                    within_composite_force = 1;
                end
            end
        end
        
        
        if(within_composite_force==0)
            set_param(char(CF_bpth(i)),'vis_on',visOnOff);
%            disp(['Force ' char(CF_bpth(i)) ' not in composite force']);
%        else
%            disp(['Force ' char(CF_bpth(i)) ' WITHIN composite force']);
        end
    end
end

if(~isempty(CF_bpth_box2box))
    for j=1:length(CF_bpth_box2box)
        set_param(char(CF_bpth_box2box(j)),'vis_on_box2box',visOnOff)
    end
end

if(~isempty(CF_bpth_box2belt))
    for j=1:length(CF_bpth_box2belt)
        set_param(char(CF_bpth_box2belt(j)),'vis_on_pla2pla',visOnOff)
    end
end

if(~isempty(CF_bpth_sph2belt))
    for j=1:length(CF_bpth_sph2belt)
        set_param(char(CF_bpth_sph2belt(j)),'vis_on_sph2bel',visOnOff)
    end
end


end

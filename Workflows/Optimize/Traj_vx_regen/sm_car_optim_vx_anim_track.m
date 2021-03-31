function sm_car_optim_vx_anim_track(optResStruct)
% Create figure for achieved speed along path
if ~exist('h5_sm_car_optim', 'var') || ...
        ~isgraphics(h5_sm_car_optim, 'figure')
    h5_sm_car_optim = figure('Name', 'sm_car_optim_xyv');
end
figure(h5_sm_car_optim)
clf(h5_sm_car_optim)

paramset = reshape([optResStruct(:).param],length(optResStruct(end).final),[])';

iter_min_inds = find(paramset == optResStruct(end).final);
iter_min = iter_min_inds(1);

% Sort lap times in order
% PUT INITIAL FIRST
%[lt, lt_inds] = sort([optResStruct(2:end).laptime],'descend');  
%lt_ind_start = find(lt<10000,1);
%lt_inds_valid = [1 lt_inds(lt_ind_start:end)+1];
[lt, lt_inds] = sort([optResStruct(1:end).laptime],'descend');  
lt_ind_start = find(lt<10000,1);
lt_inds_valid = [lt_inds(lt_ind_start:end)];

plot(optResStruct(end).xref,optResStruct(end).yref,'k--','DisplayName','Target Path');
title('Speed Along Track (Color Indicates Speed)');
axis equal
xlabel('Distance (m)');
ylabel('Distance (m)');
colormap(h5_sm_car_optim,jet);

% Determine color range
max_spd = 0;
min_spd = 1e6;
for i=1:length(optResStruct)
    min_spd = min([min_spd; optResStruct(i).vx]);
    max_spd = max([max_spd; optResStruct(i).vx]);
end

for i=1:length(optResStruct)
    optResStruct(i).vx(1)   = min_spd;
    optResStruct(i).vx(end) = max_spd;
end

%lt_inds_sorted_valid = lt_inds(lt_ind_start:end);
for optRes_i=1:length(lt_inds_valid)
    i = lt_inds_valid(optRes_i);
    laptime_str = ['Lap time: ' sprintf('%5.2f',optResStruct(i).laptime)];
    if(optRes_i==1)
        sf_h_init = surface(...
            [optResStruct(i).x'; optResStruct(i).x'],...
            [optResStruct(i).y'; optResStruct(i).y'],...
            [zeros(size(optResStruct(i).y')); zeros(size(optResStruct(i).y'))],...
            [optResStruct(i).vx'; optResStruct(i).vx'],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',3,'DisplayName',[laptime_str ' (Initial)']);
    else
        sf_h = surface(...
            [optResStruct(i).x'; optResStruct(i).x'],...
            [optResStruct(i).y'; optResStruct(i).y'],...
            [zeros(size(optResStruct(i).y')); zeros(size(optResStruct(i).y'))],...
            [optResStruct(i).vx'; optResStruct(i).vx'],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',3,'DisplayName',laptime_str);
    end
    if(optRes_i==1)
        c=colorbar;
        c.Label.String = 'Vehicle Speed (m/s)';
    end
    legend('FontSize',12,'Location','NorthEast')
    pause(0.5)
    if(exist('sf_h','var'))
        delete(sf_h)
    end
end

laptime_str = ['Lap time: ' sprintf('%5.2f',optResStruct(iter_min).laptime)];
surface(...
    [optResStruct(iter_min).x'; optResStruct(iter_min).x'],...
    [optResStruct(iter_min).y'; optResStruct(iter_min).y'],...
    [zeros(size(optResStruct(iter_min).y')); zeros(size(optResStruct(iter_min).y'))],...
    [optResStruct(iter_min).vx'; optResStruct(iter_min).vx'],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',3,'DisplayName',[laptime_str ' (Tuned)']);

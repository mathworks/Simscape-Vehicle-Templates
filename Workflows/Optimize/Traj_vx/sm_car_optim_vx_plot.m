function sm_car_optim_vx_plot(optResStruct)

% Create figure for target speed along path
if ~exist('h1_sm_car_optim', 'var') || ...
        ~isgraphics(h1_sm_car_optim, 'figure')
    h1_sm_car_optim = figure('Name', 'sm_car_optim_vx');
end
figure(h1_sm_car_optim)
clf(h1_sm_car_optim)
title('Velocity Along Path');
hold on;
box on;
xlabel('Distance Along Path (m)');
ylabel('Velocity (m/s)');

num_iter = length(optResStruct);
for i = 1:num_iter
    h=plot(optResStruct(i).traj_x, optResStruct(i).traj_vx);
    if(i==1)
        % Plot initial lap as black dotted line
        set(h,'LineWidth',2,'Color','k','LineStyle','--');
        vx_h(1) = h;
    end
end

% Find valid runs (laptime < 10000)
[lt, lt_inds] = sort([optResStruct(1:end).laptime],'descend');  
lt_ind_start = find(lt<10000,1);
lt_inds_valid = [lt_inds(lt_ind_start:end)];

% Find iteration with fastest laptime (completed laps only)
% Compare optimal set of parameters to parameters in each iteration
paramset = reshape([optResStruct(:).param],length(optResStruct(end).final),[])';
iter_min_inds = find(sum((paramset == optResStruct(end).final),2)==length(optResStruct(end).final));
iter_min = iter_min_inds(1);

% Find iteration with slowest laptime (completed laps only)
iter_max = lt_inds_valid(1);

% Plot iteration with fastest laptime (completed laps only)
vx_h(2) = plot(optResStruct(iter_min).traj_x, optResStruct(iter_min).traj_vx,'b','LineWidth',2);

hold off
legendstr{1} = ['Initial     Lap Time: ' sprintf('%5.2f',optResStruct(iter_max).laptime)];
legendstr{2} = ['Optimal Lap Time: ' sprintf('%5.2f',optResStruct(iter_min).laptime)];
legend(vx_h,legendstr,'Location','Best');

% Create figure for target path
if ~exist('h2_sm_car_optim', 'var') || ...
        ~isgraphics(h2_sm_car_optim, 'figure')
    h2_sm_car_optim = figure('Name', 'sm_car_optim_xy');
end
figure(h2_sm_car_optim)
clf(h2_sm_car_optim)

% Plot target path
plot(optResStruct(end).xref,optResStruct(end).yref,'k:');
title('Target Path');
legend({'Target'});
axis equal
hold on;

for i = 1:num_iter
    h=plot(optResStruct(i).x, optResStruct(i).y);
    if(i==1)
        % Style initial run (slowest, should track reference line well)
        set(h,'LineWidth',2,'Color','k','LineStyle','--');
        xy_h(1) = h;
    end
    if(optResStruct(i).laptime>=10000)
        % Mark end of failed runs
        off_h =plot(optResStruct(i).x(end), optResStruct(i).y(end),'ro','MarkerFaceColor','r');
    end
end

% Plot fastest run
xy_h(2) = plot(optResStruct(iter_min).x, optResStruct(iter_min).y,'b','LineWidth',1);
hold off
legendstr{1} = ['Initial         Lap Time: ' sprintf('%5.2f',optResStruct(iter_max).laptime)];
legendstr{2} = ['Optimized Lap Time: ' sprintf('%5.2f',optResStruct(iter_min).laptime)];

if(exist('off_h'))
   % Add legend entry if any lap was not completed
   legendstr{3} = 'Vehicle Left Track';
   xy_h(3) = off_h;
end
legend(xy_h,legendstr,'Location','Best');

% Create figure for achieved speed along path
if ~exist('h3_sm_car_optim', 'var') || ...
        ~isgraphics(h3_sm_car_optim, 'figure')
    h3_sm_car_optim = figure('Name', 'sm_car_optim_xyv');
end
figure(h3_sm_car_optim)
clf(h3_sm_car_optim)

plot(optResStruct(end).xref,optResStruct(end).yref,'k--','DisplayName','Target Path');
title('Speed Along Track (Color Indicates Speed)');
axis equal
hold on;

colormap(h3_sm_car_optim,jet);

% Determine color range
max_spd = max([optResStruct(iter_max).vx; optResStruct(end).vx]);
min_spd = min([optResStruct(iter_max).vx; optResStruct(end).vx]);
spd_init = optResStruct(iter_max).vx;
spd_init(end) = max_spd;
spd_init(1)   = min_spd;
%spd_init = spd_init/max_spd;

spd_opt = optResStruct(iter_min).vx;
spd_opt(end) = max_spd;
spd_opt(1)   = min_spd;
%spd_opt = spd_opt/max_spd;

vx_h(1) = surface(...
    [optResStruct(iter_max).x'; optResStruct(iter_max).x'],...
    [optResStruct(iter_max).y'; optResStruct(iter_max).y'],...
    [zeros(size(optResStruct(iter_max).y')); zeros(size(optResStruct(iter_max).y'))],...
    [spd_init'; spd_init'],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',3,'DisplayName','Initial');
hold on
vx_h(2) = surface(...
    [optResStruct(iter_min).x'; optResStruct(iter_min).x'],...
    [optResStruct(iter_min).y'; optResStruct(iter_min).y'],...
    [zeros(size(optResStruct(iter_min).y')); zeros(size(optResStruct(iter_min).y'))],...
    [spd_opt'; spd_opt'],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2,'DisplayName','Optimized');
hold off

c=colorbar;
c.Label.String = 'Vehicle Speed (m/s)';

legend('Location','NorthEast');

% Create figure for achieved speed along path
if ~exist('h4_sm_car_optim', 'var') || ...
        ~isgraphics(h4_sm_car_optim, 'figure')
    h4_sm_car_optim = figure('Name', 'sm_car_optim_vx_init_opt');
end
figure(h4_sm_car_optim)
clf(h4_sm_car_optim)

subplot(211)
plot(optResStruct(iter_max).xpath.Data,optResStruct(iter_max).vx,'DisplayName','Initial');
hold on
plot(optResStruct(iter_min).xpath.Data,optResStruct(iter_min).vx,'DisplayName','Optimized');
hold off
legend('Location','Best');
xlabel('Track Distance (m)');
ylabel('Speed (m/s)');
title('Measured Speed along Track');
subplot(212)
plot(optResStruct(iter_max).xpath.Time,optResStruct(iter_max).xpath.Data,'DisplayName','Initial');
hold on
plot(optResStruct(iter_min).xpath.Time,optResStruct(iter_min).xpath.Data,'DisplayName','Optimized');
ylabel('Distance Along track (m)');
xlabel('Time (sec)');
title('Distance Along Track vs. Time');
end

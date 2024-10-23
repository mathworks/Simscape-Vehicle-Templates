% Code to plot simulation results from sm_viscoelastic_testrig
%% Plot Description:
%
% <enter plot description here if desired>
%
% Copyright 2016-2022 The MathWorks, Inc.

% Generate simulation results if they don't exist
%if ~exist('simlog_sm_viscoelastic_testrig', 'var')
x0_spr1 = 0;
out = sim(bdroot);
logsout_sm_viscoelastic_testrig = out.get('logsout_sm_viscoelastic_testrig');
%end

% Reuse figure if it exists, else create new figure
if ~exist('h1_sm_viscoelastic_testrig', 'var') || ...
        ~isgraphics(h1_sm_viscoelastic_testrig, 'figure')
    h1_sm_viscoelastic_testrig = figure('Name', 'sm_viscoelastic_testrig');
end
figure(h1_sm_viscoelastic_testrig)
clf(h1_sm_viscoelastic_testrig)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_x = logsout_sm_viscoelastic_testrig.get('Compression');
simlog_f = logsout_sm_viscoelastic_testrig.get('Force');

% Plot results
%simlog_handles(1) = subplot(2, 1, 1);
plot(simlog_x.Values.Data, simlog_f.Values.Data, 'LineWidth', 1)
hold on
plot(bushing_test_data.staticX.data.disp,bushing_test_data.staticX.data.force, 'LineWidth', 1)
hold off
grid on
title('Disp vs. Force')
ylabel('Force (N)')
legend({'Simulation','Measured'},'Location','Best');

xlabel('Displacement (mm)')

%linkaxes(simlog_handles, 'x')

% Remove temporary variables
clear simlog_t simlog_handles
clear simlog_R1i simlog_C1v temp_colororder


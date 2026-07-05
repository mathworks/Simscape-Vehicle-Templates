function ax_h = sm_car_plot_bushings(bushRes,varargin)
%sm_car_plot_bushings  Plot bushing simulation results from sm_car simulations
%   ax_h = sm_car_plot_bushings(bushRes,varargin)
%   This function plots requested simulation results from bushings.  Use
%   sm_car_sim_res_bushings() to extract the results to a specific data
%   structure.  The arguments passed to this function govern which
%   bushings' variables will be plotted.  If the argument is empty, all
%   elements of that item (suspension, bushing, variable) will be plotted.
%
%      bushRes      Bushing data extracted by sm_car_sim_res_bushings()
%      suspName     Field names in bushRes corresponding to suspension
%                      Lowest level field, 'A1_L', 'A2_R', 'A2', ...
%      plotBush     Field names in bushRes corresponding to bushing.
%                      Second level field, 'LAf', 'UArO', 'MntL', ...
%      plotVars     Field names in bushRes corresponding to quantity.
%                      Third level field, 'fx', 'ty', 'px', 'wz', ...
%      ax_h         Axis handle where results will be plotted
%                      New figure is created if handle not passed.

% List of units - assumes setting in model correspond to this list
% First letter is variable ('px' -> 'p' for position, ...)
unitsTable = {...
    'p','mm';
    'v','m/s';
    'q','deg';
    'w','deg/s';
    'f','N';
    't','N*m';
    };

% Assume request is for all quantities
plotAllSusp = true;
plotAllBush = true;
plotAllVars = true;

if(nargin>1) 
    suspName = varargin{1};
    % If 1st argument is not empty, plot only values from requested suspension
    if(~isempty(suspName)), plotAllSusp = false; end
end
if(nargin>2)
    plotBush = varargin{2}; 
    % If 2nd argument is not empty, plot only values from requested bushing
    if(~isempty(plotBush)), plotAllBush = false; end
end
if(nargin>3)
    plotVars = varargin{3};
    % If 3rd argument is not empty, plot only requested variables
    if(~isempty(plotVars)), plotAllVars = false; end
end
if(nargin>4)  % If 4th argument provided, plot on that axis
    ax_h =  varargin{4};
else          % else create new figure
    figure
    ax_h = gca;
end

% To avoid complex logic, plot all requested quantities on same plot
% even if the units are not the same.  Collect all units in y-axis label
% Variables that will hold y-axis label 
yAxisLabel = [];
% List of unit indices already in label
unitsTableIndList = [];

if(plotAllSusp)
    % Get all suspension field names if needed.
    suspName = fieldnames(bushRes);
end

% Ensure even a single suspension name is a cell array
if ischar(suspName), suspName = {suspName}; end

% Loop over suspension fields
for s_i = 1:length(suspName)

    % Check that requested suspension is present in results
    suspCheck = isfield(bushRes,(suspName{s_i}));
    if(suspCheck)

        if(plotAllBush)
            % Get all suspension field names if needed.
            plotBush = fieldnames(bushRes.(suspName{s_i}));
            % Remove 'Time' field, not a bushing
            plotBush = setdiff(plotBush,'Time');
        end

        % Ensure even a bushing list with one entry is a cell array
        if ischar(plotBush), plotBush = {plotBush};end

        % Loop over bushing fields
        for b_i = 1:length(plotBush)

            % Check that requested bushing is present in results
            bushCheck = isfield(bushRes.(suspName{s_i}),plotBush{b_i});
            if(bushCheck)

                if(plotAllVars)
                    % Get all suspension field names if needed.
                    plotVars = fieldnames(bushRes.(suspName{s_i}).(plotBush{b_i}));
                    % Remove 'Name' field, not a bushing
                    plotVars = setdiff(plotVars,'Name');
                end

                % Ensure even a variable list with one entry is a cell array
                if ischar(plotVars), plotVars = {plotVars};end

                % Loop over variable fields
                for v_i = 1:length(plotVars)

                    % Check that requested variable is present in results
                    varsCheck = isfield(bushRes.(suspName{s_i}).(plotBush{b_i}),plotVars{v_i});
                    if(varsCheck)

                        % Create name for legend, string for bushing name
                        bushName = char(bushRes.(suspName{s_i}).(plotBush{b_i}).Name);
                        legstr = strrep([suspName{s_i} ', ' bushName ', ' plotVars{v_i}],'_','\_');

                        % Plot results
                        plot(ax_h,bushRes.(suspName{s_i}).Time,...
                            squeeze(bushRes.(suspName{s_i}).(plotBush{b_i}).(plotVars{v_i})),...
                            'DisplayName',legstr);
                        hold(ax_h,'on');

                        % Find units string - assumes units in model match table above
                        unitsChar = plotVars{v_i}(1);
                        unitsTableInd = find(strcmp(unitsTable(:,1),unitsChar));
                        newUnitsStr   = unitsTable{unitsTableInd,2};

                        if(isempty(unitsTableIndList))
                            % If new units type, add to y-axis label
                            yAxisLabel = newUnitsStr;
                            unitsTableIndList = unitsTableInd;
                        elseif(~ismember(unitsTableInd,unitsTableIndList))
                            % Else append string to label
                            yAxisLabel = [yAxisLabel '   ||   ' newUnitsStr];
                            unitsTableIndList = [unitsTableIndList unitsTableInd];
                        end
                    else
                        disp(['Requested bushing string '  plotVars{v_i} ' not valid']);
                    end
                end
            else
                disp(['Requested bushing string '  plotBush{b_i} ' not valid']);
            end
        end
    else
        disp(['Requested suspension string '  suspName{s_i} ' not valid']);
    end
end

% Finish settings for plot
hold(ax_h,'off');
legend(ax_h,'Location','Best')
grid(ax_h,'on');
xlabel(ax_h,'Time (s)')
ylabel(ax_h,yAxisLabel)
title(ax_h,'Bushing Measurements')


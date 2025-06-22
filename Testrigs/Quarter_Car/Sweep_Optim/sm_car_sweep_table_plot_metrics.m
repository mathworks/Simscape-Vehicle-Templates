function [SweepSummaryTable, ax_h] = sm_car_sweep_table_plot_metrics(par_list,SweepSummaryStruct,metricForTable,varargin)
% sm_car_sweep_table_plot_metrics  Create table and plot summarizing sweep results
%    SweepSummaryTable = sm_car_sweep_summary_table_plot(par_list,SweepSummaryStruct,metricForTable,varargin)
%    This function generates a table summarizing the results of a parameter
%    sweep.  The table lists the input parameters and the value of the
%    requested performance metric. If the sweep varies the values of two
%    parameters a surface plot is generated.
%
%       par_list             Parameters whose values were swept.
%                             Structure with values and fields for setting 
%                             value within Vehicle data structure
%       SweepSummaryStruct  Array of structures with sweep results
%       metricForTable      Metric for table
%       fig_h               Optional input - figure handle for plot
%
%    The output is a table showing input parameters and the value of the
%    requested performance metric. If only two parameters are varied, a
%    surface plot of the requested performance metric is created.
%
%

if(nargin==4)
    fig_h = varargin{1};
else
    fig_h = [];
end

%% Create table of results 

% Assemble names for summary table 
metricFieldName = strrep(metricForTable,' ','_');
unitsFieldName = [char(metricFieldName) 'Units'];
UnitsString = SweepSummaryStruct(1).(unitsFieldName);

% Extract field names from structure
fnames = fieldnames(SweepSummaryStruct);

% Get list of parameters names
parfNames = fnames(startsWith(fnames,'par_'));

% Put metric and units at end of list
parfNames{end+1} = char(metricFieldName);
parfNames{end+1} = char(unitsFieldName);
    
% Convert structure to table
SweepSummaryTable = struct2table(SweepSummaryStruct);

% Reorder table with parameters at start
SweepSummaryTable = SweepSummaryTable(:,parfNames);

%% If 2D sweep, plot surface
if (length(par_list) == 2)
    % Add short name to par_list
    par_list = sm_car_param_short_name(par_list);

    [vHP1, vHP2] = meshgrid(par_list(1).valueSet,par_list(2).valueSet);

    numVals  = zeros(1,length(par_list));
    for hp_i = 1:length(par_list)
        numVals(hp_i) = length(par_list(hp_i).valueSet);
    end
    valCombs = generateCombinations(numVals);

    metricFieldName = strrep(metricForTable,' ','_');
    surf_BumpSteer = zeros(length(par_list(2).valueSet),length(par_list(1).valueSet));
    for i = 1:length(SweepSummaryStruct)
        surf_BumpSteer(valCombs(i,2),valCombs(i,1)) = SweepSummaryStruct(i).(metricFieldName);
    end

    if(isempty(fig_h))
        fig_handle_name =   'h2_testrig_quarter_car_sweep';

        handle_var = evalin('base',['who(''' fig_handle_name ''')']);
        if(isempty(handle_var))
            evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
        elseif ~isgraphics(evalin('base',handle_var{:}))
            evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
        end
        figure(evalin('base',fig_handle_name))
        clf
        ax_h = gca;
    else
        ax_h = fig_h;
    end

    surf(ax_h,vHP1, vHP2, surf_BumpSteer, 'FaceAlpha',0.3,'DisplayName','Response Surface')
    hold on
    [VH1e, vHP2e] = meshgrid(par_list(1).valueSet([1 end]),par_list(2).valueSet([1 end]));

    for i = 1:length(SweepSummaryStruct)
        testPtsX(i) = par_list(1).valueSet(valCombs(i,1));
        testPtsY(i) = par_list(2).valueSet(valCombs(i,2));
        testPtsZ(i) = SweepSummaryStruct(i).(metricFieldName);
    end
    plot3(ax_h,testPtsX,testPtsY,testPtsZ,'bo','DisplayName','Test Points')
    hold on

    box on
    title(ax_h,['Hardpoint Locations vs. ' metricForTable ])
    xlh = xlabel(ax_h,par_list(1).name);
    ylh = ylabel(ax_h,par_list(2).name);
    zlabel(ax_h,[char(metricForTable) ' (' char(UnitsString) ')']);
    hold off
else
    ax_h = [];
end


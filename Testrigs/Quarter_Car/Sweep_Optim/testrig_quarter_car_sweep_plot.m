function TSuspMetricsReq = testrig_quarter_car_sweep_plot(hp_list,TSuspMetricsSet,metricFor2DPlot)

%% Create table of results for 2D sweep

metricFieldName = strrep(metricFor2DPlot,' ','_');
unitsFieldName = [char(metricFieldName) 'Units'];
UnitsString = TSuspMetricsSet(1).(unitsFieldName);

fnames = fieldnames(TSuspMetricsSet);

parfNames = fnames(startsWith(fnames,'par_'));

parfNames{end+1} = char(metricFieldName);
parfNames{end+1} = char(unitsFieldName);
    

TSuspMetricsSet_struct = struct2table(TSuspMetricsSet);

TSuspMetricsReq = TSuspMetricsSet_struct(:,parfNames);

%% If 2D sweep, plot surface
if (length(hp_list) == 2)
    [vHP1, vHP2] = meshgrid(hp_list(1).valueSet,hp_list(2).valueSet);

    numVals  = zeros(1,length(hp_list));
    for hp_i = 1:length(hp_list)
        numVals(hp_i) = length(hp_list(hp_i).valueSet);
    end
    valCombs = generateCombinations(numVals);

    metricFieldName = strrep(metricFor2DPlot,' ','_');
    surf_BumpSteer = zeros(length(hp_list(2).valueSet),length(hp_list(1).valueSet));
    for i = 1:length(TSuspMetricsSet)
        surf_BumpSteer(valCombs(i,2),valCombs(i,1)) = TSuspMetricsSet(i).(metricFieldName);
    end

    fig_handle_name =   'h2_testrig_quarter_car_sweep';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf

    surf(vHP1, vHP2, surf_BumpSteer)
    hold on
    [VH1e, vHP2e] = meshgrid(hp_list(1).valueSet([1 end]),hp_list(2).valueSet([1 end]));
    zeroSurf = zeros(2);
    surf(VH1e, vHP2e, zeroSurf,'FaceColor',[0.5 0.5 0.5], 'FaceAlpha',0.3)

    for i = 1:length(TSuspMetricsSet)
        plot3(hp_list(1).valueSet(valCombs(i,1)),hp_list(2).valueSet(valCombs(i,2)),TSuspMetricsSet(i).(metricFieldName),'bo')
        hold on
    end

    box on
    title(['Hardpoint Locations vs. ' metricFor2DPlot ])
    xlh = xlabel([hp_list(1).part '.' hp_list(1).point '(' num2str(hp_list(1).index) ')']);
    ylh = ylabel([hp_list(2).part '.' hp_list(2).point '(' num2str(hp_list(2).index) ')']);

    zlabel([char(metricFor2DPlot) ' (' char(UnitsString) ')']);
    hold off
end


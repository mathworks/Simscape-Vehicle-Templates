% Script to test many configurations of vehicle model
% Only verifies that variants result in a valid vehicle configuration and
% that variants are selected before Update Diagram

% Load Vehicle presets
cd(fileparts(which('Vehicle_000.mat')));
veh_data_sets = dir('Vehicle*.mat');
for vds_i=1:length(veh_data_sets)
    load(veh_data_sets(vds_i).name)
end
clear veh_data_sets vds_i

% Move to folder with this script
cd(fileparts(which('sm_car_test_configs.m')));
mdl = 'sm_car';

% Open and configure model for quick tests
open_system(mdl);
set_param([mdl '/Camera Frames'],'Commented','on');
set_param(mdl,'SimMechanicsOpenEditorOnUpdate','off');
sm_car_config_road(mdl,'Floor and Grid')
sm_car_config_maneuver(mdl,'WOT Braking');

% If output data is needed - commented out for now
%clear sm_car_res
%now_string = datestr(now,'yymmdd_HHMM');
%num_config = size(whos('-regexp','Vehicle_[0-9].*'),1);
%results_foldername = [mdl '_' now_string];
%mkdir(results_foldername)

% Set folder and filename for diary file where diagnostics will be saved
% sldiagviewer records diagnostics to diary file
% diary('on') is not sufficient for this test
sldiagviewer.diary([pwd filesep 'diary.txt'])

% Loop through configurations
for veh_i = 0:(num_config-1)
    % Disable warnings that come from Delft-Tyre
    warning('off','Simulink:blocks:AssumingDefaultSimStateForSFcn');
    warning('off','Simulink:blocks:AssumingDefaultSimStateForL2MSFcn');
    warning('off','physmod:common:gl:sli:rtp:InvalidNonValueReferenceMask');
    
    % Clear diary
    sldiagviewer.diary('off')
    if (~isempty(which('diary.txt'))), delete('diary.txt'), end
    
    % Configure vehicle data and display to command window
    veh_suffix = pad(num2str(veh_i),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    disp(['Test Vehicle_' num2str(veh_suffix) ' ' Vehicle.config '****']);
    
    % Assume we will succeed, and turn diary on
    Test_Result = 'success';
    sldiagviewer.diary('on')
    try
        % Configure vehicle
        sm_car_config_vehicle(mdl)
        % Run model to generate error during initialization
        set_param(mdl,'SimulationCommand','Start','StopTime','0.0001');
        while(~strcmp(get_param(bdroot,'SimulationStatus'),'stopped'))
            % Wait for update (and run if successful) to complete
            pause(2)
        end
    catch
        % Flag that something failed
        % This alone does not indicate variant configuration failed
        Test_Result = 'fail';
    end
    sldiagviewer.diary('off');
    
    % Read diagnostics to highlight error in command window
    if(~isempty(which('diary.txt')))
        fid_o = fopen('diary.txt');
        u=fscanf(fid_o,'%s');
        fclose(fid_o);
    else
        u = 'none';
    end
    
    % If u is empty or no "Warning" or "Error" string in diagnostics
    if(isempty(u) ||(~contains(u,'Warning') && ~contains(u,'Error')))
        % Delete generated diary file
        disp(['Test Vehicle_' num2str(veh_suffix) ': No errors or warnings']);
        delete('diary.txt');
    else
        % Else, copy diagnostic results to appropriately named file
        Test_Result = 'fail';
        vehDiagFileName = ['Vehicle_' veh_suffix '_diag.txt'];
        movefile(which('diary.txt'),[pwd filesep vehDiagFileName])
        dispstr2 = ['<a href="matlab:edit(''' vehDiagFileName ''');">diagnostics</a>'];
        % Display message and hyperlink to MATLAB window.
        disp(['Vehicle_' veh_suffix ': Warnings or errors (edit ' dispstr2 ')']);
    end
end


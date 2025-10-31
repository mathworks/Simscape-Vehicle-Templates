function sm_car_config_road(modelname,scenename)
%sm_car_config_road  Configure road surface for Simscape Vehicle Model
%   sm_car_config_road(modelname,tirename)
%   This function configures the model to have a specified surface.
%
% Copyright 2018-2025 The MathWorks, Inc.

% Find variant subsystems for inputs
f=Simulink.FindOptions('LookUnderMasks','all');
mu_scaling_h=Simulink.findBlocks(modelname,'Name','Mu Scaling by Position',f);

f=Simulink.FindOptions('LookUnderMasks','all','regexp',1);
scene_config_h=Simulink.findBlocks(modelname,'SceneDesc','.*',f);

if(~isempty(scene_config_h))
    set_param(scene_config_h,'SceneDesc','Double lane change');
end

% Set vehicle data to have flat road
Vehicle = evalin('base','Vehicle');
roadFile  = 'which(''TNO_FlatRoad.rdf'')';
assignin('base','Vehicle',Vehicle);

%VDatabase = evalin('base','VDatabase');
%trailer_var = get_param([modelname '/Vehicle/Trailer/Trailer'],'Vehicle');
%Trailer = evalin('base',trailer_var);

% Find fieldnames for tires
chassis_fnames = fieldnames(Vehicle.Chassis);
fname_inds_tire = startsWith(chassis_fnames,'Tire');
tireFields = chassis_fnames(fname_inds_tire);
tireFields = sort(tireFields); % Order important for copying Body sAxle values

% Loop over tire field names (by axle)
for axle_i = 1:length(tireFields)
    tireField = tireFields{axle_i};
    % Get tire class and settings
    if(~strcmp(Vehicle.Chassis.(tireField).class.Value,'Tire2x'))
        % For Road Surface
        tirClass{axle_i} = Vehicle.Chassis.(tireField).class.Value; %#ok<*AGROW>
        tir_diag_str{axle_i} = ['Vehicle.Chassis.' tireField  '.class.Value'];
        % For Testrig Post
        tirInst{axle_i}  = Vehicle.Chassis.(tireField).Instance;
        tirBody{axle_i}  = Vehicle.Chassis.(tireField).TireBody;
    else
        % For Road Surface - Assumes TireInner and TireOuter are the same
        tirClass{axle_i} = Vehicle.Chassis.(tireField).TireInner.class.Value;
        tir_diag_str{axle_i} = ['Vehicle.Chassis.' tireField  '.TireInner.class.Value'];
        % For Testrig Post
        tirInst{axle_i}      = Vehicle.Chassis.(tireField).TireInner.Instance;
        tirBody_Inn{axle_i}  = Vehicle.Chassis.(tireField).TireInner.TireBody;
        tirBody_Out{axle_i}  = Vehicle.Chassis.(tireField).TireOuter.TireBody;
    end
end

% Construct diagnostic string for Vehicle tires
tire_diag_str_fmt = [];
for axle_i = 1:length(tireFields)
    if(axle_i>1)
        tire_diag_str_fmt = [tire_diag_str_fmt '\n'];
    end
    tire_diag_str_fmt = [tire_diag_str_fmt '** ''' tir_diag_str{axle_i} ''' is ''' tirClass{axle_i} ''];
end

% Get Trailer tire class and settings
% For Road Surface
trailer_type = sm_car_vehcfg_getTrailerType(modelname);
if(strcmpi(trailer_type,'none'))
    % For Road Surface
    tirClassTr = 'None';
    tireFieldsTr = '';
    %tr_diag_strTr = '<no trailer>';
    %tirInstTr = '<no trailer>';
else
    % Find fieldnames for tires
    chassis_fnamesTr = fieldnames(Trailer.Chassis);
    fname_inds_tireTr = startsWith(chassis_fnamesTr,'Tire');
    tireFieldsTr = chassis_fnamesTr(fname_inds_tireTr);
    tireFieldsTr = sort(tireFieldsTr); % Order important for copying Body sAxle values

    for axle_i = 1:length(tireFieldsTr)
        tireField = tireFieldsTr{axle_i};
        % Get tire class and settings
        if(~strcmp(Trailer.Chassis.(tireField).class.Value,'Tire2x'))
            % For Road Surface
            tirClassTr{axle_i} = Trailer.Chassis.(tireField).class.Value;
            tir_diag_strTr{axle_i} = ['Trailer.Chassis.' tireField  '.class.Value'];
            % For Testrig Post
            %tirInstTr{axle_i}  = Trailer.Chassis.(tireField).Instance;
            %tirBodyTr{axle_i}  = Trailer.Chassis.(tireField).TireBody;
        else
            % For Road Surface - Assumes TireInner and TireOuter are the same
            tirClassTr{axle_i} = Trailer.Chassis.(tireField).TireInner.class.Value;
            tir_diag_strTr{axle_i} = ['Vehicle.Chassis.' tireField  '.TireInner.class.Value'];
            % For Testrig Post
            %tirInstTr{axle_i}      = Trailer.Chassis.(tireField).TireInner.Instance;
            %tirBody_InnTr{axle_i}  = Trailer.Chassis.(tireField).TireInner.TireBody;
            %tirBody_OutTr{axle_i}  = Trailer.Chassis.(tireField).TireInner.TireBody;
        end
    end
end

% Construct diagnostic string for Vehicle tires
tireTr_diag_str_fmt = [];
if(~strcmpi(tirClassTr,'none'))
    for axleTr_i = 1:length(tireFieldsTr)
        if(axleTr_i>1)
            tireTr_diag_str_fmt = [tireTr_diag_str_fmt '\n'];
        end
        tireTr_diag_str_fmt = [tireTr_diag_str_fmt '** ''' tir_diag_strTr{axleTr_i} ''' is ''' tirClassTr{axleTr_i} ''];
    end
else
    tireTr_diag_str_fmt = '';
end


% Default contact method
tirecontact_opt = 'smooth';
%tireClasses = {tirClassF tirClassR tirClassFTr};

% Do not permit trailer on 4 post testrig
if((strcmpi(scenename,'testrig 4 post') || strcmpi(scenename,'knc'))&& ~strcmpi(trailer_type,'none'))
    error_str = sprintf('%s',...
        'Disable the trailer when running on 4 post testrig');
    errordlg(error_str,'No Trailer on Testrig')
end

% Ensure proper tire model used on testrig
if((~strcmpi(scenename,'testrig 4 post') && ~strcmpi(scenename,'knc')) && sum(contains(tirClass,'Testrig')))
    error_str = sprintf(['Configure tire model to use anything other than ''Testrig_Post'' which only has vertical stiffness.\n' ...
        tire_diag_str_fmt '\n'...
        '--> Values should not include ''Testrig_Post''']);
    errordlg(error_str,'Wrong Tire Model')
end

% Set ground to have high friction everywhere
set_param(mu_scaling_h,'muFL_in','1','muFR_in','1','muRL_in','1','muRR_in','1')

% Specific checks for combinations
% Non-flat CRG files

if(verLessThan('matlab','9.12'))
    checkNonFlatCRG = sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval') contains(tirClass,'MFMbody') contains(tirClassTr,'MFMbody')]);
    messgNonFlatCRG1 = 'Configure model to use Delft Tire or MF-Swift software for this maneuver.';
    messgNonFlatCRG2 = '--> All values for active components should be ''Delft'' or ''MFSwift''';
else
    checkNonFlatCRG = sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval')]);
    messgNonFlatCRG1 = 'Configure model to use Delft Tire, MF-Swift, or Simscape  for this maneuver.';
    messgNonFlatCRG2 = '--> All values for active components should be ''Delft'', ''MFSwift'', or ''Simscape''';
end

if(verLessThan('matlab','9.14'))
    checkGridSurface = 1;
    messgGridSurface1 = 'Grid Surface events cannot be used in this release of MATLAB';
    messgGridSurface2 = '--> Please select another maneuver.';
else
    checkGridSurface = sum([contains(tirClass,'MFEval') contains(tirClass,'MFSwift') contains(tirClassTr,'MFSwift')  contains(tirClassTr,'Delft')]);
    messgGridSurface1 = 'Configure model to use Simscape  for this maneuver.';
    messgGridSurface2 = '--> All values for active components should be ''Simscape''';
end

% Switch based on requested road surface
switch lower(scenename)
    case 'plane grid'
        % No special commands
    case 'ice patch'
        set_param(mu_scaling_h,'muFL_in','0.4','muFR_in','0.4','muRL_in','0.4','muRR_in','0.4');
        if(sum(contains(tirClass,'MFSwift')))
            % Mask in Tire_MFSwift sets road type based on filename
            % Must contain "external" to change to external road definition
            roadFile = 'which(''<External Road>'')';
        end
        if(sum([contains(tirClass,'MFMbody') contains(tirClassTr,'MFMbody')]))
            error_str = sprintf(['Simscape Multibody tire cannot be used for this maneuver.\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                '--> All values for active components CANNOT be ''MFMbody''']);
            errordlg(error_str,'Wrong Tire Software')
        end

    case 'crg hockenheim'
        
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file
        roadFile = 'which(''CRG_Hockenheim.crg'')';

        set_param(modelname,'StopTime','261')

    case 'crg hockenheim f'
        if(~sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval')]))
            % Set file flat road for MF-Swift
            roadFile  = 'which(''TNO_FlatRoad.rdf'')';
        end

        set_param(modelname,'StopTime','261')

    case 'crg kyalami'
        
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file
        roadFile = 'which(''CRG_Kyalami.crg'')';

        set_param(modelname,'StopTime','261')

    case 'crg kyalami f'
        if(~sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval')]))
            % Set file flat road for MF-Swift
            roadFile  = 'which(''TNO_FlatRoad.rdf'')';
        end

        set_param(modelname,'StopTime','261')

    case 'crg mallory park'
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file
        roadFile = 'which(''CRG_Mallory_Park.crg'')';

        set_param(modelname,'StopTime','200')

    case 'crg mallory park f'
        if(~sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval')]))
            % Set file flat road for MF-Swift
            roadFile  = 'which(''TNO_FlatRoad.rdf'')';
        end

        set_param(modelname,'StopTime','200')

    case 'crg custom'
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file
        roadFile = 'which(''CRG_Custom.crg'')';

        set_param(modelname,'StopTime','200')

    case 'crg custom f'
        if(~sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval')]))
            % Set file flat road for MF-Swift
            roadFile  = 'which(''TNO_FlatRoad.rdf'')';
        end

        set_param(modelname,'StopTime','200')

    case 'crg nurburgring n'
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file
        roadFile = 'which(''CRG_Nurburgring_N.crg'')';

    case 'crg nurburgring n f'
        if(~sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval')]))
            % Set file flat road for MF-Swift
            roadFile  = 'which(''TNO_FlatRoad.rdf'')';
        end

    case 'crg pikes peak'
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file
        roadFile = 'which(''CRG_Pikes_Peak.crg'')';

    case 'gs uneven road'
        if(checkGridSurface)
            error_str = sprintf([messgGridSurface1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgGridSurface2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select STL file
        roadFile = 'GS_Uneven_Road.stl';

    case 'crg suzuka'
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file
        roadFile = 'which(''CRG_Suzuka.crg'')';

    case 'crg suzuka f'
        if(~sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval')]))
            % Select CRG file
            roadFile  = 'which(''TNO_FlatRoad.rdf'')';
        end

    case 'rdf rough road'
        if(sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval') ...
                contains(tirClass,'MFSwift') contains(tirClassTr,'MFSwift') ...
                contains(tirClass,'MFMbody') contains(tirClassTr,'MFMbody')]))
            error_str = sprintf(['Configure model to use Delft Tire software only for this maneuver.\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                '--> All values for active components should be ''Delft''']);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select RDF file for rough road
        roadFile = 'which(''Rough_Road.rdf'')';

        % Set stop time to stop at end of road
        set_param(modelname,'StopTime','30')

    case 'rdf plateau'
        if(sum([contains(tirClass,'MFEval') contains(tirClassTr,'MFEval') ...
                contains(tirClass,'MFSwift') contains(tirClassTr,'MFSwift') ...
                contains(tirClass,'MFMbody') contains(tirClassTr,'MFMbody')]))
            error_str = sprintf(['Configure model to use Delft Tire software only for this maneuver.\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                '--> All values for active components should be ''Delft''']);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select RDF file for rough road
        roadFile = 'which(''Plateau_Road.rdf'')';

        % Set stop time to stop at end of road
        set_param(modelname,'StopTime','30')

    case 'plateau z only'
        if(sum(contains(tirClass,'MFSwift')))
            % Mask in Tire_MFSwift sets road type based on filename
            % Must contain "external" to change to external road definition
            roadFile = 'which(''<External Road>'')';
        end
        if(sum(contains(tirClass,'Delft')))
            % Necessary to change contact method of Delft Tyre software
            tirecontact_opt = 'moving';
        end
        if(sum([contains(tirClass,'MFMbody') contains(tirClassTr,'MFMbody')]))
            error_str = sprintf(['Simscape Multibody tire cannot be used for this maneuver.\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                '--> All values for active components CANNOT be ''MFMbody''']);
            errordlg(error_str,'Wrong Tire Software')
        end

    case 'crg plateau'
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file for slope
        roadFile = 'which(''CRG_Plateau.crg'')';

    case 'rough road z only'
        if(sum(contains(tirClass,'MFSwift')))
            % Mask in Tire_MFSwift sets road type based on filename
            % Must contain "external" to change to external road definition
            roadFile = 'which(''<External Road>'')';
        end
        if(sum(contains(tirClass,'Delft')))
            % Necessary to change contact method of Delft Tyre software
            tirecontact_opt = 'moving';
        end
        if(sum([contains(tirClass,'MFMbody') contains(tirClassTr,'MFMbody')]))
            error_str = sprintf(['Simscape Multibody tire cannot be used for this maneuver.\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                '--> All values for active components CANNOT be ''MFMbody''']);
            errordlg(error_str,'Wrong Tire Software')
        end

    case 'crg rough road'
        if(checkNonFlatCRG)
            error_str = sprintf([messgNonFlatCRG1 '\n' ...
                tire_diag_str_fmt '\n'...
                tireTr_diag_str_fmt '\n'...
                messgNonFlatCRG2]);
            errordlg(error_str,'Wrong Tire Software')
        end

        % Select CRG file for slope
        roadFile = 'which(''CRG_Rough_Road.crg'')';

    case 'track mallory park'
        % No special commands
    case 'two lane road'
        % No special commands
    case 'double lane change'
        % No special commands
    case 'mcity'
        % Unreal scene
        if(~isempty(scene_config_h))
            if(~verLessThan('matlab','9.6'))
                set_param(scene_config_h,'SceneDesc','Virtual Mcity');
            end
        end
    case {'testrig 4 post', 'knc'}
        % Set tire model
        % -- Extract size from Instance
        % -- Get comparable field from VDatabase
        % -- Fill in Tire Body from original Vehicle structure

        % Front
        for axle_i = 1:length(tireFields)
            tireField = tireFields{axle_i};
            tire_size = tirInst{axle_i}(end-8:end);                % Size
            tirInst_testrig = ['Testrig_Post_' tire_size]; % New Instance
            if(~strcmp(Vehicle.Chassis.(tireField).class.Value,'Tire2x'))
                Vehicle.Chassis.(tireField) = VDatabase.Tire.(tirInst_testrig);
                Vehicle.Chassis.(tireField).TireBody = tirBody{axle_i};
                if(strcmpi(scenename,'knc'))
                    % Set stiffness value so that tire compliance 
                    % is not modeled on post
                    Vehicle.Chassis.(tireField).K.Value = 0;
                end
            else
                Vehicle.Chassis.(tireField).TireInner = VDatabase.Tire.(tirInst_testrig);
                Vehicle.Chassis.(tireField).TireOuter = VDatabase.Tire.(tirInst_testrig);
                Vehicle.Chassis.(tireField).TireInner.TireBody = tirBody_Inn{axle_i};
                Vehicle.Chassis.(tireField).TireOuter.TireBody = tirBody_Out{axle_i};
                if(strcmpi(scenename,'knc'))
                    % Set stiffness value so that tire compliance 
                    % is not modeled on post
                    Vehicle.Chassis.(tireField).TireInner.K.Value = 0;
                    Vehicle.Chassis.(tireField).TireOuter.K.Value = 0;
                end
            end
        end

end

if(strcmpi(scenename,'KnC'))
    set_param([modelname '/World'],'popup_scene','Testrig 4 Post');
else
    set_param([modelname '/World'],'popup_scene',scenename);
end

% Set road file for all tires
% Vehicle
for axle_i = 1:length(tireFields)
    tireField = tireFields{axle_i};

    if(~strcmp(Vehicle.Chassis.(tireField).class.Value,'Tire2x'))
        Vehicle.Chassis.(tireField).roadFile.Value = roadFile;
    else
        % Assumes TireInner and TireOuter are the same
        Vehicle.Chassis.(tireField).TireInner.roadFile.Value = roadFile;
        Vehicle.Chassis.(tireField).TireOuter.roadFile.Value = roadFile;
    end
end

% Trailer
for axleTr_i = 1:length(tireFieldsTr)
    tireField = tireFields{axleTr_i};
    if(~strcmp(Trailer.Chassis.(tireField).class.Value,'Tire2x'))
        Trailer.Chassis.(tireField).roadFile.Value = roadFile;
    else
        % Assumes TireInner and TireOuter are the same
        Trailer.Chassis.(tireField).TireInner.roadFile.Value = roadFile;
        Trailer.Chassis.(tireField).TireOuter.roadFile.Value = roadFile;
    end
end

%% Contact setting necessary for Delft and MF-Swift software in some cases
% Adjusts it if road surface requires it
% ** Assumes front and rear have same tire model
% Vehicle
if(~strcmpi(tirClass{1},'mfeval') && ~strcmpi(tirClass{1},'mfmbody'))
    temp_config = Vehicle.config;
    for axle_i = 1:length(tireFields)
        tireField = tireFields{axle_i};
        Vehicle = sm_car_vehcfg_setTireContact(Vehicle,tirecontact_opt,tireField);
    end
    Vehicle.config = temp_config;
end

% Trailer
if(~strcmpi(trailer_type,'none') && ~strcmpi(tirClassTr{1},'mfeval')&& ~strcmpi(tirClassTr{1},'mfmbody'))
    % Contact setting necessary for Delft and MF-Swift software
    % Only adjust if trailer is active
    temp_config = Trailer.config;
    for axle_i = 1:length(tireFieldsTr)
        tireField = tireFields{axle_i};
        Trailer = sm_car_vehcfg_setTireContact(Trailer,tirecontact_opt,tireField);
    end
    Trailer.config = temp_config;
end

%% Assign results to workspace
assignin('base','Vehicle',Vehicle);
%assignin('base',trailer_var,Trailer);



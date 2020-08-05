function sm_car_config_road(modelname,scenename)
%sm_car_config_road  Configure road surface for Simscape Vehicle Model
%   sm_car_config_road(modelname,tirename)
%   This function configures the model to have a specified surface.
%
% Copyright 2018-2020 The MathWorks, Inc.

% Find variant subsystems for inputs
f=Simulink.FindOptions('LookUnderMasks','all');
mu_scaling_h=Simulink.findBlocks(modelname,'Name','Mu Scaling by Position',f);

% Set vehicle data to have flat road
Vehicle = evalin('base','Vehicle');
roadFileF  = 'which(''TNO_FlatRoad.rdf'')';
roadFileR  = 'which(''TNO_FlatRoad.rdf'')';
assignin('base','Vehicle',Vehicle);

VDatabase = evalin('base','VDatabase');
Trailer = evalin('base','Trailer');

% Get tire class and settings
if(~strcmp(Vehicle.Chassis.TireF.class.Value,'Tire2x'))
    % For Road Surface
    tirClassF = Vehicle.Chassis.TireF.class.Value;
    f_diag_str = 'Vehicle.Chassis.TireF.class.Value';
    % For Testrig Post
    tirInstF  = Vehicle.Chassis.TireF.Instance;
    tirBodyF  = Vehicle.Chassis.TireF.TireBody;
else
    % For Road Surface - Assumes TireInner and TireOuter are the same
    tirClassF = Vehicle.Chassis.TireF.TireInner.class.Value;
    f_diag_str = 'Vehicle.Chassis.TireF.TireInner.class.Value';
    % For Testrig Post
    tirInstF  = Vehicle.Chassis.TireF.TireInner.Instance;
    tirBodyF_Inn  = Vehicle.Chassis.TireF.TireInner.TireBody;
    tirBodyF_Out  = Vehicle.Chassis.TireF.TireInner.TireBody;
end

if(~strcmp(Vehicle.Chassis.TireR.class.Value,'Tire2x'))
    % For Road Surface
    tirClassR = Vehicle.Chassis.TireR.class.Value;
    r_diag_str = 'Vehicle.Chassis.TireR.class.Value';
    % For Testrig Post
    tirBodyR  = Vehicle.Chassis.TireR.TireBody;
    tirInstR  = Vehicle.Chassis.TireR.Instance;
else
    % For Road Surface - Assumes TireInner and TireOuter are the same
    tirClassR = Vehicle.Chassis.TireR.TireInner.class.Value;
    r_diag_str = 'Vehicle.Chassis.TireR.TireInner.class.Value';
    % For Testrig Post
    tirInstR  = Vehicle.Chassis.TireR.TireInner.Instance;
    tirBodyR_Inn  = Vehicle.Chassis.TireR.TireInner.TireBody;
    tirBodyR_Out  = Vehicle.Chassis.TireR.TireOuter.TireBody;
end

% Get Trailer tire class and settings
% For Road Surface
trailer_type = sm_car_vehcfg_getTrailerType(modelname);
if(strcmpi(trailer_type,'none'))
    % For Road Surface
    tirClassFTr = 'None';
    tr_diag_str = '<no trailer>';
else
    % For Road Surface
    tirClassFTr = Trailer.Chassis.TireF.class.Value;
    tr_diag_str = ['Trailer.Chassis.TireF.class.Value is ' tirClassFTr];
end

tireClasses = {tirClassF tirClassR tirClassFTr};

% Do not permit trailer on 4 post testrig
if(strcmpi(scenename,'testrig 4 post') && ~strcmpi(trailer_type,'none'))
    error_str = sprintf('%s',...
        'Disable the trailer when running on 4 post testrig');
    errordlg(error_str,'No Trailer on Testrig')
end

% Ensure proper tire model used on testrig
if((~strcmpi(scenename,'testrig 4 post')) && sum(contains(tireClasses(1:2),'Testrig')))
    error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
        'Configure tire model to use anything other than ''Testrig_Post'' which only has vertical stiffness.',...
        ['** ''' f_diag_str ''' is ' tirClassF ''''],...
        ['** ''' r_diag_str ''' is ' tirClassR ''''],...
        '--> Both values should not include ''Testrig_Post''');
    errordlg(error_str,'Wrong Tire Model')
end

% Set ground to have high friction everywhere
set_param(mu_scaling_h,'muFL_in','1','muFR_in','1','muRL_in','1','muRR_in','1')


% Switch based on requested road surface
switch lower(scenename)
    case 'plane grid'
        % No special commands
    case 'ice patch'
        set_param(mu_scaling_h,'muFL_in','0.4','muFR_in','0.4','muRL_in','0.4','muRR_in','0.4')
    case 'crg slope'
        if(sum(contains(tireClasses,'MFEval')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft'' or ''MFSwift''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select CRG file for slope
        roadFileF = 'which(''handmade_sloped.crg'')';
        roadFileR = 'which(''handmade_sloped.crg'')';
        
        % Set stop time to stop at top of hill
        set_param(modelname,'StopTime','10')
        
    case 'crg kyalami'
        if(sum(contains(tireClasses,'MFEval')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft'' or ''MFSwift''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select CRG file for slope
        roadFileF = 'which(''CRG_Kyalami.crg'')';
        roadFileR = 'which(''CRG_Kyalami.crg'')';
        
        set_param(modelname,'StopTime','261')
        
    case 'crg kyalami f'
        if(~sum(contains(tireClasses,'MFEval')))
            % Select CRG file for slope
            %roadFileF = 'which(''CRG_Mallory_Park_F.crg'')';
            %roadFileR = 'which(''CRG_Mallory_Park_F.crg'')';
            roadFileF  = 'which(''TNO_FlatRoad.rdf'')';
            roadFileR  = 'which(''TNO_FlatRoad.rdf'')';
        end
        
        set_param(modelname,'StopTime','261')
        
    case 'crg mallory park'
        if(sum(contains(tireClasses,'MFEval')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft'' or ''MFSwift''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select CRG file for slope
        roadFileF = 'which(''CRG_Mallory_Park.crg'')';
        roadFileR = 'which(''CRG_Mallory_Park.crg'')';
        
        set_param(modelname,'StopTime','200')
        
    case 'crg mallory park f'
        if(~sum(contains(tireClasses,'MFEval')))
            % Select CRG file for slope
            %roadFileF = 'which(''CRG_Mallory_Park_F.crg'')';
            %roadFileR = 'which(''CRG_Mallory_Park_F.crg'')';
            roadFileF  = 'which(''TNO_FlatRoad.rdf'')';
            roadFileR  = 'which(''TNO_FlatRoad.rdf'')';
        end
        
        set_param(modelname,'StopTime','200')
        
    case 'crg nurburgring n'
        if(sum(contains(tireClasses,'MFEval')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft'' or ''MFSwift''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select CRG file for slope
        roadFileF = 'which(''CRG_Nurburgring_N.crg'')';
        roadFileR = 'which(''CRG_Nurburgring_N.crg'')';
        
    case 'crg nurburgring n f'
        if(~sum(contains(tireClasses,'MFEval')))
            % Select CRG file for slope
            %roadFileF = 'which(''CRG_Nurburgring_N_F.crg'')';
            %roadFileR = 'which(''CRG_Nurburgring_N_F.crg'')';
            roadFileF  = 'which(''TNO_FlatRoad.rdf'')';
            roadFileR  = 'which(''TNO_FlatRoad.rdf'')';
        end
                
    case 'crg pikes peak'
        if(sum(contains(tireClasses,'MFEval')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft'' or ''MFSwift''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select CRG file for slope
        roadFileF = 'which(''CRG_Pikes_Peak.crg'')';
        roadFileR = 'which(''CRG_Pikes_Peak.crg'')';
        
    case 'crg suzuka'
        if(sum(contains(tireClasses,'MFEval')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft'' or ''MFSwift''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select CRG file for slope
        roadFileF = 'which(''CRG_Suzuka.crg'')';
        roadFileR = 'which(''CRG_Suzuka.crg'')';
        
    case 'crg suzuka f'
        if(~sum(contains(tireClasses,'MFEval')))
            % Select CRG file for slope
            %roadFileF = 'which(''CRG_Suzuka_F.crg'')';
            %roadFileR = 'which(''CRG_Suzuka_F.crg'')';
            roadFileF  = 'which(''TNO_FlatRoad.rdf'')';
            roadFileR  = 'which(''TNO_FlatRoad.rdf'')';
        end
                
    case 'rdf rough road'
        if(sum(contains(tireClasses,'MFEval')+contains(tireClasses,'MFSwift')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire software only for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select RDF file for rough road
        roadFileF = 'which(''Rough_Road.rdf'')';
        roadFileR = 'which(''Rough_Road.rdf'')';
        
        % Set stop time to stop at end of road
        set_param(modelname,'StopTime','30')
        
    case 'rdf plateau'
        if(sum(contains(tireClasses,'MFEval')+contains(tireClasses,'MFSwift')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire software only for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select RDF file for rough road
        roadFileF = 'which(''Plateau_Road.rdf'')';
        roadFileR = 'which(''Plateau_Road.rdf'')';
        
        % Set stop time to stop at end of road
        set_param(modelname,'StopTime','30')
        
    case 'plateau z only'
        if(sum(contains(tireClasses,'Delft')+contains(tireClasses,'MFSwift')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''MFEval''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
    case 'crg plateau'
        if(sum(contains(tireClasses,'MFEval')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''Delft'' or ''MFSwift''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
        % Select CRG file for slope
        roadFileF = 'which(''CRG_Plateau.crg'')';
        roadFileR = 'which(''CRG_Plateau.crg'')';
        
    case 'rough road z only'
        if(sum(contains(tireClasses,'Delft')+contains(tireClasses,'MFSwift')))
            error_str = sprintf('%s\n%s\n%s\n%s\n%s',...
                'Configure model to use Delft Tire or MF-Swift software for this maneuver.',...
                ['** Vehicle.Chassis.TireF.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                ['** Vehicle.Chassis.TireR.class.Value is ''' Vehicle.Chassis.TireF.class.Value ''''],...
                tr_diag_str,...
                '--> All values for active components should be ''MFEval''');
            errordlg(error_str,'Wrong Tire Software')
        end
        
    case 'track mallory park'
        % No special commands
    case 'two lane road'
        % No special commands
    case 'double lane change'
        % No special commands
    case 'testrig 4 post'
        % Set tire model
        % -- Extract size from Instance
        % -- Get comparable field from VDatabase
        % -- Fill in Tire Body from original Vehicle structure
        
        % Front
        tire_sizeF = tirInstF(end-8:end);                % Size
        tirInstF_testrig = ['Testrig_Post_' tire_sizeF]; % New Instance
        if(~strcmp(Vehicle.Chassis.TireF.class.Value,'Tire2x'))
            Vehicle.Chassis.TireF = VDatabase.Tire.(tirInstF_testrig);
            Vehicle.Chassis.TireF.TireBody = tirBodyF;
        else
            Vehicle.Chassis.TireF.TireInner = VDatabase.Tire.(tirInstF_testrig);
            Vehicle.Chassis.TireF.TireOuter = VDatabase.Tire.(tirInstF_testrig);
            Vehicle.Chassis.TireF.TireInner.TireBody = tirBodyF_Inn;
            Vehicle.Chassis.TireF.TireOuter.TireBody = tirBodyF_Out;
        end
        
        % Rear
        tire_sizeR = tirInstR(end-8:end);
        tirInstR_testrig = ['Testrig_Post_' tire_sizeR];
        if(~strcmp(Vehicle.Chassis.TireR.class.Value,'Tire2x'))
            Vehicle.Chassis.TireR = VDatabase.Tire.(tirInstR_testrig);
            Vehicle.Chassis.TireR.TireBody = tirBodyR;
        else
            Vehicle.Chassis.TireR.TireInner = VDatabase.Tire.(tirInstR_testrig);
            Vehicle.Chassis.TireR.TireOuter = VDatabase.Tire.(tirInstR_testrig);
            Vehicle.Chassis.TireR.TireInner.TireBody = tirBodyR_Inn;
            Vehicle.Chassis.TireR.TireOuter.TireBody = tirBodyR_Out;
        end
end
set_param([modelname '/World'],'popup_scene',scenename);

% Set road file for all tires
% Car, Front Axle
if(~strcmp(Vehicle.Chassis.TireF.class.Value,'Tire2x'))
    Vehicle.Chassis.TireF.roadFile.Value = roadFileF;
else
    % Assumes TireInner and TireOuter are the same
    Vehicle.Chassis.TireF.TireInner.roadFile.Value = roadFileF;
    Vehicle.Chassis.TireF.TireOuter.roadFile.Value = roadFileF;
end

% Car, Rear Axle
if(~strcmp(Vehicle.Chassis.TireR.class.Value,'Tire2x'))
    Vehicle.Chassis.TireR.roadFile.Value = roadFileR;
else
    % Assumes TireInner and TireOuter are the same
    Vehicle.Chassis.TireR.TireInner.roadFile.Value = roadFileR;
    Vehicle.Chassis.TireR.TireOuter.roadFile.Value = roadFileR;
end

% Trailer, Front Axle
Trailer.Chassis.TireF.roadFile.Value = roadFileF;

assignin('base','Vehicle',Vehicle);
assignin('base','Trailer',Trailer);



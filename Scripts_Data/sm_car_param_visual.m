function Visual = sm_car_param_visual(car_option)
% Copyright 2018-2024 The MathWorks, Inc.

%% Colors
Visual.clr.blue        = [0.2 0.4 0.6];
Visual.clr.bluepure    = [0.2 0.4 0.6];
Visual.clr.bluelight   = [0.5 0.8 1.0];
Visual.clr.black       = [0.0 0.0 0.0];
Visual.clr.yellow      = [1.0 1.0 0.0];
Visual.clr.green       = [0.2 1.0 0.0];
Visual.clr.red         = [1.0 0.0 0.2];
Visual.clr.orange      = [1.0 0.8 0.4];
Visual.clr.orangedark  = [1.0 0.7 0.0];
Visual.clr.purple      = [0.6 0.6 1.0];
Visual.clr.yellowpale  = [0.93 0.93 0.56];
Visual.clr.graydark    = [0.1 0.1 0.1];
Visual.clr.gray        = [0.5 0.5 0.5];
Visual.clr.graylight   = [0.8 0.8 0.8];
Visual.clr.white       = [1.0 1.0 1.0];

%% Part Colors
Visual.hp.clr = Visual.clr.red;

Visual.Shock.cyl.clr        = Visual.clr.blue;
Visual.Shock.piston.clr     = Visual.clr.gray;
Visual.Shock.bumpstop.clr   = Visual.clr.yellowpale;

Visual.Rim.clr              = Visual.clr.graylight;

Visual.DiffShaftOut.clr     = Visual.clr.gray;
Visual.Driveshaft.clr       = Visual.clr.gray;
Visual.DriveshaftCVs.clr    = Visual.clr.orangedark;
Visual.Axle.clr             = Visual.clr.gray;

Visual.AntiRollBar.clr      = Visual.clr.blue;
Visual.UpperArm.clr         = Visual.clr.yellow;
Visual.LowerArm.clr         = Visual.clr.yellow;
Visual.Upright.clr          = Visual.clr.green;
Visual.Pushrod.clr          = Visual.clr.bluelight;
Visual.Bellcrank.clr        = Visual.clr.green;
Visual.SteeringArm.clr      = Visual.clr.green;
Visual.TrackRod.clr         = Visual.clr.purple;

Visual.SteeringRack.clr     = Visual.clr.bluepure;
Visual.SteeringShafts.clr   = Visual.clr.gray;
Visual.SteeringPinion.clr   = Visual.clr.gray;
Visual.SteeringWheel.clr    = Visual.clr.gray;

Visual.TireContactPlane.clr = Visual.clr.gray;
Visual.TireContactPlane.opc = 0.25;

Visual.PaceCar.body.clr     = Visual.clr.red;

% Emblem
xy_data_membrane_data      = load('xy_data_membrane');
Visual.emblem.data         = xy_data_membrane_data.xy_data_membrane;
Visual.emblem.opc          = 1;

Visual.PaceCar.emblem.data = xy_data_membrane_data.xy_data_membrane;
Visual.PaceCar.emblem.opc  = 1;
Visual.PaceCar.body.opc    = 0.1;

%% Part Dimensions
if(strcmpi(car_option,'default'))
    
    % Shock Visualization
    Visual.Shock.dead_length = 0.005;
    Visual.Shock.piston.len  = 0.01;
    Visual.Shock.cap.len     = 0.005;
    Visual.Shock.bumpstop.len= 0.01;
    Visual.Shock.cyl.rad     = 0.03;
    
    %Visual.body.hp = [0 0 0.4225-0.1]; % Not needed?
    Visual.body.opc             = 0.3;
    
    Visual.hp.opc               = 1;
    Visual.hp.rad               = 0.025;
    
    Visual.part.opc      = 1;
    Visual.Rim.opc       = 0.5;
    Visual.Tire.opc      = 1;
    Visual.Tire.clr      = Visual.clr.gray;

    % Steering
    Visual.SteeringArm.rad    = 0.02;
    Visual.TrackRod.rad       = 0.02;
    Visual.SteeringRack.rad   = 0.02;
    Visual.SteeringShafts.rad = 0.02;
    Visual.SteeringPinion.len = 0.01;
    
    % Linkage
    Visual.AntiRollBar.rad    = 0.02;
    Visual.DiffShaftOut.rad   = 0.025;
    Visual.UpperArm.rad       = 0.02;
    Visual.LowerArm.rad       = 0.02;
    Visual.Upright.rad        = 0.02;
    Visual.Pushrod.rad        = 0.02;
    Visual.Bellcrank.rad      = 0.02;
    
    % Driveline
    Visual.Driveshaft.rad     = 0.025;
    Visual.DriveshaftCVs.rad  = 0.03;
    Visual.Axle.rad           = 0.025;
    
else
    % Shock Visualization
    Visual.Shock.dead_length = 0.005;
    Visual.Shock.piston.len  = 0.01;
    Visual.Shock.cap.len     = 0.005;
    Visual.Shock.bumpstop.len= 0.01;
    Visual.Shock.cyl.rad     = 0.025;
    
    %Visual.body.hp = [0 0 0.4225-0.1]; % Not needed?
    Visual.body.opc             = 0.3;
    
    Visual.hp.opc               = 1;
    Visual.hp.rad               = 0.0125;
    
    Visual.part.opc      = 1;
    Visual.Rim.opc       = 0.5;
    Visual.Tire.opc      = 1;
    Visual.Tire.clr      = Visual.clr.graydark;

    % Steering
    Visual.SteeringArm.rad    = 0.01;
    Visual.TrackRod.rad       = 0.008;
    Visual.SteeringRack.rad   = 0.01;
    Visual.SteeringShafts.rad = 0.01;
    Visual.SteeringPinion.len = 0.01;
    
    % Linkage
    Visual.AntiRollBar.rad    = 0.006;
    Visual.UpperArm.rad       = 0.008;
    Visual.LowerArm.rad       = 0.008;
    Visual.Upright.rad        = 0.01;
    Visual.Pushrod.rad        = 0.006;
    Visual.Bellcrank.rad      = 0.008;
    
    % Driveline
    Visual.Driveshaft.rad     = 0.0125;
    Visual.DiffShaftOut.rad   = 0.0125;
    Visual.DriveshaftCVs.rad  = 0.015;
    Visual.Axle.rad           = 0.0125;
    
end

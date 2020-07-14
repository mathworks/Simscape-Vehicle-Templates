% Copyright 2018-2020 The MathWorks, Inc.

%% Colors
Visual.clr.blue        = [0.2 0.4 0.6];
Visual.clr.bluepure    = [0.2 0.4 0.6];
Visual.clr.black       = [0.0 0.0 0.0];
Visual.clr.yellow      = [1.0 1.0 0.0];
Visual.clr.green       = [0.2 1.0 0.0];
Visual.clr.red         = [1.0 0.0 0.2];
Visual.clr.orange      = [1.0 0.8 0.4];
Visual.clr.orangedark  = [1.0 0.7 0.0];
Visual.clr.purple      = [0.6 0.6 1.0];
Visual.clr.yellowpale  = [0.93 0.93 0.56];
Visual.clr.gray        = [0.5 0.5 0.5];
Visual.clr.graylight   = [0.8 0.8 0.8];
Visual.clr.white       = [1.0 1.0 1.0];

% Shock Visualization
Visual.Shock.dead_length = 0.01;
Visual.Shock.piston.len = 0.025;
Visual.Shock.cap.len = 0.025;
Visual.Shock.bumpstop.len = 0.05;
Visual.Shock.cyl.rad = 0.05;
Visual.Shock.cyl.clr = Visual.clr.blue;
Visual.Shock.piston.clr = Visual.clr.gray;
Visual.Shock.bumpstop.clr = Visual.clr.yellowpale;


% Car Body Visualization
Visual.body.hp = [0 0 0.4225-0.1];
Visual.body.opc = 0.3;

Visual.hp.clr = Visual.clr.red;
Visual.hp.opc = 1;
Visual.hp.rad = 0.025;

Visual.part.opc = 1;
Visual.Rim.clr  = Visual.clr.graylight;
Visual.Rim.opc  = 0.5;

Visual.Tire.clr  = Visual.clr.gray;
Visual.Tire.opc  = 1;

% Anti-Roll Bar
Visual.AntiRollBar.clr = Visual.clr.blue;
Visual.AntiRollBar.rad = 0.02;

% Differential Shaft
Visual.DiffShaftOut.clr = Visual.clr.gray;
Visual.DiffShaftOut.rad = 0.025;

% Driveshaft
Visual.Driveshaft.clr = Visual.clr.gray;
Visual.Driveshaft.rad = 0.025;
Visual.DriveshaftCVs.clr = Visual.clr.orangedark;
Visual.DriveshaftCVs.rad = 0.03;

% Upper Arm
Visual.UpperArm.clr = Visual.clr.yellow;
Visual.UpperArm.rad = 0.02;

% Lower Arm
Visual.LowerArm.clr = Visual.clr.yellow;
Visual.LowerArm.rad = 0.02;

% Upright
Visual.Upright.clr = Visual.clr.green;
Visual.Upright.rad = 0.02;

% Axle
Visual.Axle.clr = Visual.clr.gray;
Visual.Axle.rad = 0.025;

% Steering Arm
Visual.SteeringArm.clr = Visual.clr.green;
Visual.SteeringArm.rad = 0.02;

% Track Rod
Visual.TrackRod.clr = Visual.clr.purple;
Visual.TrackRod.rad = 0.02;

% Steering Rack
Visual.SteeringRack.clr = Visual.clr.bluepure;
Visual.SteeringRack.rad = 0.02;

% Steering Shafts
Visual.SteeringShafts.clr = Visual.clr.gray;
Visual.SteeringShafts.rad = 0.02;

% Steering Pinion
Visual.SteeringPinion.clr = Visual.clr.gray;
Visual.SteeringPinion.len = 0.01;

% Steering Wheel
Visual.SteeringWheel.clr = Visual.clr.gray;


load xy_data_membrane
Visual.emblem.data = xy_data_membrane;
Visual.emblem.opc  = 1;

Visual.PaceCar.emblem.data = xy_data_membrane;
Visual.PaceCar.emblem.opc  = 1;
Visual.PaceCar.body.clr  = Visual.clr.red;
Visual.PaceCar.body.opc  = 0.1;

clear xy_data_membrane


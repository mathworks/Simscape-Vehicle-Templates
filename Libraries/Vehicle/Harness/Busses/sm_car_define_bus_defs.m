function buses = sm_car_define_bus_defs(Vehicle_DS)
% sm_car_define_bus_defs  Function to define bus objects for Simscape
% Vehicle models
%
% Pass as argument the Vehicle
% data structure so that the objects are created match the selected
% variants.

% Copyright 2019-2022 The MathWorks, Inbuses.Controller.Road.

% VehicleModel IO Def
buses.Vehicle.Chassis.Body.CG.x = {'DocUnits', 'm', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.y = {'DocUnits', 'm', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.z = {'DocUnits', 'm', 'Description', ''};

buses.Vehicle.Chassis.Body.CG.vx = {'DocUnits', 'm/s', 'Description', ''};  %% note unit change!
buses.Vehicle.Chassis.Body.CG.vy = {'DocUnits', 'm/s', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.vz = {'DocUnits', 'm/s', 'Description', ''};

buses.Vehicle.Chassis.Body.CG.gx = {'DocUnits', 'm/s^2', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.gy = {'DocUnits', 'm/s^2', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.gz = {'DocUnits', 'm/s^2', 'Description', ''};

buses.Vehicle.Chassis.Body.CG.nRoll = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.nPitch = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.nYaw = {'DocUnits', 'rad/s', 'Description', ''};

buses.Vehicle.Chassis.Body.CG.aRoll = {'DocUnits', 'rad', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.aPitch = {'DocUnits', 'rad', 'Description', ''};
buses.Vehicle.Chassis.Body.CG.aYaw = {'DocUnits', 'rad', 'Description', ''};

buses.Vehicle.Chassis.Spring.FL.xSpring = {'DocUnits', 'm', 'Description', ''};
buses.Vehicle.Chassis.Spring.FL.FSpring = {'DocUnits', 'N', 'Description', ''};
buses.Vehicle.Chassis.Spring.FR = 'FL'; % reference buses.Vehicle.Chassis.Spring.FL definition
buses.Vehicle.Chassis.Spring.RL = 'FL'; % reference buses.Vehicle.Chassis.Spring.FL definition
buses.Vehicle.Chassis.Spring.RR = 'FL'; % reference buses.Vehicle.Chassis.Spring.FL definition
buses.Vehicle.Chassis.Damper.FL.FDamper =   {'DocUnits', 'N',   'Description', ''};
buses.Vehicle.Chassis.Damper.FL.FBumpstop = {'DocUnits', 'N',   'Description', ''};
buses.Vehicle.Chassis.Damper.FL.xDamper =   {'DocUnits', 'm',   'Description', ''};
buses.Vehicle.Chassis.Damper.FL.vDamper =   {'DocUnits', 'm/s', 'Description', ''};
buses.Vehicle.Chassis.Damper.FR = 'FL'; % reference buses.Vehicle.Chassis.Damper.Road.FL definition
buses.Vehicle.Chassis.Damper.RL = 'FL'; % reference buses.Vehicle.Chassis.Damper.Road.FL definition
buses.Vehicle.Chassis.Damper.RR = 'FL'; % reference buses.Vehicle.Chassis.Damper.Road.FL definition
buses.Vehicle.Chassis.WhlFL.qxyz =  {'Dimensions', 3, 'DocUnits', 'rad',    'Description', ''};
buses.Vehicle.Chassis.WhlFL.xyz =   {'Dimensions', 3, 'DocUnits', 'm',      'Description', ''};
buses.Vehicle.Chassis.WhlFL.n =     {                 'DocUnits', 'rad/s',  'Description', ''};
buses.Vehicle.Chassis.WhlFL.Fx =    {                 'DocUnits', 'N',      'Description', ''};
buses.Vehicle.Chassis.WhlFL.Fy =    {                 'DocUnits', 'N',      'Description', ''};
buses.Vehicle.Chassis.WhlFL.Fz =    {                 'DocUnits', 'N',      'Description', ''};
buses.Vehicle.Chassis.WhlFL.Mx =    {                 'DocUnits', 'N*m',    'Description', ''};
buses.Vehicle.Chassis.WhlFL.My =    {                 'DocUnits', 'N*m',    'Description', ''};
buses.Vehicle.Chassis.WhlFL.Mz =    {                 'DocUnits', 'N*m',    'Description', ''};
buses.Vehicle.Chassis.WhlFL.rSlip = {                 'DocUnits', '1',      'Description', ''};
buses.Vehicle.Chassis.WhlFL.aSlip = {                 'DocUnits', 'rad',    'Description', ''};
buses.Vehicle.Chassis.WhlFL.aCamber = {               'DocUnits', 'rad',    'Description', ''};
buses.Vehicle.Chassis.WhlFL.vx =    {                 'DocUnits', 'm/s',    'Description', ''};
buses.Vehicle.Chassis.WhlFL.rMuX =  {                 'DocUnits', '1',      'Description', ''};
buses.Vehicle.Chassis.WhlFL.rMuY =  {                 'DocUnits', '1',      'Description', ''};
buses.Vehicle.Chassis.WhlFR = 'WhlFL';
buses.Vehicle.Chassis.WhlRL = 'WhlFL';
buses.Vehicle.Chassis.WhlRR = 'WhlFL';
buses.Vehicle.Chassis.SuspF.Steer.FRack = {};
buses.Vehicle.Chassis.SuspF.Steer.xRack = {};
buses.Vehicle.Chassis.SuspR = 'SuspF';
buses.Vehicle.Chassis.Aero.Fx         = {'DocUnits', 'N', 'Description', ''};
buses.Vehicle.Chassis.Aero.Fz         = {'DocUnits', 'N', 'Description', ''};
buses.Vehicle.Power.nMotorF           = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.Power.nMotorR           = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.Power.MMotorF           = {'DocUnits', 'N*m', 'Description', ''};
buses.Vehicle.Power.MMotorR           = {'DocUnits', 'N*m', 'Description', ''};
buses.Vehicle.Driveline.MDriveshaftRL = {'DocUnits', 'N*m', 'Description', ''};
buses.Vehicle.Driveline.MDriveshaftRR = {'DocUnits', 'N*m', 'Description', ''};
buses.Vehicle.Driveline.MDriveshaftFL = {'DocUnits', 'N*m', 'Description', ''};
buses.Vehicle.Driveline.MDriveshaftFR = {'DocUnits', 'N*m', 'Description', ''};

buses.Vehicle.Driveline.anDriveshaftFL.w = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.Driveline.anDriveshaftFL.q = {'DocUnits', 'rad', 'Description', ''};
buses.Vehicle.Driveline.anDriveshaftFR.w = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.Driveline.anDriveshaftFR.q = {'DocUnits', 'rad', 'Description', ''};
buses.Vehicle.Driveline.anDriveshaftRL.w = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.Driveline.anDriveshaftRL.q = {'DocUnits', 'rad', 'Description', ''};
buses.Vehicle.Driveline.anDriveshaftRR.w = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.Driveline.anDriveshaftRR.q = {'DocUnits', 'rad', 'Description', ''};
buses.Vehicle.Brakes.MBrakeFL = {'DocUnits', 'N*m', 'Description', ''};
buses.Vehicle.Brakes.MBrakeFR = {'DocUnits', 'N*m', 'Description', ''};
buses.Vehicle.Brakes.MBrakeRL = {'DocUnits', 'N*m', 'Description', ''};
buses.Vehicle.Brakes.MBrakeRR = {'DocUnits', 'N*m', 'Description', ''};

brake_var = Vehicle_DS.Brakes.class.Value;

if (strcmpi(brake_var,'ABS_4_Channel'))
    buses.Vehicle.Brakes.pBrakeFL = {'DocUnits', 'bar', 'Description', ''};
    buses.Vehicle.Brakes.pBrakeFR = {'DocUnits', 'bar', 'Description', ''};
    buses.Vehicle.Brakes.pBrakeRL = {'DocUnits', 'bar', 'Description', ''};
    buses.Vehicle.Brakes.pBrakeRR = {'DocUnits', 'bar', 'Description', ''};
end

buses.Vehicle.World.x = {'DocUnits', 'm', 'Description', ''};
buses.Vehicle.World.y = {'DocUnits', 'm', 'Description', ''};
buses.Vehicle.World.z = {'DocUnits', 'm', 'Description', ''};

buses.Vehicle.World.vx = {'DocUnits', 'm/s', 'Description', ''};
buses.Vehicle.World.vy = {'DocUnits', 'm/s', 'Description', ''};
buses.Vehicle.World.vz = {'DocUnits', 'm/s', 'Description', ''};

buses.Vehicle.World.gx = {'DocUnits', 'm/s^2', 'Description', ''};
buses.Vehicle.World.gy = {'DocUnits', 'm/s^2', 'Description', ''};
buses.Vehicle.World.gz = {'DocUnits', 'm/s^2', 'Description', ''};

buses.Vehicle.World.nRoll = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.World.nPitch = {'DocUnits', 'rad/s', 'Description', ''};
buses.Vehicle.World.nYaw = {'DocUnits', 'rad/s', 'Description', ''};

buses.Vehicle.World.aRoll = {'DocUnits', 'rad', 'Description', ''};
buses.Vehicle.World.aPitch = {'DocUnits', 'rad', 'Description', ''};
buses.Vehicle.World.aYaw = {'DocUnits', 'rad', 'Description', ''};

buses.Controller.Chassis.SuspF.Steer.iMotor = {};
buses.Controller.Chassis.SuspR.Steer.iMotor = {};
buses.Controller.Chassis.Damper.FL = {};
buses.Controller.Chassis.Damper.FR = {};
buses.Controller.Chassis.Damper.RL = {};
buses.Controller.Chassis.Damper.RR = {};
buses.Controller.Chassis.Spring.FL = {};
buses.Controller.Chassis.Spring.FR = {};
buses.Controller.Chassis.Spring.RL = {};
buses.Controller.Chassis.Spring.RR = {};
buses.Controller.Power.MMotorFDemand    = {'DocUnits', 'N*m', 'Description', ''};
buses.Controller.Power.MMotorRDemand    = {'DocUnits', 'N*m', 'Description', ''};
buses.Controller.Power.MRegenBrakeLimit = {'DocUnits', 'N*m', 'Description', ''};
buses.Controller.Driveline.placeholder = {};

if (strcmpi(brake_var,'pressure'))
    % CtrlBus, Pressure variant
    buses.Controller.Brakes.pBrakeFL = {'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.pBrakeFR = {'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.pBrakeRL = {'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.pBrakeRR = {'DocUnits', 'bar', 'Description', ''};
elseif (strcmpi(brake_var,'pedal'))
    % CtrlBus, Pedal variant
    buses.Controller.Brakes.Valves.FL = {'Dimensions', 2, 'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.Valves.FR = {'Dimensions', 2, 'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.Valves.RL = {'Dimensions', 2, 'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.Valves.RR = {'Dimensions', 2, 'DocUnits', 'bar', 'Description', ''};
elseif (strcmpi(brake_var,'ABS_4_Channel'))
    % CtrlBus, ABS variant
    buses.Controller.Brakes.Valves.FL = {'Dimensions', 2, 'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.Valves.FR = {'Dimensions', 2, 'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.Valves.RL = {'Dimensions', 2, 'DocUnits', 'bar', 'Description', ''};
    buses.Controller.Brakes.Valves.RR = {'Dimensions', 2, 'DocUnits', 'bar', 'Description', ''};
end

buses.Maneuver.rClosedLoopLongitudinal = {'DocUnits', '1', 'Description', ''};
buses.Maneuver.rFollowTrajectoryLongitudinal = {'DocUnits', '1', 'Description', ''};
buses.Maneuver.rClosedLoopLateral = {'DocUnits', '1', 'Description', ''};
buses.Maneuver.rFollowTrajectoryLateral = {'DocUnits', '1', 'Description', ''};

buses.Maneuver.rCurvature = {'DocUnits', '1', 'Description','','Dimensions',7};
buses.Maneuver.xLateralDeviation = {'DocUnits', 'm', 'Description', ''};
buses.Maneuver.aYawDeviation = {'DocUnits','rad','Description',''}; %% note unit change!
buses.Maneuver.aSteerWheel = {'DocUnits', 'rad', 'Description', ''};  %% note unit change!

buses.Maneuver.vxTarget = {'DocUnits', 'm/s', 'Description', ''};  %% note unit change!
buses.Maneuver.rAccelPedal = {'DocUnits', '1', 'Description', '','Min',0,'Max',1};
buses.Maneuver.rBrakePedal = {'DocUnits', '1', 'Description', '','Min',0,'Max',1};

buses.Trajectory.vxTarget = {'DocUnits', 'm/s', 'Description', ''};  %% note unit change!
buses.Trajectory.rCurvature = {'DocUnits', '1', 'Description','','Dimensions',7};
buses.Trajectory.xLateralDeviation = {'DocUnits', 'm', 'Description', ''};
buses.Trajectory.aYawDeviation = {'DocUnits','rad','Description',''};  %% note unit change!

buses.Driver.rAccelPedal = {'DocUnits', '1', 'Description', '','Min',0,'Max',1};
buses.Driver.rBrakePedal = {'DocUnits', '1', 'Description', '','Min',0,'Max',1};
buses.Driver.aSteerWheel = {'DocUnits', 'rad', 'Description', ''};  %% note unit change!

% From Josh 19.Sep.2019
buses.Road.FL.gz = {'DocUnits', 'm', 'Description', 'TO BE REMOVED'};
buses.Road.FL.TireScaling = {'Dimensions', 7,'DocUnits','1','Description','Tire Scaling'};
buses.Road.FR = 'FL';
buses.Road.RL = 'FL';
buses.Road.RR = 'FL';

% OLD
%{
buses.Road.FL.gz = {'DocUnits', 'm', 'Description', 'TO BE REMOVED'};
buses.Road.FL.zRoad = {'DocUnits', 'm', 'Description', ''};
buses.Road.FL.eRoad = {'Dimensions', 3, 'DocUnits', 'm', 'Description', ''};
buses.Road.FR = 'FL';
buses.Road.RL = 'FL';
buses.Road.RR = 'FL';
%}
end




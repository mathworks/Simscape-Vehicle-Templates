function [tireK] = sm_car_get_tire_params(Vehicle)
% sm_car_get_track Determine track of vehicle using values from Vehicle data structure
%     veh_track = sm_car_get_track(Vehicle);
%     This function returns the track and wheelbase by extracting the
%     relevant values from the Vehicle data structure used in the Simscape
%     Vehicle Templates.  Different vehicle types store the relevant
%     parameters in different fields.  This function will identify the
%     correct fields to use to obtain the track and wheelbase.
%
%        Vehicle   MATLAB structure with vehicle parameters
%
%     Outputs include
%        veh_track       Distance between the front wheels
%        veh_wheelbase   Distance between front and rear axles
%
%

% Get Tire File name
if(isfield(Vehicle.Chassis.TireA1,'tirFile'))
    tireFile = Vehicle.Chassis.TireA1.tirFile.Value;

    if(contains(tireFile,'which'))
        tireFile = evalin('base',tireFile);
    end

    tireParams    = simscape.multibody.tirread(tireFile);
    tireK = tireParams.VERTICAL.VERTICAL_STIFFNESS;
elseif(isfield(Vehicle.Chassis.TireA1,'K'))
    tireK = Vehicle.Chassis.TireA1.K.Value;
else
    error('Cannot find find tire stiffness in structure Vehicle.Chassis.TireA1');
end

% Get Track

veh_track = 0;
if(isfield(Vehicle.Chassis.SuspA1,'Linkage'))
    veh_track = Vehicle.Chassis.SuspA1.Linkage.Upright.sWheelCentre.Value(2)*2;
elseif(isfield(Vehicle.Chassis.SuspA1,'Simple'))
    veh_track = Vehicle.Chassis.SuspA1.Simple.sWheelCentre.Value(2)*2;
end



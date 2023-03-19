%% Vehicle
%
%
% <html>
% <a href="../../sm_car_doc_overview.html">Home</a> &gt; 
% <a href="./sm_car_doc_car.html">Car</a> &gt;
% </html>
%
% 
% Copyright 2019-2023 The MathWorks, Inc.

%% Block
%
% The Vehicle block accepts three input busses and produces one output bus.
% The two physical connections are intended for the World frame (port W)
% and for connections to frames for defining dynamic cameras (port C).

open_system('sm_car_doc_model_for_images')
open_system('sm_car_doc_model_for_images/Car Subsystem');

%% Coordinate System
%
% The default coordinate system for the car model is z-up, x-forward, and y
% to the left.  This follows the ISO 8855 convention.  Measurements can be
% converted to other standard conventions.
%
% <<sm_car_doc_car_coordinate_system.png>>


%% Initial Positions and Velocities
%
% The initial position and orientation for the vehicle is defined in the
% structure *|Init|*.
%
% * *|Init.Chassis.sChassis.Value|*: Initial position in *world* frame,
% expressed as [x y z] in meters.
% * *|Init.Chassis.vChassis.Value|*: Initial velocity in *vehicle* frame,
% expressed as [vx vy vz] in meters/second.
% * *|Init.Chassis.aChassis.Value|*: Initial orientation in *vehicle* frame,
% expressed as [roll, pitch, and yaw] in radians. The rotations are
% applied sequentially in the order yaw->pitch->roll, and they are applied
% intrinsically.  Each of the elemental rotations is performed on the
% axis resulting from the previous rotation.
%
% <<sm_car_doc_car_initial_orientation.png>>

%% Vehicle Parameters
%
% The Vehicle parameters is a data structure with fields corresponding to
% different parts of the model.  The "Class" fields in the data structure
% are used to select the active variants within the model.
%

%% Initialization Trigger Dropdown
%
% The mask initialization selects the active variants for many levels of
% the model.  To trigger that code, change the value of Initialization
% Trigger Dropdown in the Vehicle block from 0 to 1 or from 1 to 0.  The
% code will set the active variant at every level by triggering the same
% mechanism at every level with variants in the model.

%%
bdclose('sm_car_doc_model_for_images')
%% Body to World Connection
%
%
% <html>
% <a href="../../sm_car_doc_overview.html">Home</a> &gt; 
% <a href="./sm_car_doc_car.html">Car</a> &gt;
% </html>
%
% 
% Copyright 2019-2022 The MathWorks, Inc.

%% Block
%
% The Body to World block models the connection between the vehicle body
% and world.  It permits 6 degrees of freedom and sets the initial position,
% orientation, and speed of the vehicle body.
% 
% * Physical port B should be connected to the World frame.  
% * Physical port F should be connected to the frame on the vehicle bode
% whose initial position should be set by the Init variable.
% * Port world outputs measurements from the World frame.

open_system('sm_car_doc_model_for_images')
open_system('sm_car_doc_model_for_images/Body to World Subsystem');

%%
open_system('sm_car_doc_model_for_images/Body to World Subsystem/Body to World');

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
% *|Init.Chassis.sChassis.Value|*: Initial position in *world* frame,
% expressed as [x y z] in meters.
%
% *|Init.Chassis.vChassis.Value|*: Initial velocity in *vehicle* frame,
% expressed as [vx vy vz] in meters/second.
%
% *|Init.Chassis.aChassis.Value|*: Initial orientation in *vehicle* frame,
% expressed as [roll, pitch, and yaw] in radians. The rotations are
% applied sequentially in the order yaw->pitch->roll, and they are applied
% intrinsically.  Each of the elemental rotations is performed on the
% axis resulting from the previous rotation.
%
% <<sm_car_doc_car_initial_orientation.png>>

%% Interface
%   
%
%%
bdclose('sm_car_doc_model_for_images')
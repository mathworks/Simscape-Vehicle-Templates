function hpAxle = calcLinkHPAxle(hpBody,hpAxle0,qx, qz)
% calccalcHPInboard  Calculate position of link inboard hardpoint
%
%   Calculate the location of the link inboard hardpoint in chassis
%   coordinates. The location of the link outboard hardpoint connection to
%   the body and Universal joint angles are used.  This permits the
%   hardpoint location to be calculated using only data from Simscape
%   logging and parameter values. If the link is connected using a revolute
%   joint, set the qz angle to 0.  
%
%   This calculation depends on the orientation and connections of the
%   joint at the body end of the link.  If the degrees of freedom or block
%   connections are modified, this code will also need modifications.  If a
%   universal joint is used, it is assumed the follower frame is connected
%   to the chassis.  Rotation must be about x, then about z.
%
%      hpBody   Location of link body connection
%      hpAxle0  Location of link axle/upright connection in design position
%      qx       Angle of universal joint about vehicle longitudinal axis
%               Angle is assumed 0 at time=0
%      qz       Angle of universial joint about vehicle vertical axis
%               Angle is assumed 0 at time=0
%

% Convert units
dtheta_x = deg2rad(qx); % Change about x-axis (degrees → radians)
dtheta_z = deg2rad(qz); % Change about z-axis

% ----- Relative vector from A to B -----
r0 = hpAxle0 - hpBody;

% ----- Rotation matrices -----
% Only correct if rotation is about x, then about z
Rx = [ ...
    1           0            0;
    0  cos(dtheta_x)  -sin(dtheta_x);
    0  sin(dtheta_x)   cos(dtheta_x)];

Rz = [ ...
    cos(dtheta_z)  -sin(dtheta_z)  0;
    sin(dtheta_z)   cos(dtheta_z)  0;
    0                   0          1];

% ----- Apply rotations (X then Z) -----
R = Rz * Rx;

% ----- New relative position -----
r_new = R * r0;

% ----- New global position of B -----
hpAxle = hpBody + r_new;

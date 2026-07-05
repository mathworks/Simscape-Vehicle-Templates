function B_world = rodTipFromGimbalAndPrismatic( ...
    A_world, B0_world, q, dL, baseAxis_world, baseAngle, varargin)
%RODTIPFROMGIMBALANDPRISMATIC  Compute new rod tip position for a gimbal+prismatic chain.
%
% Scenario:
%   - One end of rod at A_world (fixed joint origin / fixed end), world coords
%   - Rod direction is rigidly attached to gimbal FOLLOWER frame
%   - Gimbal joint angles are defined about FOLLOWER axes with XYZ sequence
%   - Prismatic joint changes rod length by dL
%
% Inputs:
%   A_world          (3x1) fixed end location in world
%   B0_world         (3x1) moving end location at start of test (world)
%   q                (3x1) or (Nx3) gimbal angles [qx qy qz] at current time(s)
%   dL               scalar or (N x 1) extension amount (same units as A/B positions)
%   baseAxis_world   (3x1) axis of base frame rotation (expressed in world)
%   baseAngle        scalar base frame rotation angle about baseAxis_world
%
% Name-Value options (all optional):
%   "AngleUnit"      "rad" (default) or "deg"
%   "q0"             (3x1) start angles at the time B0_world was measured (default [0;0;0])
%
% Output:
%   B_world          (3x1) or (Nx3) new moving end location(s) in world
%
% Notes:
%   - The function infers the rod/prismatic axis direction in the follower frame
%     from (A_world,B0_world) and the start angles q0.
%   - If your start angles are not zero, pass them via "q0".
%
% Rotation convention:
%   - FOLLOWER axes, XYZ sequence => intrinsic/body-fixed XYZ
%     (follower rotates after each elemental rotation). [1](https://mathworks.atlassian.net/wiki/spaces/SSMLTBODY/pages/163028460/_simscape.multibody.Rotation)[2](https://mathworks.atlassian.net/wiki/spaces/SSMLTBODY/pages/163025314/Simscape+Multibody+Rotation+Sequence+Euler+Angle+Velocity+Sensing)

    % ---- Parse options ----
    p = inputParser;
    p.addParameter("AngleUnit","rad", @(s)ischar(s) || isstring(s));
    p.addParameter("q0",[0;0;0], @(x)isnumeric(x) && numel(x)==3);
    p.parse(varargin{:});
    angleUnit = string(p.Results.AngleUnit);
    q0 = p.Results.q0(:);

    % ---- Normalize shapes ----
    A_world = A_world(:);
    B0_world = B0_world(:);
    baseAxis_world = baseAxis_world(:);
    baseAxis_world = baseAxis_world / norm(baseAxis_world);

    q = double(q);
    if isvector(q), q = q(:).'; end        % 1x3
    N = size(q,1);

    if isscalar(dL)
        dL = repmat(double(dL), N, 1);
    else
        dL = double(dL(:));
        if numel(dL) ~= N
            error("dL must be scalar or have the same number of rows as q.");
        end
    end

    % ---- Convert degrees to radians if needed ----
    if angleUnit == "deg"
        q  = deg2rad(q);
        q0 = deg2rad(q0);
        baseAngle = deg2rad(baseAngle);
    end

    % ---- Base rotation (world <- base) from axis-angle ----
    R_WB = axisAngleToRotm(baseAxis_world, baseAngle);

    % ---- Initial rod vector and length in world ----
    r0W = B0_world - A_world;
    L0  = norm(r0W);
    if L0 < 1e-12
        error("Initial rod length is ~0. Check A_world and B0_world.");
    end

    % ---- Infer rod axis in FOLLOWER frame from start geometry ----
    % Convert r0 to base frame, then to follower frame at start:
    R_BF0 = rotmFollowerXYZ(q0(1), q0(2), q0(3));   % base <- follower at start
    r0B = R_WB.' * r0W;                              % base coords
    r0F = R_BF0.' * r0B;                             % follower coords

    uF = r0F / norm(r0F);                            % unit rod axis in follower frame

    % ---- Compute new tip positions ----
    B_world = zeros(N,3);
    for i = 1:N
        qx = q(i,1); qy = q(i,2); qz = q(i,3);

        R_BF = rotmFollowerXYZ(qx,qy,qz);             % base <- follower (intrinsic XYZ)
        L    = L0 + dL(i);

        rB = R_BF * (uF * L);                         % base coords
        rW = R_WB * rB;                               % world coords
        Bi = A_world + rW;

        B_world(i,:) = Bi.';
    end
end

% ===== Helper: intrinsic (follower/body-fixed) XYZ rotation =====
function R_BF = rotmFollowerXYZ(qx,qy,qz)
% Returns rotation matrix that maps a vector in FOLLOWER coords to BASE coords
% for intrinsic/body-fixed XYZ sequence (Follower axes, XYZ).
    cx = cos(qx); sx = sin(qx);
    cy = cos(qy); sy = sin(qy);
    cz = cos(qz); sz = sin(qz);

    Rx = [1 0 0; 0 cx -sx; 0 sx cx];
    Ry = [cy 0 sy; 0 1 0; -sy 0 cy];
    Rz = [cz -sz 0; sz cz 0; 0 0 1];

    % Intrinsic XYZ (about follower axes): R = Rx * Ry * Rz
    R_BF = Rx * Ry * Rz;
end

% ===== Helper: axis-angle to rotation matrix (Rodrigues) =====
function R = axisAngleToRotm(u,theta)
    ux = u(1); uy = u(2); uz = u(3);
    K = [  0   -uz   uy;
          uz    0   -ux;
         -uy   ux    0 ];
    R = eye(3) + sin(theta)*K + (1-cos(theta))*(K*K);
end
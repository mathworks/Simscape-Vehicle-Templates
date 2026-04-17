function out = rollCenterFromHardpoints(type, hp, opts)
%ROLLCENTERFROMHARDPOINTS Compute geometric roll center from suspension hardpoints.
%
% out = rollCenterFromHardpoints(type, hp, opts)
%
% Inputs
%  type : string/char, one of:
%         "doubleWishbone", "macpherson", "panhard", "watts"
%
%  hp   : struct of hardpoints. Coordinates are [x y z] in meters (or consistent unit).
%
%  opts : optional struct:
%         opts.plane = "YZ" (default)  % "YZ" front view (lateral-vertical)
%         opts.centerlineY = 0 (default)
%         opts.contactPatchZ = 0 (default) % ground plane height
%
% Outputs (struct out)
%  out.RC            : [x y z] roll center (x is NaN for 2D constructions unless supplied)
%  out.RC_YZ         : [y z] roll center in YZ plane
%  out.IC_left_YZ    : [y z] left instant center (if applicable)
%  out.IC_right_YZ   : [y z] right instant center (if applicable)
%  out.debug         : intermediate lines/points
%
% Notes
%  - For independent suspensions: RC found by projecting to YZ plane:
%       IC per side -> line from contact patch to IC -> intersection at vehicle centerline.
%  - For panhard: RC is intersection of panhard bar line with vehicle centerline (Y=0).
%  - For watts: RC is the center pivot point (assumed given as hp.centerPivot).

if nargin < 3, opts = struct(); end
if ~isfield(opts, "plane"), opts.plane = "YZ"; end
if ~isfield(opts, "centerlineY"), opts.centerlineY = 0; end
if ~isfield(opts, "contactPatchZ"), opts.contactPatchZ = 0; end

type = string(type);

switch lower(type)
    case "doublewishbone"
        out = rcDoubleWishbone(hp, opts);

    case "macpherson"
        out = rcMacPherson(hp, opts);

    case "panhard"
        out = rcPanhard(hp, opts);

    case "watts"
        out = rcWatts(hp, opts);

    otherwise
        error("Unknown suspension type: %s", type);
end
end

%% --- Helpers ------------------------------------------------------------

function out = rcDoubleWishbone(hp, opts)
% Required fields:
%  hp.L.UCA_in, hp.L.UCA_out, hp.L.LCA_in, hp.L.LCA_out
%  hp.R.UCA_in, hp.R.UCA_out, hp.R.LCA_in, hp.R.LCA_out
% Optional:
%  hp.L.contactPatch, hp.R.contactPatch  (otherwise inferred from wheelCenter at ground)
%
% All points are [x y z].

% Project to YZ
L = projYZ(hp.L);
R = projYZ(hp.R);

IC_L = lineIntersection2D( lineThrough(L.UCA_in, L.UCA_out), lineThrough(L.LCA_in, L.LCA_out) );
IC_R = lineIntersection2D( lineThrough(R.UCA_in, R.UCA_out), lineThrough(R.LCA_in, R.LCA_out) );

cpL = getContactPatchYZ(L, opts);
cpR = getContactPatchYZ(R, opts);

% Lines from contact patch to instant center
lL = lineThrough(cpL, IC_L);
lR = lineThrough(cpR, IC_R);

% Intersection with vehicle centerline Y = opts.centerlineY
RC = intersectLineWithY(lL, opts.centerlineY);  % [y z]
% Sanity: For symmetric systems, lR should also hit near same [y z]
RC2 = intersectLineWithY(lR, opts.centerlineY);

out.RC_YZ = mean([RC; RC2], 1, "omitnan");
out.RC    = [NaN, out.RC_YZ(1), out.RC_YZ(2)];
out.IC_left_YZ  = IC_L;
out.IC_right_YZ = IC_R;

out.debug.leftLine_contact_to_IC  = lL;
out.debug.rightLine_contact_to_IC = lR;
out.debug.RC_left  = RC;
out.debug.RC_right = RC2;
end

function out = rcMacPherson(hp, opts)
% Required fields:
%  hp.L.strutTop, hp.L.strutBottom (e.g., lower ball joint or knuckle point on strut axis)
%  hp.L.LCA_in, hp.L.LCA_out
%  hp.R.strutTop, hp.R.strutBottom
%  hp.R.LCA_in, hp.R.LCA_out
%
% Method:
%  - In front view, use line along strut axis.
%  - Define line through LCA.
%  - Instant center is intersection of:
%       (a) line through LCA_in->LCA_out
%       (b) line perpendicular to strut axis passing through strutBottom (front view simplification)
%  - Then same construction: contact patch to IC, intersect at centerline.

L = projYZ(hp.L);
R = projYZ(hp.R);

% Left IC
lcaL = lineThrough(L.LCA_in, L.LCA_out);
strutAxisL = lineThrough(L.strutTop, L.strutBottom);
perpStrutL = perpendicularLineThrough(strutAxisL, L.strutTop);
IC_L = lineIntersection2D(lcaL, perpStrutL);

% Right IC
lcaR = lineThrough(R.LCA_in, R.LCA_out);
strutAxisR = lineThrough(R.strutTop, R.strutBottom);
perpStrutR = perpendicularLineThrough(strutAxisR, R.strutTop);
IC_R = lineIntersection2D(lcaR, perpStrutR);

cpL = getContactPatchYZ(L, opts);
cpR = getContactPatchYZ(R, opts);

lL = lineThrough(cpL, IC_L);
lR = lineThrough(cpR, IC_R);

RC  = intersectLineWithY(lL, opts.centerlineY);
RC2 = intersectLineWithY(lR, opts.centerlineY);

out.RC_YZ = mean([RC; RC2], 1, "omitnan");
out.RC    = [NaN, out.RC_YZ(1), out.RC_YZ(2)];
out.IC_left_YZ  = IC_L;
out.IC_right_YZ = IC_R;

out.debug.left_perpStrut  = perpStrutL;
out.debug.right_perpStrut = perpStrutR;
out.debug.RC_left  = RC;
out.debug.RC_right = RC2;
end

function out = rcPanhard(hp, opts)
% Required fields:
%  hp.panhardA, hp.panhardB   endpoints of bar [x y z]
%
% Roll center: intersection of panhard bar line with vehicle centerline (Y = opts.centerlineY).
pA = hp.panhardA;
pB = hp.panhardB;

% Use YZ projection to find intersection at Y=centerline
A = [pA(2), pA(3)]; % [y z]
B = [pB(2), pB(3)];

barLine = lineThrough(A, B);
RC_YZ = intersectLineWithY(barLine, opts.centerlineY);

out.RC_YZ = RC_YZ;
out.RC    = [NaN, RC_YZ(1), RC_YZ(2)];
out.debug.barLineYZ = barLine;
end

function out = rcWatts(hp, ~)
% Required fields:
%  hp.centerPivot  [x y z]  (center pivot of Watts linkage on axle)
out.RC = hp.centerPivot;
out.RC_YZ = [hp.centerPivot(2), hp.centerPivot(3)];
out.debug = struct();
end

function S = projYZ(S)
% Convert all [x y z] points in sub-struct into [y z] points (same field names).
f = fieldnames(S);
for i = 1:numel(f)
    v = S.(f{i});
    if isnumeric(v) && numel(v) == 3
        S.(f{i}) = [v(2), v(3)];
    end
end
end

function cp = getContactPatchYZ(S, opts)
% If contactPatch exists use it; else infer from wheelCenter if provided; else error.
if isfield(S, "contactPatch")
    cp = S.contactPatch;
elseif isfield(S, "wheelCenter")
    cp = [S.wheelCenter(1), opts.contactPatchZ];
else
    error("Need contactPatch or wheelCenter in hp.(L/R) to define tire contact patch.");
end
end

function line = lineThrough(p1, p2)
% line in ax + bz + c = 0 form for 2D points p=[y z]
y1 = p1(1); z1 = p1(2);
y2 = p2(1); z2 = p2(2);
a = (z1 - z2);
b = (y2 - y1);
c = (y1*z2 - y2*z1);
line = [a b c];
end

function p = lineIntersection2D(l1, l2)
% l = [a b c] for a*y + b*z + c = 0
A = [l1(1) l1(2); l2(1) l2(2)];
C = -[l1(3); l2(3)];
if abs(det(A)) < 1e-12
    p = [NaN NaN]; % parallel/degenerate
else
    sol = A \ C;
    p = sol.'; % [y z]
end
end

function lperp = perpendicularLineThrough(line, pt)
% Given line a*y + b*z + c = 0, perpendicular has coefficients [b -a ...]
a = line(1); b = line(2);
ap = b; bp = -a;
cp = -(ap*pt(1) + bp*pt(2));
lperp = [ap bp cp];
end

function p = intersectLineWithY(line, y0)
% Intersect a*y + b*z + c = 0 with y = y0
a = line(1); b = line(2); c = line(3);
if abs(b) < 1e-12
    p = [NaN NaN];
else
    z = -(a*y0 + c) / b;
    p = [y0 z];
end
end

function TSuspMetrics = sm_car_calc_susp_metrics(simlog_toe,simlog_camber,simlog_toeX,simlog_camberX,simlog_pzTire,testPhases,qToeMeas,zOffsetBumpTest,simlog_t,wCtrZ)
% sm_car_calc_susp_metrics Calculates suspension metrics 
%    TSuspMetrics = sm_car_calc_susp_metrics(simlog_toe,simlog_camber,simlog_pzTire,testPhases,qToeMeas,simlog_t,wCtrZ)
%    This function calculates various suspension metrics. It requires a few
%    measurements from a quarter-car testrig that is exercised with a
%    certain sequence of wheel height and steering.
%
%       simlog_toe     Toe measured using z axis of wheel spin frame
%       simlog_camber  Camber measured using z axis of wheel spin frame
%       simlog_toeX    Toe  measured using x axis of wheel spin frame
%       simlog_camberX Camber measured using z axis of wheel spin frame
%       simlog_pzTire  Camber angle from simulation results
%       testPhases     Time periods [start finish] for 
%                           vertical test with no steer
%                           steer at design position
%                           steer with positive vertical displacment of wheel center
%                           steer with negative vertical displacment of wheel center
%       qToeMeas       Toe angle used for caster angle calculation
%       simlog_t       Time vector from simulation results
%       wCtrZ          Z component of wheel center hardpoint location

% Copyright 2018-2024 The MathWorks, Inc.

%% Get indices for each phase of simulation results
indToeCamb   = intersect(find(simlog_t>=testPhases(1,1)),find(simlog_t<=testPhases(1,2)));
indCasterZ0  = intersect(find(simlog_t>=testPhases(2,1)),find(simlog_t<=testPhases(2,2)));
indCasterZp  = intersect(find(simlog_t>=testPhases(3,1)),find(simlog_t<=testPhases(3,2)));
indCasterZn  = intersect(find(simlog_t>=testPhases(4,1)),find(simlog_t<=testPhases(4,2)));

%% Obtain Toe, Camber: Design position
IndZ0NoSteer  = find(simlog_pzTire(indToeCamb)==wCtrZ,1);
toeZ0         = simlog_toe(IndZ0NoSteer);
camberZ0      = simlog_camber(IndZ0NoSteer);

%% Obtain Toe, Camber: + 1cm
IndZpNoSteer  = find(simlog_pzTire(indToeCamb)>=wCtrZ+zOffsetBumpTest,1);
toeZp         = simlog_toe(IndZpNoSteer);
camberZp      = simlog_camber(IndZpNoSteer);

%% Obtain Toe, Camber: - 1cm
IndZnNoSteer = find(simlog_pzTire(indToeCamb)<=wCtrZ-zOffsetBumpTest,1);
toeZn        = simlog_toe(IndZnNoSteer);
camberZn     = simlog_camber(IndZnNoSteer);

%% Get index for measurement at specific toe angles: neg, zero, pos, 3*pos
% Find points with smallest difference to desired toe angle
[toeZ0nDiff, iZ0tn]   = min(abs(simlog_toe(indCasterZ0)+qToeMeas));
[toeZ0zDiff, iZ0tz]   = min(abs(simlog_toe(indCasterZ0)));
[toeZ0pDiff, iZ0tp]   = min(abs(simlog_toe(indCasterZ0)-qToeMeas));
[toeZ03pDiff, iZ0t3p] = min(abs(simlog_toe(indCasterZ0)-qToeMeas*3));

% Add measured angle to difference to obtain measured toe angle
toeZ0n   = toeZ0nDiff - qToeMeas;
toeZ0z   = toeZ0zDiff; %#ok<NASGU> 
toeZ0p   = toeZ0pDiff + qToeMeas;
toeZ03p  = toeZ03pDiff+ qToeMeas*3;

% Find camber at those positions
camberZ0n  = simlog_camber(indCasterZ0(1)+iZ0tn-1);
camberZ0p  = simlog_camber(indCasterZ0(1)+iZ0tp-1);
camberZ03p = simlog_camber(indCasterZ0(1)+iZ0t3p-1);


%% Calculate Caster: Design position
% Use toe positions T1 = -T2 to cancel out effect of steering axis inclination
casterZ0        =  atan2d(sind(camberZ0n)-sind(camberZ0p),sind(toeZ0p)-sind(toeZ0n));
casterZ0_alt    = 180/pi*(     camberZ0n -     camberZ0p)/(    toeZ0p -     toeZ0n );  %#ok<NASGU> % Assumes sin(x) = x
% Alternate calculation assumes sin(x) = x

%% Calculate KPI: Design position
% This estimation uses the z axis of the wheel spin frame.  For standard
% vehicle suspensions, it has a higher error percentage due to the small
% variation in camber angle.  Calculation is kept here as a reference.
% Recommend using same calculation based on x-axis of wheel spin frame.

% Calculations based on SAE Technical Paper Series 850219
% https://disco3.co.uk/gallery/albums/userpics/24543/steering-geometry-and-caster-measurement%5B1%5D.pdf

% Select toe angle points to use for KPI calculation
C1  = camberZ0p;
C2  = camberZ03p;
T1  = toeZ0p;
T2  = toeZ03p;
sC1 = sind(C1); sC2 = sind(C2); sT1 = sind(T1); sT2 = sind(T2);
cC1 = cosd(C1); cC2 = cosd(C2); cT1 = cosd(T1); cT2 = cosd(T2);

% Calculate steering axis inclination
kpiZ0_zAxis     = -atand((-tand(casterZ0)+(sC1-sC2)/(    sT2-    sT1))*(    sT2-    sT1)/(    cT2-    cT1)); %#ok<NASGU> 
kpiZ0_zAxis_alt = -atand((-tand(casterZ0)+(sC1-sC2)/(cC2*sT2-cC1*sT1))*(cC2*sT2-cC1*sT1)/(cC2*cT2-cC1*cT1)); %#ok<NASGU> 
% Alternate calculation cosine of camber is nearly 1

%% Calculate KPI: Design position, X-axis
% This estimation uses the x axis of the wheel spin frame.  The x-axis
% sweeps a larger angle and has less numerical error than the z-axis
% calculation shown above.

% Calculations based on SAE Technical Paper Series 850219
% https://disco3.co.uk/gallery/albums/userpics/24543/steering-geometry-and-caster-measurement%5B1%5D.pdf

% Find "camber angle" using x-axis of spin frame
camberXZ03p   = simlog_camberX(indCasterZ0(1)+iZ0t3p-1); %#ok<NASGU> 
camberXZ0p    = simlog_camberX(indCasterZ0(1)+iZ0tp-1);
camberXZ0z    = simlog_camberX(indCasterZ0(1)+iZ0tz-1); %#ok<NASGU> 
camberXZ0n    = simlog_camberX(indCasterZ0(1)+iZ0tn-1);
% Find "toe angle" using x-axis of spin frame
toeXZ03p      = simlog_toeX(indCasterZ0(1)+iZ0t3p-1); %#ok<NASGU> 
toeXZ0p       = simlog_toeX(indCasterZ0(1)+iZ0tp-1);
toeXZ0z       = simlog_toeX(indCasterZ0(1)+iZ0tz-1); %#ok<NASGU> 
toeXZ0n       = simlog_toeX(indCasterZ0(1)+iZ0tn-1);

% Select toe angle points to use for KPI calculation
C1 = camberXZ0p;
C2 = camberXZ0n;
T1 = toeXZ0p;
T2 = toeXZ0n;
sC1 = sind(C1); sC2 = sind(C2); sT1 = sind(T1); sT2 = sind(T2);
cC1 = cosd(C1); cC2 = cosd(C2); cT1 = cosd(T1); cT2 = cosd(T2);

% Calculate steering axis inclination
kpiZ0        = -atand((-tand(casterZ0)+(sC1-sC2)/(    sT2-    sT1))*(    sT2-    sT1)/(    cT2-    cT1));
kpiZ0_alt    = -atand((-tand(casterZ0)+(sC1-sC2)/(cC2*sT2-cC1*sT1))*(cC2*sT2-cC1*sT1)/(cC2*cT2-cC1*cT1)); %#ok<NASGU> 
% Alternate calculation cosine of camber is nearly 1

%% Calculate Caster at positive vertical wheel displacement
[toeZpnDiff, iZptn] = min(abs(simlog_toe(indCasterZp)+qToeMeas));
[toeZppDiff, iZptp] = min(abs(simlog_toe(indCasterZp)-qToeMeas));
toeZpn = toeZpnDiff-qToeMeas;
toeZpp = toeZppDiff+qToeMeas;

camberZpn       = simlog_camber(indCasterZp(1)+iZptn-1);
camberZpp       = simlog_camber(indCasterZp(1)+iZptp-1);

casterZp        =  atan2d(sind(camberZpn)-sind(camberZpp),sind(toeZpp)-sind(toeZpn));
casterZp_alt    = 180/pi*(     camberZpn -     camberZpp)/(    toeZpp -     toeZpn ); %#ok<NASGU>
% Alternate calculation assumes sin(x) = x

%% Calculate Caster at negative vertical wheel displacement
[toeZnnDiff, iZntn] = min(abs(simlog_toe(indCasterZn)+qToeMeas));
[toeZnpDiff, iZntp] = min(abs(simlog_toe(indCasterZn)-qToeMeas));
toeZnn = toeZnnDiff-qToeMeas;
toeZnp = toeZnpDiff+qToeMeas;

camberZnn       = simlog_camber(indCasterZn(1)+iZntn-1);
camberZnp       = simlog_camber(indCasterZn(1)+iZntp-1);

casterZn        =  atan2d(sind(camberZnn)-sind(camberZnp),sind(toeZnp)-sind(toeZnn));
casterZn_alt    = 180/pi*(     camberZnn -     camberZnp)/(    toeZnp -     toeZnn ); %#ok<NASGU> 
% Alternate calculation assumes sin(x) = x

%% Calculate Bump Steer, Camber, Caster
bumpSteer    = (toeZp-toeZn)      /(2*zOffsetBumpTest);
bumpCamber   = (camberZp-camberZn)/(2*zOffsetBumpTest);
bumpCaster   = (casterZp-casterZn)/(2*zOffsetBumpTest);

Values = [...
    toeZ0,camberZ0,casterZ0,kpiZ0,...
    bumpSteer,bumpCamber,bumpCaster]';
Names = [...
    "Toe","Camber","Caster","KPI",...
    "Bump Steer","Bump Camber","Bump Caster"]';
Units = [...
    "deg","deg","deg","deg",...
    "deg/m","deg/m","deg/m"]';

bumpPrefix = ['+/- ' num2str(zOffsetBumpTest*1000) 'mm, '];
Description = [...
    "+Toe In","+Top Out","+Top Rear of WC","+Top Inside Bottom",...
    bumpPrefix + "+Toe In",bumpPrefix + "+Top Out",bumpPrefix + "+Caster Decrease"]';

TSuspMetrics = table(Names,Values,Units,Description);



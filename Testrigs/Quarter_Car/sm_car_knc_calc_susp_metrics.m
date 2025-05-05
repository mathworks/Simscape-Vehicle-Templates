function TSuspMetrics = sm_car_knc_calc_susp_metrics(simlog_toe,...
    simlog_camber,simlog_toeX,simlog_camberX,simlog_toeR,...
    simlog_pxTire, simlog_pyTire, simlog_pzTire, ...
    testPhases,qToeMeas,zOffsetBumpTest,simlog_t,wCtrZ,simlog_rigFz,...
    simlog_fBumpstop,simlog_xSpring,simlog_xRack,simlog_FRack,simlog_aWheel,...
    simlog_trqTz,simlog_fLat,simlog_fLong,simlog_yCPtch,...
    veh_track,veh_wheelbase,veh_mass,tireK,showPlots)
% sm_car_calc_susp_metrics Calculates suspension metrics
%    TSuspMetrics = sm_car_calc_susp_metrics(...)
%    This function calculates various suspension metrics. It requires
%    measurements from a quarter or half-car testrig that is exercised with
%    a certain sequence of wheel height and steering.
%
%       simlog_toe       Toe (left) measured using z axis of wheel spin frame (deg)
%       simlog_camber    Camber measured using z axis of wheel spin frame (deg)
%       simlog_toeX      Toe measured using x axis of wheel spin frame  (deg)
%       simlog_toeR      Toe (right) measured using z axis of wheel spin frame (deg)
%       simlog_camberX   Camber measured using z axis of wheel spin frame (deg)
%       simlog_pxTire    Position of wheel center in global X-frame (m)
%       simlog_pyTire    Position of wheel center in global Y-frame (m)
%       simlog_pzTire    Position of wheel center in global Z-frame (m)
%       testPhases       Time periods [start finish] for each phase of test (sec)
%       qToeMeas         Toe angle used for caster angle calculation (deg)
%       zOffsetBumpTest  Height for calculating bump steer, bump camber, ... (m)
%       simlog_t         Simulation time
%       wCtrZ            Height of wheel center (m)
%       simlog_rigFz     Force required to raise testrig post (N)
%       simlog_fBumpstop Force measured at bumpstop
%       simlog_xSpring   Spring extension used to calculate spring ratio (m)
%       simlog_xRack     Steering rack displacement (m)
%       simlog_FRack     Force required to move rack (N)
%       simlog_aWheel    Steering wheel angle  (rad)
%       simlog_trqTz     Aligning torque (N*m)
%       simlog_fLat      Lateral Force applied by testrig (N)
%       simlog_fLong     Longitudinal Force applied by testrig (N)
%       simlog_yCPtch    Displacement at contact patch along global y (m)
%       veh_track        Track of vehicle (m)
%       veh_wheelbase    Wheelbase of vehicle (m)
%       showPlots        true or false to show plots detailing calculations

% Copyright 2018-2024 The MathWorks, Inc.

%% Get indices for each phase of simulation results
indToeCamb   = intersect(find(simlog_t>=testPhases.Jounce(1)),find(simlog_t<=testPhases.Rebound(2)));
indCasterZ0  = intersect(find(simlog_t>=testPhases.Bumpz0(1)),find(simlog_t<=testPhases.Bumpz0(2)));
indCasterZp  = intersect(find(simlog_t>=testPhases.Bumpzp(1)),find(simlog_t<=testPhases.Bumpzp(2)));
indCasterZn  = intersect(find(simlog_t>=testPhases.Bumpzn(1)),find(simlog_t<=testPhases.Bumpzn(2)));
indBump      = intersect(find(simlog_t>=testPhases.Jounce(1)),find(simlog_t<=testPhases.Jounce(2)));
indRebound   = intersect(find(simlog_t>=testPhases.Rebound(1)),find(simlog_t<=testPhases.Rebound(2)));
indRoll      = intersect(find(simlog_t>=testPhases.Rollp(1)),find(simlog_t<=testPhases.Rolln(2)));
indATInPhs   = intersect(find(simlog_t>=testPhases.AlignTrqIn(1)), find(simlog_t<=testPhases.AlignTrqIn(2)));
indATOutPhs  = intersect(find(simlog_t>=testPhases.AlignTrqOut(1)),find(simlog_t<=testPhases.AlignTrqOut(2)));
indLAInPhs   = intersect(find(simlog_t>=testPhases.LatFrcIn(1)), find(simlog_t<=testPhases.LatFrcIn(2)));
indLAOutPhs  = intersect(find(simlog_t>=testPhases.LatFrcOut(1)),find(simlog_t<=testPhases.LatFrcOut(2)));
indLOBrk     = intersect(find(simlog_t>=testPhases.LongFrcBrk(1)),find(simlog_t<=testPhases.LongFrcBrk(2)));
indLOAcc     = intersect(find(simlog_t>=testPhases.LongFrcAcc(1)),find(simlog_t<=testPhases.LongFrcAcc(2)));

% For finding indices where tire is going up or going down
indTCUp      = find(diff(simlog_pzTire(indToeCamb))>0);
indTCDown    = find(diff(simlog_pzTire(indToeCamb))<0);
 testIndsTCUp   = indToeCamb(indTCUp);
 testIndsTCDown = indToeCamb(indTCDown);

% For finding indices where steer is increasing or decreasing
if(length(simlog_aWheel)>1)
    indQStUp        = find(diff(simlog_aWheel(indCasterZ0))>0);
    indQStDown      = find(diff(simlog_aWheel(indCasterZ0))<0);
    testIndsQStUp   = indCasterZ0(indQStUp);
    testIndsQStDown = indCasterZ0(indQStDown);
end

% Prepare the data used to find required toe and camber angles
% Sort measured data by tire height and remove duplicates
[simlog_pzTireTCsrt, iTCsrt] = unique(simlog_pzTire(indToeCamb),'sorted');
simlog_toeTC                 = simlog_toe(indToeCamb);
simlog_toeTCsrt              = simlog_toeTC(iTCsrt);
simlog_camberTC              = simlog_camber(indToeCamb);
simlog_camberTCsrt           = simlog_camberTC(iTCsrt);

simlog_pxTireTC              = simlog_pxTire(indToeCamb);
simlog_pxTireTCsrt           = simlog_pxTireTC(iTCsrt);
simlog_pyTireTC              = simlog_pyTire(indToeCamb);
simlog_pyTireTCsrt           = simlog_pyTireTC(iTCsrt);

simlog_xSpringTC             = simlog_xSpring(indToeCamb);
simlog_xSpringTCsrt          = simlog_xSpringTC(iTCsrt);

simlog_fBumpstopTC           = simlog_fBumpstop(indToeCamb);
simlog_fBumpstopTCsrt        = simlog_fBumpstopTC(iTCsrt);

%% Obtain Toe, Camber: Design position
% Use all points during both sweeps
toeZ0    = interp1(simlog_pzTireTCsrt-wCtrZ,simlog_toeTCsrt,0,'spline');
camberZ0 = interp1(simlog_pzTireTCsrt-wCtrZ,simlog_camberTCsrt,0,'spline');

%% Obtain Toe, Camber: Height is +offset for bump test
toeZp    = interp1(simlog_pzTireTCsrt,simlog_toeTCsrt,   wCtrZ+zOffsetBumpTest);
camberZp = interp1(simlog_pzTireTCsrt,simlog_camberTCsrt,wCtrZ+zOffsetBumpTest);

%% Obtain Toe, Camber: Height is -offset for bump test
toeZn    = interp1(simlog_pzTireTCsrt,simlog_toeTCsrt,   wCtrZ-zOffsetBumpTest);
camberZn = interp1(simlog_pzTireTCsrt,simlog_camberTCsrt,wCtrZ-zOffsetBumpTest);

%% Debug plots
if(showPlots)
    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h1_knc_toe_camber';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))

    subplot(121)
    plot(simlog_toeTCsrt,simlog_pzTireTCsrt-wCtrZ,'DisplayName','')
    hold on
    plot(toeZp, zOffsetBumpTest,'rx')
    plot(toeZ0, 0              ,'rx')
    plot(toeZn,-zOffsetBumpTest,'rx')
    hold off
    title('Toe Curve')
    xlabel ('Toe (deg)')
    ylabel ('Suspension Travel (m)')
    subplot(122)
    plot(simlog_camberTCsrt,simlog_pzTireTCsrt-wCtrZ)
    hold on
    plot(camberZp, zOffsetBumpTest,'rx')
    plot(camberZ0, 0              ,'rx')
    plot(camberZn,-zOffsetBumpTest,'rx')
    hold off
    title('Camber Curve')
    xlabel ('Camber (deg)')
    ylabel ('Suspension Travel (m)')
end

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

%% Calculate Camber Change with Road Wheel Angle Change: Design position
camPerToe  = (camberZ0p-camberZ0n)/(toeZ0p-toeZ0n);

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

% Find point in test where toe is closest to desired toe angles (+ and -)
[toeZpnDiff, iZptn] = min(abs(simlog_toe(indCasterZp)+qToeMeas));
[toeZppDiff, iZptp] = min(abs(simlog_toe(indCasterZp)-qToeMeas));
toeZpn = toeZpnDiff-qToeMeas;
toeZpp = toeZppDiff+qToeMeas;

% Find camber at those points
camberZpn       = simlog_camber(indCasterZp(1)+iZptn-1);
camberZpp       = simlog_camber(indCasterZp(1)+iZptp-1);

% Use toe and camber angles to calculate caster
casterZp        =  atan2d(sind(camberZpn)-sind(camberZpp),sind(toeZpp)-sind(toeZpn));
casterZp_alt    = 180/pi*(     camberZpn -     camberZpp)/(    toeZpp -     toeZpn ); %#ok<NASGU>
% Alternate calculation assumes sin(x) = x

%% Calculate Caster at negative vertical wheel displacement

% Find point in test where toe is closest to desired toe angles (+ and -)
[toeZnnDiff, iZntn] = min(abs(simlog_toe(indCasterZn)+qToeMeas));
[toeZnpDiff, iZntp] = min(abs(simlog_toe(indCasterZn)-qToeMeas));
toeZnn = toeZnnDiff-qToeMeas;
toeZnp = toeZnpDiff+qToeMeas;

% Find camber at those points
camberZnn       = simlog_camber(indCasterZn(1)+iZntn-1);
camberZnp       = simlog_camber(indCasterZn(1)+iZntp-1);

% Use toe and camber angles to calculate caster
casterZn        =  atan2d(sind(camberZnn)-sind(camberZnp),sind(toeZnp)-sind(toeZnn));
casterZn_alt    = 180/pi*(     camberZnn -     camberZnp)/(    toeZnp -     toeZnn ); %#ok<NASGU>
% Alternate calculation assumes sin(x) = x

%% Calculate Bump Steer, Camber, Caster
% Change in toe, camber, caster / change in post height
bumpSteer    = (toeZp-toeZn)      /(2*zOffsetBumpTest);
bumpCamber   = (camberZp-camberZn)/(2*zOffsetBumpTest);
bumpCaster   = (casterZp-casterZn)/(2*zOffsetBumpTest);

%% Debug plots
if(showPlots)
    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h2_knc_bump_kpi';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    temp_colororder = get(gca,'defaultAxesColorOrder');

    % Plot Toe Angle from 3 steering tests - design position, bump up, bump down
    plot(simlog_t(indCasterZp)-simlog_t(indCasterZp(1)),simlog_toe(indCasterZp),'.','LineWidth',2,'DisplayName','Toe, z+')
    hold on
    plot(simlog_t(indCasterZn)-simlog_t(indCasterZn(1)),simlog_toe(indCasterZn),'.','LineWidth',2,'DisplayName','Toe, z-')
    plot(simlog_t(indCasterZ0)-simlog_t(indCasterZ0(1)),simlog_toe(indCasterZ0),'.','LineWidth',2,'DisplayName','Toe, z0')

    % Plot Camber Angle from 3 steering tests
    plot(simlog_t(indCasterZp)-simlog_t(indCasterZp(1)),simlog_camber(indCasterZp),'.','Color',temp_colororder(1,:),'LineWidth',2,'DisplayName','Camber, z+')
    plot(simlog_t(indCasterZn)-simlog_t(indCasterZn(1)),simlog_camber(indCasterZn),'.','Color',temp_colororder(2,:),'LineWidth',2,'DisplayName','Camber, z-')
    plot(simlog_t(indCasterZ0)-simlog_t(indCasterZ0(1)),simlog_camber(indCasterZ0),'.','Color',temp_colororder(3,:),'LineWidth',2,'DisplayName','Camber, z0')

    % Plot points used to calculate caster angle
    plot(simlog_t(indCasterZp(1)+iZptp-1)-simlog_t(indCasterZp(1)),   simlog_toe(indCasterZp(1)+iZptp-1),'bd','MarkerSize',8,'DisplayName','Toe, z+, +q');
    plot(simlog_t(indCasterZp(1)+iZptp-1)-simlog_t(indCasterZp(1)),simlog_camber(indCasterZp(1)+iZptp-1),'bd','MarkerSize',8,'DisplayName','Cam, z+, +q');
    plot(simlog_t(indCasterZp(1)+iZptn-1)-simlog_t(indCasterZp(1)),   simlog_toe(indCasterZp(1)+iZptn-1),'bs','MarkerSize',8,'DisplayName','Toe, z+, -q');
    plot(simlog_t(indCasterZp(1)+iZptn-1)-simlog_t(indCasterZp(1)),simlog_camber(indCasterZp(1)+iZptn-1),'bs','MarkerSize',8,'DisplayName','Cam, z+, -q');

    plot(simlog_t(indCasterZn(1)+iZntp-1)-simlog_t(indCasterZn(1)),   simlog_toe(indCasterZn(1)+iZntp-1),'rd','MarkerSize',8,'DisplayName','Toe, z-, +q');
    plot(simlog_t(indCasterZn(1)+iZntp-1)-simlog_t(indCasterZn(1)),simlog_camber(indCasterZn(1)+iZntp-1),'rd','MarkerSize',8,'DisplayName','Cam, z-, +q');
    plot(simlog_t(indCasterZn(1)+iZntn-1)-simlog_t(indCasterZn(1)),   simlog_toe(indCasterZn(1)+iZntn-1),'rs','MarkerSize',8,'DisplayName','Toe, z-, -q');
    plot(simlog_t(indCasterZn(1)+iZntn-1)-simlog_t(indCasterZn(1)),simlog_camber(indCasterZn(1)+iZntn-1),'rs','MarkerSize',8,'DisplayName','Cam, z-, -q');

    % Plot points used to calculate kingpin inclination, z-axis equations
    plot(simlog_t(indCasterZ0(1)+iZ0t3p-1)-simlog_t(indCasterZ0(1)),   simlog_toe(indCasterZ0(1)+iZ0t3p-1),'ko','MarkerSize',8,'DisplayName','Toe, z0, +3q');
    plot(simlog_t(indCasterZ0(1)+iZ0t3p-1)-simlog_t(indCasterZ0(1)),simlog_camber(indCasterZ0(1)+iZ0t3p-1),'ko','MarkerSize',8,'DisplayName','Cam, z0, +3q');

    hold off
    title('Data For Estimating Caster Angle')
    xlabel('Time (s) within Steer Event')
    ylabel('Angle (deg)')
    legend('Location','Best')

    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h3_knc_kpi_xaxis';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    % Plot angles using x-axis of spin frame
    plot(simlog_t(indCasterZ0)-simlog_t(indCasterZ0(1)),simlog_toeX(indCasterZ0),'.','LineWidth',2,'DisplayName','Toe X, z0')
    hold on
    plot(simlog_t(indCasterZ0)-simlog_t(indCasterZ0(1)),simlog_camberX(indCasterZ0),'.','Color',temp_colororder(1,:),'LineWidth',2,'DisplayName','Camber X, z0')

    % Plot points used to calculate kingpin inclination using x-axis of spin frame
    plot(simlog_t(indCasterZ0(1)+iZ0tp-1)-simlog_t(indCasterZ0(1)),   simlog_toeX(indCasterZ0(1)+iZ0tp-1),'bd','MarkerSize',8,'DisplayName','Toe, z0, +q');
    plot(simlog_t(indCasterZ0(1)+iZ0tp-1)-simlog_t(indCasterZ0(1)),simlog_camberX(indCasterZ0(1)+iZ0tp-1),'bd','MarkerSize',8,'DisplayName','Cam, z0, +q');
    plot(simlog_t(indCasterZ0(1)+iZ0tn-1)-simlog_t(indCasterZ0(1)),   simlog_toeX(indCasterZ0(1)+iZ0tn-1),'bs','MarkerSize',8,'DisplayName','Toe, z0, -q');
    plot(simlog_t(indCasterZ0(1)+iZ0tn-1)-simlog_t(indCasterZ0(1)),simlog_camberX(indCasterZ0(1)+iZ0tn-1),'bs','MarkerSize',8,'DisplayName','Cam, z0, -q');

    hold off
    title('Data For Estimating Kingpin Inclination, Spin X-Axis')
    xlabel('Time (s) within Steer Event')
    ylabel('Angle (deg)')
    legend('Location','Best')
end

%% Steer Axis at Wheel Center Height
% Find point on steering axis that intersects
% a plane parallel to ground that contains the wheel center

% Range of wc movement to check
wcRangeX = 0.01;

% Find indices for range of steering test at design position
indStrAxPt   = intersect(...
    find(simlog_pxTire(indCasterZ0)>= (simlog_pxTire(1)-wcRangeX)),...
    find(simlog_pxTire(indCasterZ0)<= (simlog_pxTire(1)+wcRangeX)));
AxisPtInds = indCasterZ0(indStrAxPt);

% Obtain center of circle
% Ignores z-axis: Assumes symmetry about vertical axis due to small rotation of steer axis
circParam = CircleFitByPratt([simlog_pxTire(AxisPtInds) simlog_pyTire(AxisPtInds)]);

% Steer axis point
strAxisPt_des = [circParam(1) circParam(2) simlog_pzTire(1)];

%% Hub Level Lateral Offset
% Lateral offset between intersection of steering axis with
% plane parallel to ground at wheel center height

hubLatOffset = (simlog_pyTire(1)-strAxisPt_des(2))*1000;

%% Hub Level Longitudinal Offset
% Longitudinal offset between intersection of steering axis with
% plane parallel to ground at wheel center height

hubLongOffset = (simlog_pxTire(1)-strAxisPt_des(1))*1000;

%% Find Caster Trail
% Longitudinal offset between intersection of steering axis with ground
% and contact patch.
% * Positive caster trail: forward of contact patch
% * Positive caster angle: top of axis rearward from wheel center
casterTrail = hubLongOffset+tand(casterZ0)*strAxisPt_des(3)*1000;

%% Find Scrub Radius / King Pin Offset
% Lateral offset between intersection of steering axis with ground
% and contact patch
% * Positive king pin inclination: top of axis closer to vehicle center
% * Positive caster angle: top rearward from wheel center

% abs() makes it valid for left and right side
% tand() handles left and right side correctly
scrubRadius = abs(hubLatOffset)-(tand(kpiZ0)*strAxisPt_des(3))*1000;

%% Debug plot
if(showPlots)
    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h4_knc_steer_axis_hub';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    temp_colororder = get(gca,'defaultAxesColorOrder');
    % Negative sign used on lateral coordinates so that *left* wheel is shown
    % Positive Scrub Radius is *inside* wheel
    plot(-simlog_pyTire(1), simlog_pxTire(1),'o','MarkerSize',12,'DisplayName','Wheel Center')
    hold on
    plot(-simlog_pyTire(AxisPtInds), simlog_pxTire(AxisPtInds),'.','Color',temp_colororder(1,:),'DisplayName','Path of Wheel Center')
    plot(-strAxisPt_des(2),strAxisPt_des(1),'kx','MarkerSize',12,'DisplayName','Estimated Steering Axis Point')
    plot(-[simlog_pyTire(1) strAxisPt_des(2)],[simlog_pxTire(1) simlog_pxTire(1)],'b--','DisplayName','Hub Offset, Lateral')
    plot(-[strAxisPt_des(2) strAxisPt_des(2)],[simlog_pxTire(1) strAxisPt_des(1)],'r--','DisplayName','Hub Offset, Longitudinal')
    plot(-[strAxisPt_des(2) simlog_pyTire(1)-scrubRadius/1000],[strAxisPt_des(1) simlog_pxTire(1)+casterTrail/1000],'r-.s','DisplayName','Steering Axis')
    plot(-[simlog_pyTire(1)-scrubRadius/1000 simlog_pyTire(1)-scrubRadius/1000],[simlog_pxTire(1) simlog_pxTire(1)+casterTrail/1000],'g--','DisplayName','Caster Trail')
    plot(-[simlog_pyTire(1) simlog_pyTire(1)-scrubRadius/1000],[simlog_pxTire(1)+casterTrail/1000 simlog_pxTire(1)+casterTrail/1000],'k--','DisplayName','Scrub Radius')
    hold off
    title('Top View, Left Wheel')
    axis equal
    xlabel('Vehicle Lateral Axis (m)')
    ylabel('Vehicle Forward Axis (m)')
    grid on
    legend('Location','Best')
    ylim = get(gca,'YLim');
    yrange = ylim(2)-ylim(1);
    set(gca,'YLim',[ylim(1)-0.1*yrange ylim(2)+0.1*yrange])

    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h5_knc_steer_axis_wheel';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    % Circle for wheel
    qSet = linspace(0,2*pi,100);
    sVec = sin(qSet);
    cVec = cos(qSet);
    plot3([simlog_pxTire(1) simlog_pxTire(1)],[simlog_pyTire(1) simlog_pyTire(1)],[simlog_pzTire(1)*2 0],'-o','DisplayName','Wheel Vertical Axis')
    hold on
    % Positive Scrub Radius is *inside* wheel
    plot3([strAxisPt_des(1) simlog_pxTire(1)+casterTrail/1000],[strAxisPt_des(2) simlog_pyTire(1)-scrubRadius/1000],[simlog_pzTire(1) 0],'s-.','Color','r','DisplayName','Steering Axis')
    plot3(sVec*simlog_pzTire(1),ones(size(sVec))*simlog_pyTire(1),(1+cVec)*simlog_pzTire(1),'-','Color',[0.6 0.6 0.6],'LineWidth',6,'DisplayName','Tire');
    xlabel('Longitudinal');ylabel('Lateral');zlabel('Vertical')
    title('Steering Axis')
    hold off
    view(gca,[-77 17])
    axis equal
    box on
    grid on
    view(-48,20)
    legend('Location','eastoutside')
end
%% Suspension Rate
% ------ Direct measurement, affected by hysteresis due to damping
simlog_rigFzTC    = simlog_rigFz(indToeCamb);
simlog_rigFzTCsrt = simlog_rigFzTC(iTCsrt);

zForSuspRate = 20e-3; % m

fzp20mmA  = interp1(simlog_pzTireTCsrt,simlog_rigFzTCsrt, wCtrZ+zForSuspRate);
fzn20mmA  = interp1(simlog_pzTireTCsrt,simlog_rigFzTCsrt, wCtrZ-zForSuspRate);

suspRateA = (fzp20mmA-fzn20mmA)/(zForSuspRate*2) / 1e3; % N/mm

% ------ Method to find quasi-static answer
% Get post height during increasing and decreasing post height
[PzPzUp, iunU] = unique(simlog_pzTire(testIndsTCUp));
[PzPzDn, iunD] = unique(simlog_pzTire(testIndsTCDown));

% Sample normal force during increasing and decreasing post height
FzTCUp = simlog_rigFz(testIndsTCUp(iunU));
FzTCDn = simlog_rigFz(testIndsTCDown(iunD));

% Find common range of height sampled during increase and decrease
PzMax     = min(max(PzPzUp),max(PzPzDn));
PzMin     = max(min(PzPzUp),min(PzPzDn));

% Sample testrig post force for test phases with increasing and decreasing post height
PzSamplePts = linspace(PzMin,PzMax,100);
FzPzUpSamp = interp1(PzPzUp,FzTCUp,PzSamplePts);
FzPzDnSamp = interp1(PzPzDn,FzTCDn,PzSamplePts);

% Average both curves to obtain testrig post force without hysteresis
FzAvg = mean([FzPzUpSamp;FzPzDnSamp]);

% Find testrig post force at positive and negative offset
fzp20mm  = interp1(PzSamplePts,FzAvg, wCtrZ+zForSuspRate);
fzn20mm  = interp1(PzSamplePts,FzAvg, wCtrZ-zForSuspRate);

% Calculate suspension rate  (Change in Force / Change in post height)
suspRate = (fzp20mm-fzn20mm)/(zForSuspRate*2) / 1e3; % N/mm

%% Ride Rate
% Ride rate includes spring and tire stiffness. Since the spring and tire
% stiffness are in series, use formula to obtain stiffness of two springs
% in series (1/kTotal) = (1/kSpring + 1/kTire)

rideRate = 1/(1/suspRate + 1/(tireK/1e3)); % N/mm

%% Ride Frequency
% Use total stiffness and 1/4 of vehicle mass
rideFreq = sqrt(rideRate/(veh_mass/4));

%% Wheel Travel
% Find indices where endstop force is non-zero
indTravelBump    = find(simlog_fBumpstop(indBump)>0.1,1);
indTravelRebound = find(simlog_fBumpstop(indRebound)<-0.1,1);

if(~isempty(indTravelBump))
    % pz when Jounce/Bump endstop force is non-zero - start height
    zBump     = simlog_pzTire(indBump(indTravelBump))-simlog_pzTire(1);
else
    % Bump stop not reached
    zBump = nan;
end

if(~isempty(indTravelRebound))
    % pz when Rebound endstop force is non-zero - start height
    zRebound  = simlog_pzTire(indRebound(indTravelRebound))-simlog_pzTire(1);
else
    % Rebound stop not reached
    zRebound = nan;
end

% Total wheel travel
zTotal    = zBump - zRebound;

%% Debug plot
if(showPlots)
    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h6_knc_normal_force';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))

    indTravelBumpSrt    = find(simlog_fBumpstopTCsrt>0.1);
    indTravelReboundSrt = find(simlog_fBumpstopTCsrt<-0.1);

    indBumpstopAll = union(indTravelBumpSrt,indTravelReboundSrt);

    plot(simlog_pzTireTCsrt,simlog_rigFzTCsrt,'.','DisplayName','Normal Force')
    hold on
    plot(PzSamplePts,FzAvg,'r','DisplayName','Avg')
    if(~isempty(indBumpstopAll))
        hold on
        plot(simlog_pzTireTCsrt(indBumpstopAll),   simlog_rigFzTCsrt(indBumpstopAll),'ro','DisplayName','Bumpstop')
        hold off
    end
    title('Normal Force vs. Displacement');
    xlabel('Vertical Displacement (m)');
    ylabel('Normal Force (N)');
    legend('Location','Best')
    text(0.05,0.95,'If this plot is noisy, reduce damping in shock absorber.',...
        'Color',[0.6 0.6 0.6],'Units','Normalized')

end

%% Wheel Center Recession

% Find lateral and longitudinal displacement of wheel center when post is
% at positive and negative levels for bump test
WCRecLongp     = interp1(simlog_pzTireTCsrt,simlog_pxTireTCsrt, wCtrZ+zOffsetBumpTest);
WCRecLatp      = interp1(simlog_pzTireTCsrt,simlog_pyTireTCsrt, wCtrZ+zOffsetBumpTest);
WCRecLongn     = interp1(simlog_pzTireTCsrt,simlog_pxTireTCsrt, wCtrZ-zOffsetBumpTest);
WCRecLatn      = interp1(simlog_pzTireTCsrt,simlog_pyTireTCsrt, wCtrZ-zOffsetBumpTest);

% Recession is (Change in Wheel Center Position/Change in Post Height)
WCRecLong = (WCRecLongp - WCRecLongn)/(zOffsetBumpTest*2);
WCRecLat  = (WCRecLatp  - WCRecLatn )/(zOffsetBumpTest*2);

%% Spring Ratio, Damper Ratio

% Find Spring length when post is at positive and negative levels for bump test
sprRatp   = interp1(simlog_pzTireTCsrt,simlog_xSpringTCsrt, wCtrZ+zOffsetBumpTest);
sprRatn   = interp1(simlog_pzTireTCsrt,simlog_xSpringTCsrt, wCtrZ-zOffsetBumpTest);

% Ratio is (Change in Spring Length / Change in Post Height)
sprRat    = (sprRatn - sprRatp)/(zOffsetBumpTest*2);

% Find Damper length when post is at positive and negative levels for bump test
damRatp   = interp1(simlog_pzTireTCsrt,simlog_xSpringTCsrt, wCtrZ+zOffsetBumpTest);
damRatn   = interp1(simlog_pzTireTCsrt,simlog_xSpringTCsrt, wCtrZ-zOffsetBumpTest);

% Ratio is (Change in Damper Length / Change in Post Height)
damRat    = (damRatn - damRatp)/(zOffsetBumpTest*2);

%% -- Roll KnC
% Prepare the data used to find required toe and camber angles
% Sort measured data by tire height and remove duplicates
[simlog_pzTireROsrt, iROsrt] = unique(simlog_pzTire(indRoll),'sorted');
simlog_toeRO                 = simlog_toe(indRoll);
simlog_toeROsrt              = simlog_toeRO(iROsrt);
simlog_camberRO              = simlog_camber(indRoll);
simlog_camberROsrt           = simlog_camberRO(iROsrt);
simlog_rigFzRO               = simlog_rigFz(indRoll);
simlog_rigFzROsrt            = simlog_rigFzRO(iROsrt);

%% Obtain Toe, Camber: + 2deg Roll
if(~isempty(simlog_pzTireROsrt))
    
    AngleForRollTest = 2;
    pzRoll   = tand(AngleForRollTest)*simlog_pyTire(1);
    toeROZp    = interp1(simlog_pzTireROsrt,simlog_toeROsrt,   wCtrZ+pzRoll);
    camberROZp = interp1(simlog_pzTireROsrt,simlog_camberROsrt,wCtrZ+pzRoll);


    %% Obtain Toe, Camber: - 2deg Roll
    toeROZn    = interp1(simlog_pzTireTCsrt,simlog_toeTCsrt,   wCtrZ-pzRoll);
    camberROZn = interp1(simlog_pzTireTCsrt,simlog_camberTCsrt,wCtrZ-pzRoll);

    %% Roll Steer
    rollSteer   = toeROZp    - toeROZn;
    rollCamber  = camberROZp - camberROZn;

    %% Roll Stiffness
    fzp2deg  = interp1(simlog_pzTireROsrt,simlog_rigFzROsrt, wCtrZ+pzRoll);
    fzn2deg  = interp1(simlog_pzTireROsrt,simlog_rigFzROsrt, wCtrZ-pzRoll);

    rollStiffness = (fzp2deg-fzn2deg)*(simlog_pyTire(1))/(AngleForRollTest*2); % N*m/deg

    %% Roll Stiffness (Total)
    rollStiffnessTotal = 1/(1/rollStiffness + 1/(tireK*(simlog_pyTire(1))/(AngleForRollTest*2))); % N/mm 

else
    % No data for right side means quarter-car test
    % Return not-a-number for roll metrics
    rollSteer     = NaN;
    rollCamber    = NaN;
    rollStiffness = NaN;
    rollStiffnessTotal = NaN;
end

%% --Steer KnC

%% Rack Travel
if (length(simlog_xRack) == 1)
    % No steering, set max rack travel to 0
    rackMax = 0;
else
    % Find maximum rack travel during Jounce/Rebound test
    rackMax = max(simlog_xRack(indCasterZ0))*1000;
end

%% Steering Ratio at 20 deg Toe
qToeStrRatio = 20;

[simlog_toeZ0srt, iZ0srt] = unique(simlog_toe(indCasterZ0),'sorted');
if(length(simlog_aWheel)==1)
    steerRatio = 0;
    toeRZ0ToeL20 = 0;
else
    % Obtain points for steering test
    simlog_aWheelZ0           = simlog_aWheel(indCasterZ0)*180/pi; % Convert to deg
    simlog_aWheelZ0srt        = simlog_aWheelZ0(iZ0srt);

    % Get steering angle during increasing steer and decreasing steer
    [qStQstUp, iunUp]   = unique(simlog_aWheel(testIndsQStUp)*180/pi);
    [qStQstDn, iunDn]   = unique(simlog_aWheel(testIndsQStDown)*180/pi);

    % Sample toe angle during increasing steer and decreasing steer
    toeZ0QstUp = simlog_toe(testIndsQStUp(iunUp));
    toeZ0QstDn = simlog_toe(testIndsQStDown(iunDn));

    % Find range of steering angle sampled during increase and decrease
    qStMax     = min(max(qStQstUp),max(qStQstDn));
    qStMin     = max(min(qStQstUp),min(qStQstDn));

    % Sample toe angle for increasing steer and decreasing steer
    qStrSamplePts = linspace(qStMin,qStMax,100);
    toeZ0QstUpSamp = interp1(qStQstUp,toeZ0QstUp,qStrSamplePts);
    toeZ0QstDnSamp = interp1(qStQstDn,toeZ0QstDn,qStrSamplePts);
    % Average both curves to obtain toe angle without hysteresis
    toeZ0Avg = mean([toeZ0QstUpSamp;toeZ0QstDnSamp]);

    % Obtain steering ratio
    steerZ0StrRat    = interp1(toeZ0Avg,qStrSamplePts, qToeStrRatio);

    % Ratio omits signs so it is applicable to left or right wheel
    steerRatio = abs(steerZ0StrRat/qToeStrRatio);

    if(length(simlog_toeR)==1)
        % Quarter car model, right toe not measured
        % Supply zeros so calculation can complete
        toeRZ0ToeL20 = 0;
    else
        toeRZ0QstUp = simlog_toeR(testIndsQStUp(iunUp));
        toeRZ0QstDn = simlog_toeR(testIndsQStDown(iunDn));

        % Get both toe angles when inner toe angle is 20 deg
        % (RIGHT) Sample toe angle for increasing steer and decreasing steer
        toeRZ0QstUpSamp = interp1(qStQstUp,toeRZ0QstUp,qStrSamplePts);
        toeRZ0QstDnSamp = interp1(qStQstDn,toeRZ0QstDn,qStrSamplePts);
        % Average both curves to obtain toe angle without hysteresis
        toeRZ0Avg = mean([toeRZ0QstUpSamp;toeRZ0QstDnSamp]);

        qAckMeas = 20;
        toeRZ0ToeL20  = interp1(toeZ0Avg, toeRZ0Avg, -qAckMeas);
    end
end

%% Max Toe Angles
[maxToeOut,~] = min(simlog_toe(indCasterZ0)); % min: toe out is negative
[maxToeIn ,~] = max(simlog_toe(indCasterZ0)); % max: toe in is positive

%% Ackermann at Inner Wheel = 20 deg, Max Inner Wheel
if(toeRZ0ToeL20 == 0)
    % If right toe angle is 0 when left is 20 degrees, right toe was not measured
    % Do not report an Ackermann percentage
    pcntAck20deg = NaN;
    pcntAckMx    = NaN;
else
    % Inner Wheel = 20 deg
    qInn = qAckMeas;     % Angle of inner wheel
    qOut = toeRZ0ToeL20; % Angle of outer wheel

    % Ackermann angle of inner wheel using outer wheel angle
    qAck = atand(veh_wheelbase/(veh_wheelbase/tand(qOut) - veh_track));

    % Percentage of Ackermann angle for inner wheel
    % 0 percent if parallel, 100% if ideal ackermann angle
    pcntAck20deg = (qInn-qOut)/(qAck-qOut)*100;

    % Max Inner Wheel
    qInnMx = abs(toeZ0Avg(end));  % Angle of inner wheel
    qOutMx = toeRZ0Avg(end); % Angle of outer wheel

    % Ackermann angle of inner wheel using outer wheel angle
    qAckMx = atand(veh_wheelbase/(veh_wheelbase/tand(qOutMx) - veh_track));

    % Percentage of Ackermann angle for inner wheel
    % 0 percent if parallel, 100% if ideal ackermann angle
    pcntAckMx = (qInnMx-qOutMx)/(qAckMx-qOutMx)*100;
    
end

%%  Total Cornering Diameter
% Use max steering angle to determine turning radius
if(toeRZ0ToeL20 == 0)
    % No toe angle for right wheel, return 0
    turnCornDia = 0;
    turnCornDiaK2K = 0;
else
    % Standard turn cornering diameter formula to centerline
    maxToe = (abs(toeZ0Avg(end))+abs(toeRZ0Avg(end)))/2;
    turnCornDia = 2*veh_wheelbase/(sqrt(2-2*cosd(maxToe)));

    % Standard turn cornering diameter formula to outer front wheel
    turnCornDiaK2K = 2*(veh_wheelbase/sind(abs(toeRZ0Avg(end)))+hubLatOffset/1000);
end

%% Rack Loads
% Find ratio from steering wheel to rack travel
if (length(simlog_xRack) == 1)
    % No steering, set max rack force to NaN
    FRackMax  = NaN;
else
    % Check aligning torque and lateral force tests
    indsForFRack = [indATInPhs; indATOutPhs; indLAInPhs; indLAOutPhs];

    if(~isempty(indsForFRack))
    % Find maximum force magnitude
        FRackMax  = max(abs(simlog_FRack(indsForFRack)))/1000;
    else
        % Aligning torque and lateral force tests not run
        % Return 0
        FRackMax = 0;
    end
end


%% Debug Plots
if(showPlots && length(simlog_aWheel)>1)
    % Reuse figure if it exists, else create new figure
    fig_handle_name =   'h7_knc_steer_ratio';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))

    plot(simlog_toeZ0srt,simlog_aWheelZ0srt*(sign(steerZ0StrRat/qToeStrRatio)),'.');
    hold on
    plot(toeZ0Avg,qStrSamplePts*(sign(steerZ0StrRat/qToeStrRatio)),'r');
    plot(qToeStrRatio,steerZ0StrRat*(sign(steerZ0StrRat/qToeStrRatio)),'ro')
    hold off
    title('Steering Ratio')
    text(0.05,0.95,['Steering Ratio: ' num2str(steerRatio)],'Units','Normalized')

    xlabel('Toe Angle (deg)')
    ylabel('Steering Wheel Angle (deg)')
    grid on
end

%% Aligning Torque Test
% Max Change in Steer under Aligning Torque
if(~isempty(indATInPhs))
    % Find toe angle at max in-phase and max out-of-phase aligning torque
    SteerALInPhs  = interp1(simlog_t(indATInPhs), simlog_toe(indATInPhs), (simlog_t(indATInPhs(1)) +simlog_t(indATInPhs(2))) /2);
    SteerALOutPhs = interp1(simlog_t(indATOutPhs),simlog_toe(indATOutPhs),(simlog_t(indATOutPhs(1))+simlog_t(indATOutPhs(2)))/2);

    % Find max applied torque
    trqZ = simlog_trqTz(indATInPhs(1));

    % Change in Toe Angle / Applied Torque
    toeAlignTrqInPhs     = (SteerALInPhs -toeZ0)/(trqZ/1000);
    toeAlignTrqOutPhs    = (SteerALOutPhs-toeZ0)/(trqZ/1000);
else
    % If aligning torque test not performed, report not-a-number
    toeAlignTrqInPhs = NaN;
    toeAlignTrqOutPhs = NaN;
end

%% Lateral Force Test
% Lateral Compliance Steer - In phase, anti phase
if(~isempty(indLAInPhs))
    % Find toe angle at max in-phase and max out-of-phase lateral force
    toeLAInPhs  = interp1(simlog_t(indLAInPhs), simlog_toe(indLAInPhs), (simlog_t(indLAInPhs(1)) +simlog_t(indLAInPhs(2))) /2);
    toeLAOutPhs = interp1(simlog_t(indLAOutPhs),simlog_toe(indLAOutPhs),(simlog_t(indLAOutPhs(1))+simlog_t(indLAOutPhs(2)))/2);

    % Find max applied lateral force
    fLat = abs(simlog_fLat(indLAInPhs(1)));

    % Change in Toe Angle / Applied Lateral Force
    toeFLatInPhs     = (toeLAInPhs -toeZ0)/(fLat/1000);
    toeFLatOutPhs    = (toeLAOutPhs-toeZ0)/(fLat/1000);
else
    % If lateral compliance test not performed return not-a-number
    toeFLatInPhs = NaN;
    toeFLatOutPhs = NaN;
end

%% Camber Compliance - In phase, anti phase
if(~isempty(indLAInPhs))
    % Find camber angle at max in-phase and max out-of-phase lateral force
    camberLAInPhs  = interp1(simlog_t(indLAInPhs), simlog_camber(indLAInPhs), (simlog_t(indLAInPhs(1)) +simlog_t(indLAInPhs(2))) /2);
    camberLAOutPhs = interp1(simlog_t(indLAOutPhs),simlog_camber(indLAOutPhs),(simlog_t(indLAOutPhs(1))+simlog_t(indLAOutPhs(2)))/2);

    % Change in Camber Angle / Applied Lateral Force
    camFLatInPhs     = (camberLAInPhs -camberZ0)/(fLat/1000);
    camFLatOutPhs    = (camberLAOutPhs-camberZ0)/(fLat/1000);
else
    % If lateral compliance test not performed return not-a-number
    camFLatInPhs = NaN;
    camFLatOutPhs = NaN;
end

%% Lateral Compliance Wheel Center - In phase, anti phase
if(~isempty(indLAInPhs))
    % Find lateral movement of wheel center 
    % at max in-phase and max out-of-phase lateral force    
    pytireLAInPhs  = interp1(simlog_t(indLAInPhs), simlog_pyTire(indLAInPhs), (simlog_t(indLAInPhs(1)) +simlog_t(indLAInPhs(2))) /2);
    pytireLAOutPhs = interp1(simlog_t(indLAOutPhs),simlog_pyTire(indLAOutPhs),(simlog_t(indLAOutPhs(1))+simlog_t(indLAOutPhs(2)))/2);

    % Deflection of wheel center / Applied Lateral Force
    pytireFLatInPhs     = (pytireLAInPhs -simlog_pyTire(1))*1000/(fLat/1000);
    pytireFLatOutPhs    = (pytireLAOutPhs-simlog_pyTire(1))*1000/(fLat/1000);
else
    % If lateral compliance test not performed return not-a-number
    pytireFLatInPhs = NaN;
    pytireFLatOutPhs = NaN;
end

%% Lateral Compliance Contact Patch - In phase, anti phase
if(~isempty(indLAInPhs))
    % Find lateral movement of contact patch
    % at max in-phase and max out-of-phase lateral force    
    pyCptchLAInPhs  = interp1(simlog_t(indLAInPhs), simlog_yCPtch(indLAInPhs), (simlog_t(indLAInPhs(1)) +simlog_t(indLAInPhs(2))) /2);
    pyCptchLAOutPhs = interp1(simlog_t(indLAOutPhs),simlog_yCPtch(indLAOutPhs),(simlog_t(indLAOutPhs(1))+simlog_t(indLAOutPhs(2)))/2);

    % Deflection of contact patch / Applied Lateral Force
    pyCPtchFLatInPhs     = (pyCptchLAInPhs -simlog_yCPtch(1))*1000/(fLat/1000);
    pyCPtchFLatOutPhs    = (pyCptchLAOutPhs-simlog_yCPtch(1))*1000/(fLat/1000);
else
    % If lateral compliance test not performed return not-a-number    
    pyCPtchFLatInPhs = NaN;
    pyCPtchFLatOutPhs = NaN;
end

%% Longitudinal Compliance Steer, Braking, and Tracking
if(~isempty(indLOBrk))
    % Find toe angle at max braking force and max accel force
    aToeLOBrk  = interp1(simlog_t(indLOBrk), simlog_toe(indLOBrk), (simlog_t(indLOBrk(1)) +simlog_t(indLOBrk(2))) /2);
    aToeLOAcc  = interp1(simlog_t(indLOAcc), simlog_toe(indLOAcc), (simlog_t(indLOAcc(1)) +simlog_t(indLOAcc(2))) /2);

    % Find max braking and accel forces
    fLongBrk = abs(simlog_fLong(indLOBrk(1)));
    fLongAcc = abs(simlog_fLong(indLOAcc(1)));

    % (Braking) Change in Toe Angle / Max Braking  Force
    LongCompStrBrk       = (aToeLOBrk-toeZ0)/(fLongBrk/1000);

    % (Tracking) Change in Toe Angle / Change in longitinal force
    LongCompStrTrk       = (aToeLOBrk-aToeLOAcc)/((fLongAcc+fLongBrk)/1000);

    % Change in wheel center longitudinal position / Max Braking Force
    wcLongCompBrk = (abs(simlog_pxTire(indLOBrk(1)))-simlog_pxTire(indToeCamb(1)))/(fLongBrk/1000);

else
    % If longitudinal compliance test not performed return not-a-number
    LongCompStrBrk = NaN;
    LongCompStrTrk = NaN;
    wcLongCompBrk  = NaN;
end

%% Summarize Results
Values = [...
    toeZ0,camberZ0,casterZ0,kpiZ0,...
    camPerToe,...
    bumpSteer,bumpCamber,bumpCaster,...
    casterTrail,scrubRadius,...
    hubLongOffset,hubLatOffset,...
    suspRate,rideRate,rideFreq,...
    zBump,zRebound,zTotal,...
    WCRecLong,WCRecLat,...
    sprRat,damRat,...
    rollSteer,rollCamber,rollStiffness,rollStiffnessTotal,...
    rackMax,steerRatio,...
    maxToeOut,maxToeIn,...
    pcntAck20deg,pcntAckMx,...
    turnCornDiaK2K,...
    FRackMax,...
    toeAlignTrqInPhs,toeAlignTrqOutPhs,...
    toeFLatInPhs,toeFLatOutPhs,...
    camFLatInPhs,camFLatOutPhs,...
    pytireFLatInPhs,pytireFLatOutPhs,...
    pyCPtchFLatInPhs,pyCPtchFLatOutPhs,...
    LongCompStrBrk,LongCompStrTrk,...
    wcLongCompBrk...
    ]';
Names = [...
    "Toe","Camber","Caster","KPI",...
    "Camber Change per Toe Change",...
    "Bump Steer","Bump Camber","Bump Caster",...
    "Caster Trail","Scrub Radius",...
    "Hub Long Offset","Hub Lat Offset",...
    "Suspension Rate","Ride Rate","Ride Frequency",...
    "Wheel Travel Bump","Wheel Travel Rebound","Wheel Travel Total",...
    "WC Recession Long", "WC Recession Lat",...
    "Spring Ratio","Damper Ratio",...
    "Roll Steer","Roll Camber","Roll Stiffness","Roll Stiffness Total",...
    "Max Rack Travel","Steering Ratio",...
    "Max Toe Out","Max Toe In",...
    "Ackermann at 20 deg Inner","Ackermann at Max Inner"...
    "TCD Kerb to Kerb",...
    "Max Rack Force",...
    "Toe/Align Torque (In)", "Toe/Align Torque (Out)",...
    "Toe/Lat Force (In)","Toe/Lat Force (Out)",...
    "Camber/Lat Force (In)","Camber/Lat Force (Out)"...
    "Lat Compliance WCtr/Lat Force (In)","Lat Compliance WCtr/Lat Force (Out)"...
    "Lat Compliance CP/Lat Force (In)","Lat Compliance CP/Lat Force (Out)",...
    "Long Compliance Steer Braking","Long Compliance Steer Tracking",...
    "WC Long Compliance"
    ]';
Units = [...
    "deg","deg","deg","deg",...
    "deg/deg",...
    "deg/m","deg/m","deg/m",...
    "mm", "mm",...
    "mm", "mm",...
    "N/mm","N/mm","Hz",...
    "mm", "mm", "mm",...
    "mm/m", "mm/m",...
    "1", "1",...
    "deg","deg","N*m/deg","N*m/deg",...
    "mm","1",...
    "deg","deg",...
    "%","%",...
    "m",...
    "kN",...
    "deg/kN","deg/kN",...
    "deg/kN","deg/kN",...
    "deg/kN","deg/kN",...
    "mm/kN","mm/kN",...
    "mm/kN","mm/kN"...
    "deg/kN","deg/kN",...
    "mm/kN"...
    ]';

bumpPrefix = ['+/- ' num2str(zOffsetBumpTest*1000) 'mm, '];
Description = [...
    "+Toe In","+Top Out","+Top Rear of WC","+Top Inside Bottom",...
    "+/-" + num2str(qToeMeas) + " deg",...
    bumpPrefix + "+Toe In",bumpPrefix + "+Top Out",bumpPrefix + "+Caster Decrease",...
    "+Forward of Contact Patch","+Inside Wheel Center",...
    "+Forward of WC","+Inside Wheel Center", ...
    "+/-20mm, Wheel Center","+/-20mm, Contact Patch","Uses Ride Rate",...
    "Up","Down","Up+Down",...
    "+Backwards","+In",...
    "Spring Disp/WC Disp","Damper Disp/WC Disp",...
    "+/-2deg Roll, +Toe In","+/-2deg Roll, +Top Out","+/-2deg Roll, Wheel Center","+/-2deg Roll, Contact Patch",...
    "Rack Travel at Max Steer","Handwheel Angle/Toe Angle, 20 deg Toe",...
    "+Toe In","+Toe In",...
    "0% if parallel, 100% if ideal","0% if parallel, 100% if ideal",...
    "To Outer Front Wheel",...
    "From Applied Forces and Torques",...
    "In Phase","Out Phase",...
    "In Phase","Out Phase",...
    "In Phase","Out Phase",...
    "In Phase","Out Phase",...
    "In Phase","Out Phase"...
    "0:1kN, +Toe In","-1:+1kN, +Toe In",...
    "0:-1kN"...
    ]';

TSuspMetrics = table(Names,Values,Units,Description);



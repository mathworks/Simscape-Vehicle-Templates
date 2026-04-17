function maneuver_data = sm_car_maneuverdata_knc_sweepjouncesteer(varargin)

maneuver_type = 'JounceSteerSweep';

% Input Params
if(nargin == 0)
    % Generate test sequences for all vehicle classes in Simscape Vehicle Templates
    Instance_List = {...
        'Sedan_Hamba','Sedan_HambaLG','SUV_Landy','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};
    Jounce       =  [   0.14  0.22  0.16  0.15  0.22  0.22  0.05];  % m
    Rebound      =  [  -0.15 -0.15 -0.12 -0.10 -0.15 -0.15 -0.03];  % m
    zBumpHeight  =  zeros(size(Instance_List));  % m
    qSteerCaster =  [   0.95  0.95  1.30  0.95  0.95  0.95  0.95];  % rad
else
    % Generate custom test sequences
    Instance_List = {'Custom'};
    Jounce       =  varargin{1};  % m
    Rebound      =  varargin{2};  % m
    qSteerCaster =  varargin{3};  % rad
% Likely not needed as custom inputs
%{ 
    zBumpHeight  =  varargin{4};  % m
    Roll         =  varargin{5};  % m
    tAlign       =  varargin{6};  % N*m
    fLong        =  varargin{7};  % N
    fLat         =  varargin{8};  % N
    fLatCO       =  varargin{9};  % N
    fLongWC      =  varargin{10}; % N
    xCPOffset    =  varargin{11}; % m
%}
end

% Likely not needed as custom inputs
%{
Roll         =  zeros(size(Instance_List));  % m
tAlign       =  zeros(size(Instance_List));  % m
fLong        =  zeros(size(Instance_List));  % m
fLat         =  zeros(size(Instance_List));  % m
fLatCO       =  zeros(size(Instance_List));  % m
fLongWC      =  zeros(size(Instance_List));  % m
%}
xCPOffset    =  ones(size(Instance_List))*-0.3;  % m

% Durations for pieces of test (sec)
durSettleInit = 5;   % Long to let bushings settle
durInitReb    = 5;
durRebJnce    = 10;  % Move posts to z upper limit
durStrStep    = 5;
durSettle     = 0.5; 


%jncVec = [0;0;Rebound(i); 

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type      = maneuver_type;
    mdata.(Instance).Instance  = Instance;

    mdata.(Instance).xCPOffset = xCPOffset(i);

    strPts = linspace(-1,1,21);
    strVec = [0;0;0;          reshape(repmat(strPts,4,1),[],1)];
    jncSet = repmat([[1 1 1 1]*Jounce(i) [1 1 1 1]*Rebound(i) ],1,(length(strPts)-1)/2); 
    jncSeq = [0 0 Rebound(i) Rebound(i) Rebound(i) jncSet Jounce(i) Jounce(i)];
    timSet = repmat([durRebJnce durSettle durStrStep durSettle],1,(length(strPts)-1));
    timSeq = [0 durSettleInit durInitReb durInitReb durSettleInit timSet durRebJnce durSettle];

    StrJnc_seq = [timSeq' jncSeq' strVec zeros(length(timSeq),5)];
    %StrJnc_timeline = cumsum(StrJnc_seq(:,1));

    t     = cumsum([StrJnc_seq(:,1)]);
    zWhlL =        [StrJnc_seq(:,2)];
    zWhlR =        [StrJnc_seq(:,2)];
    qStr  =        [StrJnc_seq(:,3)]*qSteerCaster(i);
    fxWhlL =       [StrJnc_seq(:,4)];
    fxWhlR =       [StrJnc_seq(:,4)];
    fyWhlL =       [StrJnc_seq(:,5)];
    fyWhlR =       [StrJnc_seq(:,5)];
    tzWhlL =       [StrJnc_seq(:,6)];
    tzWhlR =       [StrJnc_seq(:,6)];
    fcoyWhlL =     [StrJnc_seq(:,7)];
    fcoyWhlR =     [StrJnc_seq(:,7)];
    fwcxWhlL =     [StrJnc_seq(:,8)];
    fwcxWhlR =     [StrJnc_seq(:,8)];

    % Assemble structure
    mdata.(Instance).Steer.t.Value         = t;
    mdata.(Instance).Steer.t.Units         = 'sec';
    mdata.(Instance).Steer.t.Comments      = '';

    mdata.(Instance).Steer.aWheel.Value    = qStr;
    mdata.(Instance).Steer.aWheel.Units    = 'rad';
    mdata.(Instance).Steer.aWheel.Comments = '';

    mdata.(Instance).PostL1.t.Value         = t;
    mdata.(Instance).PostL1.t.Units         = 'sec';
    mdata.(Instance).PostL1.t.Comments      = '';
    mdata.(Instance).PostR1.t.Value         = t;
    mdata.(Instance).PostR1.t.Units         = 'sec';
    mdata.(Instance).PostR1.t.Comments      = '';

    mdata.(Instance).PostL1.z.Value         = zWhlL;
    mdata.(Instance).PostL1.z.Units         = 'm';
    mdata.(Instance).PostL1.z.Comments      = '';
    mdata.(Instance).PostR1.z.Value         = zWhlR;
    mdata.(Instance).PostR1.z.Units         = 'm';
    mdata.(Instance).PostR1.z.Comments      = '';

    mdata.(Instance).PostL1.fx.Value         = fxWhlL;
    mdata.(Instance).PostL1.fx.Units         = 'N';
    mdata.(Instance).PostL1.fx.Comments      = '';
    mdata.(Instance).PostR1.fx.Value         = fxWhlR;
    mdata.(Instance).PostR1.fx.Units         = 'N';
    mdata.(Instance).PostR1.fx.Comments      = '';

    mdata.(Instance).PostL1.fy.Value         = fyWhlL;
    mdata.(Instance).PostL1.fy.Units         = 'N';
    mdata.(Instance).PostL1.fy.Comments      = '';
    mdata.(Instance).PostR1.fy.Value         = fyWhlR;
    mdata.(Instance).PostR1.fy.Units         = 'N';
    mdata.(Instance).PostR1.fy.Comments      = '';

    mdata.(Instance).PostL1.tz.Value         = tzWhlL;
    mdata.(Instance).PostL1.tz.Units         = 'N*m';
    mdata.(Instance).PostL1.tz.Comments      = '';
    mdata.(Instance).PostR1.tz.Value         = tzWhlR;
    mdata.(Instance).PostR1.tz.Units         = 'N*m';
    mdata.(Instance).PostR1.tz.Comments      = '';

    mdata.(Instance).PostL1.fcoy.Value         = fcoyWhlL;
    mdata.(Instance).PostL1.fcoy.Units         = 'N*m';
    mdata.(Instance).PostL1.fcoy.Comments      = '';
    mdata.(Instance).PostR1.fcoy.Value         = fcoyWhlR;
    mdata.(Instance).PostR1.fcoy.Units         = 'N*m';
    mdata.(Instance).PostR1.fcoy.Comments      = '';

    mdata.(Instance).PostL1.fwcx.Value         = fwcxWhlL;
    mdata.(Instance).PostL1.fwcx.Units         = 'N*m';
    mdata.(Instance).PostL1.fwcx.Comments      = '';
    mdata.(Instance).PostR1.fwcx.Value         = fwcxWhlR;
    mdata.(Instance).PostR1.fwcx.Units         = 'N*m';
    mdata.(Instance).PostR1.fwcx.Comments      = '';

    mdata.(Instance).PostL2 = mdata.(Instance).PostL1;
    mdata.(Instance).PostR2 = mdata.(Instance).PostR1;
    mdata.(Instance).PostL3 = mdata.(Instance).PostL1;
    mdata.(Instance).PostR3 = mdata.(Instance).PostR1;

    mdata.(Instance).Brake.t.Value          = [0.00	max(t)];
    mdata.(Instance).Brake.t.Units          = 'sec';
    mdata.(Instance).Brake.t.Comments       = '';

    mdata.(Instance).Brake.rPedal.Value     = [0.00	0.00];
    mdata.(Instance).Brake.rPedal.Units     = '0-1';
    mdata.(Instance).Brake.rPedal.Comments  = '';

    mdata.(Instance).Accel.t.Value          = [0.00	max(t)];
    mdata.(Instance).Accel.t.Units          = 'sec';
    mdata.(Instance).Accel.t.Comments       = '';

    mdata.(Instance).Accel.rPedal.Value     = [0.00	0.00];
    mdata.(Instance).Accel.rPedal.Units     = '0-1';
    mdata.(Instance).Accel.rPedal.Comments  = '';
    
    mdata.(Instance).zOffsetBumpTest.Value     = zBumpHeight(i);
    mdata.(Instance).zOffsetBumpTest.Units     = 'm';
    mdata.(Instance).zOffsetBumpTest.Comments  = 'Height (+/-) to check bump steer, camber, caster';

    mdata.(Instance).qToeForCaster.Value     = 1;
    mdata.(Instance).qToeForCaster.Units     = 'deg';
    mdata.(Instance).qToeForCaster.Comments  = 'Toe angle (+/-) to check caster';

    mdata.(Instance).tRange.Jounce          = [inf inf];
    mdata.(Instance).tRange.Bumpzn          = [inf inf];

end

if(nargin==0)
    % Assemble structure with inputs for all vehicle classes
    maneuver_data.(maneuver_type) = mdata;
else
    % Return single structure for custom test sequence
    maneuver_data = mdata.(Instance);
end

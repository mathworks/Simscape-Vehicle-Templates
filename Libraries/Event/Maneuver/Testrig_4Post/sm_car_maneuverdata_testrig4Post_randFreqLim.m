function maneuver_data = sm_car_maneuverdata_testrig4Post_randFreqLim(varargin)
%sm_car_maneuverdata_testrig4Post_randFreqLim  Generate 4 post testrig test sequence
%   maneuver_data = sm_car_maneuverdata_testrig4Post_randFreqLim(varargin)
%   This function generates a test input sequence for the four post
%   testrig. Each wheel is excited with a random input within a specific
%   frequency range. If no arguments are provided, test input sequences for
%   each of the vehicle classes in the Simscape Vehicle Templates will be
%   produced. Providing optional input arguments will produce a test
%   sequence that uses the arguments to create signals for each post.
%
%       Fs            Sampling frequency (Hz)
%       T             Desired duration (sec)
%       buffer        Extra seconds at each end (sec)
%       f_low         Lower cutoff frequency (Hz)
%       f_high        Upper cutoff frequency (Hz)
%       amplitude     Desired amplitude (m)
%       order         Filter order
%
%  The output structure includes the parameters needed for Simulink blocks
%  to calculate the post height with respect to time. The acceleration,
%  brake, and steer inputs are set to zero.
%
%  The output is structure Maneuver.Post** (L1, R1, L2, R2, L3, R3) with fields
%              t.Value     Time vector (sec)
%              z.Value     Height vector (m)
%   InterpMethod.Value     String with interpolation method for Lookup Table block
%
%  You can use this function to create the MATLAB structure used to
%  parameterize the data-driven test sequence and then replace the time and
%  height values with your own data. Be sure to configure the model with
%  the "Testrig 4 Post Data" maneuver.
%  sm_car_config_maneuver('sm_car','Testrig 4 Post Data') 
%  Maneuver = sm_car_maneuverdata_testrig4Post_randFreqLim(100,20,2,0.5,5,0.05,4);
%
% Copyright 2018-2024 The MathWorks, Inc.

maneuver_type = 'Testrig4Post_randFreqLim';

% Input Params
if(nargin == 0)
    % Generate test sequences for all vehicle classes in Simscape Vehicle Templates
    Instance_List = {...
        'Sedan_Hamba','Sedan_HambaLG','SUV_Landy','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};
    Fs        =  [100    100    100    100    100    100    100];     % Hz
    T         =  [ 20     20     20     20     20     20     20];     % sec
    buffer    =  [  2      2      2      2      2      2      2];  % sec
    f_low     =  [  0.5    0.5    0.5    0.5    0.5    0.5    0.5];  % Hz
    f_high    =  [  5      5      5      5      5      5      5];     % Hz
    amplitude =  [  0.05   0.05   0.05   0.05   0.05   0.05   0.05];     % m
    order     =  [  4      4      4      4      4      4      4];     % 1
else
    % Generate custom test sequences
    Instance_List = {'Custom'};
    Fs            =  varargin{1};  % sec
    T             =  varargin{2};  % 1
    buffer        =  varargin{3};  % m
    f_low         =  varargin{4};  % (0-1)
    f_high        =  varargin{5};  % sec
    amplitude     =  varargin{6};  % 1
    order         =  varargin{7};  % m
end

% Get input sequence for no accel, brake, or steer
ManNone = sm_car_maneuverdata_none;

% Assemble Maneuver
% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type      = maneuver_type;
    mdata.(Instance).Instance  = Instance;

    % 2. Design a bandpass Butterworth filter
    Wn = [f_low(i) f_high(i)] / (Fs(i)/2); % Normalized cutoff frequencies (0 to 1)
    try
        [b, a] = butter(order(i), Wn, 'bandpass');
    catch
        disp('Failed to use butter() to calculate filter coefficients, using defaults.')
        [b, a] = defaultFilterCoeffs;
    end

    T_total = T(i) + 2*buffer(i);
    N_total = T_total * Fs(i);  % Total number of samples

    for w_i = 1:6
        trimmed_signal = [];
        % Generate white noise for the extended duration
        raw_noise = randn(N_total,1);

        % Filter the noise to get band-limited signal
        try
            band_limited_signal = filtfilt(b, a, raw_noise);
        catch
            disp('Failed to use filtfilt(), using filter() instead.')
            band_limited_signal = filter(b, a, raw_noise);
        end

        % Trim off the first and last 'buffer' seconds
        idx_start = buffer(i)*Fs(i) + 1;
        idx_end = idx_start + T(i)*Fs(i) - 1;
        trimmed_signal = band_limited_signal(idx_start:idx_end);

        % Scale amplitude
        trimmed_signal = amplitude(i) * trimmed_signal / max(abs(trimmed_signal));

        % Smooth fade-in (half-cosine) at the start
        fade_samples = round(0.5 * Fs(i));  % Fade-in duration (0.5 seconds, adjust as needed)
        fade_in = 0.5 * (1 - cos(pi*(0:fade_samples-1)/(fade_samples-1))); % From 0 to 1
        first_val = trimmed_signal(fade_samples+1);

        % Create smooth transition from 0 to first_val
        transition = fade_in * first_val;

        % Replace the first 'fade_samples' with the transition
        trimmed_signal(1:fade_samples) = transition;
        trimmed_signal_set(:,w_i) = trimmed_signal;
    end

    t = (0:length(trimmed_signal)-1)/Fs(i);

    mdata.(Instance).PostL1.t.Value = t;
    mdata.(Instance).PostL1.z.Value = trimmed_signal_set(:,1);
    mdata.(Instance).PostL1.InterpMethod.Value = 'Cubic spline';
    mdata.(Instance).PostR1.t.Value = t;
    mdata.(Instance).PostR1.z.Value = trimmed_signal_set(:,2);
    mdata.(Instance).PostR1.InterpMethod.Value = 'Cubic spline';
    mdata.(Instance).PostL2.t.Value = t;
    mdata.(Instance).PostL2.z.Value = trimmed_signal_set(:,3);
    mdata.(Instance).PostL2.InterpMethod.Value = 'Cubic spline';
    mdata.(Instance).PostR2.t.Value = t;
    mdata.(Instance).PostR2.z.Value = trimmed_signal_set(:,4);
    mdata.(Instance).PostR2.InterpMethod.Value = 'Cubic spline';
    mdata.(Instance).PostL3.t.Value = t;
    mdata.(Instance).PostL3.z.Value = trimmed_signal_set(:,5);
    mdata.(Instance).PostL3.InterpMethod.Value = 'Cubic spline';
    mdata.(Instance).PostR3.t.Value = t;
    mdata.(Instance).PostR3.z.Value = trimmed_signal_set(:,6);
    mdata.(Instance).PostR3.InterpMethod.Value = 'Cubic spline';

    % Add zero inputs for accel, brake, and steer
    mdata.(Instance).Accel = ManNone.None.Default.Accel;
    mdata.(Instance).Accel.t.Value      = [0 t(end)];
    mdata.(Instance).Accel.rPedal.Value = mdata.(Instance).Accel.rPedal.Value(1:2);
    mdata.(Instance).Brake = ManNone.None.Default.Brake;
    mdata.(Instance).Brake.t.Value      = [0 t(end)];
    mdata.(Instance).Brake.rPedal.Value = mdata.(Instance).Brake.rPedal.Value(1:2);
    mdata.(Instance).Steer = ManNone.None.Default.Steer;
    mdata.(Instance).Steer.t.Value      = [0 t(end)];
    mdata.(Instance).Steer.aWheel.Value = mdata.(Instance).Steer.aWheel.Value(1:2);
end

if(nargin==0)
    % Assemble structure with inputs for all vehicle classes
    maneuver_data.(maneuver_type) = mdata;
else
    % Return single structure for custom test sequence
    maneuver_data = mdata.(Instance);
end

    function [b,a] = defaultFilterCoeffs
        % Default filter coefficients
        % Wn =[0.01 0.1], order = 4;
        % [b, a] = butter(order(i), Wn, 'bandpass');

        b=1.0e-04 *[...
            0.043726887978200
            0
           -0.174907551912800
            0
            0.262361327869201
            0
           -0.174907551912800
            0
            0.043726887978200]';
        a=[...
            1.000000000000000
           -7.738451142148341
           26.217221437958166
          -50.790566466086567
           61.540712220436276
          -47.755803181520804
           23.177953983526081
           -6.432685592228711
            0.781618740279003]';
    end
end
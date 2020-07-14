function [ outMF ] = mfeval(parameterSource, inputsMF, useMode)
%MFEVAL evaluates Magic Formula 5.2, 6.1 or 6.2 tyre models in steady state
%for series of input variables.
%
% outMF = mfeval(parameterSource, inputsMF, useMode)
%
% The formulation includes combined force/moment and turn slip
% calculations.
% ISO-W (TYDEX W) Contact-Patch Axis System coordinate system is used in
% all calculations.
% All the units will be SI (N,m,s,rad,kg)
%
% parameterSource refers to a MF-Tyre tyre property file (.TIR) containing
% all the Magic Formula coefficients or to a structure with all the
% parameters.
%
% inputsMF = [Fz kappa alpha gamma phit Vx P* omega*], where
% Fz     = normal load on the tyre  [N]
% kappa  = longitudinal slip        [dimensionless, -1: locked wheel]
% alpha  = side slip angle          [rad]
% gamma  = inclination angle        [rad]
% phit   = turn slip                [1/m]
% Vx     = forward velocity         [m/s]
% P*     = pressure                 [Pa]
% omega* = rotational speed         [rad/s]
%
% P* and omega* are optional inputs. If they are not included pressure is
% constant and equal to the inflation pressure on the TIR file and the
% rotational speed is approximated.
%
% useMode specifies the type of calculation performed:
%      1: combined force/moment calculation
%      2: combined force/moment calculation + turn slip
%    +10: revoke alpha_star definition
%    +20: include alpha_star definition
%   +100: include limit checks
%   +200: ignore limit checks
%
% For example: useMode = 121 implies:
%   -combined force/moment
%   -include alpha_star
%   -include limit checks
%
% For normal situations turn slip may be neglected, meaning that the radius
% of the path is close to infinity (straight line).
% Alpha_star improves the accuracy of the model for very large slip angles
% and possibly backward running of the wheel.
% The limit checks verify that the inputs are inside the stable range of
% the model.
%
% outMF consists of 30 columns:
% 1 - Fx: longitudinal force         16 - t: pneumatic trail
% 2 - Fy: lateral force              17 - mux: longitudinal friction coeff.
% 3 - Fz: normal force               18 - muy: lateral friction coeff.
% 4 - Mx: overturning moment         19 - omega: rot. speed
% 5 - My: rolling resistance moment  20 - Rl : loaded radius
% 6 - Mz: self aligning moment       21 - 2b: contact patch width
% 7 - kappa: longitudinal slip       22 - Mzr: residual torque
% 8 - alpha: side slip angle         23 - Cx: longitudinal stiffness
% 9 - gamma: inclination angle       24 - Cy: lateral stiffness
% 10 - phit: turn slip               25 - Cz: vertical stiffness
% 11 - Vx: longitudinal velocity     26 - Kya: cornering stiffness
% 12 - P: pressure                   27 - sigmax: long. relax. length
% 13 - Re: effective rolling radius  28 - sigmay: lat. relax. length
% 14 - rho: tyre deflection          29 - iKya: Instantaneous cornering stiff.
% 15 - 2a: contact patch length      30 - Kxk: slip stiffness
%
% The equations here presented are published in the book:
% Title:    	Tire and Vehicle Dynamics
% Author:       Hans Pacejka
% Edition:      3, revised
% Publisher:	Elsevier, 2012
% ISBN:         0080970176, 9780080970172
% Length:       672 pages
%
% And in the following paper:
% Besselink, I. J. M. , Schmeitz, A. J. C. and Pacejka, H. B.(2010) 'An
% improved Magic Formula/Swift tyre model that can handle inflation
% pressure changes', Vehicle System Dynamics, 48: 1, 337 — 352
% DOI: 10.1080/00423111003748088
% URL: http://dx.doi.org/10.1080/00423111003748088
%
% Code developed by:	Marco Furlan
% Email address:        marcofurlan92@gmail.com
%
% See the <a href="matlab:web(fullfile(mfevalroot, '..', 'doc','index.html'))">documentation</a> for more details and examples

%% Versions change log:
% Please refer to the documentation:
% "help mfeval" > click on the documentation hyperlink > Release Notes

% Declare extrinsic functions for C code generation
coder.extrinsic('warning')

% Check number of inputs and assign
narginchk(3, 3);

% Validate parameterSource
assert(isstruct(parameterSource) || ischar(parameterSource), ...
    'MFeval:ParameterSource:NotValid', 'parameterSource must be a char or struct');

% Validate inputsMF
assert(isnumeric(inputsMF) && isreal(inputsMF), ...
    'MFeval:inputsMF:NotValid', 'inputsMF must be numeric and real');

% Check the number of columns of inputsMF
[~,n] = size(inputsMF);

assert((n >= 6) && (n <= 8), ...
    'MFeval:inputsMF:NotValid', 'inputsMF should be an array between 6 to 8 columns');

% Validate useMode
assert(isnumeric(useMode) && isreal(useMode), ...
    'MFeval:useMode:NotValid', 'useMode must be numeric and real');

% Check the number of digits of useMode
numdigits_useMode = max(ceil(log10(abs(useMode))),1);

assert(numdigits_useMode == 3, ...
    'MFeval:useMode:NotValid', 'useMode should contain exactly 3 digits');

% Load the TIR file parameters
if ischar(parameterSource) % File location
    mfStruct = mfeval.readTIR(parameterSource); % Call an external function to read all the parameters of the TIR file.
else
    mfStruct = parameterSource; % Structure of parameter
end % If else

% Validate the Magic Formula Version
assert(isequal(mfStruct.FITTYP,61) || isequal(mfStruct.FITTYP,62) || isequal(mfStruct.FITTYP,6), ...
    'MFeval:parameterSource:NotValid', 'parameterSource is not compatible with Magic Formula 5.2, 6.1 or 6.2 \nCheck the value of FITTYP in the tyre property file (.tir)');

% Get the solver
solver = mfeval.Solver;

% Run solver
[outMF] = solver.fullSteadyState(mfStruct, inputsMF, useMode);

end % mfeval
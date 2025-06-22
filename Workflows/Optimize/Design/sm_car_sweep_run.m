function [simInput, simOut] = sm_car_sweep_run(mdl,Vehicle,par_list)

% Ensure model is open
open_system(mdl)
sm_car_config_variants(mdl);

%% Assemble combination of tests
numVals  = zeros(1,length(par_list));
for par_i = 1:length(par_list)
    numVals(par_i) = length(par_list(par_i).valueSet);
end

valCombs = generateCombinations(numVals);
numTests = size(valCombs,1);

%% Create Simulation Input Object
% Create empty set of inputs
clear simInput
simInput(1:numTests) = Simulink.SimulationInput(mdl);

% Loop to create simInput object (rows of valCombs)
testNum = 0;
for vc_i = 1:numTests
    testNum = testNum+1;
    % Loop over hps (columns of valCombs)
    UserString_SimInput = [];
    for par_i = 1:length(par_list)
        path2Val   = par_list(par_i).path2Val;

        % valCombs used to create combinations of each hp value
        axis_value = par_list(par_i).valueSet(valCombs(vc_i,par_i));

        % Set value within Vehicle data structure
        eval([path2Val ' = ' num2str(axis_value) ';']);
        UserString_SimInput = [UserString_SimInput ';' par_list(par_i).path2Val];

    end
    simInput(testNum) = setVariable(simInput(testNum),'Vehicle',Vehicle);
    simInput(testNum).UserString = UserString_SimInput(2:end);
end

%% Run simulations
clear simOut
simOut = sim(simInput,'ShowSimulationManager','on',...
    'ShowProgress','on','UseFastRestart','on');


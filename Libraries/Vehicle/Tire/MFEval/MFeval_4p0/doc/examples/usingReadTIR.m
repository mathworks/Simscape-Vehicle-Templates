%% Prepare inputs for mfeval
% Create some inputs for MFeval
inputs(:,1) = ones(100,1)*3000; % vertical load
inputs(:,2) = linspace(-0.3,0.3)'; % slip ratio
inputs(:,3) = ones(100,1)*0.02; % slip angle
inputs(:,4) = ones(100,1)*-0.03; % inclination angle
inputs(:,5) = zeros(100,1); % turn slip
inputs(:,6) = ones(100,1)*16; % forward speed

%% Read TIR file and save it as a structure
% Use readTIR to store the magic formula parameters in a structure
params = mfeval.readTIR('MagicFormula61_Paramerters.tir');

%% Compare performance
% Use a for loop to call mfeval using a structure and a string to compare
% the performance
for i = 1:10
    % Call mfeval using the structure of parameters and measure elapsed
    % time 
    tic % Start stopwatch timer
    out2 = mfeval(params, inputs, 111);
    t(i, 1) = toc; % Read elapsed time from stopwatch
    
    
    % Call mfeval using a string pointinf to the TIR file and measure
    % elapsed time
    tic % Start stopwatch timer
    out1 = mfeval('MagicFormula61_Paramerters.tir', inputs, 111);
    t(i, 2) = toc; % Read elapsed time from stopwatch
end

%% Plot results
% Display time elapsed of both methods
c = categorical({'Structure','Tir File'});
bar(c, mean(t))
ylabel('Elapsed time (s)')
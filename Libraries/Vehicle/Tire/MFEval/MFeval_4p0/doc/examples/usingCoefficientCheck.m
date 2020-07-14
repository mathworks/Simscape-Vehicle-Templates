%% Read TIR files
% Use readTIR to store the magic formula parameters into structures

modelA = mfeval.readTIR('Model_Unstable.tir');
modelB = mfeval.readTIR('MagicFormula61_Paramerters.tir');

%% Call to coefficientCheck
% Use coefficientCheck the check if the models are passing the restrictions
% explained in the Pacejka book

[resA, ~, ~] = mfeval.coefficientCheck(modelA);
[resB, ~, ~] = mfeval.coefficientCheck(modelB);

%% Check results

% Loop through the results for model A and display a message if a
% coefficient fails 
fields = fieldnames(resA);
for i = 1:numel(fields)
  if resA.(fields{i}) == 1
   fprintf([ 'Model A: Coeff. Fail: ' fields{i} '\n']);
  end
end

% Loop through the results for model A and display a message if a
% coefficient fails 
fields = fieldnames(resB);
for i = 1:numel(fields)
  if resB.(fields{i}) == 1
   fprintf([ 'Model B: Coeff. Fail: ' fields{i} '\n']);
  end
end
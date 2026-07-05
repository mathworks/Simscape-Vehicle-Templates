function sm_car_create_vehicle_values_only(Vehicle,outputFileName)
% Script: extractValuesWithUnits_singleline.m
% Reads 'input.m', extracts 'Value' assignments, 
% appends 'Units' as comments, and puts the value on the same line.

intermediateFile = 'Vehicle_Data_Full.m';
matlab.io.saveVariablesToScript(intermediateFile,'Vehicle')
inputFile = intermediateFile;
outputFile = outputFileName;

fid_in = fopen(inputFile, 'r');
fid_out = fopen(outputFile, 'w');

if fid_in == -1
    error('Could not open input file.');
end
if fid_out == -1
    error('Could not open output file.');
end

fileLines = {};
while ~feof(fid_in)
    fileLines{end+1} = fgetl(fid_in);
end
fclose(fid_in);

unitsMap = containers.Map; % Map from prefix to units

%omitFields = {'Opacity', 'Color', 'class', 'rho', 'Powertrain', 'Brakes'};
%omitFields = {'Opacity', 'Color', 'rho'};
omitFields = {'NoneZZ'};
isOmitted = @(prefix) any(cellfun(@(omit) contains(prefix, ['.' omit]), omitFields));

% First pass: collect all Units, except omitted fields
for i = 1:length(fileLines)
    line = strtrim(fileLines{i});
    unitMatch = regexp(line, '^(.*)\.Units\s*=\s*''([^'']*)'';', 'tokens');
    if ~isempty(unitMatch)
        prefix = unitMatch{1}{1};
        if ~isOmitted(prefix)
            units = unitMatch{1}{2};
            unitsMap(prefix) = units;
        end
    end
end

% Second pass: process Value assignments, except omitted fields
i = 1;
while i <= length(fileLines)
    line = fileLines{i};
    valueMatch = regexp(strtrim(line), '^(.*)\.Value\s*=\s*(.*)', 'tokens');
    if ~isempty(valueMatch)
        prefix = valueMatch{1}{1};
        if ~isOmitted(prefix)
            % Start building the value string
            valueStr = valueMatch{1}{2};
            % Remove trailing '...' if present
            valueStr = regexprep(valueStr, '\.\.\.\s*$', '');
            % Gather continuation lines if '...' was present
            while endsWith(strtrim(line), '...')
                i = i + 1;
                nextLine = strtrim(fileLines{i});
                % Remove trailing '...' from continuation lines
                nextLine = regexprep(nextLine, '\.\.\.\s*$', '');
                valueStr = [valueStr, ' ', nextLine];
                line = fileLines{i};
            end
            % Clean up extra spaces
            valueStr = strtrim(valueStr);
            % Remove any trailing semicolon(s)
            valueStr = regexprep(valueStr, ';+\s*$', '');
            % Find units if available
            units = '';
            if isKey(unitsMap, prefix)
                units = unitsMap(prefix);
            end
            commentStr = '';
            if ~isempty(units)
                commentStr = [' % Units: ' units];
            end
            % Write the assignment on a single line with ONE semicolon
            fprintf(fid_out, '%s.Value = %s;%s\n', prefix, valueStr, commentStr);
        end
    end
    i = i + 1;
end

fclose(fid_out);
disp('Single-line extraction complete. See output.m');
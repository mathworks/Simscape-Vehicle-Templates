function busNames = sm_car_build_bus_def(Input, busRoot, busSuffix)
% build a simulink bus definition from a structured list of signals
% e.g.
%   BusDefStruct.Bus1.signal1 = {};
%   BusDefStruct.Bus1.Bus2.signal1 = {};
%   BusDefStruct.Bus1.Bus2.signal2 = {};
%   BusDefStruct.Bus1.Bus2.signal3 = {};

%   busDef = sm_car_build_bus_def(BusDefStruct);
%

if nargin < 2
    busRoot = '';
end
if nargin < 3
    busSuffix = 'BusDef';
end

assert(isstruct(Input), 'Invalid input class')

busDef = Simulink.Bus;

fields = fieldnames(Input);

busNames = {};
for i = 1:numel(fields)
    field = fields{i};
    busDef.Elements(i) = Simulink.BusElement;
    busDef.Elements(i).Name = field;
    if isstruct(Input.(field))
        additionalBusNames = sm_car_build_bus_def(Input.(field), [busRoot, field], busSuffix);
        busNames = [busNames, {[busRoot, field, busSuffix]}, additionalBusNames];
        busDef.Elements(i).DataType = [busRoot, field, busSuffix];
    elseif ischar(Input.(field))
        busDef.Elements(i).DataType = [busRoot, Input.(field), busSuffix];
    elseif iscell(Input.(field))
        cellSigAttribs = Input.(field);
        for j = 1:2:numel(cellSigAttribs)
            name = cellSigAttribs{j};
            val = cellSigAttribs{j+1};
            switch name
                case 'Dimensions'
                    assert(isnumeric(val), ['Invalid data type for ', name]);
                case 'DimensionsMode'
                    assert(ischar(val), ['Invalid data type for ', name]);
                case 'DataType'
                    assert(ischar(val), ['Invalid data type for ', name]);
                case 'SampleTime'
                    assert(isnumeric(val), ['Invalid data type for ', name]);
                case 'Complexity'
                    assert(ischar(val), ['Invalid data type for ', name]);
                case 'Min'
                    assert(isnumeric(val), ['Invalid data type for ', name]);
                case 'Max'
                    assert(isnumeric(val), ['Invalid data type for ', name]);
                case 'DocUnits'
                    assert(ischar(val), ['Invalid data type for ', name]);
                case 'Description'
                    assert(ischar(val), ['Invalid data type for ', name]);
                otherwise
                    error('Invalid signal attribute');
            end
            busDef.Elements(i).(name) = val;
        end
    else
        error('invalid input');
    end
end

for i = 1:numel(busNames)
    assignin('caller', busNames{i}, eval(busNames{i}));
end
assignin('caller', [busRoot, busSuffix], busDef);

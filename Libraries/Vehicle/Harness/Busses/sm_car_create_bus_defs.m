function sm_car_create_bus_defs(Vehicle_DS)
% sm_car_create_bus_defs  Function to create bus objects for Simscape
% Vehicle models
%
% Bus objects are created in the workspace. Pass as argument the Vehicle
% data structure so that the objects are created match the selected
% variants.
%
% Useful commands
% >> sm_car_create_bus_defs(Vehicle);
% >> who *BusDef
% >> clear *BusDef

% Copyright 2019-2022 The MathWorks, Inc.

buses = sm_car_define_bus_defs(Vehicle_DS);

for field = fieldnames(buses)'
    bus = buses.(field{:});
    assignin('base','tempBus',bus)
    evalin('base',['sm_car_build_bus_def(tempBus,' '''' field{:} ''',''BusDef'');'])
    evalin('base','clear tempBus');
end


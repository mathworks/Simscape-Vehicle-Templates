function bushRes = sm_car_sim_res_bushings(logsout_sm_car)
%sm_car_sim_res_bushings - Extract bushing results from sm_car simulation
%    bushRes = sm_car_sim_res_bushings(logsout_sm_car)
%    This function extracts forces and deflections from the bushings in a
%    Simscape Vehicle Templates simulation. The function searches the front
%    and rear suspensions for specific names to know if it is a bushing and
%    extracts those results to a structure which it returns. Assumes that
%    bus elements in suspension models follow this naming convention.

bushNameTable = {...
    'UAf',     'Upper Front Inboard';
    'UAfO',    'Upper Front Outboard';
    'UAr',     'Upper Rear Inboard';
    'UArO',    'Upper Rear Outboard';
    'LAf',     'Lower Front Inboard';
    'LAfO',    'Lower Front Outboard';
    'LAr',     'Lower Rear Inboard';
    'LArO',    'Lower Rear Outboard';
    'LAc',     'Lower Center Inboard';
    'LAcO',    'Lower Center Outboard';
    'ShkT',    'Shock Top';
    'MntL',    'ARB Mount Left';
    'MntR',    'ARB Mount Right';
    'PanB',    'Panhard Rod Body';
    'PanA',    'Panhard Rod Axle';
    'TABL',    'Trailing Arm Body Left';
    'TABR',    'Trailing Arm Body Right';
    'DprBL',   'Damper Body Left';
    'DprBR',   'Damper Body Right';
    'DprAL',   'Damper Axle Left';
    'DprAR',   'Damper Axle Right';
    'DprTL',   'Damper Top Left';
    'DprTR',   'Damper Top Right';
    };

% Get bushing results from front suspension
if(isfield(logsout_sm_car.get('VehBus').Values.Chassis.SuspA1,'LinkageL'))
    bushRes.A1_L = extractResults(logsout_sm_car.get('VehBus').Values.Chassis.SuspA1.LinkageL,bushNameTable);
    bushRes.A1_R = extractResults(logsout_sm_car.get('VehBus').Values.Chassis.SuspA1.LinkageR,bushNameTable);
else
    bushRes.A1 = extractResults(logsout_sm_car.get('VehBus').Values.Chassis.SuspA1,bushNameTable);
end

% Get bushing results from front anti-roll bar
if(isfield(logsout_sm_car.get('VehBus').Values.Chassis.SuspA1,'AntiRollBar'))
    bushRes.A1_B = extractResults(logsout_sm_car.get('VehBus').Values.Chassis.SuspA1.AntiRollBar,bushNameTable);
end

% Get bushing results from Rear suspension
if(isfield(logsout_sm_car.get('VehBus').Values.Chassis.SuspA2,'LinkageL'))
    bushRes.A2_L = extractResults(logsout_sm_car.get('VehBus').Values.Chassis.SuspA2.LinkageL,bushNameTable);
    bushRes.A2_R = extractResults(logsout_sm_car.get('VehBus').Values.Chassis.SuspA2.LinkageR,bushNameTable);
else
    bushRes.A2 = extractResults(logsout_sm_car.get('VehBus').Values.Chassis.SuspA2,bushNameTable);
end

% Get bushing results from rear anti-roll bar
if(isfield(logsout_sm_car.get('VehBus').Values.Chassis.SuspA2,'AntiRollBar'))
    bushRes.A2_B = extractResults(logsout_sm_car.get('VehBus').Values.Chassis.SuspA2.AntiRollBar,bushNameTable);
end

% Prune empty fields - sometimes, bushings are not present
fn = fieldnames(bushRes);
% Find fields that are empty
emptyFields = fn(structfun(@isempty, bushRes));
% Remove them
bushRes = rmfield(bushRes, emptyFields);

end

function bushRes = extractResults(simRes,bushNameTable)
% extractResults  Extracts bushing simulation results

bushRes = []; % Default, no results are found

fNames = fieldnames(simRes);

% Loop over fieldnames
for fn_i = 1:length(fNames)

    % Search for field name in table
    tblIndex = find(strcmp(bushNameTable(:,1),fNames(fn_i)), 1);

    if(~isempty(tblIndex))

        % If field name is found, it is a bushing. 
        % Copy results to a local variable
        resNames = fieldnames(simRes.(fNames{fn_i}));
        for res_i = 1:length(resNames)
            % Get data only from each field
            bushSimRes = simRes.(fNames{fn_i}).(resNames{res_i}).Data;
            if(length(bushSimRes)>1)
                % If length is 1, value is a constant (0). Ignore it.
                % Otherwise, copy data only into local variable
                bushRes.(fNames{fn_i}).(resNames{res_i}) = bushSimRes;
            end
        end

        if(isfield(bushRes,(fNames{fn_i})))
            % If any dataset was longer than one, copy data name
            % from table into this portion of local variable
            bushRes.(fNames{fn_i}).Name = bushNameTable(tblIndex,2);
        end
    end
end

if(~isempty(tblIndex) && ~isempty(bushRes))
    % If bushing was found and any data has been found
    if(~isempty(fieldnames(bushRes.(fNames{fn_i}))))
        % If current bushing has any data, copy in time vector
        bushRes.Time = simRes.(fNames{fn_i}).(resNames{res_i}).Time;
    end
end

end


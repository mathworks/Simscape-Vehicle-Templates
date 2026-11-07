VDSets = {'AntiRollBar','BodyGeometry','DriverHuman','BodyLoad','Brakes',...
    'Dampers','Damper','Differential','Driveline','Driveshaft',...
    'Shaft','Linkage','Power','Springs','Steer',...
    'Susp','Tire','TireBody'};
VDSet  = VDSets{18};


% 'Passenger' - Type one level, classes in FL, FR, RL, RR
%     Aligns with "Human_Adult.slx model
% 'Damper' - DWDec Type on one level, classes in Heave, Roll
% 'Cooling' buried inside of Power
% 'SteerWheel' buried inside of Steer
% 'Spring' - DWDec Type on one level, classes in Heave, Roll
% 'Susp'  - Does not capture Linkage, Linkage_Decoupled
% JointInboard, Outboard buried in Driveline_Assembly

% 'Spring_LeftRight' ???
% 'Damper_LeftRight' ???
% Brake_Control - not covered, likely other controls

% 'Driveline'   - Aligns with Driveline_Axle1, Driveline_Axle2, Driveline_Axle3
% 'Driveshaft'  - Aligns with Driveshaft_Assembly.slx
% 'Shaft'       - Aligns with Driveshaft_Shaft.slx
% 'Linkage'     - Aligns with Linkage.slx, Linkage_Decoupled.slx
% 'Springs'     - Aligns with Springs_Axle1, Springs_Axle2, Springs_Axle3
% 'Steer'       - Aligns with Steer_Rack, Steer_Ackermann, Springs_Axle3 
% 'Tire'        - Aligns _1x, _2x, no CPI
% 'Brakes'      - Aligns with Brakes_Axle1, Brakes_Axle2, Brakes_Axle3
%       VDatabases missing PedalAbstract_Disc
% 'Dampers'     - Aligns with Dampers_Axle1, Dampers_Axle2, Brakes_Axle3
     
instNames = fieldnames(VDatabase.(VDSet));

abNameStr = [];
typeStr   = [];
classStr  = [];
enumStr  = [];
for i = 1:length(instNames)
    abNameStr{i,1}  = instNames{i};
    typeStr{i,1}    = VDatabase.(VDSet).(instNames{i}).Type;
    classStr{i,1}   = VDatabase.(VDSet).(instNames{i}).class.Value;
    enumStr{i,1}    = [typeStr{i} '.' classStr{i}];
end
clear abVarTable
abVarTable = table(abNameStr,typeStr,classStr,enumStr)
    
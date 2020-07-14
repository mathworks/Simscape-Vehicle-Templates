function Vehicle = sm_car_vehcfg_setDrv(Vehicle,drv_opt)
% Copy data from VDatabase to Vehicle data structure
%
% drv_opt contains string indicating configuration of driveline.
%      f<front driveshafts>r<rear differential>_<platform>
%
%   <front differential>   1D, 1D with non-rotating 3D shafts,
%                            or options for 3D driveshafts
%   <rear differential>    Same as front
%   <platform>             Abbreviation for Sedan Hamba "SH", etc.
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

switch drv_opt
    case 'f1Dr1D_SHL'
        % Front: 1D shafts
        % Rear:  1D shafts
        % Sedan HambaLG configuration
        instanceDriveline = 'IndepFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts1D_Sedan_HambaLG_f';
        instanceDrShF     = 'Shaft1D_default';
        
        instanceDiffR     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShR     = 'Shaft1D_default';
        
    case 'f1D3Dr1D_SHL'
        % 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        instanceDriveline = 'IndepFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts3Dfix_Sedan_HambaLG_f';
        instanceDrShF     = 'Shaft1D3D_Sedan_HambaLG_f';
        
        instanceDiffR     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShR     = 'Shaft1D_default';
        
    case 'f1D3Dr1D_SH'
        % 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        % Sedan Hamba configuration
        instanceDriveline = 'IndepFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts3D_Sedan_Hamba_f';
        instanceDrShF     = 'Shaft1D3D_Sedan_Hamba_f';
        
        instanceDiffR     = 'Gear1DShafts1D_Sedan_Hamba_r';
        instanceDrShR     = 'Shaft1D_default';
        
    case 'f1D3Dr1D_BM'
        % Front: 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        % Bus Makhulu configuration
        instanceDriveline = 'IndepFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts3D_Bus_Makhulu_f';
        instanceDrShF     = 'Shaft1D3D_Bus_Makhulu_f';
        
        instanceDiffR     = 'Gear1DShafts1D_Bus_Makhulu_r';
        instanceDrShR     = 'Shaft1D_default';
        
    case 'fCVpCVr1D_SHL'
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        % Rear:  1D shafts
        instanceDriveline = 'IndepFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShF     = 'Shaft3D_default';
        instanceDrShFCVi  = 'CVPrismatic_default';
        instanceDrShFSh   = 'Rigid_Sedan_HambaLG_f';
        instanceDrShFCVo  = 'CV_default';
        
        instanceDiffR     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShR     = 'Shaft1D_default';
        
    case 'fCVpCVflexr1D_SHL'
        % Front: 3D shafts for power: CV-prismatic-flexible driveshaft-CV
        % Rear:  1D shafts
        instanceDriveline = 'IndepFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShF     = 'Shaft3D_default';
        instanceDrShFCVi  = 'CVPrismatic_default';
        instanceDrShFSh   = 'Flex2Segments_Sedan_HambaLG_f';
        instanceDrShFCVo  = 'CV_default';
        
        instanceDiffR     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShR     = 'Shaft1D_default';
        
    case 'fCVCVpr1D_SHL'
        % Front: 3D shafts for power: CV-driveshaft-prismatic-CV
        % Rear:  1D shafts
        instanceDriveline = 'IndepFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShF     = 'Shaft3D_default';
        instanceDrShFCVi  = 'CV_default';
        instanceDrShFSh   = 'Rigid_Sedan_HambaLG_f';
        instanceDrShFCVo  = 'CVPrismatic_default';
        
        instanceDiffR     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShR     = 'Shaft1D_default';
        
    case 'fCVpCVr1D_1sh_SHL'
        % Single driven shaft
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        % Rear:  1D shaft
        instanceDriveline = 'ConnectFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShF     = 'Shaft3D_default';
        instanceDrShFCVi  = 'CVPrismatic_default';
        instanceDrShFSh   = 'Rigid_Sedan_HambaLG_f';
        instanceDrShFCVo  = 'CV_default';
        
        instanceDiffR     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShR     = 'Shaft1D_default';
        
    case 'fCVpCVr1D_3sh_SH'
        % Three driven shafts
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        % Rear:  1D shafts
        instanceDriveline = 'IndepFRDiffFIndepR_default';
        
        instanceDiffF     = 'Gear1DShafts3D_Sedan_Hamba_f';
        instanceDrShF     = 'Shaft3D_default';
        instanceDrShFCVi  = 'CVPrismatic_default';
        instanceDrShFSh   = 'Rigid_Sedan_Hamba_f';
        instanceDrShFCVo  = 'CV_default';
        
        instanceDrShR     = 'Shaft1D_default';
        
    case 'fCVpCVrCVpCV_SHL'
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        % Rear : 3D shafts for power: CV-prismatic-driveshaft-CV
        instanceDriveline = 'IndepFRDiffFDiffR_default';
        
        instanceDiffF     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShF     = 'Shaft3D_default';
        instanceDrShFCVi  = 'CVPrismatic_default';
        instanceDrShFSh   = 'Rigid_Sedan_HambaLG_f';
        instanceDrShFCVo  = 'CV_default';
        
        instanceDiffR     = 'Gear1DShafts3D_Sedan_HambaLG_r';
        instanceDrShR     = 'Shaft3D_default';
        instanceDrShRCVi  = 'CVPrismatic_default';
        instanceDrShRSh   = 'Rigid_Sedan_HambaLG_r';
        instanceDrShRCVo  = 'CV_default';
        
    case 'Axle1_None'
        instanceDriveline = 'Axle1_None';
end

% Assemble structure of parameters for driveline
Drv_struct               = VDatabase.Driveline.(instanceDriveline);
if(~contains(instanceDriveline,'None'))
    Drv_struct.DifferentialF = VDatabase.Differential.(instanceDiffF);
    Drv_struct.DriveshaftFL  = VDatabase.Driveshaft.(instanceDrShF);
    Drv_struct.DriveshaftFR  = VDatabase.Driveshaft.(instanceDrShF);
    if(exist('instanceDiffR','var'))
        % If there is a differential in the rear, add to structure
        Drv_struct.DifferentialR = VDatabase.Differential.(instanceDiffR);
    end
    Drv_struct.DriveshaftRL  = VDatabase.Driveshaft.(instanceDrShR);
    Drv_struct.DriveshaftRR  = VDatabase.Driveshaft.(instanceDrShR);

if(exist('instanceDrShFCVi','var'))
    % Assemble structure for front joints and driveshaft
    Drv_struct.DriveshaftFL.JointInboard  = VDatabase.JointInboard.(instanceDrShFCVi);
    Drv_struct.DriveshaftFL.JointOutboard = VDatabase.JointOutboard.(instanceDrShFCVo);
    Drv_struct.DriveshaftFL.Shaft         = VDatabase.Shaft.(instanceDrShFSh);
    Drv_struct.DriveshaftFR.JointInboard  = VDatabase.JointInboard.(instanceDrShFCVi);
    Drv_struct.DriveshaftFR.JointOutboard = VDatabase.JointOutboard.(instanceDrShFCVo);
    Drv_struct.DriveshaftFR.Shaft         = VDatabase.Shaft.(instanceDrShFSh);
end

if(exist('instanceDrShRCVi','var'))
    % Assemble structure for rear joints and driveshaft
    Drv_struct.DriveshaftRL.JointInboard  = VDatabase.JointInboard.(instanceDrShRCVi);
    Drv_struct.DriveshaftRL.JointOutboard = VDatabase.JointOutboard.(instanceDrShRCVo);
    Drv_struct.DriveshaftRL.Shaft         = VDatabase.Shaft.(instanceDrShRSh);
    Drv_struct.DriveshaftRR.JointInboard  = VDatabase.JointInboard.(instanceDrShRCVi);
    Drv_struct.DriveshaftRR.JointOutboard = VDatabase.JointOutboard.(instanceDrShRCVo);
    Drv_struct.DriveshaftRR.Shaft         = VDatabase.Shaft.(instanceDrShRSh);
end
end
% Copy data driveline data structure into Vehicle data structure
Vehicle.Powertrain.Driveline = Drv_struct;

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end

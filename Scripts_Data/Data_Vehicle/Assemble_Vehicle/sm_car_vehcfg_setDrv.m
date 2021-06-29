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
        instanceDriveline = 'Axle2_A1_A2_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts1D_Sedan_HambaLG_f';
        instanceDrShA1     = 'Shaft1D_default';
        
        instanceDiffA2     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'f1D3Dr1D_SHL'
        % 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        instanceDriveline = 'Axle2_A1_A2_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3Dfix_Sedan_HambaLG_f';
        instanceDrShA1     = 'Shaft1D3D_Sedan_HambaLG_f';
        
        instanceDiffA2     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'f1D3Dr1D_SH'
        % 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        % Sedan Hamba configuration
        instanceDriveline = 'Axle2_A1_A2_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3D_Sedan_Hamba_f';
        instanceDrShA1     = 'Shaft1D3D_Sedan_Hamba_f';
        
        instanceDiffA2     = 'Gear1DShafts1D_Sedan_Hamba_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'A11D_A21D3_A31D_BM3'
        % Three Axle Bus Makhulu configuration
        % One powered shaft
        % Front: 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        instanceDriveline = 'Axle3_A2_A2Diff_Bus_Makhulu_Axle3';
        
        instanceDiffA2     = 'Gear1DShafts1D_Bus_Makhulu_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'A11D_A21D3_A31D_TA3'
        % Three Axle Truck Amandla configuration
        % One powered shaft, one powered axle (6x2)
        % Front: 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        instanceDriveline = 'Axle3_A2_A2Diff_Truck_Amandla_Axle3';
        
        instanceDiffA2     = 'Gear1DShafts1D_Truck_Amandla_A2';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'A11D_A21D3_A31D3_BM3'
        % Three Axle Bus Makhulu configuration
        % One powered shaft, two powered axles (6x4)
        % Front: 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        instanceDriveline = 'Axle3_A23_A2Diff_A3Diff_Bus_Makhulu_Axle3';
        
        instanceDiffA2     = 'Gear1DShafts1D_Bus_Makhulu_r';
        instanceDrShA2     = 'Shaft1D_default';
        
        instanceDiffA3     = 'Gear1DShafts1D_Bus_Makhulu_r';
        instanceDrShA3     = 'Shaft1D_default';
        
    case 'A11D_A21D3_A31D3_TA3'
        % Three Axle Truck Amandla configuration
        % One powered shaft, two powered axles (6x4)
        % Front: 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        instanceDriveline = 'Axle3_A23_A2Diff_A3Diff_Truck_Amandla_Axle3';
        
        instanceDiffA2     = 'Gear1DShafts1D_Truck_Amandla_A2';
        instanceDrShA2     = 'Shaft1D_default';
        
        instanceDiffA3     = 'Gear1DShafts1D_Truck_Amandla_A3';
        instanceDrShA3     = 'Shaft1D_default';
        
    case 'f1D3Dr1D_BM'
        % Two Axle Bus Makhulu configuration
        % Two powered shaft, two powered axles (4x4)
        % Front: 1D shafts for power, non-rotating 3D shafts for visualization
        % Rear:  1D shafts
        instanceDriveline = 'Axle2_A1_A2_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3D_Bus_Makhulu_f';
        instanceDrShA1     = 'Shaft1D3D_Bus_Makhulu_f';
        
        instanceDiffA2     = 'Gear1DShafts1D_Bus_Makhulu_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'fCVpCVr1D_SHL'
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        % Rear:  1D shafts
        instanceDriveline = 'Axle2_A1_A2_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShA1     = 'Shaft3D_default';
        instanceDrShA1CVi  = 'CVPrismatic_default';
        instanceDrShA1Sh   = 'Rigid_Sedan_HambaLG_f';
        instanceDrShA1CVo  = 'CV_default';
        
        instanceDiffA2     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'fCVpCVflexr1D_SHL'
        % Front: 3D shafts for power: CV-prismatic-flexible driveshaft-CV
        % Rear:  1D shafts
        instanceDriveline = 'Axle2_A1_A2_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShA1     = 'Shaft3D_default';
        instanceDrShA1CVi  = 'CVPrismatic_default';
        instanceDrShA1Sh   = 'Flex2Segments_Sedan_HambaLG_f';
        instanceDrShA1CVo  = 'CV_default';
        
        instanceDiffA2     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'fCVCVpr1D_SHL'
        % Front: 3D shafts for power: CV-driveshaft-prismatic-CV
        % Rear:  1D shafts
        instanceDriveline = 'Axle2_A1_A2_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShA1     = 'Shaft3D_default';
        instanceDrShA1CVi  = 'CV_default';
        instanceDrShA1Sh   = 'Rigid_Sedan_HambaLG_f';
        instanceDrShA1CVo  = 'CVPrismatic_default';
        
        instanceDiffA2     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'fCVpCVr1D_1sh_SHL'
        % Single driven shaft
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        % Rear:  1D shaft
        instanceDriveline  = 'Axle2_A12Visc_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShA1     = 'Shaft3D_default';
        instanceDrShA1CVi   = 'CVPrismatic_default';
        instanceDrShA1Sh    = 'Rigid_Sedan_HambaLG_f';
        instanceDrShA1CVo   = 'CV_default';
        
        instanceDiffA2     = 'Gear1DShafts1D_Sedan_HambaLG_r';
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'fCVpCVr1D_3sh_SH'
        % Three driven shafts
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        % Rear:  1D shafts
        instanceDriveline = 'Axle2_A1_L2_R2_A1Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3D_Sedan_Hamba_f';
        instanceDrShA1     = 'Shaft3D_default';
        instanceDrShA1CVi   = 'CVPrismatic_default';
        instanceDrShA1Sh    = 'Rigid_Sedan_Hamba_f';
        instanceDrShA1CVo   = 'CV_default';
        
        instanceDrShA2     = 'Shaft1D_default';
        
    case 'f1D_r1D_4sh_SH'
        % Four driven shafts
        % Front: 1D shafts
        % Rear:  1D shafts
        instanceDriveline = 'Axle2_L1_R1_L2_R2_default';
        
    case 'fCVpCVrCVpCV_SHL'
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        % Rear : 3D shafts for power: CV-prismatic-driveshaft-CV
        instanceDriveline = 'Axle2_A1_A2_A1Diff_A2Diff_default';
        
        instanceDiffA1     = 'Gear1DShafts3D_Sedan_HambaLG_f';
        instanceDrShA1     = 'Shaft3D_default';
        instanceDrShA1CVi  = 'CVPrismatic_default';
        instanceDrShA1Sh   = 'Rigid_Sedan_HambaLG_f';
        instanceDrShA1CVo  = 'CV_default';
        
        instanceDiffA2     = 'Gear1DShafts3D_Sedan_HambaLG_r';
        instanceDrShA2     = 'Shaft3D_default';
        instanceDrShA2CVi  = 'CVPrismatic_default';
        instanceDrShA2Sh   = 'Rigid_Sedan_HambaLG_r';
        instanceDrShA2CVo  = 'CV_default';
        
    case 'Axle1_None'
        instanceDriveline = 'Axle1_None';
        
    case 'Axle2_None'
        instanceDriveline = 'Axle2_None';
        
    case 'fCVpCV_FC1m'
        % One driven shafts, FWD only
        % Front: 3D shafts for power: CV-prismatic-driveshaft-CV
        instanceDriveline  = 'Axle2_A1_A1Diff_FuelCell1Motor';
        
        instanceDiffA1     = 'Gear1DShafts3D_Sedan_Hamba_f';
        instanceDrShA1     = 'Shaft3D_default';
        instanceDrShA1CVi   = 'CVPrismatic_default';
        instanceDrShA1Sh    = 'Rigid_Sedan_Hamba_f';
        instanceDrShA1CVo   = 'CV_default';
        
end

% Assemble structure of parameters for driveline
Drv_struct               = VDatabase.Driveline.(instanceDriveline);
if(~contains(instanceDriveline,'None'))
    if(exist('instanceDiffA1','var'))
        Drv_struct.DifferentialA1 = VDatabase.Differential.(instanceDiffA1);
    end
    if(exist('instanceDrShA1','var'))
        Drv_struct.DriveshaftL1  = VDatabase.Driveshaft.(instanceDrShA1);
        Drv_struct.DriveshaftR1  = VDatabase.Driveshaft.(instanceDrShA1);
    end
    
    if(exist('instanceDiffA2','var'))
        % If there is a differential in the rear, add to structure
        Drv_struct.DifferentialA2 = VDatabase.Differential.(instanceDiffA2);
    end
    if(exist('instanceDrShA2','var'))
        Drv_struct.DriveshaftL2  = VDatabase.Driveshaft.(instanceDrShA2);
        Drv_struct.DriveshaftR2  = VDatabase.Driveshaft.(instanceDrShA2);
    end
    
    if(exist('instanceDiffA3','var'))
        % If there is a differential in the rear, add to structure
        Drv_struct.DifferentialA3 = VDatabase.Differential.(instanceDiffA3);
    end
    if(exist('instanceDrShA3','var'))
        Drv_struct.DriveshaftL3  = VDatabase.Driveshaft.(instanceDrShA3);
        Drv_struct.DriveshaftR3  = VDatabase.Driveshaft.(instanceDrShA3);
    end
    
    if(exist('instanceDrShA1CVi','var'))
        % Assemble structure for front joints and driveshaft
        Drv_struct.DriveshaftL1.JointInboard  = VDatabase.JointInboard.(instanceDrShA1CVi);
        Drv_struct.DriveshaftL1.JointOutboard = VDatabase.JointOutboard.(instanceDrShA1CVo);
        Drv_struct.DriveshaftL1.Shaft         = VDatabase.Shaft.(instanceDrShA1Sh);
        Drv_struct.DriveshaftR1.JointInboard  = VDatabase.JointInboard.(instanceDrShA1CVi);
        Drv_struct.DriveshaftR1.JointOutboard = VDatabase.JointOutboard.(instanceDrShA1CVo);
        Drv_struct.DriveshaftR1.Shaft         = VDatabase.Shaft.(instanceDrShA1Sh);
    end
    
    if(exist('instanceDrShA2CVi','var'))
        % Assemble structure for rear joints and driveshaft
        Drv_struct.DriveshaftL2.JointInboard  = VDatabase.JointInboard.(instanceDrShA2CVi);
        Drv_struct.DriveshaftL2.JointOutboard = VDatabase.JointOutboard.(instanceDrShA2CVo);
        Drv_struct.DriveshaftL2.Shaft         = VDatabase.Shaft.(instanceDrShA2Sh);
        Drv_struct.DriveshaftR2.JointInboard  = VDatabase.JointInboard.(instanceDrShA2CVi);
        Drv_struct.DriveshaftR2.JointOutboard = VDatabase.JointOutboard.(instanceDrShA2CVo);
        Drv_struct.DriveshaftR2.Shaft         = VDatabase.Shaft.(instanceDrShA2Sh);
    end

    if(exist('instanceDrShA3CVi','var'))
        % Assemble structure for rear joints and driveshaft
        Drv_struct.DriveshaftL3.JointInboard  = VDatabase.JointInboard.(instanceDrShA3CVi);
        Drv_struct.DriveshaftL3.JointOutboard = VDatabase.JointOutboard.(instanceDrShA3CVo);
        Drv_struct.DriveshaftL3.Shaft         = VDatabase.Shaft.(instanceDrShA3Sh);
        Drv_struct.DriveshaftR3.JointInboard  = VDatabase.JointInboard.(instanceDrShA3CVi);
        Drv_struct.DriveshaftR3.JointOutboard = VDatabase.JointOutboard.(instanceDrShA3CVo);
        Drv_struct.DriveshaftR3.Shaft         = VDatabase.Shaft.(instanceDrShA3Sh);
    end

end
% Copy data driveline data structure into Vehicle data structure
Vehicle.Powertrain.Driveline = Drv_struct;

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end

function Vehicle = testrig_half_car_spla_s2laf_au_setSubframe(Vehicle_in,part,connType)
% testrig_half_car_spla_s2laf_au_setSubframe  Configure subframe connections
%    Vehicle = testrig_half_car_spla_s2laf_au_setSubframe(Vehicle_in,part,connType)
%    This function adjusts fields in vehicle data structure Vehicle to
%    configure subframe connections to be rigid or have a bushing.
%
%       Vehicle_in   Vehicle structure from database
%       part         Name of part with connection to subframe ('Arm', 'ARB')
%       connType     Type of connection ('Rigid', 'Bushing')
%
%    The function outputs Vehicle with the desired modifications.
%
% Copyright 2024-2025 The MathWorks, Inc.

% Copy Vehicle data structure input
Vehicle = Vehicle_in;

% Map request to field name settings
if contains(connType,'Rigid')
    subFrameConnA = 'Rigid_1Rev';  % For wishbone - revolute joint
    subFrameConnL = 'Rigid_UJ';    % For link - universal joint
else
    subFrameConnA = 'Bushing_Ax3'; % For wishbone - bushing
    subFrameConnL = 'Bushing_Ax3'; % For link - bushing
end

switch part
    case 'Arms'
        Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.class.Value  = subFrameConnA;
        Vehicle.Chassis.SuspA1.Linkage.LowerArmF_to_Subframe.class.Value  = subFrameConnL;
        Vehicle.Chassis.SuspA1.Linkage.LowerArmR_to_Subframe.class.Value  = subFrameConnL;
    case 'ARB'
        Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection.class.Value = subFrameConnA;
end


if ~contains(connType,'Rigid')
    switch part
        case 'Arms'
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.FSpringX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.FSpringY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.FSpringZ.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.RSpringX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.RSpringY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.RSpringZ.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.FDamperX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.FDamperY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.FDamperZ.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.RDamperX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.RDamperY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.RDamperZ.Law.Value = connType;

            Vehicle.Chassis.SuspA1.Linkage.LowerArmF_to_Subframe.SpringX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmF_to_Subframe.SpringY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmF_to_Subframe.SpringZ.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmF_to_Subframe.DamperX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmF_to_Subframe.DamperY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmF_to_Subframe.DamperZ.Law.Value = connType;

            Vehicle.Chassis.SuspA1.Linkage.LowerArmR_to_Subframe.SpringX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmR_to_Subframe.SpringY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmR_to_Subframe.SpringZ.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmR_to_Subframe.DamperX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmR_to_Subframe.DamperY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.Linkage.LowerArmR_to_Subframe.DamperZ.Law.Value = connType;
        case 'ARB'
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection.SpringX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection.SpringY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection.SpringZ.Law.Value = connType;
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection.DamperX.Law.Value = connType;
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection.DamperY.Law.Value = connType;
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection.DamperZ.Law.Value = connType;
    end
end

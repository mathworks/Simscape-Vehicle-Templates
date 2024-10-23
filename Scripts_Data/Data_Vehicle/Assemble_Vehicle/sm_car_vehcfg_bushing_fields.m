function [prefix_str,arm_str] = sm_car_vehcfg_bushing_fields(susp_name)
% sm_car_susp_prefix  Obtain database fields for bushing parameters and
%    [prefix_str,arm_str] = sm_car_susp_prefix(susp_name)
%
%    This function provides database field names for the requested
%    suspension type. 
%
%       prefix_str      Prefix for database field name (
%              <bushing type>_<chassis type_axle>_<suspension type>
%       arm_str         Name abbreviations, associated with suspension type
%                         'UA'  Upper arm wishbone
%                         'UAF' Upper arm link, front
%                         'UAR' Upper arm link, rear
%                         'LA'  Lower arm wishbone
%                         'LAF' Lower arm link, front
%                         'LAR' Lower arm link, rear

% Copyright 2023-2024 The MathWorks, Inc.


switch (susp_name)
    case 'DoubleWishbone_Sedan_Hamba_f',             prefix_str = {'Bushing_Sedan'};  arm_str = {'UA','LA'};
    case 'DoubleWishbone_Sedan_HambaLG_f',           prefix_str = {'Bushing_Sedan'};  arm_str = {'UA','LA'};
    case 'DoubleWishboneA_Sedan_HambaLG_f',          prefix_str = {'Bushing_Sedan'};  arm_str = {'UA','LA'};
    case 'DoubleWishbone_Bus_Makhulu_f',             prefix_str = {'Bushing_Sedan'};  arm_str = {'UA','LA'};
    case 'SplitLowerArmShockFront_Sedan_Hamba_f',    prefix_str = {'Bushing_Sedan','BushingUJ_Sef_S2LAF','BushingUJ_Sef_S2LAF'};  arm_str = {'UA','LAF','LAR'};
    case 'SplitLowerArmShockFront_Sedan_HambaLG_f',  prefix_str = {'Bushing_Sedan','BushingUJ_SLGf_S2LAF','BushingUJ_SLGf_S2LAF'};  arm_str = {'UA','LAF','LAR'};
    case 'SplitLowerArmShockRear_Sedan_HambaLG_f',   prefix_str = {'Bushing_Sedan','BushingUJ_SLGf_S2LAR','BushingUJ_SLGf_S2LAR'};  arm_str = {'UA','LAF','LAR'};
    case 'FiveLinkShockRear_Sedan_Hamba_f',          prefix_str = {'BushingUJ_Sef_5LS2R'};  arm_str = {'UAF','UAR','LAF','LAR'};
    case 'FiveLinkShockFront_Sedan_HambaLG_f',       prefix_str = {'BushingUJ_SLGf_5LS2F'}; arm_str = {'UAF','UAR','LAF','LAR'};
    case 'FiveLinkShockRear_Sedan_HambaLG_f',        prefix_str = {'BushingUJ_SLGf_5LS2R'}; arm_str = {'UAF','UAR','LAF','LAR'};

    case 'DoubleWishboneA_Sedan_Hamba_r',            prefix_str = {'Bushing_Sedan'};  arm_str = {'UA','LA'};
    case 'DoubleWishboneA_Sedan_HambaLG_r',          prefix_str = {'Bushing_Sedan'};  arm_str = {'UA','LA'};
    case 'DoubleWishboneA_Bus_Makhulu_r',            prefix_str = {'Bushing_Sedan'};  arm_str = {'UA','LA'};
    case 'SplitLowerArmShockFront_Sedan_Hamba_r',    prefix_str = {'Bushing_Sedan','BushingUJ_Ser_S2LAF','BushingUJ_Ser_S2LAF'};   arm_str = {'UA','LAF','LAR'};
    case 'SplitLowerArmShockFront_Sedan_HambaLG_r',  prefix_str = {'Bushing_Sedan','BushingUJ_SLGr_S2LAF','BushingUJ_SLGr_S2LAF'};  arm_str = {'UA','LAF','LAR'};
    case 'SplitLowerArmShockRear_Sedan_HambaLG_r',   prefix_str = {'Bushing_Sedan','BushingUJ_SLGr_S2LAR','BushingUJ_SLGr_S2LAR'};  arm_str = {'UA','LAF','LAR'};
    case 'FiveLinkShockRear_Sedan_Hamba_r',          prefix_str = {'BushingUJ_Ser_5LS2R'};   arm_str = {'UAF','UAR','LAF','LAR'};
    case 'FiveLinkShockFront_Sedan_HambaLG_r',       prefix_str = {'BushingUJ_SLGr_5LS2F'};  arm_str = {'UAF','UAR','LAF','LAR'};
    case 'FiveLinkShockRear_Sedan_HambaLG_r',        prefix_str = {'BushingUJ_SLGr_5LS2R'};  arm_str = {'UAF','UAR','LAF','LAR'};

    otherwise, prefix_str = {'No Bushing'}; arm_str = {'No Arm'};
end

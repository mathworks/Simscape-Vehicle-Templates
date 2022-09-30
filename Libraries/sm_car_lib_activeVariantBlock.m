function blk = sm_car_lib_activeVariantBlock(variant_sub_name)
% Code to return path to block which is the active variant.

% Copyright 2022 The MathWorks, Inc.

vnt_list = get_param(variant_sub_name,'Variants');
vnt_actv = get_param(variant_sub_name,'ActiveVariant');

blk = [];
if(~isempty(vnt_actv))
    blk = vnt_list(strcmp(vnt_actv,{vnt_list(:).Name})).BlockName;
end
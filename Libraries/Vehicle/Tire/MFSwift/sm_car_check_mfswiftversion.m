function mfswift_ver = sm_car_check_mfswiftversion
% Copyright 2021-2024 The MathWorks, Inc.
% Returns version of MF-Swift software

% Version obtained from Mask Description of MF-Swift Simscape block
load_system('mfswift_simscape_library');
mask_descr = get_param('mfswift_simscape_library/MF-Swift Simscape','MaskDescription');
bdclose('mfswift_simscape_library');

check_string = 'MF-Swift v';
NL = regexp(mask_descr, '[\n]');

vers_str_index = strfind(mask_descr,check_string)+length(check_string);

%mfswift_ver = mask_descr(vers_str_index:vers_str_index+5);
mfswift_ver = mask_descr(vers_str_index:NL(end)-1);

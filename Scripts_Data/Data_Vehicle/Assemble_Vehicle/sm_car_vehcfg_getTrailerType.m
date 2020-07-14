function trailer_type = sm_car_vehcfg_getTrailerType(mdl)
% Get list of key selected variants

trl_setting = get_param([mdl '/Vehicle'],'popup_trailer');
if (strcmpi(trl_setting,'Off'))
    trailer_type = 'None';
else
    Trailer = evalin('base','Trailer');
    trl_strings = strsplit(Trailer.config,'_');
    trailer_type = trl_strings{1};
end

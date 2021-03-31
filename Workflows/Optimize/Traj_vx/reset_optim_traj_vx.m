% Disable checks to terminate run if car leaves track or lap is complete
set_param([mdl '/Check'],'start_check_time_ld','10000');
set_param([mdl '/Check'],'start_check_time_end_lap','10000');

% Turn Fast Restart off
set_param(mdl,'FastRestart','off')


%% Hydropneumatic Spring-Damper Testrig
% 
% This example models a hydropneumatic spring for an offroad vehicle
% suspension.  Control signals can select a stiff or soft spring, adjust
% the damping, and adjust the ride height.
%
% Copyright 2018-2025 The MathWorks, Inc.


%% Model

open_system('testrig_AirOilPiston')

set_param(find_system('testrig_AirOilPiston','MatchFilter',@Simulink.match.allVariants,'FindAll', 'on','type','annotation','Tag','ModelFeatures'),'Interpreter','off')

%% Hydropneumatic Spring Damper
%
% The hydropneumatic spring-damper model has mechanical connections to the
% unsprung mass (wheel) and the sprung mass (chassis). The lower oil
% chamber connects to two gas springs (soft and stiff) via an oil damper.
% Different volumes in the gas springs enable different stiffnesses.  A
% ride height system can add or remove oil to adjust the ride height.
%
% <matlab:open_system('testrig_AirOilPiston');open_system('testrig_AirOilPiston/AirOilPiston','force'); Open Subsystem>

set_param('testrig_AirOilPiston/AirOilPiston','LinkStatus','none')
open_system('testrig_AirOilPiston/AirOilPiston','force')

%% Damper Subsystem
%
% This subsystem models the damper.  Multiple flow paths enable a nonlinear
% damping characteristic.
%
% <matlab:open_system('testrig_AirOilPiston');open_system('testrig_AirOilPiston/AirOilPiston/Damper','force'); Open Subsystem>

set_param('testrig_AirOilPiston/AirOilPiston/Damper','LinkStatus','none')
open_system('testrig_AirOilPiston/AirOilPiston/Damper','force')

%% Ride Height Subsystem
%
% This subsystem models the ride height system.  The pump is modeled as an
% ideal pressure source.  Control signals open valves to let flow into and
% out of the oil chamber.
%
% <matlab:open_system('testrig_AirOilPiston');open_system('testrig_AirOilPiston/AirOilPiston/Ride%20Height','force'); Open Subsystem>

set_param('testrig_AirOilPiston/AirOilPiston/Ride Height','LinkStatus','none')
open_system('testrig_AirOilPiston/AirOilPiston/Ride Height','force')

%% Simulation Results: Soft Suspension, Step Input
%
% This test actuates the road height using a step profile for road height.
% Spring deflection and damper flow are plotted. The soft suspension is
% selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Step','Soft')
sim('testrig_AirOilPiston')
testrig_AirOilPiston_plot1xspring
testrig_AirOilPiston_plot2qdamper

%% Simulation Results: Stiff Suspension, Step Input
%
% This test actuates the road height using a step profile for road height.
% Spring deflection and damper flow are plotted. The stiff suspension is
% selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Step','Stiff')
sim('testrig_AirOilPiston')
testrig_AirOilPiston_plot1xspring
testrig_AirOilPiston_plot2qdamper

%% Simulation Results: Soft Suspension, Triangle Input
%
% This test actuates the road height using a triangular profile.  Spring
% deflection and damper flow are plotted. The soft suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Triangle','Soft')
sim('testrig_AirOilPiston')
close(h2_testrig_AirOilPiston)
testrig_AirOilPiston_plot5pressvsdisp

%% Simulation Results: Stiff Suspension, Triangle Input
%
% This test actuates the road height using a triangular profile.  Spring
% deflection and damper flow are plotted. The stiff suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Triangle','Stiff')
sim('testrig_AirOilPiston')
close(h5_testrig_AirOilPiston)
testrig_AirOilPiston_plot5pressvsdisp

%% Simulation Results: Soft Suspension, Chirp Input
%
% This test actuates the road height using a chirp profile, which is a sine
% wave with a continuously increasing frequency.  This lets us see how the
% suspension responds at varying frequencies. Spring deflection and damper
% flow are plotted. The soft suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Chirp','Soft')
sim('testrig_AirOilPiston')
testrig_AirOilPiston_plot1xspring
testrig_AirOilPiston_plot2qdamper

%%
%  Removing the orifice damper flows from the upper plot, we can see that
%  when the pressure relief valves open, the response of the system is
%  affected.

ax1 = subplot(2,1,2);      % get handle to first subplot
h = findobj(ax1,'Type','line');

delete(h(1:2))             % delete CVD and Orifice
legend(ax1,'show')
set(ax1,'YLim',[-0.3 0.3])

%% Simulation Results: Stiff Suspension, Chirp Input
%
% This test actuates the road height using a chirp profile, which is a sine
% wave with a continuously increasing frequency.  Spring deflection and
% damper flow are plotted. The stiff suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Chirp','Stiff')
sim('testrig_AirOilPiston')
testrig_AirOilPiston_plot1xspring
testrig_AirOilPiston_plot2qdamper

%%
%  Removing the orifice damper flows from the upper plot, we can see that
%  when the pressure relief valves open, the response of the system is
%  affected.

ax1 = subplot(2,1,2);      % get handle to first subplot
h = findobj(ax1,'Type','line');

delete(h(1:2))             % delete CVD and Orifice
legend(ax1,'show')
set(ax1,'YLim',[-0.3 0.3])

%% Simulation Results: Soft Suspension, Rough Road Input
%
% This test actuates the road height using a rough road profile for road
% height.  Spring deflection and damper flow are plotted. The soft
% suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Rough','Soft')
sim('testrig_AirOilPiston')
testrig_AirOilPiston_plot1xspring
testrig_AirOilPiston_plot2qdamper

%% Simulation Results: Soft Suspension, Ride Height System
%
% This test holds the road height constant as the ride height system adds
% and removes oil from the lower chamber.  The soft suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Ride Height','Soft')
sim('testrig_AirOilPiston')

close(h1_testrig_AirOilPiston)
close(h2_testrig_AirOilPiston)
testrig_AirOilPiston_plot3qrideheight

%% Simulation Results: Stiff Suspension, Ride Height System
%
% This test holds the road height constant as the ride height system adds
% and removes oil from the lower chamber.  The stiff suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Ride Height','Stiff')

sim('testrig_AirOilPiston')
testrig_AirOilPiston_plot3qrideheight

%% Simulation Results from Simscape Logging: Soft Suspension, Spring Extension Triangle
%
% This test holds the road height constant as the spring is compressed and
% extended.  Compression and extension is done using a triangle wave for
% spring length. The soft suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Extension Triangle','Soft')

sim('testrig_AirOilPiston')
testrig_AirOilPiston_plot1xspring
testrig_AirOilPiston_plot2qdamper
testrig_AirOilPiston_plot4volchamb

%% Simulation Results from Simscape Logging: Stiff Suspension, Spring Extension Triangle
%
% This test holds the road height constant as the spring is compressed and
% extended.  Compression and extension is done using a triangle wave for
% spring length. The soft suspension is selected.
%

testrig_AirOilPiston_test_config('testrig_AirOilPiston','Extension Triangle','Stiff')

sim('testrig_AirOilPiston')
testrig_AirOilPiston_plot1xspring
testrig_AirOilPiston_plot2qdamper
testrig_AirOilPiston_plot4volchamb


%%

%clear all
close all
bdclose all

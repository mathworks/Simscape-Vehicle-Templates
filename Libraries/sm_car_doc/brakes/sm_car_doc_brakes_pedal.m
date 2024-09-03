%% Brakes, Pedal Input 
%
% <html>
% <a href="../../sm_car_doc_overview.html">Home</a> &gt; 
% <a href="./sm_car_doc_brakes.html">Brakes</a> &gt;
% </html>
%
% This subsystem models the brakes for all four corners of the vehicle,
% The pressure applied to the brake is controlled by an input signal
% representing the amount the driver has depressed the brake pedal.
% 
% Copyright 2019-2024 The MathWorks, Inc.


%% Overview
%
% The Pedal variant of the brake subsystem has: 
% 
% * Simscape Bus connections for each corner 
% * Input signal bus for the control of the braking system.
% * Input signal bus for inputs from the driver (brake pedal displacement)

open_system('sm_car_doc_model_for_images')
open_system('sm_car_doc_model_for_images/Brakes Pedal Subsystem');

%% Model
%
% The brake caliper and pads are modeled using the Disc Brake block from
% Simscape Driveline.  The actuators are ideal with a first order filter to
% smooth the input to the brakes and to account for actuator dynamics.
%
% The input signal to each actuator is the amount that the brake pedal
% is depressed, ranging from 0-1.
%
% The control signals are not used in this variant.
%

open_system('sm_car_doc_model_for_images/Brakes Pedal Subsystem/Pedal','force')

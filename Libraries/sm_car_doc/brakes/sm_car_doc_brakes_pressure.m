%% Brakes, Pressure Input 
%
% <html>
% <a href="../../sm_car_doc_overview.html">Home</a> &gt; 
% <a href="./sm_car_doc_brakes.html">Brakes</a> &gt;
% </html>
%
% This subsystem models the brakes for all four corners of the vehicle,
% The pressure applied to the brake is controlled by an input signal
% representing the pressure at each brake caliper.
% 
% Copyright 2019-2020 The MathWorks, Inc.


%% Overview
%
% The Pressure variant of the brake subsystem has: 
% 
% * Simscape Bus connections for each corner 
% * Input signal bus for the control of the braking system
% * Input signal bus for inputs from the driver (brake caliper pressure)

open_system('sm_car_doc_model_for_images')
open_system('sm_car_doc_model_for_images/Brakes Pressure Subsystem');

%% Model
%
% The brake caliper and pads are modeled using the Disc Brake block from
% Simscape Driveline.  The actuators are ideal with a first order filter to
% smooth the input to the brakes.
%
% The input signal to each actuator is the pressure at the brake caliper.
% This permits the brake pressure to be calculated by an external function
% for empirical models of brake hydraulic systems and to include the
% effects of the control system.
%
% The control signals are not used in this variant.

open_system('sm_car_doc_model_for_images/Brakes Pressure Subsystem/Pressure','force')

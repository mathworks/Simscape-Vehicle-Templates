%% Double Wishbone, Design A
%
% <html>
% <a href="../../sm_car_doc_overview.html">Home</a> &gt; 
% <a href="./sm_car_doc_susp.html">Suspensions</a> &gt;
% </html>
%
% This subsystem models a double-wishbone suspension for one corner of the
% vehicle (front or rear, left or right).  This variant (labeled Design A)
% has constraints that prevent the upright from rotating freely about its
% vertical axis.  It cannot be used for an axle that has a steering system.
% 
% Copyright 2019-2024 The MathWorks, Inc.

%% Overview
%
% The suspension is parameterized relative to a single reference point for
% the axle. It models the linkage for the left or right side. The left or
% right side is set by a dropdown parameter.
%
% <<sm_car_doc_susp_context_image.png>>

%% Parts
% 
% <html>
% <img src="sm_car_doc_susp_double_wishbone_a_parts_image.png"</a>
% </html>
%
%% Hardpoints
%
% *Context*
%
% The diagram below shows where the hardpoints are located.  All hardpoints
% for the suspension are defined relative to hardpoint front mount.
% 
% <<sm_car_doc_susp_double_wishbone_a_hp_image.png>>
% 

%% Implementation Details
% 
% <html>
% <ol>
% <b><li>Left/Right Mirroring</li></b> 
% The values entered in the dialog box are assumed to be on the left side.
% You can mirror the hardpoints to the right side by selecting "Right" from
% the Left/Right dropdown. The sign is reversed on the relevant y-values
% via a parameter defined in the mask initialization.<br>
% <br>
% <b><li>Linkage Definition</li></b>
% Linkage lengths are defined by the locations of the hardpoints, which are
% defined relative to a reference point for the front/rear axle. The mass
% and radius are also specified by parameters, and the inertia is
% calculated based on those quantities.<br>
% <br>
% <b><li>Initial Positions and Speeds</li></b>
% <b>Suspension Position:</b> The initial position of the suspension is
% defined by the locations of the hardpoints, which includes the initial
% extension of the shock absorber. The initial force provided by the shock
% absorber is specified in the springs and dampers subsystem.<br><br>  
% <b>Wheel Speed:</b> The initial speed of the wheel is specified within the
% suspension, as the joint defining the wheel axial degree of freedom is in
% this subsystem.<br>
% </ol>
% </html>

%% Key Components
% <html>
% <ul>
% <li><a href="./sm_car_doc_susp_shock.html">Shock</a></li>
% </ul>
% </html>

%% Testrigs
%
% <html>
% <ul>
% <LI><a href="matlab:open_system('sm_car_harness_linkage');">Suspension Motion Testrig</a><br>
% <LI>Suspension Hardpoints: <a href="matlab:open_system('sm_car_testrig_susp_dwa_hp');">Model</a>, <a href="matlab:web('sm_car_testrig_quarter_car_testvariants_results.html')">Documentation</a><br>
% </ul>
% </html>
%  
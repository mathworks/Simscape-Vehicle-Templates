# **Simscape Vehicle Templates**
Copyright 2018-2025 The MathWorks, Inc.

This library contains library blocks and a configurable vehicle model.  
You can:

   1. Select different vehicle types model fidelity levels.
   2. Adjust parameter values for the selected vehicle configuration
   3. Configure the vehicle model to run different open and closed loop maneuvers.
   4. Visualize the simulation results in a 3D animation
   5. Render the results in photo-realistic animation (Unreal Engine)

The templates are designed to be extendable. Create your own variant for any portion 
of the vehicle model (such as the brakes, suspension, or drivetrain) and you can 
adjust the libraries so that variant can be selected.

**Please visit the [Simscape Vehicle Templates](https://www.mathworks.com/solutions/physical-modeling/simscape-vehicle-templates.html) page** for animations and videos that show what you can do with these models.

**See also these slides for more details on how the templates work: [Simscape Vehicle Templates PDF](https://content.mathworks.com/viewer/650bf0f0aedcbc278788fb2d)**


![](Overview/html/sm_car_mechExp_Sedan_PikesPeakUp.png)

[![View Simscape Vehicle Templates on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/79484-simscape-vehicle-templates)

## **Getting Started**
1. Open the project file sm\_car\_proj.prj 
   - The first time you open it, it takes 10 minutes to load all parameters for all variants from Excel.  
   - Every time after that, the data is loaded from a .MAT file, so it goes quicker.

2. Explore the vehicle types and maneuvers from the UI 

3. Modify parameter values in the "Vehicle" data structure in the MATLAB workspace.
 
### **Release History**
**v4.0  -- May 2025**
1.  Kinematics and Compliance test added to quarter, half, and full car models
... Includes roll, steering, lateral compliance, longitudinal compliance tests
2.  47 metrics reported from KnC tests
3.  Suspension linkage with pushrod added (steer, no steer)
4.  Suspension linkage split lower arm, shock to front, ARB to upright added
5.  Suspension linkage MacPherson added
6.  Suspension twist beam added
7.  Fishhook event added
8.  Ramp Steer event added
9.  Sine with Dwell event added
10. Slalom event added
11. Bushing force law added (3-axis translation independent)
12. Optional bushing connections added to anti-roll bar
13. Alignment of wishbone joints handled within variant subsystems
14. Shock spring preload can be specified by deformation or force (new parameter fPreload).
15. Adjustments to trailer disturbance, straightline maneuvers.
16. Added european-style 3-axle truck (Truck Rhuqa).
17. Updated geometry and images for Hamba and Makhulu vehicles.

**v3.9  -- Feb 2025**
1.  Added event GS Uneven Road to show Grid Surface to Magic Formula Tire (R2024b and higher)
2.  Added example to go from CRG to STL to grid surface data.
3.  Updated Longitudinal Driver model.

**v3.8  -- Feb 2025**
1.  Added 12 additional KnC metrics to testrig_quarter_car* models 
2.  Made path-following driver robust when traveling far inside of a sharp corner 

**v3.7  -- Nov 2024**
1.  Minor fixes to suspension metrics, hyperlinks in testrig_quarter_car* models 

**v3.6  -- Nov 2024**
1.  Hardpoints in all suspensions can be tuned without recompiling (use Fast Restart).
2.  Added Suspension Tester App for sweeping and optimizing hardpoint locations.
3.  Fixed settings for Interactive Driver (for use with XBox controller)

**v3.5  -- Nov 2024**
1.  Renamed suspension "PushUA" to "Pullrod".

**v3.4  -- Oct 2024**
1.  Added optional compliance elements to all inboard connections of suspension arms.
2.  Added bushing testrig to test linear, nonlinear, and nonlinear with hysteresis force laws.

**v3.3  -- Oct 2024**
1.  Toe and camber calculations suitable for left and right sides.
2.  Added suspension metrics (bump steer, caster, steering angle inclination, etc.)

**v3.2  -- Oct 2024**
1.  Improved trajectory follower with smoother transitions between segments.
2.  Fixed data types for lap counter. 
3.  Added method to terminate simulation when vehicle distance along trajectory exceeds threshold. 
4.  Changed double lane change and skidpad maneuvers to stop when distance along trajectory exceeds threshold.
5.  Adjusted initial conditions for Mallory Park, Mallory Park CCW.

**v3.1  -- Sept 2024**
1.  Set default maneuver to be Hockenheim F
2.  Quarter car testrigs and half car testrigs no longer reference VDatabase for sharing. 
3.  Added preset for pushrod 4 motor FSAE. 
4.  Added quarter car testrigs, pushrod, and hockenheim flat to FSAE.

**v3.0  -- Sept 2024**
**Starting with version 3.0, Simscape Vehicle Templates are for R2022a and higher**
1.  Removed mask code and mask parameters to trigger variant changes
    Added sm_car_config_variants() to trigger externally as needed.
2.  Removed mask code to set mask images
3.  Removed Contact Force Library
    Used Spatial Contact Force block instead
4.  Removed all internal test harnesses
5.  Using correct @Simulink filter for finding active variants
6.  Added Formula Student body based on CAD
7.  Added Formula Student parameter set for standard double-wishbone suspension
7.  Added example integrating Dynamic Scenario Designer
8.  Moved all source blocks out of sm_car_lib.slx (only contains links now).
9.  Maneuver definitions now defined using MATLAB code (was Excel)
10. Road height can be passed in as an external input for Simscape Multibody tire.
11. Mechanical connections to passengers pass through vehicle body
12. Set CV Joints to use "Rotation Sequence" instead of "Quaternion" for internal state
    Eliminates need for "Primitive Bushing" in driveline and "Primitive Gimbal" in suspension
    Computationally more efficient.
13. Fixed display battery cooling threshold (0 -> 0.5)
14. Fixed shutdown script to properly eliminate Custom_lib.slx
15. Fixed opening and closing of UI to avoid errors when project is closed.
16. Added Simscape Parts Library directly to project (eliminated reference project).
17. Fixed hp testrig
18. Fixed optimization objective function in lap time optimization scripts.


## ## ##
**Prior to v3.0, Simscape Vehicle Templates are compatible R2018b - R2024a**

**v2.16 -- April 2024**
1.  Compatible with MF-Swift v2312
2.  Adjusted double-lane change to match Unreal scene (R2022b and higher)
3.  Made project shortcuts compatible with MATLAB Online
4.  Fixed capitalization error in sm_car_database_Maneuver.xlsx (...Hockenheim_F_ --> Hockenheim_f_)

**v2.15 -- March 2024**
1.  Compatible with R2024a. Updated scripts to run with Fast Restart

**v2.15 -- September 2023**
1.  Mass and inertia of driver and passengers are adjustable
2.  Added test harness to check driver and passenger mass
3.  Compatible with MF-Swift v2306

**v2.14 -- March 2023**
1.  Adjusted hardpoints for all linkage suspensions (shorter control arms, shock placement)
2.  Added linkage parameterizations for Sedan Hamba (Five Link Shock to Rear, Split Lower Arm Shock to Front)
3.  Softened springs in Sedan Hamba
4.  Added script to check hardpoint consistency between linkage, spring, and damper systems
5.  Added measurement bus from within Linkage subsystems
6.  Enabled steering variant to be adjusted and keep location of driver 
7.  Added steering testrig, camera testrig
8.  Eliminated unsupported parameters in Truck_430_50R38.tir
9.  Added shock model with endstop on upper hardpoint
10. Linked all shocks to library Linkage_Shock.slx
11. Adjusted and republished Overview
12. Detached test harnesses from sm_car_lib.slx
13. Converted hydraulic brakes 4 channel to Isothermal Liquid domain (R2020a and higher)
14. Compatible with MF-Swift v2212

**v2.13 -- February 2023**
1.  Added 4 electric motor powertrain for 2 axle car

**v2.12 -- October 2022**
1.  Fixed plotting script in workshop exercise 6 (temperature -> cell_temperature)

**v2.11 -- September 2022**
1.  Added function sm_car_lib_activeVariantBlock.m to get active variant for variant subsystem icon 
2.  Adjusted variant subsystems to use sm_car_lib_activeVariantBlock.m
3.  Adjusted CAD frames on STEP files in Kumanzi, truck wheels

**v2.10 -- August 2022**
1.  Steering wheel geometry can be set to FSAE (Formula Student)
2.  Added Double Lane Change ISO 3888 (conforms to ISO standard)
3.  Added event CRG Hockenheim, CRG Hockenheim F

**v2.9 -- July 2022**
1.  Added default value for roadFile to sm_car_data_Tire_MFMbody.xlsx 
2.  Enabled scrollable setting on configuration app 

**v2.8 -- June 2022**
1.  Added code to define CRG surface from grid of points 
2.  Added event CRG Rough Road
3.  Added code to test protecting vehicle model
4.  Updated suspension linkage parameterization to enable run-time parameter tuning in protected models

**v2.7 -- May 2022**
1.  Simscape Multibody tire can be used on uneven roads with slope and banking (CRG defined, R2022a and higher)
2.  Added files for OpenCRG v1.1.2 under Apache license
3.  Models tested with Siemens MF-Tyre/MF-Swift Software v2022.1
4.  Replaced two geometry files to address issue on Mac only

**v2.6 -- November 2021**
1.  Added decoupled suspension linkages: double wishbone, double wishbone no steer, 5 link.
2.  Added decoupled roll and heave stiffness and damping
3.  Added method for generating GGV diagram by sweeping gravity vector and aero loads
4.  Added option to constrain vehicle with no yaw (for GGV tests)
5.  Added option to vary gravity vector (for GGV tests)
6.  Added option to terminate simulation based on maximum speed (for GGV tests)
7.  Added unique aero settings for sedan and FSAE vehicle
8.  Adjusted project startup script to work with parallel simulations
9.  Adjusted four-wheel steering algorithm to make rear steer gain speed-dependent, updated test
10. Fixed plots for showing fastest lap from optimization
11. Fixed startup script to avoid 'dir(**/*)' command on Mac and Linux (for MF-Swift)

**v2.5.1 -- October 2021**
1.  Reduced scaling factor for initial speed in lap time optimizations.

**v2.5 -- October 2021**
1.  Increased initial speed for racetrack events to avoid wheels losing traction at start.

**v2.4 -- September 2021**
1.  Added option to use Simscape Multibody tire model (R2021b and higher)
2.  Fixed parameterization of rim and tire mass, inertia
3.  Changed "Inertia" parameter to "mjRim" for rim mass and inertia

**v2.3 -- June 2021**
1.  Added basic torque vectoring algorithm (rear axle only).
2.  Added 2 templates for double-wishbone suspension, pushrod to upper arm.
3.  Added anti-roll bar with rod linkage.
4.  Added preset based on Formula SAE car sizing.
5.  Adjusted controller and steering systems to permit steering on multiple axles.
6.  Camera frame definitions from MATLAB (was Excel), adjusted Mechanics Explorer configuration
7.  Added basic control parameters for default, ideal powertrain.
8.  Added display elements for battery temperature with test script.
9.  Fixed Ice Patch maneuver, Swift tire (use external road).
10. Updated model for replaying results in Unreal to show two vehicles.

**v2.2 -- May 2021**
1. Added exercises 1-7 to teach basics of Simscape Vehicle Templates
2. Added library and code to work with Simcenter Tire 2021.1 (new .tir parser)
3. Updated fuel cell variant to work with boost converter, averaged switch (R20a and higher only)

**v2.1 -- Mar 2021**
1. Fixed bug in Simscape Vehicle Templates interface to MFeval CPI tire model
2. Updated regenerative braking model to properly account for available motor torque
3. Added serial regenerative braking algorithm for battery 2 motor powertrain
4. Added presets for battery 2 motor powertrain with brake-by-wire for serial regenerative braking
5. Added optimization example for lap time that considers battery SOC in cost function
6. Modified code to handle update to find_system() for active variants in R2021a
7. Increased bandwidth of brake actuators in PedalAbstract

**v2.0 -- Dec 2020**
**Major changes in this release to enable multi-axle vehicles.**
**Datasets compatible with earlier releases will need changes to work with this version.**
1. Added semi-truck (3 axles, 10 wheels), box trailer and tank trailer (2 axles, 8 wheels) 
2. Added optional pendulum slosh model to tank trailer
3. Added second base model (sm_car_Axle3.slx) for 3-axle vehicles pulling 2-axle trailers
4. MATLAB app can be used with base models of any name (model name is a dialog box field)
5. Axles enumerated 1, 2, 3 instead of front, rear
6. Initial values for maneuvers specified in MATLAB (was Excel)
7. Maneuver setup sets initial speed for trailer wheels
8. Data for driver models specified in MATLAB (was Excel)

**v1.6 -- Oct 2020**
1.  Added Event Constant Radius
2.  Added CRG Custom (slot for custom events, copy of CRG Mallory Park)
3.  Added Drive Cycle UrbanCycle1
4.  Added stop conditions (lateral deviation too high, lap complete)
5.  Added lateral deviation to logged results
6.  Corrected lateral deviation calculation
7.  Added example optimization for lap time (Workflows/Optimize)
8.  Removed discrete signals from traffic light signal
9.  Adjusted default trajectory CRG Mallory Park, CRG Nurburgring
10. Adjusted maneuver configuration to stop after one lap (lap events only)
11. Cleaned up trajectory definition sm_car_trajectory_double_lane_change.m

**v1.5 -- Aug 2020**
1. Added power Fuel Cell 1 Motor
2. Added Control data structure with control parameters
3. Added driveline FDiff for front wheel drive
4. Added ssc_car_FuelCell1Motor
5. Added Drive Cycle FTP75, Driver Drive Cycle
6. Consistent parameterization for all electric motor powertrains
7. Fixed bug in import of 2D tables from Excel (were flipped up/down) 

**v1.4 -- Aug 2020**

1. Moved vehicle Body sensor to CG (Vehicle, Vehicle_1Axle). Affects VehBus
2. Added sensors to passengers
3. Added ability to specify road height based on wheel position 
4. Added events Plateau Z Only, Rough Road Z Only
5. Added option to create CRG files based on x-y-z data
6. Added event CRG Plateau
7. Adjusted diagnostic for tire types in sm_car_config_road.m
8. Revised full test scripts - more modular, eliminate FastRestart warnings
   (sm_car_test_variants.m, added sm_car_test_variants_testloop.m)

### **Release History**
**v1.3 -- July 2020**

1. Changed sm_car top level to accommodate overrides from obstacles in scenes
2. Added scene Track Mallory Park Obstacle with stoplights to override speed
3. Adjusted sm_car_config_maneuver to adjust stop conditions, wind conditions
4. Added scene MCity with default trajectory and script to define one from UI
5. Adjusted xTrajectory.vx and Maneuver.vGain so that all vGain values are one
6. Added CRG road Kyalami

**v1.2 -- May 2020**

1. Added MF-Swift, CRG roads (Nurburg, Suzuka, Pikes, Mallory)
2. Swapped in MFeval 4.0
3. Fixed original Mallory park

**v1.1 -- Mar 2020**

1. Added electric powertrain options with cooling circuit

**v1.0 -- Mar 2020**

First release


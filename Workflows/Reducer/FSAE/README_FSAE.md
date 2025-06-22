# **​​Formula Student Vehicle with Simscape&trade;**

This library contains a multibody model of a formula student vehicle 
with an electric powertrain.  
You can:

   1. Select different suspension types.
   2. Adjust parameter values for the selected vehicle configuration.
   3. Configure the vehicle model to run different maneuvers.
   4. Visualize the simulation results in a 3D animation.

The templates are designed to be extendable. Create your own variant for any portion 
of the vehicle model (such as the brakes, suspension, or drivetrain) and you can 
adjust the libraries so that variant can be selected.

View on File Exchange:  [![View Formula Student Vehicle with Simscape on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/172279-formula-student-vehicle-with-simscape)  

**Please visit the [Simscape Vehicle Templates](https://www.mathworks.com/solutions/physical-modeling/simscape-vehicle-templates.html) page** for animations and videos that show what you can do with these models.

![](Scripts_Data/Overview/Simscape_Vehicle_Templates_FSAE_animation.png)

![](Scripts_Data/Overview/Simscape_Vehicle_Templates_FSAE_model.png)

## **Getting Started**
1. Open the project file SSVT\_FSAE.prj 
2. Click on the hyperlinks to swap suspension types and maneuver. 
3. Modify parameter values in the "Vehicle" data structure in the MATLAB workspace.

Copyright 2024 The MathWorks, Inc.
 
### **Release History**
**v4.1  -- June 2025**
(Not all changes to Simscape Vehicle Templates affect this repository)
1.  Adjusted parameterized sedan profile to extend above driver, steering wheel.
2.  Added bushings with axial and torsional stiffness
3.  Added additional tests to KnC (force offset from contact patch, force at wheel center)
4.  Added visual elements for forces and torques in KnC test
5.  Function for visuals can update dimensions only (custom colors, opacities not overwritten)
6.  Added simple UI for plotting results (2D)
7.  Added simple UI for plotting and animating results in 3D
8.  Optimization script can handle multiple performance metrics
9.  Sweep and optimization examples can handle any parameter, any axle
10. Lateral drivers are customizeable (Stanley and Pure Pursuit)
11. Enhanced maneuver and driver so that vehicle can drive events in reverse. 
12. Stop criteria uses lap counter to detect end of lap
13. Independently override commands for steering wheel, accelerator pedal, and brake pedal.

**v4.0  -- May 2025**
(Not all changes to Simscape Vehicle Templates affect this repository)
1.  Kinematics and Compliance test added to quarter, half, and full car models
... Includes roll, steering, lateral compliance, longitudinal compliance tests
2.  47 metrics reported from KnC tests
3.  Suspension linkage with pushrod added (steer, no steer)
4. Optional bushing connections added to anti-roll bar
5. Alignment of wishbone joints handled within variant subsystems
6. Shock spring preload can be specified by deformation or force (new parameter fPreload)

**v3.9  -- Feb 2025**  R2022a - R2024b
(Not all changes to Simscape Vehicle Templates affect this repository)
1.  Added event GS Uneven Road to show Grid Surface to Magic Formula Tire (R2024b and higher).
2.  Added example to go from CRG to STL to grid surface data.
3.  Updated Longitudinal Driver model.

**v3.8  -- Feb 2025**  R2022a - R2024b
1.  Added 12 additional KnC metrics to testrig_quarter_car* models 
2.  Made path-following driver robust when traveling far inside of a sharp corner 

**v3.7  -- Nov 2024**  R2022a - R2024b
1.  Minor fixes to suspension metrics, hyperlinks in testrig_quarter_car* models 

**v3.6  -- Nov 2024**  R2022a - R2024b
1.  Hardpoints in all suspensions can be tuned without recompiling (use Fast Restart).
2.  Added Suspension Tester App for sweeping and optimizing hardpoint locations.

**v3.5  -- Nov 2024**  R2022a - R2024b
1.  Renamed suspension "PushUA" to "Pullrod".

**v3.4  -- Oct 2024**  R2022a - R2024b
1.  Added optional compliance elements to all inboard connections of suspension arms.
2.  Added bushing testrig to test linear, nonlinear, and nonlinear with hysteresis force laws

**v3.2  -- Oct 2024**  R2022a - R2024b
1.  Improved trajectory follower with smoother transitions between segments.
2.  Fixed data types for lap counter. 
3.  Added method to terminate simulation when vehicle distance along trajectory exceeds threshold. 

**v3.1 -- September 2024** R2022a - R2024a
1. Added pushrod Suspension
2. Added Hockenheim Flat maneuver
3. Added quarter car testrig for double wishbone and pushrod suspension

**v3.0 -- September 2024**
First release, R2022a - R2024a
1. Double-Wishbone Suspension, Decoupled Double-Wishbone Suspension
2. Skidpad, Hockenheim, Accel/Decel maneuvers
3. Example torque vectoring algorithm 



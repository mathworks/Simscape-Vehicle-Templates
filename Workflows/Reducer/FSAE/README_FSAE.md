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
**v3.3  -- Oct 2024**  R2022a - R2024b
1.  Toe and camber calculations suitable for left and right sides.
2.  Added suspension metrics (bump steer, caster, steering angle inclination, etc.)

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



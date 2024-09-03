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

**Please visit the [Simscape Vehicle Templates](https://www.mathworks.com/solutions/physical-modeling/simscape-vehicle-templates.html) page** for animations and videos that show what you can do with these models.

![](Scripts_Data/Overview/Simscape_Vehicle_Templates_FSAE_animation.png)

![](Scripts_Data/Overview/Simscape_Vehicle_Templates_FSAE_model.png)

## **Getting Started**
1. Open the project file SSVT\_FSAE.prj 
2. Click on the hyperlinks to swap suspension types and maneuver. 
3. Modify parameter values in the "Vehicle" data structure in the MATLAB workspace.

Copyright 2024 The MathWorks, Inc.
 
### **Release History**
**v3.0 -- September 2024**
First release, R2022a - R2024a
1. Double-Wishbone Suspension, Decoupled Double-Wishbone Suspension
2. Skidpad, Hockenheim, Accel/Decel maneuvers
3. Example torque vectoring algorithm 



Simscape Multibody Parts Library
Copyright 2017-2023 The MathWorks, Inc.

This set of examples shows you how to create parameterized parts for Simscape Multibody
and example MATLAB scripts for defining general extrusions.  The parts have been used in a 
wide range of examples to show how these blocks enable you to rapidly model mechanisms.
Consistent orientation of frames at the interfaces make it easy to combine them.

Read the README.txt file to learn more.
Open >> Parts_Lib.prj to get started.

Within the Simscape Multibody Parts Library, you will find parameterized gear assemblies.
The gear constraint blocks require that other constraints in the mechanism correctly position 
and orient the frames associated with the gear constraint.  The library blocks group
the required blocks together and parameterize them so that frames are always in the right place.  
There are many ways they can be combined, this library shows you one way to do it.

#########  Release History  #########  
v 3.0 (R2018b)	Sep  2018   Updated mask images to mask new icons
                            Added opacity to cylinder, rod, and gears

v 2.4 (R2018a)	Mar  2018   Added pulley part and extrusion script.
                            Added example Three Connected Pulleys
                            Added example Cable-Driven XY Table with Cross Base

v 2.3 (R2017b)	Sep  2017   Added cone part and extrusion script, sphere part

v 2.2 (R2017a)	Aug  2017   Rod part: Added parameter "Relative Position (B to F)"
                            Permits changing direction of rod without rewiring diagram.
                            Useful in symmetrical opposing mechanisms, such as crossbars
                            on a scissor lift.

v 2.1 (R2017a)	Jul  2017   Added cone part and extrusion script, sphere part

v 2.0 (R2017a)	Jun  2017   Add gearset assemblies, gears, many examples

        12 Extrusion scripts, plus two functions for calculating area and perimeter.
        19 examples, plus 9 examples to show parts

        Absorbed Simscape Multibody Gearset Library v1.0 into this submission
                Gear assemblies for Common Gear, Rack and Pinion, Bevel Gear
                Bevel Gear 2x, Bevel Gear 4x Closed, and Worm Gear
                11 examples, including lead screw, lead screw with
                friction, open differential, and water powered lift


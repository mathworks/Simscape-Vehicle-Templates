function Scene3DPlot = sm_car_plot3d_get_scene(Scene,MDatabase)
% sm_car_plot3d_get_scene Extract Scene data for 3D plotter 
%    Scene3DPlot = sm_car_plot3d_get_scene(Scene,MDatabase)
%    This function extracts the data needed to plot the road surface in the
%    Vehicle Results 3D Plotter.  The center line and road dimensions are
%    extracted from the fields in the Scene and MDatabase MATLAB
%    structures.
%
%    Scene     MATLAB structure with Simscape Vehicle Templates scene parameters
%    MDatabase MATLAB structure with Simscape Vehicle Templates maneuver parameters
%
%    Output is Scene3DPlot, a MATLAB structure with fields containing
%    parameters needed to plot the scene in the 3D plotter
%
% Copyright 2025 The MathWorks, Inc.

% Get CRG_* scenes, which contain centerline and width
SceneNames   = fieldnames(Scene);
fNames_SCRGF = ~cellfun(@isempty,regexp(SceneNames,'CRG_.*'));
List_CRGf    = SceneNames(fNames_SCRGF);

numScenes = 0;
for s_i = 1:length(List_CRGf)
    SName = List_CRGf{s_i};
    if(isfield(Scene.(SName).Geometry,'centerline') ...
            && isfield(Scene.(SName).Geometry,'w'))
        numScenes = numScenes + 1;
        Scene3DPlot.(SName).centerline = Scene.(SName).Geometry.centerline.xyz;
        Scene3DPlot.(SName).width          = Scene.(SName).Geometry.w;
    end
end

% Get Skidpad parameters from MDatabase
if(isfield(Scene,'Skidpad'))
    Scene3DPlot.Skidpad.centerline = [...
        MDatabase.Skidpad.Sedan_Hamba.Trajectory.x.Value',...
        MDatabase.Skidpad.Sedan_Hamba.Trajectory.y.Value',...
        MDatabase.Skidpad.Sedan_Hamba.Trajectory.z.Value'];
    Scene3DPlot.Skidpad.width          = ...
        Scene.Skidpad.Circle_Outer.d - Scene.Skidpad.Circle_Inner.d;
end

% Get Road size from Scene
if(isfield(Scene,'Road_Two_Lane'))
    Scene3DPlot.Road_Two_Lane.centerline    = [...
        0                          Scene.Road_Two_Lane.Road.y 0;...
        Scene.Road_Two_Lane.Road.l Scene.Road_Two_Lane.Road.y 0];
    Scene3DPlot.Road_Two_Lane.width =  Scene.Road_Two_Lane.Road.w;

    % Get Slalom (does not have offset as double lane change has
    Scene3DPlot.Slalom.centerline = Scene3DPlot.Road_Two_Lane.centerline.*...
        [1 0 1;1 0 1];
    Scene3DPlot.Slalom.width =  Scene.Road_Two_Lane.Road.w;
end

% Create a big flat surface for other maneuvers
Scene3DPlot.Flat.centerline = [0 0 0;1000 0 0];
Scene3DPlot.Flat.width =  1000;

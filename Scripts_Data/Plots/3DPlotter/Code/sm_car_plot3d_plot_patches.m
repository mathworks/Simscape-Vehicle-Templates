function sm_car_plot3d_plot_patches(vehiclePatchData)
% sm_car_plot3d_plot_patches  Create plot of 3D elements for results plot
%   sm_car_plot3d_plot_patches(vehiclePatchData)
%
%   This function plots the vehicle body and one wheel in a figure window.
%   These figures can be used to check element sizes and location of
%   reference point [0 0 0].
%
%   vehiclePatchData   Structure of data for visual element
%      .Vehicle          Patch info for vehicle chassis
%              .colors      Cell array of [R G B] colors, one per element
%              .faces       Cell array of [# # #] faces, one per element
%              .opacities   Cell array of (0-1) opacities , one per element
%              .vertices    Cell array of [x y z] vertices, one per element
%                             Frame for position data is at [0 0 0]
%        .ChassisPatchInd   Index of element suitable for marking the
%                             swept path of the vehicle (body)
%
%        .Wheel          Patch info for right-facing wheel 
%              .colors      Cell array of [R G B] colors, one per element
%              .faces       Cell array of [# # #] faces, one per element
%              .opacities   Cell array of (0-1) opacities , one per element
%              .vertices    Cell array of [x y z] vertices, one per element
%                             Center of wheel is at [0 0 0]
%              .radius      Single value for radius of tire
%
% Copyright 2025 The MathWorks, Inc.

% Reuse figure if it exists, else create new figure
fig_handle_name =   'h1_sm_car_plot3d_patches';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Plot vehicle chassis
subplot(211)
for patchInd = 1:size(vehiclePatchData.Vehicle.colors,2)  
patch(...
    'Faces',     vehiclePatchData.Vehicle.faces{patchInd}, ...
    'Vertices',  vehiclePatchData.Vehicle.vertices{patchInd}, ...
    'FaceColor', vehiclePatchData.Vehicle.colors{patchInd}, ...
    'FaceAlpha', vehiclePatchData.Vehicle.opacities{patchInd}, ...
    'EdgeColor', 'none', 'FaceLighting', 'gouraud', 'AmbientStrength', 0.3, ...
    'DiffuseStrength', 0.8, 'SpecularStrength', 0.9, 'SpecularExponent', 25, 'BackFaceLighting', 'reverselit');
end
axis equal
box on
view(22,17)

% Plot wheel element
subplot(212)
for patchInd = 1:size(vehiclePatchData.Wheel.colors,2)  
patch(...
    'Faces',     vehiclePatchData.Wheel.faces{patchInd}, ...
    'Vertices',  vehiclePatchData.Wheel.vertices{patchInd}, ...
    'FaceColor', vehiclePatchData.Wheel.colors{patchInd}, ...
    'FaceAlpha', vehiclePatchData.Wheel.opacities{patchInd}, ...
    'EdgeColor', 'none', 'FaceLighting', 'gouraud', 'AmbientStrength', 0.3, ...
    'DiffuseStrength', 0.8, 'SpecularStrength', 0.9, 'SpecularExponent', 25, 'BackFaceLighting', 'reverselit');
end
axis equal
box on
view(22,17)

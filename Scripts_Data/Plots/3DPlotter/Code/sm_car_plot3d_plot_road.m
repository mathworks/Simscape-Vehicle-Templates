function [hPatch, road, figHandle, axHandle] = sm_car_plot3d_plot_road(varargin)
% Creates a 3D road surface from waypoints and displays it as a patch.
% Includes a white centerline marking patch and alternating red/white curb patches.
% Optionally plots terrain data underneath the road (only available when providing boundaries).
% Curb geometry is interpolated if curbSectionLength is smaller than original segments.
% Handles closed loops where the distance between the first and last 
% waypoints is within a specified tolerance.
% Sets camera view and material properties for a more realistic look.
% Uses Phong lighting and an explicitly positioned light source.
% Returns a structure containing geometry, appearance, and scene settings.
% 
% Input Modes & Arguments:
% 1. sm_car_plot3d_plot_road(centerlineWaypoints, roadWidth, Name, Value, ...) 
%    (Terrain plotting is NOT supported in this mode)
% 2. sm_car_plot3d_plot_road(leftBoundaryWaypoints, rightBoundaryWaypoints, Name, Value, ...)
%
% Required Inputs (Mode 1):
%   centerlineWaypoints (Nx3 double): Matrix of centerline points [x;y;z]. N >= 2.
%   roadWidth (double): Total width of the road.
% Required Inputs (Mode 2):
%   leftBoundaryWaypoints (Nx3 double): Matrix of left edge points. N >= 2.
%   rightBoundaryWaypoints (Nx3 double): Matrix of right edge points. N >= 2.
%      Must have the same number of rows (N) as leftBoundaryWaypoints.
%
% Optional Name-Value Pair Arguments:
%   'CurbSectionLength' (double): Desired length of each red/white curb section. 
%                                 If omitted or <=0, alternates per original segment.
%                                 If > 0 but >= smallest segment length, alternates per original segment (with warning).
%   'TerrainX' (1xP double): Vector of X coordinates for the terrain grid.
%   'TerrainY' (1xQ double): Vector of Y coordinates for the terrain grid.
%   'TerrainZ' (QxP double): Matrix of Z coordinates (heights) for the terrain grid.
%                            (Requires TerrainX/Y, only used if Mode 2 is active).
%
% Returns:
%   hPatch (handle): Handle to the created road surface patch object.
%   road (struct): Structure containing road geometry, appearance, and scene data:
%                  - road.vertices (matrix): Vertex coordinates for the road surface.
%                  - road.faces (matrix): Face definitions (same for road and marking).
%                  - road.faceColor (vector): RGB color for road faces.
%                  - road.edgeColor (vector/string): Color/setting for road edges.
%                  - road.markingVertices (matrix): Vertex coordinates for the centerline marking.
%                  - road.markingFaceColor (vector): RGB color for marking faces.
%                  - road.markingEdgeColor (vector/string): Color/setting for marking edges.
%                  - road.markingPatchHandle (handle): Handle to the created marking patch object.
%                  - road.leftCurbVertices (matrix): Vertices for the left curb.
%                  - road.rightCurbVertices (matrix): Vertices for the right curb.
%                  - road.curbFaces (matrix): Faces specifically for curbs (might differ if interpolated).
%                  - road.curbFaceVertexCData (matrix): Color data for curb faces (alternating).
%                  - road.leftCurbPatchHandle (handle): Handle to the left curb patch.
%                  - road.rightCurbPatchHandle (handle): Handle to the right curb patch.
%                  - road.roadMaterial (cell): Cell array of road material properties.
%                  - road.markingMaterial (cell): Cell array of marking/curb material properties.
%                  - road.terrainMaterial (cell): Cell array of terrain material properties.
%                  - road.terrainX (vector): Original TerrainX input (if provided).
%                  - road.terrainY (vector): Original TerrainY input (if provided).
%                  - road.terrainZ (matrix): Original TerrainZ input (if provided).
%                  - road.terrainHandle (handle): Handle to the terrain surface (if plotted).
%                  - road.lightingStyle (string): FaceLighting style used (e.g., 'phong').
%                  - road.lightPosition (vector): Position of the light source.
%                  - road.cameraPosition (vector): Camera position vector.
%                  - road.cameraTarget (vector): Camera target point vector.
%                  - road.cameraUpVector (vector): Camera up vector.
%                  - road.cameraViewAngle (scalar): Camera view angle.
%                  - road.axisProperties (struct): Structure with axis settings (e.g., Grid, DataAspectRatio).
%   figHandle (handle): Handle to the figure window.

% --- Constants ---
LOOP_TOLERANCE   = 3.0;    % Distance tolerance (in meters) to consider a loop closed
MARKING_WIDTH    = 0.25;    % Width of the centerline marking (e.g., 25 cm)
CURB_WIDTH       = 0.5;       % Width of the curb markings (e.g., 45 cm)
MARKING_Z_OFFSET = 0.01; % Small vertical offset for marking/curb patches
TERRAIN_Z_OFFSET = 0.15; % Small vertical offset to lower terrain below road
camera = 0;

% --- Material Properties ---
ROAD_AMBIENT     = 0.4; 
ROAD_DIFFUSE     = 0.6; 
ROAD_SPECULAR    = 0.1; 
ROAD_SPEC_EXP    = 10;

MARKING_AMBIENT  = 0.6; 
MARKING_DIFFUSE  = 0.9; 
MARKING_SPECULAR = 0.9; 
MARKING_SPEC_EXP = 25; % Glossier

TERRAIN_COLOR = [0.1 0.6 0.1]; % Green for terrain
TERRAIN_AMBIENT = 0.5; 
TERRAIN_DIFFUSE = 0.5; 
TERRAIN_SPECULAR = 0.05; 
TERRAIN_SPEC_EXP = 5; % Matte


% --- Input Parsing and Validation ---
if nargin < 2
     error('Requires at least two input arguments (waypoints/boundaries and width/boundary).');
end

input1    = varargin{1};
input2    = varargin{2};
axHandle  = varargin{3};
varargin_start_index = 4; % Index where potential Name-Value pairs start

% Determine mode based on the first two inputs
mode = ''; 
if isnumeric(input1) && size(input1, 2) == 3 && size(input1, 1) >= 2 && ...
   isnumeric(input2) && isscalar(input2) && input2 > 0
    mode = 'CenterlineWidth';
    waypoints = input1;
    roadWidth = input2;
    %fprintf('Mode detected: Centerline and Width\n');
elseif isnumeric(input1) && size(input1, 2) == 3 && size(input1, 1) >= 2 && ...
       isnumeric(input2) && size(input2, 2) == 3 && size(input2, 1) >= 2 && ...
       size(input1, 1) == size(input2, 1)
    mode = 'Boundaries';
    leftWaypoints = input1;
    rightWaypoints = input2;
    waypoints = (leftWaypoints + rightWaypoints) / 2; % Estimate centerline 
    %fprintf('Mode detected: Left and Right Boundaries\n');
else
     error(['Invalid primary input arguments. Call either with:' ...
           '\n1. (centerlineWaypoints (Nx3, N>=2), roadWidth (scalar > 0), [NV Pairs])' ...
           '\n2. (leftBoundaryWaypoints (Nx3, N>=2), rightBoundaryWaypoints (Nx3, N>=2, same N), [NV Pairs])']);
end

% --- Parse Optional Name-Value Arguments ---
p = inputParser;
addParameter(p, 'CurbSectionLength', -1, @(x) isnumeric(x) && isscalar(x));
addParameter(p, 'TerrainX', [], @isvector);
addParameter(p, 'TerrainY', [], @isvector);
addParameter(p, 'TerrainZ', [], @ismatrix);

% Parse remaining arguments
if nargin >= varargin_start_index
    parse(p, varargin{varargin_start_index:end});
else
    parse(p); % Parse with defaults if no NV pairs
end
nvResults = p.Results;
curbSectionLength = nvResults.CurbSectionLength;

% --- Further Validation and Setup ---
isLoop = false; % Flag for closed loop detection

if strcmp(mode, 'CenterlineWidth')
    % Check for loop in centerline mode using tolerance
    if size(waypoints, 1) >= 3 
        distance = norm(waypoints(1,:) - waypoints(end,:)); % Euclidean distance
        if distance < LOOP_TOLERANCE
            isLoop = true;
            waypoints = waypoints(1:end-1, :); % Remove last point (it's close enough to first)
            %fprintf('  Closed loop detected (Centerline, tolerance=%.2f m).\n', LOOP_TOLERANCE);
        end
    end
elseif strcmp(mode, 'Boundaries')
    numWaypoints = size(leftWaypoints, 1);
    % Check for loop in boundaries mode using tolerance
    if numWaypoints >= 3 
        distance_left = norm(leftWaypoints(1,:) - leftWaypoints(end,:));
        distance_right = norm(rightWaypoints(1,:) - rightWaypoints(end,:));
        % Consider it a loop if EITHER boundary is close
        if distance_left < LOOP_TOLERANCE || distance_right < LOOP_TOLERANCE 
            isLoop = true;
            leftWaypoints = leftWaypoints(1:end-1, :); 
            rightWaypoints = rightWaypoints(1:end-1, :);
            waypoints = waypoints(1:end-1,:); 
            numWaypoints = size(leftWaypoints, 1); 
            % fprintf('  Closed loop detected (Boundaries OR, tolerance=%.2f m).\n', LOOP_TOLERANCE);
        end
    end
end

numWaypoints = size(waypoints, 1); % Number of unique waypoints

if numWaypoints < 2
    error('Requires at least 2 unique waypoints to create a surface.');
end

% Validate terrain inputs together
hasTerrainX = ~isempty(nvResults.TerrainX);
hasTerrainY = ~isempty(nvResults.TerrainY);
hasTerrainZ = ~isempty(nvResults.TerrainZ);
plotTerrain = false;
if hasTerrainX || hasTerrainY || hasTerrainZ % Check if any terrain data was provided
    if strcmp(mode, 'Boundaries') % Only allow terrain if in boundary mode
        if hasTerrainX && hasTerrainY && hasTerrainZ % Check if all are provided
            if size(nvResults.TerrainZ, 1) == length(nvResults.TerrainY) && ...
               size(nvResults.TerrainZ, 2) == length(nvResults.TerrainX)
                plotTerrain = true;
                %fprintf('Terrain data provided and validated (Boundary Mode).\n');
            else
                warning('TerrainZ dimensions must match length(TerrainY) x length(TerrainX). Terrain will not be plotted.');
            end
        else
            warning('TerrainX, TerrainY, and TerrainZ must all be provided to plot terrain. Terrain will not be plotted.');
        end
    else % In CenterlineWidth mode
         warning('Terrain plotting is only supported when providing left/right boundaries. Terrain will not be plotted.');
    end
end


% --- Calculate Original Segment Lengths and Check Interpolation Need ---
segmentLengths = zeros(numWaypoints, 1); 
waypointIndicesForSegments = [1:numWaypoints; mod((1:numWaypoints), numWaypoints)+1]'; 
if ~isLoop 
    waypointIndicesForSegments = waypointIndicesForSegments(1:end-1,:); 
end

minSegmentLength = inf;
for i = 1:size(waypointIndicesForSegments, 1)
     idx1 = waypointIndicesForSegments(i,1);
     idx2 = waypointIndicesForSegments(i,2);
     len = norm(waypoints(idx2,:) - waypoints(idx1,:));
     segmentLengths(idx1) = len; 
     if len > eps 
         minSegmentLength = min(minSegmentLength, len);
     end
end
if ~isLoop 
    if numWaypoints > 1 
        segmentLengths(numWaypoints) = norm(waypoints(end,:) - waypoints(end-1,:));
         if segmentLengths(numWaypoints) > eps
             minSegmentLength = min(minSegmentLength, segmentLengths(numWaypoints));
         end
    else
         segmentLengths(numWaypoints) = 0; 
    end
end

interpolateCurbs = false;
if curbSectionLength > 0 
    if curbSectionLength >= (minSegmentLength)*3000
        warning('curbSectionLength (%.2f) is >= minimum segment length (%.2f). Defaulting to alternating curb color per original segment.', curbSectionLength, minSegmentLength);
    else
        interpolateCurbs = true;
        %fprintf('Interpolating curb geometry for section length %.2f m.\n', curbSectionLength);
    end
elseif curbSectionLength == 0 % Explicitly handle 0 case if needed
     %fprintf('CurbSectionLength is 0. Defaulting to alternating per original segment.\n');
     curbSectionLength = -1; % Treat as default
end


% --- Calculate Tangents and Normals (Based on ORIGINAL waypoints) ---
tangents = zeros(numWaypoints, 3);
normals = zeros(numWaypoints, 3);

for i = 1:numWaypoints
    prevIdx = mod(i-2, numWaypoints) + 1; 
    nextIdx = mod(i, numWaypoints) + 1;   
    
    vecToPrev = waypoints(i,:) - waypoints(prevIdx,:); 
    vecToNext = waypoints(nextIdx,:) - waypoints(i,:); 

    if ~isLoop
        if i == 1, vecToPrev = vecToNext; end
        if i == numWaypoints, vecToNext = vecToPrev; end
    end

    norm_vec1 = vecToPrev / (norm(vecToPrev) + eps);
    norm_vec2 = vecToNext / (norm(vecToNext) + eps);
    avg_tangent = (norm_vec1 + norm_vec2) / 2;
    tangent_norm = norm(avg_tangent);

    if tangent_norm < eps 
        warning('Waypoint %d has near-opposite segments or is collinear. Using segment vector.', i);
         tangents(i, :) = vecToNext / (norm(vecToNext) + eps);
         if norm(tangents(i,:)) < eps, tangents(i,:) = [1 0 0]; end
    else
         tangents(i, :) = avg_tangent / tangent_norm; 
    end
    
    % Calculate XY-plane normal vector
    t = tangents(i, :);
    n_xy = [-t(2), t(1), 0]; 
    norm_n_xy = norm(n_xy);
    if norm_n_xy < eps 
        warning('Vertical or zero tangent at waypoint %d. Using default normal [1, 0, 0].', i);
        normals(i, :) = [1, 0, 0]; 
    else
        normals(i, :) = n_xy / norm_n_xy;
    end
end

% --- Calculate Road Edge Vertices (Based on ORIGINAL waypoints) ---
roadVertices = zeros(numWaypoints * 2, 3);
if strcmp(mode, 'CenterlineWidth')
    halfWidth = roadWidth / 2;
    for i = 1:numWaypoints
        P = waypoints(i, :); 
        N = normals(i, :);   
        L = P - halfWidth * N;
        R = P + halfWidth * N;
        roadVertices(2*i - 1, :) = L; 
        roadVertices(2*i, :)     = R; 
    end
elseif strcmp(mode, 'Boundaries')
     for i = 1:numWaypoints
        roadVertices(2*i - 1, :) = leftWaypoints(i,:);  
        roadVertices(2*i, :)     = rightWaypoints(i,:); 
     end
end

% --- Calculate Marking Edge Vertices (Based on ORIGINAL waypoints) ---
markingVertices = zeros(numWaypoints * 2, 3);
halfMarkingWidth = MARKING_WIDTH / 2;
z_offset_vector = [0, 0, MARKING_Z_OFFSET]; % Define Z offset vector
for i = 1:numWaypoints
    P = waypoints(i, :); 
    N = normals(i, :);   
    L_mark = (P - halfMarkingWidth * N) + z_offset_vector; 
    R_mark = (P + halfMarkingWidth * N) + z_offset_vector;
    markingVertices(2*i - 1, :) = L_mark; 
    markingVertices(2*i, :)     = R_mark; 
end

% --- Define Faces for Road/Marking (Based on ORIGINAL waypoints) ---
numOriginalFaces = numWaypoints - 1;
if isLoop, numOriginalFaces = numWaypoints; end
if numOriginalFaces < 1, error('Cannot create faces with fewer than 2 unique waypoints.'); end

roadFaces = zeros(numOriginalFaces, 4); 
for i = 1:(numWaypoints - 1) 
    idx_Li   = 2*i - 1; idx_Ri   = 2*i;
    idx_Ri1  = 2*(i+1); idx_Li1  = 2*(i+1) - 1;
    roadFaces(i, :) = [idx_Li, idx_Ri, idx_Ri1, idx_Li1];
end
if isLoop 
    idx_LN = 2*numWaypoints - 1; idx_RN = 2*numWaypoints;
    idx_R1 = 2; idx_L1 = 1; 
    roadFaces(numWaypoints, :) = [idx_LN, idx_RN, idx_R1, idx_L1];
end


% --- Calculate Curb Vertices/Faces/Colors ---
leftCurbVertices = []; % Initialize curb data
rightCurbVertices = [];
curbFaces = [];
curbFaceColors = [];

if interpolateCurbs
    % --- Interpolate Curb Vertices and Define Curb Faces/Colors ---
    allLeftCurbInner = []; allLeftCurbOuter = [];
    allRightCurbInner = []; allRightCurbOuter = [];
    
    for i = 1:size(waypointIndicesForSegments, 1) % Loop through original segments
        idx1 = waypointIndicesForSegments(i,1); idx2 = waypointIndicesForSegments(i,2);
        L1_road = roadVertices(2*idx1 - 1, :); R1_road = roadVertices(2*idx1, :);
        L2_road = roadVertices(2*idx2 - 1, :); R2_road = roadVertices(2*idx2, :);
        N1 = normals(idx1,:); N2 = normals(idx2,:); 

        L1_curb_in = (L1_road - CURB_WIDTH * N1) - z_offset_vector; L1_curb_out = (L1_road + CURB_WIDTH * N1) - z_offset_vector;
        L2_curb_in = (L2_road - CURB_WIDTH * N2) - z_offset_vector; L2_curb_out = (L2_road + CURB_WIDTH * N2) - z_offset_vector;
        R1_curb_in = (R1_road - CURB_WIDTH * N1) - z_offset_vector; R1_curb_out = (R1_road + CURB_WIDTH * N1) - z_offset_vector;
        R2_curb_in = (R2_road - CURB_WIDTH * N2) - z_offset_vector; R2_curb_out = (R2_road + CURB_WIDTH * N2) - z_offset_vector;

        segLen = segmentLengths(idx1);
        numSections = max(1, floor(segLen / curbSectionLength)); 
        t_vals = linspace(0, 1, numSections + 1)'; 
        
        interp_L_in = L1_curb_in + t_vals * (L2_curb_in - L1_curb_in);
        interp_L_out = L1_curb_out + t_vals * (L2_curb_out - L1_curb_out);
        interp_R_in = R1_curb_in + t_vals * (R2_curb_in - R1_curb_in);
        interp_R_out = R1_curb_out + t_vals * (R2_curb_out - R1_curb_out);

        startIdx = 1; if i > 1, startIdx = 2; end 
        
        allLeftCurbInner = [allLeftCurbInner; interp_L_in(startIdx:end,:)];
        allLeftCurbOuter = [allLeftCurbOuter; interp_L_out(startIdx:end,:)];
        allRightCurbInner = [allRightCurbInner; interp_R_in(startIdx:end,:)];
        allRightCurbOuter = [allRightCurbOuter; interp_R_out(startIdx:end,:)];
    end
    
    numInterpolatedPoints = size(allLeftCurbInner, 1);
    leftCurbVertices = zeros(numInterpolatedPoints * 2, 3);
    rightCurbVertices = zeros(numInterpolatedPoints * 2, 3);
    for k = 1:numInterpolatedPoints
        leftCurbVertices(2*k - 1, :) = allLeftCurbOuter(k,:);
        leftCurbVertices(2*k, :)     = allLeftCurbInner(k,:);
        rightCurbVertices(2*k - 1, :) = allRightCurbInner(k,:);
        rightCurbVertices(2*k, :)     = allRightCurbOuter(k,:);
    end
    
    numCurbFaces = numInterpolatedPoints - 1; 
    curbFaces = zeros(numCurbFaces, 4);
    for k = 1:numCurbFaces
        idx_Li   = 2*k - 1; idx_Ri   = 2*k;
        idx_Ri1  = 2*(k+1); idx_Li1  = 2*(k+1) - 1;
        curbFaces(k, :) = [idx_Li, idx_Ri, idx_Ri1, idx_Li1];
    end
    
    curbFaceColors = zeros(numCurbFaces, 3);
    redColor = [1 0 0]; whiteColor = [1 1 1];
    for k = 1:numCurbFaces
        if mod(k, 2) == 1, curbFaceColors(k, :) = redColor;
        else, curbFaceColors(k, :) = whiteColor; end
    end
    
else 
    % --- Use Original Vertices and Faces for Curbs ---
    leftCurbVertices = zeros(numWaypoints * 2, 3);
    rightCurbVertices = zeros(numWaypoints * 2, 3);
    for i = 1:numWaypoints
        road_L = roadVertices(2*i - 1, :); road_R = roadVertices(2*i, :);     
        N = normals(i, :);               
        
        curb_L_inner = road_L - z_offset_vector; 
        curb_L_outer = (road_L - CURB_WIDTH * N) - z_offset_vector; 
        leftCurbVertices(2*i - 1, :) = curb_L_outer;
        leftCurbVertices(2*i, :)     = curb_L_inner;

        curb_R_inner = road_R - z_offset_vector; 
        curb_R_outer = (road_R + CURB_WIDTH * N) - z_offset_vector; 
        rightCurbVertices(2*i - 1, :) = curb_R_inner; 
        rightCurbVertices(2*i, :)     = curb_R_outer;
    end
    
    curbFaces = roadFaces; % Use the same faces as road/marking

    % Define curb colors alternating per original segment
    curbFaceColors = zeros(numOriginalFaces, 3);
    redColor = [1 0 0]; whiteColor = [1 1 1];
    for i = 1:numOriginalFaces
        if mod(i, 2) == 1, curbFaceColors(i, :) = redColor;
        else, curbFaceColors(i, :) = whiteColor; end
    end
end

% --- Define Road Structure ---
road.vertices = roadVertices; 
road.faces = roadFaces; % Faces for road surface           
road.faceColor = [0.5 0.5 0.5]; 
road.edgeColor = 'none';       
road.markingVertices = markingVertices; 
road.markingFaceColor = [1 1 1];      
road.markingEdgeColor = 'none';       
road.leftCurbVertices = leftCurbVertices;
road.rightCurbVertices = rightCurbVertices;
road.curbFaces = curbFaces; % Faces specifically for curbs (might differ if interpolated)
road.curbFaceVertexCData = curbFaceColors; % Use FaceVertexCData for alternating colors
% Add material properties to structure
road.roadMaterial = {'AmbientStrength', ROAD_AMBIENT, 'DiffuseStrength', ROAD_DIFFUSE, 'SpecularStrength', ROAD_SPECULAR, 'SpecularExponent', ROAD_SPEC_EXP};
road.markingMaterial = {'AmbientStrength', MARKING_AMBIENT, 'DiffuseStrength', MARKING_DIFFUSE, 'SpecularStrength', MARKING_SPECULAR, 'SpecularExponent', MARKING_SPEC_EXP};
road.terrainMaterial = {'AmbientStrength', TERRAIN_AMBIENT, 'DiffuseStrength', TERRAIN_DIFFUSE, 'SpecularStrength', TERRAIN_SPECULAR, 'SpecularExponent', TERRAIN_SPEC_EXP};
% Add terrain data if provided
if plotTerrain
    road.terrainX = nvResults.TerrainX;
    road.terrainY = nvResults.TerrainY;
    road.terrainZ = nvResults.TerrainZ; % Store original Z
else
    road.terrainX = [];
    road.terrainY = [];
    road.terrainZ = [];
end


% --- Create Figure and Patches ---
%figHandle = figure;
%axHandle = axes('Parent', figHandle);
hold(axHandle, 'on');
figHandle = get(axHandle,'Parent');
%clf(figHandle);
% --- Plot Terrain (if provided) ---
if plotTerrain
    disp('Plotting terrain...');
    [X, Y] = meshgrid(road.terrainX, road.terrainY); % Use stored X, Y
    terrainZ_offset = road.terrainZ - TERRAIN_Z_OFFSET; % Use stored Z, apply offset
    hTerrain = surf(axHandle, X, Y, terrainZ_offset, ... 
                    'FaceColor', TERRAIN_COLOR, ...
                    'EdgeColor', 'none', ...
                    'DisplayName', 'Terrain', ...
                    road.terrainMaterial{:}); 
    road.terrainHandle = hTerrain; 
    disp('Terrain plotted.');
else
    road.terrainHandle = []; 
end


% Create the road surface patch object and set material
hPatch = patch(axHandle, 'Vertices', road.vertices, 'Faces', road.faces, ...
               'FaceColor', road.faceColor, ... 
               'EdgeColor', road.edgeColor, ...
               'DisplayName', 'Road Surface', ...
               road.roadMaterial{:});        

% Create the centerline marking patch object and set material
hMarkingPatch = patch(axHandle, 'Vertices', road.markingVertices, 'Faces', road.faces, ...
                      'FaceColor', road.markingFaceColor, ...
                      'EdgeColor', road.markingEdgeColor, ...
                      'DisplayName', 'Centerline', ...
                      road.markingMaterial{:}); 
road.markingPatchHandle = hMarkingPatch; 

% Create the left curb patch object and set material
hLeftCurbPatch = patch(axHandle, 'Vertices', road.leftCurbVertices, 'Faces', road.curbFaces, ... 
                       'FaceVertexCData', road.curbFaceVertexCData, ...
                       'FaceColor', 'flat', ... 
                       'EdgeColor', 'none', ...
                       'DisplayName', 'Left Curb', ...
                       road.markingMaterial{:}); 
road.leftCurbPatchHandle = hLeftCurbPatch;

% Create the right curb patch object and set material
hRightCurbPatch = patch(axHandle, 'Vertices', road.rightCurbVertices, 'Faces', road.curbFaces, ... 
                        'FaceVertexCData', road.curbFaceVertexCData, ...
                        'FaceColor', 'flat', ... 
                        'EdgeColor', 'none', ...
                        'DisplayName', 'Right Curb', ...
                        road.markingMaterial{:}); 
road.rightCurbPatchHandle = hRightCurbPatch;


% --- Configure Plot ---
title(axHandle, 'Simulation Results');
xlabel(axHandle, 'X (m)');
ylabel(axHandle, 'Y (m)');
zlabel(axHandle, 'Z (m)');
axis(axHandle, 'equal'); 
grid(axHandle, 'on');

% --- Set Camera View ---
if camera == 1
    camproj(axHandle, 'perspective'); 
    if numWaypoints >= 2
        startPoint = waypoints(1,:);
        lookAtPoint = waypoints(2,:); 
        direction = lookAtPoint - startPoint;
        if norm(direction) > eps, direction = direction / norm(direction); 
        else, direction = [1 0 0]; end
        
        if strcmp(mode, 'CenterlineWidth'), camWidthFactor = roadWidth*1.5;
        else, camWidthFactor = norm(leftWaypoints(1,:) - rightWaypoints(1,:)); end
        camOffsetDist = camWidthFactor * 2 + 5; 
        camHeight = camWidthFactor * 0.5 + 2;   
        
        camPos = startPoint - camOffsetDist * direction + [0 15 camHeight];
        set(axHandle, 'CameraTarget', lookAtPoint); 
        set(axHandle, 'CameraPosition', camPos);        
        set(axHandle, 'CameraUpVector', [0 0 1]);        
        set(axHandle, 'CameraViewAngle', 60);                
    else
         view(axHandle, 3); 
    end
else 
    view(axHandle, 3); 
end

rotate3d(axHandle, 'on'); 
% legend(axHandle, 'show'); 

% --- Add Light Source ---
% lightPos = camPos + cross(direction, [0 0 1])*camOffsetDist*0.5 + [0 0 camHeight*1.5];
lightPos = [-100 -10 33];
light(axHandle,'Position', lightPos, 'Style', 'infinite'); 
lighting(axHandle, 'phong');  

hold(axHandle, 'off');

% --- Add Scene Settings to Road Structure ---
% *** FIX: Get FaceLighting property from a patch object ***
if ishandle(hPatch)
    road.lightingStyle = get(hPatch, 'FaceLighting'); 
else % Fallback if main patch failed
    road.lightingStyle = 'none';
end
road.lightPosition = lightPos; % Store calculated light position
road.cameraPosition = get(axHandle, 'CameraPosition');
road.cameraTarget = get(axHandle, 'CameraTarget');
road.cameraUpVector = get(axHandle, 'CameraUpVector');
road.cameraViewAngle = get(axHandle, 'CameraViewAngle');
road.axisProperties.DataAspectRatio = get(axHandle, 'DataAspectRatio'); % For axis equal
road.axisProperties.GridLineStyle = get(axHandle, 'GridLineStyle');
road.axisProperties.XGrid = get(axHandle, 'XGrid');
road.axisProperties.YGrid = get(axHandle, 'YGrid');
road.axisProperties.ZGrid = get(axHandle, 'ZGrid');

%fprintf('Road surface, markings, curbs, and terrain (if provided) created successfully.\n');

end

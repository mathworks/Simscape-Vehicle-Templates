function sm_car_scene_stl_create(scene_data)
%sm_car_scene_stl_create  Create STL files for sm_car scenes
%   sm_car_scene_stl_create(scene_data)
%   For scenes that use CRG files
%
%   scene_data      Scene.<scene name>
%
%   Example: sm_car_scene_stl_create(Scene.CRG_Mallory_Park_F)
%
% Copyright 2020-2024 The MathWorks, Inc.

curr_dir = pwd;

% Check if STL file exists
road_STL_file = scene_data.Geometry.filename;
existSTL = exist(road_STL_file,'file');
if(existSTL == 0)

    % Check if CRG file exists
    road_CRG_file = scene_data.CRGfile ;
    existCRG = exist(road_CRG_file,'file');
    if(existCRG == 2)

        % Get root name of CRG file
        [p,f,~] = fileparts(which(road_CRG_file));
        % Move to folder where CRG file is stored
        cd(p);

        % Create STL file with the same name
        disp(['Creating ' f '.stl']);
        sm_car_crg_to_stl(...
            [f '.crg'],...
            [f '.stl'],0,'n');
    end
end

% Check if CRG file exists for centerline
if(isfield(scene_data.Geometry,'centerline'))
    ctr_STL_file = scene_data.Geometry.centerline.filename;
    existSTL = exist(ctr_STL_file,'file');
    if(existSTL == 0)

        % Check if CRG file exists for centerline
        % Filename: <road crg file>_centerline.crg
        [~,f_ctr,~] = fileparts(scene_data.Geometry.centerline.filename);
        ctrline_CRG_file = [f_ctr '.crg'];
        existCRG = exist(ctrline_CRG_file,'file');
        if(existCRG == 2)

            % Get root name of CRG file
            [p,f_ctr,~] = fileparts(which(ctrline_CRG_file));
            % Move to folder where CRG file is stored
            cd(p);

            % Create STL file with the same name
            disp(['Creating ' f_ctr '.stl']);
            sm_car_crg_to_stl(...
                [f_ctr '.crg'],...
                [f_ctr '.stl'],0,'n');
        end
    end
end

cd(curr_dir)
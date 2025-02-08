function sm_car_scene_stl_create(scene_data)
%sm_car_scene_stl_create  Create STL files for sm_car scenes
%   sm_car_scene_stl_create(scene_data)
%   For scenes that use CRG files, this file will create an STL of the
%   road.  It can also generate the set of points that define a grid
%   surface that aligns with the STL points that define a surface. The
%   points are saved to a .mat file so that they do not need to be created
%   each time the scene is assembled.
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
        [xg, yg, zg] = sm_car_crg_to_stl(...
            [f '.crg'],...
            [f '.stl'],0,'n');

        % Only create points for a grid surface 
        % if the scene name start with "GS_".
        if(startsWith(scene_data.Name,'GS_'))
            if(~exist(scene_data.GSData.filename,'file'))
                xg_vec = reshape(xg,[],1);
                yg_vec = reshape(yg,[],1);
                zg_vec = reshape(zg,[],1);

                % Define name for mat file where points will be saved
                gsd_mat_file = [scene_data.Name '_GSD.mat'];
                disp(['Creating ' gsd_mat_file ]);

                % Resample the set of provided points to be a grid defined
                % by an x-vector, y-vector, and z matrix of heights.
                gsd = sm_car_points_to_gridsurface([xg_vec,yg_vec,zg_vec],size(xg,1),size(xg,2),'plot');

                % Save data to a file for reuse
                save(gsd_mat_file,'gsd');

                % Add grid surface points to Scene database in MATLAB workspace
                fnamesGSD = fieldnames(gsd);
                evalin('base',['load(''' scene_data.Name '_GSD.mat'')'])
                for fn_i = 1:length(fnamesGSD)
                    evalin('base',['Scene.' scene_data.Name '.gsd.' fnamesGSD{fn_i} ' = gsd.' fnamesGSD{fn_i} ';' ]);
                end
                evalin('base','clear gsd;')
            end
        end
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
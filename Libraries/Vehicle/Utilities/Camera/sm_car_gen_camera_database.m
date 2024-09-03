function camera_data = sm_car_gen_camera_database(varargin)
% Define Database of Viewpoint Positions for Mechanics Explorer
%
% Copyright 2019-2024 The MathWorks, Inc.

homedir = fileparts(which('sm_car.slx'));

cd(fileparts(which(mfilename)));
define_camera_file_list = dir('**/sm_car_define_camera_*.m');

[~, alpha_ind] = sort({define_camera_file_list.name});

if(nargin==0)
    camera_data = '';
    for camera_i = 1:length(define_camera_file_list)
        [~,fname] = fileparts(define_camera_file_list(alpha_ind(camera_i)).name);
        disp(['Adding ' fname]);
        eval(['new_camera_data = ' fname  ';']);
        if(~isempty(camera_data))
            camera_names = fieldnames(camera_data);
        else
            camera_names = '';
        end
        new_camera_name = matlab.lang.makeValidName(new_camera_data.Instance);
        if(~isempty(camera_data))
            unique_names = matlab.lang.makeUniqueStrings({camera_names{:} new_camera_name});
        else
            unique_names = {new_camera_name};
        end
        camera_data.(unique_names{end}) = new_camera_data;
    end
    
    
else
    disp('List of files defining camera locations and orientations:');
    for i=1:length(define_camera_file_list)
        fprintf('  edit <a href = "%s">%s</a>\n',['matlab:edit(''' define_camera_file_list(i).name ''');'] ,define_camera_file_list(i).name)
    end
end

cd(homedir)

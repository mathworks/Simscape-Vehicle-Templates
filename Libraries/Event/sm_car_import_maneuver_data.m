function manv_data = sm_car_import_maneuver_data
%sm_car_import_maneuver_data Generate database of maneuvers
%   manv_data = sm_car_import_maneuver_data
%   This function generates a structure that contains the parameters
%   defining the maneuvers for the Simscape Vehicle Templates.  This
%   applies to open and closed loop maneuvers.
%
%   This function searches the project for files whose name start with
%   "sm_car_maneuverdata".  It runs those functions and saves the results
%   in a single structure.
%     
% Copyright 2019-2024 The MathWorks, Inc.
  
% Move to root directory
curr_dir = pwd;
cd(fileparts(which('sm_car.slx')));

% Find files containing parameters defining maneuvers
manv_data_file_list = dir('**/sm_car_maneuverdata_*.m');
[~, alpha_ind] = sort({manv_data_file_list.name});

% Loop over list of files
manv_data = '';
for manv_i = 1:length(manv_data_file_list)

    % Extract name and display it in the workspace
    [~,fname] = fileparts(manv_data_file_list(alpha_ind(manv_i)).name);
    disp(['Adding ' fname]);

    % Store the parameters from that function in a local variable
    eval(['new_manv_data = ' fname  ';']);

    % Loop over list of fields and add them to the structure
    fnames = fieldnames(new_manv_data);
    for fn_i = 1:length(fnames)
        manv_data.(fnames{fn_i}) = new_manv_data.(fnames{fn_i});
    end
end

% Return to original directory
cd(curr_dir)
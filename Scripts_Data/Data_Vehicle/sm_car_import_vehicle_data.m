function sm_car_vehicle_data = sm_car_import_vehicle_data(updateData,showMessage)
%
% Copyright 2019-2022 The MathWorks, Inc.

% Get VDatabase from workspace OR create new
if(updateData)
    VDatabase = evalin('base','VDatabase');
    if(isempty(VDatabase))
        if(exist('VDatabase_file.mat','file'))
            load('VDatabase_file.mat'); %#ok<LOAD>
        else
            updateData = 0;
        end
    end
    sm_car_vehicle_data = VDatabase;
else
    sm_car_vehicle_data = [];
    VDatabase = [];
end

% Find Excel files with vehicle data (based on filename)
curr_dir = pwd;
cd(fileparts(which('sm_car_lib')));
car_data_excel_list = dir('**/sm_car_data_*.xlsx');

[~, alpha_ind] = sort({car_data_excel_list.name});

% Loop over Excel files
for excel_i = 1:length(car_data_excel_list)
    
    readFileName = car_data_excel_list(alpha_ind(excel_i)).name;
    
    if(updateData)
        %% Compare modified date of vehicle file to file used in VDatabase
        % Get modified date of vehicle file
        [~, wk_filename, wk_fileext] = fileparts(readFileName);
        filedata = dir(which(readFileName));
        wk_filedate = filedata.datenum;
        
        % Get modified date from VDatabase
        vehData_ind = find(strcmp({sm_car_vehicle_data.files.filename},[wk_filename wk_fileext]), 1);
        
        % Determine if file should be read in (if modified dates are not the same)
        readExcel = 0;
        if(isempty(vehData_ind))
            readExcel = 1;
        else
            VD_filedate = sm_car_vehicle_data.files(vehData_ind).date;
            if(wk_filedate~=VD_filedate)
                readExcel = 1;
            end
        end
    else
        readExcel = 1;
    end
    if(readExcel)
        % Get data from file
        tempDatabase = sm_car_import_database(car_data_excel_list(alpha_ind(excel_i)).name,{'Structure','NameConvention'},showMessage);
        
        % Get list of types from file
        typename = fieldnames(tempDatabase);
        
        % Loop over list of types
        for type_i = 1:length(typename)
            
            % If VDatabase is empty, set flag
            if(isempty(sm_car_vehicle_data))
                VDatabase_names = 'none';
            else
                VDatabase_names = fieldnames(sm_car_vehicle_data);
                % If VDatabase has no fields, set flag
                if(isempty(VDatabase_names))
                    VDatabase_names = 'none';
                end
            end
            
            % If type exists in VDatabase, add instances to VDatabase
            if(find(strcmp(VDatabase_names,typename{type_i})))
                
                % Loop over instances
                instance_names = fieldnames(tempDatabase.(typename{type_i}));
                for inst_i = 1:length(instance_names)
                    sm_car_vehicle_data.(typename{type_i}).(instance_names{inst_i}) = tempDatabase.(typename{type_i}).(instance_names{inst_i});
                end
                
                
            else
                % Else, add entire type to VDatabase
                sm_car_vehicle_data.(typename{type_i}) = tempDatabase.(typename{type_i});
            end
        end
        filedata = dir(which(car_data_excel_list(alpha_ind(excel_i)).name));
        sm_car_vehicle_data.files(excel_i+1).filename = filedata.name;
        sm_car_vehicle_data.files(excel_i+1).date = filedata.datenum;
    end
end

sm_car_vehicle_data_orig = sm_car_vehicle_data;
sm_car_vehicle_data = [];

typenames_list = fieldnames(sm_car_vehicle_data_orig);
sorted_typenames_list = sort(typenames_list);
for tn_i = 1:length(sorted_typenames_list)
    sm_car_vehicle_data.(sorted_typenames_list{tn_i}) = sm_car_vehicle_data_orig.(sorted_typenames_list{tn_i});
end

cd(fileparts(which('sm_car_lib.slx')))
cd('Vehicle')

VDatabase = sm_car_vehicle_data;
save VDatabase_file VDatabase

cd(curr_dir)
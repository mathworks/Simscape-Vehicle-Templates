function sm_car_database = sm_car_import_database(workbook_filename,excludeSheets,showMessage)

% Read in all initialization data from Excel file
% Creates one field per sheet

DDatabase_Import = sm_car_database_import_excel(workbook_filename,excludeSheets,showMessage);
fieldlist = fieldnames(DDatabase_Import);
for sheet_i = 1:length(fieldlist)
    % [newdata, ~] = sm_car_import_vehicle_data_sheet(workbook_filename, vehDataSheets{sheet_i});
    % Get Type for sorting, instance name for field name
    type_name     = DDatabase_Import.(fieldlist{sheet_i}).Type.Value;
    instance_name = DDatabase_Import.(fieldlist{sheet_i}).Instance.Value;
    
    % Remove Type and Instance fields (not needed by model)
    tempfield = rmfield(DDatabase_Import.(fieldlist{sheet_i}),'Type');
    tempfield = rmfield(tempfield,'Instance');
    
    sm_car_database.(type_name).(instance_name) = tempfield;
    sm_car_database.(type_name).(instance_name).Type = type_name;
    sm_car_database.(type_name).(instance_name).Instance = instance_name;

    % If a field name ends in _LoadFile, there is a .mat file with data
    % in fields that needs to be loaded into the database.
    % Load the data into a field with the same name excluding '_LoadFile'
    % Used for Maneuver Database, as trajectory is too big for Excel
    instance_field_list = fieldnames(sm_car_database.(type_name).(instance_name));
    indexes_LoadFile = find(endsWith(instance_field_list,'_LoadFile'));
    if ~isempty(indexes_LoadFile)
        for lf_i = 1:length(indexes_LoadFile)
            loadFileName= sm_car_database.(type_name).(instance_name).(instance_field_list{indexes_LoadFile(lf_i)}).Value;
            loadFileFieldName = strrep(instance_field_list{indexes_LoadFile(lf_i)},'_LoadFile','');
            sm_car_database.(type_name).(instance_name).(loadFileFieldName) = load(loadFileName);
        end
    end
end

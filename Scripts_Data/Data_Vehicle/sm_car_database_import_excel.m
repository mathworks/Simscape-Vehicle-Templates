function raw_import_structure = sm_car_database_import_excel(workbook_filename,excludeSheets,showMessage)

% Read in all vehicle data from Excel file
% Creates one field per sheet

[~,vehDataSheets_ALL] = xlsfinfo(workbook_filename);

% Exclude worksheets that have no vehicle data
%excludeSheets = {'Structure','To Do','Init', 'Init_Mallory', 'NameConvention', 'NameDiscussion', 'Names'};
vehDataSheets = setdiff(vehDataSheets_ALL,excludeSheets);

% Read all worksheets into a single MATLAB structure (field = sheet name)
raw_import_structure = [];
if(showMessage)
    [filepath,name,ext] = fileparts(which(workbook_filename));
    disp(['Importing data from ' name ' (' filepath ext ')' ]);
end
for sheet_i = 1:length(vehDataSheets)
    if(showMessage)
        disp(['... importing sheet ' vehDataSheets{sheet_i}]);
    end
    [newdata, ~] = sm_car_import_vehicle_data_sheet(workbook_filename, vehDataSheets{sheet_i}); %#ok<ASGLU>
    eval(['raw_import_structure.' vehDataSheets{sheet_i} '= newdata;']);
end
if(showMessage)
    disp(['Finished importing ' name ext]);
    disp(' ');
end
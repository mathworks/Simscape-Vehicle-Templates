function sm_car_gen_upd_database(db_type,db_update)
% sm_car_gen_upd_database  Generate or update sm_car databases
%   sm_car_gen_upd_database(db_type,db_update)
%   This function creates or updates various MATLAB structures that serve
%   as a database for sm_car. It loads the data from a .mat file or
%   imports from an Excel file.  
%
%   If the user requests no update or if the Excel file has changed since
%   the MATLAB structure was last created, the Excel file will be used to
%   generate the MATLAB structure. Otherwise, the structure will be created
%   based on the data in the .mat file.
%
%   db_type   'Init','Maneuver','Driver', or 'Camera
%   db_update 0 - Generate variable.  Read from Excel, 
%             1 - Update variable. Only read from Excel if file has changed
% 
% Copyright 2019-2020 The MathWorks, Inc.

%% Select database file, MAT file, and workspace variable name
switch db_type
    case 'Init'
        db_file = 'sm_car_database_Init.xlsx';
        mat_file = 'IDatabase_file.mat';
        var_name = 'IDatabase';
    case 'Maneuver'
        db_file = 'sm_car_database_Maneuver.xlsx';
        mat_file = 'MDatabase_file.mat';
        var_name = 'MDatabase';
    case 'Driver'
        db_file = 'sm_car_database_Driver.xlsx';
        mat_file = 'DDatabase_file.mat';
        var_name = 'DDatabase';
%    case 'Camera'
%        db_file = 'sm_car_database_Camera.xlsx';
%        mat_file = 'CDatabase_file.mat';
%        var_name = 'CDatabase';
end

% Get info about Excel file
cd(fileparts(which(db_file)))
db_file_data = dir(['**/' db_file]);

% Default is import database from Excel
readExcel = 1;

% No import from Excel if update is requested and file has not changed
if(db_update)
    % If update-only requested
    if(exist(mat_file,'file'))
        % If .mat file exists, get date of file used to generate it
        load(mat_file) %#ok<LOAD>
        mat_file_date = eval([var_name '.files.date']);
        
        if(db_file_data.datenum == mat_file_date)
            % If Excel file unchanged, do not import Excel
            readExcel = 0;
        end
    end
end

if(readExcel)
    % Import Excel data into local variable
    db_structure = sm_car_import_database(db_file,'',1);

    % Save file name and modified data in database structure
    db_structure.files.filename = db_file;
    db_structure.files.date = db_file_data.datenum;

    % Save .mat file in same folder where Excel file lives
    % Ensure .mat file has correct variable name
    cd(fileparts(which(db_file)));        % Move to folder
    %disp([var_name ' = db_structure;']); % Debug
    eval([var_name ' = db_structure;']);  % Copy data to desired variable
    %disp(['save(''' mat_file ''', ''' var_name ''');']); % Debug
    eval(['save(''' mat_file ''', ''' var_name ''');']);  % Save to file
else
    % Load data from .mat file to database structure
    disp( ['Loading ' var_name ' from ' mat_file '(' which(mat_file) ')']);
    eval(['db_structure = ' var_name  ';']);
end

% Assign in workspace
assignin('base',var_name,db_structure);

% Return to base folder
curr_proj = simulinkproject;
cd(curr_proj.RootFolder)


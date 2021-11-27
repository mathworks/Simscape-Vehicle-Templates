function [MFSwifttbx_pth,MFSwifttbx_folders]=sm_car_startupMFSwift
% DETERMINE IF MF-SWIFT DIRECTORY IS ON PATH
% CHECK IF TOOLBOX ALREADY ON PATH

% Copyright 2014-2021 The MathWorks, Inc.

curr_proj = simulinkproject;
path_preMFSwift = strsplit(path,';');
assignin('base','path_preMFSwift',path_preMFSwift);
MFSwifttbxOnPath = ~isempty(which('mfswift_startup'));
selected_dir = 0;

libraryName = 'MF-Swift MATLAB Toolbox';

% IF NOT ALREADY ON PATH
if(~MFSwifttbxOnPath)
    
    % DEFAULT INSTALLATION FOLDER
    MFSwifttbx_pth = ['C:' filesep 'simcenter_tire'];
    
    if (exist(MFSwifttbx_pth,'dir')==7)      % LOOK BELOW DEFAULT FOLDER
        selected_dir = MFSwifttbx_pth;
    elseif (~(exist(MFSwifttbx_pth)==7)) % IF NOT IN DEFAULT FOLDER
        MFSwifttbx_pth='';
        % ASK USER TO SELECT FOLDER
        %selected_dir=uigetdir('C:\','Select TNO Delft-Tyre installation folder');
        selected_dir = filesep;  % Specify custom path here
    end
    
    if(ispc)
        mfstartup_files = dir([selected_dir filesep '**' filesep 'mfswift_startup.m']);
    else
        mfstartup_files = [];
    end
    
    if(selected_dir(end)==filesep || isnumeric(selected_dir) || isempty(mfstartup_files) )
        %uiwait(warndlg(sprintf('%s\n%s\n%s\n%s','TNO Delft-Tyre MATLAB Toolbox not found.','You need to select the subfolder where the software is installed.','Run startup script again to select another directory,','or add toolbox manually to the MATLAB path.'),'MATLAB Toolbox Not Found'));
        disp('MF-Swift software not found, placeholder library used instead.')
        placeholder_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_None'];
        addpath(placeholder_path);
        MFSwifttbx_pth = placeholder_path;
    else
        disp(['Searching for ' libraryName '...']);
        path_preMFSwift = strsplit(path,';');
        mfstartup_file_full = [mfstartup_files(1).folder filesep mfstartup_files(1).name];
        disp(['Running ' mfstartup_file_full]);
        evalin('base',['run(''' mfstartup_file_full ''');']);
        addpath(mfstartup_files(1).folder);
        addpath([mfstartup_files(1).folder filesep '..' filesep 'manuals']);
        mfswift_ver = str2num(sm_car_check_mfswiftversion);
        if(mfswift_ver<2021.1)
            library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2020p1'];
        else
            library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2021p1'];
        end
        addpath(library_path);
        
        % Add opencrg tools to path
        curr_path = pwd;
        cd(mfstartup_files(1).folder)
        cd(['..' filesep 'opencrg'])
        crgpath = genpath(pwd);
        addpath(crgpath);
        cd(curr_path);
        
        MFSwifttbx_pth = mfstartup_files(1).folder;
    end
else
    MFSwifttbx_pth = fileparts(which('mfswift_startup'));
    mfswift_ver = str2num(sm_car_check_mfswiftversion);
    if(mfswift_ver<2021.1)
        library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift'];
    else
        library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2021p1'];
    end
    addpath(library_path);
end

path_postMFSwift = strsplit(path,';');

assignin('base','path_postMFSwift',path_postMFSwift);

MFSwifttbx_folders = setdiff(path_postMFSwift, path_preMFSwift);

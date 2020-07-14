function [MFSwifttbx_pth,MFSwifttbx_folders]=sm_car_startupMFSwift
% DETERMINE IF MF-SWIFT DIRECTORY IS ON PATH
% CHECK IF TOOLBOX ALREADY ON PATH

% Copyright 2014-2020 The MathWorks, Inc.

curr_proj = simulinkproject;
path_preMFSwift = strsplit(path,';');
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
        selected_dir = filesep;
    end
    if(selected_dir(end)==filesep || isnumeric(selected_dir))
        %uiwait(warndlg(sprintf('%s\n%s\n%s\n%s','TNO Delft-Tyre MATLAB Toolbox not found.','You need to select the subfolder where the software is installed.','Run startup script again to select another directory,','or add toolbox manually to the MATLAB path.'),'MATLAB Toolbox Not Found'));
        disp('MF-Swift software not found, placeholder library used instead.')
        placeholder_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_None'];
        addpath(placeholder_path);
        MFSwifttbx_pth = placeholder_path;
        path_postMFSwift = strsplit(path,';');
    else
        disp(['Searching for ' libraryName '...']);
        mfstartup_file=dir([selected_dir filesep '**/mfswift_startup.m']);
        path_preMFSwift = strsplit(path,';');
        evalin('base',['run(''' mfstartup_file.folder filesep mfstartup_file.name ''');']);
        addpath(mfstartup_file.folder);
        addpath([mfstartup_file.folder filesep '..' filesep 'manuals']);
        library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift'];
        addpath(library_path);
        
        % Add opencrg tools to path
        curr_path = pwd;
        cd(mfstartup_file.folder)
        cd(['..' filesep 'opencrg'])
        crgpath = genpath(pwd);
        addpath(crgpath);
        cd(curr_path);

        path_postMFSwift = strsplit(path,';');
        MFSwifttbx_pth = mfstartup_file.folder;
    end
else
    MFSwifttbx_pth = fileparts(which('mfswift_startup'));
    path_postMFSwift = strsplit(path,';');
end

MFSwifttbx_folders = setdiff(path_postMFSwift, path_preMFSwift);

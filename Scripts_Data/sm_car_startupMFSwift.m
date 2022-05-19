function [MFSwifttbx_pth,MFSwifttbx_folders]=sm_car_startupMFSwift
% DETERMINE IF MF-SWIFT DIRECTORY IS ON PATH
% CHECK IF TOOLBOX ALREADY ON PATH

% Copyright 2014-2022 The MathWorks, Inc.

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
    
    if(ispc && ~(strcmp(selected_dir,filesep)))
        mfstartup_files = dir([selected_dir filesep '**' filesep 'mfswift_startup.m']);
    else
        mfstartup_files = [];
    end
    
    if(selected_dir(end)==filesep || isnumeric(selected_dir) || isempty(mfstartup_files) )
        disp('MF-Swift software not found, placeholder library used instead.')
        placeholder_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_None'];
        addpath(placeholder_path);
        MFSwifttbx_pth = placeholder_path;
    else
        disp(['Searching for ' libraryName '...']);
        for mfi = 1:length(mfstartup_files)
            yrInd = regexp(mfstartup_files(mfi).folder,'\d\d\d\d.\d');
            yrStr(mfi) = str2num(mfstartup_files(mfi).folder((yrInd:yrInd+5)));
        end
        [~,mfInd] = max(yrStr);

        path_preMFSwift = strsplit(path,';');
        mfstartup_file_full = [mfstartup_files(mfInd).folder filesep mfstartup_files(mfInd).name];
        disp(['Running ' mfstartup_file_full]);
        evalin('base',['run(''' mfstartup_file_full ''');']);
        addpath(mfstartup_files(mfInd).folder);
        addpath([mfstartup_files(mfInd).folder filesep '..' filesep 'manuals']);
        mfswift_ver = str2num(sm_car_check_mfswiftversion);
        library_path = [];
        if(mfswift_ver==2020.2)
            library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2020p2'];
        elseif(mfswift_ver==2021.1)
            library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2021p1'];
        elseif(mfswift_ver==2022.1)
            library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2022p1'];
        end
        addpath(library_path);
        % Add opencrg tools to path
        %curr_path = pwd;
        %cd(mfstartup_files(mfInd).folder)
        %cd(['..' filesep 'opencrg'])
        %crgpath = genpath(pwd);
        %addpath(crgpath);
        %cd(curr_path);
        
        MFSwifttbx_pth = mfstartup_files(mfInd).folder;
    end
else
    MFSwifttbx_pth = fileparts(which('mfswift_startup'));
    mfswift_ver = str2num(sm_car_check_mfswiftversion);
    library_path = [];
    if(mfswift_ver==2020.2)
        library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2020p2'];
    elseif(mfswift_ver==2021.1)
        library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2021p1'];
    elseif(mfswift_ver==2022.1)
        library_path = [curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFSwift' filesep 'MFSwift_2022p1'];
    end
    if(isempty(library_path))
        warning('off','backtrace')
        warning('MF-Swift software found, but the version has not been integrated with this example.')
        warning('on','backtrace')
    else
        addpath(library_path);
    end
end

path_postMFSwift = strsplit(path,';');

assignin('base','path_postMFSwift',path_postMFSwift);

MFSwifttbx_folders = setdiff(path_postMFSwift, path_preMFSwift);

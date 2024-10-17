%% Start
cd(fileparts(which(mfilename)))
addpath(pwd)
repFilesPath = pwd;
repFilesList = {...
    'startup_sm_car_FSAE.m',...
    'README_FSAE.md',...
    'sm_car_lib_find_leftright_blocks_FSAE.m',...
    'sm_car_config_road_FSAE.m',...
    'sm_car_config_maneuver_FSAE.m',...
    'sm_car_config_solver_FSAE.m',...
    'sm_car_body_default_FSAE.png',...
    'sm_car_chassis_default_FSAE.png',...
    'sm_car_controlparam_Ideal_L1_R1_L2_R2_achilles_FSAE.m',...
    'sm_car_controlparam_Ideal_L1_R1_L2_R2_default_FSAE.m',...
    'sm_car_vehicle_axle2_default_FSAE.png',...
    'sm_car_vehicle_axle2_default_none_FSAE.png'};

annotationMdl = 'annotation_sm_car';

addFieldsList = {'addfieldVehicleDec.m','addfieldVehicleDW.m'};

%% Open and configure model
mdl_0 = 'sm_car';
mdl_1 = 'sm_car_TEST';
mdl_2 = 'sm_car_TEST_noLinks';
mdl_3 = 'sm_car_REDUCED';

%% Ensure any models from last export are closed
bdclose(mdl_1)
bdclose(mdl_2)
bdclose(mdl_3)

%% Get Root Folder
curr_proj = simulinkproject;
ssvt_rootfolder = curr_proj.RootFolder;
cd(ssvt_rootfolder);

%% Get file and folder names
mfevalDetails = dir('**\*+mfeval');
mfeval_dir = [strrep(mfevalDetails.folder,ssvt_rootfolder,'') filesep];

open_system(mdl_0)

% Save Accel/Decel maneuver to MATLAB script
Maneuver = MDatabase.WOT_Braking.FSAE_Achilles;
Maneuver.Accel.rPedal.Value = Maneuver.Accel.rPedal.Value/8;
matlab.io.saveVariablesToScript('Maneuver_data_wot_braking.m','Maneuver');
Init = IDatabase.Flat.FSAE_Achilles;
matlab.io.saveVariablesToScript('Init_data_wot_braking.m','Init');

% Save Decoupled vehicle to script
sm_car_load_vehicle_data('none','214');
sm_car_config_maneuver('sm_car','Skidpad');
Vehicle.config = 'Achilles_Decoupled';
Vehicle = rmfieldVehicleDec(Vehicle);
matlab.io.saveVariablesToScript('Vehicle_data_decoupled.m','Vehicle')

% Save Skidpad maneuver to script
matlab.io.saveVariablesToScript('Maneuver_data_skidpad.m','Maneuver')
matlab.io.saveVariablesToScript('Init_data_skidpad.m','Init')

% Save Pushrod vehicle to script
sm_car_load_vehicle_data(mdl_0,'215');
sm_car_config_maneuver('sm_car','CRG Hockenheim');
sm_car_config_vehicle('sm_car',true);
Vehicle.config = 'Achilles_DWPushrod';
Vehicle = rmfieldVehicleDW(Vehicle);
matlab.io.saveVariablesToScript('Vehicle_data_dwpushrod.m','Vehicle')

% Save Hockenheim maneuver to script
matlab.io.saveVariablesToScript('Maneuver_data_hockenheim.m','Maneuver')
matlab.io.saveVariablesToScript('Init_data_hockenheim.m','Init')

% Save Double Wishbone vehicle to script
sm_car_load_vehicle_data(mdl_0,'213');
sm_car_config_maneuver('sm_car','CRG Hockenheim F');
sm_car_config_vehicle('sm_car',true);
Vehicle.config = 'Achilles_DWishbone';
Vehicle_DWishbone = Vehicle; % Save complete Vehicle for export process
Vehicle = rmfieldVehicleDW(Vehicle); % Remove duplicate fields
matlab.io.saveVariablesToScript('Vehicle_data_dwishbone.m','Vehicle')
Vehicle = Vehicle_DWishbone; % Reload complete Vehicle for export process

% Save Hockenheim Flat maneuver to script
matlab.io.saveVariablesToScript('Maneuver_data_hockenheim_f.m','Maneuver')
matlab.io.saveVariablesToScript('Init_data_hockenheim_f.m','Init')

% Add call to function to copy hardpoints within Vehicle data structure
append_line_to_script('Vehicle_data_decoupled.m','% Set derived files from within Vehicle data structure')
append_line_to_script('Vehicle_data_dwpushrod.m','% Set derived files from within Vehicle data structure')
append_line_to_script('Vehicle_data_dwishbone.m','% Set derived files from within Vehicle data structure')
append_line_to_script('Vehicle_data_decoupled.m','Vehicle = addfieldVehicleDec(Vehicle);')
append_line_to_script('Vehicle_data_dwpushrod.m','Vehicle = addfieldVehicleDW(Vehicle);')
append_line_to_script('Vehicle_data_dwishbone.m','Vehicle = addfieldVehicleDW(Vehicle);')

% Save under new name
save_system(mdl_0,mdl_1)

%% Find links to break
fh = Simulink.FindOptions('FollowLinks',true,'LookUnderMasks','all');
bl = Simulink.findBlocks(mdl_1,'LinkStatus','resolved',fh);
blist = getfullname(bl);
[blist_sort, sort_i] = sort(blist);

% Levels to leave alone
doNotTouchList = {...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage L'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage R'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Anti Roll Bar'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA1/Linkage Decoupled/Linkage L'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA1/Linkage Decoupled/Linkage R'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA1/Simple'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA1/Live Axle'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA2/Linkage/Linkage L'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA2/Linkage/Linkage R'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA2/Linkage/Anti Roll Bar'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA2/Linkage Decoupled'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA2/Simple'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/SuspA2/Live Axle'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/Tire L1'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/Tire R1'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/Tire L2'],...
    [mdl_1 '/Vehicle/Vehicle/Chassis/Tire R2'],...
    };

%% Break links
for blk_i = 1:length(sort_i)
    index = sort_i(blk_i);
    refblk = get_param(bl(index),'ReferenceBlock');

    % Check if block is at or within system that should not be touched
    breakLink = true;
    for dnt_i = 1:length(doNotTouchList)
        if(contains(getfullname(bl(index)),doNotTouchList{dnt_i}))
            breakLink = false;
        end
    end

    % If not in do-not-touch systems...
    if(breakLink)

        % Check if it is a shipping block
        % See if path to shipping block is below MATLAB root
        filesep_ind = strfind(refblk,'/');
        fileName = [refblk(1:filesep_ind(1)-1) '.slx'];
        srcLib(blk_i) = contains(fileparts(which(fileName)),matlabroot);
        nameStr = regexprep(getfullname(bl(index)),'[\n\r]+','');

        % If not a shipping block
        if(~srcLib(blk_i))
            disp([nameStr ' ' num2str(srcLib(blk_i))])
            % !!! BREAK LINK !!!
            set_param(bl(index),'LinkStatus','none')
        end
    end
end

%% Save model with broken links to new name
save_system(mdl_1,mdl_2)

%% Find variant subsystems with inactive variants we wish to remove
fh_vs = Simulink.FindOptions('FollowLinks',false,'LookUnderMasks','all');
bl_vs = Simulink.findBlocks(mdl_2,'Variant','on','LinkStatus','none',fh);
blist_vs = getfullname(bl_vs);
[blist_vs_sort, sort_i_vs] = sort(blist_vs);


% Inactive variants to save list
doNotTouchList_INACTV = {
    [mdl_2 '/Vehicle/Vehicle/Chassis/SuspA1/Linkage Decoupled'],...
    [mdl_2 '/Vehicle/Vehicle/Chassis/SuspA2/Linkage Decoupled'],...
    [mdl_2 '/Vehicle/Vehicle/Chassis/Damper/Decoupled'],...
    [mdl_2 '/Vehicle/Vehicle/Chassis/Spring/Decoupled'],...
    [mdl_2 '/World/Scene/Skidpad']...
    [mdl_2 '/World/Scene/CRG Hockenheim']...
    [mdl_2 '/World/Scene/Plane Grid']...
    [mdl_2 '/Controller/TrqVec 4Motor']...
    [mdl_2 '/Driver/Open Loop']...
    };


%% Remove inactive variants

% Loop over list of variant subsystems
for blk_i = 1:length(sort_i_vs)
    index = sort_i_vs(blk_i);
    vs_h  = bl_vs(index);

    % If we have not deleted the block already
    if(getSimulinkBlockHandle(blist_vs_sort(blk_i)) > 0)

        refblk = get_param(vs_h,'ReferenceBlock');

        % If not a library block
        if(isempty(refblk))

            % Get name of active variant block
            activeBlk = get_param(vs_h,'CompiledActiveChoiceBlock');

            % Get list of all variants
            fh_as = Simulink.FindOptions('FollowLinks',true,'SearchDepth',1,'LookUnderMasks','none');
            sub_list  = Simulink.findBlocks(vs_h,'BlockType','SubSystem',fh_as);

            % Loop over list of variants
            for sub_i = 1:length(sub_list)

                % If not active variant, delete it
                if(getSimulinkBlockHandle(activeBlk)~=sub_list(sub_i))
                    disp(['Delete ' getfullname(sub_list(sub_i))]);

                    deleteVariant = true;
                    for iav_i = 1:length(doNotTouchList_INACTV)
                        if(contains(getfullname(sub_list(sub_i)),doNotTouchList_INACTV{iav_i}))
                            deleteVariant = false;
                        end
                    end

                    % !!! DELETE INACTIVE VARIANT
                    if(deleteVariant)
                        delete_block(sub_list(sub_i));
                    end
                end
            end
        end
    end
end

%% Fix Model Properties for mdl_3
preLoadFcn_str = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s',...
    '% Due to usability issue in Repeating Sequence block',...
     'warning(''off'',''Simulink:Masking:Invalid'');',...
     ' ',...
     '% Eliminate unnecessary warnings in inactive variants',...
     '% Warnings generated only if you click through inactive variant',...
     'warning(''off'',''MATLAB:nonExistentField'');',...
     'warning(''off'',''Simulink:Parameters:BlkParamUndefined'');');

postLoadFcn_str = sprintf('%s\n%s\n%s\n%s\n%s',...
    'set_param([bdroot ''/Vehicle''],''popup_trailer'',''Off'')',...
    'warning(''off'',''sm:sli:setup:compile:LocalSolverNotSupported'')',...
    '%sm_car_config_maneuver(bdroot,''WOT Braking'');',...
    'sm_car_config_vehicle(bdroot,''false'');',...
    'sm_car_config_logging(bdroot);');

set_param(mdl_2,'PreLoadFcn',preLoadFcn_str,'PostLoadFcn',postLoadFcn_str);

% fix annotation
hAnnOld=find_system(mdl_2,'FindAll','On','Type','annotation');
for i=1:length(hAnnOld)
    if(~contains(get_param(hAnnOld(i),'Text'),'Multibody Suspension'))
        delInd = i;
    end
end
delete(hAnnOld(delInd))

load_system(annotationMdl);
h=find_system(annotationMdl,'FindAll','On','Type','annotation');

ann_h_pos = get_param(h,'Position');
ann_new = Simulink.Annotation(mdl_2,'NewAnnotation');

ann_new.Interpreter = 'rich';
ann_new.Text = get_param(h,'Text');

%% Remove Scenes from World block
maskObj = get_param([mdl_2 '/World'],'MaskObject');
paramNames = {maskObj.Parameters(:).Name}';
popupSceneInd = find(matches(paramNames,'popup_scene'));

sceneList = get_param([mdl_2 '/World/Scene'],'VariantChoices');
dropDownList = strrep({sceneList(:).Name}','_',' ');
maskObj.Parameters(popupSceneInd).TypeOptions = dropDownList;
set_param([mdl_2 '/World'],'MaskObject',maskObj);
set_param([mdl_2 '/World'],'popup_scene','CRG Hockenheim F');

%% Remove Options from Control block
maskObj = get_param([mdl_2 '/Controller'],'MaskObject');
paramNames = {maskObj.Parameters(:).Name}';

popupControlInd = find(matches(paramNames,'popup_control'));
maskObj.Parameters(popupControlInd).TypeOptions = {'Default','Torque Vector 4 Motor'};

popupBrakeInd = find(matches(paramNames,'popup_brake_control'));
maskObj.Parameters(popupBrakeInd).TypeOptions = {'Pedal'};

%% Remove Options from Driver block
maskObj = get_param([mdl_2 '/Driver'],'MaskObject');
paramNames = {maskObj.Parameters(:).Name}';

popupDriverTypeInd = find(matches(paramNames,'popup_driver_type'));
maskObj.Parameters(popupDriverTypeInd).TypeOptions = {'Closed Loop','Open Loop'};
set_param([mdl_2 '/Driver'],'popup_driver_type','Closed Loop');

%% Remove Options from Visualization block
maskObj = get_param([mdl_2 '/Visualization'],'MaskObject');
paramNames = {maskObj.Parameters(:).Name}';

unrealOnOffInd = find(matches(paramNames,'unreal_onoff'));
maskObj.Parameters(unrealOnOffInd).TypeOptions = {'Off'};
set_param([mdl_2 '/Visualization'],'unreal_onoff','Off');

%% Save model with broken links and inactive variants to new name
save_system(mdl_2,mdl_3)

%% Find list of files model needs

% New folder location
Link = ['C:\SSVT_FSAE\SSVT_FSAE_' datestr(now,'yymmdd_HHMM')];

% Get root folder
SSVTRootFolder   = char(matlab.project.currentProject().RootFolder);
%SSVTRootFolderd1 = SSVTRootFolder(1:max(strfind(SSVTRootFolder,'\'))-1);

% Get list of required files
requiredFilesSLX_full = dependencies.fileDependencyAnalysis(mdl_3);

%%
doNotCopyList_SLX = {...
    '\Libraries\Event\Scene\',...
    '\Libraries\Vehicle\Tire\Delft\',...
    '\Libraries\Vehicle\Tire\MFEval\',...
    '\Libraries\Vehicle\Tire\CFL\',...
    '\Libraries\Vehicle\Tire\MFSwift\',...
    '\Libraries\Vehicle\Tire\Testrig_4Post\',...
    '\Libraries\Vehicle\Power\Shaft1\',...
    '\Libraries\Vehicle\Power\Shaft2\',...
    '\Libraries\Vehicle\Power\Shaft3\',...
    '\Libraries\Vehicle\Power\Shaft4\',...
    '\Libraries\Vehicle\Power\FuelCell\',...
    '\Libraries\Vehicle\Linkage\Link5',...
    '\Libraries\Vehicle\Linkage\SpLA',...
    '\Libraries\Vehicle\Suspension\DOF15\',...
    '\Libraries\Vehicle\Suspension\LiveAxle\',...
    '\Libraries\Vehicle\Driveline\Axle1\',...
    '\Libraries\Vehicle\Brakes\Axle1\',...
    '\Libraries\Vehicle\Body\Trailer\',...
    '\Libraries\Vehicle\Body\Semi_Truck\',...
    '\Libraries\Vehicle\Body\Load_Slosh\',...
    '\Libraries\Vehicle\Body\CAD\Truck_Amandla\',...
    '\Libraries\Vehicle\Body\CAD\Trailer_Thwala\',...
    '\Libraries\Vehicle\Body\CAD\Trailer_Kumanzi\',...
    '\Libraries\Vehicle\Body\CAD\Bus_Makhulu\',...
    '\Libraries\Vehicle\Body\CAD\Sedan_Hamba\',...
    '\Libraries\Vehicle\Body\Human\',...
    '\Libraries\Event\Driver\',...
    'AntiRollBar_None',...
    'AntiRollBar_Simple',...
    };

    %'Suspension_Linkage_Decoupled.slx',...
    %'\Libraries\Vehicle\Linkage\RollHeave_Decoupled',...
    %'Linkage_Decoupled',...
    %'\Libraries\Vehicle\Linkage\DW_Decoupled',...
    %'\Libraries\Vehicle\Linkage\DW_PushUA',...


slx_inds = 1:length(requiredFilesSLX_full);
for dns_i = 1:length(doNotCopyList_SLX)
    remove_ind = find(contains(requiredFilesSLX_full,doNotCopyList_SLX{dns_i}));
    slx_inds = setdiff(slx_inds,remove_ind);
end
requiredFilesSLX = requiredFilesSLX_full(slx_inds);

%%
requiredFilesStr = dependencies.fileDependencyAnalysis('startup_sm_car.m');
requiredFilesStr_m_inds = endsWith(requiredFilesStr,'.m');
requiredFilesStr_m_full = requiredFilesStr(requiredFilesStr_m_inds);

%%
% Exclude List: MATLAB Code
doNotCopyList_Str_m = {...
    '\Libraries\Event\Tools\CRG_Tools\',...
    '\Libraries\Event\Tools\OpenCRG_v1p1p2\',...
    '\Libraries\Event\Tools\',...
    '\Libraries\Vehicle\Tire\',...    
    '\Libraries\Power\FuelCell\',...    
    '\Scripts_Data\Data_Vehicle\Assemble_Vehicle\',...    
    '\Scripts_Data\Data_Vehicle\Presets\',...    
    '\Scripts_Data\Data_Vehicle\UI\',...    
    'sm_car_import_vehicle_data',...    
    'sm_car_database_import_excel',...
    'GetTNODelftTyrePath',...    
    'sm_car_DelftTyrePath',...    
    'sm_car_gen_upd_database',...    
    'sm_car_startupMFSwift',...    
    'sm_car_winopen_file',...
    'xlscol',...
    };

strm_inds = 1:length(requiredFilesStr_m_full);
for dnm_i = 1:length(doNotCopyList_Str_m)
    remove_ind = find(contains(requiredFilesStr_m_full,doNotCopyList_Str_m{dnm_i}));
    strm_inds = setdiff(strm_inds,remove_ind);
end
requiredFilesStr_m = requiredFilesStr_m_full(strm_inds);

%%
ensureCopyList = {...
    'Libraries\Event\Scene\CRG_Hockenheim\',...
    'Libraries\Event\Scene\Track_Mallory_Park_Obstacle\',...
    'Libraries\Event\Scene\Skidpad\',...
    'Libraries\Images\',...
    'sm_car_define_camera_achilles.m',...
    'fsae190_50R10.tir',...
    'sm_car_controlparam_default.m',...
    'sm_car_controlparam_Ideal_L1_R1_L2_R2_default.m',...
    'sm_car_controlparam_Ideal_L1_R1_L2_R2_achilles.m',...
    'sm_car_scenedata_plane_grid.m',...
    'Maneuver_data_hockenheim.m',...
    'Maneuver_data_hockenheim_f.m',...
    'Maneuver_data_skidpad.m',...
    'Maneuver_data_wot_braking.m',...
    'Init_data_hockenheim.m',...
    'Init_data_hockenheim_f.m',...
    'Init_data_skidpad.m',...
    'Init_data_wot_braking.m',...
    'Vehicle_data_dwishbone.m',...
    'Vehicle_data_decoupled.m',...
    'Vehicle_data_dwpushrod.m',...
    'startup_sm_car.m',...
    'sm_car_define_camera.m',...
    'pdaesscSetMultibody.p',...
    'plimitDerivativePerturbations.p',...
    'sm_car_plot1speed.m',...
    'sm_car_plot2whlspeed.m',...
    'sm_car_plot3maneuver.m',...
    'sm_car_plot5bodymeas.m',...
    'sm_car_plot7power.m',...
    'sm_car_plot10_tire_force_torque.m',...
    'sm_car_testrig_quarter_car_plot1toecamber.m',...
    'sm_car_calc_susp_metrics.m',...
    'README.md',...
    'SECURITY.md',...
    'LICENSE.md',...
    'readTIR.m',...
    'Libraries\Event\Tools\',...
    'sm_car_vehcfg_getTrailerType.m',...
    'testrig_quarter_car_doublewishbone.slx',...
    'testrig_quarter_car_pushrodua.slx',...
    'Spring_Linear.slx',...
    'Damper_Linear.slx',...
    'AntiRollBar_Droplink_Rod.slx',...
    'AntiRollBar_Droplink.slx',...
    };

%excludeList = {
%    'CFL_Libs\Libraries\Images\',...
%    'CFL_Libs\Libraries\Images\'...
%    };

encFileList = [];

for enc_i = 1:length(ensureCopyList)
    if(contains(ensureCopyList{enc_i},'.'))
        fil_list = dir([SSVTRootFolder '\**\' ensureCopyList{enc_i}]);
    else
        fil_list = dir([SSVTRootFolder filesep ensureCopyList{enc_i} '**\*']);
    end
    for i = 1:length(fil_list)
        if(~startsWith(fil_list(i).name,'.'))
            fileNameFull = [fil_list(i).folder filesep fil_list(i).name];
                encFileList = vertcat(encFileList,cellstr(fileNameFull));
        end
    end
end

requiredFiles_Lists = unique(vertcat(requiredFilesStr_m,requiredFilesSLX,encFileList));

% Eliminate files not within project
fileInds = find(contains(requiredFiles_Lists,SSVTRootFolder));
requiredFiles = requiredFiles_Lists(fileInds);

% Make links relative
fileLinksRelative = strrep(requiredFiles,SSVTRootFolder,'');

% Find where the last backslash is:
backslashFileNames = cellfun(@(x) max(strfind(x, '\')), fileLinksRelative, 'UniformOutput', false);

% Eliminate portion of the link containing the last backlash.
folderLinksRelative = unique(cellfun(@(x,y) x(1:y), fileLinksRelative,backslashFileNames,'UniformOutput',false));

% Point links to new location where all files will be saved
folderLinksAbsolute = cellfun(@(x,y) [x y] ,repmat({Link},numel(folderLinksRelative),1),folderLinksRelative,'UniformOutput',false);

% Create folders
cellfun(@(x) mkdir(x), folderLinksAbsolute);

% Create path to new folder
fileLinksAbsolute = cellfun(@(x,y) [x y] ,repmat({Link},numel(fileLinksRelative),1),fileLinksRelative,'UniformOutput',false);

% Copy files
cellfun(@(x,y) copyfile(x,y),requiredFiles, fileLinksAbsolute)

% Create new project
proj = matlab.project.createProject('Name','SSVT_FSAE','Folder',[Link,'\']);
proj.SimulinkCacheFolder   = 'work';
proj.SimulinkCodeGenFolder = 'work';

% Identify folders for path
folderforPath_ind = ~contains(folderLinksRelative,'+');
folderforPath     = folderLinksRelative(folderforPath_ind);

curr_proj = simulinkproject;
folderforPath(1)     = cellstr(curr_proj.RootFolder);
%folderforPath        = folderforPath(2:end);
folderforPath(end+1) = cellstr(mfeval_dir);

cellfun(@(x,y) addFolderIncludingChildFiles(x,y),repmat({proj},numel(folderforPath(2:end)),1), folderforPath(2:end))
cellfun(@(x,y) addPath(x,y), repmat({proj}, numel(folderforPath),1), folderforPath)

% Close open file - need to open copy that is part of new project
bdclose(mdl_3)
movefile([mdl_3 '.slx'],[mdl_0 '.slx'])
addFile(curr_proj,[mdl_0 '.slx']);

% Move files within project
vehDataMove = ['.' filesep 'Scripts_Data' filesep 'Data_Vehicle' filesep 'Vehicle_data_dwishbone.m'];
movefile('Vehicle_data_dwishbone.m',vehDataMove)
addFile(curr_proj,vehDataMove);
vehDataMove = ['.' filesep 'Scripts_Data' filesep 'Data_Vehicle' filesep 'Vehicle_data_decoupled.m'];
movefile('Vehicle_data_decoupled.m',vehDataMove)
addFile(curr_proj,vehDataMove);
vehDataMove = ['.' filesep 'Scripts_Data' filesep 'Data_Vehicle' filesep 'Vehicle_data_dwpushrod.m'];
movefile('Vehicle_data_dwpushrod.m',vehDataMove)
addFile(curr_proj,vehDataMove);

initDataMove = ['.' filesep 'Libraries' filesep 'Event' filesep 'Init_data_hockenheim.m'];
movefile('Init_data_hockenheim.m',initDataMove)
addFile(curr_proj,initDataMove);
initDataMove = ['.' filesep 'Libraries' filesep 'Event' filesep 'Init_data_hockenheim_f.m'];
movefile('Init_data_hockenheim_f.m',initDataMove)
addFile(curr_proj,initDataMove);
initDataMove = ['.' filesep 'Libraries' filesep 'Event' filesep 'Init_data_skidpad.m'];
movefile('Init_data_skidpad.m',initDataMove)
addFile(curr_proj,initDataMove);
initDataMove = ['.' filesep 'Libraries' filesep 'Event' filesep 'Init_data_wot_braking.m'];
movefile('Init_data_wot_braking.m',initDataMove)
addFile(curr_proj,initDataMove);

manDataMove = ['.' filesep 'Libraries' filesep 'Event' filesep 'Maneuver_data_hockenheim.m'];
movefile('Maneuver_data_hockenheim.m',manDataMove)
addFile(curr_proj,manDataMove);
manDataMove = ['.' filesep 'Libraries' filesep 'Event' filesep 'Maneuver_data_hockenheim_f.m'];
movefile('Maneuver_data_hockenheim_f.m',manDataMove)
addFile(curr_proj,manDataMove);
manDataMove = ['.' filesep 'Libraries' filesep 'Event' filesep 'Maneuver_data_skidpad.m'];
movefile('Maneuver_data_skidpad.m',manDataMove)
addFile(curr_proj,manDataMove);
manDataMove = ['.' filesep 'Libraries' filesep 'Event' filesep 'Maneuver_data_wot_braking.m'];
movefile('Maneuver_data_wot_braking.m',manDataMove)
addFile(curr_proj,manDataMove);

% Replace files within project
for i = 1:length(repFilesList)
    repFileName = strrep(repFilesList{i},'_FSAE','');
    copyfile([repFilesPath filesep repFilesList{i}],which(repFileName))
    %disp ([repFilesPath filesep repFilesList{i} ' TO ' which(repFileName)])
end

% Add addfield* files to project
DataVehicleFolder = fileparts(which('Vehicle_data_decoupled.m'));
for i = 1:length(addFieldsList)
    addFileName = [DataVehicleFolder filesep addFieldsList{i}];
    copyfile([repFilesPath filesep addFieldsList{i}],addFileName)
    addFile(curr_proj,addFileName)
end

% Add *.md files to project
addFile(curr_proj,'README.md');
addFile(curr_proj,'LICENSE.md');
addFile(curr_proj,'SECURITY.md');

% Add Overview to project
overviewPath = ['.' filesep 'Scripts_Data' filesep 'Overview'];
copyfile([repFilesPath filesep 'Overview'],overviewPath)
addFolderIncludingChildFiles(curr_proj,overviewPath)
addPath(curr_proj,overviewPath);

% Add startup file to project details
addStartupFile(curr_proj,which('startup_sm_car.m'));

% Resave Libraries
libResaveList = {'Linkage_Systems.slx','Linkage_Decoupled.slx','Tire_1x.slx'};

fullFileList = [];
for i = 1:length(libResaveList)
    fullFileList{i} = cellstr(which(libResaveList{i}));
end

close(curr_proj)

for i = 1:length(fullFileList)
    [d,f,e] = fileparts(fullFileList{i});
    cd(char(d))
    load_system(char(f));
    save_system(char(f));
    bdclose(char(f));
end

cd(curr_proj.RootFolder)
openProject("SSVT_FSAE.prj");

% Remove Custom_lib.slx
custLibName = which('Custom_lib.slx');
if(~isempty(custLibName))
    removeFile(curr_proj,custLibName);
end

%% Delete links to files we did not include
% Linkage Systems
load_system('Linkage_Systems')
set_param(bdroot,'Lock','off')

f = Simulink.FindOptions('SearchDepth',1);
linkageBlocks = Simulink.findBlocks('Linkage_Systems/Linkage',f);

for i = 1:length(linkageBlocks)
    if(strcmp(get_param(linkageBlocks(i),'LinkStatus'),'unresolved'))
        disp(getfullname(linkageBlocks(i)));
        delete_block(linkageBlocks(i))
    end
end

save_system('Linkage_Systems')
bdclose('Linkage_Systems')

% Anti Roll Bar Systems
load_system('AntiRollBar_Systems')
set_param(bdroot,'Lock','off')

f = Simulink.FindOptions('SearchDepth',1);
antiRollBarBlocks = Simulink.findBlocks('AntiRollBar_Systems/Anti Roll Bar',f);

for i = 1:length(antiRollBarBlocks)
    if(strcmp(get_param(antiRollBarBlocks(i),'LinkStatus'),'unresolved'))
        disp(getfullname(antiRollBarBlocks(i)));
        delete_block(antiRollBarBlocks(i))
    end
end

save_system('AntiRollBar_Systems')
bdclose('AntiRollBar_Systems')

% Linkage Decoupled Systems
load_system('Linkage_Decoupled')
set_param('Linkage_Decoupled','Lock','off')

f = Simulink.FindOptions('SearchDepth',1);
linkageBlocks = Simulink.findBlocks('Linkage_Decoupled/Linkage',f);

for i = 1:length(linkageBlocks)
    if(strcmp(get_param(linkageBlocks(i),'LinkStatus'),'unresolved'))
        disp(getfullname(linkageBlocks(i)));
        delete_block(linkageBlocks(i))
    end
end

save_system('Linkage_Decoupled')
bdclose('Linkage_Decoupled')

% Tire_1x2x
mdl = 'Tire_1x2x';
load_system(mdl)
set_param(mdl,'Lock','off')

f = Simulink.FindOptions('SearchDepth',1);
linkageBlocks = Simulink.findBlocks([mdl '/Tire Models'],f);

for i = 1:length(linkageBlocks)
    if(strcmp(get_param(linkageBlocks(i),'LinkStatus'),'unresolved'))
        disp(getfullname(linkageBlocks(i)));
        delete_block(linkageBlocks(i))
    end
end

delete_block('Tire_1x2x/Tire Models/Tire2x');

save_system(mdl)
bdclose(mdl)

% Tire_1x
mdl = 'Tire_1x';
load_system(mdl)
f = Simulink.FindOptions('SearchDepth',1);
linkageBlocks = Simulink.findBlocks([mdl '/Tire Individual'],f);

for i = 1:length(linkageBlocks)
    if(strcmp(get_param(linkageBlocks(i),'LinkStatus'),'unresolved'))
        disp(getfullname(linkageBlocks(i)));
        delete_block(linkageBlocks(i))
    end
end

save_system(mdl)
bdclose(mdl)

% TireBody_Systems
mdlBody = 'TireBody_Systems';
load_system(mdlBody)
set_param(mdlBody,'Lock','off')

f = Simulink.FindOptions('SearchDepth',1);
linkageBlocks = Simulink.findBlocks([mdlBody '/Tire Body'],f);

for i = 1:length(linkageBlocks)
    if(strcmp(get_param(linkageBlocks(i),'LinkStatus'),'unresolved'))
        disp(getfullname(linkageBlocks(i)));
        delete_block(linkageBlocks(i))
    end
end

save_system(mdlBody)
bdclose(mdlBody)

mdlTestrig = 'testrig_quarter_car_pushrodua';
load_system(mdlTestrig)
set_param(mdlTestrig,'PostLoadFcn','Vehicle_data_dwpushrod')
save_system(mdlTestrig)
bdclose(mdlTestrig)

mdlTestrig = 'testrig_quarter_car_doublewishbone';
load_system(mdlTestrig)
set_param(mdlTestrig,'PostLoadFcn','Vehicle_data_dwishbone')
save_system(mdlTestrig)
bdclose(mdlTestrig)


%load_system('sm_car_lib')
%set_param('sm_car_lib','Lock','off')
%set_param('sm_car_lib/Environment','Commented','on')
%save_system('sm_car_lib')
%close_system('sm_car_lib')


startup_sm_car



%% Remaining steps

% 1. Eliminate Power\FuelCell, DOF15, LiveAxle
% 2. Rename main file sm_car.slx
% 3. add, fix startup
% 4. Add project root to path
% 5. Add MFEval_4p0 to path
% 6. fix model properties
% 7. fix hyperlinks
% 8. Remove links to libraries that were not copied
%    suspension, tire, scene, ...
% 9. Modifications to config maneuver to avoid trailer which has been removed
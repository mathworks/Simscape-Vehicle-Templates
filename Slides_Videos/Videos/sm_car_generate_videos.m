% Copyright 2019-2021 The MathWorks, Inc.
cd(fileparts(which(mfilename)));
load CameraXML
cam_views = fieldnames(CameraXML);

veh_set = [12 142 145];
%veh_set = [12 142];
trailer_set = {'none','03','04'};
%trailer_set = {'none'};

view_set = {'Track_FixO_FR','Track_SeatFL', 'Track_FixO_Top', 'Track_FixO_Right', 'Track_FixO_Rear', 'View_Susp_FL'};
%view_set = {'Track_FixO_FR','Track_SeatFL'};

%{x
maneuver_vnt = {...
    'Double Lane Change', 'D';
    'Skidpad',            'K';
    'Mallory Park',       'M';
    'RDF Rough Road',     'U';  % Uneven
    'Ice Patch',          'I';
    'RDF Plateau',        'P'};
%}

%{
maneuver_vnt = {...
    'Double Lane Change', 'D';
    'Testrig 4 Post',     'T'};
%}

mdl = 'sm_car';

% Loop over all vehicle configuration presets
num_runs = 0;
for view_i = 1:length(view_set)
    open_system(mdl);
    set_param(mdl,'InternalSimMechanicsExplorerSettings',CameraXML.(view_set{view_i}));
    for veh_i = 1:length(veh_set)
        for trl_i = 1:length(trailer_set)
            veh_suffix = pad(num2str(veh_set(veh_i)),3,'left','0');
            eval(['load(''Vehicle_' veh_suffix ''');']);
            eval(['Vehicle = Vehicle_' veh_suffix ';']);
            sm_car_load_trailer_data('sm_car',trailer_set{trl_i});
            sm_car_config_vehicle(mdl);
            for m_i = 1:size(maneuver_vnt,1)
                sm_car_config_maneuver(mdl,maneuver_vnt{m_i,1});
                if(strcmp(view_set{view_i},'View_Susp_FL'))
                    Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 1 1 1]);
                end
                sm_car_config_vehicle(mdl); % Some maneuvers change vehicle type (CRG)
                
                if(strcmpi(maneuver_vnt{m_i,1},'Mallory Park'))
                    set_param(mdl,'StopTime','130')
                    playbackspeedratio = 4.0;
                    Visual.PaceCar.body.opc = 0.1;
                    Visual.PaceCar.emblem.opc = 0.1;
                else
                    playbackspeedratio = 2.0;
                    Visual.PaceCar.body.opc = 0;
                    Visual.PaceCar.emblem.opc = 0;
                end
                
                try
                    num_runs = num_runs+1;
                    disp(' ');
                    disp(['Sim ' num2str(num_runs) ' starting...']);
                    out = sim(mdl);
                    disp(['... sim finished. Elapsed Sim Time: ' num2str(Elapsed_Sim_Time)]);
                catch
                    disp('... sim Failed');
                end
                
                % Get Vehicle body name
                veh_config = Vehicle.config;
                veh_config_set = strsplit(veh_config,'_');
                veh_body =  veh_config_set{1};
                
                % Get Trailer type
                trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
                mane_vnt = maneuver_vnt{m_i,2};
                video_name = ['sm_car_' veh_body '_' trailer_type '_' mane_vnt '_' view_set{view_i}];
                folder_name = [pwd filesep veh_body filesep trailer_type];
                disp(['Video: smwritevideo ' folder_name filesep video_name]);
                smwritevideo(mdl, [folder_name filesep video_name],...
                    'PlaybackSpeedRatio', playbackspeedratio, 'FrameRate', 30, 'VideoFormat', 'mpeg-4', 'FrameSize',[800 450]);
                pause(10)
                TF = com.mathworks.physmod.sm.gui.gfx.VideoCreator.isRecording();
                while(TF)
                    pause(5)
                    TF = com.mathworks.physmod.sm.gui.gfx.VideoCreator.isRecording();
                    disp('Waiting for video to write...');
                end
                disp('Video Complete');
                %pause(30); % Appropriate for fast machine.
            end
        end
    end
    %pause(180);   % Be sure videos are done
    bdclose(mdl);
    pause(30);    % Ensure Mechanics Explorer has closed
end


veh_set = 142;
trailer_set = {'none'};
view_set = {'Global_Hamba_Testrig_Iso','Global_Hamba_Testrig_Front'};
maneuver_vnt = {...
    'Testrig 4 Post',     'T'};

mdl = 'sm_car';

% Loop over all vehicle configuration presets
num_runs = 0;
for view_i = 1:length(view_set)
    open_system(mdl);
    set_param(mdl,'InternalSimMechanicsExplorerSettings',CameraXML.(view_set{view_i}));
    for veh_i = 1:length(veh_set)
        for trl_i = 1:length(trailer_set)
            veh_suffix = pad(num2str(veh_set(veh_i)),3,'left','0');
            eval(['load(''Vehicle_' veh_suffix ''');']);
            eval(['Vehicle = Vehicle_' veh_suffix ';']);
            sm_car_load_trailer_data('sm_car',trailer_set{trl_i});
            sm_car_config_vehicle(mdl);
            for m_i = 1:size(maneuver_vnt,1)
                sm_car_config_maneuver(mdl,maneuver_vnt{m_i,1});
                sm_car_config_vehicle(mdl); % Some maneuvers change vehicle type (CRG)
                
                if(strcmpi(maneuver_vnt{m_i,1},'Mallory Park'))
                    set_param(mdl,'StopTime','130')
                    playbackspeedratio = 4.0;
                    Visual.PaceCar.body.opc = 0.1;
                    Visual.PaceCar.emblem.opc = 0.1;
                else
                    playbackspeedratio = 2.0;
                    Visual.PaceCar.body.opc = 0;
                    Visual.PaceCar.emblem.opc = 0;
                end
                
                try
                    num_runs = num_runs+1;
                    disp(' ');
                    disp(['Sim ' num2str(num_runs) ' starting...']);
                    out = sim(mdl);
                    disp(['... sim finished. Elapsed Sim Time: ' num2str(Elapsed_Sim_Time)]);
                catch
                    disp('... sim Failed');
                end
                
                % Get Vehicle body name
                veh_config = Vehicle.config;
                veh_config_set = strsplit(veh_config,'_');
                veh_body =  veh_config_set{1};
                
                % Get Trailer type
                trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
                mane_vnt = maneuver_vnt{m_i,2};
                video_name = ['sm_car_' veh_body '_' trailer_type '_' mane_vnt '_' view_set{view_i}];
                folder_name = [pwd filesep veh_body filesep trailer_type];
                disp(['Video: smwritevideo ' folder_name filesep video_name]);
                smwritevideo(mdl, [folder_name filesep video_name],...
                    'PlaybackSpeedRatio', playbackspeedratio, 'FrameRate', 30, 'VideoFormat', 'mpeg-4', 'FrameSize',[800 450]);
                pause(10)
                TF = com.mathworks.physmod.sm.gui.gfx.VideoCreator.isRecording();
                while(TF)
                    pause(5)
                    TF = com.mathworks.physmod.sm.gui.gfx.VideoCreator.isRecording();
                    disp('Waiting for video to write...');
                end
                disp('Video Complete');
                %pause(30); % Appropriate for fast machine.
            end
        end
    end
    %pause(180);   % Be sure videos are done
    bdclose(mdl);
    pause(30);    % Ensure Mechanics Explorer has closed
end

veh_set = 145;
trailer_set = {'none'};
view_set = {'Global_Makhulu_Testrig_Front','Global_Makhulu_Testrig_Iso'};
maneuver_vnt = {...
    'Testrig 4 Post',     'T'};

mdl = 'sm_car';

% Loop over all vehicle configuration presets
num_runs = 0;
for view_i = 1:length(view_set)
    open_system(mdl);
    set_param(mdl,'InternalSimMechanicsExplorerSettings',CameraXML.(view_set{view_i}));
    for veh_i = 1:length(veh_set)
        for trl_i = 1:length(trailer_set)
            veh_suffix = pad(num2str(veh_set(veh_i)),3,'left','0');
            eval(['load(''Vehicle_' veh_suffix ''');']);
            eval(['Vehicle = Vehicle_' veh_suffix ';']);
            sm_car_load_trailer_data('sm_car',trailer_set{trl_i});
            sm_car_config_vehicle(mdl);
            for m_i = 1:size(maneuver_vnt,1)
                sm_car_config_maneuver(mdl,maneuver_vnt{m_i,1});
                sm_car_config_vehicle(mdl); % Some maneuvers change vehicle type (CRG)
                
                if(strcmpi(maneuver_vnt{m_i,1},'Mallory Park'))
                    set_param(mdl,'StopTime','130')
                    playbackspeedratio = 4.0;
                    Visual.PaceCar.body.opc = 0.1;
                    Visual.PaceCar.emblem.opc = 0.1;
                else
                    playbackspeedratio = 2.0;
                    Visual.PaceCar.body.opc = 0;
                    Visual.PaceCar.emblem.opc = 0;
                end
                
                try
                    num_runs = num_runs+1;
                    disp(' ');
                    disp(['Sim ' num2str(num_runs) ' starting...']);
                    out = sim(mdl);
                    disp(['... sim finished. Elapsed Sim Time: ' num2str(Elapsed_Sim_Time)]);
                catch
                    disp('... sim Failed');
                end
                
                % Get Vehicle body name
                veh_config = Vehicle.config;
                veh_config_set = strsplit(veh_config,'_');
                veh_body =  veh_config_set{1};
                
                % Get Trailer type
                trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
                mane_vnt = maneuver_vnt{m_i,2};
                video_name = ['sm_car_' veh_body '_' trailer_type '_' mane_vnt '_' view_set{view_i}];
                folder_name = [pwd filesep veh_body filesep trailer_type];
                disp(['Video: smwritevideo ' folder_name filesep video_name]);
                smwritevideo(mdl, [folder_name filesep video_name],...
                    'PlaybackSpeedRatio', playbackspeedratio, 'FrameRate', 30, 'VideoFormat', 'mpeg-4', 'FrameSize',[800 450]);
                pause(10)
                TF = com.mathworks.physmod.sm.gui.gfx.VideoCreator.isRecording();
                while(TF)
                    pause(5)
                    TF = com.mathworks.physmod.sm.gui.gfx.VideoCreator.isRecording();
                    disp('Waiting for video to write...');
                end
                disp('Video Complete');
                %pause(30); % Appropriate for fast machine.
            end
        end
    end
    %pause(180);   % Be sure videos are done
    bdclose(mdl);
    pause(30);    % Ensure Mechanics Explorer has closed
end
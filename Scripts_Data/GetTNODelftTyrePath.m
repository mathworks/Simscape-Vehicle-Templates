function TNOtbx_pth=GetTNODelftTyrePath
% DETERMINE IF TNO DELFT-TYRE TOOLBOX DIRECTORY IS ON PATH
% CHECK IF TOOLBOX ALREADY ON PATH

% Copyright 2014-2023 The MathWorks, Inc.

TNOtbxOnPath = ~isempty(which('s_delfttyre_sti'));

% IF NOT ALREADY ON PATH
if(~TNOtbxOnPath)
    
    % DEFAULT INSTALLATION FOLDER
    TNOtbx_pth = 'C:\TNO Delft-Tyre';
        
    if ((exist(TNOtbx_pth)==7))      % LOOK BELOW DEFAULT FOLDER
        selected_dir = TNOtbx_pth;
    elseif (~(exist(TNOtbx_pth)==7)) % IF NOT IN DEFAULT FOLDER
        TNOtbx_pth='';
        % ASK USER TO SELECT FOLDER
        %selected_dir=uigetdir('C:\','Select TNO Delft-Tyre installation folder');
        selected_dir = filesep;
    end
    if(selected_dir(end)==filesep || isnumeric(selected_dir))
        %uiwait(warndlg(sprintf('%s\n%s\n%s\n%s','TNO Delft-Tyre MATLAB Toolbox not found.','You need to select the subfolder where the software is installed.','Run startup script again to select another directory,','or add toolbox manually to the MATLAB path.'),'MATLAB Toolbox Not Found'));
    else
        disp('Searching for TNO-Delft Tyre MATLAB Toolbox...');
        allsubdir = [';' genpath(selected_dir)];
        
        % FIND MOST RECENT VERSION OF TNO DELFT-TYRE SOFTWARE ( max() )
        relevantdirind=max(findstr(allsubdir,['MATLAB' filesep 'Toolbox']));
        semicolonind=findstr(allsubdir,';');
        if(~isempty(relevantdirind) && ~isempty(semicolonind))
            pathsep_previous_ind = max(semicolonind(semicolonind<relevantdirind));
            pathsep_next_ind = min(semicolonind(semicolonind>relevantdirind));
            if(~isempty(pathsep_previous_ind) && ~isempty(pathsep_next_ind))
                TNOtbx_pth = allsubdir(pathsep_previous_ind+1:pathsep_next_ind-1);
            else
                uiwait(warndlg(sprintf('%s\n%s\n%s','TNO Delft-Tyre MATLAB Toolbox not found.','Run startup script again to select another directory,','or add toolbox manually to the MATLAB path.'),'MATLAB Toolbox Not Found'));
            end
        else
            uiwait(warndlg(sprintf('%s\n%s\n%s','TNO Delft-Tyre MATLAB Toolbox not found.','Run startup script again to select another directory,','or add toolbox manually to the MATLAB path.'),'MATLAB Toolbox Not Found'));
        end
        
    end
else
    TNOtbx_pth = fileparts(which('s_delfttyre_cpi'));
end


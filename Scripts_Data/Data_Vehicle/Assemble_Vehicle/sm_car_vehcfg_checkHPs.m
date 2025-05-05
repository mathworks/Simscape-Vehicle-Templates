function hp_check_sum = sm_car_vehcfg_checkHPs(Vehicle,varargin)
% Check consistency of hardpoint locations and endstops in Vehicle data structure
%
%   Vehicle    Vehicle data structure, can have any number of axles
%   showres    Optional parameter to display results of comparison
%
% A few linkage parameter values must exist in multiple places within the
% Vehicle data structure. This enables the subsystems to be tested
% independently.  This code checks a few of the parameter values that must
% be consistent.  A checksum is calculated by measuring the distance
% between hardpoints and the difference in endstop values.  If the checksum
% is non-zero, some parameter values may be inconsistent.
%
% >> load Vehicle_002
% >> hp_check_sum = sm_car_vehcfg_checkHPs(Vehicle_002,true)
%
% The points which are checked include:
%    Shock hardpoints with spring hardpoints
%    Shock hardpoints with damper hardpoints
%    Shock endstops with Damper endstops
%
% Copyright 2023-2024 The MathWorks, Inc.

showres = false;
if(nargin>1)
    % Display results to command window
    showres = varargin{1};
end

% Find portions of data structure associated with suspensions
% Can be any number of axles
cha_fnames = sort(fieldnames(Vehicle.Chassis));
susp_field_inds = find(startsWith(cha_fnames,'Susp'));

% Assume parameters are consistent
hp_check_sum.total = 0;

% If any suspensions are found
if(~isempty(susp_field_inds))
    % Loop over suspensions
    for sus_i=1:length(susp_field_inds)
        % Extract suspension names
        suspName = cha_fnames{susp_field_inds(sus_i)};
        
        % Only perform comparison if suspension has hardpoints - Simple does not
        if(~strcmp(Vehicle.Chassis.(suspName).class.Value,'Simple'))
            % Assemble index of suspension for output
            csSuName = ['A' num2str(sus_i)];    % A1, A2
            % Assemble fieldname of Axle, exists within Vehicle data structure
            csAxName = ['Axle' num2str(sus_i)]; % Axle1, Axle2

            % If steering exists, get difference
            try
                hp_check_sum.(csSuName).Tr2Ra_InO = sum(Vehicle.Chassis.(suspName).Linkage.TrackRod.sInboard.Value  - Vehicle.Chassis.(suspName).Steer.Rack.sOutboard.Value);
            catch
            end
            
            % For Linkage suspension class
            if(strcmp(Vehicle.Chassis.(suspName).class.Value,'Linkage'))
                
                hp_check_sum.(csSuName).Sh2Sp_Top = norm(Vehicle.Chassis.(suspName).Linkage.Shock.sTop.Value    - Vehicle.Chassis.Spring.(csAxName).sTop.Value);
                hp_check_sum.(csSuName).Sh2Sp_Bot = norm(Vehicle.Chassis.(suspName).Linkage.Shock.sBottom.Value - Vehicle.Chassis.Spring.(csAxName).sBottom.Value);
                hp_check_sum.(csSuName).Sh2Da_Top = norm(Vehicle.Chassis.(suspName).Linkage.Shock.sTop.Value    - Vehicle.Chassis.Damper.(csAxName).Damping.sTop.Value);
                hp_check_sum.(csSuName).Sh2Da_Bot = norm(Vehicle.Chassis.(suspName).Linkage.Shock.sBottom.Value - Vehicle.Chassis.Damper.(csAxName).Damping.sBottom.Value);
                hp_check_sum.(csSuName).Sh2Da_xMn = Vehicle.Chassis.(suspName).Linkage.Endstop.xMin.Value  - Vehicle.Chassis.Damper.(csAxName).Endstop.xMin.Value;
                hp_check_sum.(csSuName).Sh2Da_xMx = Vehicle.Chassis.(suspName).Linkage.Endstop.xMax.Value  - Vehicle.Chassis.Damper.(csAxName).Endstop.xMax.Value;
                
                if(showres)
                    % Match HPs, Shock and Spring
                    disp([csSuName ', Shock and Spring Top: ' num2str(hp_check_sum.(csSuName).Sh2Sp_Top)]);
                    disp([csSuName ', Shock and Spring Bot: ' num2str(hp_check_sum.(csSuName).Sh2Sp_Bot)]);
                    
                    % Match HPs, Shock and Damper
                    disp([csSuName ', Shock and Damper Top: ' num2str(hp_check_sum.(csSuName).Sh2Da_Top)]);
                    disp([csSuName ', Shock and Damper Bot: ' num2str(hp_check_sum.(csSuName).Sh2Da_Bot)]);
                    
                    % Match Endstop Limits, Shock and Damper
                    disp([csSuName ', Endstop Limit xMin  : ' num2str(hp_check_sum.(csSuName).Sh2Da_xMn)]);
                    disp([csSuName ', Endstop Limit xMax  : ' num2str(hp_check_sum.(csSuName).Sh2Da_xMx)]);
                    
                    % Match Steering - track rod and rack
                    if(isfield(hp_check_sum.(csSuName),'Tr2Ra_InO'))
                        disp([csSuName ', Track in, Rack out  : ' num2str(hp_check_sum.(csSuName).Tr2Ra_InO)]);
                    end
                end

            % For LiveAxle suspension class
            elseif(strcmp(Vehicle.Chassis.(suspName).class.Value,'LiveAxle'))
                hp_check_sum.(csSuName).Sh2Da_Top = norm(Vehicle.Chassis.(suspName).LiveAxle.Shock.sTop.Value    - Vehicle.Chassis.Damper.(csAxName).Damping.sTop.Value);
                hp_check_sum.(csSuName).Sh2Da_Bot = norm(Vehicle.Chassis.(suspName).LiveAxle.Shock.sBottom.Value - Vehicle.Chassis.Damper.(csAxName).Damping.sBottom.Value);
                hp_check_sum.(csSuName).Sh2Da_xMn = Vehicle.Chassis.(suspName).LiveAxle.Endstop.xMin.Value  - Vehicle.Chassis.Damper.(csAxName).Endstop.xMin.Value;
                hp_check_sum.(csSuName).Sh2Da_xMx = Vehicle.Chassis.(suspName).LiveAxle.Endstop.xMax.Value  - Vehicle.Chassis.Damper.(csAxName).Endstop.xMax.Value;
                
                if(showres)
                    % Match HPs, Shock and Damper
                    disp([csSuName ', Shock and Damper Top: ' num2str(hp_check_sum.(csSuName).Sh2Da_Top)]);
                    disp([csSuName ', Shock and Damper Bot: ' num2str(hp_check_sum.(csSuName).Sh2Da_Bot)]);
                    
                    % Match Endstop Limits, Shock and Damper
                    disp([csSuName ', Endstop Limit xMin  : ' num2str(hp_check_sum.(csSuName).Sh2Da_xMn)]);
                    disp([csSuName ', Endstop Limit xMax  : ' num2str(hp_check_sum.(csSuName).Sh2Da_xMx)]);
                    
                    % Match Steering - track rod and rack
                    if(isfield(hp_check_sum.(csSuName),'Tr2Ra_InO'))
                        disp([csSuName ', Track in, Rack out  : ' num2str(hp_check_sum.(csSuName).Tr2Ra_InO)]);
                    end
                end

            elseif(strcmp(Vehicle.Chassis.(suspName).class.Value,'TwistBeam'))
                hp_check_sum.(csSuName).Sh2Da_Top = norm(Vehicle.Chassis.(suspName).TwistBeam.Damper.sTop.Value    - Vehicle.Chassis.Damper.(csAxName).Damping.sTop.Value);
                hp_check_sum.(csSuName).Sh2Da_Bot = norm(Vehicle.Chassis.(suspName).TwistBeam.Damper.sBottom.Value - Vehicle.Chassis.Damper.(csAxName).Damping.sBottom.Value);
                hp_check_sum.(csSuName).Sh2Sp_Top = norm(Vehicle.Chassis.(suspName).TwistBeam.Spring.sTop.Value    - Vehicle.Chassis.Spring.(csAxName).sTop.Value);
                hp_check_sum.(csSuName).Sh2Sp_Bot = norm(Vehicle.Chassis.(suspName).TwistBeam.Spring.sBottom.Value - Vehicle.Chassis.Spring.(csAxName).sBottom.Value);
                hp_check_sum.(csSuName).Sh2Da_xMn = Vehicle.Chassis.(suspName).TwistBeam.Endstop.xMin.Value  - Vehicle.Chassis.Damper.(csAxName).Endstop.xMin.Value;
                hp_check_sum.(csSuName).Sh2Da_xMx = Vehicle.Chassis.(suspName).TwistBeam.Endstop.xMax.Value  - Vehicle.Chassis.Damper.(csAxName).Endstop.xMax.Value;
                
                if(showres)
                    % Match HPs, Shock and Damper
                    disp([csSuName ', Shock and Damper Top: ' num2str(hp_check_sum.(csSuName).Sh2Da_Top)]);
                    disp([csSuName ', Shock and Damper Bot: ' num2str(hp_check_sum.(csSuName).Sh2Da_Bot)]);
                    
                    disp([csSuName ', Shock and Spring Top: ' num2str(hp_check_sum.(csSuName).Sh2Sp_Top)]);
                    disp([csSuName ', Shock and Spring Bot: ' num2str(hp_check_sum.(csSuName).Sh2Sp_Bot)]);
                    
                    % Match Endstop Limits, Shock and Damper
                    disp([csSuName ', Endstop Limit xMin  : ' num2str(hp_check_sum.(csSuName).Sh2Da_xMn)]);
                    disp([csSuName ', Endstop Limit xMax  : ' num2str(hp_check_sum.(csSuName).Sh2Da_xMx)]);
                    
                    % Match Steering - track rod and rack
                    if(isfield(hp_check_sum.(csSuName),'Tr2Ra_InO'))
                        disp([csSuName ', Track in, Rack out  : ' num2str(hp_check_sum.(csSuName).Tr2Ra_InO)]);
                    end
                end
                
            % For Decoupled suspension class
            elseif(strcmp(Vehicle.Chassis.(suspName).class.Value,'Decoupled'))

                hp_check_sum.(csSuName).HSh2Sp_Lef = norm(Vehicle.Chassis.(suspName).Linkage.Shock.Heave.sLeft.Value  - Vehicle.Chassis.Spring.(csAxName).Heave.sTop.Value);
                hp_check_sum.(csSuName).HSh2Sp_Rig = norm(Vehicle.Chassis.(suspName).Linkage.Shock.Heave.sRight.Value - Vehicle.Chassis.Spring.(csAxName).Heave.sBottom.Value);
                hp_check_sum.(csSuName).RSh2Sp_Lef = norm(Vehicle.Chassis.(suspName).Linkage.Shock.Roll.sLeft.Value   - Vehicle.Chassis.Spring.(csAxName).Roll.sTop.Value);
                hp_check_sum.(csSuName).RSh2Sp_Rig = norm(Vehicle.Chassis.(suspName).Linkage.Shock.Roll.sRight.Value  - Vehicle.Chassis.Spring.(csAxName).Roll.sBottom.Value);

                hp_check_sum.(csSuName).HSh2Da_Lef = norm(Vehicle.Chassis.(suspName).Linkage.Shock.Heave.sLeft.Value  - Vehicle.Chassis.Damper.(csAxName).Heave.Damping.sTop.Value);
                hp_check_sum.(csSuName).HSh2Da_Rig = norm(Vehicle.Chassis.(suspName).Linkage.Shock.Heave.sRight.Value - Vehicle.Chassis.Damper.(csAxName).Heave.Damping.sBottom.Value);
                hp_check_sum.(csSuName).RSh2Da_Lef = norm(Vehicle.Chassis.(suspName).Linkage.Shock.Roll.sLeft.Value   - Vehicle.Chassis.Damper.(csAxName).Roll.Damping.sTop.Value);
                hp_check_sum.(csSuName).RSh2Da_Rig = norm(Vehicle.Chassis.(suspName).Linkage.Shock.Roll.sRight.Value  - Vehicle.Chassis.Damper.(csAxName).Roll.Damping.sBottom.Value);

                hp_check_sum.(csSuName).HSh2Da_xMn = Vehicle.Chassis.(suspName).Linkage.Endstop.Heave.xMin.Value - Vehicle.Chassis.Damper.(csAxName).Heave.Endstop.xMin.Value;
                hp_check_sum.(csSuName).HSh2Da_xMx = Vehicle.Chassis.(suspName).Linkage.Endstop.Heave.xMax.Value - Vehicle.Chassis.Damper.(csAxName).Heave.Endstop.xMax.Value;
                hp_check_sum.(csSuName).RSh2Da_xMn = Vehicle.Chassis.(suspName).Linkage.Endstop.Roll.xMin.Value  - Vehicle.Chassis.Damper.(csAxName).Roll.Endstop.xMin.Value;
                hp_check_sum.(csSuName).RSh2Da_xMx = Vehicle.Chassis.(suspName).Linkage.Endstop.Roll.xMax.Value  - Vehicle.Chassis.Damper.(csAxName).Roll.Endstop.xMax.Value;

                if(showres)
                    % Match HPs, Shock and Spring
                    disp([csSuName ', Shock and Spring HeaveL: ' num2str(hp_check_sum.(csSuName).HSh2Sp_Lef)]);
                    disp([csSuName ', Shock and Spring HeaveR: ' num2str(hp_check_sum.(csSuName).HSh2Sp_Rig)]);
                    disp([csSuName ', Shock and Spring RollL : ' num2str(hp_check_sum.(csSuName).RSh2Sp_Lef)]);
                    disp([csSuName ', Shock and Spring RollR : ' num2str(hp_check_sum.(csSuName).RSh2Sp_Rig)]);
                    
                    % Match HPs, Shock and Damper
                    disp([csSuName ', Shock and Damper HeaveL: ' num2str(hp_check_sum.(csSuName).HSh2Da_Lef)]);
                    disp([csSuName ', Shock and Damper HeaveR: ' num2str(hp_check_sum.(csSuName).HSh2Da_Rig)]);
                    disp([csSuName ', Shock and Damper RollL : ' num2str(hp_check_sum.(csSuName).RSh2Da_Lef)]);
                    disp([csSuName ', Shock and Damper RollR : ' num2str(hp_check_sum.(csSuName).RSh2Da_Rig)]);
                    
                    % Match Endstop Limits, Shock and Damper
                    disp([csSuName ', Endstop Lim xMin HeaveL: ' num2str(hp_check_sum.(csSuName).HSh2Da_xMn)]);
                    disp([csSuName ', Endstop Lim xMax HeaveR: ' num2str(hp_check_sum.(csSuName).HSh2Da_xMx)]);
                    disp([csSuName ', Endstop Lim xMin RollL : ' num2str(hp_check_sum.(csSuName).RSh2Da_xMn)]);
                    disp([csSuName ', Endstop Lim xMax RollR : ' num2str(hp_check_sum.(csSuName).RSh2Da_xMx)]);
                    
                    % Match Steering - track rod and rack
                    if(isfield(hp_check_sum.(csSuName),'Tr2Ra_InO'))
                        disp([csSuName ', Track in, Rack out  : ' num2str(hp_check_sum.(csSuName).Tr2Ra_InO)]);
                    end
                end
            end
            
            % Calculate checksum for axle - sum all diferences
            suspCS_fnames = fieldnames(hp_check_sum.(csSuName));
            hp_check_sum.(csSuName).total = 0;
            for pt_i = 1:length(suspCS_fnames)
                hp_check_sum.(csSuName).total = hp_check_sum.(csSuName).total + hp_check_sum.(csSuName).(suspCS_fnames{pt_i});
            end
            
            % Calculate checksum for vehicle
            hp_check_sum.total = hp_check_sum.total + hp_check_sum.(csSuName).total;
        end
    end
end


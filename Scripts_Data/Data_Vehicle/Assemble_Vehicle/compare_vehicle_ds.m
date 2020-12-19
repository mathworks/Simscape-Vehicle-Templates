%% Copy Vehicle_### to Vehicle_a###
%{
for vehi = 0:178
    vehstr  = ['Vehicle_' pad(num2str(vehi),3,'left','0')];
    vehstra = ['Vehicle_a' pad(num2str(vehi),3,'left','0')];
%    disp(['load ' vehstr]);
%    disp([vehstra ' = ' vehstr]);
    eval(['load ' vehstr]);
    eval([vehstra ' = ' vehstr ';']);
    save(vehstra,vehstra);
end
%}

%% Copy Trailer_### to Trailer_a###
%{
for trli = 1:5
    trlstr  = ['Trailer_' pad(num2str(trli),2,'left','0')];
    trlstra = ['Trailer_a' pad(num2str(trli),2,'left','0')];
%    disp(['load ' trlstr]);
%    disp([trlstra ' = ' trlstr]);
    eval(['load ' trlstr]);
    eval([trlstra ' = ' trlstr ';']);
    save(trlstra,trlstra);
end
%}

%%
for vehi = 0:178
    eval(['load Vehicle_' pad(num2str(vehi),3,'left','0')]);
    eval(['load Vehicle_a' pad(num2str(vehi),3,'left','0')]);

    %{
    veh_temp = eval(['Vehicle_a' pad(num2str(vehi),3,'left','0')]);
    spr_temp = veh_temp.Chassis.Damper;
    temp_DamperA1 = spr_temp.Front;
    temp_DamperA2 = spr_temp.Rear;
    spr_temp = rmfield(spr_temp,'Front');
    spr_temp = rmfield(spr_temp,'Rear');
    spr_temp.DamperA1 = temp_DamperA1;
    spr_temp.DamperA2 = temp_DamperA2;
    eval(['Vehicle_a' pad(num2str(vehi),3,'left','0') '.Chassis.Damper = spr_temp;'])
    %}
    
    veh_var_0 = eval(['Vehicle_' pad(num2str(vehi),3,'left','0')]);
    veh_var_a = eval(['Vehicle_a' pad(num2str(vehi),3,'left','0')]);

    [common, d1, d2] = comp_struct(veh_var_0,veh_var_a);
    if(isempty(d1) && isempty(d2))
        disp(['Vehicle ' num2str(vehi) ': OK']);
    else
        disp(['Vehicle ' num2str(vehi) ': Mismatch']);
    end
end

%%
for trli = 1:5
    eval(['load Trailer_' pad(num2str(trli),2,'left','0')]);
    eval(['load Trailer_a' pad(num2str(trli),2,'left','0')]);
    
    %{
    trl_temp = eval(['Trailer_a' pad(num2str(trli),2,'left','0')]);
    spr_temp = trl_temp.Chassis.Damper;
    temp_DamperA1 = spr_temp.Front;
    %temp_DamperA2 = spr_temp.Rear;
    spr_temp = rmfield(spr_temp,'Front');
    %spr_temp = rmfield(spr_temp,'Rear');
    spr_temp.DamperA1 = temp_DamperA1;
    %spr_temp.DamperA2 = temp_DamperA2;
    eval(['Trailer_a' pad(num2str(trli),2,'left','0') '.Chassis.Damper = spr_temp;'])    
    %}
    
    trl_var_0 = eval(['Trailer_' pad(num2str(trli),2,'left','0')]);
    trl_var_a = eval(['Trailer_a' pad(num2str(trli),2,'left','0')]);
    [common, d1, d2] = comp_struct(trl_var_0,trl_var_a);
    if(isempty(d1) && isempty(d2))
        disp(['Trailer ' num2str(trli) ': OK']);
    else
        disp(['Trailer ' num2str(trli) ': Mismatch']);
    end
end
%% 
% Copyright 2019-2020 The MathWorks, Inc.
bdclose all
cd(fileparts(which('Aero_Coefficients.slx')))
copyfile('Aero_Coefficients_noSSC.slx','Aero_Coefficients.slx');

%{xx
cd(fileparts(which('sm_car.slx')))
load Vehicle_147
Vehicle = Vehicle_147;
open_system('sm_car');
%sm_car_config_vehicle(bdroot);
%}xx

%{xx
%% No Links
try
    tic
    cd(fileparts(which(mfilename)));
    cd('NoLinks');
    save_system('sm_car','sm_car_brkLink','BreakUserLinks',true)
    disp('Break Links Succeeded');
    Elapsed_NoLink_Time = toc;
    bdclose all
    NoLinks = true;
catch
    disp('Break Links Failed');
    Elapsed_NoLink_Time = toc;
    bdclose all
    NoLinks = false;
end
%%
%}xx
NoLinks = true;
cd(fileparts(which('sm_car.slx')))
load Vehicle_147
Vehicle = Vehicle_147;
open_system('sm_car');
%sm_car_config_vehicle(bdroot);
%save_system('sm_car')

%% No Variants
%{xx
try
    tic
    cd(fileparts(which(mfilename)));
    cd('NoVariants');
    Simulink.VariantManager.reduceModel(...
        'sm_car', ...
        'GenerateSummary',true, ...
        'ModelSuffix','_r', ...
        'OutputFolder',pwd, ...
        'PreserveSignalAttributes',true, ...
        'Verbose',false);
    disp('NoVariants Succeeded');
    Elapsed_NoVariant_Time = toc;
    bdclose all
    NoVariants = true;
catch
    disp('NoVariants Failed');
    Elapsed_NoVariant_Time = toc;
    bdclose all
    NoVariants = false;
end
%}xx

%% No LinksVariants
if(NoLinks)
    try
        open_system('sm_car_brkLink')
        cd(fileparts(which(mfilename)));
        cd('NoLinksVariants');
        
        tic
        Simulink.VariantManager.reduceModel(...
            'sm_car_brkLink', ...
            'GenerateSummary',true, ...
            'ModelSuffix','_r', ...
            'OutputFolder',pwd, ...
            'PreserveSignalAttributes',true, ...
            'Verbose',false);
        disp('NoLinksVariants Succeeded');
        Elapsed_NoLinksVariants_Time = toc;
        bdclose all
    catch
        disp('NoLinksVariants Failed');
        Elapsed_NoLinksVariants_Time = toc;
        bdclose all
    end
end

%% No VariantsLinks
if(NoVariants)
    try
        open_system('sm_car_r')
        cd(fileparts(which(mfilename)));
        cd('NoVariantsLinks');
        
        tic
        save_system('sm_car_r','sm_car_r_brkLink','BreakUserLinks',true)
        disp('NoVariantsLinks Succeeded');
        Elapsed_NoVariantsLinks_Time = toc;
        bdclose all
    catch
        disp('NoVariantsLinks Failed');
        Elapsed_NoVariantLinks_Time = toc;
        bdclose all
    end
end


%%
cd(fileparts(which('Aero_Coefficients.slx')))
copyfile('Aero_Coefficients_complete.slx','Aero_Coefficients.slx');
bdclose all


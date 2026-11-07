verString = version('-release');

try
    curr_proj = simulinkproject;
catch
    curr_proj = simulinkProject;
end

cd('C:\veh-tpl')

switch verString
    case '2022a'
        if(endsWith(curr_proj.RootFolder,'srcR22a'))
            cellRange = "A2";
        else
            cellRange = "C2";
        end
    case '2022b', cellRange = "E2";
    case '2023a', cellRange = "G2";
    case '2023b', cellRange = "I2";
    case '2024a', cellRange = "K2";
    case '2024b', cellRange = "M2";
    case '2025a', cellRange = "O2";
    case '2025b', cellRange = "Q2";
    case '2026a', cellRange = "S2";
    case '2026b', cellRange = "U2";
end

fileList      = {curr_proj.Files.Path}';
fileList_trim = sort(strrep(fileList,[curr_proj.RootFolder filesep],''));

writecell(fileList_trim,"SSVT_File_Lists.xlsx","Range",cellRange);

cd(curr_proj.RootFolder)

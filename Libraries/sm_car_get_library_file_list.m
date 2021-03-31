function sm_car_get_library_file_list
% Generates MATLAB file for publishing to HTML
% that provides hyperlinks to component library files
%
% Copyright 2019-2021 The MathWorks, Inc.

% Find all Simulink files within Library subfolders
cd(fileparts(which('sm_car_lib.slx')));
filelist_slx = dir('**/*.slx');

% Find Excel files
filelist_xlsx = dir('**/sm_car_data*.xlsx');

index_list = [];
% Loop over list of .slx files
for i = 1:length(filelist_slx)
    % If .slx file is on the path
    if(~isempty(which(filelist_slx(i).name)))
        % Check library description for specific string
        mdl_info = Simulink.MDLInfo(filelist_slx(i).name);
        if(contains(mdl_info.Description,'Component of Simscape Vehicle Templates'))
            %disp(filelist_slx(i).name);
            index_list(end+1) = i;
        end
    end
end

% Create file for publishing
html_name = 'sm_car_library_list_Demo_Script.m';
fid = fopen(html_name,'w');

% Write header
fprintf(fid,'%s\n','%% Simscape Vehicle Templates Library, Links to Component Files');
fprintf(fid,'%s\n','%');
fprintf(fid,'%s\n','% <html>');
fprintf(fid,'%s\n','% <tr><a href="matlab:web(''Simscape_Vehicle_Library_Demo_Script.html'')">Return to Main Page</a><br>');
fprintf(fid,'%s\n','% <br>');
fprintf(fid,'%s\n','% <table border=1><tr>');

% Loop over list of component files
lib_category = [];
current_row = 'data';
data_category_end = 0;
for j=1:length(index_list)
    write_str = '% <td>';
    % Create a new row for each category
    lib_name_parts = strsplit(filelist_slx(index_list(j)).name,'_');
    if(~strcmp(lib_category,lib_name_parts{1}))
        % Write line to create cell for category name
        lib_category = strrep(lib_name_parts{1},'.slx','');
        %disp(['SLX lib_category: ' lib_category]);
        write_str = [write_str '<b>' lib_category '</b></td>'];
        fprintf(fid,'%s\n',write_str);
    end
    % Trim file extension and category name from .slx filename
    type_name = strrep(filelist_slx(index_list(j)).name,'.slx','');
    type_name = strrep(type_name,[lib_category '_'],'');
    
    % Assemble string to create cell with hyperlink to .slx file
    write_str = ['% <td><a href="matlab:open_system(''' filelist_slx(index_list(j)).name ''');">' type_name '</a></td>'];
    
    % Check if next entry is a new category and add code for new row
    if(j<length(index_list))
        lib_name_parts_next = strsplit(filelist_slx(index_list(j+1)).name,'_');
        if(~strcmp(lib_category,lib_name_parts_next{1}))
            % Add new row characters at end
            write_str = [write_str '</tr>'];
            data_category_end = 1;
        end
    else
        write_str = [write_str '</tr>'];
        data_category_end = 1;
    end
    
    % Write line to file for current cell
    fprintf(fid,'%s\n',write_str);
    if (data_category_end)
        %disp(['Excel lib_category: ' lib_category]);
        xlsx_list_inds = find(contains({filelist_xlsx.name}',['sm_car_data_' lib_category '_']));
        xlsx_list_inds = [xlsx_list_inds find(contains({filelist_xlsx.name}',['sm_car_data_' lib_category '.']))];
        if(~isempty(xlsx_list_inds))
            write_str = '% <td> Data (xlsx) </td>';
            fprintf(fid,'%s\n',write_str);
            for xlsx_i=1:length(xlsx_list_inds)
                write_str = '% <td>';
                xlsx_filename = filelist_xlsx(xlsx_list_inds(xlsx_i)).name;
                % Create a new row for each category
                %lib_name_parts = strsplit(xlsx_filename,'_')
                % Trim file extension and category name from .slx filename
                %disp(['REPLACE: sm_car_data_ ' lib_category '_'])
                type_name = strrep(xlsx_filename,['sm_car_data_'],'');
                type_name = strrep(type_name,[lib_category '_'],'');
                type_name = strrep(type_name,'.xlsx','(.xlsx)');
                
                % Assemble string to create cell with hyperlink to .slx file
                write_str = ['% <td><a href="matlab:sm_car_winopen_file(''' xlsx_filename ''');">' type_name '</a></td>'];
                
                % Check if next entry is a new category and add code for new row
                if(xlsx_i==length(xlsx_list_inds))
                    write_str = [write_str '</tr>'];
                    data_category_end = 0;
                end
                fprintf(fid,'%s\n',write_str);
            end
        else
            write_str = '% <td> Data (xlsx) </td></tr>';
            fprintf(fid,'%s\n',write_str);
        end
    end
end

fprintf(fid,'%s\n','% </table><br>');
fprintf(fid,'%s\n','% </html>');
fclose(fid);

% Publish HTML
publish(html_name)
HTMLfilename = strrep(html_name,'.m','.html');
movefile(['.' filesep 'html' filesep HTMLfilename],['.' filesep HTMLfilename]);
rmdir('html');

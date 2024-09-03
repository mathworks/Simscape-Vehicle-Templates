function append_line_to_script(filename, line_to_append)
    % Check if the file exists
    if ~isfile(filename)
        error('File does not exist.');
    end

    % Open the file for reading
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file for reading.');
    end

    % Read the entire content of the file
    file_content = fread(fid, '*char')';
    fclose(fid);

    % Append the new line to the content
    file_content = [file_content, newline, line_to_append, newline];

    % Open the file for writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Cannot open file for writing.');
    end

    % Write the modified content back to the file
    fwrite(fid, file_content);
    fclose(fid);
end
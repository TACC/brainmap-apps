function dataMatrix = readTSV(filename)
    % Open the file for reading
    fileID = fopen(filename, 'r');
    
    % Initialize variables
    data = [];
    line = fgetl(fileID);
    
    % Read lines from the file
    while ischar(line)
        % Skip blank lines and lines starting with '/'
        if ~isempty(line) && line(1) ~= '/'
            % Split the line into columns
            lineData = strsplit(line, '\t');
            
            % Convert the data to numbers
            numData = str2double(lineData);
            
            % Add the row to the matrix if it has three columns
            if numel(numData) == 3
                data = [data; numData];
            end
        end
        
        % Read the next line
        line = fgetl(fileID);
    end
    
    % Close the file
    fclose(fileID);
    
    % Return the data matrix
    dataMatrix = data;
end

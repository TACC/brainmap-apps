function writeTSV(filename, dataMatrix)
    % Open the file for writing
    fileID = fopen(filename, 'w');
    
    % Write the data to the file
    [rows, cols] = size(dataMatrix);
    for i = 1:rows
        for j = 1:cols
            % Convert each element to a string with 2 decimal places
            element = sprintf('%.2f', dataMatrix(i, j));
            
            % Write the element to the file
            fprintf(fileID, '%s', element);
            
            % Add a tab delimiter ('\t') if not the last element in the row
            if j < cols
                fprintf(fileID, '\t');
            end
        end
        
        % Add a new line character ('\n') at the end of each row
        fprintf(fileID, '\n');
    end
    
    % Close the file
    fclose(fileID);
end

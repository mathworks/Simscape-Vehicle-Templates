function combinations = generateCombinations(maxValues)
    % Generate all combinations of sets of integers based on maxValues
    % maxValues: A vector where each element specifies the max number of a set

    % Get the number of sets
    numSets = length(maxValues);
    
    % Calculate the number of combinations
    totalCombinations = prod(maxValues);
    
    % Preallocate combinations matrix
    combinations = zeros(totalCombinations, numSets);
    
    % Fill combinations matrix
    for i = 1:totalCombinations
        index = i;
        for j = 1:numSets
            maxVal = maxValues(j);
            % Calculate the current value in the j-th set
            currentValue = mod(index - 1, maxVal) + 1;
            combinations(i, j) = currentValue;
            index = (index - currentValue) / maxVal + 1;
        end
    end

    numCols = size(combinations,2);
    combinations = sortrows(combinations,1:numCols-1);
end


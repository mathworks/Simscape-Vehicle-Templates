function [theta, axis] = alignZAxisToLine(point1, point2)
    % alignZAxisToLine calculates the rotation angle and axis needed to align
    % the z-axis of a frame with a line formed by two points.
    %
    % Inputs:
    %   point1 - A 3-element vector representing the first point [x1, y1, z1].
    %   point2 - A 3-element vector representing the second point [x2, y2, z2].
    %
    % Outputs:
    %   theta - The rotation angle in radians.
    %   axis  - A 3-element vector representing the rotation axis.

    % Calculate the direction vector of the line
    direction = point2 - point1;
    direction = direction / norm(direction); % Normalize the direction vector

    % The z-axis in the original frame
    zAxis = [0, 0, 1];

    % Calculate the rotation axis using the cross product
    axis = cross(zAxis, direction);
    axisNorm = norm(axis);

    if axisNorm < 1e-6
        % If the axis is near zero, the vectors are already aligned
        theta = 0;
        axis = [0, 0, 1]; % Default axis when no rotation is needed
    else
        % Normalize the rotation axis
        axis = axis / axisNorm;

        % Calculate the rotation angle using the dot product
        cosTheta = dot(zAxis, direction);
        theta = acos(cosTheta);
    end
end
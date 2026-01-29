function R = frameRotationXYextr(alpha, beta, varargin)
%frameRotationXYextr Rotation matrix for extrinsic rotations about fixed x and y axes.
%
%   R = frameRotationXYextr(alpha, beta)
%   R = frameRotationXYextr(alpha, beta, 'Units', 'deg', 'Order', 'xy')
%
%   Inputs:
%     alpha  - Angle about fixed x-axis (extrinsic).
%     beta   - Angle about fixed y-axis (extrinsic).
%
%   Name-Value Parameters:
%     'Units' - 'rad' (default) or 'deg'
%     'Order' - 'xy' (default) or 'yx'
%               'xy' : first rotate about x by alpha, then about y by beta
%                      => R = R_y(beta) * R_x(alpha)
%               'yx' : first rotate about y by beta, then about x by alpha
%                      => R = R_x(alpha) * R_y(beta)
%
%   Output:
%     R      - 3x3 rotation matrix.
%
%   Notes:
%     - Extrinsic = rotations about fixed/world axes.
%     - To rotate a vector v in the world frame: v_new = R * v.

    % Parse name-value args
    p = inputParser;
    addRequired(p, 'alpha', @(x) isnumeric(x) && isscalar(x));
    addRequired(p, 'beta',  @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'Units', 'rad', @(s) ischar(s) || isstring(s));
    addParameter(p, 'Order', 'xy',  @(s) ischar(s) || isstring(s));
    parse(p, alpha, beta, varargin{:});

    units = lower(string(p.Results.Units));
    order = lower(string(p.Results.Order));

    % Convert to radians if needed
    if units == "deg"
        a = deg2rad(alpha);
        b = deg2rad(beta);
    elseif units == "rad"
        a = alpha;
        b = beta;
    else
        error('Units must be ''rad'' or ''deg''.');
    end

    % Elementary rotations about fixed axes
    Rx = [ 1      0        0;
           0  cos(a)  -sin(a);
           0  sin(a)   cos(a) ];

    Ry = [ cos(b)  0  sin(b);
           0       1      0;
          -sin(b)  0  cos(b) ];

    % Compose according to extrinsic order
    switch order
        case "xy"
            R = Ry * Rx;   % first x, then y (extrinsic)
        case "yx"
            R = Rx * Ry;   % first y, then x (extrinsic)
        otherwise
            error('Order must be ''xy'' or ''yx''.');
    end
end

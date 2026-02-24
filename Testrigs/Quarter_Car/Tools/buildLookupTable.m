function [bp, tbl, info] = buildLookupTable(x, y, N, varargin)
% buildLookupTable  Convert unsorted (x,y) data with duplicates into N-point LUT.

p = inputParser;
p.addRequired("x", @(v)isvector(v) && isnumeric(v));
p.addRequired("y", @(v)isvector(v) && isnumeric(v) && numel(v)==numel(x));
p.addRequired("N", @(v)isnumeric(v) && isscalar(v) && v>=2 && mod(v,1)==0);

p.addParameter("dupMethod", "mean", @(s)isstring(s) || ischar(s));
p.addParameter("gridMethod","uniform",@(s)isstring(s) || ischar(s));
p.addParameter("interpMethod","pchip",@(s)isstring(s) || ischar(s));
p.addParameter("extrapMethod","none",@(s)isstring(s) || ischar(s));
p.addParameter("smoothY", 0, @(v)isnumeric(v) && isscalar(v) && v>=0);

p.parse(x,y,N,varargin{:});
opts = p.Results;

info = struct();

x = x(:); y = y(:);
valid = isfinite(x) & isfinite(y);
x = x(valid); y = y(valid);
info.numDroppedInvalid = sum(~valid);

[xS, idx] = sort(x);
yS = y(idx);

[xU, ~, g] = unique(xS, "stable");

switch lower(string(opts.dupMethod))
    case "mean"
        yU = accumarray(g, yS, [], @mean);
    case "median"
        yU = accumarray(g, yS, [], @median);
    case "min"
        yU = accumarray(g, yS, [], @min);
    case "max"
        yU = accumarray(g, yS, [], @max);
    otherwise
        error("dupMethod must be mean/median/min/max.");
end

if opts.smoothY > 0
    yU = movmedian(yU, opts.smoothY, "Endpoints","shrink");
end

if numel(xU) < 2
    error("Not enough unique x values after merging duplicates.");
end

switch lower(string(opts.gridMethod))
    case "uniform"
        bp = linspace(xU(1), xU(end), N);
    case "quantile"
        bp = quantile(xU, linspace(0,1,N));
        bp = makeStrictlyIncreasing(bp);
    otherwise
        error("gridMethod must be uniform or quantile.");
end

% Interpolation
switch lower(string(opts.extrapMethod))
    case "none"
        tbl = interp1(xU, yU, bp, opts.interpMethod); % 4 args
    case "linear"
        tbl = interp1(xU, yU, bp, opts.interpMethod, "extrap");
    otherwise
        error("extrapMethod must be none or linear.");
end

bp  = reshape(bp,  1, []);
tbl = reshape(tbl, 1, []);

info.numOriginal = numel(xS);
info.numUniqueX  = numel(xU);
info.dupMethod   = opts.dupMethod;
info.gridMethod  = opts.gridMethod;
info.interpMethod = opts.interpMethod;
info.extrapMethod = opts.extrapMethod;

end

function v = makeStrictlyIncreasing(v)
v = v(:);
for k = 2:numel(v)
    if v(k) <= v(k-1)
        v(k) = v(k-1) + eps(v(k-1)+1);
    end
end
end

function [bpZ, bpA, T, info] = build2DLUT_fromTimeSweep( ...
    zWC, steer, y, nZ, nA, varargin)
% build2DLUT_fromTimeSweep
% Create a 2‑D lookup table from time‑based sweep data
% (wheel center height, steering angle -> output)
%
% Nearest extrapolation is used to avoid NaNs at the corners.

% ---------------- Parse inputs ----------------
p = inputParser;
p.addRequired('zWC',   @(v)isnumeric(v) && isvector(v));
p.addRequired('steer', @(v)isnumeric(v) && isvector(v));
p.addRequired('y',     @(v)isnumeric(v) && isvector(v));
p.addRequired('nZ',    @(v)isnumeric(v) && isscalar(v) && v>=2);
p.addRequired('nA',    @(v)isnumeric(v) && isscalar(v) && v>=2);

p.addParameter('GridMethodZ','uniform');
p.addParameter('GridMethodA','uniform');
p.addParameter('DupMethod','mean');
p.addParameter('TolZ',0);
p.addParameter('TolA',0);
p.addParameter('InterpMethod','linear');   % interior interpolation
p.addParameter('MakePlots',false);

p.parse(zWC,steer,y,nZ,nA,varargin{:});
opt = p.Results;

% ---------------- Clean data ----------------
zWC   = zWC(:);
steer = steer(:);
y     = y(:);

valid = isfinite(zWC) & isfinite(steer) & isfinite(y);
zWC = zWC(valid);
steer = steer(valid);
y = y(valid);

info.numOriginal = numel(valid);
info.numDroppedInvalid = sum(~valid);

% ---------------- Quantize (optional) ----------------
if opt.TolZ > 0
    zQ = round(zWC/opt.TolZ)*opt.TolZ;
else
    zQ = zWC;
end

if opt.TolA > 0
    aQ = round(steer/opt.TolA)*opt.TolA;
else
    aQ = steer;
end

% ---------------- Merge duplicate (z,a) points ----------------
ZA = [zQ aQ];
[ZAu,~,g] = unique(ZA,'rows','stable');

switch lower(opt.DupMethod)
    case 'mean'
        yU = accumarray(g,y,[],@mean);
    case 'median'
        yU = accumarray(g,y,[],@median);
    case 'min'
        yU = accumarray(g,y,[],@min);
    case 'max'
        yU = accumarray(g,y,[],@max);
end

zU = ZAu(:,1);
aU = ZAu(:,2);

info.numAfterMerge = numel(yU);

% ---------------- Breakpoints ----------------
switch lower(opt.GridMethodZ)
    case 'uniform'
        bpZ = linspace(min(zU),max(zU),nZ);
    case 'quantile'
        bpZ = quantile(zU,linspace(0,1,nZ));
        bpZ = makeStrictlyIncreasing(bpZ);
end

switch lower(opt.GridMethodA)
    case 'uniform'
        bpA = linspace(min(aU),max(aU),nA);
    case 'quantile'
        bpA = quantile(aU,linspace(0,1,nA));
        bpA = makeStrictlyIncreasing(bpA);
end

bpZ = bpZ(:)';   % row vectors
bpA = bpA(:)';

% ---------------- Interpolant (KEY CHANGE) ----------------
% Linear interpolation inside hull, NEAREST extrapolation outside
F = scatteredInterpolant( ...
        zU, aU, yU, ...
        opt.InterpMethod, ...
        'nearest');   % <<< CHANGED FROM 'none'

% ---------------- Evaluate on grid ----------------
[AA,ZZ] = meshgrid(bpA,bpZ);
T = F(ZZ,AA);

% ---------------- Diagnostics ----------------
info.nanFraction = mean(isnan(T(:)));  % should be zero
info.tableSize = size(T);

% ---------------- Optional plots ----------------
if opt.MakePlots
    figure('Color','w');
    tiledlayout(2,2,'TileSpacing','compact');

    nexttile([1 2])
    scatter(aU,zU,10,yU,'filled');
    xlabel('Steering angle (rad)');
    ylabel('Wheel center height');
    title('Merged samples'); grid on; colorbar;

    nexttile
    surf(AA,ZZ,T,'EdgeColor','none');
    xlabel('Steering angle (rad)');
    ylabel('Wheel center height');
    title('2D LUT surface'); view(35,30); grid on;

    nexttile
    imagesc(bpA,bpZ,T);
    axis xy;
    xlabel('Steering angle (rad)');
    ylabel('Wheel center height');
    title('Lookup table'); colorbar;
end

end

% ---------------- Utility ----------------
function v = makeStrictlyIncreasing(v)
v = v(:);
for k = 2:numel(v)
    if v(k) <= v(k-1)
        v(k) = v(k-1) + eps(v(k-1)+1);
    end
end
end
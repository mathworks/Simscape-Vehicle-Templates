function lut = buildRollCenterLUTzWLzWR(zWL, cpYZL, zWR, cpYZR, opts)
% makeRollCenterLUTzWLzWR
% Create a 2D lookup table that estimates roll center (Y,Z) for any
% combination of wheel center heights (zWL, zWR).
%
% INPUTS
%   zWL   : Nx1 wheel center vertical positions for LEFT (monotonic sweep)
%   cpYZL : Nx2 contact patch [y z] for LEFT at same samples as zWL
%   zWR   : Mx1 wheel center vertical positions for RIGHT (monotonic sweep)
%   cpYZR : Mx2 contact patch [y z] for RIGHT at same samples as zWR
%   opts  : optional struct
%       .Window        odd integer >= 3, local window for circle fit (default 11)
%       .Method        'lsq' (default) or '3pt' (faster, noisier)
%       .SmoothSpan    moving mean span for y/z paths (default 0 = off)
%       .UnitsScale    scale factor for all y,z (default 1.0) e.g. 1e-3 for mm->m
%       .TolParallel   tolerance for near-parallel line intersection (default 1e-10)
%       .BreakpointsL  optional vector of left zW breakpoints (default unique(zWL))
%       .BreakpointsR  optional vector of right zW breakpoints (default unique(zWR))
%       .InterpMethod  'linear' (default) or 'pchip'
%       .ExtrapMethod  'nearest' (default) clamps outside range; or 'none'
%
%   Plotting options (all optional):
%       opts.Plot.Enable            (false default)
%       opts.Plot.Side              "left" or "right" or "both" (default "left")
%       opts.Plot.Index             sample index to inspect (default [] => mid)
%       opts.Plot.ShowWindow        true/false (default true)
%       opts.Plot.ShowRadiusLine    true/false (default true)
%       opts.Plot.LUTSurfaces       true/false (default true)
%       opts.Plot.LUTMask           true/false (default true)
%       opts.Plot.RCOverlay         true/false (default true)  <-- NEW third plot
%       opts.Plot.QueryZWL          scalar (default [] => mid breakpoint)
%       opts.Plot.QueryZWR          scalar (default [] => mid breakpoint)
%
% OUTPUT lut (struct)
%   .bpL, .bpR         breakpoints (left/right wheel center heights)
%   .tableY, .tableZ   2D tables size [numel(bpR) x numel(bpL)]
%   .F_Y, .F_Z         griddedInterpolant objects
%   .eval(zWLq,zWRq)   function handle returns [y z] (same size as inputs)
%   .meta              contains per-side models and options used

    if nargin < 5 || isempty(opts)
        opts = struct();
    end
    opts = defaults(opts);

    % --- Preprocess and scale ---
    [zWL, cpYZL] = prepSweep(zWL, cpYZL, opts.UnitsScale);
    [zWR, cpYZR] = prepSweep(zWR, cpYZR, opts.UnitsScale);

    % Optional smoothing of measured contact patch paths
    if opts.SmoothSpan > 0
        cpYZL(:,1) = smoothdata(cpYZL(:,1),'movmean',opts.SmoothSpan);
        cpYZL(:,2) = smoothdata(cpYZL(:,2),'movmean',opts.SmoothSpan);
        cpYZR(:,1) = smoothdata(cpYZR(:,1),'movmean',opts.SmoothSpan);
        cpYZR(:,2) = smoothdata(cpYZR(:,2),'movmean',opts.SmoothSpan);
    end

    % --- Build per-side radius-line models as functions of wheel center height ---
    leftModel  = buildSideModel(zWL, cpYZL, opts, "left");
    rightModel = buildSideModel(zWR, cpYZR, opts, "right");

    % --- Decide LUT breakpoints ---
    if isfield(opts,'BreakpointsL') && ~isempty(opts.BreakpointsL)
        bpL = opts.BreakpointsL(:)';
    else
        bpL = unique(zWL(:)','stable');
    end

    if isfield(opts,'BreakpointsR') && ~isempty(opts.BreakpointsR)
        bpR = opts.BreakpointsR(:)';
    else
        bpR = unique(zWR(:)','stable');
    end

    % Ensure monotonic increasing breakpoints (required by griddedInterpolant)
    bpL = sort(bpL);
    bpR = sort(bpR);

    % --- Populate 2D tables ---
    [ZL, ZR] = meshgrid(bpL, bpR);      % ZL is nR×nL
    K = numel(ZL);

    Lcoef = leftModel.L_of_zW(ZL(:));   % K×3 [a b c]
    Rcoef = rightModel.L_of_zW(ZR(:));  % K×3 [a b c]

    a1 = Lcoef(:,1); b1 = Lcoef(:,2); c1 = Lcoef(:,3);
    a2 = Rcoef(:,1); b2 = Rcoef(:,2); c2 = Rcoef(:,3);

    det = a1.*b2 - a2.*b1;
    ok = abs(det) >= opts.TolParallel;

    yRC = nan(K,1);
    zRC = nan(K,1);

    yRC(ok) = (c1(ok).*b2(ok) - c2(ok).*b1(ok)) ./ det(ok);
    zRC(ok) = (a1(ok).*c2(ok) - a2(ok).*c1(ok)) ./ det(ok);

    tableY = reshape(yRC, size(ZL));
    tableZ = reshape(zRC, size(ZL));

    % --- Build interpolants for continuous evaluation ---
    lut.bpL = bpL;
    lut.bpR = bpR;
    lut.tableY = tableY;
    lut.tableZ = tableZ;

    lut.F_Y = griddedInterpolant({bpR, bpL}, tableY, opts.InterpMethod, opts.ExtrapMethod);
    lut.F_Z = griddedInterpolant({bpR, bpL}, tableZ, opts.InterpMethod, opts.ExtrapMethod);

    % Query function
    lut.eval = @(zWLq,zWRq) evalLUT(lut, zWLq, zWRq);

    lut.meta.leftModel = leftModel;
    lut.meta.rightModel = rightModel;
    lut.meta.optionsUsed = opts;
    lut.meta.invalidFraction = mean(~isfinite(yRC) | ~isfinite(zRC));

    % --- Optional plots ---
    if isPlotEnabled(opts)
        if opts.Plot.LUTSurfaces
            plotLUTSurfaces(bpL, bpR, tableY, tableZ);
        end
        if opts.Plot.LUTMask
            plotLUTMask(bpL, bpR, tableY, tableZ);
        end
        if opts.Plot.RCOverlay
            % Default query points = mid breakpoints unless user overrides
            zWLq = opts.Plot.QueryZWL;
            zWRq = opts.Plot.QueryZWR;
            if isempty(zWLq), zWLq = bpL(round(numel(bpL)/2)); end
            if isempty(zWRq), zWRq = bpR(round(numel(bpR)/2)); end

            plotRadiusLinesAndIntersection(leftModel, rightModel, zWLq, zWRq, opts);
        end
    end
end

% ===================== helper functions =====================

function tf = isPlotEnabled(opts)
    tf = isfield(opts,'Plot') && isfield(opts.Plot,'Enable') && opts.Plot.Enable;
end

function opts = defaults(opts)
    if ~isfield(opts,'Window'),       opts.Window = 11; end
    if mod(opts.Window,2)==0, opts.Window = opts.Window+1; end
    if opts.Window < 3, opts.Window = 3; end
    if ~isfield(opts,'Method'),       opts.Method = 'lsq'; end
    if ~isfield(opts,'SmoothSpan'),   opts.SmoothSpan = 0; end
    if ~isfield(opts,'UnitsScale'),   opts.UnitsScale = 1.0; end
    if ~isfield(opts,'TolParallel'),  opts.TolParallel = 1e-10; end
    if ~isfield(opts,'InterpMethod'), opts.InterpMethod = 'linear'; end % or 'pchip'
    if ~isfield(opts,'ExtrapMethod'), opts.ExtrapMethod = 'nearest'; end % clamp

    % Plotting / diagnostics
    if ~isfield(opts,'Plot'), opts.Plot = struct(); end
    if ~isfield(opts.Plot,'Enable'),         opts.Plot.Enable = false; end
    if ~isfield(opts.Plot,'Side'),           opts.Plot.Side = "left"; end   % "left","right","both"
    if ~isfield(opts.Plot,'Index'),          opts.Plot.Index = []; end      % [] => mid
    if ~isfield(opts.Plot,'ShowWindow'),     opts.Plot.ShowWindow = true; end
    if ~isfield(opts.Plot,'ShowRadiusLine'), opts.Plot.ShowRadiusLine = true; end
    if ~isfield(opts.Plot,'LUTSurfaces'),    opts.Plot.LUTSurfaces = true; end
    if ~isfield(opts.Plot,'LUTMask'),        opts.Plot.LUTMask = true; end

    % NEW: overlay plot of both radius lines and intersection
    if ~isfield(opts.Plot,'RCOverlay'),      opts.Plot.RCOverlay = true; end
    if ~isfield(opts.Plot,'QueryZWL'),       opts.Plot.QueryZWL = []; end
    if ~isfield(opts.Plot,'QueryZWR'),       opts.Plot.QueryZWR = []; end
end

function [zW, cpYZ] = prepSweep(zW, cpYZ, scale)
    zW = zW(:);
    cpYZ = cpYZ(:,1:2);

    if size(cpYZ,1) ~= numel(zW)
        error('zW and cpYZ must have the same number of samples.');
    end

    % Remove rows with NaNs
    ok = isfinite(zW) & all(isfinite(cpYZ),2);
    zW = zW(ok);
    cpYZ = cpYZ(ok,:);

    % Scale y/z (not scaling zW; typically zW already in same units as z)
    cpYZ = cpYZ * scale;

    if numel(zW) < 3
        error('Need at least 3 samples per side.');
    end

    % Make increasing
    if zW(1) > zW(end)
        zW = flipud(zW);
        cpYZ = flipud(cpYZ);
    end

    % Enforce uniqueness in zW (required for griddedInterpolant)
    [zWuniq, ia] = unique(zW,'stable');
    cpYZ = cpYZ(ia,:);
    zW = zWuniq;

    % Sort (handles small non-monotonic noise)
    [zW, is] = sort(zW);
    cpYZ = cpYZ(is,:);
end

function side = buildSideModel(zW, cpYZ, opts, sideName)
    y = cpYZ(:,1);
    z = cpYZ(:,2);
    N = numel(zW);

    % Instantaneous center estimate at each sample via local circle fit on (y,z)
    IC = nan(N,2);
    fitErr = nan(N,1);
    halfW = floor(opts.Window/2);

    for i = 1:N
        i1 = max(1,i-halfW);
        i2 = min(N,i+halfW);
        pts = [y(i1:i2), z(i1:i2)];
        if size(pts,1) < 3, continue; end

        if strcmpi(opts.Method,'3pt')
            if i<=1 || i>=N, continue; end
            [c, e] = circumcenter3pt([y(i-1) z(i-1)], [y(i) z(i)], [y(i+1) z(i+1)]);
        else
            [c, ~, e] = fitCircleLSQ(pts);
        end

        IC(i,:) = c;
        fitErr(i) = e;
    end

    % Line coefficients through contact patch point and IC: a*y + b*z = c
    % Fallback: if IC invalid, use normal to local tangent as a "radius line"
    Lcoef = nan(N,3);
    for i = 1:N
        if all(isfinite(IC(i,:)))
            Lcoef(i,:) = lineFrom2Pts([y(i) z(i)], IC(i,:));
        else
            iPrev = max(1,i-1);
            iNext = min(N,i+1);
            dy = y(iNext) - y(iPrev);
            dz = z(iNext) - z(iPrev);
            if hypot(dy,dz) < 1e-12
                continue;
            end
            a = -dz;          % coefficient on Y
            b =  dy;          % coefficient on Z
            c0 = a*y(i) + b*z(i);
            Lcoef(i,:) = [a b c0];
        end
    end

    ok = all(isfinite([IC Lcoef]),2);
    % Debugging
    %fprintf('buildSideModel(%s): total=%d, valid=%d, zW span=%g\n', ...
    %    sideName, N, nnz(ok), max(zW)-min(zW));

    zWok = zW(ok);
    if numel(zWok) < 2
        error('Too few valid samples for interpolant on %s: valid=%d of %d. Increase Window/SmoothSpan or check data.', ...
              sideName, nnz(ok), N);
    end

    % Build interpolants vs wheel center height (Values are N×M)
    side.IC_of_zW = griddedInterpolant(zWok, IC(ok,:),    'pchip', 'nearest');   % N×2
    side.L_of_zW  = griddedInterpolant(zWok, Lcoef(ok,:), 'pchip', 'nearest');   % N×3

    % NEW: also create interpolant for patch point vs zW so overlay plot can mark points
    side.P_of_zW  = griddedInterpolant(zW, cpYZ, 'pchip', 'nearest');           % N×2

    side.zWmin = min(zWok);
    side.zWmax = max(zWok);
    side.fitErr = fitErr;

    % Store raw data for debugging/plotting
    side.name = sideName;
    side.zW = zW;
    side.cpYZ = cpYZ;
    side.IC = IC;
    side.Lcoef = Lcoef;
    side.ok = ok;

    % Optional per-side diagnostic plot
    if isPlotEnabled(opts)
        if opts.Plot.Side == "both" || opts.Plot.Side == sideName
            plotSideDiagnostics(side, opts);
        end
    end
end

function plotSideDiagnostics(side, opts)
    zW = side.zW;
    cpYZ = side.cpYZ;
    IC = side.IC;
    ok = side.ok;

    y = cpYZ(:,1);
    z = cpYZ(:,2);
    N = numel(zW);

    i = opts.Plot.Index;
    if isempty(i)
        i = round(N/2);
    end
    i = max(1, min(N, i));

    % If the chosen point isn't valid, move to nearest valid
    if ~ok(i)
        validIdx = find(ok);
        if isempty(validIdx)
            warning('No valid points to plot for side %s.', side.name);
            return;
        end
        [~,k] = min(abs(validIdx - i));
        i = validIdx(k);
    end

    halfW = floor(opts.Window/2);
    i1 = max(1, i-halfW);
    i2 = min(N, i+halfW);

    figure('Name',sprintf('RC Diagnostics: %s side', side.name));
    tiledlayout(1,2,'Padding','compact','TileSpacing','compact');

    % Plot 1: path + selected sample + IC + radius line + local window
    nexttile; hold on; grid on; axis equal;
    plot(y, z, 'k.-', 'DisplayName','Contact patch path');

    if opts.Plot.ShowWindow
        plot(y(i1:i2), z(i1:i2), 'o', 'Color',[0.3 0.3 1], ...
            'DisplayName',sprintf('Fit window [%d:%d]', i1,i2));
    end

    plot(y(i), z(i), 'ro', 'MarkerSize',8, 'LineWidth',1.5, ...
        'DisplayName',sprintf('Sample i=%d (zW=%.4g)', i, zW(i)));

    if all(isfinite(IC(i,:)))
        plot(IC(i,1), IC(i,2), 'bx', 'MarkerSize',10, 'LineWidth',2, ...
            'DisplayName','Instantaneous center (IC)');

        if opts.Plot.ShowRadiusLine
            plot([y(i) IC(i,1)], [z(i) IC(i,2)], 'b-', 'LineWidth',1.5, ...
                'DisplayName','Radius line (P->IC)');
        end
    else
        text(y(i), z(i), '  IC=NaN', 'Color','r', 'FontWeight','bold');
    end

    xlabel('Y (lateral)');
    ylabel('Z (vertical)');
    title(sprintf('Path + IC + Radius line (%s)', side.name));
    legend('Location','best');

    % Plot 2: validity vs zW
    nexttile; hold on; grid on;
    plot(zW, double(ok), 'k.', 'DisplayName','valid (finite IC & Lcoef)');
    ylim([-0.1 1.1]);
    xlabel('zW');
    ylabel('valid');
    title(sprintf('Validity vs zW (%s)', side.name));
    legend('Location','best');
end

function RC = evalLUT(lut, zWLq, zWRq)
    % Evaluate continuous LUT at query wheel center heights
    if isscalar(zWLq) && ~isscalar(zWRq), zWLq = zWLq + zeros(size(zWRq)); end
    if isscalar(zWRq) && ~isscalar(zWLq), zWRq = zWRq + zeros(size(zWLq)); end

    if ~isequal(size(zWLq), size(zWRq))
        error('zWLq and zWRq must be same size or scalar-expandable.');
    end

    y = lut.F_Y(zWRq, zWLq);
    z = lut.F_Z(zWRq, zWLq);

    RC = cat(ndims(y)+1, y, z); % last dimension holds [y z]
end

function [center, radius, rmsErr] = fitCircleLSQ(pts)
    y = pts(:,1); z = pts(:,2);
    A = [y z ones(size(y))];
    bb = -(y.^2 + z.^2);
    x = A\bb; % [D;E;F]
    D = x(1); E = x(2); F = x(3);
    a = -D/2; b0 = -E/2;
    r2 = a^2 + b0^2 - F;

    if r2 <= 0 || any(~isfinite([a b0 r2]))
        center = [NaN NaN]; radius = NaN; rmsErr = NaN; return;
    end

    radius = sqrt(r2);
    center = [a b0];
    rHat = sqrt((y-a).^2 + (z-b0).^2);
    rmsErr = sqrt(mean((rHat - radius).^2));
end

function [center, rmsErr] = circumcenter3pt(p1,p2,p3)
    x1=p1(1); y1=p1(2);
    x2=p2(1); y2=p2(2);
    x3=p3(1); y3=p3(2);

    d = 2*(x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2));
    if abs(d) < 1e-12
        center = [NaN NaN]; rmsErr = NaN; return;
    end

    ux = ((x1^2+y1^2)*(y2-y3) + (x2^2+y2^2)*(y3-y1) + (x3^2+y3^2)*(y1-y2)) / d;
    uy = ((x1^2+y1^2)*(x3-x2) + (x2^2+y2^2)*(x1-x3) + (x3^2+y3^2)*(x2-x1)) / d;

    center = [ux uy];

    r1 = hypot(x1-ux,y1-uy);
    r2 = hypot(x2-ux,y2-uy);
    r3 = hypot(x3-ux,y3-uy);
    r = mean([r1 r2 r3]);
    rmsErr = sqrt(mean(([r1 r2 r3] - r).^2));
end

function L = lineFrom2Pts(pA, pB)
    % Line in form a*y + b*z = c
    y1 = pA(1); z1 = pA(2);
    y2 = pB(1); z2 = pB(2);
    a = (z2 - z1);
    b = -(y2 - y1);
    c = a*y1 + b*z1;
    L = [a b c];
end

function plotLUTSurfaces(bpL, bpR, tableY, tableZ)
    figure('Name','Roll Center 2D LUT Surfaces');
    tiledlayout(1,2,'Padding','compact','TileSpacing','compact');

    [ZL, ZR] = meshgrid(bpL, bpR);

    nexttile;
    surf(ZL, ZR, tableY, 'EdgeColor','none');
    xlabel('zW\_L'); ylabel('zW\_R'); zlabel('RC\_y');
    title('RC\_y(zW\_L, zW\_R)');
    colorbar; view(135,30); grid on;

    nexttile;
    surf(ZL, ZR, tableZ, 'EdgeColor','none');
    xlabel('zW\_L'); ylabel('zW\_R'); zlabel('RC\_z');
    title('RC\_z(zW\_L, zW\_R)');
    colorbar; view(135,30); grid on;
end

function plotLUTMask(bpL, bpR, tableY, tableZ)
    figure('Name','Roll Center LUT Invalid/NaN Mask');
    mask = ~(isfinite(tableY) & isfinite(tableZ)); % 1 where invalid
    imagesc(bpL, bpR, mask);
    set(gca,'YDir','normal');
    xlabel('zW\_L'); ylabel('zW\_R');
    title('Invalid LUT cells (1 = invalid/NaN)');
    colormap(gray); colorbar;
end

% ===================== NEW THIRD PLOT =====================

function plotRadiusLinesAndIntersection(leftModel, rightModel, zWLq, zWRq, opts)
% Overlay left/right radius lines in Y–Z plane and show intersection.

    % Evaluate contact patch points and instantaneous centers at query heights
    PL = leftModel.P_of_zW(zWLq);   % 1×2 [y z]
    PR = rightModel.P_of_zW(zWRq);  % 1×2 [y z]

    ICL = leftModel.IC_of_zW(zWLq); % 1×2 [y z]
    ICR = rightModel.IC_of_zW(zWRq);

    % Evaluate line coefficients a*y + b*z = c
    L1 = leftModel.L_of_zW(zWLq);   % 1×3
    L2 = rightModel.L_of_zW(zWRq);  % 1×3

    a1=L1(1); b1=L1(2); c1=L1(3);
    a2=L2(1); b2=L2(2); c2=L2(3);

    det = a1*b2 - a2*b1;

    % Compute intersection (if not near-parallel)
    yRC = NaN; zRC = NaN; isOK = abs(det) >= opts.TolParallel;
    if isOK
        yRC = (c1*b2 - c2*b1) / det;
        zRC = (a1*c2 - a2*c1) / det;
    end

    % Determine plotting bounds from the measured paths (for nicer axis limits)
    yAll = [leftModel.cpYZ(:,1); rightModel.cpYZ(:,1)];
    zAll = [leftModel.cpYZ(:,2); rightModel.cpYZ(:,2)];
    yMin = min(yAll); yMax = max(yAll);
    zMin = min(zAll); zMax = max(zAll);
    yPad = 0.1*(yMax-yMin + eps);
    zPad = 0.1*(zMax-zMin + eps);

    yPlot = linspace(yMin-yPad, yMax+yPad, 200);

    % Convert each line to z(y) when possible
    [yLline, zLline] = lineToYZ(a1,b1,c1, yPlot, yMin-yPad, yMax+yPad, zMin-zPad, zMax+zPad);
    [yRline, zRline] = lineToYZ(a2,b2,c2, yPlot, yMin-yPad, yMax+yPad, zMin-zPad, zMax+zPad);

    figure('Name','Radius Lines + Intersection (Roll Center)');
    hold on; grid on; axis equal;

    % Plot paths
    plot(leftModel.cpYZ(:,1),  leftModel.cpYZ(:,2),  'b.-', 'DisplayName','Left CP path');
    plot(rightModel.cpYZ(:,1), rightModel.cpYZ(:,2), 'r.-', 'DisplayName','Right CP path');

    % Plot query points
    plot(PL(1), PL(2), 'bo', 'MarkerSize',8, 'LineWidth',1.5, ...
        'DisplayName',sprintf('Left CP @ zW_L=%.4g', zWLq));
    plot(PR(1), PR(2), 'ro', 'MarkerSize',8, 'LineWidth',1.5, ...
        'DisplayName',sprintf('Right CP @ zW_R=%.4g', zWRq));

    % Plot ICs (if finite)
    if all(isfinite(ICL))
        plot(ICL(1), ICL(2), 'bx', 'MarkerSize',10, 'LineWidth',2, ...
            'DisplayName','Left IC');
        if opts.Plot.ShowRadiusLine
            plot([PL(1) ICL(1)], [PL(2) ICL(2)], 'b-', 'LineWidth',1.5, ...
                'HandleVisibility','off');
        end
    end
    if all(isfinite(ICR))
        plot(ICR(1), ICR(2), 'rx', 'MarkerSize',10, 'LineWidth',2, ...
            'DisplayName','Right IC');
        if opts.Plot.ShowRadiusLine
            plot([PR(1) ICR(1)], [PR(2) ICR(2)], 'r-', 'LineWidth',1.5, ...
                'HandleVisibility','off');
        end
    end

    % Plot infinite radius lines (clipped to plot bounds)
    plot(yLline, zLline, 'b--', 'LineWidth',2, 'DisplayName','Left radius line');
    plot(yRline, zRline, 'r--', 'LineWidth',2, 'DisplayName','Right radius line');

    % Plot intersection
    if isOK && isfinite(yRC) && isfinite(zRC)
        plot(yRC, zRC, 'k*', 'MarkerSize',10, 'LineWidth',2, ...
            'DisplayName','Intersection (Roll Center)');
    else
        text(mean([yMin yMax]), mean([zMin zMax]), ...
            'Lines nearly parallel / no stable intersection', ...
            'Color','k','FontWeight','bold');
    end

    xlabel('Y (lateral)');
    ylabel('Z (vertical)');
    title(sprintf('Radius lines + intersection at (zW_L=%.4g, zW_R=%.4g)', zWLq, zWRq));
    xlim([yMin-yPad yMax+yPad]);
    ylim([zMin-zPad zMax+zPad]);
    legend('Location','best');
    hold off;
end

function [yLine, zLine] = lineToYZ(a,b,c, yPlot, yMin, yMax, zMin, zMax)
% Convert a*y + b*z = c to line points, clipped for display.

    epsB = 1e-12;

    if abs(b) > epsB
        % z = (c - a*y)/b
        yLine = yPlot;
        zLine = (c - a*yPlot) / b;
        % clip to z bounds
        keep = isfinite(zLine) & zLine>=zMin & zLine<=zMax & yLine>=yMin & yLine<=yMax;
        yLine = yLine(keep);
        zLine = zLine(keep);
    else
        % Vertical line in Y: a*y = c
        if abs(a) < 1e-12
            yLine = NaN; zLine = NaN;
            return;
        end
        y0 = c / a;
        yLine = y0 * ones(1,200);
        zLine = linspace(zMin, zMax, 200);
        keep = y0>=yMin && y0<=yMax;
        if ~keep
            yLine = NaN; zLine = NaN;
        end
    end
end
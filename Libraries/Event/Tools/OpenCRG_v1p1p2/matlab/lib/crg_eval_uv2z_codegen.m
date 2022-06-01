function [pz, data] = crg_eval_uv2z(data, puv)
%CRG_EVAL_UV2Z Evaluate z at grid position.
%   [PZ, DATA] = CRG_EVAL_UV2Z(DATA, PUV) evaluates the z-values at
%   the given u/v-positions.
%
%   Inputs:
%       DATA    struct array as defined in CRG_INTRO.
%       PUV     (np, 2) array of points in u/v-system
%
%   Outputs:
%       PZ      (np) vector of z-values
%       DATA    struct array as defined in CRG_INTRO.
%
%   Examples:
%   pz = crg_eval_uv2z(data, puv) 
%       Evaluates the z-values at the given u/v-positions.
%
%   See also CRG_INTRO.

% *****************************************************************
% ASAM OpenCRG Matlab API
%
% OpenCRG version:           1.2.0
%
% package:               lib
% file name:             crg_eval_uv2z.m 
% author:                ASAM e.V.
%
%
% C by ASAM e.V., 2020
% Any use is limited to the scope described in the license terms.
% The license terms can be viewed at www.asam.net/license
%
% More Information on ASAM OpenCRG can be found here:
% https://www.asam.net/standards/detail/opencrg/
%
% *****************************************************************

%% check if already successfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% for closed reference line: map u-values to valid interval

if data.opts.rflc==1 && data.dved.ulex~=0
    puv(:,1) = mod(puv(:,1)-data.dved.ubex, data.dved.ulex) + data.dved.ubex;
end

%% simplify data access

np = size(puv, 1);

bdmu = data.opts.bdmu;
bdmv = data.opts.bdmv;
bdou = data.opts.bdou;
bdov = data.opts.bdov;
bdss = data.opts.bdss;
bdse = data.opts.bdse;

ubeg = data.head.ubeg;
uend = data.head.uend;
uinc = data.head.uinc;
ulen = uend - ubeg;
ule2 = ulen * 2;

vmin = data.head.vmin;
vmax = data.head.vmax;
if isfield(data.head, 'vinc')
    vinc = data.head.vinc;
    v = 0; % Sam change for code-gen
else
    vinc = 0;
    v = data.v;
end
vwid = vmax - vmin;
vwi2 = vwid * 2;

zbeg = data.head.zbeg;
zend = data.head.zend;
sbeg = data.head.sbeg;
bbeg = data.head.bbeg;

z = data.z;
[nu nv] = size(z);
nvm1 = nv - 1;

if isfield(data, 'rz')
    rz = data.rz;
    nrz = length(rz);
else
    nrz = 0;
end

if isfield(data, 'b')
    b = data.b;
    nb = length(b);
else
    nb = 0;
end

%% pre-allocate output

pz = zeros(np, 1);

%% work on all points

for ip = 1 : np
    pui = puv(ip, 1);
    pvi = puv(ip, 2);

    % repeat/reflect border mode maps u-value into [ubeg uend] interval
    switch bdmu % border_mode_u
        case 3 % repeat
            pui = mod(pui-ubeg, ulen) + ubeg;
        case 4 % reflect
            pui = mod(pui-ubeg, ule2);
            if pui > ulen, pui = ule2 - pui; end
            pui = pui + ubeg;
    end

    % repeat/reflect border mode maps v-value into [vmin vmax] interval
    switch bdmv % border_mode_v
        case 3 % repeat
            pvi = mod(pvi-vmin, vwid) + vmin;
        case 4 % reflect
            pvi = mod(pvi-vmin, vwi2);
            if pvi > vwid, pvi = vwi2 - pvi; end
            pvi = pvi + vmin;
    end

    % find u-interval in constantly spaced u-axis
    ui = (pui - ubeg) / uinc;
    iu = min(max(0, floor(ui)), nu-2); % find u interval
    du = ui-iu;
    ui = min(max(0, du), 1); % limit to [0 1] border interval
    iu = iu + 1; % MATLAB counts from 1

    if vinc ~= 0
        % find v-interval in constanty spaced v-axis
        vi = (pvi - vmin) / vinc;
        iv = min(max(0, floor(vi)), nv-2); % find v-interval
        dv = vi-iv;
        vi = min(max(0, dv), 1); % limit to [0 1] border interval
        iv = iv + 1; % MATLAB counts from 1
    else
        % find v-interval in variably spaced v-axis
        i0 = nvm1;
        iv = 0;
        while 1
            im = floor((iv+i0)/2);
            if im > iv
                if pvi <  v(im+1)
                    i0 = im;
                else
                    iv = im;
                end
            else
                break
            end
        end
        iv = iv + 1; % MATLAB counts from 1
        dv = (pvi-v(iv))/(v(iv+1)-v(iv));
        vi = min(max(0, dv), 1);
    end

    % evaluate z(u, v) by bilinear interpolation
    z00 = double(z(iu  , iv  ));
    z10 = double(z(iu+1, iv  )) - z00;
    z01 = double(z(iu  , iv+1));
    z11 = double(z(iu+1, iv+1)) - (z10 + z01);
    z01 = z01 - z00;

    % Change SteveM. - piz, bdou, and bdou need constant types for codegen
    % Original code had different types for even/uneven v vector
    % Code now ensures all three quantities are type single
    %piz = (z11*vi + z10)*ui + z01*vi + z00;
    pizd = (z11*vi + z10)*ui + z01*vi + z00;
    piz  = single(pizd);

    % add slope
    if nrz > 0
        piz = piz + rz(iu) + ui*(rz(iu+1)-rz(iu));
    else
        piz = piz + zbeg + (min(max(ubeg, pui), uend)-ubeg)*sbeg;
    end

    % add banking
    if nb > 1
        pib = b(iu) + ui*(b(iu+1)-b(iu));
    else
        pib = bbeg;
    end
    piz = piz + min(max(vmin, pvi), vmax)*pib;

    % extrapolating border mode in u-direction
    if ui ~= du % ui was limited to [0 1] border interval
        switch bdmu % border_mode_u
            case 1 % set zero
                %piz = bdou; 
                piz = single(bdou); % Change SteveM - codegen
            case 2 % keep last
                %piz = piz + bdou;
                piz = piz + single(bdou); % Change SteveM - codegen
        end
    end

    % extrapolating border mode in v-direction
    if vi ~= dv % vi was limited to [0 1] border interval
        switch bdmv % border_mode_v
            case 1 % set zero
                %piz = bdov;
                piz = single(bdov);
            case 2 % keep last
                %piz = piz + bdov;
                piz = piz + single(bdov);
        end
    end

    % smoothing zone at start
    urel = max(0, pui-ubeg);
    if bdss>urel % inside smoothing zone
        piz = urel/bdss*(piz-zbeg) + zbeg;
    end

    % smoothing zone at end
    urel = max(0, uend-pui);
    if bdse>urel % inside smoothing zone
        piz = urel/bdse*(piz-zend) + zend;
    end

    if (bdmu==0 && ui~=du) || (bdmv==0 && vi~=dv) % NaN border mode and ui or vi was outside [0 1] border interval
        pz(ip) = NaN;
    else
        pz(ip) = piz;
    end
end

end

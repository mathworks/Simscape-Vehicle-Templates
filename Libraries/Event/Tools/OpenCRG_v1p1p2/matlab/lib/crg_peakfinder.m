function [ pindex, pij] = crg_peakfinder( data, iu, iv, th, ra )
% CRG_PEAKFINDER detects peaks at a CRG file.
%   [PINDEX, PIJ] = CRG_PEAKFINDER(DATA, IU, IV, TH, RA) returns
%   positons of peaks.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   IU      U index for subpatch selection (default: full CRG)
%           IU(1): longitudinal start index
%           IU(2): longitudinal end index
%   IV      V index for subpatch selection (default: full CRG)
%           IV(1): lateral start index
%           IV(2): lateral end index
%   TH      threshold detecting edges [0,1]
%   RA      range of peak finding mask size
%
%   Outputs:
%   PINDEX  peak index
%   PIJ     peak position [u,v]
%
%   Examples:
%   [pindex, pij] = crg_peakfinder(data, iu, iv, th)
%       CRG peak detection.
%   See also CRG_INTRO.

%   Copyright 2005-2010 OpenCRG - VIRES Simulationstechnologie GmbH - Holger Helmich
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
%
%   More Information on OpenCRG open file formats and tools can be found at
%
%       http://www.opencrg.org
%
%   $Id: crg_peakfinder.m 22 2009-08-21 10:25:32Z helmich $

%% default

[nu nv] = size(data.z);

if nargin < 5 || isempty(ra), ra = 3; end
if nargin < 4 || isempty(th), th = 0.5; end
if nargin < 3 || isempty(iu), iu = [1 nu]; end
if nargin < 2 || isempty(iv), iv = [1 nv]; end

if length(iu) < 2, iu = [iu, nu]; end
if length(iv) < 2, iv = [iv, nv]; end

%% check/complement optional arguments

if iu(1)<1 || iu(1) >= iu(2) || iu(2) > nu
    error('CRG:peakFinderError', 'illegal IU index values iu=[%d %d] with nu=%d', iu(1), iu(2), nu);
end

if iv(1)<1 || iv(1) >= iv(2) || iv(2) > nv
    error('CRG:peakFinderError', 'illegal IV index values iv=[%d %d] with nv=%d', iv(1), iv(2), nv);
end

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% build uv

ubeg = data.head.ubeg + data.head.uinc*(iu(1)-1);
uend = data.head.ubeg + data.head.uinc*(iu(2)-1);
uinc = data.head.uinc;
u = ubeg:uinc:uend;

if isfield(data.head, 'vinc')
    vmin = data.head.vmin + data.head.vinc*(iv(1)-1);
    vmax = data.head.vmin + data.head.vinc*(iv(2)-1);
    vinc = data.head.vinc;
    v = vmin:vinc:vmax;
else
    v = data.v(iv(1):iv(2));
end

%% get necessary z-value patch

[xu, xv] = meshgrid(u, v);

pz = crg_eval_uv2z(data, [xu(:), xv(:)]);

pz = reshape(pz, size(xu,1), size(xu,2));

clear xu xv;

%% find edges
% edges can indicate a peak, as long as only peaks far away are required.
% using fast image filtering on matrix to find relevant areas

pindex = crg_peakfinder_laplacian(pz, th);

%% find peak positions

pindex = crg_peakfinder_peak(pz, pindex, ra);

[in,jn] = ind2sub(size(pz), pindex);        % local u,v-coord

pij = [jn+iu(1)-1, in+iv(1)-1];             % global u,v-coord

end % function crg_peakfinder

function [ds] = crg_peakfinder_peak(z, pindex, ra)
% CRG_PEAKFINDER_PEAK
%   using median to find peak positions in sub patch
%
%   Inputs:
%   Z       sample data (local)
%   pindex  relevant peak edge points (local)
%   ra      filter size in one direction
%           should be bigger than expected peak size
%
%   Outputs:
%   DS      peak index
%
%   Examples:
%   ds = crg_peakfinder_peak(z, th)

[j,i] = ind2sub(size(z), pindex);        % local u,v-coord
cm = zeros(size(z));

i(i+ra > size(z,2)) = size(z,2)-ra-1; % fit search area to size(z)
i(i-ra < 1) = ra+1;
j(j+ra > size(z,1)) = size(z,1)-ra-1;
j(j-ra < 1) = ra+1;

for k=1:length(pindex)                  % for each point
    zi = z(j(k)-ra:j(k)+ra,i(k)-ra:i(k)+ra);
    mv = max(median(zi(:)), 0.05);
    cm(j(k)-ra:j(k)+ra,i(k)-ra:i(k)+ra) = cm(j(k)-ra:j(k)+ra,i(k)-ra:i(k)+ra) + ...
                (abs(zi) > mv + abs(mv));
end

ds = find(cm > 0);

end % function crg_peakfinder_peak


function [ds] = crg_peakfinder_laplacian(z, th)
% CRG_PEAKFINDER_LAPLACIAN
%   using laplacian filter to find edges of peaks
%
%   Inputs:
%   Z       sample data
%   TH      threshold
%
%   Outputs:
%   DS      peak index
%
%   Examples:
%   ds = crg_peakfinder_laplacian(z, th)

% Laplacian filter mask (edge detector incl. 45deg)
a = [-1 -1 -1;
     -1  8 -1;
     -1 -1 -1 ];

a = a*10;                           % peaks should get more attention

zi = filter2(a, abs(z), 'valid');   % filter image/matrix

zi = [zeros(1,size(zi,2)); zi; zeros(1,size(zi,2))]; % add cut off edges
zi = [zeros(size(zi,1),1), zi, zeros(size(zi,1),1)];

ds = find(zi > th);                 % find index

end % function crg_peakfinder_laplacian

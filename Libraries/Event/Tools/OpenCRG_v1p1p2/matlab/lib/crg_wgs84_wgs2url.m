function [url] = crg_wgs84_wgs2url(wgs, opts)
%CRG_WGS84_WGS2URL CRG generate url string to show wgs info
%   [URL] = CRG_WGS84_WGS2URL(WGS, OPTS) generates url string
%   to show WGS84 coordinates.
%
%   Inputs:
%   WGS     (np, 2) arrays of latitude/longitude (north/east) wgs84
%           coordinate pairs (in degrees)
%   OPTS    stuct for method options (optional, no default)
%   .label  sets label comment text (default: 'OpenCRG road mark')
%
%   Outputs:
%   URL     url string (for np=1) or struct of strings (for np>1)
%
%   Examples:
%   wgs = [51.477811,-0.001475]  % Greenwich Prime Meridian
%                                % (Airy's Transit Circle)
%   url = crg_wgs84_wgs2url(wgs) % generate url sting
%   web(url, '-browser')         % show url in default browser
%   generate url string to show wgs info in
%
%   See also CRG_INTRO.

%   Copyright 2005-2009 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_wgs84_wgs2url.m 184 2010-09-22 07:41:39Z jorauh $

%% handle optional args

if nargin < 2
    opts = struct;
end

if isfield(opts, 'label')
    label = opts.label;
else
    label = 'OpenCRG road mark';
end
label = strrep(label, ' ', '+'); % replace blanks by '+' for url string

%% generate url string

np = size(wgs, 1);

if np == 1
    url = sprintf('http://maps.google.com/maps?q=%.6f,%.6f(%s)', wgs(1,1), wgs(1,2), label);
else
    for i = 1:np
        url{i} = sprintf('http://maps.google.com/maps?q=%.6f,%.6f(%s)', wgs(i,1), wgs(i,2), label); %#ok<AGROW>
    end
end

end

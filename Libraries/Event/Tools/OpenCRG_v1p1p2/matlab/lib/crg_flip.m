function [data] = crg_flip(data)
% CRG_FLIP flip CRG data structure.
%   DATA = CRG_FLIP(DATA) flips a CRG data structure, i.e. swaps start
%   and end, while leaving the mods and opts sub-structures untouched.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Examples:
%   crg = crg_flip(crg)
%       flips the CRG contents.

%   Copyright 2011 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_flip.m 236 2011-03-01 07:28:44Z jorauh $


data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

%% keep everything

dat0 = data;

%% flip elevation grid

data.z = dat0.z(end:-1:1, end:-1:1);


%% flip vectors

if length(dat0.v) > 1
    data.v = -dat0.v(end:-1:1);
end
if isfield(dat0, 'p')
    data.p = angle(-exp(i*dat0.p(end:-1:1)));
end
if isfield(dat0, 's')
    data.s = -dat0.s(end:-1:1);
end
if isfield(dat0, 'b')
    data.b = -dat0.b(end:-1:1);
end

%% flip head data

data.head.vmin = -dat0.head.vmax;
data.head.vmax = -dat0.head.vmin;

data.head.xbeg = dat0.head.xend;
data.head.ybeg = dat0.head.yend;
data.head.zbeg = dat0.head.zend;
data.head.xend = dat0.head.xbeg;
data.head.yend = dat0.head.ybeg;
data.head.zend = dat0.head.zbeg;

data.head.sbeg = -dat0.head.send;
data.head.send = -dat0.head.sbeg;

data.head.bbeg = -dat0.head.bend;
data.head.bend = -dat0.head.bbeg;

data.head.pbeg = angle(-exp(i*dat0.head.pend));
data.head.pend = angle(-exp(i*dat0.head.pbeg));

% WGS84: beg or beg/end allowed, end only not allowed
if isfield(dat0.head, 'eend')
    data.head.ebeg = dat0.head.eend;
    data.head.nbeg = dat0.head.nend;
    if isfield(dat0.head, 'ebeg')
        data.head.eend = dat0.head.ebeg;
        data.head.nend = dat0.head.nbeg;
    else
        warning('crg:flipWarning', 'WGS84 start lon/lat removed')
    end
end
if isfield(dat0.head, 'aend')
    data.head.abeg = dat0.head.aend;
    if isfield(dat0.head, 'abeg')
        data.head.aend = dat0.head.abeg;
    else
         warning('crg:flipWarning', 'WGS84 start altitude removed')
    end
end

%% add timestamp

if ~isfield(data, 'struct')
    data.struct = cell(1,0);
end
data.struct{end+1} = ...
    sprintf('* flipped by %s at %s', mfilename, datestr(now, 31));

%% check again

data = crg_check(data);

end

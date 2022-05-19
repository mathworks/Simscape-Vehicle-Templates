function [data] = crg_single(data)
%CRG_SINGLE single type conversion of core data.
%   [DATA] = CRG_SINGLE(DATA) makes CRG data type conversion to
%   single for core data vectors and arrays as far as not already done.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO.
%
%   Outputs:
%   DATA    struct array with updated contents.
%
%   Examples:
%   data = crg_single(data);
%       converts CRG core data to single type.
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
%   $Id: crg_single.m 184 2010-09-22 07:41:39Z jorauh $


%% convert core vectors and arrays to single type

% core elevation grid data
if isfield(data, 'z'), data.z = single(data.z); end
if isfield(data, 'v'), data.v = single(data.v); end
if isfield(data, 'b'), data.b = single(data.b); end

% core reference line data
if isfield(data, 'u'), data.u = single(data.u); end
if isfield(data, 'p'), data.p = single(data.p); end
if isfield(data, 's'), data.s = single(data.s); end

end

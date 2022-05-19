function [sdf_out] = sdf_add(sdf_in, blockname, sdf_block)
% SDF_ADD SDF (structured data file) block add.
%   [SDF_OUT] = SDF_CUT(SDF_IN, BLOCKNAME) adds block to SDF
%
%   Inputs:
%   SDF_IN      cell array of struct data file lines
%   BLOCKNAME   name of block to add
%   SDF_BLOCK   cell array of struct data lines of named block
%
%   Output:
%   SDF_OUT     cell array of resulting struct data lines
%
%   Example:
%   sdf_out = sdf_add(sdf_in, blockname, sdf_block) adds a SDF block.
%
%   See also SDF_CUT.

%   Copyright 2005-2008 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: sdf_add.m 184 2010-09-22 07:41:39Z jorauh $

sdf_out = sdf_in;

sdf_out{end+1} = strcat('$', blockname);
for i = 1:length(sdf_block)
    if strncmp(sdf_block{i}, '$', 1)
        sdf_out{end+1} = strcat('$', sdf_block{i}); %#ok<AGROW>
    else
        sdf_out{end+1} = sdf_block{i}; %#ok<AGROW>
    end
end
sdf_out{end+1} = '$';

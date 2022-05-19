function [sdf_block, sdf_out] = sdf_cut(sdf_in, blockname)
% SDF_CUT SDF (structured data file) block cut.
%   [SDF_BLOCK SDF_OUT] = SDF_CUT(SDF_IN, BLOCKNAME) cuts block from SDF
%
%   Inputs:
%   SDF_IN      cell array of struct data file lines
%   BLOCKNAME   name of block to cut out
%
%   Outputs:
%   SDF_BLOCK   cell array of struct data lines of named block
%   SDF_OUT     cell array of remaining struct data lines
%
%   Example:
%   [sdf_block, sdf_out] = sdf_cut(sdf_in, blockname) extracts a SDF block.
%
%   See also SDF_ADD.

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
%   $Id: sdf_cut.m 184 2010-09-22 07:41:39Z jorauh $

sdf_block{1} = '';
sdf_out{1} = '';

state = 0;

hc = upper(strcat('$', blockname));

for i = 1:length(sdf_in)
    switch state
        case 0 % outside of $BLOCKNAME
            if strcmp(upper(strtok(sdf_in{i}, ' !')), hc)
                state = 1; % begin of $BLOCKNAME detected
            else
                sdf_out{end+1} = sdf_in{i}; %#ok<AGROW>
            end
        case 1 % inside of $BLOCKNAME
            if strncmp(sdf_in{i}, '$', 1)
                if strncmp(sdf_in{i}, '$$', 2)
                    sdf_block{end+1} = sdf_in{i}(2:end); %#ok<AGROW>
                else
                    state = 2; % end of $BLOCKNAME detected
                end
            else
                sdf_block{end+1} = sdf_in{i}; %#ok<AGROW>
            end
        case 2 % after end of $BLOCKNAME
            sdf_out{end+1} = sdf_in{i}; %#ok<AGROW>
    end
end

sdf_block(1) = [];
sdf_out(1) = [];

function [] = crg_demo_gen_syntheticStraight()
% CRG_DEMO_GEN_SYNTHETICSTRAIGHTREFLINE CRG demo to generate a synthtec straigth crg file.
%   CRG_DEMO_GEN_SYNTHETICSTRAIGHT() demonstrates how a simple straight crg file can be
%   generated.
%
%   Example:
%   crg_demo_gen_syntheticStraight    runs this demo to generate "simpleStraight.crg"
%
%   See also CRG_INTRO.

%   Copyright 2005-2010 OpenCRG - VIRES Simulationstechnologie GmbH - HHelmich
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
%   $Id: crg_demo_gen_syntheticStraight.m 01 2010-02-26 12:00:00Z helmich $

%% default settings

u =   [  0    900   ];
v =   [ -2.50   2.5 ];
inc = [  0.04   0.02];

filename = 'simpleStraight.crg';
ct = 'CRG generated file';

%% generate synthetical straight crg file

data = crg_gen_csb2crg0(inc, u, v);

%% add z-values

[nu nv] = size(data.z);

z = 0.01*peaks(nv);
z = repmat(z, ceil(nu/nv), 1);

data.z(1:nu,:) = single(z(1:nu,:));

%% write to file

data.ct{1} = ct;
crg_write(data, filename);

%% display result

crg_show(data);

end

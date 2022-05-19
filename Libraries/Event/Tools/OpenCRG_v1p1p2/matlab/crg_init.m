function [] = crg_init()
% CRG_INIT initialize CRG environment.
%   CRG_INIT initalizes the CRG MATLAB environment by adding the
%   application directory and required subdirectories to path
%
%   Examples:
%   crg_init initializes the CRG environment
%
%   See also CRG_INTRO.

%   Copyright 2005-2011 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_init.m 288 2011-06-06 20:56:48Z jorauh $

%% get the application directory

[appdir] = fileparts(mfilename('fullpath'));

%% add application directory and required subdirectories to path

addpath(appdir);
addpath(fullfile(appdir, 'lib'));
addpath(fullfile(appdir, 'test'));
addpath(fullfile(appdir, 'demo'));

end

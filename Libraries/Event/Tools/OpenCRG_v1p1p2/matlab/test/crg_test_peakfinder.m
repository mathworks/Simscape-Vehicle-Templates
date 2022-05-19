%% Usage of CRG_PEAKFINDER
% Introducing the usage of crg_peakfinder.
% Examples are included.
% The file comments are optimized for the matlab publishing makro.

%   Copyright 2005-2011 OpenCRG - VIRES Simulationstechnologie GmbH -
%   Holger Helmich
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
%   $Id: crg_test_peakfinder.m 1 2011-06-08 11:36:00Z hhelmich $

%% Test proceedings
%
% * Load demo file
% * add peaks
% * find peaks
% * display result
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all;

%% Test1

data = crg_read('demo8.crg');

% add peaks
data.z(200:210, 25:35) = 0.5;      % 10x10 + 0.05
data.z(300:305, 50:55) = 0.2;      % 5x5   + 0.09
data.z(800, 50) = -0.5;            % 1x1   - 0.5

iu = [1 1000];
iv = [1 200];

[pindex, pij] = crg_peakfinder( data, [], [], 0.5, 10);

crg_show_peaks(data, pij, iu, iv, [], []);

%% Test1.1 (sub selection)

data = crg_read('demo8.crg');

% add peaks
data.z(200:210, 25:35) = 0.5;      % 10x10 + 0.05
data.z(300:305, 50:55) = 0.2;      % 5x5   + 0.09
data.z(800, 50) = -0.5;            % 1x1   - 0.5

iu = [1 400];
iv = [1 100];

[pindex, pij] = crg_peakfinder( data, iu, iv, 0.5, 10);

crg_show_peaks(data, pij, iu, iv);

%% Test1.2 (sub selection)

data = crg_read('demo8.crg');

% add peaks
data.z(200:210, 25:35) = 0.5;      % 10x10 + 0.05
data.z(300:305, 50:55) = 0.2;      % 5x5   + 0.09
data.z(800, 50) = -0.5;            % 1x1   - 0.5

iu = [1 400];
iv = [1 100];

[pindex, pij] = crg_peakfinder( data, iu, iv, 0.5, 10);

crg_show_peaks(data, pij, [], [], iu, iv);

%% Test2 (real)

dat1 = crg_read('../crg-bin/country_road.crg');

% add peaks
dat1.z(200:210, 25:35) = 0.5;      % 10x10 + 0.05
dat1.z(300:305, 50:55) = 0.2;      % 5x5   + 0.09
dat1.z(800, 50) = 0.5;             % 1x1   - 0.03

iu = [1 1000];
iv = [1 150];

[pindex, pij] = crg_peakfinder( dat1, iu, iv, 0.5, 10);

crg_show_peaks(dat1, pij, iu, iv, [1 1000]);

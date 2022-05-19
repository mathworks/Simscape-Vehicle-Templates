%% Usage of CRG_LIMITER
% Introducing the usage of crg_limiter.
% Examples are included.
% The file comments are optimized for the matlab publishing makro.
%
% NOTE
% One u-increment is used to adjust both crg-files into the right
% direction. Hence make sure you have a overlap by one (see examples).

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
%   $Id: crg_test_limiter.m 1 2011-06-08 10:50:00Z hhelmich $

%% Test proceedings
%
% Test 1-4
%
% * load demo crg-file
% * set limitations
% * display result
%
% Test 5-6
%
% * load real dataset
% * set limitations
% * display only subset (if necessary)
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all;

%% Test1 ( min/max limitations )

dat = crg_read('demo3.crg');

data = crg_limiter(dat, [-0.02, 0.05] );

crg_show(data);

%% Test2 ( incl. u start/stop )

dat = crg_read('demo6.crg');

data = crg_limiter(dat, [-0.05, -0.03], [200 600]);

crg_show(data);

%% Test3 ( incl. v start/stop )

dat = crg_read('demo6.crg');

data = crg_limiter(dat, [-0.05 0.03], [], [50 100]);

crg_show(data);

%% Test4 ( incl. u/v start/stop )

dat = crg_read('demo8.crg');

data = crg_limiter(dat, 0.15, [400 750], [50 125]);

crg_show(data);

%% Test5 ( real dataset incl. u/v start/stop)

dat = crg_read('../crg-bin/country_road.crg');

data = crg_limiter(dat, -31.45, [62500 63000], [25 150]);

crg_show(data, [62000 63500]);

%% Test6 ( real dataset incl. u/v start/stop)

dat = crg_read('../crg-bin/belgian_block.crg');

data = crg_limiter(dat, [-10 2.13], [600 800], 150);

crg_show(data);

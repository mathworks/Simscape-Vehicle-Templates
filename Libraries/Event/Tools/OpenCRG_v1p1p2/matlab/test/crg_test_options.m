%% Usage of OPTIONS
% Test scripts to display results of option settings.
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
%   $Id: crg_test_options.m 1 2011-06-08 11:22:00Z hhelmich $

%% Test proceedings
%
% * read crg-file
% * set options
% * display results
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all;
% range
u = -1:0.01:11;
v = -2:0.01:2;

%% Test 1.1 ( const space: BM_UV = NaN )

data = crg_read('demo1.crg');

data.opts.bdmu = 0;
data.opts.bdmv = 0;

crg_show_road_uv2surface(data, u, v);

%% Test 1.2 ( const space, banking: BM_UV = NaN )

data = crg_read('demo7.crg');

data.opts.bdmu = 0;
data.opts.bdmv = 0;

crg_show_road_uv2surface(data, u, v);

%% Test 1.3 ( const space, slope: BM_UV = NaN )

data = crg_read('demo9.crg');

data.opts.bdmu = 0;
data.opts.bdmv = 0;

crg_show_road_uv2surface(data, u, v);

%% Test 1.4 ( variable space, banking, slope: BM_UV = NaN )

data = crg_read('demo8.crg');

data.opts.bdmu = 0;
data.opts.bdmv = 0;

crg_show_road_uv2surface(data, u, v);

%% Test 2.1 ( const space: BM_UV = Set Zero )

data = crg_read('demo1.crg');

data.opts.bdmu = 1;
data.opts.bdmv = 1;

crg_show_road_uv2surface(data, u, v);

%% Test 2.2 ( const space, banking: BM_UV = Set Zero )

data = crg_read('demo7.crg');

data.opts.bdmu = 1;
data.opts.bdmv = 1;

crg_show_road_uv2surface(data, u, v);

%% Test 2.3 ( const space, slope: BM_UV = Set Zero )

data = crg_read('demo9.crg');

data.opts.bdmu = 1;
data.opts.bdmv = 1;

crg_show_road_uv2surface(data, u, v);

%% Test 2.4 ( variable space, slope, banking: BM_UV = Set Zero )

data = crg_read('demo8.crg');

data.opts.bdmu = 1;
data.opts.bdmv = 1;

crg_show_road_uv2surface(data, u, v);

%% Test 3.1 ( const space: BM_UV = Keep Last )

data = crg_read('demo1.crg');

data.opts.bdmu = 2;
data.opts.bdmv = 2;

crg_show_road_uv2surface(data, u, v);

%% Test 3.2 ( const space, banking: BM_UV = Keep Last )

data = crg_read('demo7.crg');

data.opts.bdmu = 2;
data.opts.bdmv = 2;

crg_show_road_uv2surface(data, u, v);

%% Test 3.3 ( const space, slope: BM_UV = Keep Last )

data = crg_read('demo9.crg');

data.opts.bdmu = 2;
data.opts.bdmv = 2;

crg_show_road_uv2surface(data, u, v);

%% Test 3.4 ( variable space, slope, banking: BM_UV = Keep Last )

data = crg_read('demo8.crg');

data.opts.bdmu = 2;
data.opts.bdmv = 2;

crg_show_road_uv2surface(data, u, v);

%% Test 4.1 ( const space: BM_UV = Repeat )

data = crg_read('demo1.crg');

data.opts.bdmu = 3;
data.opts.bdmv = 3;

crg_show_road_uv2surface(data, u, v);

%% Test 4.2 ( const space, banking: BM_UV = Repeat )

data = crg_read('demo7.crg');

data.opts.bdmu = 3;
data.opts.bdmv = 3;

crg_show_road_uv2surface(data, u, v);

%% Test 4.3 ( const space, slope: BM_UV = Repeat )

data = crg_read('demo9.crg');

data.opts.bdmu = 3;
data.opts.bdmv = 3;

crg_show_road_uv2surface(data, u, v);

%% Test 4.4 ( variable space, slope banking: BM_UV = Repeat )

data = crg_read('demo8.crg');

data.opts.bdmu = 3;
data.opts.bdmv = 3;

crg_show_road_uv2surface(data, u, v);

%% Test 5.1 ( const space: BM_UV = Reflect )

data = crg_read('demo1.crg');

data.opts.bdmu = 4;
data.opts.bdmv = 4;

crg_show_road_uv2surface(data, u, v);

%% Test 5.2 ( const space, banking: BM_UV = Reflect )

data = crg_read('demo7.crg');

data.opts.bdmu = 4;
data.opts.bdmv = 4;

crg_show_road_uv2surface(data, u, v);

%% Test 5.3 ( const space, slope: BM_UV = Reflect )

data = crg_read('demo9.crg');

data.opts.bdmu = 4;
data.opts.bdmv = 4;

crg_show_road_uv2surface(data, u, v);

%% Test 5.4 ( variable space, banking: BM_UV = Reflect )

data = crg_read('demo8.crg');

data.opts.bdmu = 4;
data.opts.bdmv = 4;

crg_show_road_uv2surface(data, u, v);

%% Test 6.1 ( const space, banking: smoothing )
data = crg_read('demo7.crg');

data.opts.bdmu = 1;
data.opts.bdmv = 0;

data.opts.bdss = 3;
data.opts.bdse = 3;

crg_show_road_uv2surface(data, u, v);


%% Test 6.2 ( const space, slope: smoothing )

data = crg_read('demo9.crg');

data.opts.bdmu = 1;
data.opts.bdmv = 0;

data.opts.bdss = 3;
data.opts.bdse = 3;

crg_show_road_uv2surface(data, u, v);

%% Test 6.3 ( variable space, banking, slope: smoothing )

data = crg_read('demo8.crg');

data.opts.bdmu = 4;
data.opts.bdmv = 0;

data.opts.bdss = 3;
data.opts.bdse = 3;

crg_show_road_uv2surface(data, -1:0.01:15, v);

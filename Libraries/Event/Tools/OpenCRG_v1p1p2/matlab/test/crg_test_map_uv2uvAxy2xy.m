%% Usage of CRG_MAP_UV2UVV AND CRG_MAP_XY2XY
% Introducing the usage of crg_map_uv2uv and crg_map_xy2xy.
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
%   $Id: crg_test_map_uv2uvAxy2xy.m 1 2011-06-08 11:06:00Z hhelmich $

%% Test proceedings
%
% * generate 0-z-crg file
% * load test/real files
% * FIRST: u,v maping ( za(u,v) -> zb(u,v) )
% * SECOND: inertial x,y mapping ( za(x,y) -> zb(x,y) )
% * display result
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all;

%% Test1 ( no additional parameter )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
dat2 = crg_read('demo1.crg');

data = crg_map_uv2uv(dat1,dat2);        % u,v mapping
crg_show(data);

data = crg_map_xy2xy(dat1,dat2);        % inertial mapping
crg_show(data);


%% Test2 ( u-start/stop index)
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
dat2 = crg_read('demo3.crg');

data = crg_map_uv2uv(dat1, dat2, [200 1000]);       % u,v mapping
crg_show(data);

data = crg_map_xy2xy(dat1,dat2, [200 1000]);        % inertial mapping
crg_show(data);

%% Test3 ( v-start/stop index )
% Border Mode is default
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };


dat1 = crg_gen_csb2crg0([], 16, 1, c);
dat2 = crg_read('demo1.crg');

data = crg_map_uv2uv(dat1, dat2, [], [70 110]);     % u,v mapping
crg_show(data);

data = crg_map_xy2xy(dat1,dat2, [], [20 75]);       % inertial mapping
crg_show(data);


%% Test4 ( u/v-start/stop index )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
dat2 = crg_read('demo1.crg');

data = crg_map_uv2uv(dat1, dat2, [200 1000], [50 150]); % u,v mapping
crg_show(data);

data = crg_map_xy2xy(dat1,dat2, [50 150], [20 50]);     % inertial mapping
crg_show(data);

%% Test5 ( add curved crg )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
dat2 = crg_read('demo7.crg');

data = crg_map_uv2uv(dat1, dat2);   % u,v mapping
crg_show(data);

data = crg_map_xy2xy(dat1,dat2);    % inertial mapping
crg_show(data);

%% Test6 ( adding real dataset )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
dat2 = crg_read('../crg-bin/belgian_block.crg');

dat2.mods.rptx = 1;
dat2.mods.rpty = 1;
dat4 = crg_mods(dat2);

data = crg_map_uv2uv(dat1, dat4 );    % u,v mapping
crg_show(data);

data = crg_map_xy2xy(dat1,dat4 );     % inertial mapping
crg_show(data);

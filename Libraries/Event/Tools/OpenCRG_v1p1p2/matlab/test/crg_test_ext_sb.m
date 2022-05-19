%% Usage of CRG_EXT_BANKING and CRG_EXT_SLOPE
% Introducing the usage of crg_ext_banking and crg_ext_slope.
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
%   $Id: crg_test_ext_sb.m 1 2011-06-07 11:49:00Z hhelmich $

%% Test proceedings
%
% * load demo/real file
% * extract banking/banking
% * display result
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all;

%% Test1 ( extract banking incl. smoothing )

dat = crg_read('demo7.crg');

exdata = crg_ext_banking(dat, 0.0000003);

crg_show_refline_elevation(exdata);
crg_show_elgrid_surface(exdata)
crg_show_road_surface(exdata);

%% Test1.1 ( extract banking w/o smoothing  )

dat = crg_read('demo7.crg');

exdata = crg_ext_banking(dat);

crg_show_refline_elevation(exdata);
crg_show_elgrid_surface(exdata)
crg_show_road_surface(exdata);

%% Test2 ( extract slope )

dat = crg_read('demo9.crg');

exdata = crg_ext_slope(dat);

crg_show_refline_elevation(exdata);
crg_show_elgrid_surface(exdata)
crg_show_road_surface(exdata);

%% Test2.1 ( extract slope/banking )

dat = crg_read('demo8.crg');

exdata = crg_ext_banking(dat);
exdata = crg_ext_slope(exdata);

crg_show_refline_elevation(exdata);
crg_show_elgrid_surface(exdata)
crg_show_road_surface(exdata);

%% Test3 ( real dataset extract slope/banking )

dat = crg_read('../crg-bin/belgian_block.crg');

exdata = crg_ext_banking(dat, 0.0000000000003);
exdata = crg_ext_slope(exdata);

crg_show_refline_elevation(exdata);
crg_show_elgrid_surface(exdata)
crg_show_road_surface(exdata);

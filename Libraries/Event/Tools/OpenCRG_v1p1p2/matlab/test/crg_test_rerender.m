%% Usage of CRG_RERENDER
% Introducing the usage of crg_rerender.
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
%   $Id: crg_test_map_rerender.m 1 2011-06-08 11:36:00Z hhelmich $

%% Test proceedings
%
% * generate 0-z-crg file
% * add z-values ( optional )
% * rerender crg
% * display result
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all;

%% Test1 ( different uinc )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
data = crg_rerender( dat1, 0.4 );

crg_show(data);

%% Test2 ( different vinc )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
data = crg_rerender( dat1, [0.01, 0.2] );

crg_show(data);

%% Test3 ( different uinc, vinc )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
data = crg_rerender( dat1, [0.005, 0.03] );

crg_show(data);

%% Test4 ( different v )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
data = crg_rerender( dat1, [], 0.5 );

crg_show(data);

%% Test5 ( interpolation method )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
data = crg_rerender( dat1, [0.2, 0.2] );

crg_show(data);

%% Test6 ( incl. z-values )

dat1 = crg_read('demo7.crg');

data = crg_rerender( dat1, [0.2, 0.2] );

crg_show(data);

%% Test7 ( try uinc > 0.45 )
c = {  3   {   0  -0.2/3 }  ...    % klothoide
     ; 5   {-0.2   0.4/5 }  ...    % turning klothoide
     ; 8   { 0.4   0.4/8 }  ...    % circle
    };

dat1 = crg_gen_csb2crg0([], 16, 1, c);
data = crg_rerender( dat1, 0.5 );

crg_show(data);

%% Test8 ( real case: )

dat1 = crg_read('../crg-bin/country_road.crg');

data = crg_rerender(dat1, 0.4);
crg_show(data);

%% Test9 ( no curvature )

dat = crg_read('demo1.crg');
data = crg_rerender(dat, 0.5);

crg_show(data);

%% Test10 ( curvature )

dat = crg_read('demo6.crg');
data = crg_rerender(dat, 0.5);

crg_show(data);

%% Test11 ( constant curvature )

dat = crg_read('demo4.crg');
data = crg_rerender(dat, 0.05);

crg_show(data);

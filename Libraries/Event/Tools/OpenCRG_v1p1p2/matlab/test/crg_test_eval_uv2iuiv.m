%% Usage of CRG_EVAL_UV2IUIV
% Introducing the usage of crg_eval_uv2iuiv.
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
%   $Id: crg_test_eval_uv2iuiv.m 1 2011-06-07 11:47:00Z hhelmich $

%% Test proceedings
%
% Test 1-4
%
% * load crg-file
% * find index positions
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all;

%% Test1 ( u-values )

data = crg_read('demo3.crg');
u = data.head.ubeg:data.head.uinc:data.head.uend;

[iu] = crg_eval_uv2iuiv(data, [-1, 0, 5, 7, 10, 11] );
disp('Index: ');
disp(sprintf('< %d > \t', iu));

disp('Distance u(iu) = ');
disp(sprintf('< %f > \t', u(iu)));

%% Test2 ( empty )

data = crg_read('demo3.crg');

[iu] = crg_eval_uv2iuiv(data, [] );

%% Test3 ( v-values constant vinc )

data = crg_read('demo1.crg');
v = data.head.vmin:data.head.vinc:data.head.vmax;

[iu, iv] = crg_eval_uv2iuiv(data, [],  [-2 -1 -0.5, 0, 0.5, 1 2]);
disp('Index: ');
disp(sprintf('< %d > \t', iv));

disp('Distance v(iv) = ');
disp(sprintf('< %f > \t', v(iv)));


%% Test3.1 ( v-values no constant vinc )

data = crg_read('demo3.crg');
v = data.v;

[iu, iv] = crg_eval_uv2iuiv(data, [],  [-2 -1 -0.5, 0, 0.5, 1 2]);
disp('Index: ');
disp(sprintf('< %d > \t', iv));

disp('Distance v(iv) = ');
disp(sprintf('< %f > \t', v(iv)));


%% Test4 ( uv-values & different uinc );

data = crg_read('demo6.crg');
u = data.head.ubeg:data.head.uinc:data.head.uend;
v = data.v;

dat = crg_rerender(data, [0.2]);

[iu, iv] = crg_eval_uv2iuiv(dat, [-1, 0, 5, 7, 10, 11], [-2, -1, 0.5, 0, 0.5, 1, 2]);
disp('Index iu: ');
disp(sprintf('< %d > \t', iu));
disp('Index iv: ');
disp(sprintf('< %d > \t', iv));

disp('Distance u(iu) = ');
disp(sprintf('< %f > \t', u(iu)));
disp('Distance v(iv) = ');
disp(sprintf('< %f > \t', v(iv)));

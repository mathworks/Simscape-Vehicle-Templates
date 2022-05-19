%% Demo file generation CRG_DEMO
% Building a set of demo files with differ specifications.
% Do not alter this CRG-file. If necessary add new demo files. Several test proceedings require these data-structures.
% The file comments are optimized for the matlab publishing makro.

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
%   $Id: crg_demo.m 289 2011-06-09 11:07:18Z jorauh $

%% Demo proceeding
% The demos are initialized as followed:
%
% Demo 1-9
%
% * generate minimal crg-structure
% * alter, add specifications (change increment, add slope ec.)
% * write CRG-file
% * show results
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all
% display results
dispRes = 0;

% build minimum crg-struct
uinc = 0.01;
vinc = 0.01;

nv = 201;
nu = 5*nv;

v = -(nv-1)/2*vinc:vinc:(nv-1)/2*vinc;

z = 0.01*peaks(nv);
z = repmat(z, nu/nv, 1);

%% Demo1: crg defined by z matrix and scalar u and v specs

data.u = (nu-1)*uinc;
data.v = (nv-1)*vinc/2;
data.z = z;
data.ct{1} = 'CRG defined by z matrix';
crg_write(crg_single(data), 'demo1.crg');

dat = crg_read('demo1.crg');
if dispRes, crg_show(dat); end

%% Demo2: ... and evenly spaced v vector

data.v = v;
data.ct{2} = '... and evenly spaced v vector';
crg_write(crg_single(data), 'demo2.crg');

dat = crg_read('demo2.crg');
if dispRes, crg_show(dat); end


%% Demo3: ... and unevenly spaced v vector

data.v(1) = single(-0.992);
data.ct{2} = '... and unevenly spaced v vector';
crg_write(crg_single(data), 'demo3.crg');

dat = crg_read('demo3.crg');
if dispRes, crg_show(dat); end

%% Demo4: ... generate diagonal reference line by one p value

data.p(1) = pi/4;
data.ct{3} = '... with diagonal reference line by one p value';
crg_write(crg_single(data), 'demo4.crg');

dat = crg_read('demo4.crg');
if dispRes, crg_show(dat); end

%% Demo5: ... generate diagonal reference line by nu-1 p values

np = nu-1;
data.p(1:np) = pi/4;
data.ct{3} = '... with diagonal reference line by nu-1 p values';
crg_write(crg_single(data), 'demo5.crg');

dat = crg_read('demo5.crg');
if dispRes, crg_show(dat); end

%% Demo6: ... generate curved reference line

np = nu-1;
for i=1:np
    data.p(i) = 0.5*cos(i/np*1.5*pi);
end

data.ct{3} = '... with curved reference line';
crg_write(crg_single(data), 'demo6.crg');

dat = crg_read('demo6.crg');
if dispRes, crg_show(dat); end

%% Demo7: ... generate banking

for i=1:nu
    data.b(i) = 0.1*sin(i/nu*2*pi);
end
data.ct{4} = '... with variable cross slope';
crg_write(crg_single(data), 'demo7.crg');

dat = crg_read('demo7.crg');
if dispRes, crg_show(dat); end

%% Demo8: ... generate slope

for i=1:np
    data.s(i) = 0.1*sin(i/np*2*pi);
end
data.b=0.05; % constant cross slope
data.ct{4} = '... with variable slope and constant cross slope';
crg_write(crg_single(data), 'demo8.crg');

dat = crg_read('demo8.crg');
if dispRes, crg_show(dat); end

%% Demo9: ... slope without banking

data = rmfield(data, 'b');

data.ct{4} = '... with variable slope';
crg_write(crg_single(data), 'demo9.crg');

dat = crg_read('demo9.crg');
if dispRes, crg_show(dat); end

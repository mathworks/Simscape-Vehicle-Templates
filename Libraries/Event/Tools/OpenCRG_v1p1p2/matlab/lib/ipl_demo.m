function [] = ipl_demo()
% IPL_DEMO IPLOS write/read demonstration.
%   IPL_DEMO() demonstrates use of ipl_ routines
%
%   IPL_DEMO writes and reads various files in current directory.
%
%   Example
%   ipl_demo generates IPL structures, writes and reads IPL files, and
%   shows contents.
%
%   See also IPL_READ, IPL_WRITE.

%   Copyright 2005-2008 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: ipl_demo.m 184 2010-09-22 07:41:39Z jorauh $

close all

% generate data channel descriptions
d.kd_def{1} = 't,s';
d.kd_def{2} = 'sin(t),-';
d.kd_def{3} = 'cos(t),-';

% generate data array
t = 0:0.01:10;
d.kd_dat = [t' sin(t') cos(t')];

% show it
figure
plot(d.kd_dat(:,1)', d.kd_dat(:,2)', ...
    d.kd_dat(:,1)', d.kd_dat(:,3)');

% write it as compact single precision binary
ipl_write(d, 'ipl_demo_1.ipl', 'KRBI');
disp('data written as KRBI to ipl_demo_1.ipl:')
disp(d)

% write it as long double precision formattet
ipl_write(d, 'ipl_demo_2.ipl', 'LDFI');
disp('data written as LDFI to ipl_demo_2.ipl:')
disp(d)

% read first file (default channel precision: single)
d1 = ipl_read('ipl_demo_1.ipl');
disp('data read into single from ipl_demo_1.ipl:')
disp(d1)

% read second file to double data array
d2 = ipl_read('ipl_demo_2.ipl', 'double');
disp('data read into double from ipl_demo_2.ipl:')
disp(d2)

% add extra lines for read data
hold on
plot(d1.kd_dat(:,1)', d1.kd_dat(:,2)', '--', ...
    d1.kd_dat(:,1)', d1.kd_dat(:,3)', '--');
plot(d2.kd_dat(:,1)', d2.kd_dat(:,2)', ':', ...
    d2.kd_dat(:,1)', d2.kd_dat(:,3)', ':');
xlabel(d.kd_def{1})
legend(strcat('d: ', d.kd_def{2}), strcat('d: ', d.kd_def{3}), ...
    strcat('d1: ', d1.kd_def{2}), strcat('d1: ', d1.kd_def{3}), ...
    strcat('d2: ', d2.kd_def{2}), strcat('d2: ', d2.kd_def{3}));

function [] = crg_show_isequal(dd, out)
% CRG_SHOW_ISEQUAL CRG_comparison of two crg_files data core visualizer.
%   CRG_SHOW_ISEQUAL(DD) visualize crg-file comparison
%
%   Inputs:
%   DD      struct array as defined in CRG_ISEQUAL
%   OUT     visualization ( optional )
%           html:   html visualization
%
%   Examples:
%   crg_show_isequal(dd, 'html') visualizes crg_isequal results.
%
%   See also CRG_INTRO, CRG_ISEQUAL.

%   Copyright 2005-2010 OpenCRG - VIRES Simulationstechnologie GmbH - Helmich Holger
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
%   $Id: crg_show_isequal.m 29 2009-10-02 10:00:32Z helmich $

% default
if nargin < 2 || isempty(out), out = ''; end

scrpos = get(0,'ScreenSize');   % Set plot area
scrpos(3) = scrpos(4);          % quadratic max. window size

% publish html
if strcmp(out,'html')
    function_options.format = 'html';
    function_options.evalCode=true;
    function_options.codeToEvaluate= 'crg_show_isequal(dd)' ;
    function_options.showCode=false;
    web(publish('crg_show_isequal.m',function_options))
    return
end

%% warning messages
% warning messages will not stop comparison
for i = 1:length(dd.warn)
    disp(dd.warn(i));
end

%% error messages
% display error messages
for i = 1:length(dd.err)
    disp(dd.err(i));
end

%% visualize z-matrix comparison

% histogram of arithmetic absolute mean
figure('Position', scrpos)

[xi, yi] = meshgrid(dd.u,dd.v);

subplot(3,1,1)
hist(dd.mean)
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

xlabel('Diff [m]')
ylabel('Count [#]')
title('CRG histogramm of absolute arithmetic average')

% arithmetic average of z-values (absolute)
subplot(3,1,2)
surf(xi, yi, double(dd.mean));
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

shading interp

xlabel('X [m]')
ylabel('Y [m]')
zlabel('Z [m]')
title('CRG arithmetic average of z-values (absolute)')

colorbar

% CRG arithmetic average of z-values (relative)
subplot(3,1,3)
surf(xi,yi, double(dd.rmean));
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

shading interp

xlabel('NN')
ylabel('NN')
zlabel('NN')
title('CRG arithmetic average of z-values (relative)')

colorbar

end % function crg_show_isequal

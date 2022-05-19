function [data] = crg_show_refpnts_and_refline(data, pxy)
% CRG_SHOW_REFLINE_MAP CRG road refpnts and refline visualizer.
%   DATA = CRG_SHOW_REFLINE_MAP(DATA, IU) visualizes CRG reference points
%   resulting refline map.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   PXY     (np, 2) array of points in xy system
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_show_refpnts_and_refline(data, pxy)
%       shows CRG refpnts and refline map info.
%   See also CRG_INTRO.

%   Copyright 2005-2009 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_show_refpnts_and_refline.m 184 2010-09-22 07:41:39Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% define figure frame

if ~isfield(data, 'fopt') || ~isfield(data.fopt, 'tit')
    data.fopt.tit = 'CRG reference points and resulting reference line map';
    data          = crg_figure(data);
    data.fopt     = rmfield(data.fopt, 'tit');
else
    data = crg_figure(data);
end

%% refpoints and refline XY overview map

subplot(3,2,1)

plot(pxy(:,1), pxy(:,2), '.')
hold on
data = crg_plot_refline_xy_overview_map(data);
title('CRG reference points in reference line XY overview map')

set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

%% refpoint distances from refline

subplot(3,2,2)

data = crg_plot_refpnt_distances(data, pxy);

set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

%% refline XY overview map

subplot(3,2,3)
data = crg_plot_refline_xy_overview_map(data);
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

%% refline heading plot

subplot(3,2,4)
data = crg_plot_refline_heading(data);
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

%% refline XY map with norm. curvature

subplot(3,2,5)
data = crg_plot_refline_xy_map_and_curv(data);
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')


%% refline curvature plot

subplot(3,2,6)
data = crg_plot_refline_curvature(data);
set(    gca             , 'ButtonDownFcn','copy_ax2fig')
set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')

end

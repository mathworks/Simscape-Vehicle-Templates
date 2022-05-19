function [] = copy_ax2fig()
% COPY_AX2FIG Copy current axes object to new figure.
%   COPY_AX2FIG() copies the current axes object to a new figure.
%   This function is most useful if called by a mouse click action in a
%   subplot of a complex figure.
%   -   If the subplot is a surface plot, then a colorbar is also attached
%       to the new figure.
%   -   If the subplot has a legend, then a legend will also attached to
%       the new figure.
%   In order for the function to work, each subplot must be have it's
%   ButtonDownFcn set to COPY_AX2FIG. To set this property for the current
%   axes object:
%       set(    gca             , 'ButtonDownFcn','copy_ax2fig')
%       set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')
%   for all children of the current axis object, or more individually
%       set(axis_handle,'ButtonDownFcn','copy_ax2fig');
%       set(line_handle,'ButtonDownFcn','copy_ax2fig');
%   The line_handle represents the handle for either a line, surface,
%   or plot handle. If there are multiple line objects, each needs to be
%   set. With both the line and axis object set, it doesn't matter whether
%   the axis object or line object is clicked on.
%
%   Example:
%   figure
%   t = 0:pi/100:2*pi;
%
%   subplot(2,1,1)
%   plot(t,sin(t))
%   set(    gca             , 'ButtonDownFcn','copy_ax2fig')
%   set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')
%
%   subplot(2,1,2)
%   plot(t,cos(t))
%   set(    gca             , 'ButtonDownFcn','copy_ax2fig')
%   set(get(gca, 'Children'), 'ButtonDownFcn','copy_ax2fig')
%
%   See also gca.

%   Motivated by call_copy of Jeff Lucas
%   http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=3450
%
%   Copyright 2005-2010 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: copy_ax2fig.m 192 2010-11-09 23:12:42Z jorauh $

[legend_h,object_h,plot_h,text_strings] = legend;

ax = copyobj(gca,figure);

set(ax,'OuterPosition',[0 0 1 1]);
set(ax,'LooseInset',get(ax,'TightInset')+[0.045 0.02 0.065 0.02]);

set(ax,'ButtonDownFcn','');
h_child=get(ax,'Children');
set(h_child,'ButtonDownFcn','');

if any(strcmp(get(h_child,'Type'),'surface'));
    colorbar;
end;

if iscell(text_strings)
    legend(text_strings)
end

end

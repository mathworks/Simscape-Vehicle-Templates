function [data] = crg_figure(data)
% CRG_FIGURE CRG figure setup.
%   DATA = CRG_FIGURE(DATA) sets up a CRG figure.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_figure(data)
%       sets up a CRG figure.
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
%   $Id: crg_figure.m 184 2010-09-22 07:41:39Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% check/complement figure opts

if isfield(data, 'fopt')
    fopt = data.fopt;
else
    fopt = struct;
end

if ~isfield(fopt, 'ori')
    fopt.ori = 'landscape';
end
if ~isfield(fopt, 'tit')
    fopt.tit = 'CRG figure';
end
if ~isfield(fopt, 'fnm')
    if isfield(data, 'filenm')
        fopt.fnm = data.filenm;
    else
        fopt.fnm = '<unknown CRG file name>';
    end
end
if ~isfield(fopt, 'dat')
    fopt.dat = datestr(now, 31);
end


%% define figure frame

scrpos = get(0,'ScreenSize');

switch fopt.ori
    case 'landscape'
        figpos(4) = min(scrpos(3)/sqrt(2), scrpos(4)) * 0.8;    % heigth
        figpos(3) = figpos(4)*sqrt(2);                          % width
        figpos(1) = scrpos(1) + scrpos(3)*0.9 - figpos(3);      % left
        figpos(2) = scrpos(2) + scrpos(4)*0.9 - figpos(4);      % bottom

        pappos(1) = 0.05; % left
        pappos(2) = 0.05; % botton
        pappos(3) = 0.90; % width
        pappos(4) = 0.90; % height
    case 'portrait'
        figpos(3) = min(scrpos(3), scrpos(4)/sqrt(2)) * 0.8;    % width
        figpos(4) = figpos(3)*sqrt(2);                          % heigth
        figpos(1) = scrpos(1) + scrpos(3)*0.9 - figpos(3);      % left
        figpos(2) = scrpos(2) + scrpos(4)*0.9 - figpos(4);      % bottom

        pappos(1) = 0.10; % left
        pappos(2) = 0.10; % botton
        pappos(3) = 0.80; % width
        pappos(4) = 0.80; % height
    otherwise
        error('CRG:figureError', 'illegal value of DATA.fopt.ori="%s"', fopt.ori)
end


figure('Position', figpos, ...
    'Name', fopt.tit, ...
    'PaperUnits', 'normalized', ...
    'PaperPosition', pappos, ...
    'PaperOrientation', fopt.ori)

% set(gcf, 'DefaultLineLineWidth', 1.5)

annotation('textbox', [0.00 0.95 1.0 0.05], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'top', ...
    'Interpreter', 'none', ...
    'LineStyle', 'none', ...
    'String', fopt.tit);

annotation('textbox', [0.00 0.00 1.00 0.05], ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'Interpreter', 'none', ...
    'LineStyle', 'none', ...
    'String', fopt.fnm);

annotation('textbox', [0.00 0.00 1.00 0.05], ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'Interpreter', 'none', ...
    'LineStyle', 'none', ...
    'String', fopt.dat);

end

function [data] = crg_plot_refpnt_distances(data, pxy)
% CRG_PLOT_REFPNT_DISTANCES CRG road refpoint distance plot.
%   DATA = CRG_PLOT_REFPNT_DISTANCES(DATA, PXY) plots CRG reference point
%   distances from reference line in current axes object.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   PXY     (np, 2) array of points in xy system
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_plot_refpnt_distances(data, pxy)
%       plots refpoint distances.
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
%   $Id: crg_plot_refpnt_distances.m 184 2010-09-22 07:41:39Z jorauh $

%% check if already succesfully checked

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

%% generate auxiliary data

[puv, data] = crg_eval_xy2uv(data, pxy);
vmean = mean(puv(:,2));
vstd  = std (puv(:,2));

vstd1 = [data.head.ubeg data.head.uend NaN data.head.ubeg data.head.uend];
vstd2 = [vmean+vstd     vmean+vstd     NaN vmean-vstd     vmean-vstd    ];

%% plot refpoint distances from reference line

plot(puv(:,1), puv(:,2), '.')

hold on
plot([data.head.ubeg data.head.uend], [vmean vmean], 'r-.') % mean
plot(vstd1, vstd2, 'r--') % mean +/- std
grid on

title('CRG reference point distances from reference line')
xlabel('U [m]')
ylabel('point distance V [m]')
legend('point distances', ...
    sprintf('mean = %d', vmean), ...
    sprintf('std = %d', vstd))


end

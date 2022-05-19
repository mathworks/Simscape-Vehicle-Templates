function [data] = crg_surf(data, x, y, z)
% CRG_SURF plots a 3d surface.
%   DATA = CRG_SURF(DATA, X, Y, Z) plots a 3d surface in current axes
%   object with extended option settings.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%           DATA.fopts options are evaluated if available.
%   X       surf argument X
%   Y       surf argument Y
%   Z       surf argument Z
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_surf(data, x, y, z)
%       plots 3d surface.
%   See also CRG_INTRO.

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
%   $Id: crg_surf.m 184 2010-09-22 07:41:39Z jorauh $

%% plot elgrid XYZ perspective map

fmod = 0; % colormap mod divisor 0 returns unchanged value
if isfield(data, 'fopt') && isfield(data.fopt, 'mod')
    fmod = data.fopt.mod;
end
surf(x, y, z, mod(z, fmod))

fasp = 0.1; % z aspect ratio 0.1 magnifies z axis by 10
if isfield(data, 'fopt') && isfield(data.fopt, 'asp')
    fasp = data.fopt.asp;
end
daspect([1 1 fasp])

axis tight
grid on
colorbar

shading interp
lighting phong

h = camlight;
flit = 0; % light visibility
if isfield(data, 'fopt') && isfield(data.fopt, 'lit')
    flit = data.fopt.lit;
end
if flit == 0
    set(h, 'Visible', 'off')
end

end

function [dist dbeg dend] = crg_wgs84_dist(wgs1, wgs2)
%CRG_WGS84_DIST CRG evaluate distance and bearing between WGS84 positions.
%   [DIST DBEG DEND] = CRG_WGS84_DIST(WGS1, WGS2) evaluates distance and
%   bearing for given WGS84 positions. Since the earth is approximately a
%   sphere, the bearing (azimut direction) following a straight line along
%   a great-circle arc will change from start to end in general.
%
%   Inputs:
%   WGS1    (np, 2) arrays of latitude/longitude (north/east) wgs84
%           coordinate pairs (in degrees)
%   WGS2    (np, 2) arrays of latitude/longitude (north/east) wgs84
%           coordinate pairs (in degrees)
%
%   Outputs:
%   DIST    (np) vector of distance values
%   DBEG    (np) vector of direction (bearing) values at begin (in rad)
%   DEND    (np) vector of direction (bearing) values at end (in rad)
%
%   Examples:
%   wgs1 = [51.477811,-0.001475] % Greenwich Prime Meridian
%                                % (Airy's Transit Circle)
%   wgs2 = [51.477678, 0.000000] % WGS84 "zero meridian way crossing"
%                                % (there is no real landmark)
%   [dist dbeg dend] = crg_wgs84_dist(wgs1, wgs2)
%   evaluates the distance and bearing between two positions in Greenwich.
%   (The WGS84 zero is about 100m east of the Greenwich Prime Meridian).
%
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
%   $Id: crg_wgs84_dist.m 184 2010-09-22 07:41:39Z jorauh $

%% call wgs84dist

[dist dbeg dend] = wgs84dist(wgs1(:,1),wgs1(:,2), wgs2(:,1),wgs2(:,2), 1,0);

dist = dist';
dbeg = dbeg';
dend = dend' - pi;

end

%% wgs84dist

% download 2009-07-31
% http://www.mathworks.com/matlabcentral/fileexchange/8607
% code found in comments of 28 Nov 2006 by John Lansberry

function [s_out, faz_out, baz_out] = wgs84dist(varargin)
%------------------------------------------------------------------------------
% function [s, faz, baz] = wgs84dist(lat1, lon1, lat2, lon2 [, deg_in, deg_out])
%
% This code is part of the geodetic tool kit, which can be downloaded
% from the National Oceanic and Atmospheric Administration (NOAA)
% National Geodetic Survey (ngs) website at:
% http://www.ngs.noaa.gov/index.shtml.
%
% input description
%
% lat1 initial latitude (rad or deg)
% lon1 initial longitude (rad or deg)
% lat2 final latitude (rad or deg)
% lon2 final longitude (rad or deg)
% deg_in selects whether angular inputs are in degrees or
% radians (deg_in = 1 for degrees) (optional)
% deg_out selects whether angular outputs are in degrees or
% radians (deg_out = 1 for degrees) (optional)
%
% output description
%
% s surface distance along ellipsoid (m)
% faz forward azimuth (rad or deg) (optional)
% baz backward azimuth (rad or deg) (optional)
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
% Original source code comments:
%
% Solution of the geodetic direct problem after T.Vincenty
% modified Rainsford's method with Helmert's elliptical terms
% effective in any azimuth and at any distance short of antipodal
% standpoint/forepoint must not be the geographic pole
%
% a is the semi-major axis of the reference ellipsoid
% f is the flattening of the reference ellipsoid
% latitudes and longitudes in radians positive north and east
% forward azimuths at both points returned in radians from north
%
% programmed for cdc-6600 by LCDR L.Pfeifer NGS Rockville MD 18FEB75
% modified for system 360 by John G Gergen NGS Rockville MD 7507
%------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% check input arguments
%-------------------------------------------------------------------------------
  error(nargchk(4, 6, nargin));

%-------------------------------------------------------------------------------
% check for input errors (e.g., inputs have incorrect number of rows or columns)
%-------------------------------------------------------------------------------
  rows = zeros(1,nargin);
  cols = zeros(1,nargin);

  for ii=1:nargin,
    [rows(ii), cols(ii)] = size(varargin{ii});
  end

  maxrows = max(rows);

% make sure each input has either 1 row or n rows
  inputerr = any(rows ~= 1 & rows ~= maxrows);

  if inputerr,
    error('inputs must have either 1 row or n rows')
  end

% all inputs must have 1 column
  inputerr = any(cols ~= 1);

  if inputerr
    error('all inputs must have one column');
  end

%-------------------------------------------------------------------------------
% expand inputs as necessary
%-------------------------------------------------------------------------------
  expand = any(rows == 1) & (maxrows > 1);

  if expand,
    for ii=1:nargin,
      if rows(ii) == 1,
        varargin{ii} = repmat(varargin{ii}, maxrows, 1);
      end
    end
  end

%------------------------------------------------------------------------------
% extract inputs from varargin
%------------------------------------------------------------------------------
  lat1 = varargin{1};
  lon1 = varargin{2};
  lat2 = varargin{3};
  lon2 = varargin{4};

  deg_in = zeros(maxrows, 1);
  deg_out = zeros(maxrows, 1);

  if nargin >= 5,
    deg_in = varargin{5};
    if nargin == 6,
      deg_out = varargin{6};
    end
  end

%------------------------------------------------------------------------------
% WGS-84 defining parameters.
%------------------------------------------------------------------------------
  a = 6378137.0;
  f = 1.0 / 298.257223563;

%------------------------------------------------------------------------------
% Miscellaneous parameters.
%------------------------------------------------------------------------------
  rad2deg = 180 / pi;
  deg2rad = 1.0 / rad2deg;

  zero = 0.0; one = 1.0; two = 2.0;three = 3.0; four = 4.0; six = 6.0;
  three_eighths = 3.0 / 8.0; sixteen = 16.0;

%------------------------------------------------------------------------------
% Input conversions.
%------------------------------------------------------------------------------
  lat1(deg_in == 1) = lat1(deg_in == 1) * deg2rad;
  lon1(deg_in == 1) = lon1(deg_in == 1) * deg2rad;
  lat2(deg_in == 1) = lat2(deg_in == 1) * deg2rad;
  lon2(deg_in == 1) = lon2(deg_in == 1) * deg2rad;

%------------------------------------------------------------------------------
% Find lat/lon pairs that are identical - remove them from the calculations.
% The surface distance, forward azimuth and backward azimuth for these points
% will be set to zero.
%------------------------------------------------------------------------------
  equal = ( abs(lat1 - lat2) < eps & abs(lon1 - lon2) < eps);

  s_out = zeros(size(lat1));
  faz_out = zeros(size(lat1));
  baz_out = zeros(size(lat1));

  lat1 = lat1(~equal);
  lon1 = lon1(~equal);
  lat2 = lat2(~equal);
  lon2 = lon2(~equal);

%------------------------------------------------------------------------------
% Main routine.
%------------------------------------------------------------------------------
  eps0 = 0.5e-13;
  r = one - f;
  tu1 = r * sin(lat1) ./ cos(lat1);
  tu2 = r * sin(lat2) ./ cos(lat2);
  cu1 = one ./ sqrt(tu1 .* tu1 + one);
  su1 = cu1 .* tu1;
  cu2 = one ./ sqrt(tu2 .* tu2 + one);
  s = cu1 .* cu2;
  baz = s .* tu2;
  faz = baz .* tu1;
  x = lon2 - lon1;

  repeat = 1;

  while repeat == 1,

    sx = sin(x);
    cx = cos(x);
    tu1 = cu2 .* sx;
    tu2 = baz - su1 .* cu2 .* cx;
    sy = sqrt(tu1 .* tu1 + tu2 .* tu2);
    cy = s .* cx + faz;
    y = atan2(sy, cy);
    sa = s .* sx ./ sy;
    c2a = -sa .* sa + one;
    cz = faz + faz;

    ii = c2a > 0;

    cz(ii) = -cz(ii) ./ c2a(ii) + cy(ii);

    e = cz .* cz * two - one;
    c = ((-three * c2a + four) * f + four) .* c2a * f / sixteen;
    d = x;
    x = ((e .* cy .* c + cz) .* sy .* c + y) .* sa;
    x = (one - c) .* x * f + lon2 - lon1;

    if all(abs(d-x) <= eps0),
      break
    end

  end

  faz = atan2(tu1,tu2);
  baz = atan2(cu1 .* sx, baz .* cx - su1 .* cu2) + pi;
  x = sqrt((one / r / r - one) .* c2a + one) + one;
  x = (x - two) ./ x;
  c = one - x;
  c = (x .* x / four + one) ./ c;
  d = (three_eighths * x .* x - one) .* x;
  x = e .* cy;
  s = one - e - e;
  s = ((((sy .* sy * four - three) .* s .* cz .* (d / six) - x) .* ...
      (d / four) + cz) .* sy .* d + y) .* c * a * r;

%------------------------------------------------------------------------------
% Map to outputs.
%------------------------------------------------------------------------------
  s_out(~equal) = s;
  faz_out(~equal) = faz;
  baz_out(~equal) = baz;

%------------------------------------------------------------------------------
% Output conversions.
%------------------------------------------------------------------------------
  faz_out(deg_out == 1) = faz_out(deg_out == 1) * rad2deg;
  baz_out(deg_out == 1) = baz_out(deg_out == 1) * rad2deg;

  if nargout == 1,
    s_out = [s_out faz_out baz_out];
  end

end

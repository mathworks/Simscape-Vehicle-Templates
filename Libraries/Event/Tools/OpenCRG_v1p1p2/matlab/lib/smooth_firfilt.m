function [y] = smooth_firfilt(x, w, opts)
% SMOOTH_FIRFILT smoothen input signals with symmetric FIR filter.
%   Y = SMOOTH_FIRFILT(X, W, OPTS) smoothens inputs signals using
%   symmetric moving average (and some relatives of it) FIR filtering.
%
%   Inputs:
%   X       Data to be smoothened. If X is a matrix, SMOOTH_FILTER operates
%           on the columns of X.
%   W       FIR filter window width on each side of the center value.
%   OPTS    (optional) stuct array with
%       .reflect    reflection mode to extrapolate input data at begin and
%                   end to have start-up and ending transients as desired.
%                   'line' extrapolates by (line) reflection at begin and
%                   end of data (default).
%                   'point' extrapolates by point reflection at begin and
%                   end of data.
%                   'const' extrapolates with constant value at begin and
%                   end of data.
%                   'zero' extrapolates with zero value at begin and end of
%                   data.
%       .window     filter window type (see also at
%                   http://en.wikipedia.org/wiki/Window_function) All
%                   windows are constructed to have non-zero end points.
%                   'rectangular' generates a moving average (default).
%                   'triangular' uses a triangular window.
%                   'hann' uses a hann window.
%                   'sine' uses a sine window.
%
%   Outputs:
%   Y       Smoothened data.
%
%   Examples:
%   y = smooth_firfilt(x, 10)
%       generates results using symmetric moving average of 2*10+1 input
%       values using (line) reflection at begin and end of input data.
%   opts = struct
%   opts.reflect = 'point';
%   opts.window = 'triangular';
%   y = smooth_firfilt(x, 10, opts)
%       generates results using symmetric triangular weithted average of
%       2*10+1 input values using poiint reflection at begin and end of
%       input data.

%   Copyright 2011 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: smooth_firfilt.m 217 2011-02-06 19:54:42Z jorauh $

%% check inputs

if isempty(w) || length(w) > 1 || ~isnumeric(w) || ~isreal(w) || w~=round(w) || w<=0,
    error('Filter width must be a real, positive integer.')
end

if nargin < 3
    opts = struct;
end


%% recursive call for matrix input
% operate on columns as MATLAB filter function would do

[m,n] = size(x);
if (n>1) && (m>1)
    y = x;
    for i = 1:n
        y(:,i) = smooth_firfilt(x(:,i), w, opts);
    end
    return
end

%% handle input column vectors

if n==1
    x = x.'; % convert column to row
end

if length(x) <= w
    error('Data must have length greater than filter width.');
end

reflect = 'line';
if isfield(opts, 'reflect')
   reflect = opts.reflect;
end

window = 'rectangular';
if isfield(opts, 'window')
    window = opts.window;
end

% extend input vector by filter width

switch(reflect)
    case('line')
        xx = [       x(w+1:-1:2) x          x(end-1:-1:end-w)];
    case('point')
        xx = [2*x(1)-x(w+1:-1:2) x 2*x(end)-x(end-1:-1:end-w)];
    case('const')
        xx = [x(1)*ones(1,w)     x           x(end)*ones(1,w)];
    case('zero')
        xx = [zeros(1,w)         x                 zeros(1,w)];
    otherwise
        error('illegal opts.reflect value')
end

%% build symmetric filter

switch(window)
    case('rectangular')
        f = ones(1, w+1);
    case('triangular')
        f = 1:w+1;
    case('hann')
        f = 1 + cos((-w:0)*(pi/(w+1)));
    case('sine')
        f = sin((1:w+1)*(pi/2/(w+1)));
    otherwise
        error('illegal opts.window value')
end
f = [f f(end-1:-1:1)]; % line reflect filter coefficients

%% normalize filter

f = f / sum(f);

%% apply filter

y = zeros(size(x));
for i = 1:length(f)
    y = y + f(i)*xx(i:i-1+length(x));
end

%% convert output to column if input was column

if n == 1
    y = y(:);
end

end

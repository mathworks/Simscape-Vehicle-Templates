function [ data ] = crg_ext_slope( data, p )
% CRG_EXT_SLOPE extracts slope of a crg-file.
%   DATA = CRG_EXT_SLOPE(DATA, P) extracts slope.
%
%   Inputs:
%   DATA    struct array as defined in CRG_INTRO
%   P is the smooting parameter [0...1] (default 0.01)
%       0: LS-straight line
%       1: cubic spline interpolant
%
%   Outputs:
%   DATA    struct array as defined in CRG_INTRO
%
%   Examples:
%   data = crg_ext_slope( data, 0.01 )
%       extracts slope.
%   See also CRG_INTRO.

%   Copyright 2005-2010 OpenCRG - VIRES Simulationstechnologie GmbH - Holger Helmich
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
%   $Id: crg_ext_slope.m 25 2009-08-21 15:29:32Z helmich $

%% check input parameter

if nargin < 2, p = 0.01; end    % default smoothing parameter

if ~isfield(data, 'ok')
    data = crg_check(data);
    if ~isfield(data, 'ok')
        error('CRG:checkError', 'check of DATA was not completely successful')
    end
end

if p < 0 || p > 1
    error('CRG:checkError', 'smoothness parameter not in intervall [0,1]')
end

%% slope/banking exists

if isfield(data, 's')
    data = crg_s2z(data);
end

if isfield(data, 'b')
    tb = data.b;
    tbbeg = data.head.bbeg;
    tbend = data.head.bend;

    data = rmfield(data, 'b');
    data.head.bbeg = 0;
    data.head.bend = 0;
end

%% build uv

ubeg = data.head.ubeg;
uend = data.head.uend;
uinc = data.head.uinc;
u = ubeg:uinc:uend;

if isfield(data.head, 'vinc')
    vmin = data.head.vmin;
    vmax = data.head.vmax;
    vinc = data.head.vinc;
    v = vmin:vinc:vmax;
else
    v = data.v;
end

%% calculate regression smooth spline

nu = size(data.z,1);

puv = zeros(nu, 2);                   % get rz values
puv(:,1) = u;
pz = crg_eval_uv2z(data, puv);

ppxy = spl_smooth(u', pz, p, u);      % smooth slope

%% remove slope z-offset

xui = diff(double(ppxy))/double(uinc);

nxui = -xui;

data.s = single(nxui);

data.head.sbeg = nxui(1);
data.head.send = nxui(end);

data = rmfield(data, 'rx');
data = rmfield(data, 'ry');
data.head = rmfield(data.head, 'xbeg');
data.head = rmfield(data.head, 'ybeg');
data.head = rmfield(data.head, 'xend');
data.head = rmfield(data.head, 'yend');
data.head = rmfield(data.head, 'zbeg');
data.head = rmfield(data.head, 'zend');

dout = crg_check(data);

[XI, YI] = meshgrid(u, v);

z = crg_eval_uv2z(dout, [XI(:), YI(:)]);    % z-values with negative slope
z = reshape(z, size(XI,1), size(XI,2));

data.z = single(z');

clear nxui dout;

%% add slope/banking content

data.s = single(xui);
data.head.sbeg = xui(1);
data.head.send = xui(end);

if exist('tb', 'var')
    data.b = tb;
    data.head.bbeg = tbbeg;
    data.head.bend = tbend;

    clear tb tbbeg tbend;
end

clear xui;

%% check

data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check of DATA was not completely successful')
end

end % function crg_ext_slope( data, n )

%% spl_smooth

% download 2007-05-09
% http://www.maths.lth.se/matstat/wafo/download/wafo-2.1.1.zip
% - wafo/misc/smooth.m (re-named and modified by Jochen Rauh 2007-05-09)
% see also CSAPS of MATLAB Spline Toolbox if available

function [yy] = spl_smooth(x, y, p, xx, ext, v)
% SPL_SMOOTH Cubic smoothing spline.
%   YY = SPL_SMOOTH(X, Y, P, XX, EXT, V) calculates cubic smooting spline
%
%   X is the vector of independant data values
%   Y is the vector of dependant data values
%
%   P is the smooting parameter [0...1]
%       0: LS-straight line
%       1: cubic spline interpolant
%
%   XX is the optional vector of the x-coordinates in which to calculate
%       the smoothed function result YY.
%
%   EXT is an optional extrapolation flag
%       0: regular smoothing spline (default)
%       1: smoothing spline with a constraint on the ends to
%          ensure linear extrapolation outside the range of the data
%
%   V is the optional variance vector related to Y which
%       might be used to weight the importance of the Y members
%       (default:  ones(length(X),1))
%
%   YY is the result.
%       If XX was given, this are the calculated y-coordinates of the
%           smoothed function.
%       If XX was not given then YY contains the
%              pp-form of the spline, for use with PPVAL.
%
%  Given the approximate values
%
%                Y(i) = g(x(i))+e(i)
%
%  of some smooth function, g, where e(i) is the error. SMOOTH tries to
%  recover g from y by constructing a function, f, which  minimizes
%
%              P * sum (Y(i) - f(X(i)))^2/V(i)  +  (1-P) * int (f'')^2
%
%  The call  pp = spl_smooth(x,y,p)  gives the pp-form of the spline,
%  for use with PPVAL.
%
% Example:
%  x = linspace(0,1).';
%  y = exp(x)+1e-1*randn(size(x));
%  pp = spl_smooth(x,y,.9);
%  plot(x,y,x,spl_smooth(x,y,.99,x),'g',x,ppval(pp,x),'k',x,exp(x),'r')
%
% See also PPVAL.

% References:
%  Carl de Boor (1978)
%  Practical Guide to Splines
%  Springer Verlag
%  Uses EqXIV.6--9, pp 239

%   tested on: Matlab 4.x 5.x
%   History:
%    revised pab  26.11.2000
%    - added example
%    - fixed a bug: n=2 is now possible
%    revised by pab 21.09.99
%    - added v
%    revised by pab 29.08.99
%    - new extrapolation: ensuring that
%      the smoothed function has contionous derivatives
%      in the first and last knot
%    modified by Per A. Brodtkorb  23.09.98
%      secret option forcing linear extrapolation outside the ends when p>0

if (nargin<5)||(isempty(ext)),
  ext=0; %do not force linear extrapolation in the ends (default)
end

[xi,ind]=sort(x(:));
n = length(xi);
y = y(:);
if n<2,
   error('There must be >=2 data points.')
elseif any(diff(xi)<=0),
   error('Two consecutive values in x can not be equal.')
elseif n~=length(y),
   error('x and y must have the same length.')
end

if nargin<6||isempty(v),
  v = ones(n,1);  %not implemented yet
else
  v=v(:);
end

yi=y(ind); %yi=yi(:);

dx = diff(xi);
dydx = diff(yi)./dx;

if (n==2)  % straight line
  coefs=[dydx yi(1)];
else
  if ext && n==3, p = 0;end % Force LS-fit
  dx1=1./dx;
  Q = spdiags([dx1(1:n-2) -(dx1(1:n-2)+dx1(2:n-1)) dx1(2:n-1)],0:-1:-2,n,n-2);
  D = spdiags(v,0,n,n);  % The variance
  R = spdiags([dx(1:n-2) 2*(dx(1:n-2)+dx(2:n-1)) dx(2:n-1)],-1:1,n-2,n-2);

  QQ = (6*(1-p))*(Q.'*D*Q)+p*R;
  % Make sure Matlab uses symmetric matrix solver
  u  = 2*((QQ+QQ')\diff(dydx));                     % faster than u=QQ\(Q'*yi);
  ai = yi-6*(1-p)*D*diff([0;diff([0;u;0]).*dx1;0]); % faster than yi-6*(1-p)*Q*u

  % The piecewise polynominals are written as
  % fi=ai+bi*(x-xi)+ci*(x-xi)^2+di*(x-xi)^3
  % where the derivatives in the knots according to Carl de Boor are:
  %    ddfi  = 6*p*[0;u] = 2*ci;
  %    dddfi = 2*diff([ci;0])./dx = 6*di;
  %    dfi   = diff(ai)./dx-(ci+di.*dx).*dx = bi;

  ci = 3*p*[0;u];

  if ext && p~=0 && n>3, %Forcing linear extrapolation in the ends
    ci([2,  end]) = 0;
  % New call
  % fixing the coefficients so that we have continous
  % derivatives everywhere
    ai(1) = -(ai(3)-ai(2))*dx(1)/dx(2) +ai(2)+ ci(3)*dx(1)*dx(2)/3;
    ai(n) = (ai(n-1)-ai(n-2))*dx(n-1)/dx(n-2) +ai(n-1)+ ci(n-2)*dx(n-2)*dx(n-1)/3;
  end

  di    = diff([ci;0]).*dx1/3;
  bi    = diff(ai).*dx1-(ci+di.*dx).*dx;
  coefs = [di ci bi ai(1:n-1)];
end

pp = mkpp(xi,coefs);
if (nargin<4)||(isempty(xx)),
  yy = pp;
else
  yy = ppval(pp,xx);
end

end

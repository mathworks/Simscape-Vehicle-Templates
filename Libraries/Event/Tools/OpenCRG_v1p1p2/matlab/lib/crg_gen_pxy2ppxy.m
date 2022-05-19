function [ppxy] = crg_gen_pxy2ppxy(pxy, opts)
% CRG_GEN_PXY2PPXY CRG generates (smooth) polynomial through refpoints.
%   [PPXY] = CRG_GEN_PXY2PPXY(PXY, OPTS) generates a (smooth spline)
%   polynomial (in pp-form) through the given refpoints.
%
%   Inputs:
%   PXY     (np, 2) array of points in xy system
%   OPTS    stuct for method options (optional)
%       .sf_incr    splinefit break increment (default: 2.0)
%       .ss_spar    splsmooth smooting parameter (default: depends on data)
%
%   Outputs:
%   PPXY    complex piecewise polynomial (e.g. spline) in pp-form
%           describing the (smoothed) refline.
%
%   Examples:
%   [ppxy] = crg_gen_pxy2ppxy(pxy)
%       generates a smooth spline of given refpoints.
%
%   See also CRG_GEN_PPXY2PHI, CRG_INTRO.

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
%   $Id: crg_gen_pxy2ppxy.m 184 2010-09-22 07:41:39Z jorauh $

%% set defaults for optional arguments

if nargin < 2
    opts = struct;
end

%% complex handling of real xy points makes some things simpler ...

cxy = complex(pxy(:, 1)', pxy(:, 2)');

%% build chainage of points (defined by distances of subsequent points)

sxy = [0 cumsum(abs(diff(cxy)))];  % chainage of points

%% eliminate consecutive pxy/cxy duplicates (with 0 chainage increment)

[sxy, m, n] = unique(sxy); %#ok<NASGU>
cxy = cxy(m);
clear m n

%% reduce number of points to a reasonable amount

if isfield(opts, 'sf_incr')
    sf_incr = opts.sf_incr;
else
    sf_incr = 2.0;
end

if mean(diff(sxy)) < 0.25*sf_incr
    sxy1 = linspace(sxy(1), sxy(end), ceil((sxy(end)-sxy(1))/sf_incr));
    % TODO: alternativ auch jeder n-te (erhält Dichteverteilung)

    % splinefit only works on real data ...

    ppx = splinefit(sxy, real(cxy), sxy1);
    ppy = splinefit(sxy, imag(cxy), sxy1);
    ppxy = ppx;
    ppxy.coefs = complex(ppx.coefs, ppy.coefs);
    clear ppx ppy

    %replace original points by smoothed fit

    sxy = sxy1;
    cxy = ppval(ppxy, sxy);
end

%% smoothen points

if isfield(opts, 'ss_spar')
    ss_spar = opts.ss_spar;
else
    ss_spar = 1-1.0/(1.0 + mean(diff(sxy))^3/0.6);
end

%ppxy = csaps(sxy, cxy, ss_spar);
ppxy = spl_smooth(sxy, cxy, ss_spar);

end

%% splinefit

% download 2009-07-06
% http://www.mathworks.com/matlabcentral/fileexchange/13812

% Copyright (c) 2009, Jonas Lundgren
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

function pp = splinefit(x,y,arg3)
%SPLINEFIT Fit a cubic spline to noisy data.
%   PP = SPLINEFIT(X,Y,XB) fits a piecewise cubic spline with breaks
%   (or knots) XB to the noisy data (X,Y). X is a vector and Y is a vector
%   or an ND array. If Y is an ND array, then X(j) and Y(:,...,:,j) are
%   matched. XB may or may not be a subset of X. Use PPVAL to evaluate PP.
%
%   PP = SPLINEFIT(X,Y,M) where M is a positive integer takes XB as a
%   subset of X according to: XS = SORT(X), XB = XS(1:M:end). A large M
%   means few breaks and a smooth spline. Default is M = 4.
%
%   Example:
%       x = cumsum(rand(1,50));
%       y = sin(x/2) + cos(x/4) + 0.05*randn(size(x));
%       pp = spline(x,y);
%       qq = splinefit(x,y,6);
%       xx = linspace(min(x),max(x),400);
%       yy = ppval(pp,xx);
%       zz = ppval(qq,xx);
%       plot(x,y,'bo',xx,yy,'r',xx,zz,'k')
%       legend('NOISY DATA','SPLINE','SPLINEFIT','Location','Best')
%
%   See also PPVAL, SPLINE, PPFIT

%   Author: jonas.lundgren@saabgroup.com, 2009.

%   2009-05-15  Bug fix for ND arrays.

if nargin < 2, help splinefit, return, end
if nargin < 3, arg3 = 4; end

% Check data
x = x(:);
mx = length(x);             % Number of data points

% Treat ND array
dim = size(y);
while length(dim) > 2 && dim(end) == 1
    dim(end) = [];
end

if length(dim) > 2
    % ND array
    my = dim(end);
    dim(end) = [];
    y = reshape(y,prod(dim),my);
    y = y.';
elseif dim(2) > 1
    % 2D array
    my = dim(2);
    dim(2) = [];
    y = y.';
else
    % Column vector
    my = dim(1);
    dim = 1;
end

% Check dimensions
if mx ~= my
    msgid = 'SPLINEFIT:DataDimensions';
    message = 'Last dimension of array Y must equal length of vector X!';
    error(msgid,message)
end

% Sort data
if any(diff(x) < 0)
    [x,isort] = sort(x);
    y = y(isort,:);
end

% Treat breaks
if numel(arg3) == 1
    if ~isreal(arg3) || mod(arg3,1) || arg3 < 1
        msgid = 'SPLINEFIT:BreakCount';
        message = 'Third argument must be a vector or a positive integer!';
        error(msgid,message)
    end
    xb = x(1:arg3:end);
else
    xb = arg3(:);
end

% Unique breaks
if any(diff(xb) <= 0)
    xb = unique(xb);
end

% Ensure at least two breaks
if length(xb) < 2
    xb = [x(1); x(mx)];
    if xb(1) == xb(2)
        xb(2) = xb(1) + 1;
    end
end

% Dimensions
nb = length(xb);            % Number of breaks
nu = 2*nb;                  % Number of unknowns
mb = nb - 2;                % Number of smoothness conditions
nr = nb + 2;                % Dimension of null space base

% Scale data
xb0 = xb;
scale = (nb-1)/(xb(nb)-xb(1));
if scale > 10 || scale < 0.1
    x = scale*x;
    xb = scale*xb;
end

% Interval lengths
hb = diff(xb);
% Negative powers of interval lengths
r1 = 1./hb;
r2 = r1./hb;
r3 = r2./hb;

% Is the mesh uniform?
hm = (xb(nb)-xb(1))/(nb-1);
uniform = max(abs(hb - hm)) < 10*eps(max(abs(xb([1 nb]))));

% Adjust limits
xlim = xb;
xlim(1) = -Inf;
xlim(end) = Inf;

% Bin data
[junk,ibin] = histc(x,xlim);

% Evaluate polynomial base
t = (x - xb(ibin))./hb(ibin);
t2 = t.*t;
t3 = t2.*t;
p1 = 2*t3 - 3*t2 + 1;
p2 = hb(ibin).*(t3 - 2*t2 + t);
p3 = -2*t3 + 3*t2;
p4 = hb(ibin).*(t3 - t2);

% Set up system matrix A
ii = repmat(1:mx,1,4);
jj = [2*ibin-1; 2*ibin; 2*ibin+1; 2*ibin+2];
A = sparse(ii, jj, [p1; p2; p3; p4], mx, nu);

% Set up smoothness matrix B (continuous curvature)
curv1 = [6*r2(1:mb); 2*r1(1:mb); -6*r2(1:mb); 4*r1(1:mb)];
curv2 = [6*r2(2:mb+1); 4*r1(2:mb+1); -6*r2(2:mb+1); 2*r1(2:mb+1)];
ii = repmat(1:mb,1,4);
jj = [1:2:nu-5, 2:2:nu-4, 3:2:nu-3, 4:2:nu-2];
B = sparse(ii, jj, curv1, mb, nu, 6*nb);
B = B + sparse(ii, jj+2, curv2, mb, nu);

% Set up coefficient transformation matrix C
ii = repmat(1:nb-1,1,4);
ii = [ii, ii+nb-1, 2*nb-1:4*nb-4];
jj = [1:2:nu-3, 2:2:nu-2, 3:2:nu-1, 4:2:nu];
jj = [jj, jj, 2:2:nu-2, 1:2:nu-3];
cc = [2*r3; r2; -2*r3; r2; -3*r2; -2*r1; 3*r2; -r1; ones(2*nb-2,1)];
C = sparse(ii, jj, cc, 4*nb-4, nu);

% Compute a base Z for the null space of B (B*Z = 0)
if nb < 60
    % QR-factorization is efficient for small problems
    [Q,R] = qr(full(B')); %#ok<NASGU>
    Z = Q(:,mb+1:nu);
else
    % For larger problems we need a sparse null space base.
    % The following is an adaption of the Turnback Algorithm.
    % See for example: Berry, et al, An algorithm to compute a sparse basis
    % of the null space, Numer Math, Vol 47, pp 483-504.
    k = 0;
    % Indices for the submatrices of B
    imin = [1 1 1 1 1:mb];
    imax = [1:mb mb mb mb mb];
    kmin = [1:4, 5:2:nu-1];
    kmax = [2:2:nu-4, nu-3:nu];
    % Allocate space for Z
    Z = spalloc(nu, nr, 6*nr);
    % Loop over null vectors
    for j = 1:nr
        k0 = k;
        k = kmax(j) - kmin(j);
        % For a uniform mesh we can reuse null vectors
        if ~uniform || k ~= k0
            % Each submatrix Bj determines a null vector
            Bj = B(imin(j):imax(j),kmin(j):kmax(j));    % k by k+1
            z = [-Bj(:,1:k)\Bj(:,k+1); 1];
        end
        Z(kmin(j):kmax(j),j) = z;
    end
end

% Solve: Minimum norm(A*u - y) subject to B*u = 0
G = A*Z;
u = Z*(G\y);

% Compute polynomial coefficients
coefs = C*u;
coefs = reshape(coefs.',[],4);

% Scale coefficients
if scale > 10 || scale < 0.1
    scalepow = repmat(scale.^[3 2 1 0], (nb-1)*prod(dim), 1);
    coefs = scalepow.*coefs;
end

% Make piecewise polynomial
pp.form = 'pp';
pp.breaks = xb0';
pp.coefs = coefs;
pp.pieces = nb-1;
pp.order = 4;
pp.dim = dim;

end

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

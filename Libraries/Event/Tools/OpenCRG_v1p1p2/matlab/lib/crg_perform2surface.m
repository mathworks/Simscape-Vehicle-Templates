function [data] = crg_perform2surface(data, uv_surf, oper)
% CRG_PERFORM2SURFACE synthetical surface generation.
%   [DATA] = CRG_PERFORM2SURFACE(DATA,UV_SURF,OPER) checks CRG data
%   and perform it to surface data
%
%   Inputs:
%   DATA      struct array as defined in CRG_INTRO.
%   UV_SURF   cell array with surface data
%   OPER      operator which is performed to the data
%
%   Outputs:
%   DATA    is a checked, purified, and eventually completed version of
%           the function input argument DATA
%
%   Examples:
%   data = crg_perform2surface(data, uv_surf, 'add');
%
%   See also CRG_DEMO_GEN_SL_SURF, CRG_DEMO_GEN_SL_MUE,
%   CRG_DEMO_GEN_SYN_ROAD, CRG_INTRO.

%   Copyright 2005-2011 OpenCRG - Daimler AG - Klaus Mueller
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
%   $Id: crg_perform2surface.m 217 2011-02-06 19:54:42Z jorauh $

%% check number of arguments

error(nargchk(3, 3, nargin));

%% check input data struct

data = crg_check(data);
if ~isfield(data, 'ok')
    error('CRG:checkError', 'check CRG data was not completely successful')
end

%% evaluate/extract u and v
ubeg = data.head.ubeg;
uend = data.head.uend;
uinc = data.head.uinc;
u = (ubeg:uinc:uend)';

if isfield(data.head, 'vinc')
    vmin = data.head.vmin;
    vmax = data.head.vmax;
    vinc = data.head.vinc;
    v = vmin:vinc:vmax;
else
    v = data.v;
end

vmin = v(1);
vmax = v(end);

[nu nv] = size(data.z);

%% check of mismatch between data.v and data of uv_surf

posmode = {'Ignore' 'Profile' 'Random'};
vs = crg_check_uv_descript(uv_surf, posmode);
vl = zeros(size(vs));
for ii = 1:length(vl)
    vl(ii) = find((v - data.opts.ceps) < vs(ii) & (v + data.opts.ceps) > vs(ii));
end
if ~all(vl)
    error('CRG:checkError', 'Mismatch between data.v and the corresponding data of uv_surf');
end

%% check the operator

posoper = {'add' 'multiply'};
switch char(posoper(strmatch(lower(strtrim(oper)),lower(posoper))))
    case 'add'
        oper = 'add';
    case 'multiply'
        oper = 'multiply';
    otherwise
        error('CRG:checkError', 'Not a valid operand which can be performed to the data');
end

%% now perform profile(s) and random surfaces if present

[vn vm] = size(uv_surf);
for ii = 1:vn
    switch char(posmode(strmatch(lower(strtrim(uv_surf{ii,1}{1,1})),lower(posmode))))
        case 'Ignore'
        case 'Profile'
            us = interp1(uv_surf{ii,1}{1,2}(1,:), uv_surf{ii,1}{1,2}(2,:), u, 'linear', 0);
            vs = interp1(uv_surf{ii,1}{1,3}(1,:), uv_surf{ii,1}{1,3}(2,:), v, 'linear', 0);
            if strcmp(oper,'add')     , identelem = 0; end
            if strcmp(oper,'multiply'), identelem = 1; end
            [ubind, ueind] = rangeind(us, @(x) find((x ~= identelem) | (x == identelem)));
            [vbind, veind] = rangeind(vs, @(x) find((x ~= identelem) | (x == identelem)));
            for jj = 1:length(ubind)
                ub = ubind(jj); ue = ueind(jj);
                for kk = 1:length(vbind)
                    vb = vbind(kk); ve = veind(kk);
                    if strcmp(oper,'add')
                        data.z(ub:ue,vb:ve) = data.z(ub:ue,vb:ve) + single(us(ub:ue)*vs(vb:ve));
                    end
                    if strcmp(oper,'multiply')
                       data.z(ub:ue,vb:ve) = data.z(ub:ue,vb:ve) .* single(us(ub:ue)*vs(vb:ve));
                    end
                end
            end
            txtnum = length(data.ct) + 1; data.ct{txtnum} = ['CRG lateral and longitudinal profile uv_surf(' num2str(ii) ') performed to surface'];
        case 'Random'
            us = interp1(uv_surf{ii,1}{1,2}(1,:), uv_surf{ii,1}{1,2}(2,:), u, 'linear', 0);
            vs = interp1(uv_surf{ii,1}{1,3}(1,:), uv_surf{ii,1}{1,3}(2,:), v, 'linear', 0);
            if strcmp(oper,'add')     , identelem = 0; end
            if strcmp(oper,'multiply'), identelem = 1; end
            [ubind, ueind] = rangeind(us, @(x) find((x ~= identelem) | (x == identelem)));
            [vbind, veind] = rangeind(vs, @(x) find((x ~= identelem) | (x == identelem)));
            rand('twister',5489);    % default initial state
            rand('twister', uv_surf{ii,1}{1,4});
            if isfloat(uv_surf{ii,1}{1,5}), amplmin = uv_surf{ii,1}{1,5}; end
            if isfloat(uv_surf{ii,1}{1,6}), amplmax = uv_surf{ii,1}{1,6}; end
            if isfloat(uv_surf{ii,1}{1,7}) && uv_surf{ii,1}{1,7} >= 0 && uv_surf{ii,1}{1,7} <= 1
                u_smooth = uv_surf{ii,1}{1,7};
            else
                error('CRG:checkError', 'Parameter for smoothing in u-direction must be in the range 0 .. 1');
            end
            if isfloat(uv_surf{ii,1}{1,8}) && uv_surf{ii,1}{1,8} >= 0 && uv_surf{ii,1}{1,8} <= 1
                v_smooth = uv_surf{ii,1}{1,8};
            else
                error('CRG:checkError', 'Parameter for smoothing in v-direction must be in the range 0 .. 1');
            end
            for jj = 1:length(ubind)
                ub = ubind(jj); ue = ueind(jj);
                for kk = 1:length(vbind)
                    vb = vbind(kk); ve = veind(kk);
                    zr = -1 + 2*rand(ue-ub+1,ve-vb+1);
                    zk = (ones(min(round(u_smooth*size(zr,1)+1),size(zr,1)),1)*ones(1,min(round(v_smooth*size(zr,2)+1),size(zr,2))));
                    zr = conv2(zr,zk,'same');
                    zr = zr - min(min(zr));
                    zr = zr./max(max(zr));
                    zr = amplmin + (amplmax-amplmin).*zr;
                    zr = zr.*(us(ub:ue)*vs(vb:ve));
                    if strcmp(oper,'add')
                        data.z(ub:ue,vb:ve) = data.z(ub:ue,vb:ve) + single(zr);
                    end
                    if strcmp(oper,'multiply')
                        data.z(ub:ue,vb:ve) = data.z(ub:ue,vb:ve) .* single(zr);
                    end
                end
            end
            txtnum = length(data.ct) + 1; data.ct{txtnum} = ['CRG random uv_surf(' num2str(ii) ') performed to surface'];
        otherwise;
            tmp = strcat({' '''},posrandmode,{''''});
            error('CRG:checkError', ['Cell array element of uv_surf{' num2str(ii) ',1}(1,5) must be one unambiguously abbrivation out of the strings: ' cat(2,tmp{:})]);
    end
end

end % crg_perform2surface

%% rangeind

function [ ibeg, iend ] = rangeind(a, afct)
% Linear range indices of contiguous elements which satisfy the condition of an anonymous function
%
% [IBEG, IEND] = RANGEIND(A, AFCT)
% The output IBEG returns the linear start indices and IEND the linear end indices of
% each section of the elements of input A which satisfy the condition of the anonymous function AFCT.
% If all elements do not satisfy the condition of the anonymous function AFCT,
% empty linear indices IBEG and IEND returned.
%
%   Inputs:
%   a       array
%   afct    anonymous function => typical example: @(x) find(x<0.9*pi & x>1.1*pi)
%
%   Outputs:
%   ibeg     linear start indices
%   iend     linear end   indices
%
% Example(s):
%
% [a,o]=rangeind([ 0  1.1  1.11  0  1.2  1.22  0  ],@(x) find(x >= 1 & x < 1.22 ,2,'last'))
% a =
%      3     5
% o =
%      3     5
%
% [a,o]=rangeind(['a' 'b'  'b' ' ' 'd' ],@(x) find(x > 'a' | x == 'd' ))
% a =
%      2     5
% o =
%      3     5
%
% [a,o]=rangeind([ 1 0 2 0 3 ]',@(x) find(x > 1))
% a =
%      3
%      5
% o =
%      3
%      5
%
% See also find, ind2sub
%
% Copyright 2011 by DC
% Written by Klaus Mueller 21-Jan-2011
%
% Reference:
%

error(nargchk(2, 2, nargin));
error(nargoutchk(0, 2, nargout));

if ~isa(afct,'function_handle')
    error('Second parameter must be a valid function_handle ...');
end

ibeg = [];
iend = [];
numela = numel(a);
if numela > 0
    if size(a,1) == 1    % is row vector => conform to find
        tf = zeros(1,numela+2);
    else
        tf = zeros(numela+2,1);
    end
    ind = afct(a) + 1;
    tf(ind) = 1;
    dtf  = diff(tf);
    ibeg = find( dtf > 0 );
    iend = find( dtf < 0 ) - 1;
end

end % rangeind

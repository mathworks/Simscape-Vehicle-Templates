function [ident, dd] = crg_isequal( bcrg, acrg )
% CRG_ISEQUAL compares two CRG-files if equal
%   [IDENT, DD] = CRG_ISEQUAL( BCRG, ACRG ) checks if isequal
%
%   Input:
%       BCRG    struct array as defined in CRG_INTRO
%       ACRG    struct array as defined in CRG_INTRO
%
%   Output:
%       IDENT   [true, false] identical boolian variable
%       DD      struct array with further comparison informations
%               warn    warning messages
%               err     error messages
%               fn      compared field names
%               u       u-space
%               v       v-space
%               mean    arithmetic average(absolute)
%               rmean   arithmetic average(relative)
%
%   Example:
%   [crgIsEqual, dd] = crg_isequal( crg_one, crg_two, 'html') compares two
%   CRG-files if equal and visualize on default system web browser
%
%   See also CRG_INTRO

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
%   $Id: crg_isequal.m 2009-08-27 13:11:00Z hhelmich $

%% check if already succesfully checked

if ~isfield( bcrg, 'ok' )
    bcrg = crg_check( bcrg );
    if ~isfield( bcrg, 'ok' )
        error( 'CRG:checkError', 'check of bcrg was not completely successful' )
    end
end

if ~isfield( acrg, 'ok' )
    acrg = crg_check( acrg );
    if ~isfield( acrg, 'ok' )
        error( 'CRG:evalError', 'check of acrg was not completely successful' )
    end
end

%% simplify data access

ceps = max(acrg.opts.ceps, bcrg.opts.ceps);
ctol = max(acrg.opts.ctol, bcrg.opts.ctol);

aba = acrg;
bba = bcrg;

dd = struct;
dd.warn = cell(1,0);
dd.err = cell(1,0);

ident = 0;                 % assume both files are not equal

%% minimal common struct fields

a_fn = fieldnames(aba);         % top fieldnames acrg
fn = isfield(bba, a_fn);
fn = strcmp(a_fn, 'b') + fn;   % exceptions
fn = strcmp(a_fn, 's') + fn;
fn = strcmp(a_fn, 'rz') + fn;

if ~all(fn)
    aba = rmfield(aba,a_fn(~fn));
    dd.warn{end+1} = sprintf('fields in acrg are dropped: "%s"', char(a_fn(~fn)));
end

b_fn = fieldnames(bba);         % top fieldnames bcrg
fn = isfield(aba, b_fn);
fn = strcmp(b_fn, 'b') + fn;   % exceptions
fn = strcmp(b_fn, 's') + fn;
fn = strcmp(b_fn, 'rz') + fn;

if ~all(fn)
    bba = rmfield(bba,b_fn(~fn));
    dd.warn{end+1} = sprintf('fields in bcrg are dropped: "%s".', char(b_fn(~fn)));
end

% which fields are compared
dd.fn = fieldnames(aba);

clear fn;

%% each fieldname

for i = 1:length(dd.fn)
    switch char(dd.fn(i,1))
        case 'u'
             if size(bba.u) ~= size(aba.u)
                 dd.err{end+1} = sprintf('different u-dimension');
             end
             if abs(bba.u - aba.u) > max(ceps*(bba.u + aba.u),ctol)
                 dd.err{end+1} = sprintf('u-spacing of CRG-files are not equal');
             end
        case 'v'
             if size(bba.v) ~= size(aba.v)
                 dd.err{end+1} = sprintf('different v-dimension');
             end
             if abs(bba.v - aba.v) > max(ceps*(bba.v + aba.v),ctol)
                 dd.err{end+1} = sprintf('cross cut positions are not equal');
             end
        case 'head'
            if abs(bba.head.ubeg - aba.head.ubeg) > max(ceps*(bba.head.ubeg + aba.head.ubeg),ctol)
                dd.err{end+1} = ('ubeg of CRG-files are not equal');
            end
            if abs(bba.head.uend - aba.head.uend) > max(ceps*(bba.head.uend + aba.head.uend),ctol)
                dd.err{end+1} = ('uend of CRG-files are not equal');
            end
            if abs(bba.head.uinc - aba.head.uinc) > max(ceps*(bba.head.uinc + aba.head.uinc),ctol)
                dd.err{end+1} = ('uinc of CRG-files are not equal');
            end
            if abs(bba.head.vmin - aba.head.vmin) > max(ceps*(bba.head.vmin + aba.head.vmin),ctol)
                dd.err{end+1} = ('vmin of CRG-files are not equal');
            end
            if abs(bba.head.vmax - aba.head.vmax) > max(ceps*(bba.head.vmax + aba.head.vmax),ctol)
                dd.err{end+1} = ('vmax of CRG-files are not equal');
            end
            if abs(bba.head.xbeg - aba.head.xbeg) > max(ceps*(bba.head.xbeg + aba.head.xbeg),ctol)
                dd.err{end+1} = ('xbeg of CRG-files are not equal');
            end
            if abs(bba.head.xend - aba.head.xend) > max(ceps*(bba.head.xend + aba.head.xend),ctol)
                dd.err{end+1} = ('xend of CRG-files are not equal');
            end
            if abs(bba.head.ybeg - aba.head.ybeg) > max(ceps*(bba.head.ybeg + aba.head.ybeg),ctol)
                dd.err{end+1} = ('ybeg of CRG-files are not equal');
            end
            if abs(bba.head.yend - aba.head.yend) > max(ceps*(bba.head.yend + aba.head.yend),ctol)
                dd.err{end+1} = ('yend of CRG-files are not equal');
            end

            if isfield(bba.head, 'vinc') && isfield(aba.head, 'vinc')
                if abs(bba.head.vinc - aba.head.vinc) > max(ceps*(bba.head.vinc + aba.head.vinc),ctol)
                    dd.err{end+1} = ('vinc of CRG-files are not equal');
                end
            end
        case 'z'
            if size(bba.z) ~= size(aba.z)
                 dd.err{end+1} = sprintf('different z-dimension');
            end
        otherwise
            dd.warn{end+1} = sprintf('field %s not considered', char(dd.fn(i,1)));
    end
end

% build uv
ubeg = aba.head.ubeg;
uend = aba.head.uend;
uinc = aba.head.uinc;
u = ubeg:uinc:uend;

if isfield(aba.head, 'vinc')
    vmin = aba.head.vmin;
    vmax = aba.head.vmax;
    vinc = aba.head.vinc;
    v = vmin:vinc:vmax;
else
    v = aba.v;
end

% check data.z field

[XI, YI] = meshgrid(u, v);

pza = crg_eval_uv2z(aba, [XI(:), YI(:)]);
pzb = crg_eval_uv2z(bba, [XI(:), YI(:)]);

pza = reshape(pza, size(XI,1), size(XI,2));
pzb = reshape(pzb, size(XI,1), size(XI,2));

clear XI YI;

% difference

dd.u = u;
dd.v = v;

dd.mean = abs(pza - pzb);           % arithmetic average
dd.rmean = (pza.\pzb - 1).*100;     % relative arithmetric average

if isempty(find(dd.mean < ceps == 0)) ...
        ||  isempty(find(~((dd.mean < ceps) == isnan(dd.mean)) == 0))
    ident = 1;
end

end % function crg_isequal

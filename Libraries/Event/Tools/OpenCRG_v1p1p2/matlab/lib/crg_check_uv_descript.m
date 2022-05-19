function [v] = crg_check_uv_descript(uv_descript, posmode)
% CRG_CHECK_UV_DESCRIPT perform a simple check of uv_descript and create a v profile
%   CRG_CHECK_UV_DESCRIPT(UV_DESCRIPT, POSMODE) checks whether the uv description (see below)
%   is in a valid form and returns the associated v profile otherwise an error occures.
%   Each row of the UV_DESCRIPT must be out of the following style:
%
%   { 'Profile' [u_sect ; u_prof] [v_sect ; vr_prof] }
%   or
%   { 'Ignore' [u_sect ; u_prof] [v_sect ; vr_prof] }
%   or
%   { 'Random' [u_sect ; u_prof] [v_sect ; vr_prof] initval amp_min amp_max u_smooth v_smooth }
%   or
%   { 'Ignore' [u_sect ; u_prof] [v_sect ; vr_prof] initval amp_min amp_max u_smooth v_smooth }
%
%   Example of uv_descript:
%                       mode
%                       |          u section       u profile         v section       v profile        valid only for random profile(s)
%                       |          |               |                 |               |                /----------^----------\
%    UV_DESCRIPT = { ...
%                  ; { 'Profile' [ uwp_road_sect ; uwp_road_prof ] [ vwp_road_sect ; vwp_road_prof  ]                        } ...
%                  ; { 'Random'  [ ulr_lane_sect ; ulr_lane_prof ] [ vlr_lane_sect ; vlr_lane_prof  ] 2010  0.5  1  0.4  0.4 } ...
%                  ; { 'Ignore'  [ ulp_lane_sect ; ulp_lane_prof ] [ vlp_lane_sect ; vlp_lane_prof  ]                        } ...
%                  ; { 'Profile' [ urp_lane_sect ; urp_lane_prof ] [ vrp_lane_sect ; vrp_lane_prof  ]                        } ...
%                  };
%                                                                                                     ^     ^   ^   ^    ^
%                                                                                                     |     |   |   |    |
%                                                                                                     |     |   |   |    v_smooth (random) in range 0 .. 1
%                                                                                                     |     |   |   u_smooth (random) in range 0 .. 1
%                                                                                                     |     |    max amplitude random
%                                                                                                     |     min amplitude random
%                                                                                                     initialize state of random generator
%
%  Inputs:
%   UV_DESCRIPT (see above)
%   POSMODE     cell string with possible modes (see mode in UV_DESCRIPT)
%               e.g. {'Profile' 'Random' 'Ignore' }
%                    'Ignore'    : ignore check
%                    'Profile'   : defined cross section
%                    'Random'    : random cross section
%
%   Outputs:
%   V           v profile
%
%   Example:
%   v = crg_check_uv_descript(uv_mue, {'Ignore' 'Profile' 'Random'});
%
%   See also CRG_INTRO,
%            CRG_DEMO_GEN_SL_ROAD, CRG_DEMO_GEN_SL_SURF, CRG_DEMO_GEN_SL_MUE,
%            CRG_PERFORM2SURFACE

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
%   $Id: crg_check_uv_descript.m 217 2011-02-06 19:54:42Z jorauh $

%% chech arguments and initialize
error(nargchk(2, 2, nargin));
error_cnt   = 0;
ignore_cnt  = 0;
profile_cnt = 0;
random_cnt  = 0;

v = [];

%% check uv_descript struct
[vn vm] = size(uv_descript);
for ii = 1:vn
    if iscellstr(uv_descript{ii,:}(1,1))
        switch char(posmode(strmatch(lower(strtrim(uv_descript{ii,1}{1,1})),lower(posmode))));
            case char(posmode(1))
                ignore_cnt = ignore_cnt + 1;
            case char(posmode(2))
                if ~isequal(size(uv_descript{ii,:}),[1 3])
                    error_cnt = error_cnt + 1;
                    warning('CRG:checkWarning', ['Cell array uv_descript{' num2str(ii) '} must be of type\n' '{ posmode(2) [u_sect ; u_prof] [v_sect ; vr_prof] }']);
                else
                    if  ~isequal(size(uv_descript{ii,1}{1,2}(1,:)), size(uv_descript{ii,1}{1,2}(2,:))) || ...
                        ~isequal(size(uv_descript{ii,1}{1,3}(1,:)), size(uv_descript{ii,1}{1,3}(2,:))) || ...
                        ~issorted(uv_descript{ii,1}{1,2}(1,:)) || ...
                        ~issorted(fliplr(uv_descript{ii,1}{1,3}(1,:)))
                        error_cnt = error_cnt + 1;
                        warning('CRG:checkWarning', ['Cell array uv_descript{' num2str(ii) '} size mismatch or u_sect, v_sect not sorted}']);
                    else
                        profile_cnt = profile_cnt + 1;
                    end
                end
            case char(posmode(3))
                if ~isequal(size(uv_descript{ii,:}),[1 8])
                    error_cnt = error_cnt + 1;
                    warning('CRG:checkWarning', ['Cell array uv_descript{' num2str(ii) '} must be of type\n' '{ posmode() [u_sect ; u_prof] [v_sect ; vr_prof] initval amp_min amp_max u_smooth v_smooth }']);
                else
                    if  ~isequal(size(uv_descript{ii,1}{1,2}(1,:)), size(uv_descript{ii,1}{1,2}(2,:))) || ...
                        ~isequal(size(uv_descript{ii,1}{1,3}(1,:)), size(uv_descript{ii,1}{1,3}(2,:))) || ...
                        ~issorted(uv_descript{ii,1}{1,2}(1,:)) || ...
                        ~issorted(fliplr(uv_descript{ii,1}{1,3}(1,:)))
                        error_cnt = error_cnt + 1;
                        warning('CRG:checkWarning', ['Cell array uv_descript{' num2str(ii) '} size mismatch or u_sect, v_sect not sorted}']);
                    else
                        random_cnt = random_cnt + 1;
                    end
                end
            otherwise
                error_cnt = error_cnt + 1;
                warning('CRG:checkWarning', ['A valid cell array uv_descript{' num2str(ii) '} must be one of type\n' ...
                    '{ ''' char(posmode(1)) ''' .. }' ...
                    '\n or \n' ...
                    '{ ''' char(posmode(2)) ''' [u_sect ; u_prof] [v_sect ; vr_prof] }' ...
                    '\n or \n' ...
                    '{ ''' char(posmode(3)) ''' [u_sect ; u_prof] [v_sect ; vr_prof] initval amp_min amp_max u_smooth v_smooth }']);
        end
    else
        error_cnt = error_cnt + 1;
        tmp = strcat({' '''},posmode,{''''});
        warning('CRG:checkWarning', ['Cell array element of uv_descript{' num2str(ii) ',1}(1,1) must be one unambiguously abbrivation out of the strings: ' cat(2,tmp{:})]);
    end
end

%% errors detectected ?
if ~isequal(error_cnt, 0) || isequal(profile_cnt + random_cnt, 0)
    error('CRG:checkError', 'No valid uv_descript is spezified');
end

%% generate lateral vector v out of uv_descript
for ii = 1:vn
    v = unique([v uv_descript{ii,1}{1,3}(1,:)]);
end

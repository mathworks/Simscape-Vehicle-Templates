function [ier] = crg_demo_gen_sl_mue(filename)
% CRG_DEMO_GEN_SL_MUE generate a synthetic crg-file.
%   CRG_DEMO_GEN_SL_MUE(filename) demonstrates how to generate a surface
%   with different friction coefficients
%
%  Inputs:
%   FILENAME    is the file to write
%
%   Outputs:
%   IER         error return code
%               = 0     successful
%               = -1    not successful
%
%   Example:
%   CRG_DEMO_GEN_SL_MUE('sl_mue.crg')   % generate a crg file
%
%   See also CRG_INTRO, CRG_GEN_CSB2CRG0, CRG_CHECK_UV_DESCRIPT,
%            CRG_PERFORM_2SURFACE

%   Copyright 2005-2010 OpenCRG - Daimler AG - Klaus Mueller
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
%   $Id: crg_demo_gen_sl_mue.m 217 2011-02-06 19:54:42Z jorauh $

%% check input parameter

ier = -1;
if ~exist('filename','var') || ~ischar(filename)
    error('CRG:checkError', 'No valid filename is spezified');
end

%% default settings

%% start of user settings

uinc =  0.2;
ubeg =  0;
uend =  200;

u = (ubeg:uinc:uend)';
c = {};
s = {};
b = {};

%% curvature

LC1  =  uend-ubeg;      R1s  =  inf;    R1e  =  inf;

c = { ...
    ;  LC1   { 1/R1s  ( 1/R1e  - 1/R1s  )/LC1  }  ...
    };

%% slope

LS1  = uend-ubeg;      S1s  =  0;        S1e  =  0;

s = { ...
    ; LS1   { S1s  ( S1e  - S1s  )/LS1  }  ...
    };

%% banking

LB1  = uend-ubeg;      B1s  =  0;        B1e  =  0;

b = { ...
    ; LB1   { B1s  ( B1e  - B1s  )/LB1  }  ...
    };


%% create longitudenal and lateral profile(s) like this

% u ----> coordinate          begin                                 middle sections                        end
% v ----> coordinate          left                                  origin                                 right
%  l ---> left  hand side
%  r ---> right hand side
%  w ---> width of whole road
%  c ---> center of road
%   p --> profile
%   r --> raughness
%    _ -> name_sect
%    _ -> name_prof
%                 offset or ampltitude to origin
%                 |
uwp_road_sect  =          [  ubeg                                                                         uend  ];    % road width       u sections
uwp_road_prof  =          [  1                                                                            1     ];
vwp_road_sect  =  0     + [  3                                     : -0.5 :                              -3     ];    % road width       v sect
vwp_road_prof  =  1     * [  ones(size(vwp_road_sect))                                                          ];

ulp_lane_sect  =          [  ubeg                                                                         uend  ];    % left lane        u sections
ulp_lane_prof  =          [  1                                                                            1     ];
vlp_lane_sect  =  1.25  + [  1                             : -0.2 :                                      -1     ];    % left lane        v sect
vlp_lane_prof  =  1     * [  1             0.8 0.8 0.6 0.6    0.6       0.6 0.6 0.8 0.8                   1     ];

ulr_lane_sect  =  100   + [  0    10                                                              50     60     ];    % left lane        u sections
ulr_lane_prof  =          [  1     0.8                                                             0.8    1     ];
vlr_lane_sect  =  1.25  + [  1                             : -0.2 :                                      -1     ];    % left lane        v sect
vlr_lane_prof  =  1     * [  ones(size(vlr_lane_sect))                                                          ];

urp_lane_sect  =          [  ubeg                   30  40    50   80     90                              uend  ];    % right lane       u sections
urp_lane_prof  =          [  1                       1  0.6   0.8  0.5    1                               1     ];
vrp_lane_sect  = -1.25  + [  1                                                                           -1     ];    % right lane       v sect
vrp_lane_prof  =  1     * [  1                                                                            1     ];

%             mode one of {'Profile' 'Random' 'Ignore' }
%             |          u section       u profile         v section       v profile        valid only for random profile(s)
%             |          |               |                 |               |                /----------^----------\
uv_mue = { ...
         ; { 'Profile' [ uwp_road_sect ; uwp_road_prof ] [ vwp_road_sect ; vwp_road_prof  ]                        } ...
         ; { 'Random'  [ ulr_lane_sect ; ulr_lane_prof ] [ vlr_lane_sect ; vlr_lane_prof  ] 2010  0.5  1  0.4  0.4 } ...
         ; { 'Profile' [ ulp_lane_sect ; ulp_lane_prof ] [ vlp_lane_sect ; vlp_lane_prof  ]                        } ...
         ; { 'Profile' [ urp_lane_sect ; urp_lane_prof ] [ vrp_lane_sect ; vrp_lane_prof  ]                        } ...
         };
%                                                                                           ^     ^   ^   ^    ^
%                                                                                           |     |   |   |    |
%                                                                                           |     |   |   |    v_smooth (random) in range 0 .. 1
%                                                                                           |     |   |   u_smooth (random) in range 0 .. 1
%                                                                                           |     |    max amplitude random
%                                                                                           |     min amplitude random
%                                                                                           initialize state of random generator

%% end of user settings

%% create and check lateral profile vector

v = crg_check_uv_descript(uv_mue, {'Ignore' 'Profile' 'Random'});

%% generate synthetical road map with mue = 1

data = crg_gen_csb2crg0(uinc, [ubeg uend], v, c, s, b);
txtnum = length(data.ct) + 1; data.ct{txtnum} = 'CRG curvature, slope, banking generated';

data = crg_perform2surface(data, uv_mue(1), 'add');
% data = crg_perform2surface(data, {{'Profile' [ uwp_road_sect ; uwp_road_prof ] [ vwp_road_sect ; vwp_road_prof ]}}, 'add');

%% perform synthetical mue

data = crg_perform2surface(data, uv_mue(2:end), 'mult');
txtnum = length(data.ct) + 1; data.ct{txtnum} = 'CRG synthetical mue performed to surface';


%% check and write data to file

txtnum = length(data.ct) + 1; data.ct{txtnum} = '... finished';
data = crg_single(data);
data = crg_check(data);
data.mods = [];
ier  = crg_write(data, filename);

end

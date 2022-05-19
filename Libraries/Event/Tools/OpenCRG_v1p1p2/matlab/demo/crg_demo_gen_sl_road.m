function [ier] = crg_demo_gen_sl_road(filename)
% CRG_DEMO_GEN_SL_ROAD CRG demo to generate a synthetic crg-file.
%   CRG_DEMO_GEN_SL_ROAD(FILENAME) demonstrates how a road inluding
%   walkline etc. can be generated.
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
%   crg_demo_gen_sl_road('synthetic_road.crg') % generate a crg file
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
%   $Id: crg_demo_gen_sl_road.m 217 2011-02-06 19:54:42Z jorauh $

%% check input parameter

ier = -1;
if ~exist('filename','var') || ~ischar(filename)
    error('CRG:checkError', 'No valid filename is spezified');
end

%% default settings


%% start of user settings

uinc =    0.5;
ubeg =  -20;
uend =  750;

u = ubeg:uinc:uend;

%% create longitudenal and lateral profile(s) like this

% u ----> coordinate         begin                  middle sections      end
% v ----> coordinate         left                   origin               right
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
uwp_road_sect  =          [  ubeg                                        uend  ];    % road width       u sections
uwp_road_prof  =  1     * [  1                                           1     ];
vwp_road_sect  =  0     + [  4                      0                   -4     ];    % road width       v sect
vwp_road_prof  =  0     * [  ones(size(vwp_road_sect))                         ];

ulp_walk_sect  =  400   + [  0    2       60      70                           ];    % sidewalk left hand side
ulp_walk_prof  =  1     * [  0    1        1       0                           ];
vlp_walk_sect  =  4     + [  2             0.01    0                           ];
vlp_walk_prof  =  0.02  * [  1             1       0                           ];

ulp_curb_sect  =          [  ubeg                                        uend  ];    % curb left hand side
ulp_curb_prof  =  1     * [  1                                           1     ];
vlp_curb_sect  =  6     + [  1             0.2     0                           ];
vlp_curb_prof  = -0.01  * [  1             1       0                           ];

urp_curb_sect  =          [  ubeg                                        uend  ];    % curb right hand side
urp_curb_prof  =  1     * [  1                                           1     ];
vrp_curb_sect  = -4     + [                        0   -0.3             -3     ];
vrp_curb_prof  = -0.01  * [                        0    1                1     ];

ulp_mark_sect  =          [  ubeg                                        uend  ];    % marking left hand side
ulp_mark_prof  =  1     * [  1                                           1     ];
vlp_mark_sect  =  3.5   + [  0.11     0.1                    -0.1      -0.11   ];
vlp_mark_prof  =  0.003 * [  0        1                       1         0      ];

ucp_mark_sect  =          [  u                                                 ];    % center road marking
ucp_mark_prof  =  1     * [  (mod(u,10)<0.4*10)                                ];    % 10 m period with 4m marking
vcp_mark_sect  =  0     + [  0.11     0.1                    -0.1       -0.11  ];
vcp_mark_prof  =  0.005 * [  0        1                        1         0     ];

urp_mark_sect  =          [  ubeg                                        uend  ];    % marking right hand side
urp_mark_prof  =  1     * [  1                                           1     ];
vrp_mark_sect  = -3.5   + [  0.11     0.1                    -0.1       -0.11  ];
vrp_mark_prof  =  0.002 * [  0        1                        1         0     ];

ulp_gutt_sect  =          [  ubeg                                        uend  ];    % gutter left hand side
ulp_gutt_prof  =  1     * [  1                                           1     ];
vlp_gutt_sect  =  3.8   + [  0.16     0.15                   -0.15     -0.16   ];
vlp_gutt_prof  = -0.01 * [  0        1                       1         0      ];

ulp_rut__sect  =          [  ubeg                                        uend  ];    % rut left hand side
ulp_rut__prof  =  1     * [  1                                           1     ];
vlp_rut__sect  = -0.75  + [                   0.3:-0.05:-0.3                   ];
vlp_rut__prof  = -0.005 * [          (cos(pi*(0.3:-0.05:-0.3)/0.6)).^2         ];

urp_rut__sect  =          [  ubeg                                        uend  ];    % rut right hand side
urp_rut__prof  =  1     * [  1                                           1     ];
vrp_rut__sect  = -2.75  + [                   0.3:-0.05:-0.3                   ];
vrp_rut__prof  = -0.008 * [          (cos(pi*(0.3:-0.05:-0.3)/0.6)).^2         ];

upvp = { ...
       ; { 'Profile' [ uwp_road_sect ; uwp_road_prof ] [ vwp_road_sect ; vwp_road_prof ] } ...  % road with lanes
       ; { 'Profile' [ ulp_mark_sect ; ulp_mark_prof ] [ vlp_mark_sect ; vlp_mark_prof ] } ...  % left   marker line
       ; { 'Profile' [ ucp_mark_sect ; ucp_mark_prof ] [ vcp_mark_sect ; vcp_mark_prof ] } ...  % center marker line
       ; { 'Profile' [ urp_mark_sect ; urp_mark_prof ] [ vrp_mark_sect ; vrp_mark_prof ] } ...  % right  marker line
       ; { 'Profile' [ ulp_gutt_sect ; ulp_gutt_prof ] [ vlp_gutt_sect ; vlp_gutt_prof ] } ...  % left  gutter
       ; { 'Profile' [ ulp_rut__sect ; ulp_rut__prof ] [ vlp_rut__sect ; vlp_rut__prof ] } ...  % left  rut
       ; { 'Profile' [ urp_rut__sect ; urp_rut__prof ] [ vrp_rut__sect ; vrp_rut__prof ] } ...  % right rut
       ; { 'Profile' [ ulp_walk_sect ; ulp_walk_prof ] [ vlp_walk_sect ; vlp_walk_prof ] } ...  % sidewalk on left hand side
       ; { 'Profile' [ ulp_curb_sect ; ulp_curb_prof ] [ vlp_curb_sect ; vlp_curb_prof ] } ...  % curb on left hand side
       ; { 'Profile' [ urp_curb_sect ; urp_curb_prof ] [ vrp_curb_sect ; vrp_curb_prof ] } ...  % curb on right hand side
       };

v = crg_check_uv_descript(upvp, {'Ignore' 'Profile' 'Random'});

%% curvature

LC1  =  120;      R1s  =  inf;    R1e  =  inf;
LC2  =   50;      R2s  =  inf;    R2e  =  -50;
LC3  =  185.5;    R3s  =  -50;    R3e  =  -50;
LC4  =   50;      R4s  =  -50;    R4e  =  inf;
LC5  =   65;      R5s  =  inf;    R5e  =  inf;
LC6  =   20;      R6s  =  inf;    R6e  =   30;
LC7  =  126.5;    R7s  =   30;    R7e  =   30;
LC8  =   10;      R8s  =   30;    R8e  =  inf;
LC9  =   10;      R9s  =  inf;    R9e  =  inf;

c = { ...
    ;  LC1   { 1/R1s  ( 1/R1e  - 1/R1s  )/LC1  }  ...
    ;  LC2   { 1/R2s  ( 1/R2e  - 1/R2s  )/LC2  }  ...
    ;  LC3   { 1/R3s  ( 1/R3e  - 1/R3s  )/LC3  }  ...
    ;  LC4   { 1/R4s  ( 1/R4e  - 1/R4s  )/LC4  }  ...
    ;  LC5   { 1/R5s  ( 1/R5e  - 1/R5s  )/LC5  }  ...
    ;  LC6   { 1/R6s  ( 1/R6e  - 1/R6s  )/LC6  }  ...
    ;  LC7   { 1/R7s  ( 1/R7e  - 1/R7s  )/LC7  }  ...
    ;  LC8   { 1/R8s  ( 1/R8e  - 1/R8s  )/LC8  }  ...
    ;  LC9   { 1/R9s  ( 1/R9e  - 1/R9s  )/LC9  }  ...
    };

%% slope

LS1  = 120;      S1s  =  0;        S1e  =  0;
LS2  =  25;      S2s  =  0;        S2e  =  0;
LS3  =  25;      S3s  =  0;        S3e  =  0.03;
LS4  = 185.5;    S4s  =  0.03;     S4e  =  0.03;
LS5  =  25;      S5s  =  0.03;     S5e  =  0;
LS6  =  25;      S6s  =  0;        S6e  =  0;
LS7  =  65;      S7s  =  0;        S7e  = -0.01;
LS8  =  20;      S8s  = -0.01;     S8e  = -0.04;
LS9  = 126.5;    S9s  = -0.04;     S9e  = -0.04;
LS10 =  20;      S10s = -0.04;     S10e =  0;

s = { ...
    ; LS1   { S1s  ( S1e  - S1s  )/LS1  }  ...
    ; LS2   { S2s  ( S2e  - S2s  )/LS2  }  ...
    ; LS3   { S3s  ( S3e  - S3s  )/LS3  }  ...
    ; LS4   { S4s  ( S4e  - S4s  )/LS4  }  ...
    ; LS5   { S5s  ( S5e  - S5s  )/LS5  }  ...
    ; LS6   { S6s  ( S6e  - S6s  )/LS6  }  ...
    ; LS7   { S7s  ( S7e  - S7s  )/LS7  }  ...
    ; LS8   { S8s  ( S8e  - S8s  )/LS8  }  ...
    ; LS9   { S9s  ( S9e  - S9s  )/LS9  }  ...
    ; LS10  { S10s ( S10e - S10s )/LS10 }  ...
    };

%% banking

LB1  = 120;      B1s  =  0;        B1e  =  0;
LB2  =  50;      B2s  =  0;        B2e  =  0.02;
LB3  = 185.5;    B3s  =  0.02;     B3e  =  0.02;
LB4  =  50;      B4s  =  0.02;     B4e  =  0;
LB5  =  65;      B5s  =  0;        B5e  = -0.02;
LB6  =  20;      B6s  = -0.02;     B6e  = -0.05;
LB7  = 126.5;    B7s  = -0.05;     B7e  = -0.02;
LB8  =  10;      B8s  = -0.02;     B8e  = -0.02;
LB9  =  10;      B9s  = -0.02;     B9e  =  0.0;

% coefficients for smooth non linear Banking (spline), a demonstration
B7_a =  1*B7s;
B7_b =  0;
B7_c =  3*( B7e  - B7s  )/LB7^2;
B7_d = -2*( B7e  - B7s  )/LB7^3;

b = { ...
    ; LB1   { B1s  ( B1e  - B1s  )/LB1  }  ...
    ; LB2   { B2s  ( B2e  - B2s  )/LB2  }  ...
    ; LB3   { B3s  ( B3e  - B3s  )/LB3  }  ...
    ; LB4   { B4s  ( B4e  - B4s  )/LB4  }  ...
    ; LB5   { B5s  ( B5e  - B5s  )/LB5  }  ...
    ; LB6   { B6s  ( B6e  - B6s  )/LB6  }  ...
%    ; LB7   { B7s  ( B7e  - B7s  )/LB7  }  ...
    ; LB7   { B7_a  B7_b  B7_c   B7_d   }  ...
    ; LB8   { B8s  ( B8e  - B8s  )/LB8  }  ...
    ; LB9   { B9s  ( B9e  - B9s  )/LB9  }  ...
    };

%% generate synthetical road map

data = crg_gen_csb2crg0(uinc, [ubeg uend], v, c, s, b);
txtnum = length(data.ct) + 1; data.ct{txtnum} = 'CRG curvature, slope, banking generated';

%% perform profile(s) to surface

data = crg_perform2surface(data, upvp, 'add');
txtnum = length(data.ct) + 1; data.ct{txtnum} = 'CRG lateral and longitudinal profile performed to surface';

%% check and write data to file

txtnum = length(data.ct) + 1; data.ct{txtnum} = '... finished';
data = crg_single(data);
data = crg_check(data);
ier  = crg_write(data, filename);

end

%% Usage of CRG_TEST_GEN_CSB2CRG0
% Introducing the usage of crg_test_gen_csb2crg0.
% Examples are included.
% The file comments are optimized for the matlab publishing makro.

%   Copyright 2005-2011 OpenCRG - VIRES Simulationstechnologie GmbH -
%   Holger Helmich
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
%   $Id: crg_test_gen_csb2crg0.m 41 2011-06-08 10:27:00Z hhelmich $

%% Test proceedings
%
% * create additional information (curv, banking, slope)
% * display result
%

% DEFAULT SETTINGS
% clear enviroment
clear all;
close all;

%% Test1.1 ( curvature )

ulength = 350;

LC1  =   120;  C1s  =  inf;      C1e  =  inf;
LC2  =    50;  C2s  =  inf;      C2e  =  -50;
LC3  =   180;  C3s  =  -50;      C3e  =  -50;

c = {  LC1    { 1/C1s ( 1/C1e - 1/C1s )/ LC1} ...
    ;  LC2    { 1/C2s ( 1/C2e - 1/C2s )/ LC2} ...
    ;  LC3    { 1/C3s ( 1/C3e - 1/C3s )/ LC3} ...
    };
dat1 = crg_gen_csb2crg0([1 0.5], ulength, 1, c);

crg_show_refline_elevation(dat1);

%% Test1.2 ( curvature and slope )

ulength = 350;

LC1  =   120;  C1s  =  inf;      C1e  =  inf;
LC2  =    50;  C2s  =  inf;      C2e  =  -50;
LC3  =   180;  C3s  =  -50;      C3e  =  -50;

LS1  =  120;      S1s  =  0;        S1e  =  0;
LS2  =   50;      S2s  =  0;        S2e  =  0;
LS3  =  180;      S3s  =  0;        S3e  =  0.03;

c = {  LC1    { 1/C1s ( 1/C1e - 1/C1s )/ LC1} ...
    ;  LC2    { 1/C2s ( 1/C2e - 1/C2s )/ LC2} ...
    ;  LC3    { 1/C3s ( 1/C3e - 1/C3s )/ LC3} ...
    };

s = { ...
    ; LS1   { S1s  ( S1e  - S1s  )/LS1  }  ...
    ; LS2   { S2s  ( S2e  - S2s  )/LS2  }  ...
    ; LS3   { S3s  ( S3e  - S3s  )/LS3  }  ...
    };

dat1 = crg_gen_csb2crg0([1,0.5], ulength, 1, c, s);

crg_show_refline_elevation(dat1);

%% Test1.3 ( slope )

ulength = 350;

LS1  =  120;      S1s  =  0;        S1e  =  0;
LS2  =   50;      S2s  =  0;        S2e  =  0;
LS3  =  180;      S3s  =  0;        S3e  =  0.03;

s = { ...
    ; LS1   { S1s  ( S1e  - S1s  )/LS1  }  ...
    ; LS2   { S2s  ( S2e  - S2s  )/LS2  }  ...
    ; LS3   { S3s  ( S3e  - S3s  )/LS3  }  ...
    };

dat1 = crg_gen_csb2crg0([1,0.5], ulength, 1, [], s);

crg_show_refline_elevation(dat1);

%% Test1.4 ( minimal content )

ulength = 350;

dat1 = crg_gen_csb2crg0([], ulength, 1);

crg_show_refline_elevation(dat1);

%% Test2.1 ( banking )

ulength = 350;

LB1  = 120;      B1s  =  0;        B1e  =  0;
LB2  =  50;      B2s  =  0;        B2e  =  0.02;
LB3  = 180;      B3s  =  0.02;     B3e  =  0.02;

b = { ...
    ; LB1   { B1s  ( B1e  - B1s  )/LB1  }  ...
    ; LB2   { B2s  ( B2e  - B2s  )/LB2  }  ...
    ; LB3   { B3s  ( B3e  - B3s  )/LB3  }  ...
    };

dat1 = crg_gen_csb2crg0([1,0.5], ulength, 1, [], [], b);

crg_show_refline_elevation(dat1);

%% Test2.2 (  banking/spline )

ulength = 485;

LB1  = 120;      B1s  =  0;        B1e  =  0;
LB2  =  50;      B2s  =  0;        B2e  =  0.02;
LB3  = 180;      B3s  =  0.02;     B3e  =  0.02;
LB4  =  50;      B4s  =  0.02;     B4e  =  0.02;
LB5  =  65;      B5s  =  0.03;     B5e  =  0.02;
LB6  =  20;      B6s  =  0.02;     B6e  =  0.02;

B2_a =                        0;
B2_b =  3*( B2e  - B2s  )/LB2^2;
B2_c = -2*( B2e  - B2s  )/LB2^3;

b = { ...
    ; LB1   { B1s  ( B1e  - B1s  )/LB1  }  ...
    ; LB2   { B2s  B2_a B2_b B2_c       }  ...
    ; LB3   { B3s  ( B3e  - B3s  )/LB3  }  ...
    ; LB4   { B4s  ( B4e  - B4s  )/LB4  }  ...
    ; LB5   { B5s  ( B5e  - B5s  )/LB5  }  ...
    ; LB6   { B6s  ( B6e  - B6s  )/LB6  }  ...
    };

dat1 = crg_gen_csb2crg0([1,0.5], ulength, 1, [], [], b);

crg_show_road_uv2surface(dat1, [120:1:180], [-1:0.2:1]);

%% Test2.3 ( curvature, slope and banking )

ulength = 350;

LC1  =   120;  C1s  =  inf;      C1e  =  inf;
LC2  =    50;  C2s  =  inf;      C2e  =  -50;
LC3  =   180;  C3s  =  -50;      C3e  =  -50;

LS1  =   120;  S1s  =  0;        S1e  =  0;
LS2  =    50;  S2s  =  0;        S2e  =  0;
LS3  =   180;  S3s  =  0;        S3e  =  0.03;

LB1  =   120;  B1s  =  0;        B1e  =  0;
LB2  =    50;  B2s  =  0;        B2e  =  0.02;
LB3  =   180;  B3s  =  0.02;     B3e  =  0.02;

c = {  LC1    { 1/C1s ( 1/C1e - 1/C1s )/ LC1} ...
    ;  LC2    { 1/C2s ( 1/C2e - 1/C2s )/ LC2} ...
    ;  LC3    { 1/C3s ( 1/C3e - 1/C3s )/ LC3} ...
    };

s = { ...
    ; LS1   { S1s  ( S1e  - S1s  )/LS1  }  ...
    ; LS2   { S2s  ( S2e  - S2s  )/LS2  }  ...
    ; LS3   { S3s  ( S3e  - S3s  )/LS3  }  ...
    };

b = { ...
    ; LB1   { B1s  ( B1e  - B1s  )/LB1  }  ...
    ; LB2   { B2s  ( B2e  - B2s  )/LB2  }  ...
    ; LB3   { B3s  ( B3e  - B3s  )/LB3  }  ...
    };

dat1 = crg_gen_csb2crg0([1,0.5], ulength, 2, c, s, b);

crg_show(dat1);

function [] = crg_intro()
% CRG_INTRO CRG introduction.
%   CRG_INTRO introduces some on basic CRG concepts
%
%   The methods of the CRG package communicate to each other by a single
%   DATA struct array consisting of:
%
%   - core reference line data, which defines the curved reference line
%     This data is checked and complemented by equivalent head data where
%     available. Vectors of length 1 (u, p, s) or 2 (u) are complemented
%     by equivalent head data by crg_check. Vectors (p, s) with constant
%     values are condensed by crg_check.
%       DATA.u      vector of u values (single)
%                   length(u) == 1: length of reference line
%                   length(u) == 2: start/end value of u
%       DATA.p      (optional) vector of phi values (single)
%                   length(p) == 1: straight refline
%                   length(p) == nu-1: curved refline
%       DATA.s      (optional) vector of slope values (single)
%                   length(s) == 1: constant slope
%                   length(s) == nu-1: variable slope
%
%   - core elevation grid data, which defines the regular grid
%     This data is checked and complemented by equivalent head data where
%     available. Vectors of length 1 (v, b) or 2 (v) are complemented
%     by equivalent head data by crg_check. Vector v with constant
%     increment is condensed by crg_check. Vector b with constant values is
%     condensed in crg_check.
%       DATA.z      array(nu, nv) of z (height) values (single)
%       DATA.v      vector of v values (single)
%                   length(v) == 1: defines half width of road
%                   length(v) == 2: defines right/left edge of road
%                   length(v) == nv: defines length cut positions
%       DATA.b      (optional) vector of banking values (single)
%                   length(b) == 1: constant banking
%                   length(b) == nu: variable banking
%
%   - head data, which is read/writen from/to CRG file headers
%     This data is checked and complemented with equivalent core data where
%     available. Defaults are used for missing CRG curved and local
%     rectangular coordinate systems. WGS84 data is optional.
%       DATA.head   struct array of data scalars
%                   (and equivalent CRG file header keyword)
%                   with these struct elements:
%         CRG curved coordinate system: longitudinal axis
%           ubeg (reference_line_start_u)
%           uend (reference_line_end_u)
%           uinc (reference_line_increment)
%         CRG curved coordinate system: lateral axis
%           vmin (long_section_v_right)
%           vmax (long_section_v_left)
%           vinc (long_section_v_increment)
%         CRG curved coordinate system: slope
%           sbeg (reference_line_start_s)
%           send (reference_line_end_s)
%         CRG curved coordinate system: banking
%           bbeg (reference_line_start_b)
%           bend (reference_line_end_b)
%         local rectangular coordinate system: location
%           xbeg (reference_line_start_x)
%           ybeg (reference_line_start_y)
%           xend (reference_line_end_x)
%           yend (reference_line_end_y)
%           xoff (reference_line_offset_x)
%           yoff (reference_line_offset_y)
%         local rectangular coordinate system: heading
%           pbeg (reference_line_start_phi)
%           pend (reference_line_end_phi)
%           poff (reference_line_offset_phi)
%         local rectangular coordinate system: elevation
%           zbeg (reference_line_start_z)
%           zend (reference_line_end_z)
%           zoff (reference_line_offset_z)
%         WGS84 world geodetic system: location
%           ebeg (reference_line_start_lon)
%           nbeg (reference_line_start_lat)
%           eend (reference_line_end_lon)
%           nend (reference_line_end_lat)
%         WGS84 world geodetic system: altitude
%           abeg (reference_line_start_alt)
%           aend (reference_line_end_alt)
%
%   - file data, which complements the CRG file
%       DATA.ct     cell array of comment text, reqired for file output
%       DATA.struct (optional) cell array of further structured data, used
%                   for file output, may contain opts data for later CRG
%                   file processing.
%       DATA.filenm name of read crg data file
%
%   - mods data, which defines further CRG modifiers
%     This data is read from CRG file headers or otherwise set,
%     and is evaluated and applied by CRG_MODS. The mods are evaluated in
%     sequence as they appear below, and are cleared after they are
%     applied. An empty mods array inhibits any default settings.
%       DATA.mods   struct array of data scalars
%                   (and equivalent CRG file opts keywords)
%                   with these struct elements:
%         CRG scaling (default: no scaling)
%           - scale elevation data
%           szgd (scale_z_grid): scale elevation grid
%           sslp (scale_slope): scale slope information
%           sbkg (scale_banking): scale banking information
%           - scale refline data (resets refline position to origin)
%           slth (scale_length): scale u information
%           swth (scale_width): scale v information
%           scrv (scale_curvature): scale reference line's curvature
%         CRG elevation grid NaN handling
%           gnan (grid_nan_mode): how to handle NaN values (default: 2)
%               = 0: keep NaN
%               = 1: set zero
%               = 2: keep last value in cross section
%           gnao (grid_nan_offset): z offset to be applied at NaN positions
%               (default: 0)
%         CRG re-positioning: refline by offset (default: "by refpoint")
%           first rotate:
%           rlrx (refline_rotcenter_x): rotation center (default: xbeg)
%           rlry (refline_rotcenter_y): rotation center (default: ybeg)
%           rlop (refline_offset_phi): rotate by rlop around (rlrx, rlry)
%           then translate:
%           rlox (refline_offset_x): translate by rlox
%           rloy (refline_offset_y): translate by rloy
%           rloz (refline_offset_z): translate by rloz
%         CRG re-positioning: refline by refpoint (overwrites "by offset")
%         - position (u,v) on reference line:
%           rpfu (refpoint_u_fraction) relative u (default: 0)
%             or: rptu (refpoint_u) absolute u
%           [with optional: rpou (refpoint_u_offset) (default: 0)]
%           rptv (refpoint_v) absolute v (default: 0)
%             or: rpfv (refpoint_v_fraction) relative v
%           [with optional rpov (refpoint_v_offset) (default: 0)]
%         - position (x,y,z) and orientation (phi) in inertial frame:
%           rptx (refpoint_x) target position (default: 0)
%           rpty (refpoint_y) target position (default: 0)
%           rptz (refpoint_z) target position (default: 0)
%           rptp (refpoint_phi) target orientation (default: 0)
%
%   - opts data, which defines further CRG processing options
%     This data is read from CRG file headers or set by
%     crg_opts_set.
%       DATA.opts   struct array of data scalars
%                   (and equivalent CRG file opts keywords)
%                   with these struct elements:
%         CRG elevation grid border modes in u and v directions
%           bdmu (border_mode_u): at beginning and end (default: 2)
%           bdmv (border_mode_v): at left and right side (default: 2)
%               = 0: return NaN
%               = 1: set zero
%               = 2: keep last
%               = 3: repeat
%               = 4: reflect
%           bdou (border_offset_u): z offset beyond border (default: 0)
%           bdov (border_offset_v): z offset beyond border (default: 0)
%           bdss (border_smooth_ubeg): smoothing zone length at start
%           bdse (border_smooth_uend): smoothing zone length at end
%         CRG reference line continuation
%           rflc (refline_continuation): how to extrapolate (default: 0)
%               = 0: follow linear extrapolation
%               = 1: close track
%         CRG reference line search strategy
%           sfar (refline_search_far): far value (default: 1.5)
%           scls (refline_search_close): close value (default: sfar/5)
%         CRG message options
%               = 0: no messages at all
%               = -1: unlimited messages
%               > 0: max. number of messages to show
%           wmsg (warn_msgs): warning messages (default: -1)
%           wcvl (warn_curv_local): local curvature limit exceeded (d:-1)
%           wcvg (warn_curv_global): global curvature limit exceeded (d:-1)
%           lmsg (log_msgs): log messages (default: -1)
%           leva (log_eval): evaluation inputs and results (default: 20)
%           levf (log_eval_freq): how often (default: 1)
%           lhst (log_hist): refline search history (default: -1)
%           lhsf (log_hist_freq): how often (default: 100000)
%           lsta (log_stat): evaluation statistics (default: -1)
%           lstf (log_stat_freq): how often (default: 100000)
%         CRG check options
%           ceps (check_eps): expected min. accuracy (default: 1e-6)
%           cinc (check_inc): expected min. increment (default: 1e-3)
%           ctol (check_tol): expected abs. tolerance (default: 0.1*cinc)
%
%   - status data
%       DATA.ok     ok-flag signaling previous check result is o.k.
%                   (generated by CRG_CHECK*)
%
%   - derived data (generated by CRG_CHECK for efficient internal use)
%       DATA.rx     vector(nu) of reference line x positions
%       DATA.ry     vector(nu) of reference line y positions
%       DATA.rz     vector(nu) of reference line z positions
%       DATA.rc     vector(nu-2) of reference line curvature
%       DATA.il     vector(nu) of index to leftmost valid in cross section
%       DATA.ir     vector(nu) of index to rightmost valid in cross section
%       DATA.dved   struct array of derived data with these elements:
%           pbec        cos(data.head.pbeg)
%           pbes        sin(data.head.pbeg)
%           penc        cos(data.head.pend)
%           pens        sin(data.head.pend)
%           ubex        u start value at extrapolated refline crossing
%           uenx        u end value at extrapolated refline crossing
%           ulex        u roundtrip length of closed extrapolated refline
%                       = 0: no crossing, no closed track exists
%
%   - evaluation history data (generated by CRG_CHECK and CRG_EVAL_XY2UV)
%       DATA.hist   struct array of history data with these elements:
%           m       max. size of history
%           o       history option
%                   = 0: unknown evaluation point, look for closest point
%                        in history
%                   > 0: use history point no. o if available
%                   =-1: forget history, restart search from beginning.
%                   =-2: forget history, restart search from end.
%           c       square of distance limit for close search
%           f       square of distance limit for far   search
%           n       number of stacked history results
%           i       vector(m) of history interval pointers
%           x       vector(m) of history x positions
%           y       vector(m) of history x positions
%
%   - figure options - to overwrite the default figure labels
%       DATA.fopt   struct array of figure options used by crg_figure
%           ori     orientation (default: 'landscape')
%                   figure orientation, may be 'landscape' or 'portrait'
%           tit     title (default is set in crg_show_* or crg_figure)
%                   string defining annotation top middle
%           fnm     filename (default: DATA.filenm)
%                   string defining annotation bottom left
%           dat     datestr (default: datestr(now, 31))
%                   string defining annotation bottom right
%           mod     mod divisor argument, to generate periodic 3d surface
%                   colormap representation (default: 0.0)
%           asp     daspect argument for z-axis scaling in 3d plots
%                   (default: 0.1)
%           lit     light visibility off/on for surfaces (default: 0)
%
%   A minimal CRG data structure consists of "core reference line data"
%   with a scalar DATA.u and "core elevation grid data" with a 2x2 array
%   DATA.z and a scalar DATA.v only.
%   Adding more "core reference line data" and "core elevation grid data"
%   yields a complete CRG, which might be further complemented with a
%   partial or full set of "head data", "opts data" and/or "mods data".
%   The consistency of a given CRG is checked by CRG_CHECK, which also
%   supplements missing head data as defined above.
%   Modifiers of a given CRG are only applied by an explicit call to
%   CRG_MODS, while options are evaluated without extra activation.
%   Before writing a CRG file, DATA.ct has to be defined to provide some
%   textual information about the CRG contents.
%   Data type of "core reference line data" and "core elevation grid data"
%   is "single". Global accuracy is still ensured by the "head data", which
%   complements the core data and is stored in "double" precision.
%
%   Examples:
%   crg = crg_read('demo.crg') reads a CRG file.
%   crg = crg_show(crg) shows contents of a CRG data structure.
%   [pz crg] = crg_eval_xy2z(crg,[0.3 0.7]) evaluates CRG at xy=(0.3,0.7).
%
%   See also CRG_INIT,
%   CRG_DEMO, CRG_SHOW, CRG_TEST,
%   CRG_READ, CRG_WRITE,
%   CRG_CHECK, CRG_MODS, CRG_SINGLE, CRG_WRAP,
%   CRG_EVAL_UV2XY, CRG_EVAL_UV2Z, CRG_EVAL_U2PHI,
%   CRG_EVAL_XY2UV, CRG_EVAL_XY2Z, CRG_EVAL_U2CRV,
%   CRG_WGS84_CRG2HTML, CRG_WGS84_WGS2URL, CRG_WGS84_XY2WGS,
%   and many others.

%   Copyright 2005-2013 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_intro.m 334 2013-11-30 15:06:30Z jorauh $

%% add application directory and required subdirectories to path

crg_init

%% show help if someone calls this function

help crg_intro

end

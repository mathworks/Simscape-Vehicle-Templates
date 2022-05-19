#
#    Copyright 2005-2017 OpenCRG - Daimler AG - Jochen Rauh
#    Copyright 2017 VIRES Simulationstechnologie GmbH
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#


Introduction
--------------------------------------------------------------
Welcome to the OpenCRG collection.

OpenCRG provides open file formats and tools for the detailed
description and evaluation of 3D road surfaces. It is suitable for a
broad range of applications including e.g. tyre and driving
simulations.

Since OpenCRG is open, you are welcome to use it and to share your
experiences with other users. We would also like to invite your
contributions to our common intitiative.


Version Info
--------------------------------------------------------------
This readme file was updated on April 17, 2018 by
VIRES Simulationstechnologie GmbH 


Overview
--------------------------------------------------------------
Three major components are provided:
C-API           - read and evaluate OpencRG data independent of third party tools
MATLAB-Tools    - read, modify, generate, write and evaluate OpenCRG based on 
                  methods using the MATLAB tool suite
Data            - OpenCRG sample data of various types

These components are complemented by a comprehensive documentation.

For comments and instructions referring to the individual components, please check
additional readme.txt-files in the respective sub-directories.


Directory structure:
--------------------------------------------------------------

|----doc..................documentation of the entire tool suite
|    |----matlab..........additional documentation of matlab-specific tests etc.
|----docsrc...............documentation generation tools
|    |----make............makefile for pdf generation in Linux (pdflatex)
|    |----xsl.............extensible stylesheet language for publishing in latex
|----c-api................c-api libraries and executables
|    |----baselib.........OpenCRG basic library
|    |----demo............demo sources showing the usage of the basic library
|    |----test............test sources and scripts for performance tests etc.
|----matlab...............matlab library, functions and tools
|    |----demo............demo examples
|    |----lib.............library functions
|    |----test............test functions
|    |----crg_init.m......initialize OpenCRG MATLAB environment
|    |----crg_intro.m.....give overview on OpenCRG data structures
|----crg-bin..............OpenCRG sample data in binary representation
|----crg-txt..............OpenCRG sample data in text representation
|----temp.................working directory 

        
Release Notes:
--------------------------------------------------------------

March 30, 2018 Release 1.1.2
-----------------------------
- C-API:
  fixes multiplatform issues with files bigger than 2GB, WIN64 now uses stat64 while WIN32 build are still possible
- MATLAB-API:
  crg_cut_iuiv - cutting CRG is now possible without losing offsets

July 26, 2017 Release 1.1.1
-----------------------------
- C-API:
  fixes to handle crg input files bigger than 2GB (Windows: use „struct stat64“ instead of „struct stat“ to use this feature under Windows)
  fixes invalid memory access during OpenCRG road file access
  fixes use of size_t and type cast warnings
- Documentation
  additional information on Closed track checks

October 26, 2015 Release 1.1.0 - Stable
---------------------------------------
- C-API:
  fix memory corruption (from ver. 1.0.7 RC2)

October 15, 2015 Release 1.1.0 - RC2
-----------------------------------
- C-API:
  fix warning
- MATLAB-API:
  crg_wgs84_crg2html.m: bugfix - swap start/end lat/lon locations
  crg_eval_u2crv.m: bugfix - index out of bounds error for last uIndex
  crg_mods.m: bugfix - xyzp offset calculations
  crg_check_data.m: bugfix last banking value

Juli 31, 2015 Release 1.1.RC1
---------------------------------
- Common:
- MATLAB-API:
  successfully tested with MATLAB R2015a

April 08, 2015 Release 1.0.7 RC3:
---------------------------------
- Common:
  add OpenCRG base description to the manual

April 03, 2015 Release 1.0.7 RC2:
---------------------------------

- C-API:
  handle crg input files bigger than 2GB
  feature #3079: add public access to closed track utility data (uIsClosed, uCloseMin, uCloseMax)
  bug #1210: reuse deleted contact point positions

October 31, 2014 Release 1.0.7 - RC1
------------------------------------

- C-API:
  corrected check routines for modifiers (determination of byref and byoff)
  added message if modifiers are changed implicitly by crgCheck()

April 08, 2014 Release 1.0.6:
-------------------------------

- Common:
  * add new modifier to define a rotation center (refline by offset)
- C-API:
  revert strchr by memchr fix of Release 1.0.5 - RC2
  implement MATLAB-API equivalent check routines for
      * options
      * modifier
- MATLAB:
  x/y offset checks consider also reference line offset phi (poff) 
  crg_check_data():
    modified inconsistent value checks for 'pbeg' and 'pend'

July 31, 2013 Release 1.0.6 - RC1
---------------------------

- C-API:
  revert to c89/90 standard
  set optimization level 3 as default
  bugfix: in some cases the history may be currupt
  rename: mBigEndian -> mCrgBigEndian
  add crg check data routine for consistency and accuracy
     * validate option if track can be closed

- MATLAB:
  update lib/map_wgs2html.m        : allow array of points [input] for multiple tracks

May 28, 2013, Release 1.0.5
---------------------------
- RC3 becomes Stable

April 12. 2013, Release 1.0.5 - RC3 
--------------------------------------
- C-API:
    bug-fix: Contact point table will be delete only if all contact points are removed
- Matlab:
    reenable google map support

October 31. 2012, Release 1.0.5 - RC2
--------------------------------------
- Matlab:
    MATLAB bug in verison 7.13 (R2011b):
      using a matrix of singles as input to PLOT causes MATLAB to crash or hang
      workaround: cast matrix to double data type
      (see MATLAB service request 1-GAYXED of 2012-01-09)
    add header check if DATA.u->ubeg/uend/uinc is not consistent with number of rows of DATA.z
    add header check if DATA.v->vmin/vmax/vinc is not consistent with number of columns of DATA.z

January 04. 2012, Release 1.0.5 - RC1:
--------------------------------------
- C-API:
  fix non-critic memory leak( create contact point )
    * free pre initialized option entry before setting default data set options.
  fix warnings
    * replaced strchr by memchr with fixed size ( reading char* )

December 19. 2011, Release 1.0.4:
--------------------------------------
- C-API:
  bug-fix: reading data format

December 08, 2011
-------------------------------
- Release 1.0.3 - Stable
- Matlab:
  update lib/crg_wgs84_invdist.m      : remove surface distance along ellipsoid from computation if equal 0

June 01, 2011
-------------------------------
- Release 1.0.3 - RC1
- New policy:
  extrapolation considers now banking (uv->z)
  border mode 'set zero' overwrites smoothing and banking (uv->z)
  border mode 'keep last' overwrites smoothing and banking (uv->z)
- Matlab:
  adapt several crg_check_data checks
  remove of FILEPARTS fourth output [crg_init.m] (depricated in R2011a)
  add    lib/crg_show_info.m          : road text info visualizer
  add    lib/crg_flip.m               : flips the crg contents
  add    lib/crg_generate_sb.m        : finds and generates slope and banking
  add    lib/smooth_firfilt.m         : smoothen input signals with symmetric FIR filter
  update lib/crg_write.m              : accept mods like they are set
  update lib/crg_b2z.m                : applies new banking
  update lib/crg_check_uv_descript.m  : head docu and error checks
  update lib/crg_cut_iuiv.m           : set default if input parmams are empty
- C-API:
  bug-fix: comment behind data format token is no longer considered
  update test/Verify                  : add 'v out of core area' comment

September 24, 2010
--------------------------------
- Release 1.0.2 - RC5 
- Matlab:
  consistent linefeed
  minor doc/spelling changes
  add complex demos to generate synthetic roads incl. sidewalk etc.
  include lib/crg_perform2surface.m   : synthetic surface generation
  include lib/crg_check_uv_descript.m : creates v profile

August 21, 2010:
--------------------------------
- Release 1.0.2 - RC4 (adjustments in C-API, see readme.txt in c-api/)
- introduced reference line offset information in Matlab routines and
  in file header
- Matlab:
  store x,y,z,phi-offset in head information

April 14, 2010:
--------------------------------
- Release 1.0.0 (minor adjustments in message printing of C-API)
- for complete documentation of differences between 0.8 and 1.0, 
  please review all release notes concerning the release candidates
  for release 1.0.0 (i.e. Feb 10 until April 12)

April 12, 2010:
--------------------------------
- RC7 (minor adjustments in C-API and Matlab)

March 30, 2010:
--------------------------------
- C-API  1.0.0 rc6, see also "readme.txt" in c-api/
- Matlab:
    updated plot routines
- General:
  - default modifiers are now implemented in consistent manner
    in both tools Matlab and C-API
  - default modifiers may be removed by defining an empty 
    CRG_MODS block in the CRG files or by calling the respective
    routines in Matlab and C-API
  - when setting own modifiers via the CRG files, please be notified
    that the first occurrence of a CRG_MODS block will delete ALL
    default modifiers, i.e. the user has to make sure that the ones
    he/she wants to keep are explicitly defined in the CRG_MODS block

March 26, 2010:
--------------------------------
- updated various ASCII examples in crg-txt/
- C-API  1.0.0 rc5, see also "readme.txt" in c-api/
- Matlab:
        update crg_gen_csb2crg0.m
        update crg_eval_xy2uv.m
        update crg_check_data.m
        new/mod test cases:  crg_test_continuesTrack.m
                             crg_test_gen_csb2crg0.m
                             crg_test_gen_road.m
        new demo:            crg_demo_csb2crg0.m
        fixed some typing errors


March 03, 2010:
--------------------------------
- C-API  1.0.0 rc4, see also "readme.txt" in c-api/
- updated comments in ASCII samples crg-txt/

February 26, 2010:
--------------------------------
- C-API  1.0.0 rc3, see also "readme.txt" in c-api/
- Matlab 1.0.0 rc3, see also "readme.txt" in matlab/

February 10, 2010:
--------------------------------
- C-API  1.0.0 rc2, see also "readme.txt" in c-api/
- Matlab 1.0.0 rc2, see also "readme.txt" in matlab/
- updated user manual

January  13, 2010:
--------------------------------
- add Matlab option: continued track

December 29, 2009:
--------------------------------
- update Matlab tools suite
- add Matlab comparing tool (crg_isequal)
- update crg_gen_csb2crg0 dealing with crest/sag

December 17, 2009:
--------------------------------
- C-API 0.8.0, see also "readme.txt" in c-api/

December 04, 2009:
--------------------------------
- C-API.0.7.2, see also "readme.txt" in c-api/

November 19, 2009:
--------------------------------
- C-API.0.7.1, see also "readme.txt" in c-api/

November 04, 2009:
--------------------------------
- update Matlab tools suite
- add Matlab modification, generation tools
- add Matlab test routines
- add Matlab demo routines
- add Matlab tools suite introduction to documentation
- C-API.0.7, see also "readme.txt" in c-api/

October 16, 2009:
--------------------------------
- C-API 0.7, release candidate 2

October 01, 2009:
--------------------------------
- C-API 0.7, release candidate 1

August 15, 2009:
--------------------------------
- new directory structure for better handling of an entire OpenCRG release
- merge of MATLAB routines from Daimler AG (Dr. J. Rauh) with C-API
- C-API 0.6beta
- updated matlab routines
- updated documentation



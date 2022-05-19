Welcome to the OpenCRG MATLAB functions and tools suite. This set of
MATLAB m-files lets you read, manipulate, evaluate, visualize and write
CRG data files.

Usage:

Start OpenCRG environment by running crg_init.m from the MATLAB command
line

> run <path-to-OpenCRG>/matlab/crg_init.m

Running the crg_demo command will generate some CRG data structures,
write them to disk, read them again, and visualizes some contents. It may
be useful to look into crg_demo to get some first examples how to use the
OpenCRG MATLAB functions and tools suite.

To get an overview on CRG data organization, run the crg_intro command.


Hint on memory limitations: with 32bit MATLAB available memory is sometimes
rather limited, especially on WIN32 systems, see MATLAB help on memory.

On a typical WIN32 installation with 4GB, only 440MB of contingous memory
was available (use feature('memstats') to show on your system). This allows
to work on 220MB CRG files, with e.g. 1cm x 1cm resolution, 4m width and
1.4km length. On Linux32, at least double file sizes can be handled, on
all 64bit installations, there is virtually no limitation in CRG size.


%   Copyright 2005-2011 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: readme.txt 294 2011-12-20 11:40:59Z jorauh $

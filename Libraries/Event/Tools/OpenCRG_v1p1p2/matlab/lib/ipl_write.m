function [ier] = ipl_write(data, filename, type)
% IPL_WRITE IPLOS file writer.
%   IER = IPL_WRITE(DATA, FILENAME, TYPE) writes IPLOS data file
%
%   Inputs:
%   DATA        is a struct array with
%       DATA.struct     (optional) cell array of struct data lines
%       DATA.kd_ind     (optional) cell array of virtual channel definitions
%       DATA.kd_def     cell array of data channel definitions
%       DATA.kd_oth     (optional) cell array of other definitions
%       DATA.kd_dat     data array (single or double)
%   FILENAME    is the file to write
%   TYPE        is the data representation type to use
%               'KRBI'  binary float32
%               'KDBI'  binary float64
%               'LRFI'  ascii single precision
%               'LDFI'  ascii double precision
%
%   Outputs:
%   IER         error return code
%               = 0     successful
%               = -1    not successful
%
%   Example
%   ier = ipl_write(data, filename, type) writes an IPLOS file
%
%   See also IPL_READ, IPL_DEMO.

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
%   $Id: ipl_write.m 231 2011-02-17 10:36:49Z jorauh $

[nr, nc] = size(data.kd_dat);

% IPLOS file machineformat: ieee-be (IEEE floating point with big-endian byte ordering)
% IPLOS file encoding: ISO-8859-1 (latin1, explicitly supported since Matlab R2006a)
try
  fid = fopen(filename,'w','ieee-be','ISO-8859-1');
catch
  fid = fopen(filename,'w','ieee-be');
end
if fid < 0
    error('file %s could not be opened for write', filename)
end

% write structured data

if isfield(data, 'struct')
    for i = 1:length(data.struct)
        hc = data.struct{i};
        if length(hc) > 72
            hc = hc(1:72);
            warning('IPL:recLengthExceeded', ...
            'data.struct{%d} too long:\n %s\nwill only be used as:\n %s', ...
            i, data.struct{i}, hc)
        end
        fprintf(fid, '%s\n', data.struct{i});
    end
end

% write date

fprintf(fid, '* written by %s at %s\n', mfilename, datestr(now, 31));

% write definition block for sequential data

fprintf(fid, '%s\n', '$KD_DEFINITION');

fprintf(fid, '#:%s\n', type);

if isfield(data, 'kd_ind')
    for i = 1:length(data.kd_ind)
        hc = data.kd_ind{i};
        if length(hc) > 72
            hc = hc(1:72);
            warning('IPL:recLengthExceeded', ...
            'data.kd_ind{%d} too long:\n %s\nwill only be used as:\n %s', ...
            i, data.kd_ind{i}, hc)
        end
        fprintf(fid, 'U:%s\n', data.kd_ind{i});
    end
end

if nc ~= length(data.kd_def)
    error('wrong number of data definitions')
end

for i = 1:length(data.kd_def)
        hc = data.kd_def{i};
        if length(hc) > 72
            hc = hc(1:72);
            warning('IPL:recLengthExceeded', ...
            'data.kd_def{%d} too long:\n %s\nwill only be used as:\n %s', ...
            i, data.kd_def{i}, hc)
        end
    fprintf(fid, 'D:%s\n', data.kd_def{i});
end

if isfield(data, 'kd_oth')
    for i = 1:length(data.kd_oth)
        hc = data.kd_oth{i};
        if length(hc) > 72
            hc = hc(1:72);
            warning('IPL:recLengthExceeded', ...
            'data.kd_oth{%d} too long:\n %s\nwill only be used as:\n %s', ...
            i, data.kd_oth{i}, hc)
        end
        fprintf(fid, '%s\n', data.kd_oth{i});
    end
end

fprintf(fid, '%s\n', '$');

% write separator

hc(1:72) = '$';
fprintf(fid, '%s\n', hc);

% write sequential data

switch type
    case 'KRBI'
        try
            fwrite(fid, data.kd_dat', 'float32');
        catch
            % transposing big data.kd_dat can result in "Out of memory"
            % problems. A workaround is to write it record by record,
            % which gives a second chance:
            for ir = 1:nr
                fwrite(fid, data.kd_dat(ir, :), 'float32');
            end
        end
        % pad with NaN to full multiple of 80 data bytes
        for i = 1:mod(-nc*nr,20)
            fwrite(fid, NaN, 'float32');
        end
    case 'KDBI'
        try
            fwrite(fid, data.kd_dat', 'float64');
        catch
            % transposing big data.kd_dat can result in "Out of memory"
            % problems. A workaround is to write it record by record,
            % which gives a second chance:
            for ir = 1:nr
                fwrite(fid, data.kd_dat(ir, :), 'float64');
            end
        end
        % pad with NaN to full multiple of 80 data bytes
        for i = 1:mod(-nc*nr,10)
            fwrite(fid, NaN, 'float64');
        end
    case 'LRFI'
        for ir = 1:nr
            for ic = 1:nc
                if isnan(data.kd_dat(ir, ic))
                    fprintf(fid, '**********');
                else
                    fprintf(fid, ' %s', str_num2strn(double(data.kd_dat(ir, ic)), 9));
                end
                if (mod(ic, 8) == 0)
                    fprintf(fid, '\n');
                end
            end
            if (mod(nc, 8) ~= 0)
                fprintf(fid, '\n');
            end
        end
    case 'LDFI'
        for ir = 1:nr
            for ic = 1:nc
                if isnan(data.kd_dat(ir, ic))
                    fprintf(fid, '********************');
                else
                    fprintf(fid, ' %s', str_num2strn(double(data.kd_dat(ir, ic)), 19));
                end
                if (mod(ic, 4) == 0)
                    fprintf(fid, '\n');
                end
            end
            if mod(nc, 4) ~= 0
                fprintf(fid, '\n');
            end
        end
     otherwise
        error('type %s is not supported', type)
end

ier = fclose(fid);

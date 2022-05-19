function [data] = ipl_read(filename, opts)
% IPL_READ IPLOS file reader.
%   DATA = IPL_READ(FILENAME, OPTS) reads IPLOS data file
%
%   Inputs:
%   FILENAME    is the file to read
%   OPTS        options
%      if OPTS is string:
%               'single': return single precision data
%               'double': return double precision data
%               'meta'  : read only meta data, DATA.kd_dat is not returned
%               --> All data channels are returned.
%      if OPTS is structure:
%      .dtype   is the datatype of DATA.kd_dat to be returned.
%               'single': return single precision data
%               'double': return double precision data
%               'meta'  : read only meta data, DATA.kd_dat is not returned
%      .channel string or cellarray of strings of data channels
%               to be returned. If string is empty all channels are
%               returned.
%      (--> Defaults: - return single precision data
%                     - return all data channels     )
%
%   Outputs:
%   DATA is a struct array with
%       DATA.struct     cell array of struct data lines
%       DATA.filenm     name of read IPLOS data file
%     and only if sequential data is available also with
%       DATA.kd_ind     cell array of virtual channel definitions
%       DATA.kd_def     cell array of data channel definitions
%                       (as specified by OPTS.channel)
%       DATA.kd_oth     cell array of other definitions
%     and only if OPTS.DTYPE ~= 'meta' also with
%       DATA.kd_dat     data array (single or double as specified by OPTS.dtype)
%
%   Example
%   data = ipl_read(filename) reads an IPLOS file.
%
%   See also IPL_WRITE, IPL_DEMO.

%   Copyright 2005-2010 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: ipl_read.m 184 2010-09-22 07:41:39Z jorauh $

% defaults
nmp = 20000;    %pre-allocate DATA.kd_dat size to increase performance
options.dtype   = 'single';
options.channel = '';

% check number of input arguments
error(nargchk(1, 2, nargin))

% check options
if nargin == 2
    if isstruct(opts)
        if isfield(opts,'dtype'),   options.dtype   = opts.dtype;   end
        if isfield(opts,'channel'), options.channel = opts.channel; end
    elseif ischar(opts)
        options.dtype = opts;
    else
        error('IPL:argumentError', 'illegal argument type ''%s''', class(opts))
    end
end

switch lower(options.dtype)
    case 'single'
        dtype = 'S';
    case 'double'
        dtype = 'D';
    case 'meta'
        dtype = 'M';
    otherwise
        error('IPL:argumentError', 'illegal argument DTYPE=%s', options.dtype)
end

% IPLOS file machineformat: ieee-be (IEEE floating point with big-endian byte ordering)
% IPLOS file encoding: ISO-8859-1 (latin1, explicitly supported since Matlab R2006a)
try
  fid = fopen(filename,'r','ieee-be','ISO-8859-1');
catch
  fid = fopen(filename,'r','ieee-be');
end
if fid < 0
    error('IPL:fileNotAvailable', 'file %s could not be opened for read', filename)
end
data.filenm = filename;
nl = 0;

% read structured data
data.struct = cell(1,0);
state = 0;
while 1
    hc = fgetl(fid);
    if ~ischar(hc)
        switch state
            case 0 % outside $name block
                break; % end of file, end of (correctly) structured data
            case 1 % inside $name block
                error('IPL:invalidFile', 'unexpected end of file inside named block in file %s line %d', filename, nl)
        end
    end
    nl = nl + 1;
    if length(hc) > 72 % ignore extra characters
        hc = hc(1:72);
    end
    switch state
        case 0 % outside $name block
            if strncmp(hc, '$', 1)
                if strcmp(strtok(hc,' !'), '$') % detect block end marker
                    error('IPL:invalidFile', 'block end marker outside named block in file %s line %d', filename, nl)
                elseif strncmp(hc, '$$', 2)
                    break % end of (correctly) structured data
                end
                state = 1;
            end
        case 1 % inside $name block
            if strcmp(strtok(hc,' !'), '$') % detect block end marker
                state = 0;
            elseif strncmp(hc, '$', 1) % detect other block marker
                if ~strncmp(hc, '$$', 2) % it is no deeper block marker
                    error('IPL:invalidFile', 'block start marker inside named block in file %s line %d', filename, nl)
                end
            end
    end
    data.struct{end+1} = hc;
end

if ~ischar(hc) % end of file, no sequential data available
    fclose(fid);
    return;
end

% extract and evaluate $KD_DEFINITION block
[kd_definition, data.struct] = sdf_cut(data.struct, 'KD_DEFINITION');

data.kd_def = cell(1,0);
data.kd_ind = cell(1,0);
data.kd_oth = cell(1,0);

type = 'NONE';
for i = 1:length(kd_definition)
    hc = kd_definition{i};
    if strncmp(hc, '*', 1), continue, end % skip comment lines
    hc = deblank(regexprep(hc, '!+.*', ''));  % erase inline comments
    switch hc(1:2)
        case '#:'
            type = hc(3:end);
        case 'U:'
            data.kd_ind{end+1} = hc(3:end);
        case 'D:'
            data.kd_def{end+1} = hc(3:end);
        otherwise
            data.kd_oth{end+1} = hc;
    end
end

nc = length(data.kd_def);

if nc == 0
    error('IPL:invalidFile', 'file %s has no valid sequential data definitions', filename)
end

% read only requested channels: get index
index = 1:length(data.kd_def);
nci = nc;
if ~isempty(options.channel)

    % clean up requested channel definition
    options.channel = cellstr(options.channel);
    options.channel = cellfun(@CleanUpChannelName,options.channel(:),'UniformOutput',false);
    [tmp2, tmp1, tmp] = unique(options.channel);

    % display multiple requests
    tmp = setdiff(tmp,tmp1);
    if ~isempty(tmp)
       cellfun(@(x) fprintf('IPL_READ: Multiple requests for channel ''%s''\n',x),options.channel(tmp))
    end
    options.channel = tmp2;

    % get index & clean up iplos channel definition
    [tmp1,index] = ismember(options.channel,cellfun(@CleanUpChannelName,data.kd_def,'UniformOutput',false));
    index = sort(index(index>0));

    % display requested channels that are not member of iplos file
    if sum(~tmp1)
        fprintf('IPL_READ: File: ''%s''\n',filename);
        cellfun(@(x) fprintf('IPL_READ:       --> Did not find requested channel ''%s''\n',x),options.channel(~tmp1));
    end

    % number of channels to return
    nci = length(index);

    if nci == 0
        % no channels specified
        data.kd_def = cell(1,0);
    else
        % update/trim data channel definitions
        data.kd_def = data.kd_def(index);
    end
end

if dtype == 'M'
    fclose(fid);
    return % only meta data is returned, no sequential data
end

if dtype == 'S'
    data.kd_dat = single([]);
else
    data.kd_dat = double([]);
end

% no channels specified, skip file reading
if nci == 0
    fclose(fid);
    return
end

switch type
    case {'KRBI','KDBI'}
        % Read binary data
        switch type
            case 'KRBI'
                ipldtype = 'float32';
                mcount = 20;
            case 'KDBI'
                ipldtype = 'float64';
                mcount = 10;
        end
        % workaround for MATLAB bug in verison 7.5 (R2007b) which occurs if
        % first binary number is NaN, where the last fgetl call eats one
        % byte too much (see MATLAB service request 1-988VA1 of 2009-03-15,
        % resulting in bug report 535858 of 2009-04-01)
        fseek(fid, -1, 'cof'); % we go back one byte and expect the last LF
        if fread(fid, 1, 'uint8') ~= 10 % we expected LF=10, if not ...
            fseek(fid, -2, 'cof'); % we have to go back one more byte
            if fread(fid, 1, 'uint8') ~= 10 % we expected LF=10, if not ...
                error('IPL:matlabBug', 'MATLAB bug workaround failed')
            end
        end

        if nci == nc
            % read all channels
            if dtype == 'S'
                [data.kd_dat count] = fread(fid, inf, [ipldtype,'=>single']);
            else
                [data.kd_dat count] = fread(fid, inf, [ipldtype,'=>double']);
            end
            if mod(count, mcount) % count must be a multiple of mcount (80 bytes)
                warning('IPL:sequentialEOF', 'unexpected end of sequential data in file %s', filename)
            end
            nr = floor(count / nc); % number of full records
            if sum(~isnan(data.kd_dat(nr*nc+1:count))) % expect NaN only padding
                warning('IPL:filePadding', 'file %s is not correctly padded', filename)
            end
            count = nr*nc; % remove further appended NaNs
            while (sum(isnan(data.kd_dat(count-nc+1:count))) == nc)
                nr = nr - 1; % remove appended NaN record
                count = nr*nc;
            end
            data.kd_dat = reshape(data.kd_dat(1:count), nc, nr)';
        else
            % read requested channels only
            nr = 0;
            nm = 0;
            while 1
                if dtype == 'S'
                    [tmp count] = fread(fid, nc, [ipldtype,'=>single']);
                else
                    [tmp count] = fread(fid, nc, [ipldtype,'=>double']);
                end

                if count ~= nc, break, end
                nr = nr+1;

                % preallocate records in data.kd_dat
                if nr > nm
                    if dtype == 'S'
                        data.kd_dat(nr:nm,1:nci) = single(NaN);
                    else
                        data.kd_dat(nr:nm,1:nci) = double(NaN);
                    end
                    nm = nm + nmp;
                end

                data.kd_dat(nr,:) = tmp(index);
            end

            % remove further appended NaNs
            while (sum(isnan(data.kd_dat(nr,:))) == length(index))
                nr = nr - 1;
            end
            data.kd_dat = data.kd_dat(1:nr,:);
        end
    case {'LRFI','LDFI'}
        % read formated data
        switch type
            case 'LDFI'
                nchar = 20;     % number of characters
                vpl = 80/nchar; % values per line
            case 'LRFI'
                nchar = 10;     % number of characters
                vpl = 80/nchar; % values per line
        end

        nr = 0;
        nm = 0;
        while 1
            cc = cell(1,nc);
            for ic = 1:nc
                mic = mod(ic-1, vpl);
                if mic == 0
                    hc = fgetl(fid);
                    nl = nl + 1;
                    if ~ischar(hc), break, end
                    if length(hc) > 80 % ignore extra characters
                        hc = hc(1:80);
                    else
                        hc(end+1:80) = ' ';
                    end
                end
                cc{ic} = hc(mic*nchar+1:mic*nchar+nchar);
            end
            if ~ischar(hc), break, end
            nr = nr + 1;
            if nr > nm % preallocate records in data.kd_dat
                nm = nm + nmp;
                if dtype == 'S'
                    data.kd_dat(nr:nm,1:nci) = single(NaN);
                else
                    data.kd_dat(nr:nm,1:nci) = double(NaN);
                end
            end
            for ic = 1:nci
                if sum(isspace(cc{index(ic)})) == nchar
                    warning('IPL:whiteSpace', 'unexpected whitespace in file %s line %d', filename, nl)
                end
                hd = sscanf(cc{index(ic)}, '%f');
                if length(hd) == 1 % take result if one valid number was read
                    if dtype == 'S'
                        data.kd_dat(nr,index(ic)) = single(hd);
                    else
                        data.kd_dat(nr,index(ic)) = double(hd);
                    end
                end
            end
        end
        if nm > nr % remove unused preallocated records in data.kd_dat
            data.kd_dat = data.kd_dat(1:nr,:);
        end
        if ic ~= 1
            warning('IPL:sequentialEOF', 'unexpected end of sequential data in file %s', filename)
        end
    otherwise
        error('IPL:invalidFile', 'type %s in file %s is not supported', type, filename)
end
fclose(fid);
end

%% subfunctions

function out = CleanUpChannelName(in)
tmp = strfind(in,',');
if isempty(tmp)
    out = strtrim(in);
else
    out = [strtrim(in(1:tmp(1)-1)),',',strtrim(in(tmp(1)+1:end))];
end
end

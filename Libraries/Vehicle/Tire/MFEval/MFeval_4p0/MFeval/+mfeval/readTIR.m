function tirParams = readTIR(FileNameLocation)%#codegen
% READTIR reads a user specified TIR file and converts it to a MATLAB
% structure.
% The structure containing the tire model parameters can be used as input
% in mfeval or the Simulink masks.
%
% The performance of mfeval can be improved using a structure of parameters
% instead of a string pointing to the .tir file location.
%
% The function loops over each line in the TIR file and adds each value to
% the corresponding name in the structure.
% Due to limitations in C code generation, the structure names are defined
% during initialization, and an if statement must be defined for each
% parameter.
%
% Syntax: [tirParams] = mfeval.readTIR(FileNameLocation), where:
%
% - FileNameLocation may refer to a Magic Formula tyre property file
%       (.tir)
%
% - tirParams is structure similar to the tyre property file containing the
%       model parameters
%
% See also: mfeval

% Declare Magic Formula 6.1 parameter names for C code generation
tirParams.FILE_TYPE = 'default';
tirParams.FILE_VERSION = 3.0;
tirParams.FILE_FORMAT = 'default';
tirParams.LENGTH = 'default';
tirParams.FORCE = 'default';
tirParams.ANGLE = 'default';
tirParams.MASS = 'default';
tirParams.TIME = 'default';
tirParams.FITTYP = 0;
tirParams.TYRESIDE = 'LEFT';
tirParams.LONGVL = 16.7;
tirParams.VXLOW = 1;
tirParams.ROAD_INCREMENT = 0.01;
tirParams.ROAD_DIRECTION = 1;
tirParams.PROPERTY_FILE_FORMAT = 'default';
tirParams.USER_SUB_ID = 815;
tirParams.N_TIRE_STATES = 4;
tirParams.USE_MODE = 124;
tirParams.HMAX_LOCAL = 2.5E-4;
tirParams.TIME_SWITCH_INTEG = 0.1;
tirParams.UNLOADED_RADIUS = 0.3135;
tirParams.WIDTH = 0.205;
tirParams.ASPECT_RATIO = 0.6 ;
tirParams.RIM_RADIUS = 0.1905;
tirParams.RIM_WIDTH = 0.152;
tirParams.INFLPRES = 220000;
tirParams.NOMPRES = 220000;
tirParams.MASS1 = 9.3;
tirParams.IXX = 0.391;
tirParams.IYY = 0.736;
tirParams.BELT_MASS = 7;
tirParams.BELT_IXX = 0.34;
tirParams.BELT_IYY = 0.6;
tirParams.GRAVITY = -9.81;
tirParams.FNOMIN = 4000;
tirParams.VERTICAL_STIFFNESS = 200000;
tirParams.VERTICAL_DAMPING = 50;
tirParams.MC_CONTOUR_A = 0.5;
tirParams.MC_CONTOUR_B = 0.5;
tirParams.BREFF = 8.4;
tirParams.DREFF = 0.27;
tirParams.FREFF = 0.07;
tirParams.Q_RE0 = 1;
tirParams.Q_V1 = 0;
tirParams.Q_V2 = 0;
tirParams.Q_FZ2 = 1.0E-4;
tirParams.Q_FCX = 0;
tirParams.Q_FCY = 0;
tirParams.Q_CAM = 0;
tirParams.PFZ1 = 0;
tirParams.BOTTOM_OFFST = 0.01;
tirParams.BOTTOM_STIFF = 2000000;
tirParams.LONGITUDINAL_STIFFNESS = 300000;
tirParams.LATERAL_STIFFNESS = 100000;
tirParams.YAW_STIFFNESS = 5000;
tirParams.FREQ_LONG = 80;
tirParams.FREQ_LAT = 40;
tirParams.FREQ_YAW = 50;
tirParams.FREQ_WINDUP = 70;
tirParams.DAMP_LONG = 0.04;
tirParams.DAMP_LAT = 0.04;
tirParams.DAMP_YAW = 0.04;
tirParams.DAMP_WINDUP = 0.04;
tirParams.DAMP_RESIDUAL = 0.0020;
tirParams.DAMP_VLOW = 0.0010;
tirParams.Q_BVX = 0;
tirParams.Q_BVT = 0;
tirParams.PCFX1 = 0;
tirParams.PCFX2 = 0;
tirParams.PCFX3 = 0;
tirParams.PCFY1 = 0;
tirParams.PCFY2 = 0;
tirParams.PCFY3 = 0;
tirParams.PCMZ1 = 0;
tirParams.Q_RA1 = 0.5;
tirParams.Q_RA2 = 1;
tirParams.Q_RB1 = 1;
tirParams.Q_RB2 = -1;
tirParams.ELLIPS_SHIFT = 0.8;
tirParams.ELLIPS_LENGTH = 1;
tirParams.ELLIPS_HEIGHT = 1;
tirParams.ELLIPS_ORDER = 1.8;
tirParams.ELLIPS_MAX_STEP = 0.025;
tirParams.ELLIPS_NWIDTH = 10;
tirParams.ELLIPS_NLENGTH = 10;
tirParams.PRESMIN = 10000;
tirParams.PRESMAX = 1000000;
tirParams.FZMIN = 100;
tirParams.FZMAX = 10000;
tirParams.KPUMIN = -1.5;
tirParams.KPUMAX = 1.5;
tirParams.ALPMIN = -1.5;
tirParams.ALPMAX = 1.5;
tirParams.CAMMIN = -0.175;
tirParams.CAMMAX = 0.175;
tirParams.LFZO = 1;
tirParams.LCX = 1;
tirParams.LMUX = 1;
tirParams.LEX = 1;
tirParams.LKX = 1;
tirParams.LHX = 1;
tirParams.LVX = 1;
tirParams.LCY = 1;
tirParams.LMUY = 1;
tirParams.LEY = 1;
tirParams.LKY = 1;
tirParams.LHY = 1;
tirParams.LVY = 1;
tirParams.LTR = 1;
tirParams.LRES = 1;
tirParams.LXAL = 1;
tirParams.LYKA = 1;
tirParams.LVYKA = 1;
tirParams.LS = 1;
tirParams.LKYC = 1;
tirParams.LKZC = 1;
tirParams.LVMX = 1;
tirParams.LMX = 1;
tirParams.LMY = 1;
tirParams.LMP = 1;
tirParams.PCX1 = 1.65;
tirParams.PDX1 = 1.3;
tirParams.PDX2 = -0.15;
tirParams.PDX3 = 0;
tirParams.PEX1 = 0;
tirParams.PEX2 = 0;
tirParams.PEX3 = 0;
tirParams.PEX4 = 0;
tirParams.PKX1 = 20;
tirParams.PKX2 = 0;
tirParams.PKX3 = 0;
tirParams.PHX1 = 0;
tirParams.PHX2 = 0;
tirParams.PVX1 = 0;
tirParams.PVX2 = 0;
tirParams.PPX1 = 0;
tirParams.PPX2 = 0;
tirParams.PPX3 = 0;
tirParams.PPX4 = 0;
tirParams.RBX1 = 20;
tirParams.RBX2 = 15;
tirParams.RBX3 = 0;
tirParams.RCX1 = 1;
tirParams.REX1 = 0;
tirParams.REX2 = 0;
tirParams.RHX1 = 0;
tirParams.QSX1 = 0;
tirParams.QSX2 = 0;
tirParams.QSX3 = 0;
tirParams.QSX4 = 5;
tirParams.QSX5 = 1;
tirParams.QSX6 = 10;
tirParams.QSX7 = 0;
tirParams.QSX8 = 0;
tirParams.QSX9 = 0.4;
tirParams.QSX10 = 0;
tirParams.QSX11 = 5;
tirParams.QSX12 = 0;
tirParams.QSX13 = 0;
tirParams.QSX14 = 0;
tirParams.PPMX1 = 0;
tirParams.PCY1 = 1.3;
tirParams.PDY1 = 1.1;
tirParams.PDY2 = -0.15;
tirParams.PDY3 = 0;
tirParams.PEY1 = 0;
tirParams.PEY2 = 0;
tirParams.PEY3 = 0;
tirParams.PEY4 = 0;
tirParams.PEY5 = 0;
tirParams.PKY1 = -20;
tirParams.PKY2 = 1;
tirParams.PKY3 = 0;
tirParams.PKY4 = 2;
tirParams.PKY5 = 0;
tirParams.PKY6 = -1;
tirParams.PKY7 = 0;
tirParams.PHY1 = 0;
tirParams.PHY2 = 0;
tirParams.PVY1 = 0;
tirParams.PVY2 = 0;
tirParams.PVY3 = 0;
tirParams.PVY4 = 0;
tirParams.PPY1 = 0;
tirParams.PPY2 = 0;
tirParams.PPY3 = 0;
tirParams.PPY4 = 0;
tirParams.PPY5 = 0;
tirParams.RBY1 = 10;
tirParams.RBY2 = 10;
tirParams.RBY3 = 0;
tirParams.RBY4 = 0;
tirParams.RCY1 = 1;
tirParams.REY1 = 0;
tirParams.REY2 = 0;
tirParams.RHY1 = 0;
tirParams.RHY2 = 0;
tirParams.RVY1 = 0;
tirParams.RVY2 = 0;
tirParams.RVY3 = 0;
tirParams.RVY4 = 20;
tirParams.RVY5 = 2;
tirParams.RVY6 = 10;
tirParams.QSY1 = 0.01;
tirParams.QSY2 = 0;
tirParams.QSY3 = 4.0E-4;
tirParams.QSY4 = 4.0E-5;
tirParams.QSY5 = 0;
tirParams.QSY6 = 0;
tirParams.QSY7 = 0.85;
tirParams.QSY8 = -0.4;
tirParams.QBZ1 = 10;
tirParams.QBZ2 = 0;
tirParams.QBZ3 = 0;
tirParams.QBZ4 = 0;
tirParams.QBZ5 = 0;
tirParams.QBZ9 = 10;
tirParams.QBZ10 = 0;
tirParams.QCZ1 = 1.1;
tirParams.QDZ1 = 0.12;
tirParams.QDZ2 = 0;
tirParams.QDZ3 = 0;
tirParams.QDZ4 = 0;
tirParams.QDZ6 = 0;
tirParams.QDZ7 = 0;
tirParams.QDZ8 = -0.05;
tirParams.QDZ9 = 0;
tirParams.QDZ10 = 0;
tirParams.QDZ11 = 0;
tirParams.QEZ1 = 0;
tirParams.QEZ2 = 0;
tirParams.QEZ3 = 0;
tirParams.QEZ4 = 0;
tirParams.QEZ5 = 0;
tirParams.QHZ1 = 0;
tirParams.QHZ2 = 0;
tirParams.QHZ3 = 0;
tirParams.QHZ4 = 0;
tirParams.PPZ1 = 0;
tirParams.PPZ2 = 0;
tirParams.SSZ1 = 0;
tirParams.SSZ2 = 0;
tirParams.SSZ3 = 0;
tirParams.SSZ4 = 0;
tirParams.PDXP1 = 0.4;
tirParams.PDXP2 = 0;
tirParams.PDXP3 = 0;
tirParams.PKYP1 = 1;
tirParams.PDYP1 = 0.4;
tirParams.PDYP2 = 0;
tirParams.PDYP3 = 0;
tirParams.PDYP4 = 0;
tirParams.PHYP1 = 1;
tirParams.PHYP2 = 0.15;
tirParams.PHYP3 = 0;
tirParams.PHYP4 = -4;
tirParams.PECP1 = 0.5;
tirParams.PECP2 = 0;
tirParams.QDTP1 = 10;
tirParams.QCRP1 = 0.2;
tirParams.QCRP2 = 0.1;
tirParams.QBRP1 = 0.1;
tirParams.QDRP1 = 1;

% Declare Magic Formula 6.2 parameter names for C code generation
tirParams.FUNCTION_NAME = 'default';
tirParams.SWITCH_INTEG = 0;
tirParams.Q_FCY2 = 0;
tirParams.Q_CAM1 = 0;
tirParams.Q_CAM2 = 0;
tirParams.Q_CAM3 = 0;
tirParams.Q_FYS1 = 0;
tirParams.Q_FYS2 = 0;
tirParams.Q_FYS3 = 0;
tirParams.ENV_C1 = 0;
tirParams.ENV_C2 = 0;

% Declare Magic Formula 5.2 parameter names for C code generation
tirParams.Q_A1 = 0;
tirParams.Q_A2 = 0;
tirParams.PHY3 = 0;
tirParams.PTX1 = 0;
tirParams.PTX2 = 0;
tirParams.PTX3 = 0;
tirParams.PTY1 = 0;
tirParams.PTY2 = 0;
tirParams.LSGKP = 1;
tirParams.LSGAL = 1;

% Declare variables for the loop
skipSection = false;

% Open the file
ident = fopen(FileNameLocation);

if ident == -1
    % File doesn't exist
    error('readTIR:File:CannotBeOpen','The tire property located in: "%s" cannot be open', FileNameLocation)
end

% Read the file
charTIRFile = fread(ident, '*char');

% Transpose the file
charTIRFile = charTIRFile';

% Find new lines along the tir file. Note that char(10) is used for code
% generation.
newLineIdx = strfind(charTIRFile, char(10)); %#ok<CHARTEN>

% Check if the last line has been captured
if newLineIdx(end) ~= length(charTIRFile)
    % Append last line into the index
    newLineIdx = [newLineIdx, length(charTIRFile)];
end

% Number of lines in the text file
nlines = length(newLineIdx);

% Initial definition of the cell to register each text line
cellTIRFile = cell(nlines, 1);

% Create a cell with multiple lines using charTIRFile
for ii = 1:nlines
    if ii == 1
        in = 1;
    else
        in = newLineIdx(ii - 1) + 1;
    end
    out = newLineIdx(ii) - 2;
    cellTIRFile{ii, 1} = charTIRFile(1, in:out);
end % For all lines

% Close the file
fclose(ident);


% Mass is used as a variable name twice in the MF6.1 TIR
% format. Once in the Units section and once in the Inertia
% section. Rename the inertia section as MASS1. Undo this when
% writing the TIR file.
indxMass = 1;

% Loop through all the lines
for jj = 1:nlines
    % Create a char variable with the current line
    currentLine = cellTIRFile{jj, 1};
    
    % If the line is not empty
    if ~isempty(currentLine)
        
        % If current line is not a title, comment or description
        currentLineNoSpaces = strtrim(currentLine);
        
        % In MF5.2 tir files there is a section named "SHAPE" that is
        % obsolete and was used to calculate the tire-to-road volume of
        % interference
        if strcmp(currentLineNoSpaces,'[SHAPE]')
            skipSection = true;
        elseif currentLineNoSpaces(1) == '[' && ~strcmp(currentLineNoSpaces,'[SHAPE]')
            skipSection = false;
        end
        
        if (currentLineNoSpaces(1) ~= '[' && currentLineNoSpaces(1) ~= '$' && currentLineNoSpaces(1) ~= '!' && ~skipSection)
            
            % Find location of "=" in the current line
            temp_equal = strfind(currentLine, '=');
            
            % Use only the first indexed value (force size to be 1x1)
            indx_equal = temp_equal(1);
            
            % Get current Parameter Name
            unCutParamName = currentLine(1:(indx_equal-1));
            ParamName = strtrim(unCutParamName);
            
            % Find location of "$" in the current line
            temp_dollar = strfind(currentLine, '$');
            
            % If there is no dollar in current line
            if (isempty(temp_dollar) == 1)
                unCutParamValue = currentLine(indx_equal+1:end);
                ParamValue = strtrim(unCutParamValue);
            else
                % Use only the first indexed value (force size to be 1x1)
                index_dollar = temp_dollar(1);
                unCutParamValue = currentLine(indx_equal+1:index_dollar-1);
                ParamValue = strtrim(unCutParamValue);
            end
            
            % Due to limitations in C code, an if statement must be defined
            % for each parameter.
            
            if strcmp(ParamName,'FILE_TYPE')
                tirParams.FILE_TYPE = ParamValue;
            end
            
            if strcmp(ParamName,'FILE_VERSION')
                tirParams.FILE_VERSION = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FILE_FORMAT')
                tirParams.FILE_FORMAT = ParamValue;
            end
            
            if strcmp(ParamName,'LENGTH')
                tirParams.LENGTH = ParamValue;
            end
            
            if strcmp(ParamName,'FORCE')
                tirParams.FORCE = ParamValue;
            end
            
            if strcmp(ParamName,'ANGLE')
                tirParams.ANGLE = ParamValue;
            end
            
            if strcmp(ParamName,'MASS') && indxMass<=1
                % Assume that the first MASS in the .tir file defines the
                % units and is a char.
                tirParams.MASS = ParamValue;
                indxMass = 100;
            end
            
            if strcmp(ParamName,'TIME')
                tirParams.TIME = ParamValue;
            end
            
            if strcmp(ParamName,'FITTYP')
                tirParams.FITTYP = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'TYRESIDE')
                tirParams.TYRESIDE = ParamValue;
            end
            
            if strcmp(ParamName,'LONGVL')
                tirParams.LONGVL = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'VXLOW')
                tirParams.VXLOW = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ROAD_INCREMENT')
                tirParams.ROAD_INCREMENT = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ROAD_DIRECTION')
                tirParams.ROAD_DIRECTION = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PROPERTY_FILE_FORMAT')
                tirParams.PROPERTY_FILE_FORMAT = ParamValue;
            end
            
            if strcmp(ParamName,'USER_SUB_ID')
                tirParams.USER_SUB_ID = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'N_TIRE_STATES')
                tirParams.N_TIRE_STATES = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'USE_MODE')
                tirParams.USE_MODE = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'HMAX_LOCAL')
                tirParams.HMAX_LOCAL = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'TIME_SWITCH_INTEG')
                tirParams.TIME_SWITCH_INTEG = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'UNLOADED_RADIUS')
                tirParams.UNLOADED_RADIUS = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'WIDTH')
                tirParams.WIDTH = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ASPECT_RATIO')
                tirParams.ASPECT_RATIO = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RIM_RADIUS')
                tirParams.RIM_RADIUS = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RIM_WIDTH')
                tirParams.RIM_WIDTH = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'INFLPRES')
                tirParams.INFLPRES = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'NOMPRES')
                tirParams.NOMPRES = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'MASS') && indxMass>1
                % Assume that the second MASS in the .tir file is the the
                % inertia section and is a double
                tirParams.MASS1 = str2double(ParamValue);
                
                % If ParmValue is not a double "str2double" will pass a NaN
                % This line will protect against this setting MASS1 to 9.3
                tirParams.MASS1(isnan(tirParams.MASS1)) = 9.3;
            end
            
            if strcmp(ParamName,'IXX')
                tirParams.IXX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'IYY')
                tirParams.IYY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'BELT_MASS')
                tirParams.BELT_MASS = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'BELT_IXX')
                tirParams.BELT_IXX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'BELT_IYY')
                tirParams.BELT_IYY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'GRAVITY')
                tirParams.GRAVITY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FNOMIN')
                tirParams.FNOMIN = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'VERTICAL_STIFFNESS')
                tirParams.VERTICAL_STIFFNESS = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'VERTICAL_DAMPING')
                tirParams.VERTICAL_DAMPING = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'MC_CONTOUR_A')
                tirParams.MC_CONTOUR_A = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'MC_CONTOUR_B')
                tirParams.MC_CONTOUR_B = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'BREFF')
                tirParams.BREFF = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'DREFF')
                tirParams.DREFF = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FREFF')
                tirParams.FREFF = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_RE0')
                tirParams.Q_RE0 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_V1')
                tirParams.Q_V1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_V2')
                tirParams.Q_V2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_FZ2')
                tirParams.Q_FZ2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_FCX')
                tirParams.Q_FCX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_FCY')
                tirParams.Q_FCY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_CAM')
                tirParams.Q_CAM = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PFZ1')
                tirParams.PFZ1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'BOTTOM_OFFST')
                tirParams.BOTTOM_OFFST = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'BOTTOM_STIFF')
                tirParams.BOTTOM_STIFF = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LONGITUDINAL_STIFFNESS')
                tirParams.LONGITUDINAL_STIFFNESS = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LATERAL_STIFFNESS')
                tirParams.LATERAL_STIFFNESS = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'YAW_STIFFNESS')
                tirParams.YAW_STIFFNESS = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FREQ_LONG')
                tirParams.FREQ_LONG = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FREQ_LAT')
                tirParams.FREQ_LAT = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FREQ_YAW')
                tirParams.FREQ_YAW = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FREQ_WINDUP')
                tirParams.FREQ_WINDUP = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'DAMP_LONG')
                tirParams.DAMP_LONG = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'DAMP_LAT')
                tirParams.DAMP_LAT = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'DAMP_YAW')
                tirParams.DAMP_YAW = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'DAMP_WINDUP')
                tirParams.DAMP_WINDUP = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'DAMP_RESIDUAL')
                tirParams.DAMP_RESIDUAL = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'DAMP_VLOW')
                tirParams.DAMP_VLOW = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_BVX')
                tirParams.Q_BVX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_BVT')
                tirParams.Q_BVT = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCFX1')
                tirParams.PCFX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCFX2')
                tirParams.PCFX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCFX3')
                tirParams.PCFX3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCFY1')
                tirParams.PCFY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCFY2')
                tirParams.PCFY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCFY3')
                tirParams.PCFY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCMZ1')
                tirParams.PCMZ1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_RA1')
                tirParams.Q_RA1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_RA2')
                tirParams.Q_RA2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_RB1')
                tirParams.Q_RB1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_RB2')
                tirParams.Q_RB2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ELLIPS_SHIFT')
                tirParams.ELLIPS_SHIFT = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ELLIPS_LENGTH')
                tirParams.ELLIPS_LENGTH = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ELLIPS_HEIGHT')
                tirParams.ELLIPS_HEIGHT = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ELLIPS_ORDER')
                tirParams.ELLIPS_ORDER = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ELLIPS_MAX_STEP')
                tirParams.ELLIPS_MAX_STEP = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ELLIPS_NWIDTH')
                tirParams.ELLIPS_NWIDTH = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ELLIPS_NLENGTH')
                tirParams.ELLIPS_NLENGTH = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PRESMIN')
                tirParams.PRESMIN = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PRESMAX')
                tirParams.PRESMAX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FZMIN')
                tirParams.FZMIN = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'FZMAX')
                tirParams.FZMAX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'KPUMIN')
                tirParams.KPUMIN = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'KPUMAX')
                tirParams.KPUMAX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ALPMIN')
                tirParams.ALPMIN = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ALPMAX')
                tirParams.ALPMAX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'CAMMIN')
                tirParams.CAMMIN = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'CAMMAX')
                tirParams.CAMMAX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LFZO')
                tirParams.LFZO = str2double(ParamValue);
            end
            if strcmp(ParamName,'LCX')
                tirParams.LCX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LMUX')
                tirParams.LMUX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LEX')
                tirParams.LEX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LKX')
                tirParams.LKX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LHX')
                tirParams.LHX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LVX')
                tirParams.LVX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LCY')
                tirParams.LCY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LMUY')
                tirParams.LMUY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LEY')
                tirParams.LEY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LKY')
                tirParams.LKY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LHY')
                tirParams.LHY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LVY')
                tirParams.LVY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LTR')
                tirParams.LTR = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LRES')
                tirParams.LRES = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LXAL')
                tirParams.LXAL = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LYKA')
                tirParams.LYKA = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LVYKA')
                tirParams.LVYKA = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LS')
                tirParams.LS = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LKYC')
                tirParams.LKYC = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LKZC')
                tirParams.LKZC = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LVMX')
                tirParams.LVMX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LMX')
                tirParams.LMX = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LMY')
                tirParams.LMY = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LMP')
                tirParams.LMP = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCX1')
                tirParams.PCX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDX1')
                tirParams.PDX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDX2')
                tirParams.PDX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDX3')
                tirParams.PDX3 = str2double(ParamValue);
            end
            if strcmp(ParamName,'PEX1')
                tirParams.PEX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PEX2')
                tirParams.PEX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PEX3')
                tirParams.PEX3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PEX4')
                tirParams.PEX4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKX1')
                tirParams.PKX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKX2')
                tirParams.PKX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKX3')
                tirParams.PKX3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHX1')
                tirParams.PHX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHX2')
                tirParams.PHX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PVX1')
                tirParams.PVX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PVX2')
                tirParams.PVX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPX1')
                tirParams.PPX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPX2')
                tirParams.PPX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPX3')
                tirParams.PPX3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPX4')
                tirParams.PPX4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RBX1')
                tirParams.RBX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RBX2')
                tirParams.RBX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RBX3')
                tirParams.RBX3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RCX1')
                tirParams.RCX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'REX1')
                tirParams.REX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'REX2')
                tirParams.REX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RHX1')
                tirParams.RHX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX1')
                tirParams.QSX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX2')
                tirParams.QSX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX3')
                tirParams.QSX3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX4')
                tirParams.QSX4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX5')
                tirParams.QSX5 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX6')
                tirParams.QSX6 = str2double(ParamValue);
            end
            if strcmp(ParamName,'QSX7')
                tirParams.QSX7 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX8')
                tirParams.QSX8 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX9')
                tirParams.QSX9 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX10')
                tirParams.QSX10 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX11')
                tirParams.QSX11 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX12')
                tirParams.QSX12 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX13')
                tirParams.QSX13 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSX14')
                tirParams.QSX14 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPMX1')
                tirParams.PPMX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PCY1')
                tirParams.PCY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDY1')
                tirParams.PDY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDY2')
                tirParams.PDY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDY3')
                tirParams.PDY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PEY1')
                tirParams.PEY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PEY2')
                tirParams.PEY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PEY3')
                tirParams.PEY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PEY4')
                tirParams.PEY4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PEY5')
                tirParams.PEY5 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKY1')
                tirParams.PKY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKY2')
                tirParams.PKY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKY3')
                tirParams.PKY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKY4')
                tirParams.PKY4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKY5')
                tirParams.PKY5 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKY6')
                tirParams.PKY6 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKY7')
                tirParams.PKY7 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHY1')
                tirParams.PHY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHY2')
                tirParams.PHY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PVY1')
                tirParams.PVY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PVY2')
                tirParams.PVY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PVY3')
                tirParams.PVY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PVY4')
                tirParams.PVY4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPY1')
                tirParams.PPY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPY2')
                tirParams.PPY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPY3')
                tirParams.PPY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPY4')
                tirParams.PPY4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPY5')
                tirParams.PPY5 = str2double(ParamValue);
            end
            if strcmp(ParamName,'RBY1')
                tirParams.RBY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RBY2')
                tirParams.RBY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RBY3')
                tirParams.RBY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RBY4')
                tirParams.RBY4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RCY1')
                tirParams.RCY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'REY1')
                tirParams.REY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'REY2')
                tirParams.REY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RHY1')
                tirParams.RHY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RHY2')
                tirParams.RHY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RVY1')
                tirParams.RVY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RVY2')
                tirParams.RVY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RVY3')
                tirParams.RVY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RVY4')
                tirParams.RVY4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RVY5')
                tirParams.RVY5 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'RVY6')
                tirParams.RVY6 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSY1')
                tirParams.QSY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSY2')
                tirParams.QSY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSY3')
                tirParams.QSY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSY4')
                tirParams.QSY4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSY5')
                tirParams.QSY5 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSY6')
                tirParams.QSY6 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSY7')
                tirParams.QSY7 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QSY8')
                tirParams.QSY8 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QBZ1')
                tirParams.QBZ1 = str2double(ParamValue);
            end
            if strcmp(ParamName,'QBZ2')
                tirParams.QBZ2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QBZ3')
                tirParams.QBZ3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QBZ4')
                tirParams.QBZ4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QBZ5')
                tirParams.QBZ5 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QBZ9')
                tirParams.QBZ9 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QBZ10')
                tirParams.QBZ10 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QCZ1')
                tirParams.QCZ1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ1')
                tirParams.QDZ1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ2')
                tirParams.QDZ2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ3')
                tirParams.QDZ3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ4')
                tirParams.QDZ4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ6')
                tirParams.QDZ6 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ7')
                tirParams.QDZ7 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ8')
                tirParams.QDZ8 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ9')
                tirParams.QDZ9 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ10')
                tirParams.QDZ10 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDZ11')
                tirParams.QDZ11 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QEZ1')
                tirParams.QEZ1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QEZ2')
                tirParams.QEZ2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QEZ3')
                tirParams.QEZ3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QEZ4')
                tirParams.QEZ4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QEZ5')
                tirParams.QEZ5 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QHZ1')
                tirParams.QHZ1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QHZ2')
                tirParams.QHZ2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QHZ3')
                tirParams.QHZ3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QHZ4')
                tirParams.QHZ4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPZ1')
                tirParams.PPZ1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PPZ2')
                tirParams.PPZ2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'SSZ1')
                tirParams.SSZ1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'SSZ2')
                tirParams.SSZ2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'SSZ3')
                tirParams.SSZ3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'SSZ4')
                tirParams.SSZ4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDXP1')
                tirParams.PDXP1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDXP2')
                tirParams.PDXP2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDXP3')
                tirParams.PDXP3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PKYP1')
                tirParams.PKYP1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDYP1')
                tirParams.PDYP1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDYP2')
                tirParams.PDYP2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDYP3')
                tirParams.PDYP3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PDYP4')
                tirParams.PDYP4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHYP1')
                tirParams.PHYP1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHYP2')
                tirParams.PHYP2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHYP3')
                tirParams.PHYP3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHYP4')
                tirParams.PHYP4 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PECP1')
                tirParams.PECP1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PECP2')
                tirParams.PECP2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDTP1')
                tirParams.QDTP1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QCRP1')
                tirParams.QCRP1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QCRP2')
                tirParams.QCRP2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QBRP1')
                tirParams.QBRP1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'QDRP1')
                tirParams.QDRP1 = str2double(ParamValue);
            end
            
            % Extra parameters for Magic Formula 6.2
            if strcmp(ParamName,'FUNCTION_NAME')
                tirParams.FUNCTION_NAME = ParamValue;
            end
            
            if strcmp(ParamName,'SWITCH_INTEG')
                tirParams.SWITCH_INTEG = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_FCY2')
                tirParams.Q_FCY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_CAM1')
                tirParams.Q_CAM1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_CAM2')
                tirParams.Q_CAM2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_CAM3')
                tirParams.Q_CAM3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_FYS1')
                tirParams.Q_FYS1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_FYS2')
                tirParams.Q_FYS2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_FYS3')
                tirParams.Q_FYS3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ENV_C1')
                tirParams.ENV_C1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'ENV_C2')
                tirParams.ENV_C2 = str2double(ParamValue);
            end
            
            % Extra parameters for Magic Formula 5.2
            if strcmp(ParamName,'Q_A1')
                tirParams.Q_A1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'Q_A2')
                tirParams.Q_A2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PHY3')
                tirParams.PHY3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PTX1')
                tirParams.PTX1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PTX2')
                tirParams.PTX2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PTX3')
                tirParams.PTX3 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PTY1')
                tirParams.PTY1 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'PTY2')
                tirParams.PTY2 = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LSGKP')
                tirParams.LSGKP = str2double(ParamValue);
            end
            
            if strcmp(ParamName,'LSGAL')
                tirParams.LSGAL = str2double(ParamValue);
            end

        end % If is not '[' '$' or '!'
    end % If current line is not empty
end % For loop

end
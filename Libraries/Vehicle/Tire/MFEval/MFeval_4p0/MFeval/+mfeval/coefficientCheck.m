function [result, c, values] = coefficientCheck(MFStruct, ParamGroup)
%COEFFICIENTCHECK Validate that model coefficients pass any restrictions
%placed on them.
%
%   [res, c, vals] = mfeval.coefficientCheck(MFStruct)
%   [res, c, vals] = mfeval.coefficientCheck(MFStruct, ParamGroup)
%
%   Outputs:
%
%   res is a struct of logical results for each coefficient
%   check where (0 = pass, 1 = fail)
%
%   c is a struct of values for which an optimiser must satisfy
%   c <= 0 to make the coefficient check pass.
%
%   vals is a struct of the values for each coefficient check.
%
%   Inputs:
%
%   mfStruct is structure of Magic Formula parameters
%
%   paramGroup is a string defining the Magic Formula parameter
%   group for which to conduct the coefficient checks for.
%   Leaving blank will run all.

if nargin < 1
    % Minimum required input arguments is 1
    errmsg = 'Not enough input arguments.';
    error(errmsg);
end

% Check that MFStruct is a structure
% As it is not a custom class, this is the best check that can be carried
% out.
validateattributes(MFStruct, ...
    {'struct'}, ...
    {'nonempty'});

if MFStruct.FITTYP ~= 61 && MFStruct.FITTYP ~= 62
    errmsg = 'coefficientCheck works only for Magic Formula 6.1 or 6.2 models. The provided tyre model is not compatible with this function';
    error('coefficientCheck:Invalid:MFStruct', errmsg);
end

inputs = generateInputs(MFStruct);

% Switch calculation mode between 'all' or 'paramGroup' based on number of
% inputs
switch nargin
    case 1 % Case 1 - Evaluate all coefficient checks
        % If one input, calculate all coefficients
        [result.Cx, values.Cx, c.Cx] = calcCx(MFStruct);
        [result.Dx, values.Dx, c.Dx] = calcDx(MFStruct, inputs);
        [result.Ex, values.Ex, c.Ex] = calcEx(MFStruct, inputs);
        [result.Cy, values.Cy, c.Cy] = calcCy(MFStruct);
        [result.Ey, values.Ey, c.Ey] = calcEy(MFStruct, inputs);
        [result.Bt, values.Bt, c.Bt] = calcBt(MFStruct, inputs);
        [result.Ct, values.Ct, c.Ct] = calcCt(MFStruct);
        [result.Et, values.Et, c.Et] = calcEt(MFStruct, inputs);
        % Note: Some models were not tested under combined
        % loading, therefore some of the combined coefficients were not
        % parametrized. When this is the case, do not evaluate this section
        if MFStruct.RBX1 ~= 0 || MFStruct.RBX3 ~= 0
            [result.Bxa, values.Bxa, c.Bxa] = calcBxa(MFStruct, inputs);
            [result.Exa, values.Exa, c.Exa] = calcExa(MFStruct, inputs);
            [result.Gxa, values.Gxa, c.Gxa] = calcGxa(MFStruct, inputs);
        end
        if MFStruct.RBY1 ~= 0 || MFStruct.RBY3 ~= 0
            [result.Byk, values.Byk, c.Byk] = calcByk(MFStruct, inputs);
            [result.Eyk, values.Eyk, c.Eyk] = calcEyk(MFStruct, inputs);
            [result.Gyk, values.Gyk, c.Gyk] = calcGyk(MFStruct, inputs);
        end
    case 2 % Evaluate only the provided ParamGroup coefficients
        
        switch ParamGroup
            case 'FyPure'
                %  Cy, Ey
                [result.Cy, values.Cy, c.Cy] = calcCy(MFStruct);
                [result.Ey, values.Ey, c.Ey] = calcEy(MFStruct, inputs);
            case 'FxPure'
                % Cx, Dx, Ex
                [result.Cx, values.Cx, c.Cx] = calcCx(MFStruct);
                [result.Dx, values.Dx, c.Dx] = calcDx(MFStruct, inputs);
                [result.Ex, values.Ex, c.Ex] = calcEx(MFStruct, inputs);
            case 'MzPure'
                % Ct, Et, Bt
                [result.Bt, values.Bt, c.Bt] = calcBt(MFStruct, inputs);
                [result.Ct, values.Ct, c.Ct] = calcCt(MFStruct);
                [result.Et, values.Et, c.Et] = calcEt(MFStruct, inputs);
            case 'FyComb'
                % Gyk, Eyk, Byk
                [result.Byk, values.Byk, c.Byk] = calcByk(MFStruct, inputs);
                [result.Eyk, values.Eyk, c.Eyk] = calcEyk(MFStruct, inputs);
                [result.Gyk, values.Gyk, c.Gyk] = calcGyk(MFStruct, inputs);
            case 'FxComb'
                % Gxa, Exa, Bxa
                [result.Bxa, values.Bxa, c.Bxa] = calcBxa(MFStruct, inputs);
                [result.Exa, values.Exa, c.Exa] = calcExa(MFStruct, inputs);
                [result.Gxa, values.Gxa, c.Gxa] = calcGxa(MFStruct, inputs);
            case 'FxPureComb'
                % Cx, Dx, Ex
                [result.Cx, values.Cx, c.Cx] = calcCx(MFStruct);
                [result.Dx, values.Dx, c.Dx] = calcDx(MFStruct, inputs);
                [result.Ex, values.Ex, c.Ex] = calcEx(MFStruct, inputs);
                % Gxa, Exa, Bxa
                [result.Bxa, values.Bxa, c.Bxa] = calcBxa(MFStruct, inputs);
                [result.Exa, values.Exa, c.Exa] = calcExa(MFStruct, inputs);
                [result.Gxa, values.Gxa, c.Gxa] = calcGxa(MFStruct, inputs);
            otherwise
                result.Nan = false;
                values.Nan = 0; % Replace with zero for rsim compatibility
                c.Nan = 0;
        end % switch ParamGroup
        
end % switch nargin


%% Internal Functions
    function inputs = generateInputs(MFStruct)
        
        % Extract tyre standard conditions and stable limits
        Pi0 = MFStruct.INFLPRES;
        Fz0 = MFStruct.FNOMIN;
        Pimin = MFStruct.PRESMIN;
        Pimax = MFStruct.PRESMAX;
        Fzmin = MFStruct.FZMIN;
        Fzmax = MFStruct.FZMAX;
        SRmin = MFStruct.KPUMIN;
        SRmax = MFStruct.KPUMAX;
        SAmin = MFStruct.ALPMIN;
        SAmax = MFStruct.ALPMAX;
        IAmin = MFStruct.CAMMIN;
        IAmax = MFStruct.CAMMAX;
        
        % To prevent Dx from failing when Fzmin = 0, change FzMin to 1.
        % This occurs because Dx = Mux*Fz where Dx must be > 0.
        if Fzmin == 0
            Fzmin = 1;
        end
        
        % Generate input parameters based on the tyre model limits
        inputs.dPi = (linspace(Pimin, Pimax, 11) - Pi0)./Pi0;               % Normalised change in inflation pressure EQN 32
        inputs.dFz = (linspace(Fzmin, Fzmax, 11) - Fz0)./Fz0;               % Normalised change in vertical load EQN 31
        inputs.Fz = linspace(Fzmin, Fzmax, 11);                             % Vertical Load
        inputs.Pi = linspace(Pimin, Pimax, 11);                             % Pressure
        inputs.SR = linspace(SRmin, SRmax, 11);                             % Slip ratio EQN 27
        inputs.SA = linspace(SAmin, SAmax, 11);                             % Slip angle EQN 28
        inputs.IA = linspace(IAmin, IAmax, 11);                             % Inclination angle EQN 29
        
    end % generateInputs

    function [fail, values, c] = calcCx(MFStruct)
        
        % MF6.1 requirement is that Cx > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        PCX1 = MFStruct.PCX1;
        LCX = MFStruct.LCX;
        
        % EQN 35
        Cx = PCX1.*LCX;
        values = Cx;
        
        % Convert Cx to c to satisfy conditions
        c = -Cx;
        
        % Generate result
        if all(Cx(:) > 0)
            fail = false;
        else
            fail = true;
        end
    end % calcCx

    function [fail, values, c] = calcDx(MFStruct, inputs)
        
        % MF6.1 requirement is that Dx > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        PDX1 = MFStruct.PDX1;
        PDX2 = MFStruct.PDX2;
        PDX3 = MFStruct.PDX3;
        PPX3 = MFStruct.PPX3;
        PPX4 = MFStruct.PPX4;
        LMUX = MFStruct.LMUX;
        
        % Generate input matrix
        [dFz, IA, dPi] = ndgrid(inputs.dFz, inputs.IA, inputs.dPi);
        Fz = repmat(inputs.Fz', 1, length(inputs.Fz), length(inputs.Fz));
        
        % EQN 37
        Mux = (PDX1 + PDX2.*dFz)...
            .*(1 - PDX3.*(IA.^2))...
            .*(1 + PPX3.*dPi + PPX4.*(dPi.^2))...
            .*LMUX;
        
        % EQN 36
        Dx = Mux.*Fz;
        values = Dx;
        
        % Convert Dx to c to satisfy conditions
        c = -Dx;
        
        % Generate results
        if all(Dx(:) > 0)
            fail = false;
        else
            fail = true;
        end
    end % calcDx

    function [fail, values, c] = calcEx(MFStruct, inputs)
        
        % MF6.1 requirement is that Ex <= 1
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        PHX1 = MFStruct.PHX1;
        PHX2 = MFStruct.PHX2;
        LHX = MFStruct.LHX;
        PEX1 = MFStruct.PEX1;
        PEX2 = MFStruct.PEX2;
        PEX3 = MFStruct.PEX3;
        PEX4 = MFStruct.PEX4;
        LEX = MFStruct.LEX;
        
        % Generate input matrix
        [dFz, SR] = ndgrid(inputs.dFz, inputs.SR);
        
        % EQN 41
        SHx = (PHX1 + PHX2.*dFz)...
            .*LHX;
        
        % EQN 34
        SRx = SR + SHx;
        
        % EQN 38
        Ex = (PEX1 + PEX2.*dFz + PEX3.*(dFz.^2))...
            .*(1 - PEX4.*sign(SRx))...
            .*LEX;
        values = Ex;
        
        % Convert Dx to c to satisfy conditions
        c = Ex - 1;
        
        % Generate results
        if all(Ex(:) <= 1)
            fail = false;
        else
            fail = true;
        end
    end % calcEx

    function [fail, values, c] = calcCy(MFStruct)
        
        % MF6.1 requirement is that Cy > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        PCY1 = MFStruct.PCY1;
        LCY = MFStruct.LCY;
        
        % EQN 54
        Cy = PCY1.*LCY;
        values = Cy;
        
        % Convert Cx to c to satisfy conditions
        c = -Cy;
        
        % Generate result
        if all(Cy(:) > 0)
            fail = false;
        else
            fail = true;
        end
    end % calcCy

    function [fail, values, c] = calcEy(MFStruct, inputs)
        
        % MF6.1 requirement is that Ey <= 1
        % fmincon requirement is that c <= 0
        
        % NOTE: EQN 57 takes the sign of the calculated SA, for which this is the
        % only use in this equation. To save computational speed, the sub
        % calculation of SAy is ignored, and a one postivie and one negative value
        % are evaluated instead.
        
        % Extract coefficients
        PEY1 = MFStruct.PEY1;
        PEY2 = MFStruct.PEY2;
        PEY3 = MFStruct.PEY3;
        PEY4 = MFStruct.PEY4;
        PEY5 = MFStruct.PEY5;
        LEY = MFStruct.LEY;
        
        % Generate input matrix
        inputs.SAsgn = [-1 1];
        [SAsgn, dFz, IA] = ndgrid(inputs.SAsgn, inputs.dFz, inputs.IA);
        
        % EQN 57
        Ey = (PEY1 + PEY2*dFz)...
            .*(1 + PEY5*(IA.^2) - (PEY3 + PEY4.*IA)...
            .*sign(SAsgn))...
            .*LEY;
        values = Ey;
        
        % Convert Cx to c to satisfy conditions
        c = Ey - 1;
        
        % Generate result
        if all(Ey(:) <= 1)
            fail = false;
        else
            fail = true;
        end
        
    end % calcEy

    function [fail, values, c] = calcBt(MFStruct, inputs)
        
        % MF6.1 requirement is that Bt > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        QBZ1 = MFStruct.QBZ1;
        QBZ2 = MFStruct.QBZ2;
        QBZ3 = MFStruct.QBZ3;
        QBZ4 = MFStruct.QBZ4;
        QBZ5 = MFStruct.QBZ5;
        LKY = MFStruct.LKY;
        LMUY = MFStruct.LMUY;
        
        % Generate input matrix
        [dFz, IA] = ndgrid(inputs.dFz, inputs.IA);
        
        % EQN 84
        Bt = (QBZ1 + QBZ2.*dFz + QBZ3.*(dFz.^2))...
            .*(2 + QBZ4 + QBZ5.*abs(IA))...
            .*(LKY./LMUY);
        values = Bt;
        
        % Convert Cx to c to satisfy conditions
        c = -Bt;
        
        % Generate result
        if all(Bt(:) > 0)
            fail = false;
        else
            fail = true;
        end
        
    end % calcBt

    function [fail, values, c] = calcCt(MFStruct)
        
        % MF6.1 requirement is that Ct > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        QCZ1 = MFStruct.QCZ1;
        
        % EQN 54
        Ct = QCZ1;
        values = Ct;
        
        % Convert Cx to c to satisfy conditions
        c = -Ct;
        
        % Generate result
        if all(Ct(:) > 0)
            fail = false;
        else
            fail = true;
        end
        
    end % calcCt

    function [fail, values, c] = calcEt(MFStruct, inputs)
        
        % MF6.1 requirement is that Et <= 1
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        QHZ1 = MFStruct.QHZ1;
        QHZ2 = MFStruct.QHZ2;
        QHZ3 = MFStruct.QHZ3;
        QHZ4 = MFStruct.QHZ4;
        QEZ1 = MFStruct.QEZ1;
        QEZ2 = MFStruct.QEZ2;
        QEZ3 = MFStruct.QEZ3;
        QEZ4 = MFStruct.QEZ4;
        QEZ5 = MFStruct.QEZ5;
        
        % Generate input matrix
        [dFz, IA, SA] = ndgrid(inputs.dFz, inputs.IA, inputs.SA);
        
        % Generate required sub calcs
        [~, Bt, ~] = calcBt(MFStruct, inputs);
        Bt = repmat(Bt, 1, 1, length(inputs.SA));
        [~, Ct, ~] = calcCt(MFStruct);
        
        % EQN 77
        SHt = QHZ1 + QHZ2.*dFz+(QHZ3 + QHZ4.*dFz).*IA;
        
        % EQN 76
        SAt = SA + SHt;
        
        % EQN 87
        Et = (QEZ1 + QEZ2*dFz + QEZ3.*(dFz.^2))...
            .*(1 + (QEZ4 + QEZ5.*IA).*(2/pi).*(atan(Bt.*Ct.*SAt)));
        values = Et;
        
        % Convert Dx to c to satisfy conditions
        c = Et - 1;
        
        % Generate results
        if all(Et(:) <= 1)
            fail = false;
        else
            fail = true;
        end
    end % calcEt

    function [fail, values, c] = calcGxa(MFStruct, inputs)
        
        % MF6.1 requirement is that Gxa > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        RCX1 = MFStruct.RCX1;
        RHX1 = MFStruct.RHX1;
        
        % Generate input matrix
        [~, ~, ~, SA] = ndgrid(inputs.dFz, inputs.SR, inputs.IA, inputs.SA);
        
        % Generate required sub calcs
        [~, Bxa, ~] = calcBxa(MFStruct, inputs); % [SR, IA]
        [~, Exa, ~] = calcExa(MFStruct, inputs); % [dFz]
        Bxa = reshape(Bxa, 1, 11, 11);
        Bxa = repmat(Bxa, length(inputs.dFz), 1, 1, length(inputs.SA));
        Exa = repmat(Exa', 1, length(inputs.SR), length(inputs.IA), length(inputs.SA));
        
        % EQN 46
        Cxa = RCX1;
        
        % EQN 48
        SHxa = RHX1;
        
        % EQN 44
        SAs = SA + SHxa;
        
        % EQN 43
        Gxa = (cos(Cxa.*atan(Bxa.*SAs - Exa.*(Bxa.*SAs - atan(Bxa.*SAs)))))./(cos(Cxa.*atan(Bxa.*SHxa - Exa.*(Bxa.*SHxa - atan(Bxa.*SHxa)))));
        values = Gxa;
        
        % Convert Dx to c to satisfy conditions
        c = -Gxa;
        
        % Generate results
        if all(Gxa(:) > 0)
            fail = false;
        else
            fail = true;
        end
    end % calcGxa

    function [fail, values, c] = calcBxa(MFStruct, inputs)
        
        % MF6.1 requirement is that Bxa > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        RBX1 = MFStruct.RBX1;
        RBX2 = MFStruct.RBX2;
        RBX3 = MFStruct.RBX3;
        LXAL = MFStruct.LXAL;
        
        % Generate input matrix
        [SR, IA] = ndgrid(inputs.SR, inputs.IA);
        
        % EQN 45
        Bxa = (RBX1 + RBX3.*(IA.^2))...
            .*cos(atan(RBX2.*SR))...
            .*LXAL;
        values = Bxa;
        
        % Convert Dx to c to satisfy conditions
        c = -Bxa;
        
        % Generate results
        if all(Bxa(:) > 0)
            fail = false;
        else
            fail = true;
        end
    end % calcBxa

    function [fail, values, c] = calcExa(MFStruct, inputs)
        
        % MF6.1 requirement is that Bxa <= 1
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        REX1 = MFStruct.REX1;
        REX2 = MFStruct.REX2;
        
        % Generate input matrix
        dFz = inputs.dFz;
        
        % EQN 47
        Exa = REX1 + REX2.*dFz;
        values = Exa;
        
        % Convert Dx to c to satisfy conditions
        c = Exa - 1;
        
        % Generate results
        if all(Exa(:) <= 1)
            fail = false;
        else
            fail = true;
        end
        
    end % calcExa

    function [fail, values, c] = calcGyk(MFStruct, inputs)
        
        % MF6.1 requirement is that Gyk > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        RCY1 = MFStruct.RCY1;
        RHY1 = MFStruct.RHY1;
        RHY2 = MFStruct.RHY2;
        
        % Generate input matrix
        [dFz, SR, ~, ~] = ndgrid(inputs.dFz, inputs.SR, inputs.IA, inputs.SA);
        
        % Generate required sub calcs
        [~, Byk, ~] = calcByk(MFStruct, inputs); % [SA, IA]
        [~, Eyk, ~] = calcEyk(MFStruct, inputs); % [dFz]
        Byk = permute(Byk, [2 1]); % [IA, SA]
        Byk = reshape(Byk, 1, 1, length(inputs.IA), length(inputs.SA));
        Byk = repmat(Byk, length(inputs.dFz), length(inputs.SR), 1, 1);
        Eyk = repmat(Eyk', 1, length(inputs.SR), length(inputs.IA), length(inputs.SA));
        
        % EQN 72
        Cyk = RCY1;
        
        % EQN 74
        SHyk = RHY1 + RHY2.*dFz;
        
        % EQN 70
        SRs = SR + SHyk;
        
        % EQN 69
        Gyk = (cos(Cyk.*atan(Byk.*SRs - Eyk.*(Byk.*SRs - atan(Byk.*SRs)))))...
            ./(cos(Cyk.*atan(Byk.*SHyk - Eyk.*(Byk.*SHyk - atan(Byk.*SHyk)))));
        values = Gyk;
        
        % Convert Dx to c to satisfy conditions
        c = -Gyk;
        
        % Generate results
        if all(Gyk(:) > 0)
            fail = false;
        else
            fail = true;
        end
        
    end % calcGyk

    function [fail, values, c] = calcByk(MFStruct, inputs)
        
        % MF6.1 requirement is that Bxa > 0
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        RBY1 = MFStruct.RBY1;
        RBY2 = MFStruct.RBY2;
        RBY3 = MFStruct.RBY3;
        RBY4 = MFStruct.RBY4;
        LYKA = MFStruct.LYKA;
        
        % Generate input matrix
        [SA, IA] = ndgrid(inputs.SA, inputs.IA);
        
        % EQN 45
        Byk= (RBY1 + RBY4*(IA.^2))...
            .*cos(atan(RBY2...
            .*(SA - RBY3)))...
            .*LYKA;
        values = Byk;
        
        % Convert Dx to c to satisfy conditions
        c = -Byk;
        
        % Generate results
        if all(Byk(:) > 0)
            fail = false;
        else
            fail = true;
        end
    end % calcByk

    function [fail, values, c] = calcEyk(MFStruct, inputs)
        
        % MF6.1 requirement is that Eyk <= 1
        % fmincon requirement is that c <= 0
        
        % Extract coefficients
        REY1 = MFStruct.REY1;
        REY2 = MFStruct.REY2;
        
        % Generate input matrix
        dFz = inputs.dFz;
        
        % EQN 47
        Eyk = REY1 + REY2.*dFz;
        values = Eyk;
        
        % Convert Dx to c to satisfy conditions
        c = Eyk - 1;
        
        % Generate results
        if all(Eyk(:) <= 1)
            fail = false;
        else
            fail = true;
        end
        
    end % calcEyk

end
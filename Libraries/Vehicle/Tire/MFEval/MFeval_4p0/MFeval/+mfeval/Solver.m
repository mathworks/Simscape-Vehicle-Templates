classdef Solver
    %SOLVER Solver for Magic Formula 5.2, 6.1 and 6.2 Tyre Models
    
    methods
        % All the functions available for the user are placed here.
        
        function out = fullSteadyState(obj, tirParams, inputs, useMode)%#codegen
            %FULLSTEADYSTATE Performs a full calculation of the MF model
            %
            % The calculation is split into 3 stages:
            %   1: The inputs are validated and analyzed by calling
            %   obj.parseInputs (public access)
            %
            %   2: The forces and moments are calculated by calling
            %   obj.doForcesAndMoments (private access)
            %
            %   3: Extra calculations like the lateral and longitudinal
            %   stiffness, contact patch length and width, etc by calling
            %   obj.doExtras (private access)
            %
            % Syntax:
            % out = obj.fullSteadyState(tirParams, inputs, useMode)
            %
            % Returns a matrix with all the outputs for mfeval.
            % For more information about the inputs, please refer to
            % mfeval
            %
            % See also: mfeval
            
            % Declare extrinsic functions for C code generation
            coder.extrinsic('warning')
            
            % Solve in steady state mode
            userDynamics = 0;
            
            % Call parseInputs
            [postProInputs, internalParams, modes] = obj.parseInputs(tirParams, inputs, useMode, userDynamics);
            
            % Call doForcesAndMoments
            [forcesAndmoments, varinf] = obj.doForcesAndMoments(tirParams, postProInputs, internalParams, modes);
            
            % Call doExtras
            [Re, omega, rho, Rl, a, b, Cx, Cy, Cz, sigmax, sigmay, instKya] = obj.doExtras(tirParams, postProInputs, forcesAndmoments, varinf);
            
            % Check the sign of the coefficient of friction
            % The calculation of Fy is not affected by the sign of muy
            if(modes.useLimitsCheck)
                if any(varinf.muy < 0)
                    varinf.muy = abs(varinf.muy);
                    warning('MFeval:Results:Muy',['Negative lateral '...
                        'coefficient of friction forced to be positive'])
                end % muy < 0
            end % useLimitsCheck
            
            % Preallocate out variable
            [mrows,~] = size(inputs);
            out = zeros(mrows,30);
            
            % Pack all the outputs
            out(:,1) = real(forcesAndmoments.Fx);
            out(:,2) = real(forcesAndmoments.Fy);
            out(:,3) = real(postProInputs.uFz);
            out(:,4) = real(forcesAndmoments.Mx);
            out(:,5) = real(forcesAndmoments.My);
            out(:,6) = real(forcesAndmoments.Mz);
            out(:,7) = real(postProInputs.ukappaLow);
            out(:,8) = real(postProInputs.ualpha);
            out(:,9) = real(postProInputs.ugamma);
            out(:,10) = real(postProInputs.phit);
            out(:,11) = real(postProInputs.uVcx);
            out(:,12) = real(postProInputs.p);
            out(:,13) = real(Re);
            out(:,14) = real(rho);
            out(:,15) = real(2*a);
            out(:,16) = real(varinf.t);
            out(:,17) = real(varinf.mux);
            out(:,18) = real(varinf.muy);
            out(:,19) = real(omega);
            out(:,20) = real(Rl);
            out(:,21) = real(2*b);
            out(:,22) = real(varinf.Mzr);
            out(:,23) = real(Cx);
            out(:,24) = real(Cy);
            out(:,25) = real(Cz);
            out(:,26) = real(varinf.Kya);
            out(:,27) = real(sigmax);
            out(:,28) = real(sigmay);
            out(:,29) = real(instKya);
            out(:,30) = real(varinf.Kxk);
            
        end % fullSteadyState
        
        function out = fullCPI(obj, tirParams, inputs, userUseMode, userDynamics)%#codegen
            %FULLCPI Performs the calculation of the MF model optimized
            %for the Simulink block with Contact Point Interface (CPI).
            %Less outputs are obtained compared to fullSteadyState
            %
            % The calculation is split into 3 sages:
            %   1: The inputs are validated and analyzed by calling
            %   obj.parseInputs (public access)
            %
            %   2: The forces and moments are calculated by calling
            %   obj.doForcesAndMoments (private access)
            %
            %   3: Extra calculations like the vertical deflection, loaded
            %   radius, etc are calculated by calling obj.doExtras (private
            %   access)
            %
            % Syntax:
            % out = solver.obj(tirParams,inputs,userUseMode,userDynamics)
            %
            % Returns a matrix with the necessary outputs for the Simulink
            % CPI block.
            %
            % Where:
            %   tirParams is a structure with the MF parameters
            %
            %   inputs is an array of 9 elements:
            %   [Fz kappa alpha gamma phit Vx P omega Vsy]
            %
            %   userUseMode is a number with values 1 or 2 to specify if
            %   tuenslip is applied (2) or not (1)
            %
            %   userDynamics is a number between 1 to 3 to specify the
            %   dynamics [steady state (1), linear transients (2) or
            %   nonlinear (3)]
            %
            % See also: mfeval
            
            % Get the right useMode number
            if userUseMode>1
                % Use turn slip
                useMode = 112;
            else
                % Do not use turn slip
                useMode = 111;
            end
            
            % Parse Inputs
            [postProInputs, internalParams, modes] = obj.parseInputs(tirParams, inputs, useMode, userDynamics);
            
            % Call doForcesAndMoments
            [forcesAndmoments, varinf] = obj.doForcesAndMoments(tirParams, postProInputs, internalParams, modes);
            
            % Call doExtras
            [~, ~, rho, Rl, ~, ~, ~, ~, ~, ~, ~] = obj.doExtras(tirParams, postProInputs, forcesAndmoments, varinf);
            
            % Preallocate OUTPUT variable
            [mrows,~] = size(inputs);
            out = zeros(mrows,11);
            
            % Pack all the outputs
            out(:,1) = forcesAndmoments.Fx;
            out(:,2) = forcesAndmoments.Fy;
            out(:,3) = forcesAndmoments.Fz;
            out(:,4) = forcesAndmoments.Mx;
            out(:,5) = forcesAndmoments.My;
            out(:,6) = forcesAndmoments.Mz;
            out(:,7) = rho;
            out(:,8) = Rl;
            out(:,9) = varinf.t;
            out(:,10) = varinf.mux;
            out(:,11) = varinf.muy;
            
        end % fullCPI
        
        function [postProInputs, internalParams, modes] = parseInputs(obj, tirParams, inputs, useMode, userDynamics)%#codegen
            %PARSEINPUTS Applies certain limits on the inputs depending on
            %useMode and userDynamics to create necessary variables for
            %obj.fullSteadyState and obj.fullCPI
            %
            % Syntax:
            % [postProInputs, internalParams, modes] =
            % parseInputs(tirParams,inputs, useMode, userDynamics)
            %
            % Where:
            % postProInputs is a structure with the original and
            % post-processed inputs
            %
            % internalParams is a structure that contains parameters not
            % defined in the TIR file with default values from the
            % literature and internal variables for the low speed and
            % turn slip modes.
            %
            % modes is a structure with logical variables that depend on
            % the useMode number.
            %
            % See also: mfeval
            
            % Declare extrinsic functions
            coder.extrinsic('warning')
            
            assert(isstruct(tirParams), ...
                'Solver:tirParams:NotValid', ['tirParams must be a' ...
                'structure containing all the parameters of the MF model']);
            
            assert(isnumeric(inputs) && isreal(inputs), ...
                'Solver:Inputs:NotValid', 'inputs must be numeric and real');
            
            assert(isnumeric(useMode) && isreal(useMode), ...
                'Solver:useMode:NotValid', 'useMode must be numeric and real');
            
            % Check the number of digits of useMode
            numdigits_useMode = max(ceil(log10(abs(useMode))),1);
            
            assert(numdigits_useMode==3, 'Solver:UseMode:Format','useMode should contain exactly 3 digits')
            
            % Save the elements into separate variables
            hundreds = floor(useMode/100);
            tens = floor((useMode-hundreds*100)/10);
            units = floor((useMode-hundreds*100-tens*10));
            
            % Pre-allocate variables for C code generation
            useTurnSlip = false; %#ok<NASGU>
            
            % Create the logical variables
            switch hundreds
                case 1
                    % 1: include limits checks
                    useLimitsCheck = true;
                case 2
                    % 2: revoke limits checks
                    useLimitsCheck = false;
                otherwise
                    error('Solver:UseMode:HundredsNotValid','useMode not contemplated')
            end % useLimitsCheck
            
            switch tens
                case 1
                    % 1: revoke alpha_star definition
                    useAlphaStar = false;
                case 2
                    % 2: include alpha_star definition
                    useAlphaStar = true;
                otherwise
                    error('Solver:UseMode:TensNotValid','useMode not contemplated')
            end % useAlphaStar
            
            switch units
                case 1
                    % 1: combined force/moment calculation
                    useTurnSlip = false;
                case 2
                    % 2: combined force/moment calculation + turn slip
                    useTurnSlip = true;
                otherwise
                    error('Solver:UseMode:UnitsNotValid','useMode not contemplated')
            end % useAlphaStar
            
            % Parameters not specified in the TIR file
            % Used to avoid low speed singularity
            epsilon  = 1e-6; % [Eqn (4.E6a) Page 178 - Book]
            epsilonv = epsilon;
            epsilonx = epsilon;
            epsilonk = epsilon;
            epsilony = epsilon;
            epsilonr = epsilon;
            
            % Check the size of the inputs
            [mrows,ncolumns] = size(inputs);
            
            % Flag an error if the number of inputs is incorrect
            if userDynamics == 0
                assert((ncolumns >= 6) && (ncolumns <= 8), ...
                    'Solver:Inputs:NotValid', 'inputs should be an array between 6 to 8 columns');
            end % if Dynamics is zero (MATLAB)
            
            % Unpack the input matrix into separate input variables
            Fz       = inputs(:,1); % vertical load            (N)
            kappa    = inputs(:,2); % longitudinal slip        (-) (-1 = locked wheel)
            alpha    = inputs(:,3); % side slip angle          (radians)
            gamma    = inputs(:,4); % inclination angle        (radians)
            phit     = inputs(:,5); % turn slip                (1/m)
            Vcx      = inputs(:,6); % forward velocity         (m/s)
            
            % IMPORTANT NOTE: Vx = Vcx [Eqn (7.4) Page 331 - Book]
            % It is assumed that the difference between the wheel centre
            % longitudinal velocity Vx and the longitudinal velocity Vcx of
            % the contact centre is negligible
            
            % If any Fz is negative set it to zero
            Fz(Fz<0) = 0;
            
            % Create a copy of the variables (u stands for unlimited)
            uFz = Fz;
            ukappa = kappa;
            ukappaLow = kappa;
            ualpha = alpha;
            ugamma = gamma;
            uphit = phit;
            uVcx = Vcx;
            
            % If the pressure is specified by the user, grab it
            if ncolumns > 6 && sum(inputs(:, 7)) ~= 0
                p = inputs(:,7); % pressure (Pa)
            else % If is not, use the Inflation pressure of the TIR file
                p = ones(mrows,1).*tirParams.INFLPRES; % pressure (Pa)
            end % if pressure
            
            % Limits:
            % This section applies the appropriate limits to the input
            % values of the model based on the MF limits specified in
            % the TIR File
            
            % Fz_lowLimit is only used in some Moments equations
            % Pre-declare the variable for C code generation
            Fz_lowLimit = Fz;
            
            if useLimitsCheck
                % Turn slip modifications
                phit = phit.*cos(alpha); % Empirically discovered
                
                % Minimum Speed
                VXLOW = tirParams.VXLOW;
                
                % Inflation Pressure Range
                PRESMIN = tirParams.PRESMIN;
                PRESMAX = tirParams.PRESMAX;
                
                % Vertical Force Range
                FZMIN = tirParams.FZMIN;
                FZMAX = tirParams.FZMAX;
                
                % Slip Angle Range
                ALPMIN = tirParams.ALPMIN;
                ALPMAX = tirParams.ALPMAX;
                
                % Inclination Angle Range
                CAMMIN = tirParams.CAMMIN;
                CAMMAX = tirParams.CAMMAX;
                
                % Long Slip Range
                KPUMIN = tirParams.KPUMIN;
                KPUMAX = tirParams.KPUMAX;
                
                % Low Speed Model:
                % Create a reduction factor for low speed and standstill
                
                % Logic to flag if the speed it's below the limit
                isLowSpeed = abs(Vcx) <= VXLOW;
                
                % Create a vector with numbers between 0 and 1 to apply a
                % reduction factor with smooth transitions.
                Wvlow = 0.5.*(1+cos(pi().*(Vcx(isLowSpeed)./VXLOW)));
                reductionSmooth = 1-Wvlow;
                
                % Create a vector with numbers between 0 and 1 to apply a
                % linear reduction toward zero
                reductionLinear = abs(Vcx(isLowSpeed)/VXLOW);
                
                % Create a vector with numbers between 0 and 1 to apply a
                % reduction factor using a sharp decrease toward zero but
                % smooth transition toward VXLOW
                reductionSharp = sin(reductionLinear.*(pi/2));
                
                % ukappaLow is equal to ukappa but with low speed
                % correction. This is only used to export kappa
                ukappaLow(isLowSpeed) = real(ukappaLow(isLowSpeed).*reductionLinear);
                
                % If Vcx is close to zero, use linear reduction
                phit(isLowSpeed) = phit(isLowSpeed).*reductionLinear;
                
                if userDynamics == 0
                    % Calculate the lateral speed if userDynamics is zero
                    % (called from MATLAB)
                    Vsy = tan(alpha).*Vcx;
                else
                    % Dynamics is 1 or 3 (called from Simulink)
                    % Grab Vsy from inputs to avoid Vsy = 0 when Vx = 0
                    Vsy = inputs(:,9);
                end % Vsy calculation
                
                % If the speed is negative, the turn slip is also negative
                isNegativeSpeed = Vcx<0;
                phit(isNegativeSpeed) = -phit(isNegativeSpeed);
                
                % Sum the forward and lateral speeds
                speedSum = abs(Vcx) + abs(Vsy);
                
                % The slip angle also suffers a reduction when the sum of
                % Vx and Vy is less than VXLOW
                isLowSpeedAlpha = speedSum < VXLOW;
                
                % Create a vector with numbers between 0 and 1 to apply a
                % linear reduction toward zero for alpha
                reductionLinear_alpha = speedSum(isLowSpeedAlpha)/VXLOW;
                
                if userDynamics == 0
                    % Solve only when is mfeval from MATLAB
                    kappa(isLowSpeed) = kappa(isLowSpeed).*reductionLinear;
                end % if userDynamics == 0
                
                if userDynamics <= 1
                    % Solve for steady state (both MATLAB and Simulink)
                    % If Vcx is close to zero then SA is also 0, linear
                    % reduction
                    alpha(isLowSpeedAlpha) = alpha(isLowSpeedAlpha).*reductionLinear_alpha;
                end % if steady state
                
                % Check Slip Angle limits
                isLowSlip = alpha < ALPMIN;
                alpha(isLowSlip) = real(ALPMIN);
                
                isHighSlip = alpha > ALPMAX;
                alpha(isHighSlip) = real(ALPMAX);
                
                % Check camber limits
                isLowCamber = gamma < CAMMIN;
                gamma(isLowCamber) = real(CAMMIN);
                
                isHighCamber = gamma > CAMMAX;
                gamma(isHighCamber) = real(CAMMAX);
                
                % Check Fz limits
                isHighLoad = Fz > FZMAX;
                Fz(isHighLoad) = real(FZMAX);
                
                % Create a copy of Fz and apply the low limit.
                % This is only used in some Moments equations
                Fz_lowLimit = Fz;
                isLowLoad = Fz < FZMIN;
                Fz_lowLimit(isLowLoad) = real(FZMIN);
                
                % Check pressure limits
                isLowPressure = p < PRESMIN;
                p(isLowPressure) = real(PRESMIN);
                
                isHighPressure = p > PRESMAX;
                p(isHighPressure) = real(PRESMAX);
                
                % Check slip ratio limits
                isLowSlipR = kappa < KPUMIN;
                kappa(isLowSlipR) = real(KPUMIN);
                
                isHighSlipR = kappa > KPUMAX;
                kappa(isHighSlipR) = real(KPUMAX);
                
                % Flag if anything is out of range.
                if any(isLowSlip)
                    warning ('Solver:Limits:Exceeded',['Slip angle below ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isHighSlip)
                    warning ('Solver:Limits:Exceeded',['Slip angle above ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isLowCamber)
                    warning ('Solver:Limits:Exceeded',['Inclination angle below ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isHighCamber)
                    warning ('Solver:Limits:Exceeded',['Inclination angle above ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isLowLoad)
                    warning ('Solver:Limits:Exceeded',['Vertical load below ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isHighLoad)
                    warning ('Solver:Limits:Exceeded',['Vertical load above ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isLowPressure)
                    warning ('Solver:Limits:Exceeded',['Pressure below ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isHighPressure)
                    warning ('Solver:Limits:Exceeded',['Pressure above ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isLowSlipR)
                    warning ('Solver:Limits:Exceeded',['Slip ratio below ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isHighSlipR)
                    warning ('Solver:Limits:Exceeded',['Slip ratio above ',...
                        'the limit. Values have been saturated.']);
                end
                
                if any(isLowSpeed)
                    warning('Solver:Limits:Exceeded',['Speed input VX below ',...
                        'the limit. Low speed mode activated.']);
                end
                
            else
                % Not using limits checks
                isLowSpeed = false(length(Fz),1);
                reductionSmooth = ones(length(Fz),1);
                reductionSharp = ones(length(Fz),1);
                reductionLinear = ones(length(Fz),1);
                isLowSpeedAlpha = false(length(Fz),1);
                reductionLinear_alpha = ones(length(Fz),1);
            end % if useLimitsCheck
            
            % Pack the outputs
            modes.useLimitsCheck = useLimitsCheck;
            modes.useAlphaStar = useAlphaStar;
            modes.useTurnSlip = useTurnSlip;
            modes.isLowSpeed = isLowSpeed;
            modes.isLowSpeedAlpha = isLowSpeedAlpha;
            modes.userDynamics = userDynamics;
            
            internalParams.epsilonx = epsilonx;
            internalParams.epsilonk = epsilonk;
            internalParams.epsilony = epsilony;
            internalParams.epsilonr = epsilonr;
            internalParams.epsilonv = epsilonv;
            internalParams.reductionSmooth = reductionSmooth;
            internalParams.reductionSharp = reductionSharp;
            internalParams.reductionLinear = reductionLinear;
            internalParams.reductionLinear_alpha = reductionLinear_alpha;
            
            % Set optional inputs to zero (needed for C code generation)
            internalParams.zeta2 = ones(size(Fz));
            internalParams.epsilong = 0;
            
            postProInputs.alpha = alpha;
            postProInputs.kappa = kappa;
            postProInputs.gamma = gamma;
            postProInputs.phit = phit;
            postProInputs.Fz = Fz;
            postProInputs.p = p;
            
            % Set optional inputs to zero (needed for C code generation)
            postProInputs.omega = zeros(size(Fz));
            postProInputs.phi = zeros(size(Fz));
            postProInputs.Vsx = zeros(size(Fz));
            
            % Zero speed (empirically discovered)
            ualpha(uVcx == 0) = 0;
            
            postProInputs.uFz = uFz;
            postProInputs.ukappa = ukappa;
            postProInputs.ukappaLow = ukappaLow;
            postProInputs.ualpha = ualpha;
            postProInputs.ugamma = ugamma;
            postProInputs.uphit = uphit;
            postProInputs.uVcx = uVcx;
            postProInputs.nInputs = ncolumns;
            postProInputs.Fz_lowLimit = Fz_lowLimit;
            
            dpi = (p - tirParams.NOMPRES)./tirParams.NOMPRES; % [Eqn (4.E2b) Page 177 - Book]
            
            % Check if omega is one input
            if ncolumns > 7 && sum(inputs(:, 8)) ~= 0
                % Grab omega if exists
                omega = inputs(:,8);
            else
                % If omega is NOT one of the inputs: Estimate omega
                [~, ~, omega] = obj.calculateRe(tirParams, postProInputs, dpi);
            end % if omega
            
            % Save omega
            postProInputs.omega = omega;
            [Re, ~, ~] = obj.calculateRe(tirParams, postProInputs, dpi);
            
            % Longitudinal slip velocity
            Vsx = Vcx - Re.*omega; % [Eqn (2.3) Page 64 - Book]
            postProInputs.Vsx = Vsx;
            
            if useTurnSlip
                PECP1 = tirParams.PECP1;
                PECP2 = tirParams.PECP2;
                LFZO  = tirParams.LFZO;
                Fz0   = tirParams.FNOMIN;
                
                Fz0_prime =  LFZO.*Fz0; % [Eqn (4.E1) Page 177 - Book]
                dfz = (Fz - Fz0_prime)./Fz0_prime; % [Eqn (4.E2a) Page 177 - Book]
                
                Vsy = -tan(alpha).*abs(Vcx);
                V = sqrt(Vcx.^2 +Vsy.^2);
                
                epsilong = PECP1.*(1 + PECP2.*dfz); % [Eqn (4.90) Page 186 - Book] Camber reduction factor
                
                % Speed limits (avoid zero speed)
                %Vc_prime = Vcx; % From the book
                Vc_prime = V; % From the Equation Manual
                
                isLowSpeed = abs(Vcx) < tirParams.VXLOW;
                signVcx = sign(Vcx(isLowSpeed));
                signVcx(signVcx == 0) = 1;
                Vc_prime(isLowSpeed) = real(tirParams.VXLOW * signVcx); % Singularity protected velocity, text on Page 184
                
                psi_dot = -phit.*Vc_prime; % Rearrange [Eqn (4.75) Page 183 - Book]
                
                phi = (1./Vc_prime).*(psi_dot-(1-epsilong).*omega.*sin(gamma)); % [Eqn (4.76) Page 184 - Book]
                
                % IMPORTANT NOTE: Eqn (4.76) has been modified
                % In chapter 2.2 "Definition of tire input quantities" in the Pacejka
                % book, it is assumed that the z-axis of the road coordinate system
                % "points downward normal to the road plane" (p. 62). Due to this
                % definition, Pacejka introduces the minus sign for the spin slip so
                % that a positive spin leads to a positive torque Mz (p. 68).But in
                % CarMaker (and other MBS software), the road coordinate system is
                % orientated differently. The z-axis points upward to the
                % road plane. Thus switching the signs is not needed here.
                
                internalParams.epsilong = epsilong;
                postProInputs.phi = real(phi);
            end % if turnslip
            
        end % parseInputs
        
    end % Public methods
    
    methods (Hidden)
        % This methods are public but they are hidden for the normal user
        
        function [starVar, primeVar, incrVar, slipVel] = calculateBasic(~, tirParams, modes, internalParams, postProInputs)%#codegen
            
            % Unpack Parameters
            V0 = tirParams.LONGVL; %Nominal speed
            pi0	= tirParams.NOMPRES; %Nominal tyre inflation pressure
            Fz0	= tirParams.FNOMIN; %Nominal wheel load
            LFZO = tirParams.LFZO; % Scale factor of nominal (rated) load
            LMUX = tirParams.LMUX; % Scale factor of Fx peak friction coefficient
            LMUY = tirParams.LMUY; % Scale factor of Fy peak friction coefficient
            
            % New scaling factor in Pacejka 2012 with it's default value.
            % This scaling factor is not present in the standard MF6.1 TIR
            % files.
            LMUV = 0; % Scale factor with slip speed Vs decaying friction
            
            Fz = postProInputs.Fz;
            kappa = postProInputs.kappa;
            alpha = postProInputs.alpha;
            gamma = postProInputs.gamma;
            Vcx = postProInputs.uVcx;
            p = postProInputs.p;
            
            epsilonv = internalParams.epsilonv;
            useAlphaStar = modes.useAlphaStar;
            
            % Some basic calculations are done before calculating forces
            % and moments
            
            % Velocities in point S (slip point)
            Vsx = -kappa.*abs(Vcx); % [Eqn (4.E5) Page 181 - Book]
            Vsy = tan(alpha).*abs(Vcx); % [Eqn (2.12) Page 67 - Book] and [(4.E3) Page 177 - Book]
            % Important Note:
            % Due to the ISO sign convention, equation 2.12 does not need a
            % negative sign. The Pacejka book is written in adapted SAE.
            Vs = sqrt(Vsx.^2+Vsy.^2); % [Eqn (3.39) Page 102 - Book] -> Slip velocity of the slip point S
            
            % Velocities in point C (contact)
            Vcy = Vsy; % Assumption from page 67 of the book, paragraph above Eqn (2.11)
            Vc = sqrt(Vcx.^2+Vcy.^2); % Velocity of the wheel contact centre C, Not described in the book but is the same as [Eqn (3.39) Page 102 - Book]
            
            % Effect of having a tire with a different nominal load
            Fz0_prime =  LFZO.*Fz0; % [Eqn (4.E1) Page 177 - Book]
            
            % Normalized change in vertical load
            dfz = (Fz - Fz0_prime)./Fz0_prime; % [Eqn (4.E2a) Page 177 - Book]
            
            % Normalized change in inflation pressure
            dpi = (p - pi0)./pi0; % [Eqn (4.E2b) Page 177 - Book]
            
            % Use of star (*) definition. Only valid for the book
            % implementation. TNO MF-Tyre does not use this.
            if useAlphaStar
                alpha_star = tan(alpha).*sign(Vcx); % [Eqn (4.E3) Page 177 - Book]
                gamma_star = sin(gamma); % [Eqn (4.E4) Page 177 - Book]
            else
                alpha_star = alpha;
                gamma_star = gamma;
            end % if useAlphaStar
            
            % For the aligning torque at high slip angles
            signVc = sign(Vc);
            signVc(signVc==0) = 1;
            Vc_prime = Vc + epsilonv.*signVc; % [Eqn (4.E6a) Page 178 - Book] [sign(Vc) term explained on page 177]
            
            alpha_prime = acos(Vcx./Vc_prime); % [Eqn (4.E6) Page 177 - Book]
            
            % Slippery surface with friction decaying with increasing (slip) speed
            LMUX_star = LMUX./(1 + LMUV.*Vs./V0); % [Eqn (4.E7) Page 179 - Book]
            LMUY_star = LMUY./(1 + LMUV.*Vs./V0); % [Eqn (4.E7) Page 179 - Book]
            
            % Digressive friction factor
            % On Page 179 of the book is suggested Amu = 10, but after
            % comparing the use of the scaling factors against TNO, Amu = 1
            % was giving perfect match
            Amu = 1;
            LMUX_prime = Amu.*LMUX_star./(1+(Amu-1).*LMUX_star); % [Eqn (4.E8) Page 179 - Book]
            LMUY_prime = Amu.*LMUY_star./(1+(Amu-1).*LMUY_star); % [Eqn (4.E8) Page 179 - Book]
            
            % Pack outputs
            starVar.alpha_star = alpha_star;
            starVar.gamma_star = gamma_star;
            starVar.LMUX_star = LMUX_star;
            starVar.LMUY_star = LMUY_star;
            starVar.gamma_star = gamma_star;
            
            primeVar.Fz0_prime = Fz0_prime;
            primeVar.alpha_prime = alpha_prime;
            primeVar.LMUX_prime = LMUX_prime;
            primeVar.LMUY_prime = LMUY_prime;
            
            incrVar.dfz = dfz;
            incrVar.dpi = dpi;
            
            slipVel.Vsx = Vsx;
            slipVel.Vsy = Vsy;
            
        end % calculateBasic
        
        function [Fx0, mux, Kxk] = calculateFx0(~, tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar)%#codegen
            
            % Declare extrinsic functions
            coder.extrinsic('warning')
            
            %[SCALING_COEFFICIENTS]
            LCX 	= tirParams.LCX ; % Scale factor of Fx shape factor
            LEX  	= tirParams.LEX ; % Scale factor of Fx curvature factor
            LKX  	= tirParams.LKX ; % Scale factor of Fx slip stiffness
            LHX  	= tirParams.LHX ; % Scale factor of Fx horizontal shift
            LVX  	= tirParams.LVX ; % Scale factor of Fx vertical shift
            
            %[LONGITUDINAL_COEFFICIENTS]
            PCX1  	=  tirParams.PCX1 ; %Shape factor Cfx for longitudinal force
            PDX1  	=  tirParams.PDX1 ; %Longitudinal friction Mux at Fznom
            PDX2  	=  tirParams.PDX2 ; %Variation of friction Mux with load
            PDX3  	=  tirParams.PDX3 ; %Variation of friction Mux with camber squared
            PEX1  	=  tirParams.PEX1 ; %Longitudinal curvature Efx at Fznom
            PEX2  	=  tirParams.PEX2 ; %Variation of curvature Efx with load
            PEX3  	=  tirParams.PEX3 ; %Variation of curvature Efx with load squared
            PEX4  	=  tirParams.PEX4 ; %Factor in curvature Efx while driving
            PKX1  	=  tirParams.PKX1 ; %Longitudinal slip stiffness Kfx./Fz at Fznom
            PKX2  	=  tirParams.PKX2 ; %Variation of slip stiffness Kfx./Fz with load
            PKX3  	=  tirParams.PKX3 ; %Exponent in slip stiffness Kfx./Fz with load
            PHX1  	=  tirParams.PHX1 ; %Horizontal shift Shx at Fznom
            PHX2  	=  tirParams.PHX2 ; %Variation of shift Shx with load
            PVX1  	=  tirParams.PVX1 ; %Vertical shift Svx./Fz at Fznom
            PVX2  	=  tirParams.PVX2 ; %Variation of shift Svx./Fz with load
            PPX1  	=  tirParams.PPX1 ; %linear influence of inflation pressure on longitudinal slip stiffness
            PPX2  	=  tirParams.PPX2 ; %quadratic influence of inflation pressure on longitudinal slip stiffness
            PPX3  	=  tirParams.PPX3 ; %linear influence of inflation pressure on peak longitudinal friction
            PPX4  	=  tirParams.PPX4 ; %quadratic influence of inflation pressure on peak longitudinal friction
            
            % Unpack Parameters
            epsilonx = internalParams.epsilonx;
            
            dfz = incrVar.dfz;
            dpi = incrVar.dpi;
            
            LMUX_star = starVar.LMUX_star;
            LMUX_prime = primeVar.LMUX_prime;
            
            Fz = postProInputs.Fz;
            kappa = postProInputs.kappa;
            gamma  = postProInputs.gamma;
            Vx   = postProInputs.uVcx;
            
            useLimitsCheck = modes.useLimitsCheck;
            useTurnSlip = modes.useTurnSlip;
            userDynamics = modes.userDynamics;
            isLowSpeed = modes.isLowSpeed;
            
            % Turn slip
            if useTurnSlip
                PDXP1   = tirParams.PDXP1;
                PDXP2   = tirParams.PDXP2;
                PDXP3   = tirParams.PDXP3;
                R0      = tirParams.UNLOADED_RADIUS;
                phi     = postProInputs.phi;
                
                Bxp = PDXP1.*(1 + PDXP2.*dfz).*cos(atan(PDXP3.*kappa)); % [Eqn (4.106) Page 188 - Book]
                zeta1 = cos(atan(Bxp.*R0.*phi)); % [Eqn (4.105) Page 188 - Book]
            else
                zeta1 = ones(size(Fz));
            end % if useTurnSlip
            
            Cx = PCX1.*LCX; % (> 0) (4.E11)
            mux = (PDX1 + PDX2.*dfz).*(1 + PPX3.*dpi + PPX4.*dpi.^2).*(1 - PDX3.*gamma.^2).*LMUX_star; % (4.E13)
            mux(Fz==0) = 0; % Zero Fz correction
            Dx = mux.*Fz.*zeta1; % (> 0) (4.E12)
            Kxk = Fz.*(PKX1 + PKX2.*dfz).*exp(PKX3.*dfz).*(1 + PPX1.*dpi + PPX2.*dpi.^2).*LKX;  % (= BxCxDx = dFxo./dkx at kappax = 0) (= Cfk) (4.E15)
            
            signDx = sign(Dx);
            signDx(signDx == 0) = 1; % If [Dx = 0] then [sign(0) = 0]. This is done to avoid [Kxk / 0 = NaN] in Eqn 4.E16
            
            Bx = Kxk./(Cx.*Dx + epsilonx.*signDx); % (4.E16) [sign(Dx) term explained on page 177]
            SHx = (PHX1 + PHX2.*dfz).*LHX; % (4.E17)
            SVx = Fz.*(PVX1 + PVX2.*dfz).*LVX.*LMUX_prime.*zeta1; % (4.E18)
            
            % Low speed model
            if any(isLowSpeed)
                SVx(isLowSpeed) = SVx(isLowSpeed).*internalParams.reductionSmooth;
                SHx(isLowSpeed) = SHx(isLowSpeed).*internalParams.reductionSmooth;
            end % if isLowSpeed
            
            kappax = kappa + SHx; % (4.E10)
            
            % Only in Linear Transients mode
            if userDynamics == 2
                kappax(Vx < 0) = -kappax(Vx < 0);
            end % if linear transients
            
            Ex = (PEX1 + PEX2.*dfz + PEX3.*dfz.^2).*(1 - PEX4.*sign(kappax)).*LEX; % (<=1) (4.E14)
            
            % Limits check
            if(useLimitsCheck)
                if(any(Ex > 1))
                    warning('Solver:CoeffChecks:Ex','Ex over limit (>1), Eqn(4.E14)')
                    Ex(Ex > 1) = 1;
                end % if Ex > 1
            end % if useLimitsCheck
            
            % Pure longitudinal force
            Fx0 = Dx.*sin(Cx.*atan(Bx.*kappax-Ex.*(Bx.*kappax-atan(Bx.*kappax))))+SVx; % (4.E9)
            
            %if any(isLowSpeed) && (userDynamics==2)
            %    % Low speed model and Linear Transients
            %    Fx0(isLowSpeed) = Dx.*(1-internalParams.reductionSmooth)*sign(kappax)+ Fx0.*internalParams.reductionSmooth;
            %end % if linear transients and low speed
            
            % Backward speed check
            if userDynamics~=3
                Fx0(Vx < 0) = -Fx0(Vx < 0);
            end % if is not Nonlinear Transients
            
        end % calculateFx0
        
        function [Fy0, muy, Kya, Kyg0, SHy, SVy, By, Cy, internalParams] = calculateFy0(~, tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar)%#codegen
            
            % Declare extrinsic functions
            coder.extrinsic('warning')
            
            % Unpack Parameters
            epsilonk = internalParams.epsilonk;
            epsilony = internalParams.epsilony;
            
            dfz = incrVar.dfz;
            dpi = incrVar.dpi;
            
            LMUY_star = starVar.LMUY_star;
            alpha_star = starVar.alpha_star;
            gamma_star = starVar.gamma_star;
            
            LMUY_prime = primeVar.LMUY_prime;
            Fz0_prime = primeVar.Fz0_prime;
            
            Fz = postProInputs.Fz;
            Vcx   = postProInputs.uVcx;
            
            useLimitsCheck = modes.useLimitsCheck;
            useAlphaStar = modes.useAlphaStar;
            useTurnSlip = modes.useTurnSlip;
            
            %[SCALING_COEFFICIENTS]
            LCY   = tirParams.LCY   ; % Scale factor of Fy shape factor
            LEY   = tirParams.LEY   ; % Scale factor of Fy curvature factor
            LKY   = tirParams.LKY   ; % Scale factor of Fy cornering stiffness
            LHY   = tirParams.LHY   ; % Scale factor of Fy horizontal shift
            LVY   = tirParams.LVY   ; % Scale factor of Fy vertical shift
            LKYC  = tirParams.LKYC  ; % Scale factor of camber force stiffness
            
            %[LATERAL_COEFFICIENTS]
            PCY1  =  tirParams.PCY1 	; %Shape factor Cfy for lateral forces
            PDY1  =  tirParams.PDY1 	; %Lateral friction Muy
            PDY2  =  tirParams.PDY2 	; %Variation of friction Muy with load
            PDY3  =  tirParams.PDY3 	; %Variation of friction Muy with squared camber
            PEY1  =  tirParams.PEY1 	; %Lateral curvature Efy at Fznom
            PEY2  =  tirParams.PEY2 	; %Variation of curvature Efy with load
            PEY3  =  tirParams.PEY3 	; %Zero order camber dependency of curvature Efy
            PEY4  =  tirParams.PEY4 	; %Variation of curvature Efy with camber
            PEY5  =  tirParams.PEY5 	; %Variation of curvature Efy with camber squared
            PKY1  =  tirParams.PKY1 	; %Maximum value of stiffness Kfy./Fznom
            PKY2  =  tirParams.PKY2 	; %Load at which Kfy reaches maximum value
            PKY3  =  tirParams.PKY3 	; %Variation of Kfy./Fznom with camber
            PKY4  =  tirParams.PKY4 	; %Curvature of stiffness Kfy
            PKY5  =  tirParams.PKY5 	; %Peak stiffness variation with camber squared
            PKY6  =  tirParams.PKY6 	; %Fy camber stiffness factor
            PKY7  =  tirParams.PKY7 	; %Vertical load dependency of camber stiffness
            PHY1  =  tirParams.PHY1 	; %Horizontal shift Shy at Fznom
            PHY2  =  tirParams.PHY2 	; %Variation of shift Shy with load
            PVY1  =  tirParams.PVY1 	; %Vertical shift in Svy./Fz at Fznom
            PVY2  =  tirParams.PVY2 	; %Variation of shift Svy./Fz with load
            PVY3  =  tirParams.PVY3 	; %Variation of shift Svy./Fz with camber
            PVY4  =  tirParams.PVY4 	; %Variation of shift Svy./Fz with camber and load
            PPY1  =  tirParams.PPY1 	; %influence of inflation pressure on cornering stiffness
            PPY2  =  tirParams.PPY2 	; %influence of inflation pressure on dependency of nominal tyre load on cornering stiffness
            PPY3  =  tirParams.PPY3 	; %linear influence of inflation pressure on lateral peak friction
            PPY4  =  tirParams.PPY4 	; %quadratic influence of inflation pressure on lateral peak friction
            PPY5  =  tirParams.PPY5 	; %Influence of inflation pressure on camber stiffness
            
            % Pre-allocate MF5.2 parameters for C code generation
            PHY3  =  0 	; %Variation of shift Shy with camber
            
            % Turn slip
            if useTurnSlip
                %[TURNSLIP_COEFFICIENTS]
                PKYP1 = tirParams.PKYP1 ; %Cornering stiffness reduction due to spin
                PDYP1 = tirParams.PDYP1 ; %Peak Fy reduction due to spin parameter
                PDYP2 = tirParams.PDYP2 ; %Peak Fy reduction due to spin with varying load parameter
                PDYP3 = tirParams.PDYP3 ; %Peak Fy reduction due to spin with alpha parameter
                PDYP4 = tirParams.PDYP4 ; %Peak Fy reduction due to square root of spin parameter
                
                %[DIMENSION]
                R0   = tirParams.UNLOADED_RADIUS ; %Free tyre radius
                
                % Inputs
                alpha = postProInputs.alpha;
                phi = postProInputs.phi;
                
                zeta3 = cos(atan(PKYP1.*R0.^2.*phi.^2)); % [Eqn (4.79) Page 185 - Book]
                
                Byp = PDYP1.*(1 + PDYP2.*dfz).*cos(atan(PDYP3.*tan(alpha))); % [Eqn (4.78) Page 185 - Book]
                
                zeta2 = cos(atan(Byp.*(R0.*abs(phi)+ PDYP4.*sqrt(R0.*abs(phi))))); % [Eqn (4.77) Page 184 - Book]
            else
                % No turn slip and small camber angles
                % First paragraph on page 178 of the book
                zeta2 = ones(size(Fz));
                zeta3 = ones(size(Fz));
            end % if useTurnSlip calculate zeta2 and zeta3
            
            % Save zeta2 for Mz calculations
            internalParams.zeta2 = real(zeta2);
            
            Kya = PKY1.*Fz0_prime.*(1 + PPY1.*dpi).*(1 - PKY3.*abs(gamma_star)).*sin(PKY4.*atan((Fz./Fz0_prime)./((PKY2+PKY5.*gamma_star.^2).*(1+PPY2.*dpi)))).*zeta3.*LKY; % (= ByCyDy = dFyo./dalphay at alphay = 0) (if gamma =0: =Kya0 = CFa) (PKY4=2)(4.E25)
            SVyg = Fz.*(PVY3 + PVY4.*dfz).*gamma_star.* LKYC .* LMUY_prime .* zeta2; % (4.E28)
            
            % Check MF version
            if tirParams.FITTYP == 6
                % Load MF5.2 parameters
                PHY3  =  tirParams.PHY3 	; %Variation of shift Shy with camber
                
                % MF5.2 equations from the MF-Tyre equation manual
                Kya0 = PKY1.*Fz0_prime.*sin(PKY4.*atan(Fz./(PKY2.*Fz0_prime))).*LKYC; % Simplified without pressure dependency
                Kyg0 = (PHY3.*Kya0 + Fz.*(PVY3+PVY4.*dfz)).*LKYC;
            else
                % MF6.1 and 6.2 equatons
                Kyg0 = Fz.*(PKY6 + PKY7 .*dfz).*(1 + PPY5.*dpi).*LKYC; % (=dFyo./dgamma at alpha = gamma = 0) (= CFgamma) (4.E30)
            end
            
            if useTurnSlip
                %[SCALING_COEFFICIENTS]
                LKY  = tirParams.LKY ; % Scale factor of Fy cornering stiffness
                
                %[TURNSLIP_COEFFICIENTS]
                PHYP1  = tirParams.PHYP1; %Fy-alpha curve lateral shift limitation
                PHYP2  = tirParams.PHYP2; %Fy-alpha curve maximum lateral shift parameter
                PHYP3  = tirParams.PHYP3; %Fy-alpha curve maximum lateral shift varying with load parameter
                PHYP4  = tirParams.PHYP4; %Fy-alpha curve maximum lateral shift parameter
                
                %[LATERAL_COEFFICIENTS]
                PKY1 =  tirParams.PKY1; %Maximum value of stiffness Kfy./Fznom
                PKY2 =  tirParams.PKY2; %Load at which Kfy reaches maximum value
                PKY3 =  tirParams.PKY3; %Variation of Kfy./Fznom with camber
                PKY4 =  tirParams.PKY4; %Curvature of stiffness Kfy
                PKY5 =  tirParams.PKY5; %Peak stiffness variation with camber squared
                PPY1 =  tirParams.PPY1; %influence of inflation pressure on cornering stiffness
                PPY2 =  tirParams.PPY2; %influence of inflation pressure on dependency of nominal tyre load on cornering stiffness
                
                %[DIMENSION]
                R0   = tirParams.UNLOADED_RADIUS ; %Free tyre radius
                
                % Inputs
                epsilong = internalParams.epsilong;
                phi = postProInputs.phi;
                
                Kya0 = PKY1.*Fz0_prime.*(1 + PPY1.*dpi).*(1 - PKY3.*abs(0)).*sin(PKY4.*atan((Fz./Fz0_prime)./((PKY2+PKY5.*0.^2).*(1+PPY2.*dpi)))).*zeta3.*LKY;
                
                % IMPORTANT NOTE: Explanation of the above equation, Kya0
                % Kya0 is the cornering stiffness when the camber angle is zero
                % (gamma=0) which is again the product of the coefficients By, Cy and
                % Dy at zero camber angle. Information from Kaustub Ragunathan, email:
                % carmaker-service-uk@ipg-automotive.com
                
                signKya = sign(Kya);
                signKya(signKya == 0) = 1; % If [Kya = 0] then [sign(0) = 0]. This is done to avoid [num / 0 = NaN] in Eqn 4.E39
                
                signKya0 = sign(Kya0);
                signKya0(signKya0 == 0) = 1; % If [Kya0 = 0] then [sign(0) = 0]. This is done to avoid [num / 0 = NaN]
                
                Kya_prime = Kya + epsilonk.*signKya; % (4.E39) [sign(Kya) term explained on page 177]
                Kyao_prime = Kya0 + epsilonk.*signKya0; % epsilonk is a small factor added to avoid the singularity condition during zero velocity (equation 308, CarMaker reference Manual).
                
                
                CHyp = PHYP1; % (>0) [Eqn (4.85) Page 186 - Book]
                DHyp = (PHYP2 + PHYP3.*dfz).*sign(Vcx); % [Eqn (4.86) Page 186 - Book]
                EHyp = PHYP4; % (<=1) [Eqn (4.87) Page 186 - Book]
                
                % Limits check
                if(useLimitsCheck)
                    if EHyp > 1
                        EHyp = 1;
                        warning('Solver:CoeffChecks:EHyp','EHyp over limit (>1), Eqn(4.87)')
                    end % if EHyp > 1
                end % if useLimitsCheck
                
                KyRp0 = Kyg0./(1-epsilong); % Eqn (4.89)
                BHyp = KyRp0./(CHyp.*DHyp.*Kyao_prime); %[Eqn (4.88) Page 186 - Book]
                SHyp = DHyp.*sin(CHyp .* atan(BHyp.*R0.*phi - EHyp.*(BHyp.*R0.*phi - atan(BHyp.*R0.*phi)))).*sign(Vcx); % [Eqn (4.80) Page 185 - Book]
                
                zeta0 = 0; % [Eqn (4.83) Page 186 - Book]
                zeta4 = 1 + SHyp - SVyg./Kya_prime; % [Eqn (4.84) Page 186 - Book]
            else
                % No turn slip and small camber angles
                % First paragraph on page 178 of the book
                zeta0 = 1;
                zeta4 = ones(size(Fz));
            end % if useTurnSlip calculate zeta0 and zeta4
            
            signKya = sign(Kya);
            signKya(signKya == 0) = 1; % If [Kya = 0] then [sign(0) = 0]. This is done to avoid [num / 0 = NaN] in Eqn 4.E27
            
            % Check MF version
            if tirParams.FITTYP == 6
                % MF5.2 equations
                SHy = (PHY1 + PHY2.*dfz).* LHY + PHY3.*gamma_star.*LKYC; % From the MF-Tyre equation manual
            else
                % MF6.1 and 6.2 equatons
                SHy = (PHY1 + PHY2.*dfz).* LHY + ((Kyg0 .*gamma_star - SVyg)./(Kya + epsilonk.*signKya)).*zeta0 +zeta4 -1; % (4.E27) [sign(Kya) term explained on page 177]
            end
            SVy = Fz.*(PVY1 + PVY2.*dfz).*LVY.*LMUY_prime.*zeta2 + SVyg; % (4.E29)
            
            % Low speed model
            isLowSpeed = modes.isLowSpeed;
            if any(isLowSpeed)
                SVy(isLowSpeed) = SVy(isLowSpeed).*internalParams.reductionSmooth;
                SHy(isLowSpeed) = SHy(isLowSpeed).*internalParams.reductionSmooth;
            end % if isLowSpeed
            
            alphay = alpha_star + SHy; % (4.E20)
            Cy = PCY1.*LCY; % (> 0) (4.E21)
            muy = (PDY1 + PDY2 .* dfz).*(1 + PPY3.*dpi + PPY4 .*dpi.^2).*(1 - PDY3.*gamma_star.^2).*LMUY_star; % (4.E23)
            Dy = muy.*Fz.*zeta2; % (4.E22)
            signAlphaY = sign(alphay);
            signAlphaY(signAlphaY == 0) = 1;
            Ey = (PEY1 + PEY2.*dfz).*(1 + PEY5.*gamma_star.^2 - (PEY3 + PEY4.*gamma_star).*signAlphaY).*LEY; % (<=1)(4.E24)
            
            % Limits check
            if(useLimitsCheck)
                if(any(Ey > 1))
                    warning('Solver:CoeffChecks:Ey','Ey over limit (>1), Eqn(4.E24)')
                    Ey(Ey > 1) = 1;
                end % if Ey > 1
            end % if useLimitsCheck
            
            signDy = sign(Dy);
            signDy(signDy == 0) = 1; % If [Dy = 0] then [sign(0) = 0]. This is done to avoid [Kya / 0 = NaN] in Eqn 4.E26
            
            By = Kya./(Cy.*Dy + epsilony.*signDy); % (4.E26) [sign(Dy) term explained on page 177]
            
            Fy0 = Dy .* sin(Cy.*atan(By.*alphay-Ey.*(By.*alphay - atan(By.*alphay))))+ SVy; % (4.E19)
            
            % Backward speed check for alpha_star
            if(useAlphaStar)
                Fy0(Vcx < 0) = -Fy0(Vcx < 0);
            end % if useAlphaStar
            
            %if any(isLowSpeed) && (modes.userDynamics==2)
            %    % Low speed model and Linear Transients
            %    Fy0(isLowSpeed) = Dy.*(1-internalParams.reductionSmooth).*sign(-alphay+eps)+ Fy0.*internalParams.reductionSmooth;
            %end % if linear transients and low speed
            
            % Zero Fz correction
            muy(Fz==0) = 0;
            
        end % calculateFy0
        
        function [Mz0, alphar, alphat, Dr, Cr, Br, Dt, Ct, Bt, Et, Kya_prime] = calculateMz0(obj, tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar, Kya, ~, SHy, SVy, By, Cy)%#codegen
            
            % Declare extrinsic functions
            coder.extrinsic('warning')
            
            % Unpack Parameters
            epsilonk = internalParams.epsilonk;
            dfz = incrVar.dfz;
            dpi = incrVar.dpi;
            LMUY_star = starVar.LMUY_star;
            alpha_star = starVar.alpha_star;
            gamma_star = starVar.gamma_star;
            Fz0_prime = primeVar.Fz0_prime;
            alpha_prime = primeVar.alpha_prime;
            useLimitsCheck = modes.useLimitsCheck;
            useTurnSlip = modes.useTurnSlip;
            gamma  = postProInputs.gamma;
            Vcx   = postProInputs.uVcx;
            
            if useLimitsCheck
                Fz = postProInputs.Fz_lowLimit;
                % Set Fz to zero if the input is negative
                Fz(postProInputs.Fz<=0) = 0;
            else
                Fz = postProInputs.Fz;
            end % if useLimitsCheck
            
            %[DIMENSION]
            R0  = tirParams.UNLOADED_RADIUS; %Free tyre radius
            
            %[SCALING_COEFFICIENTS]
            LKY  = tirParams.LKY ; % Scale factor of Fy cornering stiffness
            LTR  = tirParams.LTR ; % Scale factor of peak of pneumatic trail
            LRES = tirParams.LRES; % Scale factor for offset of residual torque
            LKZC = tirParams.LKZC; % %Scale factor of camber torque stiffness
            
            %[ALIGNING_COEFFICIENTS]
            QBZ1  =  tirParams.QBZ1 	; %Trail slope factor for trail Bpt at Fznom
            QBZ2  =  tirParams.QBZ2 	; %Variation of slope Bpt with load
            QBZ3  =  tirParams.QBZ3 	; %Variation of slope Bpt with load squared
            QBZ4  =  tirParams.QBZ4		; %Variation of slope Bpt with camber
            QBZ5  =  tirParams.QBZ5 	; %Variation of slope Bpt with absolute camber
            QBZ9  =  tirParams.QBZ9 	; %Factor for scaling factors of slope factor Br of Mzr
            QBZ10 =  tirParams.QBZ10	; %Factor for dimensionless cornering stiffness of Br of Mzr
            QCZ1  =  tirParams.QCZ1 	; %Shape factor Cpt for pneumatic trail
            QDZ1  =  tirParams.QDZ1 	; %Peak trail Dpt = Dpt.*(Fz./Fznom.*R0)
            QDZ2  =  tirParams.QDZ2 	; %Variation of peak Dpt" with load
            QDZ3  =  tirParams.QDZ3 	; %Variation of peak Dpt" with camber
            QDZ4  =  tirParams.QDZ4 	; %Variation of peak Dpt" with camber squared
            QDZ6  =  tirParams.QDZ6 	; %Peak residual torque Dmr" = Dmr./(Fz.*R0)
            QDZ7  =  tirParams.QDZ7 	; %Variation of peak factor Dmr" with load
            QDZ8  =  tirParams.QDZ8 	; %Variation of peak factor Dmr" with camber
            QDZ9  =  tirParams.QDZ9 	; %Variation of peak factor Dmr" with camber and load
            QDZ10 =  tirParams.QDZ10	; %Variation of peak factor Dmr with camber squared
            QDZ11 =  tirParams.QDZ11	; %Variation of Dmr with camber squared and load
            QEZ1  =  tirParams.QEZ1 	; %Trail curvature Ept at Fznom
            QEZ2  =  tirParams.QEZ2 	; %Variation of curvature Ept with load
            QEZ3  =  tirParams.QEZ3 	; %Variation of curvature Ept with load squared
            QEZ4  =  tirParams.QEZ4 	; %Variation of curvature Ept with sign of Alpha-t
            QEZ5  =  tirParams.QEZ5 	; %Variation of Ept with camber and sign Alpha-t
            QHZ1  =  tirParams.QHZ1 	; %Trail horizontal shift Sht at Fznom
            QHZ2  =  tirParams.QHZ2 	; %Variation of shift Sht with load
            QHZ3  =  tirParams.QHZ3 	; %Variation of shift Sht with camber
            QHZ4  =  tirParams.QHZ4 	; %Variation of shift Sht with camber and load
            PPZ1  =  tirParams.PPZ1		; %effect of inflation pressure on length of pneumatic trail
            PPZ2  =  tirParams.PPZ2		; %Influence of inflation pressure on residual aligning torque
            
            SHt = QHZ1 + QHZ2.*dfz + (QHZ3 + QHZ4.*dfz).*gamma_star; % (4.E35)
            
            signKya = sign(Kya);
            signKya(signKya == 0) = 1; % If [Kya = 0] then [sign(0) = 0]. This is done to avoid [num / 0 = NaN] in Eqn 4.E38
            
            Kya_prime = Kya + epsilonk.*signKya; % (4.E39) [sign(Kya) term explained on page 177]
            SHf = SHy + SVy./Kya_prime; % (4.E38)
            alphar = alpha_star + SHf; % = alphaf (4.E37)
            alphat = alpha_star + SHt; % (4.E34)
            
            if useTurnSlip
                QDTP1   = tirParams.QDTP1;
                R0      = tirParams.UNLOADED_RADIUS;
                phi     = postProInputs.phi;
                
                zeta5 = cos(atan(QDTP1.*R0.*phi)); %[Eqn (4.91) Page 186 - Book]
            else
                zeta5 = ones(size(Fz));
            end % if useTurnSlip
            
            % Dt0 = Fz.*(R0./Fz0_prime).*(QDZ1 + QDZ2.*dfz).*(1 - PPZ1.*dpi).* LTR.*sign(Vcx); % (4.E42)
            % Dt = Dt0.*(1 + QDZ3.*abs(gamma_star) + QDZ4.*gamma_star.^2).*zeta5; % (4.E43)
            %
            % IMPORTANT NOTE: The above original equation (4.E43) was not matching the
            % TNO solver. The coefficient Dt affects the pneumatic trail (t) and the
            % self aligning torque (Mz).
            % It was observed that when negative inclination angles where used as
            % inputs, there was a discrepancy between the TNO solver and mfeval.
            % This difference comes from the term QDZ3, that in the original equation
            % is multiplied by abs(gamma_star). But in the paper the equation is
            % different and the abs() term is not written. Equation (A60) from the
            % paper resulted into a perfect match with TNO.
            % Keep in mind that the equations from the paper don't include turn slip
            % effects. The term zeta5 has been added although it doesn't appear in the
            % paper.
            
            % Paper definition:
            Dt = (QDZ1 + QDZ2.*dfz).*(1 - PPZ1.*dpi).* (1 + QDZ3.*gamma + QDZ4.*gamma.^2).*Fz.*(R0./Fz0_prime).*LTR.*zeta5; % (A60)
            
            % Bt = (QBZ1 + QBZ2.*dfz + QBZ3.*dfz.^2).*(1 + QBZ5.*abs(gamma_star) + QBZ6.*gamma_star.^2).*LKY./LMUY_star; %(> 0)(4.E40)
            %
            % IMPORTANT NOTE: In the above original equation (4.E40) it is used the
            % parameter QBZ6, which doesn't exist in the standard TIR files. Also note
            % that on page 190 and 615 of the book a full set of parameters is given
            % and QBZ6 doesn't appear.
            % The equation has been replaced with equation (A58) from the paper.
            
            % Paper definition:
            Bt = (QBZ1 + QBZ2.*dfz + QBZ3.*dfz.^2).*(1 + QBZ4.*gamma + QBZ5.*abs(gamma) ).*LKY./LMUY_star; %(> 0) (A58)
            Ct = QCZ1; % (> 0) (4.E41)
            Et = (QEZ1 + QEZ2.*dfz + QEZ3.*dfz.^2).*(1+(QEZ4+QEZ5.*gamma_star).*(2./pi).*atan(Bt.*Ct.*alphat)); % (<=1) (4.E44)
            
            % Limits check
            if(useLimitsCheck)
                if(any(Et > 1))
                    warning('Solver:CoeffChecks:Et','Et over limit (>1), Eqn(4.E44)')
                    Et(Et > 1) = 1;
                end % if Et > 1
            end % if useLimitsCheck
            
            t0 = Dt.*cos(Ct.*atan(Bt.*alphat - Et.*(Bt.*alphat - atan(Bt.*alphat)))).*cos(alpha_prime); %t(aplhat)(4.E33)
            
            % Evaluate Fy0 with gamma = 0 and phit = 0
            modes_sub0 = modes;
            modes_sub0.useTurnSlip = false;
            
            postProInputs_sub0 = postProInputs;
            postProInputs_sub0.gamma = zeros(size(Fz));
            
            starVar_sub0 = starVar;
            starVar_sub0.gamma_star = zeros(size(Fz));
            
            [Fyo_sub0, ~, ~, ~, ~, ~, ~, ~] = obj.calculateFy0(tirParams, postProInputs_sub0, internalParams, modes_sub0, starVar_sub0, primeVar, incrVar);
            
            Mzo_prime = -t0.*Fyo_sub0; % gamma=phi=0 (4.E32)
            
            if useTurnSlip
                zeta0 = 0;
                zeta2 = internalParams.zeta2;
                phi     = postProInputs.phi;
                
                QBRP1 = tirParams.QBRP1;
                QCRP1 = tirParams.QCRP1;
                QDRP1 = tirParams.QDRP1;
                QCRP2 = tirParams.QCRP2;
                QDZ8  = tirParams.QDZ8;
                QDZ9  = tirParams.QDZ9;
                QDZ10 = tirParams.QDZ10;
                QDZ11 = tirParams.QDZ11;
                LMP   = tirParams.LMP;
                
                zeta6 = cos(atan(QBRP1.*R0.*phi)); % [Eqn (4.102) Page 188 - Book]
                
                [Fy0, muy, ~, ~, ~, ~, ~, ~, ~] = obj.calculateFy0(tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar);
                
                epsilong = internalParams.epsilong;
                phit = postProInputs.phit;
                
                Mzp_inf = QCRP1.*abs(muy).*R0.*Fz.*sqrt(Fz./Fz0_prime).*LMP; % [Eqn (4.95) Page 187 - Book]
                % Mzp_inf should be always > 0
                negative_Mzp_inf = Mzp_inf < 0;
                Mzp_inf(negative_Mzp_inf) = 1e-6;
                
                CDrp = QDRP1; % (>0) [Eqn (4.96) Page 187 - Book]
                DDrp = Mzp_inf./sin(0.5.*pi.*CDrp); % [Eqn (4.94) Page 187 - Book]
                Kzgr0 = Fz.*R0.*(QDZ8.*QDZ9.*dfz + (QDZ10 + QDZ11.*dfz.*abs(gamma))).*LKZC; %[Eqn (4.99) Page 187 - Book]
                BDrp = Kzgr0./(CDrp.*DDrp.*(1 - epsilong)); % Eqn from the manual
                Drp = DDrp.*sin(CDrp.*atan(BDrp.*R0.*(phit))); % Eqn from the manual
                
                [~,Gyk] = obj.calculateFy(tirParams, postProInputs, internalParams, modes, starVar, incrVar, Fy0, muy);
                
                Mzp90 = Mzp_inf.*(2/pi).*atan(QCRP2.*R0.*abs(phit)).*Gyk; % [Eqn (4.103) Page 188 - Book]
                
                zeta7 = (2/pi).*acos(Mzp90./(abs(Drp))); % Eqn from the manual
                zeta8 = 1 + Drp;
            else
                zeta0 = 1;
                zeta2 = ones(size(Fz));
                zeta6 = ones(size(Fz));
                zeta7 = ones(size(Fz));
                zeta8 = ones(size(Fz));
            end % if useTurnSlip
            
            Dr = Fz.*R0.*((QDZ6 + QDZ7.*dfz).*LRES.*zeta2 + ((QDZ8 + QDZ9.*dfz).*(1 + PPZ2.*dpi) + (QDZ10 + QDZ11.*dfz).*abs(gamma_star)).*gamma_star.*LKZC.*zeta0).*LMUY_star.*sign(Vcx).*cos(alpha_star) + zeta8 - 1; % (4.E47)
            Br = (QBZ9.*LKY./LMUY_star + QBZ10.*By.*Cy).*zeta6; % preferred: qBz9 = 0 (4.E45)
            Cr = zeta7; % (4.E46)
            Mzr0 = Dr.*cos(Cr.*atan(Br.*alphar)).*cos(alpha_prime); % =Mzr(alphar)(4.E36)
            Mz0 = Mzo_prime + Mzr0; % (4.E31)
            
        end % calculateMz0
        
        function [Fx] = calculateFx(~, tirParams, postProInputs, modes, starVar, incrVar, Fx0)%#codegen
            
            % Declare extrinsic functions
            coder.extrinsic('warning')
            
            % Unpack Parameters
            useLimitsCheck = modes.useLimitsCheck;
            kappa = postProInputs.kappa;
            alpha_star = starVar.alpha_star;
            gamma_star = starVar.gamma_star;
            dfz = incrVar.dfz;
            
            %[SCALING_COEFFICIENTS]
            LXAL = tirParams.LXAL ; % Scale factor of alpha influence on Fx
            
            %[LONGITUDINAL_COEFFICIENTS]
            RBX1 =  tirParams.RBX1 ; %Slope factor for combined slip Fx reduction
            RBX2 =  tirParams.RBX2 ; %Variation of slope Fx reduction with kappa
            RBX3 =  tirParams.RBX3 ; %Influence of camber on stiffness for Fx combined
            RCX1 =  tirParams.RCX1 ; %Shape factor for combined slip Fx reduction
            REX1 =  tirParams.REX1 ; %Curvature factor of combined Fx
            REX2 =  tirParams.REX2 ; %Curvature factor of combined Fx with load
            RHX1 =  tirParams.RHX1 ; %Shift factor for combined slip Fx reduction
            
            Cxa = RCX1; % (4.E55)
            Exa = REX1 + REX2.*dfz; % (<= 1) (4.E56)
            
            % Limits check
            if(useLimitsCheck)
                if(any(Exa > 1))
                    warning('Solver:CoeffChecks:Exa','Exa over limit (>1), Eqn(4.E56)')
                    Exa(Exa > 1) = 1;
                end % if Exa > 1
            end % if useLimitsCheck
            
            SHxa = RHX1; % (4.E57)
            Bxa = (RBX1 + RBX3.*gamma_star.^2).*cos(atan(RBX2.*kappa)).*LXAL; % (> 0) (4.E54)
            
            alphas = alpha_star + SHxa; % (4.E53)
            
            Gxa0 = cos(Cxa.*atan(Bxa.*SHxa-Exa.*(Bxa.*SHxa-atan(Bxa.*SHxa)))); % (4.E52)
            Gxa = cos(Cxa.*atan(Bxa.*alphas-Exa.*(Bxa.*alphas-atan(Bxa.*alphas))))./Gxa0;  % (> 0)(4.E51
            
            Fx = Gxa.*Fx0; % (4.E50)
            
        end % calculateFx
        
        function [Fy, Gyk, SVyk] = calculateFy(~, tirParams, postProInputs, internalParams, modes, starVar, incrVar, Fy0, muy)%#codegen
            
            % Declare extrinsic functions
            coder.extrinsic('warning')
            
            useTurnSlip = modes.useTurnSlip;
            
            useLimitsCheck = modes.useLimitsCheck;
            
            Fz = postProInputs.Fz;
            kappa = postProInputs.kappa;
            alpha_star = starVar.alpha_star;
            gamma_star = starVar.gamma_star;
            dfz = incrVar.dfz;
            
            if useTurnSlip
                zeta2 = internalParams.zeta2;
            else
                zeta2 = ones(size(Fz));
            end % if useTurnSlip
            
            %[SCALING_COEFFICIENTS]
            LYKA  = tirParams.LYKA  ; % Scale factor of alpha influence on Fx
            LVYKA = tirParams.LVYKA ; % Scale factor of kappa induced Fy
            
            %[LATERAL_COEFFICIENTS]
            RBY1 =  tirParams.RBY1; %Slope factor for combined Fy reduction
            RBY2 =  tirParams.RBY2; %Variation of slope Fy reduction with alpha
            RBY3 =  tirParams.RBY3; %Shift term for alpha in slope Fy reduction
            RBY4 =  tirParams.RBY4; %Influence of camber on stiffness of Fy combined
            RCY1 =  tirParams.RCY1; %Shape factor for combined Fy reduction
            REY1 =  tirParams.REY1; %Curvature factor of combined Fy
            REY2 =  tirParams.REY2; %Curvature factor of combined Fy with load
            RHY1 =  tirParams.RHY1; %Shift factor for combined Fy reduction
            RHY2 =  tirParams.RHY2; %Shift factor for combined Fy reduction with load
            RVY1 =  tirParams.RVY1; %Kappa induced side force Svyk./Muy.*Fz at Fznom
            RVY2 =  tirParams.RVY2; %Variation of Svyk./Muy.*Fz with load
            RVY3 =  tirParams.RVY3; %Variation of Svyk./Muy.*Fz with camber
            RVY4 =  tirParams.RVY4; %Variation of Svyk./Muy.*Fz with alpha
            RVY5 =  tirParams.RVY5; %Variation of Svyk./Muy.*Fz with kappa
            RVY6 =  tirParams.RVY6; %Variation of Svyk./Muy.*Fz with atan(kappa)
            
            DVyk = muy.*Fz.*(RVY1 + RVY2.*dfz + RVY3.*gamma_star).*cos(atan(RVY4.*alpha_star)).*zeta2; % (4.E67)
            SVyk = DVyk.*sin(RVY5.*atan(RVY6.*kappa)).*LVYKA; % (4.E66)
            SHyk = RHY1 + RHY2.*dfz; % (4.E65)
            Eyk = REY1 + REY2.*dfz; % (<=1) (4.E64)
            
            % Limits check
            if(useLimitsCheck)
                if(any(Eyk > 1))
                    warning('Solver:CoeffChecks:Eyk','Eyk over limit (>1), Eqn(4.E64)')
                    Eyk(Eyk > 1) = 1;
                end % if Eyk > 1
            end % useLimitsCheck
            
            Cyk = RCY1; % (4.E63)
            Byk = (RBY1 + RBY4.*gamma_star.^2).*cos(atan(RBY2.*(alpha_star - RBY3))).*LYKA; % (> 0) (4.E62)
            kappas = kappa + SHyk; % (4.E61)
            
            Gyk0 = cos(Cyk.*atan(Byk.*SHyk - Eyk.*(Byk.*SHyk - atan(Byk.*SHyk)))); % (4.E60)
            Gyk = cos(Cyk.*atan(Byk.*kappas - Eyk.*(Byk.*kappas-atan(Byk.*kappas))))./Gyk0; % (> 0)(4.E59)
            
            % Low speed model
            isLowSpeed = modes.isLowSpeed;
            if any(isLowSpeed) % Line for Simulink
                SVyk(isLowSpeed) = SVyk(isLowSpeed).*internalParams.reductionSmooth;
            end % if isLowSpeed
            
            Fy = Gyk.*Fy0 + SVyk; % (4.E58)
            
        end % calculateFy
        
        function [Mx] = calculateMx(~, tirParams, postProInputs, incrVar, Fy)%#codegen
            
            % Unpack Parameters
            Fz = postProInputs.Fz;
            gamma = postProInputs.gamma;
            dpi = incrVar.dpi;
            
            % Empirically discovered:
            % If Fz is below FzMin a reduction factor is applied:
            reduction_lowFz = Fz.*(Fz./tirParams.FZMIN).^2;
            Fz(Fz<tirParams.FZMIN) = real(reduction_lowFz(Fz<tirParams.FZMIN));
            
            %[VERTICAL]
            Fz0 = tirParams.FNOMIN; %Nominal wheel load
            
            %[DIMENSION]
            R0 = tirParams.UNLOADED_RADIUS; %Free tyre radius
            
            %[SCALING_COEFFICIENTS]
            LVMX = tirParams.LVMX; % Scale factor of Mx vertical shift
            LMX  = tirParams.LMX ; % Scale factor of overturning couple
            
            %[OVERTURNING_COEFFICIENTS]
            QSX1 =  tirParams.QSX1 ; %Vertical shift of overturning moment
            QSX2 =  tirParams.QSX2 ; %Camber induced overturning couple
            QSX3 =  tirParams.QSX3 ; %Fy induced overturning couple
            QSX4 =  tirParams.QSX4 ; %Mixed load lateral force and camber on Mx
            QSX5 =  tirParams.QSX5 ; %Load effect on Mx with lateral force and camber
            QSX6 =  tirParams.QSX6 ; %B-factor of load with Mx
            QSX7 =  tirParams.QSX7 ; %Camber with load on Mx
            QSX8 =  tirParams.QSX8 ; %Lateral force with load on Mx
            QSX9 =  tirParams.QSX9 ; %B-factor of lateral force with load on Mx
            QSX10=  tirParams.QSX10; %Vertical force with camber on Mx
            QSX11=  tirParams.QSX11; %B-factor of vertical force with camber on Mx
            QSX12=  tirParams.QSX12; %Camber squared induced overturning moment
            QSX13=  tirParams.QSX13; %Lateral force induced overturning moment
            QSX14=  tirParams.QSX14; %Lateral force induced overturning moment with camber
            PPMX1=  tirParams.PPMX1; %Influence of inflation pressure on overturning moment
            
            % Mx = R0.*Fz.*(QSX1.*LVMX - QSX2.*gamma.*(1 + PPMX1.*dpi) + QSX3.*((Fy)/Fz0)...
            %     + QSX4.*cos(QSX5.*atan((QSX6.*(Fz./Fz0)).^2)).*sin(QSX7.*gamma + QSX8.*atan...
            %     (QSX9.*((Fy)/Fz0))) + QSX10.*atan(QSX11.*(Fz./Fz0)).*gamma).*LMX; %(4.E69)
            %
            % IMPORTANT NOTE: The above original equation (4.E69) is not used
            % because is not matching the results of the official TNO solver. Also, in
            % the book definition and in the official paper, parameters QSX12 QSX13 and
            % QSX14 are not used
            % Instead of using equations (4.E69) from the book or (A47) from the
            % official paper, it has been used the equation (49) described in the draft
            % paper of Besselink (Not the official paper). This draft can be downloaded
            % from:
            % https://pure.tue.nl/ws/files/3139488/677330157969510.pdf
            % purl.tue.nl/677330157969510.pdf
            
            % Draft paper definition:
            Mx = R0 .* Fz .* LMX .* (QSX1 .* LVMX - QSX2 .* gamma .* (1 + PPMX1 .* dpi) - QSX12 .* gamma .* abs(gamma) + QSX3 .* Fy ./ Fz0 + ...
                QSX4 .* cos(QSX5 .* atan((QSX6 .* Fz ./ Fz0) .^ 2)) .* sin(QSX7 .* gamma + QSX8 .* atan(QSX9 .* Fy ./ Fz0)) + ...
                QSX10 .* atan(QSX11 .* Fz ./ Fz0) .* gamma) + R0 .* Fy .* LMX .* (QSX13 + QSX14 .* abs(gamma)); % (49)
            
        end % calculateMx
        
        function [My] = calculateMy(obj, tirParams, postProInputs, ~, Fx)%#codegen
            
            % Unpack Parameters
            Fz_unlimited = postProInputs.uFz;
            
            % Empirically discovered:
            % If Fz is below FzMin a reduction factor is applied:
            reduction_lowFz = Fz_unlimited.*(Fz_unlimited./tirParams.FZMIN);
            Fz_unlimited(Fz_unlimited<tirParams.FZMIN) = real(reduction_lowFz(Fz_unlimited<tirParams.FZMIN));
            
            Vcx = postProInputs.uVcx;
            kappa = postProInputs.ukappa;
            gamma = postProInputs.gamma;
            p = postProInputs.p;
            
            %[OPERATING_CONDITIONS]
            pi0	= tirParams.NOMPRES	; %Nominal tyre inflation pressure
            
            %[MODEL]
            V0	= tirParams.LONGVL	; %Nominal speed
            
            %[VERTICAL]
            Fz0	= tirParams.FNOMIN	; %Nominal wheel load
            
            %[DIMENSION]
            R0	= tirParams.UNLOADED_RADIUS	; %Free tyre radius
            
            %[SCALING_COEFFICIENTS]
            LMY	= tirParams.LMY	; % Scale factor of rolling resistance torque
            
            %[ROLLING_COEFFICIENTS]
            QSY1	=  tirParams.QSY1	; %Rolling resistance torque coefficient
            QSY2	=  tirParams.QSY2	; %Rolling resistance torque depending on Fx
            QSY3	=  tirParams.QSY3	; %Rolling resistance torque depending on speed
            QSY4	=  tirParams.QSY4	; %Rolling resistance torque depending on speed .^4
            QSY5	=  tirParams.QSY5	; %Rolling resistance torque depending on camber squared
            QSY6	=  tirParams.QSY6	; %Rolling resistance torque depending on load and camber squared
            QSY7	=  tirParams.QSY7	; %Rolling resistance torque coefficient load dependency
            QSY8	=  tirParams.QSY8	; %Rolling resistance torque coefficient pressure dependency
            
            VXLOW = tirParams.VXLOW;
            
            % My = Fz.R0*(QSY1 + QSY2.*(Fx./Fz0) + QSY3.*abs(Vcx./V0) + QSY4.*(Vcx./V0).^4 ...
            %     +(QSY5 + QSY6.*(Fz./Fz0)).*gamma.^2).*((Fz./Fz0).^QSY7.*(p./pi0).^QSY8).*LMY.; %(4.E70)
            %
            % IMPORTANT NOTE: The above equation from the book (4.E70) is not used
            % because is not matching the results of the official TNO solver.
            % This equation gives a positive output of rolling resistance, and in the
            % ISO coordinate system, My should be negative. Furthermore, the equation
            % from the book has an error, multiplying all the equation by Fz instead of
            % Fz0 (first term).
            % Because of the previous issues it has been used the equation (A48) from
            % the paper.
            
            % Check MF version
            if tirParams.FITTYP == 6
                % MF5.2 equations
                My = -R0.*Fz_unlimited.*LMY.*(QSY1 + QSY2.*(Fx./Fz0) + QSY3.*abs(Vcx./V0) + QSY4.*(Vcx./V0).^4); % From the MF-Tyre equation manual
            else
                % MF6.1 and MF6.2 equations
                % Paper definition:
                My = -R0.*Fz0.*LMY.*(QSY1 + QSY2.*(Fx./Fz0) + QSY3.*abs(Vcx./V0) + QSY4.*(Vcx./V0).^4 ...
                    +(QSY5 + QSY6.*(Fz_unlimited./Fz0)).*gamma.^2).*((Fz_unlimited./Fz0).^QSY7.*(p./pi0).^QSY8); %(A48)
            end
            
            % Backward speed check
            My(Vcx < 0) = -My(Vcx < 0);
            
            % Low speed model (Empirically discovered)
            highLimit = VXLOW./abs(Vcx) - 1;
            lowLimit = -1 - VXLOW - highLimit;
            idx = kappa>=lowLimit & kappa<=highLimit;
            if any(idx)
                % Points for the interpolation
                x = kappa(idx);
                x1 = highLimit(idx);
                y1 = ones(size(x))*pi/2;
                x0 = -(ones(size(x)));
                y0 = zeros(size(x));
                % Call the interpolation function
                reduction = obj.interpolate(x0, y0, x1, y1, x);
                % Reduce My values
                My(idx) = My(idx).*sin(reduction);
            end % if idx
            
            % Negative SR check
            My(kappa<lowLimit) = -My(kappa<lowLimit);
            
            % Zero speed check
            My(Vcx == 0) = 0;
            
        end % calculateMy
        
        function [Mz,t, Mzr] = calculateMz(obj, tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar, alphar, alphat, Kxk, Kya_prime, Fy, Fx, Dr, Cr, Br, Dt, Ct, Bt, Et)%#codegen
            
            % Unpack Parameters
            kappa = postProInputs.kappa;
            gamma = postProInputs.gamma;
            dfz = incrVar.dfz;
            alpha_prime = primeVar.alpha_prime;
            
            %[VERTICAL]
            Fz0	= tirParams.FNOMIN	; %Nominal wheel load
            
            %[DIMENSION]
            R0	= tirParams.UNLOADED_RADIUS	; %Free tyre radius
            
            %[SCALING_COEFFICIENTS]
            LS		= tirParams.LS	; % Scale factor of moment arm of Fx
            LFZO	= tirParams.LFZO; % Scale factor of nominal (rated) load
            
            %[ALIGNING_COEFFICIENTS]
            SSZ1	=  tirParams.SSZ1	; %Nominal value of s./R0: effect of Fx on Mz
            SSZ2	=  tirParams.SSZ2	; %Variation of distance s./R0 with Fy./Fznom
            SSZ3	=  tirParams.SSZ3	; %Variation of distance s./R0 with camber
            SSZ4	=  tirParams.SSZ4	; %Variation of distance s./R0 with load and camber
            
            % alphar_eq = sqrt(alphar.^2+(Kxk./Kya_prime).^2.*kappa.^2).*sign(alphar); % (4.E78)
            % alphat_eq = sqrt(alphat.^2+(Kxk./Kya_prime).^2.*kappa.^2).*sign(alphat); % (4.E77)
            % s = R0.*(SSZ1 + SSZ2.*(Fy./Fz0_prime) + (SSZ3 + SSZ4.*dfz).*gamma_star).*LS; % (4.E76)
            
            % IMPORTANT NOTE: The equations 4.E78 and 4.E77 are not used due to small
            % differences discovered at negative camber angles with the TNO solver.
            % Instead equations A54 and A55 from the paper are used.
            %
            % IMPORTANT NOTE: The coefficient "s" (Equation 4.E76) determines the
            % effect of Fx into Mz. The book uses "Fz0_prime" in the formulation,
            % but the paper uses "Fz0". The equation (A56) from the paper has a better
            % correlation with TNO.
            
            alphar_eq = atan(sqrt(tan(alphar).^2+(Kxk./Kya_prime).^2.*kappa.^2)).*sign(alphar); % (A54)
            alphat_eq = atan(sqrt(tan(alphat).^2+(Kxk./Kya_prime).^2.*kappa.^2)).*sign(alphat); % (A55)
            s = R0.*(SSZ1 + SSZ2.*(Fy./Fz0) + (SSZ3 + SSZ4.*dfz).*gamma).*LS; % (A56)
            Mzr = Dr.*cos(Cr.*atan(Br.*alphar_eq)); % (4.E75)
            
            % Evaluate Fy and Fy0 with gamma = 0 and phit = 0
            internalParams_sub0 = internalParams;
            internalParams_sub0.zeta0 = 1;
            internalParams_sub0.zeta1 = ones(size(gamma));
            internalParams_sub0.zeta2 = ones(size(gamma));
            internalParams_sub0.zeta3 = ones(size(gamma));
            internalParams_sub0.zeta4 = ones(size(gamma));
            internalParams_sub0.zeta5 = ones(size(gamma));
            internalParams_sub0.zeta6 = ones(size(gamma));
            internalParams_sub0.zeta7 = ones(size(gamma));
            internalParams_sub0.zeta8 = ones(size(gamma));
            
            postProInputs_sub0 = postProInputs;
            postProInputs_sub0.gamma = zeros(size(gamma));
            
            starVar_sub0 = starVar;
            starVar_sub0.gamma_star = zeros(size(gamma));
            
            % Evaluate Fy0 with gamma = 0 and phit  = 0
            [Fyo_sub0, muy_sub0, ~, ~, ~, ~, ~, ~] = obj.calculateFy0(tirParams, postProInputs_sub0, internalParams_sub0, modes, starVar_sub0, primeVar, incrVar);
            
            % Evaluate Gyk with gamma = 0 and phit  = 0
            [~,Gyk_sub0, SVyk] = obj.calculateFy(tirParams, postProInputs_sub0, internalParams_sub0, modes, starVar, incrVar, Fyo_sub0, muy_sub0);
            
            % Note: in the above equation starVar is used instead of
            % starVar_sub0 beacuse it was found a better match with TNO
            
            Fy_prime = Gyk_sub0.*Fyo_sub0; % (4.E74)
            t = Dt.*cos(Ct.*atan(Bt.*alphat_eq - Et.*(Bt.*alphat_eq - atan(Bt.*alphat_eq)))).*cos(alpha_prime); % (4.E73)
            
            t = t*LFZO;
            
            % IMPORTANT NOTE: the above equation is not written in any source, but "t"
            % is multiplied by LFZO in the TNO dteval function. This has been empirically
            % discovered.
            
            % Low speed model
            isLowSpeed = modes.isLowSpeed;
            if any(isLowSpeed)% Line for Simulink
                t(isLowSpeed) = t(isLowSpeed).*internalParams.reductionSmooth;
                Mzr(isLowSpeed) = Mzr(isLowSpeed).*internalParams.reductionSmooth;
            end % if isLowSpeed
            
            Mz_prime = -t.*Fy_prime; % (4.E72)
            
            % Check MF version
            if tirParams.FITTYP == 6
                % MF5.2 equations
                Mz = -t.*(Fy-SVyk) + Mzr + s.*Fx; % % From the MF-Tyre equation manual
            else
                % MF6.1 and 6.2 equatons
                Mz = Mz_prime + Mzr + s.*Fx; % (4.E71)
            end
        end % calculateMz
        
        function [Re, Romega, omega] = calculateRe(~, tirParams, postProInputs, dpi)%#codegen
            
            % Unpack Parameters
            Vcx = postProInputs.uVcx;
            Fz_unlimited = postProInputs.uFz;
            kappa_unlimited = postProInputs.ukappa;
            
            % Rename the TIR file variables in the Pacejka style
            Fz0	= tirParams.FNOMIN;         	% Nominal (rated) wheel load
            R0	= tirParams.UNLOADED_RADIUS;	% Free tyre radius
            V0	= tirParams.LONGVL;          	% Nominal speed (LONGVL)
            Cz0	= tirParams.VERTICAL_STIFFNESS;	% Vertical stiffness
            
            PFZ1	= tirParams.PFZ1 	; %Pressure effect on vertical stiffness
            BREFF	= tirParams.BREFF	; %Low load stiffness effective rolling radius
            DREFF	= tirParams.DREFF	; %Peak value of effective rolling radius
            FREFF	= tirParams.FREFF	; %High load stiffness effective rolling radius
            Q_RE0	= tirParams.Q_RE0	; %Ratio of free tyre radius with nominal tyre radius
            Q_V1	= tirParams.Q_V1 	; %Tyre radius increase with speed
            
            % C code declaration
            omega = postProInputs.omega; % rotational speed (rad/s)
            Romega = R0 .* (Q_RE0 + Q_V1.*((omega.*R0)./V0).^2); % [Eqn (1) Page 2 - Paper] - Centrifugal growth of the free tyre radius
            Re = ones(size(Vcx)) * (R0*0.965);
            
            % Excerpt from OpenTIRE MF6.1 implementation
            % Date: 2016-12-01
            % Prepared for Marco Furlan/JLR
            % Questions: henning.olsson@calspan.com
            
            % Nominal stiffness (pressure corrected)
            Cz = Cz0 .* (1 + PFZ1.*dpi); % [Eqn (5) Page 2 - Paper] - Vertical stiffness adapted for tyre inflation pressure
            
            % Check if omega is one of the inputs
            % If it is, use it to calculate Re, otherwise it can be approximated with a
            % short iteration
            
            if postProInputs.nInputs > 7 && sum(postProInputs.omega) ~= 0
                % Omega is one of the inputs
                omega = postProInputs.omega+eps; % rotational speed (rad/s) [eps is added to avoid Romega = 0]
                
                Romega = R0 .* (Q_RE0 + Q_V1.*((omega.*R0)./V0).^2); % [Eqn (1) Page 2 - Paper] - Centrifugal growth of the free tyre radius
                
                % Eff. Roll. Radius
                Re = Romega -(Fz0./Cz) .* ( DREFF .*atan( BREFF.*(Fz_unlimited./Fz0)) + FREFF.*(Fz_unlimited./Fz0)); % [Eqn (7) Page 2 - Paper]
            else
                % Omega is not specified and is going to be approximated
                % Initial guess of Re based on something slightly less than R0
                
                Re_old = ones(size(Vcx)) * R0;
                
                while (abs(Re_old - Re)>1e-9)
                    Re_old = Re;
                    % Use the most up to date Re to calculate an omega
                    % omega = Vcx ./ Re; % Old definition of Henning without kappa, not valid for brake and drive
                    omega = real((kappa_unlimited.*Vcx+Vcx)./Re); % [Eqn (2.5) Page 65 - Book]
                    
                    % Then we calculate free-spinning radius
                    Romega = R0 .* (Q_RE0 + Q_V1.*((omega.*R0)./V0).^2); % [Eqn (1) Page 2 - Paper] - Centrifugal growth of the free tyre radius
                    
                    % Effective Rolling Radius
                    Re = Romega -(Fz0./Cz) .* ( DREFF .*atan( BREFF.*(Fz_unlimited./Fz0)) + FREFF.*(Fz_unlimited./Fz0)); % [Eqn (7) Page 2 - Paper]
                end % while Re has not converged
                
            end % if omega is an input
            
        end % calculateRe
        
        function [rho_z, Rl, Cz] = calculateRhoRl61(~, tirParams, postProInputs, forcesAndmoments, dpi, omega, Romega)%#codegen
            
            % Unpack Parameters
            Fz = postProInputs.Fz_lowLimit;
            Fx = forcesAndmoments.Fx;
            Fy = forcesAndmoments.Fy;
            
            % Declare extrinsic functions
            coder.extrinsic('warning')
            
            %[MODEL]
            V0      = tirParams.LONGVL 	; %Nominal speed
            
            %[VERTICAL]
            Fz0     = tirParams.FNOMIN	; %Nominal wheel load
            Cz0     = tirParams.VERTICAL_STIFFNESS	; %Tyre vertical stiffness
            Q_V2	= tirParams.Q_V2	; %Vertical stiffness increase with speed
            Q_FZ2	= tirParams.Q_FZ2	; %Quadratic term in load vs. deflection
            Q_FCX 	= tirParams.Q_FCX 	; %Longitudinal force influence on vertical stiffness
            Q_FCY 	= tirParams.Q_FCY 	; %Lateral force influence on vertical stiffness
            PFZ1  	= tirParams.PFZ1  	; %Pressure effect on vertical stiffness
            
            %[DIMENSION]
            R0    	= tirParams.UNLOADED_RADIUS	; %Free tyre radius
            
            % Model parameters as QFZ1 that normally aren't present in the TIR files
            Q_FZ1 = sqrt((Cz0.*R0./Fz0).^2 - 4.* Q_FZ2); % Rearranging [Eqn (4) Page 2 - Paper]
            
            % Split Eqn (A3.3) Page 619 of the Book into different bits:
            speed_effect    = Q_V2 .* (R0 ./ V0) .*abs(omega);
            fx_effect       = (Q_FCX .* Fx ./ Fz0).^2;
            fy_effect       = (Q_FCY .* Fy ./ Fz0).^2;
            pressure_effect   = (1+PFZ1.*dpi);
            
            % Joining all the effects except tyre deflection terms:
            external_effects = (1 + speed_effect - fx_effect - fy_effect) .* pressure_effect.*Fz0;
            
            % Equation (A3.3) can be written as:
            % Fz = (Q_FZ2*(rho/R0)^2 + Q_FZ1*(rho/R0)) * external_effects
            
            % Rearranging all the terms we end up with a quadratic equation as:
            % ax^2 + bx + c = 0
            % Q_FZ2*(rho/R0)^2 + Q_FZ1*(rho/R0) -(Fz/(external_effects)) = 0
            
            % Note: use of capital letters to avoid confusion with contact patch
            % lengths "a" and "b"
            
            A = Q_FZ2;
            B = Q_FZ1;
            C = -(Fz ./ (external_effects));
            
            if all((B^2 - 4*A*C) > 0)
                x = (-B + sqrt(B^2 - 4*A.*C)) ./ (2*A);
            else
                warning('Solver:Radius:NegativeRho','No positive solution for rho calculation')
                x = (-B + sqrt(B^2 - 4*A.*C)) ./ (2*A);
            end % if there is a real solution
            
            rho_zfr = max(x.*R0,0); % tyre deflection for a free rolling tyre
            
            % The loaded radius is the free-spinning radius minus the deflection
            Rl = max(Romega - rho_zfr, 0); % Eqn A3.2 Page 619 - Book assuming positive rho at all the time
            
            rho_z = rho_zfr;
            
            % Avoid division between zero
            rho_z(Fz==0) = 1e-6;
            
            % Vertical stiffness (Spring)
            Cz = Fz./rho_z;
            
        end % calculateRhoRl61
        
        function [rho_z, Rl, Cz] = calculateRhoRl62(obj, tirParams, postProInputs, forcesAndmoments, dpi, omega, Romega)%#codegen
            
            % Pre-allocate the variable
            Rl = zeros(size(omega));
            
            % The loaded radius (Rl) cannot be calculated straight forward
            % when the vertical load (Fz) is an input.
            %
            % Here I have written the equation for the vertical load (Fz)
            % of the MF-Tyre 6.2 model that has the loaded radius (Rl) as
            % input. (see calculateFz62 function)
            %
            % The Rl is calculated with a derivative-free method by
            % minimizing the error between the target Fz (input to mfeval)
            % and the Fz from  the "calculateFz62" function
            
            for i = 1:length(omega)
                % Declare the anonymous function (Cost function) for the fitting.
                % The cost function will measure the error between your model and the data
                % The @ operator creates the handle, and the parentheses () immediately
                % after the @ operator include the function input arguments
                fun = @(Rl) obj.costFz(tirParams, postProInputs.gamma(i), omega(i), Romega(i), dpi(i), Rl, forcesAndmoments.Fx(i), forcesAndmoments.Fy(i), forcesAndmoments.Fz(i));
                
                % Set options for Newton-Raphson and Solve
                options.Display = 'off';
                options.TolX = 1e-6;
                x0 = 0.3;
                Rl(i) = fminsearch(fun,x0,options);
            end
            
            % Call calculateFz62 with the calculated Rl to get rho_z
            [~, rho_z] = obj.calculateFz62(tirParams, postProInputs.gamma, omega, Romega, dpi, Rl, forcesAndmoments.Fx, forcesAndmoments.Fy);
            
            % Avoid division between zero
            rho_z(forcesAndmoments.Fz==0) = 1e-6;
            
            % Vertical stiffness (Spring)
            Cz = forcesAndmoments.Fz./rho_z;
            
        end % calculateRhoRl62
        
        function [a, b, NCz] = calculateContactPatch(~, tirParams, postProInputs, dpi)%#codegen
            
            % Unpack Parameters
            Fz_unlimited = postProInputs.uFz;
            
            % Rename the TIR file variables in the Pacejka style
            R0  = tirParams.UNLOADED_RADIUS;	% Free tyre radius
            w   = tirParams.WIDTH;       		% Nominal width of the tyre
            Cz0 = tirParams.VERTICAL_STIFFNESS;	% Vertical stiffness
            
            PFZ1 = tirParams.PFZ1; %Pressure effect on vertical stiffness
            
            % Nominal stiffness (pressure corrected)
            NCz = Cz0 .* (1 + PFZ1.*dpi); % [Eqn (5) Page 2 - Paper] - Vertical stiffness adapted for tyre inflation pressure
            
            %[CONTACT_PATCH]
            Q_RA1	= tirParams.Q_RA1	; %Square root term in contact length equation
            Q_RA2	= tirParams.Q_RA2	; %Linear term in contact length equation
            Q_RB1 	= tirParams.Q_RB1 	; %Root term in contact width equation
            Q_RB2 	= tirParams.Q_RB2 	; %Linear term in contact width equation
            
            % Pre-allocate MF5.2 parameters for C code generation
            Q_A1 	= 0 	; %#ok<NASGU> % MF5.2 Square root load term in contact length
            Q_A2 	= 0 	; %#ok<NASGU> % MF5.2 Linear load term in contact length
            
            %[DIMENSION]
            Rrim = tirParams.RIM_RADIUS; %Nominal rim radius
            
            %[VERTICAL]
            Fz0  = tirParams.FNOMIN	; %Nominal wheel load
            Dbtm = tirParams.BOTTOM_OFFST; %Distance to rim when bottoming starts to occur
            
            % Approximated loaded Radius
            Rl = R0 - (Fz_unlimited./NCz);
            
            % Bottoming model (Empirically discovered):
            % Check if bottoming has happened
            isBottoming = Rl-(Rrim + Dbtm)<0;
            
            % Calculate the max Fz if bottoming happens to calculate the
            % contact patch
            maxFz = (R0 - Rrim - Dbtm).* NCz;
            
            % Substitute max Fz for the calculations
            Fz_unlimited(isBottoming) = real(maxFz(isBottoming));
            
            % Check MF version
            if tirParams.FITTYP == 6
                % Load MF5.2 parameters
                Q_A1 	= tirParams.Q_A1 	; % MF5.2 Square root load term in contact length
                Q_A2 	= tirParams.Q_A2 	; % MF5.2 Linear load term in contact length
                
                if Q_A1 == 0 && Q_A2 == 0
                    % Set default vaules (Empirically discovered)
                    y = log10(R0*(Cz0/Fz0));
                    Q_A1 = -0.0388*y^3 + 0.2509*y^2 + -0.6283*y + 0.6279;
                    Q_A2 = 1.693*Q_A1^2;
                end
                
                a = R0.*(Q_A2.*(Fz_unlimited./Fz0)+Q_A1.*sqrt(Fz_unlimited./Fz0)); % From the MF-Tyre equation manual
                b = w/2; % From the MF-Tyre equation manual
            else
                % MF6.1 and 6.2 equatons
                a = R0.*(Q_RA2.*(Fz_unlimited./(NCz.*R0)) + Q_RA1.*sqrt(Fz_unlimited./(NCz.*R0))); %[Eqn (9) Page 3 - Paper]
                b = w.*(Q_RB2.*(Fz_unlimited./(NCz.*R0)) + Q_RB1.*(Fz_unlimited./(NCz.*R0)).^(1/3)); %[Eqn (10) Page 3 - Paper]
            end
        end % calculateContactPatch
        
        function [Cx, Cy, sigmax, sigmay] = calculateRelax(~, tirParams, postProInputs, varinf)%#codegen
            
            % Unpack Parameters
            gamma = postProInputs.gamma;
            Fz = postProInputs.Fz;
            p = postProInputs.p;
            Kxk = varinf.Kxk;
            Kya = varinf.Kya;
            
            PCFX1 = tirParams.PCFX1; %Tyre overall longitudinal stiffness vertical deflection dependency linear term
            PCFX2 = tirParams.PCFX2; %Tyre overall longitudinal stiffness vertical deflection dependency quadratic term
            PCFX3 = tirParams.PCFX3; %Tyre overall longitudinal stiffness pressure dependency
            PCFY1 = tirParams.PCFY1; %Tyre overall lateral stiffness vertical deflection dependency linear term
            PCFY2 = tirParams.PCFY2; %Tyre overall lateral stiffness vertical deflection dependency quadratic term
            PCFY3 = tirParams.PCFY3; %Tyre overall lateral stiffness pressure dependency
            LFZO = tirParams.LFZO; % Scale factor of nominal (rated) load
            Fz0 = tirParams.FNOMIN; % Nominal (rated) wheel load
            R0  = tirParams.UNLOADED_RADIUS; % Free tyre radius
            pi0 = tirParams.NOMPRES; % Reference pressure
            cx0 = tirParams.LONGITUDINAL_STIFFNESS; %Tyre overall longitudinal stiffness
            cy0 = tirParams.LATERAL_STIFFNESS; %Tyre overall lateral stiffness
            
            % Pre-allocate MF5.2 parameters for C code generation
            PTX1 = 0; %#ok<NASGU> % Relaxation length SigKap0/Fz at Fznom
            PTX2 = 0; %#ok<NASGU> % Variation of SigKap0/Fz with load
            PTX3 = 0; %#ok<NASGU> % Variation of SigKap0/Fz with exponent of load
            PTY1 = 0; %#ok<NASGU> % Peak value of relaxation length SigAlp0/R0
            PTY2 = 0; %#ok<NASGU> % Value of Fz/Fznom where SigAlp0 is extreme
            LSGKP = 0; %#ok<NASGU> % Scale factor of Relaxation length of Fx
            LSGAL = 0; %#ok<NASGU> % Scale factor of Relaxation length of Fy
            PKY3 = 0; %#ok<NASGU> % Variation of Kfy/Fznom with camber
            
            % Basic calculations
            Fz0_prime =  LFZO.*Fz0; % [Eqn (4.E1) Page 177 - Book]
            dfz = (Fz - Fz0_prime)./Fz0_prime; % [Eqn (4.E2a) Page 177 - Book]
            dpi = (p - pi0)./pi0; % [Eqn (4.E2b) Page 177 - Book]
            
            % Overall longitudinal Cx and lateral stiffness Cy
            Cx = cx0.*(1 + PCFX1.*dfz + PCFX2.*dfz.^2).*(1 + PCFX3.*dpi); % (Eqn 17 - Paper)
            Cy = cy0.*(1 + PCFY1.*dfz + PCFY2.*dfz.^2).*(1 + PCFY3.*dpi); % (Eqn 18 - Paper)
            
            % Check MF version
            if tirParams.FITTYP == 6
                % Load MF5.2 parameters
                PTX1 = tirParams.PTX1; % Relaxation length SigKap0/Fz at Fznom
                PTX2 = tirParams.PTX2; % Variation of SigKap0/Fz with load
                PTX3 = tirParams.PTX3; % Variation of SigKap0/Fz with exponent of load
                PTY1 = tirParams.PTY1; % Peak value of relaxation length SigAlp0/R0
                PTY2 = tirParams.PTY2; % Value of Fz/Fznom where SigAlp0 is extreme
                LSGKP = tirParams.LSGKP; % Scale factor of Relaxation length of Fx
                LSGAL = tirParams.LSGAL; % Scale factor of Relaxation length of Fy
                PKY3 = tirParams.PKY3; % Variation of Kfy/Fznom with camber
                
                % MF 5.2 equation for the longitudinal relaxation length
                sigmax = (PTX1 + PTX2.*dfz).* exp(-PTX3.*dfz) .*LSGKP.*R0.*Fz./Fz0; % From the MF-Tyre equation manual
                
                % MF 5.2 equations for the lateral relaxation length
                sigmayg = 1-PKY3.*abs(gamma);
                PTYfzn = PTY2.*Fz0_prime;
                sigmay = PTY1.*sin(2.*atan(Fz./PTYfzn)).*sigmayg.*R0.*LFZO.*LSGAL; % From the MF-Tyre equation manual
            else
                % MF 6.1 and 6.2 equations for the relaxation lengths
                sigmax = abs(Kxk./Cx); %(Eqn 19 - Paper)
                sigmay = abs(Kya./Cy); %(Eqn 19 - Paper)
            end
        end % calculateRelax
        
        function [instKya]  = calculateInstantaneousKya(~, postProInputs, forcesAndmoments)%#codegen
            
            % Unpack Parameters
            Fy =  forcesAndmoments.Fy;
            SA =  postProInputs.alpha;
            
            if numel(Fy)>1
                % Derivative and append to get same number of elements
                diffFY = diff(Fy)./diff(SA);
                instKya = [diffFY; diffFY(end)];
            else
                instKya = 0;
            end
        end % calculateInstantaneousKya
        
        function [Fz, rho_z] = calculateFz62(~, tirParams, gamma, omega, Romega, dpi, Rl, Fx, Fy)
            % Calculate the vertical Force using the equations described in
            % the MF-Tyre/MF-Swift 6.2 equation manual Document revision:
            % 20130706
            
            %[MODEL]
            V0	= tirParams.LONGVL;     % Nominal speed (LONGVL)
            
            %[DIMENSION]
            R0 = tirParams.UNLOADED_RADIUS	; %Free tyre radius
            ASPECT_RATIO = tirParams.ASPECT_RATIO;
            WIDTH = tirParams.WIDTH;
            
            %[VERTICAL]
            Fz0     = tirParams.FNOMIN	; %Nominal wheel load
            Cz0     = tirParams.VERTICAL_STIFFNESS	; %Tyre vertical stiffness
            Q_V2	= tirParams.Q_V2	; %Vertical stiffness increase with speed
            Q_FZ2	= tirParams.Q_FZ2	; %Quadratic term in load vs. deflection
            Q_FCX 	= tirParams.Q_FCX 	; %Longitudinal force influence on vertical stiffness
            Q_FCY 	= tirParams.Q_FCY 	; %Lateral force influence on vertical stiffness
            PFZ1	= tirParams.PFZ1 	; %Pressure effect on vertical stiffness
            Q_FCY2	= tirParams.Q_FCY2	; %Explicit load dependency for including the lateral force influence on vertical stiffness
            Q_CAM1	= tirParams.Q_CAM1  ; %Linear load dependent camber angle influence on vertical stiffness
            Q_CAM2	= tirParams.Q_CAM2  ; %Quadratic load dependent camber angle influence on vertical stiffness
            Q_CAM3	= tirParams.Q_CAM3  ; %Linear load and camber angle dependent reduction on vertical stiffness
            Q_FYS1	= tirParams.Q_FYS1  ; %Combined camber angle and side slip angle effect on vertical stiffness (constant)
            Q_FYS2	= tirParams.Q_FYS2  ; %Combined camber angle and side slip angle linear effect on vertical stiffness
            Q_FYS3	= tirParams.Q_FYS3  ; %Combined camber angle and side slip angle quadratic effect on vertical stiffness
            
            % Model parameters as QFZ1 that normally aren't present in the TIR files
            Q_FZ1 = sqrt((Cz0.*R0./Fz0).^2 - 4.* Q_FZ2); % Rearranging [Eqn (4) Page 2 - Paper]
            
            % Asymmetric effect for combinations of camber and lateral force
            Sfyg = (Q_FYS1 + Q_FYS2.*(Rl./Romega) + Q_FYS3.*(Rl./Romega).^2).*gamma;
            
            % Tyre deflection for a free rolling tyre
            rho_zfr = max(Romega-Rl, 0);
            
            % Reference tread width
            rtw = (1.075 - 0.5*ASPECT_RATIO)*WIDTH;
            
            % Deflection caused by camber
            rho_zg = ((Q_CAM1 .* Rl + Q_CAM2 .* Rl.^2) .* gamma).^2 .* (rtw/8).*abs(tan(gamma)) ./ ((Q_CAM1 .* Romega + Q_CAM2 .* Romega.^2) .* gamma).^2   - (Q_CAM3.* rho_zfr .* abs(gamma));
            
            % Change NaN to Zero
            rho_zg(isnan(rho_zg)) = 0;
            
            % Vertical deflection
            rho_z = max(rho_zfr + rho_zg, 0);
            
            % Correction term
            fcorr = (1 + Q_V2.*(R0./V0).*abs(omega) - ((Q_FCX.*Fx)./Fz0).^2 - ((rho_z./R0).^Q_FCY2 .* (Q_FCY*(Fy - Sfyg)./Fz0)).^2).*(1+PFZ1.*dpi);
            
            % Vertical force
            Fz = fcorr.*(Q_FZ1.*(rho_z/R0) + Q_FZ2.*(rho_z/R0).^2).*Fz0;
            
        end % calculateFz62
        
    end % Hidden methods
    
    methods (Access = protected)
        % This methods are private and only accessible inside the class
        
        function [forcesAndmoments, varinf] = doForcesAndMoments(obj, tirParams, postProInputs, internalParams, modes)%#codegen
            
            [starVar, primeVar, incrVar, ~] = obj.calculateBasic(tirParams, modes, internalParams, postProInputs);
            
            [Fx0, mux, Kxk] = obj.calculateFx0(tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar);
            
            [Fy0, muy, Kya, Kyg0, SHy, SVy, By, Cy, internalParams] = obj.calculateFy0(tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar);
            
            [~, alphar, alphat, Dr, Cr, Br, Dt, Ct, Bt, Et, Kya_prime] = obj.calculateMz0(tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar, Kya, Kyg0, SHy, SVy, By, Cy);
            
            [Fx] = obj.calculateFx(tirParams, postProInputs, modes, starVar, incrVar, Fx0);
            
            [Fy, ~, ~] = obj.calculateFy(tirParams, postProInputs, internalParams, modes, starVar, incrVar, Fy0, muy);
            
            [Mx] = obj.calculateMx(tirParams, postProInputs, incrVar, Fy);
            
            [My] = obj.calculateMy(tirParams, postProInputs, incrVar, Fx);
            
            [Mz, t, Mzr] = obj.calculateMz(tirParams, postProInputs, internalParams, modes, starVar, primeVar, incrVar, alphar, alphat, Kxk, Kya_prime, Fy, Fx, Dr, Cr, Br, Dt, Ct, Bt, Et);
            
            % Pack outputs
            forcesAndmoments.Fx = Fx;
            forcesAndmoments.Fy = Fy;
            forcesAndmoments.Fz = postProInputs.Fz;
            forcesAndmoments.Mx = Mx;
            forcesAndmoments.My = My;
            forcesAndmoments.Mz = Mz;
            
            varinf.Kxk = Kxk;
            varinf.mux = mux;
            varinf.Kya = Kya;
            varinf.muy = muy;
            varinf.t = t;
            varinf.Mzr = Mzr;
            
        end % doForcesAndMoments
        
        function [Re, omega, rho, Rl, a, b, Cx, Cy, Cz, sigmax, sigmay, instKya] = doExtras(obj, tirParams, postProInputs, forcesAndmoments, varinf)%#codegen
            
            dpi = (postProInputs.p - tirParams.NOMPRES)./tirParams.NOMPRES; % [Eqn (4.E2b) Page 177 - Book]
            
            [Re, Romega, omega] = obj.calculateRe(tirParams, postProInputs, dpi);
            
            % Calculate the radius with the MF61 or MF62 formulation
            if tirParams.FITTYP == 61
                [rho, Rl, Cz] = obj.calculateRhoRl61(tirParams, postProInputs, forcesAndmoments, dpi, omega, Romega);
            else
                [rho, Rl, Cz] = obj.calculateRhoRl62(tirParams, postProInputs, forcesAndmoments, dpi, omega, Romega);
            end
            
            [a, b, ~] = obj.calculateContactPatch(tirParams, postProInputs, dpi);
            
            [Cx, Cy, sigmax, sigmay] = obj.calculateRelax(tirParams, postProInputs, varinf);
            
            [instKya] = obj.calculateInstantaneousKya(postProInputs, forcesAndmoments);
            
        end % doExtras
        
        function [y] = interpolate(~, xo, yo, x1, y1, x)%#codegen
            %INTERPOLATE Interpolate between two points.
            
            y = (yo.*(x1-x)+y1.*(x-xo))./(x1-xo);
            
        end % interpolate
        
        function cost = costFz(obj, tirParams, gamma, omega, Romega, dpi, Rl, Fx, Fy, dataFz)
            % Cost function to calculate Rl. This measures the error
            % between the tatget Fz (input of MFeval) vs the Fz calculated
            % with the current Rl value.
            
            % Calculate Fz from MF 6.2  with current Rl
            modelFz = obj.calculateFz62(tirParams, gamma, omega, Romega, dpi, Rl, Fx, Fy);
            
            % Cost (error)
            cost = (modelFz-dataFz)^2;
            
        end % costFz
        
    end % Protected methods
    
end % Classdef
function limitDerivativePerturbations(varargin)
%limitDerivativePerturbations - limit perturbations in finite difference
% approximation of derivatives used in the Simulink numerical integrators.
% Call with () to limit perturbations. Call with ([]) to set back to
% defaults.

try
    plimitDerivativePerturbations(varargin{:});
catch
    %str = sprintf();
    show_warning = 1;
    if(nargin>0)
        if(isempty(varargin{:}))
            show_warning = 0;
        end
    end
    if(show_warning)
        warning('%s\n%s',...
            'Unable to limit pertubations.',...
            'We recommend you use this example in a newer version of MATLAB.');
    end
    
end

end

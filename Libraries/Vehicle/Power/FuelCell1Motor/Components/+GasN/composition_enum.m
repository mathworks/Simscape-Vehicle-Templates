classdef composition_enum < int32
% Enumeration for variable/fixed orifice choice
  enumeration
    mass (0)
    mole (1)
  end
  methods(Static)
    function map = displayText()
      map = containers.Map;
      map('mass') = 'Mass Fractions';
      map('mole') = 'Mole Fractions';
    end
  end
  
end
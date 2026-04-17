function sm_car_lut_plot1lutkin(lut_kin)

% Use existing figure if one exists
fig_handle_name =   'h1_kin_tables';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

subplot(221)
[X,Y] = meshgrid(lut_kin.qaToe.Value, lut_kin.zaToe.Value);
surf(X,Y,lut_kin.aToe.Value)
xlabel('Str (rad)');ylabel('zWC (m)')
title('Toe Angle (deg)')
view(155,25); box on

subplot(222)
[X,Y] = meshgrid(lut_kin.qaCamber.Value, lut_kin.zaCamber.Value);
surf(X,Y,lut_kin.aCamber.Value)
xlabel('Str(rad)');ylabel('zWC (m)')
title('Camber Angle (deg)')
view(155,25); box on

subplot(223)
[X,Y] = meshgrid(lut_kin.qxLong.Value, lut_kin.zxLong.Value);
surf(X,Y,lut_kin.xLong.Value)
xlabel('Str (rad)');ylabel('zWC (m)')
title('Long. Defl. (m)')
view(155,25); box on

subplot(224)
[X,Y] = meshgrid(lut_kin.qxLat.Value, lut_kin.zxLat.Value);
surf(X,Y,lut_kin.xLat.Value) 
xlabel('Str (rad)');ylabel('zWC (m)')
title('Lat. Defl. (m)')
view(155,25); box on

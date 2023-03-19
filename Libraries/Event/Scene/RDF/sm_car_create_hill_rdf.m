function sm_car_create_hill_rdf(varargin)
%sm_car_create_hill_rdf  Write RDF file for hill
%   sm_car_create_rough_road_rdf(varargin)
%
%   showplot   'y' to plot profile for left and right sides
%
% Copyright 2018-2023 The MathWorks, Inc.

cd(fileparts(which(mfilename)));

showplot = 'n';
if(nargin==1)
    showplot = varargin{1};
end

start_run      = 40;   start_height   = 0;
upslope_run    = 70;  plateau_height = upslope_run*0.07;   
plateau_run    = 20;   
dnslope_run    = 100;   
end_run        = 30;   end_height     = 0;

road_ptxz = zeros(6,2);
road_ptxz = [road_ptxz(:,1) + [0 1 1 1 1 1]'*start_run    road_ptxz(:,2)];
road_ptxz = [road_ptxz(:,1) + [0 0 1 1 1 1]'*upslope_run   road_ptxz(:,2)];
road_ptxz = [road_ptxz(:,1) + [0 0 0 1 1 1]'*plateau_run   road_ptxz(:,2)];
road_ptxz = [road_ptxz(:,1) + [0 0 0 0 1 1]'*dnslope_run   road_ptxz(:,2)];
road_ptxz = [road_ptxz(:,1) + [0 0 0 0 0 1]'*end_run       road_ptxz(:,2)];

road_ptxz = [road_ptxz(:,1)   road_ptxz(:,2) + [1 1 0 0 0 0]'*start_height];
road_ptxz = [road_ptxz(:,1)   road_ptxz(:,2) + [0 0 1 1 0 0]'*plateau_height];
road_ptxz = [road_ptxz(:,1)   road_ptxz(:,2) + [0 0 0 0 1 1]'*end_height];
% Select interpolation points

startpts = linspace(road_ptxz(1,1),road_ptxz(2,1),10);
platpts  = linspace(road_ptxz(3,1),road_ptxz(4,1),10);
endpts   = linspace(road_ptxz(5,1),road_ptxz(6,1),10);


npts_slope = 40;
interp_ptx = [...
    startpts(1:end-1) ...
    road_ptxz(2,1):((road_ptxz(3,1)-(road_ptxz(2,1)))/npts_slope):road_ptxz(3,1) ...
    platpts(2:end-1) ...
    road_ptxz(4,1):((road_ptxz(5,1)-(road_ptxz(4,1)))/npts_slope):road_ptxz(5,1) ...
    endpts(2:end)];

%interp_ptx = [...
%    road_ptxz(1,1) ...
%    road_ptxz(2,1):((road_ptxz(3,1)-(road_ptxz(2,1)))/npts_slope):road_ptxz(3,1) ...
%    road_ptxz(4,1):((road_ptxz(5,1)-(road_ptxz(4,1)))/npts_slope):road_ptxz(5,1) ...
%    road_ptxz(6,1)];


interp_ptz = interp1(road_ptxz(:,1),road_ptxz(:,2),interp_ptx,'pchip');

x =  interp_ptx;
zL = interp_ptz;
zR = interp_ptz;

if(strcmpi(showplot,'y'))
    subplot(211)
    plot(x,zL,'-o')
    title('X-Z Data, Left Wheel');
    ylabel('m');
    
    subplot(212)
    plot(x,zR,'-o')
    title('X-Z Data, Right Wheel');
    xlabel('m');
    ylabel('m');
end
%plot(x,z,'-o')
%axis('equal')

fid=fopen('Plateau_Road.rdf','w');

fprintf(fid,'%s\n','!');
fprintf(fid,'%s\n','! road data file');
fprintf(fid,'%s\n','!');
fprintf(fid,'%s%s.m\n','! from ',mfilename);
fprintf(fid,'%s\n','!');
fprintf(fid,'%s\n','$--------------------------------------------------------------------------UNITS');
fprintf(fid,'%s\n','[UNITS]');
fprintf(fid,'%s\n','LENGTH             = ''meter''');
fprintf(fid,'%s\n','FORCE              = ''newton''');
fprintf(fid,'%s\n','ANGLE              = ''degree''');
fprintf(fid,'%s\n','MASS               = ''kg''');
fprintf(fid,'%s\n','TIME               = ''sec''');
fprintf(fid,'%s\n','$--------------------------------------------------------------------------MODEL');
fprintf(fid,'%s\n','[MODEL]');
fprintf(fid,'%s\n','METHOD             = ''2D''');
fprintf(fid,'%s\n','ROAD_TYPE          = ''poly_line''');
fprintf(fid,'%s\n','$---------------------------------------------------------------------PARAMETERS');
fprintf(fid,'%s\n','[PARAMETERS]');
fprintf(fid,'%s\n','MU                      =  1.0   $ peak friction scaling coefficient');
fprintf(fid,'%s\n','OFFSET                  =    0   $ vertical offset of the ground wrt inertial frame');
fprintf(fid,'%s\n','ROTATION_ANGLE_XY_PLANE =    0   $ definition of the positive X-axis of the road wrt inertial frame');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s   %s   %s   %s\n','$','X_road','Z_left','Z_right');
fprintf(fid,'%s\n','(XZ_DATA)');
fprintf(fid,'   %4.4f   %4.4f   %4.4f\n',-1e4,0,0);
for i=1:length(x)
    fprintf(fid,'   %4.4f   %4.4f   %4.4f\n',x(i),zL(i),zR(i));
end
fprintf(fid,'   %4.4f  %4.4f   %4.4f\n',1e4,0,0);
fclose(fid);


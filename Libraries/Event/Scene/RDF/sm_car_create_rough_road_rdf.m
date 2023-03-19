function sm_car_create_rough_road_rdf(varargin)
%sm_car_create_rough_road_rdf  Write RDF file for rough road
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

x1=[0:5:40]';
zL1=zeros(size(x1));

zR1=zL1;

% Sine Wave, Large, In-Phase
amp_sw       = 0.1;
ncycles      = 3;
lcycle       = 10;
ncyclepts    = 50;

zL2=amp_sw*sin(2*pi/(ncyclepts):(2*pi)/(ncyclepts):(ncycles*2*pi))';
x2=[(x1(end))+[(lcycle/(ncyclepts)):(lcycle/(ncyclepts)):(lcycle*ncycles)]]';

zR2 = zL2;

% Flat Section
x3 = [(x2(end)+2):2:(x2(end)+10)]';
zL3 = zeros(size(x3));

zR3 = zL3;

% Sine Wave, Small, In-phase
amp_sw       = 0.02;
ncycles      = 10;
lcycle       = 2.824;
ncyclepts    = 50;

zL4=amp_sw*sin(2*pi/(ncyclepts):(2*pi)/(ncyclepts):(ncycles*2*pi))';
x4=[(x3(end))+[(lcycle/(ncyclepts)):(lcycle/(ncyclepts)):(lcycle*ncycles)]]';

zR4 = zL4;

% Flat Section
x5 = [(x4(end)+2):2:(x4(end)+10)]';
zL5 = zeros(size(x5));

zR5 = zL5;

% Sine Wave, Small, Out-of-phase
amp_sw       = 0.02;
ncycles      = 10;
lcycle       = 2.824;
ncyclepts    = 50;

zL6=amp_sw*sin(2*pi/(ncyclepts):(2*pi)/(ncyclepts):(ncycles*2*pi))';
x6=[(x5(end))+[(lcycle/(ncyclepts)):(lcycle/(ncyclepts)):(lcycle*ncycles)]]';

zR6 = -zL6;

% Flat Section
x7 = [(x6(end)+2):2:(x6(end)+10)]';
zL7 = zeros(size(x7));

zR7 = zL7;


% Triangle Wave in phase
amp_sw       = 0.05;
ncycles      = 4;
lcycle       = 3;
ncyclepts    = 50;

za=amp_sw*[1/(ncyclepts):1/(ncyclepts/4):1]';
zb=amp_sw*[1-(1/(ncyclepts/4)):-1/(ncyclepts/4):-1]';
zc=amp_sw*[-1+1/(ncyclepts/4):1/(ncyclepts/4):0]';
zL8 = [za;zb;zc];
x8=[(x7(end))+[(lcycle/(ncyclepts)):(lcycle/(ncyclepts)):(lcycle)]]';

zR8 = zL8;

% Repeat triangle
zL9 = zL8;
zR9 = zR8;
x9=[(x8(end))+[(lcycle/(ncyclepts)):(lcycle/(ncyclepts)):(lcycle)]]';

% Repeat triangle
zL10 = zL9;
zR10 = zR9;
x10=[(x9(end))+[(lcycle/(ncyclepts)):(lcycle/(ncyclepts)):(lcycle)]]';

% Flat Section
x11 = [(x10(end)+2):2:(x10(end)+10)]';
zL11 = zeros(size(x11));

zR11 = zL11;

x = [x1;x2;x3;x4;x5;x6;x7;x8;x9;x10;x11];
zL = [zL1;zL2;zL3;zL4;zL5;zL6;zL7;zL8;zL9;zL10;zL11];
zR = [zR1;zR2;zR3;zR4;zR5;zR6;zR7;zR8;zR9;zR10;zR11];

if(strcmpi(showplot,'y'))
    subplot(211)
    plot(x1,zL1,'r-o')
    hold on
    plot(x2,zL2,'b-x')
    plot(x3,zL3,'r-o')
    plot(x4,zL4,'b-x')
    plot(x5,zL5,'r-o')
    plot(x6,zL6,'b-x')
    plot(x7,zL7,'r-o')
    plot(x8,zL8,'b-x')
    plot(x9,zL9,'r-x')
    plot(x10,zL10,'b-x')
    plot(x11,zL11,'r-x')
    hold off
    title('X-Z Data, Left Wheel');
    ylabel('m');
    
    subplot(212)
    plot(x1,zR1,'r-o')
    hold on
    plot(x2,zR2,'b-x')
    plot(x3,zR3,'r-o')
    plot(x4,zR4,'b-x')
    plot(x5,zR5,'r-o')
    plot(x6,zR6,'b-x')
    plot(x7,zR7,'r-o')
    plot(x8,zR8,'b-x')
    plot(x9,zR9,'r-x')
    plot(x10,zR10,'b-x')
    plot(x11,zR11,'r-x')
    hold off
    title('X-Z Data, Right Wheel');
    xlabel('m');
    ylabel('m');
end
%plot(x,z,'-o')
%axis('equal')

fid=fopen('Rough_Road.rdf','w');

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


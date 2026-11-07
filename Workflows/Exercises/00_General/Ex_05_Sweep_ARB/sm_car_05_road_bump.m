function [x_road, y_road] = replace_plateau_bump

x1 = [-1000 0 99];
x2 = [0:0.05:1];
x3 = [1:1:18];
x4 = x2;

% Ensure length is same as RDF Rough Road
numpts = length(x1)+length(x2)+length(x3)+length(x4);
x5 = linspace(0,500,1329-numpts);

y1 = 0*ones(size(x1));

bump_height = 0.05;
bump_length = x2(end)-x2(1);
for i=1:length(x2)
    U = (x2(i)-x2(1))/x2(end)-x2(1);
    y2(i) = (bump_height)*(3-2*U)*U*U;
end
y3 = bump_height*ones(size(x3));
y4 = fliplr(y2);
y5 = 0*ones(size(x5));

x2 = x2+(x1(end))+1;
x3 = x3+x2(end);
x4 = x4+x3(end)+1;
x5 = x5+x4(end)+1;

x_road = [x1';x2';x3';x4';x5'];
y_road = [y1';y2';y3';y4';y5'];

x_road = [x_road;flipud(x_road)];
y_road = flipud([y_road;flipud(y_road)-0.05]);

%figure(99)
%plot(x_vec,y_vec,'-o')

end
function [] = PlotPoints(points, colour, drawIndices)
%PLOTPOINTS Draws the given points
%   Plots the given point cloud, colour-coded by depth

%Validate the inputs
if size(points, 1) <= 0
    warning('No points given');
    return;
end
if size(points, 2) ~= 3
    warning('Points given in incorrect format');
    return;
end

if nargin < 3
	drawIndices = 0;
end

savedhold = ishold;

figure(1);

span = [ min(points(:,1)) max(points(:,1)) min(points(:,2)) max(points(:,2)) min(points(:,3)) max(points(:,3)) ];


if nargin < 2
    colormap hsv;
    maxDepth = max(points(:,3));
    colour = points(:,3)/maxDepth;
end
%colour = [ points(:,3)/maxDepth, maxDepth + 1 - points(:,3)/maxDepth,  ones(size(points,1),1) ];

scatter3(points(:,1), points(:,2), points(:,3), 1, colour)

if drawIndices
    a = [1:size(points, 1)]'; b = num2str(a); c = cellstr(b);
    text(points(:,1), points(:,2), points(:,3), c);
end

axis(span);
grid on;
xlabel('x');
ylabel('y');
zlabel('z');
camproj('perspective')

%Reset the hold state to what it was before starting this function
if savedhold
    hold on;
else
    hold off;
end

end

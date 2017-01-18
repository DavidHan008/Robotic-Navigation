function [points] = GenerateMock3DData()

left = 2;
right = -2;
back = -2;
front = 2;
bottom = 0;
top = 2;

width = right - left;
depth = front - back;
height = top - bottom;

xDensity = 16;
yDensity = 16;
zDensity = 8;

proximityTolerance = 0.001;

points = [];

%Left Wall
points = [points; GenerateQuadrilateralPoints([left, front, bottom], ...
    [0, -depth, 0], [0, 0, height], xDensity, zDensity)];

%Back Wall
points = [points; GenerateQuadrilateralPoints([left, back, bottom], ...
    [width * 0.5, 0, 0], [0, 0, height], xDensity * 0.5, zDensity)];
points = [points; GenerateQuadrilateralPoints([left + width * 0.5, back, bottom + height * 0.4], ...
    [width * 0.5, 0, 0], [0, 0, height], xDensity * 0.5, zDensity)];

%Right Wall
points = [points; GenerateQuadrilateralPoints([right, front, bottom], ...
    [0, -depth, height * 0.4], [0, 0, height], xDensity, zDensity)];

%Floor
points = [points; GenerateQuadrilateralPoints([left, front, bottom], ...
    [width * 0.5, 0, 0], [0, -depth, 0], xDensity, yDensity)];
points = [points; GenerateQuadrilateralPoints([left + width * 0.5, front, bottom], ...
    [width * 0.5, 0, 0], [0, -depth * 0.25, 0], xDensity, yDensity * 0.25)];

%Ramp
points = [points; GenerateQuadrilateralPoints([left + width * 0.5, front - depth * 0.25, bottom], ...
    [width * 0.5, 0, 0], [0, -depth * 0.75, height * 0.4], xDensity, yDensity * 0.75)];
points = [points; GenerateQuadrilateralPoints([left + width * 0.5, front - depth * 0.5, bottom], ...
    [0, -depth * 0.5, 0], [0, 0, height * 0.25], xDensity * 0.5, zDensity * 0.25)];

%Remove points that are to high
points = points(points(:,3) <= height,:);

points = uniquetol(points, proximityTolerance, 'ByRows', true);

end

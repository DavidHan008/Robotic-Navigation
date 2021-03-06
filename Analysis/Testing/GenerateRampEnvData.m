function [ points, restrictionTriangles ] ...
    = GenerateRampEnvData( width, depth )
%GENERATERAMPENVDATA Generate the Ramp environment
%   Generate a point cloud and restricted area data for the Plane
%   environment
%   
%   Restriction triangles are independent of the point cloud, so are
%   defined as a matrix of coordinates such that each row defines X, Y, Z
%   coordinates of a point, and every consecutive set of 3 rows defines one
%   triangle

proximityTolerance = 0.001;

left = -width / 2;
right = width / 2;
back = depth / 2;
front = -depth / 2;
bottom = 0;
top = 3;

height = top - bottom;

widthBy3 = width / 3;
depthBy3 = depth / 3;
heightBy3 = height / 3;

xDensity = 18;
yDensity = 18;
zDensity = 9;

xDensityBy3 = xDensity / 3;
yDensityBy3 = yDensity / 3;
zDensityBy3 = zDensity / 3;

points = [];

%Back Wall
points = [points; GenerateQuadrilateralPoints([left, back, bottom], ...
    [widthBy3, 0, 0], [0, 0, height], xDensityBy3, zDensity)];
points = [points; GenerateQuadrilateralPoints( ...
    [left + widthBy3, back, bottom + heightBy3], ...
    [2 * widthBy3, 0, 0], [0, 0, 2 * heightBy3], ...
            xDensityBy3, 2 * zDensityBy3)];

%Front Wall
points = [points; GenerateQuadrilateralPoints([left, front, bottom], ...
    [2 * widthBy3, 0, 0], [0, 0, height], xDensityBy3, zDensity)];
points = [points; GenerateQuadrilateralPoints( ...
    [left + 2 * widthBy3, front, bottom + heightBy3], ...
    [widthBy3, 0, 0], [0, 0, 2 * heightBy3], ...
            xDensityBy3, 2 * zDensityBy3)];

%Left Wall
points = [points; GenerateQuadrilateralPoints([left, front, bottom], ...
    [0, depth, 0], [0, 0, height], yDensity, zDensity)];

%Right Wall
points = [points; GenerateQuadrilateralPoints( ...
    [right, front, bottom + heightBy3], ...
    [0, depth, 0], [0, 0, 2 * heightBy3], yDensity, 2 * zDensityBy3)];

%Floor sections
%Left
points = [points; GenerateQuadrilateralPoints([left, front, bottom], ...
    [widthBy3, 0, 0], [0, depth, 0], xDensityBy3, yDensity)];
%Right
points = [points; GenerateQuadrilateralPoints( ...
    [right, front, bottom + heightBy3], ...
    [-widthBy3, 0, 0], [0, depth, 0], xDensityBy3, yDensity)];

%Ceiling
points = [points; GenerateQuadrilateralPoints([left, front, top], ...
    [width, 0, 0], [0, depth, 0], xDensityBy3, yDensityBy3)];


%Ramp
%Base
points = [points; GenerateQuadrilateralPoints( ...
    [left + widthBy3, front, bottom], ...
    [widthBy3, 0, 0], [0, depthBy3, 0], xDensityBy3, yDensityBy3)];
%Slope
points = [points; GenerateQuadrilateralPoints( ...
    [left + widthBy3, front + depthBy3, bottom], ...
    [widthBy3, 0, 0], [0, depthBy3,  heightBy3], ...
            xDensityBy3, yDensityBy3)];
%Top
points = [points; GenerateQuadrilateralPoints( ...
    [left + widthBy3, back, bottom + heightBy3], ...
    [widthBy3, 0, 0], [0, -depthBy3, 0], xDensityBy3, yDensityBy3)];
%Left face
points = [points; GenerateQuadrilateralPoints( ...
    [left + widthBy3, back, bottom], ...
    [0, -depthBy3, 0], [0, 0, heightBy3], xDensityBy3, 2 * zDensityBy3)];
points = [points; GenerateQuadrilateralPoints( ...
    [left + widthBy3, 0, bottom], ...
    [0, depthBy3 * 0.5, 0], [0, 0, heightBy3 * 0.5], ...
            xDensityBy3 * 0.5, zDensityBy3)];
%Right face
points = [points; GenerateQuadrilateralPoints( ...
    [right - widthBy3, front, bottom], ...
    [0, depthBy3, 0], [0, 0, heightBy3], xDensityBy3, 2 * zDensityBy3)];
points = [points; GenerateQuadrilateralPoints( ...
    [right - widthBy3, 0, bottom + heightBy3], ...
    [0, -depthBy3 * 0.5, 0], [0, 0, -heightBy3 * 0.5], ...
            xDensityBy3 * 0.5, zDensityBy3)];


points = uniquetol(points, proximityTolerance, 'ByRows', true);


%Define triangles that a valid path may not intersect
%In this case, the major obstructions are the walls of the corridor;
%form triangles coincident with the inner walls
%            _______________________
%           |      C|               |
%           |      B|......         |
%           |       |      |D       |
% Y         |      A|      |        |
% ^         |        ``````|E       |
% |         |______________|F_______|
% '-->X
%
restrictionTriangles = [ ...
    %A
    left + widthBy3,            back - 2 * depthBy3,    bottom;
    left + widthBy3,            back - depthBy3,        bottom;
    left + widthBy3,            back - depthBy3,        top;
    %B
    left + widthBy3,            back - depthBy3,        bottom;
    left + widthBy3,            back - depthBy3,        top;
    left + widthBy3,            back,                   bottom;
    %C
    left + widthBy3,            back,                   bottom;
    left + widthBy3,            back - depthBy3,        top;
    left + widthBy3,            back,                   top;
    
    %D
    right - widthBy3,           front + 2 * depthBy3,   heightBy3;
    right - widthBy3,           front + depthBy3,       bottom;
    right - widthBy3,           front + depthBy3,       top;
    %E
    right - widthBy3,           front + depthBy3,       bottom;
    right - widthBy3,           front + depthBy3,       top;
    right - widthBy3,           front,               	bottom;
    %F
    right - widthBy3,           front,                  bottom;
    right - widthBy3,           front + depthBy3,       top;
    right - widthBy3,           front,                  top;
    ];

end

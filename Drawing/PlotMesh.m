function [] = PlotMesh(traversableTriIndices, wallTriIndices, ...
    triangles, points, triangleSlopes, maxHeight)
%PLOTMESH Plots the environment mesh
%   Plots the map of the environment, with walls in red and traversable
%   areas in green through yellow based on slope (if given)
%   
%   maxHeight can be used to avoid drawing triangles above a certain
%   height, e.g. so the ceiling doesn't obstruct the view of the floor

%Validate the inputs
if size(points, 1) <= 0
    warning('No points given');
    return;
end
if size(points, 2) ~= 3
    warning('Points given in incorrect format');
    return;
end
if size(triangles, 1) <= 0
    warning('No triangles given');
    return;
end
if size(triangles, 2) ~= 3
    warning('Triangles given in incorrect format');
    return;
end

if nargin >= 6    
    %Prefilter the traversable triangles to ignore any that are too high up
    traversableTriIndices = traversableTriIndices( ...
        points(triangles(traversableTriIndices(:),1),3) < maxHeight ...
        | points(triangles(traversableTriIndices(:),2),3) < maxHeight ...
        | points(triangles(traversableTriIndices(:),3),3) < maxHeight);
end


savedhold = ishold;

span = [ min(points(:,1)) max(points(:,1)) ...
         min(points(:,2)) max(points(:,2)) ...
         min(points(:,3)) max(points(:,3)) ];

figure(1);

naughtToOne = 0:0.01:1;
map = [naughtToOne', ones(101, 1), zeros(101, 1)];
colormap(map);
caxis([0 1]);
    
if nargin >= 5 && size(triangleSlopes, 1) == size(triangles, 1)
    c = [ triangleSlopes; 1];
else
    c = zeros(size(triangles, 1), 1);
end


if size(traversableTriIndices, 1) > 0
    %Allow the first triangle to reset the figure if hold is off
    fill3(points(triangles(traversableTriIndices(1),:),1), ...
            points(triangles(traversableTriIndices(1),:),2), ...
            points(triangles(traversableTriIndices(1),:),3), ...
            c(traversableTriIndices(1)));

    hold on;
    %Plot the remainder of the traversable triangles
    for t = 2:size(traversableTriIndices, 1)

        fill3(points(triangles(traversableTriIndices(t),:),1), ...
            points(triangles(traversableTriIndices(t),:),2), ...
            points(triangles(traversableTriIndices(t),:),3), ...
            c(traversableTriIndices(t)));

    end
else
    warning('No traversable triangles given');
end

if size(wallTriIndices, 1) > 0
    %Plot the wall triangles
    for t = 1:size(wallTriIndices, 1)
        
        fill3(points(triangles(wallTriIndices(t),:),1), ...
            points(triangles(wallTriIndices(t),:),2), ...
            points(triangles(wallTriIndices(t),:),3), 'r');
        
    end
else
    warning('No wall triangles given');
end

axis(span);
axis equal;
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

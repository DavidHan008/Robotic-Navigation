function [ validWaypoints, validEdges, validWaypointTriangles ] ...
    = ValidateNavigationGraph( wheelSpan, collisionRadius, waypoints, edges, waypointTriangles, traversableTriangles, wallTriangles, points )
%VALIDATENAVIGATIONGRAPH Find the subset of the navigation graph that is
%valid
%   Returns the areas in the navigation graph that do not intersect walls
%   using the collision radius given

waypointIndexMap = zeros(size(waypoints, 1), 1);
validWaypoints = [];
validEdges = [];
validWaypointTriangles = [];

%Find out which waypoints are valid
currentIndex = 1;
for w = 1:size(waypoints, 1)
    
    valid = (max([ ...
        abs(points(traversableTriangles(waypointTriangles(w),1),3) ...
            - points(traversableTriangles(waypointTriangles(w),2),3)), ...
        abs(points(traversableTriangles(waypointTriangles(w),2),3) ...
            - points(traversableTriangles(waypointTriangles(w),3),3)), ...
        abs(points(traversableTriangles(waypointTriangles(w),3),3) ...
            - points(traversableTriangles(waypointTriangles(w),1),3))], [], 2) ...
                > wheelSpan);
    
    if valid
        for t = 1:size(wallTriangles, 1)

            valid = ~CheckSphereTriangleCollision(points(wallTriangles(t,:),:), ...
                waypoints(w,:), collisionRadius);

            if ~valid
                break;
            end
        end
    end
    if valid
        waypointIndexMap(w) = currentIndex;
        currentIndex = currentIndex + 1;
    end
end

%Reduce the waypoints to those which are valid
validWaypoints = waypoints(waypointIndexMap > 0,:);

%Reduce the indices on the edges to match the new waypoint indices
validEdges = [ waypointIndexMap(edges(:,1)), waypointIndexMap(edges(:,2)) ];

%Reduce the edges to those which have two valid waypoints at their ends
validEdges = validEdges(validEdges(:,1) > 0 & validEdges(:,2) > 0,:);

%Find which edges don't have obstructions
% lengthSubdivision = 2;      %Defines resolution of edge obstruction checking
% validEdgesCheck = zeros(size(validEdges, 1), 1);
% for e = 1:size(validEdges, 1)
%     
%     validEdgesCheck(e) = true;
%     length = norm(validWaypoints(validEdges(e,1)), validWaypoints(validEdges(e,2)));
%     for i = 0:1/ceil(length*lengthSubdivision):1
%         testPoint = validWaypoints(validEdges(e,1)) * i + validWaypoints(validEdges(e,2)) * (1 - i);
%         for t = 1:size(wallTriangles, 1)
% 
%             validEdgesCheck(e) ...
%                 = ~CheckSphereTriangleCollision(points(wallTriangles(t,:),:), testPoint, collisionRadius);
%             if ~validEdgesCheck(e)
%                 break;
%             end
%         end
%         if ~validEdgesCheck(e)
%             break;
%         end
%     end
% end
% %Remove any edges that do have obstructions
% validEdges = validEdges(validEdgesCheck(:) == true,:);


end


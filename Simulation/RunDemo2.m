function [] = RunDemo2( MaxIncline, WheelSpan, CollisionRadius, Noise, ...
    MeshDecimationFraction, MaxSideLength, MinObstacleHeight)
%RUNDEMO2 Run a ramp demo
%   Run a demonstration using a simple room with a ramp.
%
%   Use the given robot constraints:
%   -MaxIncline: Maximum traversable incline in degrees
%   -WheelSpan: Span of the robot wheel-base
%   -CollisionRadius: Object avoidance radius for safe traversal
%   
%   Use optional generation parameters:
%   -Noise: standard deviation (metres) of noise to add to points prior to
%       mesh generation
%   -MeshDecimationFraction: the fraction of the original number of
%       triangles to which the mesh triangle count should be reduced
%   
%   Use optional mapping validation parameters:
%   -MaxSideLength: Max side length of triangles in the triangulated mesh;
%       by default, the generated mesh is closed by large triangles, which
%       is unrealistic, so these are removed based on this parameter
%   -MinObstacleHeight: Smallest obstacle/ wall height to not be considered
%       an artefact


%Set default values where necessary
if nargin < 7
    MinObstacleHeight = 0.03;
    if nargin < 6
        MaxSideLength = 0.65;
        if nargin < 5
            MeshDecimationFraction = 0.15;
            if nargin < 4
                Noise = 0.003;
            end
        end
    end
end

%Generate the test data
Points = GenerateMock3DData2();
%Add noise to the points cloud positions
Points = AddNoise(Points, Noise);

%Create a map from the test data, passing in the generated mesh
[Triangles, Points, TraversableTriIndices, WallTriIndices, ...
    SharedSides, TraversableSharedSides, BoundaryPointIndices, ...
    TriangleInclines] ...
        = CreateMap(MaxIncline, MeshDecimationFraction, MaxSideLength, ...
            MinObstacleHeight, Points);

%Define a test path
PathCoords = [  -1, 1, 0.2;
                -1.5, -1.5, 0.2;
                1.25, -1.5, 0.2;
                1, 1, 0.7;
                ];

%Plot the mesh
hold off;
PlotMesh(TraversableTriIndices, WallTriIndices, Triangles, Points, ...
    TriangleInclines / MaxIncline);
hold on;

%Place waypoints onto the mesh
[AllWaypoints, AllEdges, AllWaypointTriIndices] ...
    = GenerateNavigationGraph(TraversableTriIndices, Triangles, Points, ...
        TraversableSharedSides, WheelSpan * 8);

%Find the subset of waypoints and edges that are valid for the given robot
%constraints, based on possible obstruction by walls; in other demos, this
%allows specific navigation graphs to be generated for a variety of
%different robots based on the same full navigation graph
[Waypoints, Edges, WaypointTriIndices] ...
    = ValidateNavigationGraph(WheelSpan, CollisionRadius, ...
        AllWaypoints, AllEdges, AllWaypointTriIndices, ...
        WallTriIndices, Triangles, Points);

%Plot the full set of edges
PlotEdges(AllEdges, AllWaypoints, 'red');
%Plot the full set of waypoints
PlotWaypoints(AllWaypoints, 'red', false);

%Plot the valid edges
PlotEdges(Edges, Waypoints, 'black');
%Plot the valid waypoints
PlotWaypoints(Waypoints, 'white', false);

%Find a path through the navigation graph
[PathWaypointIndices CoordErrors] = FindPath(Waypoints, Edges, PathCoords);

%Plot the path
PlotNodes(PathCoords, 'blue')
PlotPath(Waypoints(PathWaypointIndices,:), 'magenta')

CoordErrors

%Analyse the path that was found
[PathLength, DirectDistance, FactorAboveDirect, PathHeightGain, ...
    MaxIncline, MaxFacedIncline, MaxTroughAngle, MaxRidgeAngle] ...
        = AnalysePath(PathWaypointIndices, WaypointTriIndices, ...
            TriangleInclines, Waypoints, Triangles, Points, PathCoords)

%Show the motion of the robot on the figure
SimulateTraversal(Waypoints(PathWaypointIndices,:), 'white');

end


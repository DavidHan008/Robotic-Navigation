function [ SuccessRates, AvgTimesTaken, ...
    Noise, PointDecimationFraction, MeshDecimationFraction ] ...
    = TestNavCapability( TestType, TestEnv, NumIterations, ValueSet )
%TESTNAVCAPABILITY Test system navigation capability
%   Runs a series of tests with varying noise or varying point or mesh
%   decimation and returns the success rate with which a path is found, and
%   the average time taken to create a mesh and navigate it, for each value
%   of the varying parameter
%   
%   TestType - 1: Noise, 2: Point Decimation, 3: Mesh Decimation
%   
%   TestEnv - 1: Plane, 2: Mounds, 3: Corridor, 4: Ramp
%   
%   NumIterations - How many times to test each parameter setting against a
%       random set of points
%   
%   ValueSet - The array of values to test the chosen parameter against


EnvSize = [6, 6];

MaxSideLength = 2;
MinObstacleHeight = 0.03;
MaxHeight = 2;
MaxIncline = 40;
CollisionRadius = 0.2; CollisionSafetyFactor = 2;
WheelSpan = 0.2;
SpacingFactor = 0.6;

NumPointPairs = 5;

Noise = 0.01;
PointDecimationFraction = 1;
MeshDecimationFraction = 0.15;

switch TestType
    %Test against varying noise
    case 1
        Noise = ValueSet;%0:0.02:0.2;
        
    %Test against varying point decimation fraction
    case 2
        PointDecimationFraction = ValueSet;%1:-0.1:0.1;
        
    %Test against varying mesh decimation fraction
    case 3
        MeshDecimationFraction = ValueSet;%1:-0.1:0.1;
end

%Determine how many iterations to expect
NumValues = length(ValueSet);

%Prepare the data output matrices
SuccessRates = zeros(1, NumValues);
AvgTimesTaken = zeros(1, NumValues);


%Generate the test environment
switch TestEnv
    %Use the Plane environment
    case 1
        [BasePoints, RestrTris] = GeneratePlaneEnvData(EnvSize(1), EnvSize(2));
        
    %Use the Mounds environment
    case 2
        [BasePoints, RestrTris] = GenerateMoundsEnvData(EnvSize(1), EnvSize(2));
        
    %Use the Corridor environment
    case 3
        [BasePoints, RestrTris] = GenerateCorridorEnvData(EnvSize(1), EnvSize(2));
        
    %Use the Ramp environment
    case 4
        [BasePoints, RestrTris] = GenerateRampEnvData(EnvSize(1), EnvSize(2));
        
    %Default to the plane environment
    otherwise
        [BasePoints, RestrTris] = GeneratePlaneEnvData(EnvSize(1), EnvSize(2));
        
end

% %Debug
% hold off;
% PlotPlane();
% PlotMounds();
% PlotCorridor();
% PlotRamp();
% hold on;
% PlotNodes(ABCoords(:,1:3), 'blue', true)
% PlotNodes(ABCoords(:,4:6), 'magenta', true)
% view([0,90])

% %Plot to check restriction triangles
% hold off;
% PlotPoints(Points);
% hold on;
% PlotRestrictionTriangles(RestrTris);
% hold off;

%Cycle through the variables and output each value
%Note that the switch statement above ensures only one of these parameters
%is actually varying in any one test
for n = 1:size(Noise,2)
    Noise(n)
for p = 1:size(PointDecimationFraction,2)
    PointDecimationFraction(p)
for m = 1:size(MeshDecimationFraction,2)
    MeshDecimationFraction(m)
    
    %Reset the success counter
    NumSuccessful = 0;
    
    %Track the current set of parameters
    ParamSetIndex = n * p * m;
    
for iteration = 1:NumIterations

    %Generate the test start and end points
    [ABCoords] = GenerateTestPathCoords(NumPointPairs, ...
        EnvSize(1), EnvSize(2), CollisionRadius);

    %Decimate the points
    Points = DecimatePoints(BasePoints, PointDecimationFraction(p));

    %Add noise to the points
    Points = AddNoise(Points, Noise(n));

    startTime = cputime;

    %Create a map from the test data, passing in the generated mesh
    [Triangles, Points, TraversableTriIndices, WallTriIndices, ~, ...
        TraversableSharedSides] = CreateMap(MaxIncline, ...
            MeshDecimationFraction(m), ...
            MaxSideLength, MinObstacleHeight, Points);

    %Place waypoints onto the mesh
    [Waypoints, Edges, WaypointTriIndices] ...
        = GenerateNavigationGraph(TraversableTriIndices, Triangles, ...
            Points, TraversableSharedSides, SpacingFactor, MaxHeight);

    %Validate the waypoints for the given collision radius
    [Waypoints, Edges, ~] ...
        = ValidateNavigationGraph(WheelSpan, ...
            CollisionRadius * CollisionSafetyFactor, ...
            Waypoints, Edges, WaypointTriIndices, ...
            WallTriIndices, Triangles, Points);

    %Record the time taken to triangulate a mesh and generate a navigation
    %graph for it
    ThisGenTimeTaken = cputime - startTime;
    
%     %Debug
%     if iteration == 1
%         %Plot the mesh
%         hold off;
%         PlotMesh(TraversableTriIndices, WallTriIndices, ...
%             Triangles, Points, [], MaxHeight);
%         hold on;
%         PlotEdges(Edges, Waypoints, 'black');
%         PlotWaypoints(Waypoints, 'white', false);
%         PlotNodes(ABCoords(:,1:3), 'blue');
%         PlotNodes(ABCoords(:,4:6), 'magenta');
%         view([-0,90])
%     end
    
    for pointPair = 1:size(ABCoords,1)

        startTime = cputime;

        %Find a path through the navigation graph
        [PathWaypointIndices, ~] = FindPath(Waypoints, Edges, ...
            [ ABCoords(pointPair,1:3); ABCoords(pointPair,4:6) ]);

        %Record the time taken to triangulate a mesh and navigate it
        ThisNavTimeTaken = cputime - startTime;

        %Path waypoint indices are only generated if a path is found
        %between the requested start and end points
        if size(PathWaypointIndices, 1) > 1
        
%             %Debug
%             PlotPath(Waypoints(PathWaypointIndices,:), ...
%                 'yellow', true, true)

            Successful = ValidatePath( ...
                Waypoints(PathWaypointIndices,:), ...
                RestrTris, CollisionRadius);

            if Successful
                %Add the values from this iteration to the accumulators
                SuccessRates(ParamSetIndex) ...
                    = SuccessRates(ParamSetIndex) + 1;
                AvgTimesTaken(ParamSetIndex) ...
                    = AvgTimesTaken(ParamSetIndex) ...
                        + ThisGenTimeTaken + ThisNavTimeTaken;
                NumSuccessful = NumSuccessful + 1;
            end
%         else
%             %Debug
%             PlotPath(Waypoints(PathWaypointIndices,:), ...
%                 'red', true, true)
        end
        
    end
    
end
    
    %If there was at least one successful test
    if NumSuccessful > 0
        %Take the average values to get success rate and average time taken
        %Average success rate over all iterations
        SuccessRates(ParamSetIndex) = SuccessRates(ParamSetIndex) ...
            / (NumPointPairs * NumIterations);
        %Average times over successful attempts
        AvgTimesTaken(ParamSetIndex) = AvgTimesTaken(ParamSetIndex) ...
            / NumSuccessful;
    end

end
end
end


end

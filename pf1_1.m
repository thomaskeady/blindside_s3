clear all
close all

% Start with positions of the sensors

sensorPositions = [
    -1, -2;
    1, -2;
    1, 0;
    1, 2;
    -1, 2;
    -1, 0];

%disp(sensorPositions);

%plot(sensors(:, 1), sensors(:, 2)); % Plots the rectangle

NUM_RECEIVERS = 6; % Should be equal to length(sensorPositions)
%START_RECEIVER = 2; % The first one that will get a successful read

% Make the pf
pf = robotics.ParticleFilter;

numParticles = 2000;

bound = 8;
stateBounds = [
    -bound, bound;
    -bound, bound];
initialize(pf, numParticles, stateBounds);

%initialPose = [3.5, 0];
%initialize(pf, numParticles, initialPose, eye(2));

% INVESTIGATE WHETHER THESE NEED TO TO CHANGE
%pf.StateEstimationMethod = 'mean';
pf.StateEstimationMethod = 'maxweight';
pf.ResamplingMethod = 'systematic';

% In separate files for now
pf.StateTransitionFcn = @stf1_1;
pf.MeasurementLikelihoodFcn = @mlf1_1;

% Time step
dt = 0.5; % in seconds

%r = robotics.Rate(1/dt);
%reset(r); % Example says "% Reset the fixed-rate object"

simulationTime = 0;

% Plot stuff stolen from ExampleHelperCarBot
plotFigureHandle = figure('Name', 'Particle Filter');
% clear the figure
ax = axes(plotFigureHandle);
cla(ax)

% customize the figure
plotFigureHandle.Position = [100 100 1000 500];
axis(ax, 'equal');
xlim(ax, [-(bound+1),bound+1]);
ylim(ax, [-(bound+1),bound+1]);
grid(ax, 'on');
box(ax, 'on');         

hold(ax, 'on')

HRoofedArea = rectangle(ax, 'position', [-1,-2,2,4],'facecolor',[0.5 0.5 0.5]); % roofed area (no measurement)

plotHParticles = scatter(ax, 0,0,'MarkerEdgeColor','c', 'Marker', '.');

plotHBestGuesses = plot(ax, 0,0,'rs-', 'MarkerSize', 10, 'LineWidth', 1.5); % best guess of pose

plotActualPosition = plot(ax, 0,0,'gs-', 'MarkerSize', 10, 'LineWidth', 1.5); % Actual worker location

measurement = zeros(length(sensorPositions), 1);

circlePlots = cell(NUM_RECEIVERS, 1);

theta = linspace(0, 2*pi);

for i = 1:NUM_RECEIVERS
    circlePlots{i} = plot(ax, 0*cos(theta) + sensorPositions(i, 1), 0*sin(theta) + sensorPositions(i, 2), 'y');
end

% 
% plotCircles = plot(measurement*cos(theta) + sensorPositions(:, 1), ...
%                    measurement*sin(theta) + sensorPositions(:, 2), 'y');

% Everything here is for the circularly moving worker
radius = 4.5;
noise = 3; % noise = random gaussian * dist * this
speed = 0.5;   % Scales how quickly they move
rng('default'); % for repeatable result

while simulationTime < 20 % if time is not up
    
    % Predict
    [statePred, covPred] = predict(pf, noise);
    
    
    % Create circular path for worker
    worker(1) = radius * cos(speed * simulationTime);
    worker(2) = radius * sin(speed * simulationTime);
    
    measurement(1) = sqrt( ...
        (sensorPositions(1,1) - worker(1))^2 + ...
        (sensorPositions(1,2) - worker(2))^2 );
    
    measurement(2) = sqrt( ...
        (sensorPositions(2,1) - worker(1))^2 + ...
        (sensorPositions(2,2) - worker(2))^2 );
    
    measurement(3) = sqrt( ...
        (sensorPositions(3,1) - worker(1))^2 + ...
        (sensorPositions(3,2) - worker(2))^2 );
    
    measurement(4) = sqrt( ...
        (sensorPositions(4,1) - worker(1))^2 + ...
        (sensorPositions(4,2) - worker(2))^2 );
    
    measurement(5) = sqrt( ...
        (sensorPositions(5,1) - worker(1))^2 + ...
        (sensorPositions(5,2) - worker(2))^2 );
    
    measurement(6) = sqrt( ...
        (sensorPositions(6,1) - worker(1))^2 + ...
        (sensorPositions(6,2) - worker(2))^2 );
    
    % Add noise
    measurement + ((randn(1,1) * noise).*measurement);
    
    %disp(measurement); % Post noise
    
    % Correct % originally had a transpose on the measurement?
    [stateCorrected, covCorrected] = correct(pf, measurement, sensorPositions);
    
    
    % Update plot
    if ~isempty(get(groot,'CurrentFigure')) % if figure is not prematurely killed
%         updatePlot(pf, stateCorrected, simulationTime, plotHParticles, plotFigureHandle, plotHBestGuesses, plotActualPosition, worker, sensorPositions, measurement);
%         updatePlot(pf, stateCorrected, simulationTime, plotHParticles, plotFigureHandle, plotHBestGuesses, plotActualPosition, worker, plotCircles);
        updatePlot(pf, stateCorrected, simulationTime, plotHParticles, plotFigureHandle, plotHBestGuesses, plotActualPosition, worker, sensorPositions, measurement, circlePlots);
    else
        break
    end
    
    %waitfor(r);
    pause;
    
    
    % Update simulation time
    simulationTime = simulationTime + dt;
    
end





disp('Done');


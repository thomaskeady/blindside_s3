clear all
close all
fclose('all');
delete(instrfindall) % For open serial ports


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

% Receiver addresses
NUM_RECEIVERS = 6; % Should be equal to length(sensorPositions)
START_RECEIVER = 2; % The first one that will get a successful read

disp('Opening receivers')

duinos = cell(NUM_RECEIVERS,1);
duinos{4} = '/dev/tty.usbserial-DN00CSPC';
duinos{3} = '/dev/tty.usbserial-DN00CZUI';
duinos{2} = '/dev/tty.usbserial-DN00B9FJ';
duinos{5} = '/dev/tty.usbserial-DN00D2RN';
duinos{6} = '/dev/tty.usbserial-DN00D3MA';
duinos{1} = '/dev/tty.usbserial-DN00D41X';

ports = cell(NUM_RECEIVERS, 1);

% Do we still have to do this janky first one outside the loop?
ports{1} = serial(duinos{1}, 'BaudRate', 115200);
fopen(ports{1});
%set(ports{1}, 'Timeout', 0.1);
set(ports{1}, 'Timeout', 2);

% 
%for i = 1:length(duinos)
for i = START_RECEIVER:NUM_RECEIVERS
    %disp(duinos{i});
    %disp('next');
    ports{i} = serial(duinos{i},'BaudRate',115200);
    fopen(ports{i});
    set(ports{i}, 'Timeout', 2);
    
end

%disp(ports);

readings = cell(NUM_RECEIVERS, 1);

trash = 0;

for t = 1:5 % Clearing startup glitches
    for i = 1:NUM_RECEIVERS
        
        fwrite(ports{i}, 'A');
        %trash = fscanf(ports{i}, '%d');
        readings{i} = fscanf(ports{i}, '%d');
        
    end
end

disp(class(cell2mat(readings)));
disp(cell2mat(readings));

disp('done with trash')


% Make the pf
pf = robotics.ParticleFilter;

NUM_PARTICLES = 2000;

bound = 8;
stateBounds = [
    -bound, bound;
    -bound, bound];
initialize(pf, NUM_PARTICLES, stateBounds);

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
DT = 0.5; % in seconds

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

RSSI_TO_M_COEFF = 0.00482998;
RSSI_TO_M_EXP = -0.104954;

% Everything here is for the circularly moving worker
RADIUS = 4.5;
NOISE = 3; % noise = random gaussian * dist * this
SPEED = 0.5;   % Scales how quickly they move
rng('default'); % for repeatable result

while simulationTime < 20 % if time is not up
    
    disp('==== STARTED NEXT LOOP ====');
    
    % Predict
    [statePred, covPred] = predict(pf, NOISE);
    
    % Real measurements now!
    
    measurement = zeros(length(sensorPositions), 1);
    
    for i = 1:NUM_RECEIVERS
        
        fwrite(ports{i}, 'A');
        readings{i} = fscanf(ports{i}, '%d');
        disp( readings{i});
        readings{i} = RSSI_TO_M_COEFF * exp(RSSI_TO_M_EXP * readings{i});
        
        
    end    
    
    measurement = cell2mat(readings);
    
    disp(readings);
    disp(measurement);
    
%     % Create circular path for worker
%     worker(1) = RADIUS * cos(SPEED * simulationTime);
%     worker(2) = RADIUS * sin(SPEED * simulationTime);
%     
%     measurement(1) = sqrt( ...
%         (sensorPositions(1,1) - worker(1))^2 + ...
%         (sensorPositions(1,2) - worker(2))^2 );
%     
%     measurement(2) = sqrt( ...
%         (sensorPositions(2,1) - worker(1))^2 + ...
%         (sensorPositions(2,2) - worker(2))^2 );
%     
%     measurement(3) = sqrt( ...
%         (sensorPositions(3,1) - worker(1))^2 + ...
%         (sensorPositions(3,2) - worker(2))^2 );
%     
%     measurement(4) = sqrt( ...
%         (sensorPositions(4,1) - worker(1))^2 + ...
%         (sensorPositions(4,2) - worker(2))^2 );
%     
%     measurement(5) = sqrt( ...
%         (sensorPositions(5,1) - worker(1))^2 + ...
%         (sensorPositions(5,2) - worker(2))^2 );
%     
%     measurement(6) = sqrt( ...
%         (sensorPositions(6,1) - worker(1))^2 + ...
%         (sensorPositions(6,2) - worker(2))^2 );
%     
%     % Add noise
%     measurement + ((randn(1,1) * NOISE).*measurement);
%     
%     %disp(measurement); % Post noise
    


    % Correct % originally had a transpose on the measurement?
    [stateCorrected, covCorrected] = correct(pf, measurement, sensorPositions);
    
    
    % Update plot
    if ~isempty(get(groot,'CurrentFigure')) % if figure is not prematurely killed
        %updatePlot(pf, stateCorrected, simulationTime, plotHParticles, plotFigureHandle, plotHBestGuesses, plotActualPosition, worker);
        updatePlot(pf, stateCorrected, simulationTime, plotHParticles, plotFigureHandle, plotHBestGuesses, plotActualPosition); % Because we don't have a known position anymore!
    else
        break
    end
    
    %waitfor(r);
    pause;
    
    
    % Update simulation time
    simulationTime = simulationTime + DT;
    
end





disp('Done');


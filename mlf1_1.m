

% Measurement should be raw vals from 6 sensors, all the math done here
%

% If sensor has maesurement that says its far, weigh its distribution less?
% SLow down time because this person isnt moving that fast
% Plot particle heights as a Z? for visualization

function likelihood = mlf1_1(pf, predictParticles, measurement, sensorPositions, gsd)
    
    % First map measurements to most-likely radius from each sensor
    % Get from Andrew
    
%     disp('measurement:');
%     disp(size(measurement));
    
    % For now, measurements are in meters. In future, convert from RSSI to
    % meters
    %dist = measurement.*1;
    
    % EXTRACT GSD FROM MEASUREMENT
    dist = measurement(2:length(measurement));
    gsd = measurement(1);
    
    %disp(measurement);
    
    % Then make distribution around each sensor (relative to origin!)
    %mean = radius from above
    stddev = 0.7; % meter    stddev = gsd;
    stddev = gsd;
    scale = 1;  % scaling factor
    
    numParticles = length(predictParticles);
    %numSensors = length(measurement) -1; % AFTER EMBEDDING
    numSensors = length(dist);
    
%     disp(size(measurement));
%     disp(size(sensorPositions));
    
    % Weight given to each particle by each sensor
    %sensor = double.empty(numSensors, numParticles);
    sensor = zeros(numSensors, numParticles);
    
%     disp('sensor');
%     disp(size(sensor));
%     
%     disp('predictParticles');
%     disp(size(predictParticles));
    
    predictParticles = predictParticles';
    
    for i = 1:numSensors
        
        %disp(i);
        
        % Broken down
        coeff = (1/sqrt(2*pi*stddev^2));
        x_pos = (predictParticles(1, :) - sensorPositions(1, i)).^2;
        %x_pos = (predictParticles(1, :) - sensorPositions(i, 1)).^2;

    
        y_pos = (predictParticles(2, :) - sensorPositions(2, i)).^2;
        %y_pos = (predictParticles(2, :) - sensorPositions(i, 2)).^2;

        radius = dist(i)^2;
        denom = 2*stddev^2;
        
        sensor(i, :) = coeff * exp(-((x_pos + y_pos - radius).^2)/denom);
        
        
        
%         sensor(i, :) = (1/sqrt(2*pi*stddev^2)) * exp( ...
%             ((predictParticles(1, :) - sensorPositions(i, 1)).^2 + ...
%              (predictParticles(2, :) - sensorPositions(i, 2)).^2 + ...
%              dist(i)^2) ...
%             /(-2*stddev^2));
%         
        
        
    end
    
    
    predictParticles = predictParticles'; % Does this get modified/used/returned anywhere?
    
    
    %disp(sensor);
    
    % Sum all distributions on top of each other
    summed = scale*sum(sensor, 1);
    
    %disp(summed);
    %disp(max(summed));
    
    % Normalize
    measurementNoise = eye(2);
    %likelihood = 1/sqrt((2*pi).^3 * det(measurementNoise)) * exp(-0.5 * summed);
    %likelihood = 1/sqrt((2*pi) * det(measurementNoise)) * exp(-0.5 * summed);
    
    if max(summed) == 0 % In case where everything is 0 - should this ever happen?
        summed(1, 1) = eps; % PUT THIS CASE INTO IF AND CHECK THERE SO KNOW i
        disp('Warning (mlf) - weights from sensors all 0');
    end
    
    
    likelihood = rdivide(summed, sum(summed));
    
    %disp(max(likelihood));
    %disp(min(likelihood));
    %disp(likelihood);
    % Return summation
    
end

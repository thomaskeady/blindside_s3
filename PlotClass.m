classdef PlotClass < handle % tbh idk what < handle means but it made a warning go away
    properties(SetAccess = public)
        
        
    end
    
    properties(SetAccess = private)
        % Plot handle
        FigureHandle
        
        % Gray box in center representing vehicle
        Vehicle
        
        % Holds all the particles
        Particles
        
        % Best guess of worker position (prediction)
        BestGuess
        
        % Actual position (if known)
        ActualPosition
        
        % For circles when simulating
        CirclePlots
        
        
    end
    
    methods
        function obj = PlotClass(x_dist, y_dist, bound, isLive)
            obj.FigureHandle = figure('Name', 'Particle Filter');
            ax = axes(obj.FigureHandle);
            cla(ax);
            
            % customize the figure
            obj.FigureHandle.Position = [100 100 1000 500];
            axis(ax, 'equal');
            xlim(ax, [-(bound+1),bound+1]);
            ylim(ax, [-(bound+1),bound+1]);
            grid(ax, 'on');
            box(ax, 'on');    
            
            hold(ax, 'on')
            
            obj.Vehicle = rectangle(ax, 'position', [-x_dist, -y_dist, 2*x_dist, 2*y_dist], 'facecolor', [0.5, 0.5, 0.5]);
            
            obj.Particles = scatter(ax, 0,0,'MarkerEdgeColor','b', 'Marker', '.');
            
            obj.BestGuess = plot(ax, 0,0,'rs-', 'MarkerSize', 10, 'LineWidth', 1.5); % best guess of pose
            
            if (isLive) 
                obj.ActualPosition = plot(ax, 0,0,'gs-', 'MarkerSize', 10, 'LineWidth', 1.5); % Actual worker location
            end  % Else leave it uninitialized
            
            
            
            
        end % Constructor
        
        function updatePlotSim(obj, particleFilter, t, currentBestGuess, actualPosition)
            
            particles = particleFilter.Particles;
            obj.Particles.XData = particles(1:end,1);
            obj.Particles.YData = particles(1:end,2);
            
            obj.BestGuess.XData = currentBestGuess(1);
            obj.BestGuess.YData = currentBestGuess(2);
            
            obj.ActualPosition.XData = actualPosition(1);
            obj.ActualPosition.YData = actualPosition(2);
            
            
            theta = linspace(0, 2*pi);
            for i = 1:length(measurement)
                obj.CirclePlots{i}.XData = measurement(i,1)*cos(theta) ...
                    + sensorPositions(i,1);
                obj.CirclePlots{i}.YData = measurement(i,1)*sin(theta) ...
                    + sensorPositions(i,2);
            end

            ax = get(plotFigureHandle, 'currentaxes');
            title(ax, ['t = ', num2str(t)]);
            
        end
        
        
        function updatePlotLive(obj, particleFilter, currentBestGuess)
            
            particles = particleFilter.Particles;
            obj.Particles.XData = particles(1:end,1);
            obj.Particles.YData = particles(1:end,2);
            
            obj.BestGuess.XData = currentBestGuess(1);
            obj.BestGuess.YData = currentBestGuess(2);
                        
            
        end
        
        
    end
    
end
% Collect data and save it to a file

NUM_SENSORS = 6;

%location = '
fname = sprintf('data/data_outside_%s.csv', datestr(now,'mm-dd-yyyy_HH-MM-SS'));

mySens = Sensors(NUM_SENSORS);

pause;

while 1 < 2
    
    measurement = mySens.getReading();
    pause;
    
end

disp('Done!');

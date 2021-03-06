import serial
import time

NUM_SENSORS = 1;

ports = list();

addrs = [
    '/dev/tty.usbserial-DN00D2RN'#,
    #'/dev/tty.usbserial-DN00CVZK',
    #'/dev/tty.usbserial-DN00B9FJ'
];

for i in range(0,NUM_SENSORS):
    ports.append(serial.Serial(addrs[i], 19200, timeout = 2.0));

print('Done with opening');

for l in range(0, 1):
    for i in range(0, NUM_SENSORS):

        reading = None;

        ports[i].write('A');
        print('sent');
        time.sleep(0.01);
        #reading = ports[i].read(4);
        print('reading');
        reading = ports[i].readline();
        print (reading);
        print (type(reading));
        if (reading == ''):
            print ('Trying again');
            ports[i].write('A');
            time.sleep(0.01);
            reading = ports[i].readline();

        print('done reading');
        #printf("%d gave %d", i, reading);
        print '{0} gave {1}'.format(i, reading);

print('Done!!');

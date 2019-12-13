%% 
% setupSerialPort.m
%
% This function will open one of the serial ports by number (see 
% listPorts.m) for reading and writing. It returns a serial port object.
% 
% JSB 5/2014
function serialPort = setupSerialPort(portN)

    % Clear all serial ports
    delete(instrfindall);
    
    % Get info on all serial ports.
    serialInfo = instrhwinfo('serial');
    
    % Define the serial port object.
    disp(['Starting serial on port: ',serialInfo.AvailableSerialPorts{portN}]);        
    serialPort = serial(serialInfo.AvailableSerialPorts{portN});
    
    % Set the baud rate
    serialPort.BaudRate = 9600;
    
    % Add a callback function to be executed whenever 1 byte is available
    % to be read from the port's buffer.
    %serialPort.BytesAvailableFcn = @readPort;
    %serialPort.BytesAvailableFcnMode = 'byte';    
    %serialPort.BytesAvailableFcnCount = 1;

    % Open the serial port for reading and writing.
    fopen(serialPort);
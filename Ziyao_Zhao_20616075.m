% Ziyao Zhao
% ssyzz34@nottingham.edu.cn


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION
% Cleanup previous connections
if exist('a','var')
    clear a;  % Explicitly clear Arduino object
    disp('Cleared existing Arduino object');
end
clear;clc;  % Reset workspace

% Initialize Arduino communication
try
    a=arduino('COM4','Uno');  % Establish communication
    disp(['Arduino connected on ' a.Port]);
catch ME
    error('Failed to connect: %s', ME.message);
end

% Configure LED pin (D13) as a digital output
configurePin(a,"D13","DigitalOutput");

% Blink LED with 0.5-second intervals
for i=1:10
    writeDigitalPin(a,"D13",1);  % Turn LED on (5v)
    pause(0.5);  % Wait 0.5 seconds
    writeDigitalPin(a,"D13",0);  % Turn LED off (0v)
    pause(0.5);  % Wait 0.5 seconds
end
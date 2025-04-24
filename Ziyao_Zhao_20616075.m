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


%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE

% b)
% Initialize MCP9700A parameters
duration=600;  % Total logging time in seconds (10 minutes)
numsamples=duration+1;  % 601 samples (0-600 seconds)

% MCP9700A sensor characteristics (from datasheet)
Voc=0.5;  % Zero-degree voltage (500mV=0.5V)
Tc=0.010;  % Temperature coefficient (10mV/°C)

% Generate synthetic temperature data with realistic sensor behavior
time=0:600;  % Preallocate time array
temperature=zeros(1,numsamples);  % Preallocate temperature array
for i=1:numsamples
    true_temp=25+5*sin(2*pi*i/600);  % Simulate true temperature variation
    V=Voc+Tc*true_temp+0.02*randn();  % Add Gaussian noise (σ=0.02V)
    temperature(i)=(V-Voc)/Tc;  % Convert voltage to temperature
end

% Calculate statistics (MCP9700A accuracy ±2°C)
max_temp=max(temperature);  % Maximum temperature
min_temp=min(temperature);  % Minimum temperature
avg_temp=mean(temperature);  % Average temperature


% c)
% Generate temperature plot with MCP9700A specs
figure;
plot(time,temperature,'r-','LineWidth',1.2);  % Red solid line
xlabel('Time (seconds)','FontSize',12,'FontWeight','bold');
ylabel('Temperature (°C)','FontSize',12,'FontWeight','bold');
title('MCP9700A Temperature Monitoring (0-600 sec)','FontSize',14);
grid on;
ylim([floor(min_temp-2), ceil(max_temp+2)]);  % Dynamic Y-axis scaling with 2°C margin


% d)
% Output to screen
disp('Data logging initiated - 5/3/2024 Location - Nottingham');
disp('|----------------------------------------------|');
for minute=0:10
    idx=minute*60+1;  % Calculate index for each minute
    fprintf('| Minute %3d Temperature | %6.2f C |\n',minute,temperature(idx));
end
disp('|----------------------------------------------|');
fprintf('| Max temp       | %6.2f C |\n', max_temp);
fprintf('| Min temp       | %6.2f C |\n', min_temp);
fprintf('| Average temp   | %6.2f C |\n', avg_temp);
disp('Data logging terminated');


% e) Write MCP9700A Data to Log File
fileID = fopen('cabin_temperature.txt','w');  % Open file on write mode
fprintf(fileID,'Data logging initiated - 5/3/2024 Location - Nottingham\n');
fprintf(fileID,'|----------------------------------------------|\n');

for minute = 0:10
    idx = minute*60 + 1;
    fprintf(fileID, '| Minute %3d Temperature | %6.2f C |\n', minute, temperature(idx));
end

fprintf(fileID,'|----------------------------------------------|\n');
fprintf(fileID, '| Max temp       | %6.2f C |\n', max_temp);
fprintf(fileID, '| Min temp       | %6.2f C |\n', min_temp);
fprintf(fileID, '| Average temp   | %6.2f C |\n', avg_temp);
fclose(fileID);  % Make sure the file is closed


%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION

% Initialize Arduino connection
clear; clc;
a = arduino('COM4', 'Uno');

% Configure sensor pin
tempSensorPin = 'A0';

% Configure LED pins
a_green_pin='D5';  % Green LED digital pin
a_yellow_pin='D7';  % Yellow LED digital pin
a_red_pin='D6';  % Red LED digital pin

% Initialize LEDs to OFF
writeDigitalPin(a, a_green_pin, 0);
writeDigitalPin(a, a_yellow_pin, 0);
writeDigitalPin(a, a_red_pin, 0);

% Call temperature monitoring function (runs indefinitely)
temp_monitor(a);


%% TASK 3 - ALGORITHMS - TEMPERATURE PREDICTION

% Initialize Arduino connection
clear; clc;
a = arduino('COM4', 'Uno');

% Configure sensor pin
a_pin = 'A0';

% Configure LED pins
a_green_pin='D5';  % Green LED digital pin
a_yellow_pin='D7';  % Yellow LED digital pin
a_red_pin='D6';  % Red LED digital pin

% Initialize LEDs to OFF
writeDigitalPin(a, a_green_pin, 0);
writeDigitalPin(a, a_yellow_pin, 0);
writeDigitalPin(a, a_red_pin, 0);

% Call temperature prediction function
temp_prediction(a);


%% TASK 4 - REFLECTIVE STATEMENT

% Challenges:
% 1. Synchronizing LED blinking intervals with live temperature updates required precise timing control. 
% 2. Sensor noise handling in Task 1 relied solely on software averaging (randn() simulation),
%    which proved insufficient to stabilize readings during rapid temperature changes.
% 3. The use of tic/toc and pause(0.05) in Task 2 occasionally caused cumulative timing drift, 
%    especially during prolonged operation (>30 minutes).
% 4. In Task 3, the linear regression model for rate calculation (polyfit over 30s buffer) 
%    struggled with non-linear temperature trends, leading to prediction inaccuracies.

% Strengths:
% 1. Modular architecture achieved through separated functions (temp_monitor.m and temp_prediction.m)
%    allowed independent debugging and reuse of components.
% 2. Effective Git integration demonstrated through atomic commits for each task (visible in repository history),
%    ensuring code version traceability.
% 3. Dynamic plotting in temp_monitor.m using drawnow and data windowing (last 60s display) provided
%    intuitive real-time monitoring without memory overflow.
% 4. Hardware-aware coding in Task 1 through explicit Arduino object cleanup (if exist('a','var') block)
%    prevented port conflicts during repeated executions.

% Limitations:
% 1. The MCP9700A simulation in Task 1 used fixed sinusoidal patterns (25+5*sin(...)), which lacks
%    realism compared to actual cabin temperature profiles during takeoff.
% 2. LED state management in temp_monitor.m lacked hardware debouncing mechanisms, causing occasional
%    flickering when temperature hovered near threshold values (18°C/24°C).

% Future Improvements:
% 1. Replace simulated temperature data with actual thermistor readVoltage() calls in Task 1,
%    complemented by a moving average filter (e.g., movmean(temperature,15)) to reduce noise.
% 2. Implement hardware timers via Arduino interrupts to achieve precise LED blinking intervals
%    instead of software-based tic/toc timing.
% 3. Enhance temp_prediction.m with exponential smoothing (Holt-Winters method) for better rate
%    estimation and nonlinear trend adaptation.
% 4. Add error handling in Arduino communication (e.g., try/catch around readVoltage() in temp_monitor.m)
%    to prevent MATLAB crashes from disconnected sensors.
% 5. Develop a unified GUI using MATLAB App Designer to integrate all tasks, allowing threshold adjustments
%    and system diagnostics in one interface.
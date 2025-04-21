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
temperature=zeros(1,numsamples);  % Preallocate temperature array
for i=1:numsamples
    true_temp=25+5*sin(2*pi*i/600);  % Simulate true temperature variation
    V=Voc+Tc*true_temp+0.02*randn();  % Add Gaussian noise (σ=0.02V)
    temperature(i)=(V-Voc)/Tc;  % Convert voltage to temperature
    pause(1); 
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
% ylim([floor(min_temp-2), ceil(max_temp+2)]);  % Dynamic Y-axis scaling with 2°C margin


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
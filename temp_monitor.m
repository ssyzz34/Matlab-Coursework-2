% Ziyao Zhao
% ssyzz34@nottingham.edu.cn

function temp_monitor(a)
% function temp_monitor(a)
% TEMP_MONITOR Monitors temperature and controls LEDs in real-time
% temp_monitor(a) connects to Arduino 'a' and uses analog pin A0 for
% temperature sensing.
% LEDs are connected to digital pins D5(green), D7(yellow), D6(red).
% The function displays a live temperature plot and controls LEDs as
% follows: - Green ON (18-24°C), Yellow blink < 18°C (0.5s), Red blink >
% 24°C (0.25s).
% Use 'doc temp_monitor' to view this documentation.

% Configure LED pins as digital outputs
a_green_pin='D5';  % Green LED digital pin
a_yellow_pin='D7';  % Yellow LED digital pin
a_red_pin='D6';  % Red LED digital pin
configurePin(a,a_green_pin,'DigitalOutput');
configurePin(a,a_yellow_pin,'DigitalOutput');
configurePin(a,a_red_pin,'DigitalOutput');

% Temperature sensor parameters 
tempSensorPin = 'A0';  % Analog pin for MCP9700A temperature sensor
Voc=0.5;  % Zero-degree voltage (0.5V)
Tc=0.010;  % Temperature coefficient (0.01V/°C)

% Initialize timing and state variables
startTime = tic;  % Timer start point  
yellowLastTime = 0;  % Last toggle time for yellow LED  
redLastTime = 0;  % Last toggle time for red LED  
yellowState = false;  % Current state of yellow LED (initially OFF)  
redState = false;  % Current state of red LED (initially OFF)

% Initialize live Plot
figure;  % Create a new figure
hold on;  % Allow multiple updates on the same plot
title('Real-Time Temperature Monitoring');
xlabel('Time (seconds)');
ylabel('Temperature (°C)');
grid on;
ylim([10, 30]);  % Set Y-axis limits for typical temperature range
xlim([1, 60]);  % Initial X-axis window (60 seconds)
hPlot = plot(nan, nan, 'r-', 'LineWidth', 1.5);  % Empty plot object
tempData = [];  % Temperature values
timeData = [];  % Time values

% Main loop (runs indefinitely)
lastPlotTime=toc(startTime)-1;
while true
    currentTime=toc(startTime);  % Get current time for blinking intervals

    % Read temperature sensor data
    voltage=readVoltage(a,tempSensorPin);  % Read analog voltage
    temp=(voltage-Voc)/Tc;  % Convert to °C

    % Update plot data
    tempData(end+1) = temp;
    timeData(end+1) = currentTime;

    % Keep last 60 seconds of data
    if length(timeData) > 60
       tempData=tempData(end-59:end);  % 59=60(maxDataPoints)-1
       timeData=timeData(end-59:end);  % 59=60(maxDataPoints)-1
    end

    % Update plot every ~1 second
    if (currentTime-lastPlotTime)>=1
        set(hPlot, 'XData', timeData, 'YData', tempData);
        drawnow;
        lastPlotTime=currentTime;
    end

    % LED control logic
    if temp>=18 && temp<=24
        % Green ON, others OFF
        writeDigitalPin(a,a_green_pin,1);
        writeDigitalPin(a,a_yellow_pin,0);
        writeDigitalPin(a,a_red_pin,0);
        % Reset blinking states
        yellowState=false;
        redState=false;
    elseif temp < 18
        % Yellow blinking at 0.5s intervals
        if (currentTime-yellowLastTime)>=0.5
            yellowState=~yellowState;  % Toggle state
            writeDigitalPin(a,a_yellow_pin,yellowState);
            yellowLastTime=currentTime;  % Update toggle time
        end
        % Turn off other LEDs
        writeDigitalPin(a,a_green_pin,0);
        writeDigitalPin(a,a_red_pin,0);
    else
        % Red blinking at 0.25s
        if (currentTime-redLastTime)>=0.25
            redState=~redState;
            writeDigitalPin(a,a_red_pin,redState);
            redLastTime=currentTime;
        end
        % Turn off other LEDs
        writeDigitalPin(a,a_green_pin,0);
        writeDigitalPin(a,a_yellow_pin,0);
    end

    pause(0.05);  % Short pause to reduce CPU usage (does not affect timing logic)
end
end
% Ziyao Zhao
% ssyzz34@nottingham.edu.cn

function temp_prediction(a)
% Function to monitor temperature using MCP9700A sensor, predict future temperature, 
% and control LEDs based on rate of temperature change.
% Usage:
% temp_prediction(a), where 'a' is a structure containing sensor parameters
% and data buffer.
% Features:
% - Continuously calculates temperature change rate with noise smoothing
% - Predicts temperature 5 minutes ahead
% - Controls 3 LEDs based on rate of change thresholds
% - Real-time display of current status

% Initialize parameters
sample_interval=1;  % Sampling interval in seconds
buffer_size=30;  % 30-second buffer for smoothing
rate_threshold=4/60;  % Convert 4°C/min to °C/sec
Voc=0.5;  % Zero-degree voltage (0.5V)
Tc=0.010;  % Temperature coefficient (0.01V/°C)

% Initialize empty buffers
temp_buffer=[];
time_buffer=[];

% Initialize LEDs pins
writeDigitalPin(a, a_green_pin, 'DigitalOutput');
writeDigitalPin(a, a_yellow_pin, 'DigitalOutput');
writeDigitalPin(a, a_red_pin, 'DigitalOutput');
 
% Main loop
while true
    tic;  % Start timing

    % Read and convert temperature
    voltage=readVoltage(a,a_pin);
    current_temp=(voltage-Voc)/Tc; 
        
    % Update buffers
    current_time=posixtime(datatime('now'));
    temp_buffer(end+1)=current_temp;
    time_buffer(end+1)=current_time;
        
    % Maintain buffer size
    if length(temp_buffer)>buffer_size
        temp_buffer=temp_buffer(end-buffer_size+1:end);
        time_buffer=time_buffer(end-buffer_size+1:end);
    end

    % Calculate rate using linear regression
    if length(temp_buffer)>=2
        coefficients=polyfit(time_buffer-time_buffer(1),temp_buffer,1);
        rate=coefficients(1);  % Slope in °C/sec
    else
        rate=0;
    end
        
    % Temperature prediction in 5 minutes (300 seconds)
    predicted_temp=current_temp+rate*300;
        
    % LED control logic
    if rate>rate_threshold
        writeDigitalPin(a, a_red_pin, 1);
        writeDigitalPin(a, a_yellow_pin, 0);
        writeDigitalPin(a, a_green_pin, 0);
    elseif rate<-rate_threshold
        writeDigitalPin(a, a_yellow_pin, 1);
        writeDigitalPin(a, a_red_pin, 0);
        writeDigitalPin(a, a_green_pin, 0);
    else
        writeDigitalPin(a, a_green_pin, 1);
        writeDigitalPin(a, a_red_pin, 0);
        writeDigitalPin(a, a_yellow_pin, 0);
    end
        
    % Display with corrected format
    fprintf('Current Temp: %.2f°C\n', current_temp);
    fprintf('Predicted Temp in 5min: %.2f°C\n', predicted_temp);
    fprintf('Rate of Change: %.4f°C/s\n\n', rate);
    
    % Compensate for processing time
    elapsed=toc;
    pause(max(sample_interval-elapsed,0));  % Control sampling frequency
end
end
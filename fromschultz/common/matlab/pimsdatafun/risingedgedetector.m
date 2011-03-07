function [indRisingEdges,accel,absSmoothAngularRate] = risingedgedetector(angle,fs)
% EXAMPLE
% load c:\temp\trash_angle % gets "angle"
% fs = 100; % sa/sec sample rate
% [indRisingEdges,accel,absSmoothAngularRate] = risingedgedetector(angle,fs);

%% Get angular rate
angularRate = gradient(angle)*fs;

%% Design 10Hz LPF
order = 9;
fc = 10; % Hz
[b,a] = butter(order,fc/(fs/2),'low');

%% Apply 10Hz LPF to angularRate
smoothAngularRate = filtfilt(b,a,angularRate);

%% Get absolute value of smoothAngularRate
absSmoothAngularRate = abs(smoothAngularRate);

%% Find all "edges" in absSmoothAngularRate (despite variable's name...)
blnRisingEdges = edge(absSmoothAngularRate,'prewitt'); % best edge detector? 

%% Keep only positive slopes (to make good on variable's name)
accel = gradient(absSmoothAngularRate)*fs;
blnRisingEdges(accel<0) = 0; % just rising edges are of interest
indRisingEdges = find(blnRisingEdges);
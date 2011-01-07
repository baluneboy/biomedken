function [dydtfilt,t] = filtdydt(y,order,fc,fs,strFiltType,strTrial)
% filtdydt.m - takes given signal and applies butterworth filter based on
% given parameters
% 
% INPUTS
% y - vector to be differentiated and filtered
% order - filter order
% fc - cutoff frequency
% fs - sampling rate [Hz]
% strFiltType - 'low', 'high','stop' for filter type
% strFigure - name of figure to plot data
% 
% OUTPUTS
% dydtfilt - filtered dy/dt signal
% t - time vector for filtered dy/dt signal
% 
% EXAMPLE
% order = 5; 
% fc = 2;
% fs = 100;
% strFiltType = 'low';
% dydtfilt = filtdydt(y,order,fc,fs,strFiltType);

% Author - Krisanne Litinas
% $Id$

% Find dy/dt, t
[dydt,t] = getdydt(y,fs);

% Get filter parameters
Wn = fc/(fs/2);
[b,a] = butter(order,Wn,strFiltType);

% Apply filter to dy/dt
dydtfilt = filtfilt(b,a,dydt);

% Generate plot to check accuracy of filtering
% populatevelocitysubplots(5,2,dydt,filtdydt,t,'check_lpf',strDir,strTrial)
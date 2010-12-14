function [epochMillisec,powerActual,freqActual,t,y] = generate_spectral_epoch(fs,powerDesired,frequencyDesired,epochMillisec)

%% Get integer value for N (and adjust epoch duration)
N = round(fs*epochMillisec/1e3);
epochMillisec = 1e3*N/fs;

%% Get actual power


%% Get actual frequency

%% 
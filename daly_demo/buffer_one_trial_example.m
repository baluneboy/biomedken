function [t,y,tb,yb] = buffer_one_trial_example(freq,durEpochSec,A,Anoise,numEpochs,nEpoch,nOverlap)

% % % EXAMPLE
% % strFileDat = 'S:\data\upper\bci\therapy\s1332plas\index_finger_extension\real\s1332plas007\s1332plasS007R01.dat';
% % [ signal, states, parameters ] = load_bcidat(strFileDat,'-calibrated');
% % yc3 = double(signal(:,24));
% % t = gent(yc3,250);
% A = 0.1; % amplitude (uV)
% Anoise = 0.01; % amplitude of noise (uV)
% durEpochSec = 0.320; %that's 320msec
% freq = 9.375; %Hz (integer multiple of cycles in an epoch is 3*1/durEpochSec)
% numEpochs = 10.5; %remember 50% overlap (160msec for Wadsworth)
% fs = 250;
% nEpoch = fs*durEpochSec;
% nOverlap = fs*durEpochSec/2; % for Wadsworth (FOUR FOR DALY)
% [t,y,tb,yb] = buffer_one_trial_example(freq,durEpochSec,A,Anoise,numEpochs,nEpoch,nOverlap);
%% figure, plot(t,y,'b'), hold on, plot(tb(:,end),yb(:,end),'r'), plot(tb(:,end-2),yb(:,end-2),'m'), shg, figure
% pwr = []; for i = 1:nCols(yb), [pxx,f] = mem(yb(:,i),[16,9.375-6,9.375+6,3,15,2,250]); pwr(i) = 3*pxx(3); end, pwr

[t,y] = generate_one_trial_example(freq,durEpochSec,A,Anoise,numEpochs);
yb = buffer(y,nEpoch,nOverlap,'nodelay');
tb = buffer(t,nEpoch,nOverlap,'nodelay');
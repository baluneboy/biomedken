function [pTopWario,pBotWario,r2Wario,pTopWads,pBotWads,r2Wads] = power_four_trials_example

% EXAMPLE
% function [pTopWario,pBotWario,pTopWads,pBotWads,r2Wario,r2Wads] = power_four_trials_example

ABOTS = [0.100 0.080]; ANOISEBOTS = [0.015 0.007]; NUMEPOCHSBOT = [1112.5 1110.5];
ATOPS = [0.075 0.062]; ANOISETOPS = [0.010 0.005]; NUMEPOCHSTOP = [1110.5 1112.5];

durEpochSec = 0.320; %that's 320msec
freq = 9.375; %Hz (integer multiple of cycles in an epoch is 3*1/durEpochSec)
fs = 250;
nEpoch = fs*durEpochSec;
nOverlap = fs*durEpochSec/2; % for Wads (DENOM IS 4 FOR DALY)

% numEpochsBot %remember 50% overlap (160msec for Wads)
% Atop  % amplitude (uV)
% AnoiseBot % amplitude of noise (uV)
strType = 'wario';
pBot = [];
for i = 1:length(ABOTS)
    Abot = ABOTS(i);
    AnoiseBot = ANOISEBOTS(i);
    numEpochsBot = NUMEPOCHSBOT(i);
    pBot = [pBot power_one_trial_example(freq,durEpochSec,Abot,AnoiseBot,numEpochsBot,nEpoch,nOverlap,strType)];
end
pTop = [];
for i = 1:length(ATOPS)
    Atop = ATOPS(i);
    AnoiseTop = ANOISETOPS(i);
    numEpochsTop = NUMEPOCHSTOP(i);
    pTop = [pTop power_one_trial_example(freq,durEpochSec,Atop,AnoiseTop,numEpochsTop,nEpoch,nOverlap,strType)];
end
pTopWario = pTop;
pBotWario = pBot;
r2Wario = rsqu(pTopWario,pBotWario);
[numWario,denWario] = getnumdenrsq(pTopWario,pBotWario);
% plot(ones(size(pTopWario)),pTopWario,'.','color',[0 0.7 0]);
% hold on
% plot(2*ones(size(pBotWario)),pBotWario,'.','color',[0.7 0 0]);


strType = 'wadsworth';
pBot = [];
for i = 1:length(ABOTS)
    Abot = ABOTS(i);
    AnoiseBot = ANOISEBOTS(i);
    numEpochsBot = NUMEPOCHSBOT(i);
    pBot = [pBot power_one_trial_example(freq,durEpochSec,Abot,AnoiseBot,numEpochsBot,nEpoch,nOverlap,strType)];
end
pTop = [];
for i = 1:length(ATOPS)
    Atop = ATOPS(i);
    AnoiseTop = ANOISETOPS(i);
    numEpochsTop = NUMEPOCHSTOP(i);
    pTop = [pTop power_one_trial_example(freq,durEpochSec,Atop,AnoiseTop,numEpochsTop,nEpoch,nOverlap,strType)];
end
pTopWads = pTop;
pBotWads = pBot;
r2Wads = rsqu(pTopWads,pBotWads);
% plot(0.95*ones(size(pTopWads)),pTopWads,'o','color',[0 0.7 0]);
% hold on
% plot(1.95*ones(size(pBotWads)),pBotWads,'o','color',[0.7 0 0]);
% 
% set(gca,'xlim',[0 3],'ylim',[0 1]); shg
% xlabel('target'), ylabel('power')

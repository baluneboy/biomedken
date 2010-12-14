function pwr = power_one_trial_example(freq,durEpochSec,Atop,AnoiseTop,numEpochsTop,nEpoch,nOverlap,strType)

% strType = 'wario'; % or 'wadsworth'
% Atop = 0.1; % amplitude (uV)
% AnoiseTop = 0.01; % amplitude of noise (uV)
% durEpochSec = 0.320; %that's 320msec
% freq = 9.375; %Hz (integer multiple of cycles in an epoch is 3*1/durEpochSec)
% numEpochsTop = 10.5; %remember 50% overlap (160msec for Wadsworth)
% fs = 250;
% nEpoch = fs*durEpochSec;
% nOverlap = fs*durEpochSec/2; % for Wadsworth (FOUR FOR DALY)
% pwrTop = power_one_trial_example(freq,durEpochSec,Atop,AnoiseTop,numEpochsTop,nEpoch,nOverlap,strType);
% numEpochsBot = 12.5;
% Abot = 0.75*Atop;
% AnoiseBot = 0.015;
% pwrBot = power_one_trial_example(freq,durEpochSec,Abot,AnoiseBot,numEpochsBot,nEpoch,nOverlap,strType);
% plot(ones(size(pwrTop)),pwrTop,'.','color',[0 0.7 0])
% hold on
% plot(2*ones(size(pwrBot)),pwrBot,'.','color',[0.7 0 0]);
% set(gca,'xlim',[0 3],'ylim',[0 1]); shg
% xlabel('target'), ylabel('power')

[t,y,tb,yb] = buffer_one_trial_example(freq,durEpochSec,Atop,AnoiseTop,numEpochsTop,nEpoch,nOverlap); %#ok<ASGLU>
pwr = [];
BinWidth = 3;
switch lower(strType)
    case 'wario' % per-epoch
        for i = 1:nCols(yb)
            [pxx,f] = mem(yb(:,i),[16,9.375-6,9.375+6,BinWidth,15,2,250]);
            pwr(i) = BinWidth*pxx(3);
        end
    case 'wadsworth' % per-trial
            [pxx,f] = mem(yb,[16,9.375-6,9.375+6,BinWidth,15,2,250]);
            pxx = mean(pxx,2);
            pwr = BinWidth*pxx(3);
    otherwise
        error('strType must be wario or wadsworth')
end
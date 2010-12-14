function M = bruteforcethismutha()

% yields: 
% msecEpochWadsworth = 330;
% msecEpochWario = 300;
% numEpochsWadsworth = 24; % 50% overlap
% numEpochsWario = 18; % 25% overlap
% T = 4.125;

msecStep = 4;
ctr = 320; TOL = 319; rngMsecEpochWario = ctr-TOL:msecStep:ctr+TOL;
ctr = 333; TOL = 0; rngMsecEpochWadsworth = ctr-TOL:msecStep:ctr+TOL;

M = [];
for j = 1:length(rngMsecEpochWadsworth)
    msecEpochWadsworth = rngMsecEpochWadsworth(j);
    for i = 1:length(rngMsecEpochWario)
        msecEpochWario = rngMsecEpochWario(i);
        for numEpochsWadsworth = 12:2:52
            [T,numEpochsWario] = numberpoints2use(msecEpochWario,msecEpochWadsworth,numEpochsWadsworth);
            txt = sprintf('\n%g, %g sec, %g, %g',numEpochsWadsworth,T,numEpochsWario,T);
%             if isint(numEpochsWario) && iseven(numEpochsWadsworth) && iseven(numEpochsWario) && (rem(msecEpochWario,4)==0)
            if isint(numEpochsWario)
                M = [M; msecEpochWadsworth msecEpochWario numEpochsWadsworth numEpochsWario T];
            end
        end
    end
end
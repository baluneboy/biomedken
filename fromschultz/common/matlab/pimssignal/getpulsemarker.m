function ind = getpulsemarker(leadingEdges,durations,fs,msecPulseNominal,msecTol)

% GETPULSEMARKER do some discrimination to get good pulse marker based on duration criteria

if nargin == 4
    msecTol = 2;
end
msecDurations = 1e3*(durations/fs); % convert pulse widths to msec
msecLo = msecPulseNominal - msecTol;
msecHi = msecPulseNominal + msecTol;
indGoodWidth = find(msecDurations>msecLo & msecDurations<msecHi);
ind = leadingEdges(indGoodWidth);
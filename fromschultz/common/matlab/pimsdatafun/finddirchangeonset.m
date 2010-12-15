function [starts,durs,localRanges] = finddirchangeonset(v,strDir)
% finddirchangeonset - finds when vector begins increasing or decreasing
% 
% EXAMPLE:  
% [startNeg,durNeg] = finddirchangeonset(kneeSwing,'neg');
% [startNeg,durNeg,localNegRanges] = finddirchangeonset(kneeSwing,'neg');

v = v(:);
d = diff(v);
switch lower(strDir)
    case 'pos'
        vSign = d > 0;
    case 'neg'
        vSign = d < 0;
    otherwise
        error('invalid direction')
end

% vSign = [nan; vSign];
[starts,durs] = contig_statespecific(vSign,1);
ends = starts + durs;
localRanges = v(ends) - v(starts);

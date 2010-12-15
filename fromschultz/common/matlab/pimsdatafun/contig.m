function [starts,durations] = contig(t,ind)

% CONTIG find starting indices & durations in points of contiguous chunks
%        of t which correspond to the indices in ind
%
% [starts,durations] = contig(t,ind);
%
% Inputs: t - vector
%         ind - indices into t which satisfy some criteria specified
%               before call to this function.
%
% Outputs: starts - starting indices of contiguous chunks
%          durations - duration in points of contiguous chunks
%
% EXAMPLE:
% fakeStates = [ 0 2 0 1 1 1 2 2 0 0 3 3 3 1 4 1 1 0 4 4 0 5 5 ];
% stateOfInterest = 1;
% indOfInterest = find(fakeStates==stateOfInterest);
% [st1,du1] = contig(fakeStates,indOfInterest)
% stateOfInterest = 4;
% indOfInterest = find(fakeStates==stateOfInterest);
% [st4,du4] = contig(fakeStates,indOfInterest)
% [ (1:length(fakeStates)); fakeStates ]'
%
% See contig2ind

% written by: Ken Hrovat on 11/22/95
% $Id: contig.m 4160 2009-12-11 19:10:14Z khrovat $

x=zeros(size(t));          % Vector of zeros size of input vector
x(ind)=ones(size(ind));    % Replace appropriate components with ones
x=x(:);                    % Shape x as a column
ips=find(x==1);            % Indices of possible starts
if ( isempty(ips) )
	starts=[];              % No elements equal 1, so return empty results
	durations=[];
	return;
end
starts=ips(1);             % First index of starts is first index of possible starts
ips(1)=0;                  % Need to set this to zero for diff to work properly
diffx=diff(x);             % Calculate deltas
starts=[starts; find(diffx==1)+1];  % These are the start indices
durations=[];              % Initialize durations
for num=1:length(starts)-1
	subx=x(starts(num):starts(num+1)-1);
	durations=[durations; sum(subx)];
end
subx=x(max(starts):length(x));
durations=[durations; sum(subx)];
ibad=find(durations==0);
starts(ibad)=[];
durations(ibad)=[];
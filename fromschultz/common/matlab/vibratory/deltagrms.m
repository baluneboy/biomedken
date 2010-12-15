function [dv,dx,dy,dz,mbv,mev]=deltagrms(newt,iv,ix,iy,iz,int,basetimes,exertimes);

% DELTAGRMS - Function to calculate the change in RMS accleration level given 
%             two distinct, possibly non-contiguous, time frames.  These time
%             frames represent periods for two conditions, like exercise and
%             no exercise for USMP-4 PCIS exercise assessment.
%
% [dv,dx,dy,dz,mbv,mev]=deltagrms(newt,iv,ix,iy,iz,int,basetimes,exertimes);
%
% Inputs: newt,ix,iy,iz - vectors of equal length for interval RMS data
%                         NOTE: newt MUST BE RELATIVE TIME IN SECONDS (MET OR DMT)
%         int - scalar for interval in seconds (from interval RMS calculations)
%         basetimes - matrix of times for condition #1 (baseline), like so
%                     basetimes=[ t1 t2; t3 t4; ... ];
%                     where [t1 t2], [t3 t4], ... are contiguous chunks of time
%                     when condition #1 is present; the rows of basetimes, which
%                     represent distinct time chunks, do not have to be
%                     contiguous though
%         exertimes - matrix of times for condition #2 (like basetimes)
%
% Output: dv,dx,dy,dz - scalars for delta gRMS from condition #1 (baseline) to
%                       condition #2 (exercise)
%         mbv,mev - scalars for median grms of baseline and exercise, respectively

% written by: Ken Hrovat on 9/29/97
% $Id: deltagrms.m 4160 2009-12-11 19:10:14Z khrovat $

% Error checking:

if ( ~(length(newt)==length(ix) & length(newt)==length(iy) & length(newt)==length(iz)) )
	error('DELTAGRMS.M : input vectors newt,ix,iy,iz must have same length')
end

t1=newt(1);
if ( t1~=0 )
	disp('DELTAGRMS WARNING: IT APPEARS THAT newt IS NOT RELATIVE TIME. VERIFY THAT IT IS RELATIVE.');
end

mint=min(newt);
maxt=max(newt);
if ( any(any(basetimes<mint)) | max(max(basetimes))>maxt )
	disp('DELTAGRMS.M : newt does not span all of basetimes')
	keyboard
	error('DELTAGRMS.M : newt does not span all of basetimes')
end
if ( any(any(exertimes<mint)) | max(max(exertimes))>maxt )
	disp('DELTAGRMS.M : newt does not span all of exertimes')
	keyboard
	error('DELTAGRMS.M : t does not span all of exertimes')
end


% Find indices for condition #1 chunks (baseline times)

ib=[];
itmp=[];
for k=1:nRows(basetimes)
	itmp=find(newt>=basetimes(k,1) & newt<=basetimes(k,2));
	ib=[ib; itmp(:)];
end


% Find indices for condition #2 chunks (exercise times)

ie=[];
itmp=[];
for k=1:nRows(exertimes)
	itmp=find(newt>=exertimes(k,1) & newt<=exertimes(k,2));
	ie=[ie; itmp(:)];
end

% Calculate delta for [medians means]

dv=[ median(iv(ie))-median(iv(ib)) mean(iv(ie))-mean(iv(ib)) ];
dx=[ median(ix(ie))-median(ix(ib)) mean(ix(ie))-mean(ix(ib)) ];
dy=[ median(iy(ie))-median(iy(ib)) mean(iy(ie))-mean(iy(ib)) ];
dz=[ median(iz(ie))-median(iz(ib)) mean(iz(ie))-mean(iz(ib)) ];

mev=median(iv(ie)); mbv=median(iv(ib));


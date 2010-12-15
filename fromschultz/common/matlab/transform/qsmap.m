function [osscomp,loccomp]= qsmap(raddata,sHeader,sParameters)
%
% QSMAP uses rates and angles to calculate gravity gradient and 
% rotational components for OSS location and an alternate location
% specified in sParameters
%
%  $Id: qsmap.m 4160 2009-12-11 19:10:14Z khrovat $
%

% remove the time component, RADDATA should matchup with acceleration data at this point
raddata(:,1) = [];

%generate rotational and tranformation matrices where A is the
% rotational acceleration matrices, and T is the matrices for the 
% coordinate tranformation [SS Analysis] = T * [LVLH]

%Quaternions are columns 1:4 [q0 q1 q2 q3]
T = quat2TyprN(raddata(:,1:4));
raddata(:,1:4) =[];

% angular velocities [wx wy wz] now columns 1:3
A = ArotN(raddata(:,1:3),'rad');
raddata(:,1:3) =[];

% Center of mass [cmx xmy cmz] now columtns 1:3 (in inches)
% Convert cm data from SS Reference in meters to inches in SSA;
m2in = getsf('meter','inch');
raddata(:,1) = (raddata(:,1) - 100)*m2in;  % X
raddata(:,2) = raddata(:,2)*m2in;          % Y
raddata(:,3) = (raddata(:,3) - 100)*m2in;  % Z
cm = reshape(raddata(:,1:3)',1,3,size(raddata,1));

% J2K position (inertial) now column 4:6
% convert to radius in feet 
Ro = pimsrss(raddata(:,4),raddata(:,5),raddata(:,6));
clear raddata;

% get gravity gradient and rotational components at OSS and rack loc in SS Analysis.
[osscomp,loccomp] = calc_ggrot_comp(T,A,cm,Ro,sHeader,sParameters);
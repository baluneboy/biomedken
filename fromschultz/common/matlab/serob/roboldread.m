function [ind,x,y,vx,vy,fx,fy,fz] = roboldread(strFile)

% roboldread - read binary robotics data file from old format dat files
%
% INPUTS:
% strFile - string for binary dat file to read
%
% OUTPUTS:
% ind - vector of index values (that can be converted to time via sample
%       rate, which is nominally fs=200, so times=index./fs)
% x,y - vectors of robot x,y position (m)
% vx,vy - vectors of x,y velocities (m/s)
% fx,fy,fz - vector of x,y,z forces (to be ignored)
%
% %EXAMPLE
% strFile = 'S:\data\upper\eeg_emg_rob\s1221moda\pre\rob\point_to_point_122704_Nt1.dat';
% [ind,x,y,vx,vy,fx,fy,fz] = roboldread(strFile);
% fs = 200; t = (ind-1):1/fs:length(ind)/fs-1/fs;
% figure
% subplot(3,2,1), plot(t,x), ylabel('x(t)'), xlabel('time (sec)'), set(gca,'ylim',0.2*[-1 1])
% subplot(3,2,2), plot(t,y), ylabel('y(t)'), xlabel('time (sec)'), set(gca,'ylim',0.2*[-1 1])
% subplot(3,2,3), plot(t,vx), ylabel('vx(t)'), xlabel('time (sec)'), set(gca,'ylim',0.4*[-1 1])
% subplot(3,2,4), plot(t,vy), ylabel('vy(t)'), xlabel('time (sec)'), set(gca,'ylim',0.4*[-1 1])
% subplot(3,2,5), plot(x,y), ylabel('y(x)'), axis(0.2*[-1 1 -1 1])
% subplot(3,2,6), plot(vx,vy), ylabel('vy(vx)'), axis(0.4*[-1 1 -1 1])

% AUTHOR: Roger Cheng
% $Id: roboldread.m 4160 2009-12-11 19:10:14Z khrovat $

fid = fopen(strFile);
fseek(fid,142,-1);
data = fread(fid,'double');
data = reshape(data,numel(data)/7,7);
[x,y,vx,vy,fx,fy,fz] = deal(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),data(:,6),data(:,7));
ind = 1:size(data,1);
fclose(fid);
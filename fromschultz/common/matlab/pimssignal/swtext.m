function [swa,swd] = swtext(signal,level,extmode,wname)
% SWTEXT -- Use stationary wavelet transform with automatic signal
% extension
% INPUTS:
%   signal -- 1 dimensional signal
%   (OPTIONAL)level -- transform level, default 8
%   (OPTIONAL)extmode -- extension mode, default zero padding
%   (OPTIONAL)wname -- wavelet filter, default sym3
%
% OUTPUTS:
%   swa -- stationary wavelet approximations (level x sample)
%   swd -- stationary wavelet details (level x sample)
%
% EXAMPLE:
%     [signal,states,parameters] = load_bcidat('S:\data\upper\bci\therapy\s1818bcis\baseline\s1818bcis001\s1818bcisS001R02.dat','-calibrated');
%     basesig = signal(:,1);
%     [swa,swd] = swtext(basesig);
% 
% SWT default values based on paper "Removal of Ocular Artifacts in the EEG through Wavelet Transform without using an EOG Reference Channel"
% Kumar, Arumuganathan, Sivakumar, Vimal
% Int. J. Open Problems Compt. Math.,Vol.1, No. 3, December 2008

if ~exist('signal','var')
    error('Error: No signal input.');
end

if ~exist('level','var')
    level = 8;
end

if ~exist('extmode','var')
    extmode = 'zpd';
end

if ~exist('wname','var')
    wname = 'sym3';
end

extlen = 2^level - mod(size(signal,1),2^level);
extsig = wextend(1,extmode,signal,extlen,'r');

[swa,swd] = swt(extsig,level,wname);
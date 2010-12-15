function [hFig,hAx,hText]=PLOTTYPE(data,sHeader,sParameters,varargin);

%PLOTTYPE - function to generate PLOTTYPE as specified in sParameters.  The conventions
%           defined in this template are good for adding to slice disposition list in
%           popload gui.
%
%[hFig,hAx,hText]=PLOTTYPE(data,sHeader,sParameters,varargin);
%
%Inputs: data - matrix of [t x y z s?] columns
%        sHeader - structure of header information
%        sParameters - nested structure of .plot, .output, .other? parameters
%
%Outputs: hFig - scalar figure handle
%         hAx - vector of axes handles
%         hText - vector of text handles

% written by: Ken Hrovat on 7/6/2000
% $Id: template.m 4160 2009-12-11 19:10:14Z khrovat $

% NOTE: Deal varargin here if needed:
%[p1,p2,...]=deal(varargin{:});

% Get nested structures
sPlot=getfield(sParameters,'plot'); %of plot parameters
sOutput=getfield(sParameters,'output'); %of output parameters
% NOTE: need any other structures from sParameters?

% Perform generic tasks common to all plot types
[hFig,hAx,hText,sPlot,sOutput]=plotgeneric(data,sHeader,sPlot,sOutput);


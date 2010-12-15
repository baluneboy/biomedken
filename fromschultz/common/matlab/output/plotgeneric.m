function [hFig,hAx,hAxTitle,hAxXLabel,hText] = plotgeneric(data,sHeader,sParameters,varargin)

%PLOTGENERIC - function to perform tasks common to all plot types.
%
%[hFig,hAx,hText] = plotgeneric(data,sHeader,sParameters);
%
%Inputs: data - matrix of data in columns
%        sHeader - structure of header information
%        sParameters - nested structure with fields:
%                   .sPlot - structure with fields:
%                        .strType - string for type like ('bci spectra')
%                   .sOutput - structure with fields
%
%Outputs: hFig - scalar figure handle
%         hAx - vector of axes handles
%         hAxTitle - scalar handle for axes parent of ancillary text
%         hAxXLabel - scalar handle for axes parent of xlabel
%         hText - vector of text handles common to all plots

% Author: Ken Hrovat
% $Id: plotgeneric.m 4160 2009-12-11 19:10:14Z khrovat $

% Process inputs
if nargin==4
    %[p1,p2,...]=deal(varargin{:});
elseif nargin~=3
    error('wrong nargin')
end

% Switch to branch for output type
switch sParameters.sOutput.strType
    
    case {'screen','screendebug','www'}
        
        % Generate subplots and return matrix of handles
        switch sParameters.sPlot.strType
            case 'bcispectra' % subplots: 3x1 for PSD linear, PSD log and r-squared vs. frequency
                rows = 3; cols = 1;
            case 'debug' % subplots: 1x1
                rows = 1; cols = 1;
            otherwise
                error('unrecognized value for sParameters.sPlot.strType = %s',sParameters.sPlot.strType)
        end
        
        % Create and initialize figure and axes objects
        [hFig,hAx,hAxTitle,hAxXLabel] = plotsetupfigax(rows,cols);
        
        % Create text cell array of strings
        % for upper left: subject,setting,dataCollectDate
        casUpperLeft = sprintf('%s, id: %s, %.1f Hz',sHeader.DataType,sHeader.SensorID,sHeader.CutoffFreq);
        casUpperLeft = cappend(casUpperLeft,sprintf('%.1f samples/second',sHeader.SampleRate));
        % for upper right: Increment,DisplayCoordinates
        casUpperRight = sprintf('Increment %s','??WHAT');
        casUpperRight = cappend(casUpperRight,sprintf('%s Coordinates','??WHICH'));
        % for title: Comment,TimeZero
        casTitle = {sParameters.Comment;popdatestr(sHeader.TimeZero,0)};
        set(get(hAxTitle,'title'),'str',casTitle)
        
    case 'data_file'
        
        hFig=[];hAx=[];hText=[];% no figure needed
        %fwritepims(data,sHeader,sOutput);
        
    otherwise
        
        error('unrecognized output type')
        
end % switch sOutput.Type

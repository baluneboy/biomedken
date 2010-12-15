function strPlotMode=parseplotinputs(data,sHeader,sParameters,varargin);

%parseplotinputs - function to parse plot routine input arguments and
%                  determine plot mode based on profile of inputs.
%
%strPlotMode=parseplotinputs([],fig,sParameters,varargin);
%
%Inputs: fig - scalar handle of a popload or popbatch figure
%        sParameters - nested structure of .plot, .output, .other? parameters
%
% OR
%
%strPlotMode=parseplotinputs(data,sHeader,sParameters,varargin);
%
%Inputs: data - matrix of [t x y z s?] columns
%        sHeader - structure of header information
%        sParameters - nested structure of .plot, .output, .other? parameters
%
%Output: strPlotMode - string for plot mode
%  ALSO IMPLIED (where needed):
%        strCmds - string of commands evalin'ed plot routine workspace
%                  (if needed, to have data & sHeader variables assigned)

%written by: Ken Hrovat on 8/30/2000
% $Id: parseplotinputs.m 4160 2009-12-11 19:10:14Z khrovat $

% Check 1st three input args' profile
if ( isempty(data) & locIsScalar(sHeader) & isstruct(sParameters) )
   fig=sHeader;
   strTag=get(fig,'tag');
   if strmatch('popload',strTag)
      strPlotMode='popload';
      strCmds=['data=get(' num2str(fig) ',''UserData'');sHeader=get(findobj(' num2str(fig) ',''tag'',''ListboxHeader''),''UserData'');'];
      strCatch='warnmodal(''PARSE INPUTS ERROR'',''Could not eval for data & header in caller plot routine.'')';
      evalin('caller',strCmds,strCatch);
   elseif strmatch('popbatch',strTag)
      strPlotMode='popbatch';
   else
      error('2nd argument (fig) does not have expected tag')
   end
elseif ( isnumeric(data) & isstruct(sHeader) & isstruct(sParameters) )
   strPlotMode='nonpop';
else
   error('input arguments do not fit expected profile to determine plot mode')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
function b=locIsScalar(x);
b=0;
if ( isnumeric(x) & length(x)==1 )
   b=1;
end

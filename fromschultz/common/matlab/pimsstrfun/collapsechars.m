function strCollapsed=collapsechars(str,varargin);

% COLLAPSECHARS replace contiguous runs of chars in strSet with charSymbol
%
% strCollapsed=collapsechars(str); % collapse digits and decimal pts into #
%
% strCollapsed=collapsechars(str,strSet,charSymbol); % general syntax
%
%Inputs: str - string input
%        strSet - string of chars to unify
%        charSymbol - string to place hold for contig runs in strSet
%
%Output: strCollapsed - string with contiguous runs of chars in strSet replaced
%                       with place holder (charSymbol)

% author: Ken Hrovat, 9/29/2000
% $Id: collapsechars.m 4160 2009-12-11 19:10:14Z khrovat $

if ~isstr(str)
   error('string input required')
end

% defaults
strSet='0.123456789';
charSymbol='#';

switch nargin
case 1
   % use digit defaults
case 2
   strSet=varargin{1};
case 3
   [strSet,charSymbol]=deal(varargin{1:2});
otherwise
   error('unexpected input arguments')
end

% verify charSymbol not member of strSet
ind=findstr(strSet,charSymbol);
if ~isempty(ind)
   error('charSymbol cannot be in strSet of chars to collapse')
end
if ( ~isstr(charSymbol) | length(charSymbol)~= 1 )
   error('charSymbol must be a single char')
end

% mark those chars in set to collapse
ivec=ismember(str,strSet);
str2=ivec*charSymbol;

% get chars not in set
inot=find(str2==0);

% preserve chars not in collapse set
str2(inot)=str(inot);

% get run length info
[runLength,runValue]=runlength(str2,inf);

% collapse string
strCollapsed=char(runValue);

function showswitch(str)
% no help here for quick example of switch instead of if/elseif train
% EXAMPLE
% showswitch('five')
switch lower(str)
    case {'one','three','five'}
        disp('you entered "one", "three" or "five"')
    case 'two'
        disp('you entered "two"')
    case 'four'
        disp('another special case here...you entered "four"')
    otherwise
        warning('daly:bci:unrecognizedSwitchCase','do not know what to do with %s in %s',str,mfilename);
end
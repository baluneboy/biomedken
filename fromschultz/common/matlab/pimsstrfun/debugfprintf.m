function debugfprintf(strFormat,varargin)
global BOOLEAN_DEBUG
if BOOLEAN_DEBUG
    feval('fprintf',strFormat,varargin{:})
end
function varargout = mode(varargin)
% Allows inputs to be char
ic = ischar(varargin{1});
if ic
    varargin{1} = double(varargin{1});
end
[varargout{1:nargout}] = builtin('mode', varargin{:});
if ic
    varargout{1} = char(varargout{1});
    if nargout>2
        varargout{3} = cellfun(@char, varargout{3}, 'UniformOutput', false);
    end
end
end
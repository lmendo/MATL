function y = dec2base(varargin)
% Works for empty input
% Allows inputs to be char
if isempty(varargin{1})
    y = '';
else
    if ischar(varargin{1})
        varargin{1} = double(varargin{1});
    end
    if nargin>1 && ischar(varargin{2})
        varargin{2} = double(varargin{2});
    end
    if nargin>2 && ischar(varargin{3})
        varargin{3} = double(varargin{3});
    end
    y = builtin('dec2base', varargin{:});
end
end
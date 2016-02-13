function y = dec2bin(varargin)
% Allows inputs to be char
if ischar(varargin{1}) 
    varargin{1} = double(varargin{1});
end
if nargin>1 && ischar(varargin{2}) 
    varargin{2} = double(varargin{2});
end
y = builtin('dec2bin', varargin{:});
end
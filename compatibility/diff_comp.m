function y = diff(varargin)
% Allows first input to be char
if ischar(varargin{1}) 
    varargin{1} = double(varargin{1});
end
y = builtin('diff', varargin{:});
end
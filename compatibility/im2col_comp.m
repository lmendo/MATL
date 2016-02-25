function y = im2col(varargin)
% Allows char input
charInput = ischar(varargin{1});
if charInput
    varargin{1} = double(varargin{1});
end
% Fixes behaviour regarding shape.
argin1 = varargin{1}; argin1 = reshape(argin1, size(argin1,1), []);
% Gives empty output (instead of error) if block size too large
if any(varargin{2}>size(varargin{1}))
    y = [];
else
    y = builtin('im2col', argin1, varargin{2:end});
end
if charInput
    y = char(y);
end
end
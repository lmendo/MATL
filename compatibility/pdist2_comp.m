function y = pdist2(varargin)
% Allows distances used in pdist
try
    y = builtin('pdist2', varargin{:});
catch
    x = [varargin{1}; varargin{2}];
    y = squareform(pdist(x, varargin{3:end}));
    y = y(1:size(varargin{1},1), size(varargin{1},1)+1:size(varargin{1},1)+size(varargin{2},1));
end
end
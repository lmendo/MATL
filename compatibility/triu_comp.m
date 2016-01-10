function y = triu(varargin)
% When matrix is empty and there's a non-zero second argument it should give [] (that's what Matlab does), not error 
if nargin==2 && isempty(varargin{1})
    y = [];
else
    y = builtin('triu', varargin{:});
end
end
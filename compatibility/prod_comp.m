function y = prod(varargin)
% Fixes special case prod([],1), prod([],1,...), prod('',1), prod('',1,...)
% Fixes special case prod(sym([])), prod(sym([]),...) (without specifying dimension)
if nargin>1 && isequal(size(varargin{1}), [0 0]) && isequal(varargin{2}, 1)
    y = ones(1,0);
elseif ( nargin==1 && isa(varargin{1}, 'sym') && isequal(size(varargin{1}), [0 0]) ) || ...
       ( nargin>1  && isa(varargin{1}, 'sym') && isequal(size(varargin{1}), [0 0]) && ~isnumeric(varargin{2}) )
    y = 1;
else
    if ~isa(varargin{1},'sym')
        y = builtin('prod', varargin{:});
    else
        y = builtin('@sym/prod', varargin{:});
    end
end
end
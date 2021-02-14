function y = sum(varargin)
% Fixes special case sum([],1), sum([],1,...), sum('',1), sum('',1,...)
% Fixes special case sum(sym([])), sum(sym([]),...) (without specifying dimension)
% Adds 'omitnan'  functionality
if nargin>1 && isequal(size(varargin{1}), [0 0]) && isequal(varargin{2}, 1)
    y = zeros(1,0);
elseif ( nargin==1 && isa(varargin{1}, 'sym') && isequal(size(varargin{1}), [0 0]) ) || ...
        ( nargin>1  && isa(varargin{1}, 'sym') && isequal(size(varargin{1}), [0 0]) && ~isnumeric(varargin{2}) )
    y = 0;
elseif nargin>1 && strcmp(varargin{end},'omitnan') 
    y = nansum(varargin{1:end-1});
else
    if ~isa(varargin{1},'sym')
        y = builtin('sum', varargin{:});
    else
        y = builtin('@sym/sum', varargin{:});
    end
end
end
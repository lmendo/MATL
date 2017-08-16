function varargout = intersect(varargin)
% Adds support for 'stable' input flag with one output
if iscell(varargin{1}) && ~iscell(varargin{2}), varargin{2} = {varargin{2}}; end
if iscell(varargin{2}) && ~iscell(varargin{1}), varargin{1} = {varargin{1}}; end
if nargin>=3 && strcmp(varargin{end},'stable')
    if strcmp(varargin{3},'rows')
        y = [varargin{1}; varargin{2}];
        [a, ~, x] = unique(y,'rows');
        x1 = x(1:size(varargin{1},1));
        x2 = x(size(varargin{1},1)+1:end); 
    else
        y = [varargin{1}(:); varargin{2}(:)];
        [a, ~, x] = unique(y);
        x1 = x(1:numel(varargin{1}));
        x2 = x(numel(varargin{1})+1:end); 
    end
    ind = ismember(x1, x2);
    x = x1(ind);
    if ~isempty(x)
        x = x(~any(triu(bsxfun(@eq, x, x.'),1)));
    end
    if strcmp(varargin{3},'rows')
        y = a(x,:);
    else        
        y = a(x);
    end
    if size(varargin{1},1)==1 && size(varargin{2},1)==1 % row ouput if first two inputs are rows
        y = reshape(y,1,[]);
    end
    varargout{1} = y;
else
    if strcmp(varargin{end},'sorted'), varargin(end) = []; end
    varargout = cell(1,max(nargout,1)); % if called without outputs, nargout will be zero. In that case we return one output
    [varargout{:}] = builtin('intersect', varargin{:});
end
end

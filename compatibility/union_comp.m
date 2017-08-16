function varargout = union(varargin)
% Adds support for 'stable' input flag with one output
if iscell(varargin{1}) && ~iscell(varargin{2}), varargin{2} = {varargin{2}}; end
if iscell(varargin{2}) && ~iscell(varargin{1}), varargin{1} = {varargin{1}}; end
% The above two lines are needed to {mimic Matlab's/Octave's behaviour}
% onto the 'stable' case: if there are a cell input and a non-cell input,
% the latter behaves as it it was automatically packed into a cell. BTW, this
% happens also with concatenation: [{1 2 3} 4 5] gives {1 2 3 4 5}
if nargin>=3 && strcmp(varargin{end},'stable')
    if strcmp(varargin{3},'rows')
        y = [varargin{1}; varargin{2}];
        [a, ~, x] = unique(y,'rows');
    else
        y = [varargin{1}(:); varargin{2}(:)];
        [a, ~, x] = unique(y);
    end
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
    [varargout{:}] = builtin('union', varargin{:});
end
end

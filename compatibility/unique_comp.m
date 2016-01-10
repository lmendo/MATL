function varargout = unique(varargin)
% - Adds support for 'stable' flag. Only one output
% - The first ocurrence is returned, as in new Matlab versions. Octave, like old
% Matlab version, returns the last.
% - Second and third outputs are column vectors, as in new Matlab versions. 
if nargin>=2 && strcmp(varargin{end},'stable')
    if strcmp(varargin{2},'rows')
        [a, ~, y] = builtin('unique', varargin{1}, 'rows', 'first');
    else
        [a, ~, y] = builtin('unique', varargin{1}, 'first');
    end
    if ~isempty(y)
        y = y(~any(triu(bsxfun(@eq, y, y.'),1)));
    end    
    if strcmp(varargin{2},'rows')
        y = a(y,:);
    else
        y = a(y);
    end
    varargout{1} = y; clear y
else
    if strcmp(varargin{end},'sorted'), varargin(end) = []; end
    varargout = cell(1,nargout);
    if isequal(varargin{end},'first') || isequal(varargin{end},'first'), varargin{end+1} = 'first'; end
    [varargout{:}] = builtin('unique', varargin{:});
end
if nargout>=2, varargout{2} = varargout{2}(:); end
if nargout>=3, varargout{3} = varargout{3}(:); end
end
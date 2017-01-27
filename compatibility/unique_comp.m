function varargout = unique(varargin)
% - Adds support for 'stable' flag, with all three outputs. If 'stable' or 'sorted'
% are used they must be the last input
% - The first ocurrence is returned by default, as in new Matlab versions. Octave,
% like old Matlab version, returns the last y default.
% - Second and third outputs are column vectors, as in new Matlab versions. 
if nargin>=2 && strcmp(varargin{end},'stable')
    if strcmp(varargin{2},'rows')
        [a, ~, x] = builtin('unique', varargin{1}, 'rows', 'first');
    else
        [a, ~, x] = builtin('unique', varargin{1}, 'first');
    end
    if ~isempty(x)
        [~, ind] = max(bsxfun(@eq, x(:), (1:max(x)))); [y, ind2] = sort(ind(:));
        [~, ind3] = sort(ind2); z =  ind3(x);
        for n = 1:numel(x)
            x(n) = x(n) * ~any(x(n)==x(1:n-1));
        end
        x = nonzeros(x).';
    end    
    if strcmp(varargin{2},'rows')
        x = a(x,:);
    else
        x = a(x);
    end
    varargout{1} = x;
    if nargout>=2, varargout{2} = y; end
    if nargout>=3, varargout{3} = z; end
else
    if strcmp(varargin{end},'sorted'), varargin(end) = []; end
    varargout = cell(1,nargout);
    if ~any(cellfun(@(x) any(strcmp(x, {'first', 'last'})), varargin(2:end))), varargin{end+1} = 'first'; end
    [varargout{:}] = builtin('unique', varargin{:});
end
if nargout>=2, varargout{2} = varargout{2}(:); end
if nargout>=3, varargout{3} = varargout{3}(:); end
end
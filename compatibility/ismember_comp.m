function varargout = ismember(varargin)
% To make Octave's `ismember` behaviour match recent Matlab's: the second
% output gives the index of the first occurrence, not the last
if nargout==1 % single output: no interception needed
    [varargout{:}] = builtin('unique', varargin{:});
elseif nargin>=3 && strcmp(varargin{3},'rows') % two outputs, 'rows' case
    [aim, bim] = builtin('ismember', varargin{1}, varargin{2}(end:-1:1,:), 'rows');
    bim(aim) = size(varargin{2},1)+1-bim(aim);
    varargout = {aim, bim};
else % two outputs, no 'rows'
    [aim, bim] = builtin('ismember', varargin{1}, varargin{2}(end:-1:1));
    bim(aim) = numel(varargin{2})+1-bim(aim);
    varargout = {aim, bim};
end
end
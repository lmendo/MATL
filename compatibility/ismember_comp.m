function varargout = ismember(varargin)
% (1) To make Octave's `ismember` behaviour match recent Matlab's: the second
% output gives the index of the first occurrence, not the last
% (2) Octave gives error when the first two inputs are char and
% numeric, whereas Matlab works. So I include here conversion from char to
% double in that case.
% (2):
if ischar(varargin{1})&&isnumeric(varargin{2})
   varargin{1} = double(varargin{1});
end
if isnumeric(varargin{1})&&ischar(varargin{2})
   varargin{2} = double(varargin{2});
end
% (1):
if nargout==1 % single output: no interception needed
    varargout{1} = builtin('ismember', varargin{:});
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
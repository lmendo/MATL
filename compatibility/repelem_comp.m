function y = repelem(varargin)
% Implements Matlab's `repelem` in Octave
if nargin==2 && isvector(varargin{1}) && isvector(varargin{2}) && numel(varargin{2})>1
    ind = repelems(1:numel(varargin{1}), [1:numel(varargin{1}); varargin{2}(:).']);
    y = varargin{1}(ind);
elseif nargin==2 && isvector(varargin{1}) && isvector(varargin{2}) && numel(varargin{2})==1
    ind = repelems(1:numel(varargin{1}), [1:numel(varargin{1}); repmat(varargin{2},1,numel(varargin{1}))]);
    y = varargin{1}(ind);
elseif nargin>2
    ind = cell(1,nargin-1);
    for k = 2:nargin
        r = varargin{k};
        ind{k-1} = ceil(1/r:1/r:size(varargin{1},k-1));
    end
    y = varargin{1}(ind{:});
else
    error('Inputs not supported')
end
end
function varargout = min(varargin)
% Converts first or second inputs to double if they are char
if nargin>=1 && ischar(varargin{1})
    varargin{1} = double(varargin{1});
end
if nargin>=2 && ischar(varargin{2})
    varargin{2} = double(varargin{2});
end
if nargout==0
    nargout = 1; % if called without outputs: produce 1 output
end
varargout = cell(1,nargout);
if ~any(cellfun(@(x) isa(x,'sym'), varargin))
    [varargout{:}] = builtin('min', varargin{:});
else
    [varargout{:}] = builtin('@sym/min', varargin{:});
end
end
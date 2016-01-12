function varargout = randsample(varargin)
% - Produces a column in Octave (instead of a row) when the first input is a scalar
varargout{1} = builtin('randsample', varargin{:});
if numel(varargin{1})==1
    varargout{1} = varargout{1}(:);
end
end
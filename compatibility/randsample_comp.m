function varargout = randsample(varargin)
% - Produces a column, like Matlab does (instead of Octave, which produces a row), when the first input is a scalar
% - Allows first input to be char. It is then treated as the population to sample from (not as a number)
if ischar(varargin{1})
    varargout{1} = varargin{1}(randsample(numel(varargin{1}), varargin{2}));
else
    varargout{1} = builtin('randsample', varargin{:});
    if numel(varargin{1})==1
        varargout{1} = varargout{1}(:);
    end
end
end
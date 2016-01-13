function varargout = nchoosek(varargin)
% Allows first input to be non-numeric
y = builtin('nchoosek', 1:numel(varargin{1}), varargin{2});
varargout{1} = varargin{1}(y);
end
function varargout = regexprep(varargin)
% If regular expression is invalid, instead of an error it gives empty outputs, 
% like Matlab does. For that we use a try...catch block; if an error is found we
% use an empty regexp to produce empty outputs
nargout = max(nargout,1);
try
    [varargout{1:nargout}] = builtin('regexprep', varargin{:});
catch
    varargin{2} = '';
    [varargout{1:nargout}] = builtin('regexprep', varargin{:});
end
end
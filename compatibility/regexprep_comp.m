function varargout = regexprep(varargin)
% Octave does not support numeric fourth input. To partly address this, fourth
% input equal to 1 is replaced by 'once', so that at least that one works.
% If regular expression is invalid, instead of an error it gives empty outputs, 
% like Matlab does. For that we use a try...catch block; if an error is found we
% use an empty regexp to produce empty outputs
if nargin >=4 && isequal(varargin{4}, 1)
    varargin{4} = 'once';
end
nargout = max(nargout,1);
try
    [varargout{1:nargout}] = builtin('regexprep', varargin{:});
catch
    varargin{2} = '';
    [varargout{1:nargout}] = builtin('regexprep', varargin{:});
end
end
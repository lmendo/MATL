function y = round(varargin)
% Implements Matlab's `round` with 2 or 3 inputs
if nargin==1
    y = builtin('round',varargin{1});
elseif nargin==2 || (nargin==3 && strcmp(varargin{3}, 'decimal'))
    e = 10^varargin{2};
    y = builtin('round',varargin{1}*e)/e;
elseif nargin==3 && strcmp(varargin{3}, 'significant')
    e = 10^(varargin{2} - (floor(log10(abs(varargin{1})))+1));
    y = builtin('round',varargin{1}*e)/e;
else
    error('Incorrect inputs')
end
end
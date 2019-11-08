function y = round(varargin)
% Implements Matlab's `round` with 2 or 3 inputs
% For symbolic data: only 1 input is supported by the original round function, so only that case is
% covered here
if nargin==1
    if ~isa(varargin{1},'sym')
        y = builtin('round',varargin{1});
    else
        y = builtin('@sym/round',varargin{1});
    end
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
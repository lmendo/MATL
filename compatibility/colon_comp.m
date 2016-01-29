function y = colon(varargin)
% Implements Matlab's `colon` function
if nargin==2
    y = varargin{1}:varargin{2};
elseif nargin==3
    y = varargin{1}:varargin{2}:varargin{3};
else
    error('Incorrect number of inputs')
end
end
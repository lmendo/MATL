function y = circshift(varargin)
% Implements three-input version. It does so by using an equivalent
% two-input call where the second input is a vector
%   Also, in the two-input version allows vector to have more elements than
% the number of dimensions of input. The extra elements do nothing (those dimensions are singleton),
% so they are simply removed
if nargin<3
    v = varargin{2};
    if numel(v) > ndims(varargin{1})
        v = v(1:ndims(varargin{1}));
    end
    y = builtin('circshift', varargin{1}, v);
elseif nargin==3
    v = zeros(1,ndims(varargin{1}));
    v(varargin{3}) = varargin{2};
    y = builtin('circshift', varargin{1}, v);
end
end
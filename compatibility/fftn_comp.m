function y = fftn(varargin)
% For two inputs, if second input has a zero it gives an empty result with the
% size specified by the second input, like Matlab does, instead of giving
% an error
if nargin==2 && any(varargin{2}==0)
    y = ones(varargin{2});
else
    y = builtin('fftn', varargin{:});
end
end
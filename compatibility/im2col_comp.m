function y = im2col(varargin)                                      
% Fixes behaviour
argin1 = varargin{1}; argin1 = reshape(argin1, size(argin1,1), []);
y = builtin('im2col', argin1, varargin{2:end});   
end
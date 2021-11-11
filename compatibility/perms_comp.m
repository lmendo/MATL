function y = perms(x)
% Linearizes non-vector input, so that it gives the same result as in Matlab; except for order,
% which is different even for vector input
if ~isvector(x)
    x = reshape(x, 1, []);
end
y = builtin('perms', x);
end
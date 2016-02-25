function y = logical(x)
% Allows char input
if ischar(x)
    x = double(x);
end
y = builtin('logical', x);
end
function y = lcm(a,b)
% Patch for allowing char input
if ischar(a)
    a = double(a);
end
if ischar(b)
    b = double(b);
end
y = builtin('lcm', a, b);
end
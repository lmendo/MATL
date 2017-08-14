function y = gcd(a,b)
% Patch for allowing char input
if ischar(a)
    a = double(a);
end
if ischar(b)
    b = double(b);
end
y = builtin('gcd', a, b);
end
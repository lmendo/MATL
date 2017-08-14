function x = cconv(a,b,N)
% Inputs a and b should be vectors. The output has the orientation of a
if nargin < 3
    N = numel(a) + numel(b) - 1;
end

iscol = iscolumn(a);
a = wrap(a(:).',N);
b = wrap(b(:).',N);
x = ifft(fft(a,N).*fft(b,N));
if iscol
    x = x.';
end
end

function y = wrap(x,N)
% x should be a row vector
    d = ceil(numel(x)/N);
    r = d*N-numel(x);
    y = sum(reshape([x zeros(1,r)],[],d).',1);
end
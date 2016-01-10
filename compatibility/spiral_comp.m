function s = spiral(n)
% This function doesn't exist in Octave
s = zeros(n,n); i = ceil(n/2); j = ceil(n/2);
s(i,j) = 1; if n == 1, return, end
k = 1; d = 1;
for p = 1:n
    q = 1:min(p,n-1); j = j+d*q; k = k+q; s(i,j) = k; if (p == n), return, end
    j = j(p); k = k(p); i = i+d*q'; k = k+q'; s(i,j) = k; i = i(p); k = k(p); d = -d;
end
end
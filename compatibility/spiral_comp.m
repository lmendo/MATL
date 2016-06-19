function y = spiral(N)
% Implementation of `spiral`. It's slow, because the matrix is grown
ss = reshape([1:N-1; 2:N], 1, []);
y = 1;
for s = ss;
    y = [y (y(1,end)+1:y(1,end)+s).'];
    y = rot90(y);
end
y = rot90(y, -numel(ss));
end



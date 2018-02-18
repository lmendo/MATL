function y = nnz(x)
% Octave treats ranges specially to save memory: https://www.gnu.org/software/octave/doc/v4.2.0/Ranges.html
% When applying `nnz` to a range an error occurs. It seems to be solved by linearizing the input (that is,
% applying index `(:)`). That probably turns the range into an actual column vector
y = builtin('nnz', x(:));
end
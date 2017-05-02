function y = str2double(x)
% Linearizes char input to a row, like Matlab does 
if ischar(x)
    x = x(:).';
end
y = builtin('str2double', x);
end
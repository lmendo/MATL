function disp(x)
% Avoids newline for '' input, or any output at all for [] input 
if isempty(x)
    return
end
builtin('disp', x);
end
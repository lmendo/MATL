function disp(x)
% Avoids newline for '' input, or any output at all for [] input 
%   Changes char(0) to space (Matlab displays char(0) as a space; Octave displays it as a space or
% as nothing, depending on platform)
if isempty(x)
    return
end
if ischar(x)
    x(x==0) = ' ';
end
builtin('disp', x);
end
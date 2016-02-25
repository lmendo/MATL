function f = str2func(s)
% Adds functionality of the form f = str2func('@(x) max(x)') (Octave's
% str2func only works in the form f = str2func('max'))
try
    f = builtin('str2func', s);
catch
    if s(1)=='@' % check for security
        eval(['f = ' s ';']);
    else
        error('Content not allwed in string')
    end
end
end
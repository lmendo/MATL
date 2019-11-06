function varargout = disp(x, wh)
if ~isa(x, 'sym') % No output, no wh
    % Avoids newline for '' input, or any output at all for [] input
    if isempty(x)
        return
    end
    builtin('disp', x);
else
    % The code below is similar to that of sym/disp (Octave 4.2.2), except that a subfunction
    % ('make_indented') is transformed into normal code. This code is included here because
    % I don't know how to call `sym/disp` when shadowed by another function called `disp`;
    % `builtin('disp', ...)` doesn't work as expected (probably because `sym/disp` is not a
    % builtin function. And `disp` had to be shadowed because of the above (non-sym case)
    % Also, I change the padding n from 2 to 0. This effectively makes the original
    % 'make_indented' function do nothing. So the code is commented out, to save time
    if (nargin == 1)
        wh = sympref('display'); % read config to see how to display x
    end
    switch lower(wh)
    case 'flat'
        s = x.flat;
    case 'ascii'
        s = x.ascii;
    case 'unicode'
        s = x.unicode;
    otherwise
        print_usage ();
    end
    %n = 0; % begin of original 'make_indented' subfunction. Originally 2. With 0 it does nothing
    %pad = char (double (' ')*ones (1,n));
    %newl = sprintf('\n');
    %s = strrep (s, newl, [newl pad]);
    %s = [pad s];  % end of 'make_indented'
    if (nargout == 0)
        disp(s)
    else
        varargout = {[s newl]};  % add a newline
    end
end
end
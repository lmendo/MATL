function [m, state] = str2num (s)
% Uses `try eval(x); catch ...; end instead of `eval(x,y)`, which seems to be buggy
% Defines (shadows) e so that a loose 'e' in the input string doesn't give exp(1)
  e = @()[];
  if (nargin != 1)
    print_usage ();
  elseif (! ischar (s))
    error ("str2num: S must be a string or string array");
  endif
  s(:, end+1) = ";";
  s = sprintf ("m = [%s];", reshape (s', 1, numel (s)));
  state = true;
  try eval(s); catch m = []; state = false; end
  if (ischar (m))
    m = [];
    state = false;
  endif
endfunction
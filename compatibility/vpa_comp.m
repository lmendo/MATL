function y = vpa(varargin);
% (1) vpa in Octave produces a lot of unwanted displayed text. It's directly displayed, not part of the
% function  output. I didn't found a way to remove it (I tried changing
% PAGER). But Dennis uses a clever trick (with "tail") to remove that output in the
% online compiler
% (2) (i) After converting to char, the result is different from Matlab. For
% example, char(vpa(pi^pi)) produces the string
%     'Float(''36.462159607207901501624291995540261'', prec=32)''
% instead of just the string
%     '36.46215960720790150162429199554' as in Matlab.
% (ii) Also, precision is lost by using `char`: char(vpa('-3.4')) gives the
% string
%     'Float(''-3.3999999999999999999999999999999988'', prec=32)'
% Both (i) and (ii) seem to be resolved by `pretty` (which actually calls `disp`):
% `pretty(vpa('-3.4'))` gives the string
%     '-3.4000000000000000000000000000000'
% However, `pretty` formats the output string with spaces and newlines. These
% characters are removed if we are sure they are unwanted: real scalars
y = pretty(builtin('vpa', varargin{:}));
if isscalar(varargin{1}) && isreal(double(varargin{1})) 
    y = y(y>32); % remove spaces and newlines produced by `pretty`
end
% In Octave `pretty(vpa('765.0908',20))` gives '765.09080000000000000'. In Matlab it gives '765.0908', and 765 gives '765.0'.
% To remove surplus zeros in Octave, the following seems to work. It
% doesn't work for complex values, but the complex case seems to have
% precision loss anyway
if ~ismember('I',y) % complex case not covered
    y = regexprep(y,'(?<=\.\d*)0+(?=(e|$))','0');
end
end
function y = vpa(varargin);
% (1) vpa in Octave produces a lot of unwanted displayed text. It's directly displayed, not part of the
% function  output. I didn't found a way to removed (I tried changing
% PAGER). But Dennis uses a clever trick to remove that output in the
% online compiler
% (2) (i) After converting to char, the result is different from Matlab. For
% example, char(vpa(pi^pi)) produces the string
%     'Float(''36.462159607207901501624291995540261'', prec=32)''
% instead of just the string
%     '36.46215960720790150162429199554' as in Matlab.
% (ii) Also, precision is lost by using `char`: char(vpa('-3.4')) gives the
% string
%     'Float(''-3.3999999999999999999999999999999988'', prec=32)'
% Both (i) and (ii) seem to be resolved by `pretty`:
% `pretty(vpa('-3.4'))` gives the string
%     '-3.4000000000000000000000000000000'
% However, `pretty` formats the output string with spaces and newlines. These
% characters are removed.
y = pretty(builtin('vpa', varargin{:}));
y = y(y>32); % remove spaces and newlines produced by `pretty`
end
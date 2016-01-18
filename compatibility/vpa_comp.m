function y = vpa(varargin);
% vpa in Octave produces a lot of unwanted displayed text. It's directly displayed, not part of the
% function  output. So we evaluate the function to get rid of the text.
% `builtin` serves to do the evaluation.
%   After converting to char, the result is different from Matlab. For
% example, char(vpa(pi^pi)) produces the string
%     'Float(''36.462159607207901501624291995540261'', prec=32)''
% instead of just the string
%     '36.46215960720790150162429199554' as in Matlab.
% Also, precisions is lost by using `char`: char(vpa('-3.4')) gives the
% string
%     'Float(''-3.3999999999999999999999999999999988'', prec=32)'
% Both issues seem to be resolved by `pretty`:
% `pretty(vpa('-3.4'))` gives the string
%     '-3.4000000000000000000000000000000'
y = pretty(builtin('vpa', varargin{:}));
end
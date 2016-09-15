function y = strcat(varargin)
% Octave's strcat does not trim space at the end when there is a single
% string as input. Matlab's does.
% This patch reproduces Matlab's behaviour
if numel(varargin)==1 && ischar(varargin{1})
    y = deblank(varargin{1});
else
    y = builtin('strcat', varargin{:});
end
end
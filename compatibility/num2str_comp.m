function y = num2str(varargin)
% Avoids '-0' in result by the simple procedure of adding 0 to the input
% if it's numeric. ('-0' arises in Octave because of "negative 0". It turns
% out that adding "(positive) 0" to "negative 0" gives "(positive) 0".
if isnumeric(varargin{1})
    varargin{1} = varargin{1} + 0;
end 
% Fixes alignment in certain cases
% http://stackoverflow.com/q/34483961/2586922
% https://savannah.gnu.org/bugs/?46770
x = varargin{1}; x = reshape(x, size(x,1),[]);
if nargin==1 || ischar(varargin{1}) || isnumeric(varargin{2}) || any(imag(x(:)))
    y = builtin('num2str', varargin{:});
else
    fmt = varargin{2}; y = sprintf([fmt '\n'], x.'); y = regexp(y, '\n', 'split'); y = y(1:end-1).';
    y = cellfun(@fliplr, y, 'uniformoutput', false); y = char(y); y = fliplr(y);
    y = reshape(y.',[],size(x,1)).'; y = strtrim(y);
end
end
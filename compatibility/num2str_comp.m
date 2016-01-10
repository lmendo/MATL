function y = num2str(varargin)
% Fixes alignment in certain cases
x = varargin{1}; x = reshape(x, size(x,1),[]);
if nargin==1 || ischar(varargin{1}) || isnumeric(varargin{2}) || any(imag(x(:)))
    y = builtin('num2str', varargin{:});
else
    fmt = varargin{2}; y = sprintf([fmt '\n'], x.'); y = regexp(y, '\n', 'split'); y = y(1:end-1).';
    y = cellfun(@fliplr, y, 'uniformoutput', false); y = char(y); y = fliplr(y);
    y = reshape(y.',[],size(x,1)).'; y = strtrim(y);
end
end
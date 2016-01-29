function y = nchoosek(varargin)
% Allows first input to be non-numeric
if ~isnumeric(varargin{1}) || numel(varargin{1})>1
    if numel(varargin{1}) >= varargin{2}
        y = builtin('nchoosek', 1:numel(varargin{1}), varargin{2});
        y = varargin{1}(y);
    else
        y = ones(0,varargin{2});
    end
else
    y = builtin('nchoosek', varargin{:});
end    
end
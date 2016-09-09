function y = blkdiag(varargin)
% Allows char input
ind = cellfun(@ischar, varargin);
for k = find(ind)
    varargin{k} = double(varargin{k});
end
y = builtin('blkdiag', varargin{:});
if any(ind)
    y = char(y);
end
end
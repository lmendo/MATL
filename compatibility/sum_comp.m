function y = sum(varargin)
% Adds 'omitnan'  functionality
if nargin>1 && strcmp(varargin{end},'omitnan') 
    y = nansum(varargin{1:end-1});
else
    y = builtin('sum', varargin{:});
end
end
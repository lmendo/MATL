function y = mean(varargin)
% Adds 'omitnan'  functionality
if nargin>1 && strcmp(varargin{end},'omitnan') 
    y = nanmean(varargin{1:end-1});
else
    y = builtin('mean', varargin{:});
end
end
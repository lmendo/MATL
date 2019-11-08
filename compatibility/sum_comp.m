function y = sum(varargin)
% Adds 'omitnan'  functionality
if nargin>1 && strcmp(varargin{end},'omitnan') 
    y = nansum(varargin{1:end-1});
else
    if ~isa(varargin{1},'sym')
        y = builtin('sum', varargin{:});
    else
        y = builtin('@sym/sum', varargin{:});
    end
end
end
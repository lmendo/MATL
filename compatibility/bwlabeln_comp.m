function varargout = bwlabeln(varargin)
% bwlabeln(1), bwlabeln(8), bwlabeln(true) give an error on TIO. This patches that
if numel(varargin{1})==1 && varargin{1} % patch
    varargout{1} = 1;
    if nargout>1
        varargout{2} = 1;
    end
else % normal call to bwlabeln
    [varargout{1:nargout}] = builtin('bwlabeln', varargin{:});
end
end
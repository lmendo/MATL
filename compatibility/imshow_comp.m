function varargout = imshow(varargin)
% Avoid image size being scaled. That is, make one image pixel equal one screen pixel. That's what Matlab does by default
h = builtin('imshow', varargin{:});
sz = size(get(h, 'CData'));
sz = sz([2 1]);
set(gcf, 'Units', 'pixels')
sc = get(0,'ScreenSize');
sc = sc([3 4]);
set(gcf, 'Position', [floor((sc-sz)/2) sz]); % Place the figure in the center of the screen
set(gca, 'Position', [0 0 1 1])
if nargout
    varargout{1} = h;
end
end
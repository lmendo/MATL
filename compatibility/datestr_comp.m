function y = datestr(varargin)
% Corrects bug in format 16, which produces things like '22:19 PM' instead
% of '10:19 PM'
y = builtin('datestr', varargin{:});
if numel(varargin)>=2 && (strcmp(varargin{2},'HH:MM PM') || isequal(varargin{2}, 16))
    t = num2str([(mod(str2num(y(:,1:2))-1,12)+1); 11]); % 11 is to force two chars
    y(:,1:2) = t(1:end-1,:);
end
end
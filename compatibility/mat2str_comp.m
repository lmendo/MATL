function z = mat2str(varargin)
% Patch for handling char input (Octave can't)
% Newlines are not dealt with
if ischar(varargin{1});
    severalRows = size(varargin{1},1)>1;
    if severalRows
        z = num2cell(varargin{1},2);
        z = regexprep(z, '''', '''''');
        z = strcat('''', z, ''';');
        z = horzcat(z{:});
        z = [ '[' z(1:end-1)  ']'];
    else
        z = regexprep(varargin{1}, '''', '''''');
        z = strcat('''', z, '''');
    end
else
    z = builtin('mat2str', varargin{:});
end
end
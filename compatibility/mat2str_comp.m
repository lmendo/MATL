function z = mat2str(varargin)
% Patch for handling char input (Octave can't)
% Newlines are not dealt with
if ischar(varargin{1});
    severalRows = size(varargin{1},1)>1;
    if severalRows
        z = num2cell(varargin{1},2);
        z = regexprep(z, '''', '''''');
        z = strcat('''', z, ''';'); % We use strcat here because z is a cell array. Trailing spaces are correctly preserved
        z = horzcat(z{:});
        z = [ '[' z(1:end-1)  ']'];
    else
        z = regexprep(varargin{1}, '''', '''''');
        z = horzcat('''', z, ''''); % We use horzcat here because z is a string, and trailing spaces would be incorrectly removed by strcat
    end
else
    z = builtin('mat2str', varargin{:});
end
end
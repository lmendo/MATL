function F = genFunDef(masterFileName, fileName)
%
% Generates function definition struct array "F" from tab-separated text
% file, and saves it in file.
%
% The tab-separated file has one or more lines for each function.
% The first line for each function contains its source code in the first
% column. If a function has the sixth column ("body") empty, the function
% is considered to be undefined, and is not included in struct array "F".
%
% Wraps function body in a cell, even if it's a single string.
% Function body in the text file may span several strings. This is defined
% using subsequent lines with "source" column empty and "body" field
% filled. In that case, this function collects all lines in a cell array of
% strings.
%
% Luis Mendo

fieldNames = {'source' 'minIn' 'maxIn' 'defIn' 'minOut' 'maxOut' 'defOut' 'consumeInputs' 'wrap' 'body' 'comment' 'description'};
fid = fopen(masterFileName, 'r');
F = reshape(fread(fid,inf,'*char'),1,[]);
fclose(fid);
F = reshape(regexp(F, '[\r\n]+', 'split'),[],1);
ind = cellfun(@(s) ~isempty(s)&&s(1)~='%', F);
F = F(ind);
F = regexp(F, ' *\t *', 'split');
n = numel(fieldNames);
F = cellfun(@(s) [ s(1:min(n,end)) repmat({''},1,max(n-numel(s),0)) ], F, 'uniform', 0); % fill if empty columns
F = vertcat(F{:});
F = F(~cellfun(@isempty, F(:,10)),:); % remove functions that have a line in
% the file but are not actually defined. These are identified because "body"
% column is empty.

% Transform 'consumeInputs' and 'wrap' fields into logical values:
for c = [8 9]
    for r = 1:size(F,1)
        F{r,c} = logical(str2num(F{r,c})); %#ok
    end
end

% Join function body lines corresponding to the same function source into
% a cell array of strings. Single lines are also wrapped into a cell array.
d = [~cellfun('isempty', F(:,1)); true];
starts = find(d(1:end-1));
ends = find(d(2:end));
for n = numel(starts):-1:1 % process from end because F will be shrunk along the way
    F{starts(n),10} = F(starts(n):ends(n),10).';
    F(starts(n)+1:ends(n),:) = [];
end

assert(numel(unique(F(:,1)))==numel(F(:,1)), 'MATL:compiler:internal', 'MATL internal error while reading function definition file: function names are not unique')

F = cell2struct(F, fieldNames, 2);
save(fileName, 'F')
function matl_help(H, strHelp, verbose, useTags)
%
% MATL help.
%
% Search for input string and show corresponding help.
%
% Luis Mendo

if verbose
    disp('MATL help:')
end

if useTags
    strongBegin = '<strong>';
    strongEnd = '</strong>';
else
    strongBegin = '';
    strongEnd = '';
end

if isempty(strHelp) || strcmp(strHelp,'help') % empty string: show help usage and return
    if verbose
        fprintf('  General help\n')
        fprintf('\n')
    end
    fprintf('%smatl%s usage:\n', strongBegin, strongEnd)
    fprintf('First input: options:\n')
    fprintf('  %s-p%s: parse\n', strongBegin, strongEnd)
    fprintf('  %s-l%s: listing. Numeric options specify format\n', strongBegin, strongEnd)
    fprintf('  %s-e%s: listing with comments. Numeric options specify format\n', strongBegin, strongEnd)
    fprintf('  %s-c%s: compile\n', strongBegin, strongEnd)
    fprintf('  %s-r%s: run (default)\n', strongBegin, strongEnd)
    fprintf('  %s-d%s: debug\n', strongBegin, strongEnd)
    fprintf('  %s-f%s: use file\n', strongBegin, strongEnd)
    fprintf('  %s-v%s: verbose\n', strongBegin, strongEnd)
    fprintf('  %s-h%s: help.\n', strongBegin, strongEnd)
    fprintf('Second input: string:\n')
    fprintf('  Contains source code, file name or search text\n')
    fprintf('  Source code or file name can be omitted. In that case they are introduced later\n')
    fprintf('  Search text can be a name of function or statement, or a word.\n')
    return
elseif numel(strHelp)==1 || (numel(strHelp)==2 && any(strHelp(1)=='XYZ'))  % search in source
    if verbose
        fprintf('  Searching for statement with exact matching\n')
    end
    ind = find(strcmp(H.sourcePlain, strHelp)); % exact search in source
elseif ~isempty(strHelp) % search in comment or description
    if verbose
        fprintf('  Searching for text, case-insensitive, partial matching\n')
    end
    ind = find(~cellfun(@isempty, strfind(lower(H.comm), lower(strHelp))) |...
        ~cellfun(@isempty, strfind(lower(H.descrPlain), lower(strHelp)))); % partial, case-insentive search in comment and description
end

if verbose && ~isempty(ind)
    disp(' ')
end
if useTags
    descrFieldName = 'descr';
    sourceFieldName = 'source';
else
    descrFieldName = 'descrNoTags';
    sourceFieldName = 'sourcePlain';
end
for n = ind
    disp([H.(sourceFieldName){n} repmat(' ',1,4-numel(H.sourcePlain{n})) H.comm{n}]) % one or two spaces for left margin, total four characters
    if ~isempty(H.in{n}) && ~isempty(H.in{n})
        disp(['    ' H.in{n}, ';  ' H.out{n}]) % four spaces for left margin
    end
    disp(H.(descrFieldName){n})
end
if verbose && ~isempty(ind)
    disp(' ')
end


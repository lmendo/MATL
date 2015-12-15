function matl_help(H, strHelp, verbose)
%
% MATL help.
%
% Search for input string and show corresponding help.
%
% Luis Mendo

if verbose
    disp('MATL help:')
end
if isempty(strHelp) || strcmp(strHelp,'help') % empty string: show help usage and return
    if verbose
        disp('  General help')
        disp(' ')
    end
    disp('<strong>matl</strong> usage:')
    disp('First input: options:')
    disp('  <strong>-p</strong>: parse')
    disp('  <strong>-l</strong>: listing. Numeric options specify format')
    disp('  <strong>-e</strong>: listing with comments. Numeric options specify format')
    disp('  <strong>-c</strong>: compile')
    disp('  <strong>-r</strong>: run (default)')
    disp('  <strong>-d</strong>: debug')
    disp('  <strong>-f</strong>: use file')
    disp('  <strong>-v</strong>: verbose')
    disp('  <strong>-h</strong>: help.')
    disp('Second input: string:')
    disp('  Contains source code, file name or search text')
    disp('  Source code or file name can be omitted. In that case they are introduced later')
    disp('  Search text can be a name of function or statement, or a word.')
    return
elseif numel(strHelp)==1 || (numel(strHelp)==2 && any(strHelp(1)=='XYZ'))  % search in source
    if verbose
        disp('  Searching for statement with exact matching')
    end
    ind = find(strcmp(H.sourcePlain, strHelp)); % exact search in source
elseif ~isempty(strHelp) % search in comment or description
    if verbose
        disp('  Searching for text, case-insensitive, partial matching')
    end
    ind = find(~cellfun(@isempty, strfind(lower(H.comm), lower(strHelp))) |...
        ~cellfun(@isempty, strfind(lower(H.descrPlain), lower(strHelp)))); % partial, case-insentive search in comment and description
end

if verbose && ~isempty(ind)
    disp(' ')
end
for n = ind
    disp([H.source{n} repmat(' ',1,4-numel(H.sourcePlain{n})) H.comm{n}]) % one or two spaces for left margin, total four characters
    if ~isempty(H.in{n}) && ~isempty(H.in{n})
        disp(['    ' H.in{n}, ';  ' H.out{n}]) % four spaces for left margin
    end
    disp(H.descr{n})
end
if verbose && ~isempty(ind)
    disp(' ')
end


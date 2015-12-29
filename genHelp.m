function H = genHelp(F, L)
%
% Generates help struct array "H" from struct array "F" (functions) and
% additional information coded directly here (non-functions), and saves it
% in file "help.mat"
%
% Luis Mendo.


N = 65; % characters per line

% Non-functions. Changes done here should be don in `genHelp.m` too

% Statements that are not functions. Changes done here to the comment field should be
% done in `matl_disp.m` too.
F(end+1).source = '"';
F(end).comment = 'for';
F(end).description = '\matlab+for+ (control flow: loop). \sa \matl+]+, \matl+@+, \matl+X}+, \matl+Y}+';

F(end+1).source = '`';
F(end).comment = 'do...while';
F(end).description = 'do...while (control flow: loop). \sa \matl+X`+, \matl+]+, \matl+@+, \matl+X}+, \matl+Y}+';

F(end+1).source = 'X`';
F(end).comment = 'while';
F(end).description = '\matlab+while+ (control flow: loop). \sa \matl+`+, \matl+]+, \matl+@+, \matl+X}+, \matl+Y}+';

F(end+1).source = '?';
F(end).comment = 'if';
F(end).description = '\matlab+if+ (control flow: conditional branch). \sa \matl+]+, \matl+}+';

F(end+1).source = '}';
F(end).comment = 'else';
F(end).description = '\matlab+else+ (control flow: conditional branch). \sa \matl+?+';

F(end+1).source = '@';
F(end).comment = 'for loop variable or do...while / while loop iteration index';
F(end).description = 'for loop variable, do...while loop iteration index or while loop iteration index of innermost loop';

F(end+1).source = ']';
F(end).comment = 'end';
F(end).description = '\matlab+end+ (control flow). End loop or conditional branch. \sa \matl+"+, \matl+`+, \matl+?+';

F(end+1).source = '.';
F(end).comment = 'conditional break';
F(end).description = 'conditional \matlab+break+ (control flow: loop). Consume the top of the stack and, if it evaluates to ''true'' acccording to \matlab+if+ rules, terminate execution of innermost loop. \sa \matl+"+, \matl+`+';

F(end+1).source = 'X.';
F(end).comment = 'conditional continue';
F(end).description = 'conditional \matlab+continue+ (control flow: loop). Consume the top of the stack and, if it evaluates to ''true'' acccording to \matlab+if+ rules, pass control to next iteration of innermost loop. \sa \matl+"+, \matl+`+';

F(end+1).source = '''';
F(end).comment = 'string delimiter';
F(end).description = 'string delimiter. Should be doubled when used within a string';

F(end+1).source = ',';
F(end).comment = 'separator';
F(end).description = 'separator. Space and newline can be used as separators too';

F(end+1).source = '%';
F(end).comment = 'comment';
F(end).description = 'comment. The rest of the line is ignored';

% Sort according to source
[~, ind] = sort(cellfun(@(x) x(end:-1:1), {F.source}, 'UniformOutput', 0));
F = F(ind);

commFormatted = {F.comment};
descrFormatted = {F.description};
descrFormatted = regexprep(descrFormatted, '\\matlab(.)(.*?)(\1)', '<strong>$2</strong>');
descrFormatted = regexprep(descrFormatted, '\\matl\+(.*?)\+', '<strong>$1</strong>'); %***make delimiter arbitrary her too
descrFormatted = regexprep(descrFormatted, '\\comp{(.*?)}', '<strong>$1</strong>');
descrFormatted = regexprep(descrFormatted, '\\sa', 'See also');
descrFormatted = regexprep(descrFormatted, '\$(.*?)\$', '$1');
descrPlain = cell(1,numel(descrFormatted));
inFormatted = cell(1,numel(descrFormatted));
outFormatted = cell(1,numel(descrFormatted));
sourceFormatted = cell(1,numel(descrFormatted));
sourcePlain = {F.source};

for n = 1:numel(descrFormatted)
    % Format source
    sourceFormatted{n} = ['<strong>' F(n).source '</strong>'];
    
    % Add information on predefined literals, if applicable
    if ~isempty(regexp(F(n).source,'[XYZ]\d','once')) && isfield(L, (F(n).source)) % X0...Z9 that are defined
        aux = [num2cell(L.(F(n).source).key); L.(F(n).source).val];
        descrFormatted{n} = [ descrFormatted{n} '. ' sprintf('%i: %s; ', aux{:})];
    end        
    
    % Format description
    descrFormatted{n}(end+1) = ' '; % needed so that the "find" line always finds last index
    [s, e] = regexp(descrFormatted{n},'<strong>','start','end');
    descrMask = true(1,numel(descrFormatted{n}));
    descrSpace = false(1,numel(descrFormatted{n}));
    for m = 1:numel(s)
        descrMask(s(m):e(m)) = false;
    end
    [s, e] = regexp(descrFormatted{n},'</strong>','start','end');
    for m = 1:numel(s)
        descrMask(s(m):e(m)) = false;
    end
    descrPlain{n} = descrFormatted{n}(descrMask);
    s = regexp(descrFormatted{n},'\s','start');
    descrSpace(s) = true;
    d = {};
    while ~isempty(descrMask)
        c = cumsum(descrMask);
        ind = find((c<=N)& descrSpace, 1, 'last');
        d{end+1} = descrFormatted{n}(1:ind);
        descrFormatted{n}(1:ind) = [];
        descrMask(1:ind) = [];
        descrSpace(1:ind) = [];
    end
    % descrFormatted{n} = char(d); % gives a char 2D array. Bad for searching
    d = sprintf('    %s\n', d{:}); % four spaces for left margin
    descrFormatted{n} = d(1:end-1); % remove last '\n'
    
    % Format input spec:
    minIn = str2double(F(n).minIn);
    maxIn = str2double(F(n).maxIn);
    defIn = str2double(F(n).defIn);
    minOut = str2double(F(n).minOut);
    maxOut = str2double(F(n).maxOut);
    defOut = str2double(F(n).defOut);

    if isnan(defIn) && ~isempty(F(n).defIn) % F(n).defIn contains a string that couldn't be converted to a number
        switch F(n).defIn
        case 'numel(STACK)'
            defInStr = 'number of elements in stack';
        otherwise
            error('Unrecognized default number of inputs')
        end
    else
        defInStr = sprintf('%i', defIn);
    end
    
    if isempty(F(n).minIn) || isempty(F(n).maxIn)
        inFormatted{n} = [];
    elseif minIn ~= maxIn
        if isfinite(maxIn)
            inFormatted{n} = sprintf('%i--%i (%s)', minIn, maxIn, defInStr);
        else
            inFormatted{n} = sprintf('%i-- (%s)', minIn, defInStr);
        end
    else
        if maxIn ~= defIn
            error('Incorrect specification of number of inputs')
        end
        inFormatted{n} = sprintf('%i', defIn);
    end

    % Format output spec:
    if isnan(defOut) && ~isempty(F(n).defOut) % F(n).defOut contains a string that couldn't be converted to a number
        switch F(n).defOut
        case {'numel(CB_H)' 'numel(CB_I)' 'numel(CB_J)' 'numel(CB_K)'}
            defOutStr = 'number of elements in clipboard';
        case 'numel(CB_L{in{1}})'
            defOutStr = 'number of elements in clipboard level';
        case 'numel(in{1})'
            defOutStr = 'number of elements of first input';
        otherwise
            error('Unrecognized default number of outputs')
        end
    else
        defOutStr = sprintf('%i', defOut);
    end

    if isempty(F(n).minOut) || isempty(F(n).maxOut)
        outFormatted{n} = [];
    elseif minOut ~= maxOut
        if isfinite(maxOut)
            outFormatted{n} = sprintf('%i--%i (%s)', minOut, maxOut, defOutStr);
        else
            outFormatted{n} = sprintf('%i-- (%s)', minOut, defOutStr);
        end
    else
        if maxOut ~= defOut
            error('Incorrect specification of number of inputs')
        end
        outFormatted{n} = sprintf('%i', defOut);
    end
end

%
descrNoTags = regexprep(descrFormatted,{'<strong>', '</strong>'}, '');

H.source = sourceFormatted;
H.comm = commFormatted;
H.descr = descrFormatted; % description with format including tags
H.descrNoTags = descrNoTags; % description with format but without tags
H.in = inFormatted;
H.out = outFormatted;
H.sourcePlain = sourcePlain;
H.descrPlain = descrPlain;
save help H



function H = genHelp(F, L)
%
% Generates help struct array "H" from struct array "F" (functions) and
% additional information coded directly here (non-functions), and saves it
% in file "help.mat"
%
% Luis Mendo.


N = 65; % characters per line

% Statements that are not functions. Changes done here to the comment field should be
% done in `matl_disp.m` too.
F(end+1).source = '$';
F(end).comment = 'input specification';
F(end).description = 'specify inputs for next function';

F(end+1).source = '#';
F(end).comment = 'output specification';
F(end).description = 'specify outputs for next function';

F(end+1).source = '&';
F(end).comment = 'alternative input/output specification';
F(end).description = 'alternative specification of inputs and outputs for next function';

F(end+1).source = '"';
F(end).comment = 'for';
F(end).description = '\matlab+for+ (control flow: loop). \sa \matl+]+, \matl+@+, \matl+X@+, \matl+.+, \matl+X.+';

F(end+1).source = '`';
F(end).comment = 'do...while';
F(end).description = 'do...while (control flow: loop). \sa \matl+X`+, \matl+]+, \matl+@+, \matl+.+, \matl+X.+';

F(end+1).source = 'X`';
F(end).comment = 'while';
F(end).description = '\matlab+while+ (control flow: loop). \sa \matl+`+, \matl+]+, \matl+@+, \matl+.+, \matl+X.+';

F(end+1).source = '?';
F(end).comment = 'if';
F(end).description = '\matlab+if+ (control flow: conditional branch). \sa \matl+]+, \matl+}+';

F(end+1).source = '}';
F(end).comment = 'else / finally';
F(end).description = '\matlab+else+ (control flow: conditional branch) or \matlab+finally+ (control flow: do...while or while loop). \sa \matl+?+, \matl+`+, \matl+X`+';

F(end+1).source = '@';
F(end).comment = 'for loop variable or do...while / while loop iteration index';
F(end).description = 'for loop variable, do...while loop iteration index or while loop iteration index of innermost loop. \sa \matl+X@+';

F(end+1).source = 'X@';
F(end).comment = 'for loop iteration index';
F(end).description = 'for loop iteration index of innermost loop. \sa \matl+@+';

F(end+1).source = ']';
F(end).comment = 'end';
F(end).description = '\matlab+end+ (control flow). End loop or conditional branch. \sa \matl+"+, \matl+`+, \matl+X`+, \matl+?+';

F(end+1).source = '.';
F(end).comment = 'break';
F(end).description = '\matlab+break+ (control flow: loop). Terminate execution of innermost loop. \sa \matl+"+, \matl+`+, \matl+X`+';

F(end+1).source = 'X.';
F(end).comment = 'continue';
F(end).description = '\matlab+continue+ (control flow: loop). Pass control to next iteration of innermost loop. \sa \matl+"+, \matl+`+, \matl+X`+';

F(end+1).source = '''';
F(end).comment = 'string delimiter';
F(end).description = 'string delimiter. Should be doubled when used within a string';

%F(end+1).source = ' ';
%F(end).comment = 'separator';
%F(end).description = 'separator. Newline can be used as separator too';

F(end+1).source = '%';
F(end).comment = 'comment';
F(end).description = 'comment. The rest of the line is ignored';

% Sort according to source
[~, ind] = sort(cellfun(@(x) x(end:-1:1), {F.source}, 'UniformOutput', 0));
F = F(ind);

commFormatted = {F.comment};
descrFormatted = {F.description};
descrFormatted = regexprep(descrFormatted, '\\matlab(.)(.*?)(\1)', '<strong>$2</strong>');
descrFormatted = regexprep(descrFormatted, '\\matl(.)(.*?)\1', '<strong>$2</strong>'); % delimiter can be any
descrFormatted = regexprep(descrFormatted, '\\comp{(.*?)}', '<strong>$1</strong>');
descrFormatted = regexprep(descrFormatted, '\\sa', 'See also');
descrFormatted = regexprep(descrFormatted, '\$(.*?)\$', '$1');
descrPlain = cell(1,numel(descrFormatted));
inFormatted = cell(1,numel(descrFormatted));
outFormatted = cell(1,numel(descrFormatted));
inOutTogether = cell(1,numel(descrFormatted));
sourceFormatted = cell(1,numel(descrFormatted));
sourcePlain = {F.source};

for n = 1:numel(descrFormatted)
    % Format source
    sourceFormatted{n} = ['<strong>' F(n).source '</strong>'];
    
    % Add information on predefined literals, if applicable
    if ~isempty(regexp(F(n).source,'[XYZ]\d','once')) && isfield(L, (F(n).source)) % X0...Z9 that are defined
        aux = [num2cell(L.(F(n).source).key); L.(F(n).source).val];
        descrFormatted{n} = [ descrFormatted{n} '. ' sprintf('%i: <strong>%s</strong>, ', aux{:})];
        descrFormatted{n} = descrFormatted{n}(1:end-2); % remove final comma and space
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
    
    % Values for formatting input and output specs
    minIn = str2double(F(n).minIn);
    maxIn = str2double(F(n).maxIn);
    defIn = str2double(F(n).defIn);
    altIn = str2double(F(n).altIn);
    minOut = str2double(F(n).minOut);
    maxOut = str2double(F(n).maxOut);
    defOut = str2double(F(n).defOut);
    altOut = str2double(F(n).altOut);

    % Special strings for defIn. Changes done here should also be done in genFunDefTableLatex.m and in MATL_spec.tex too.
    if isnan(defIn) && ~isempty(F(n).defIn) % F(n).defIn contains a string that couldn't be converted to a number
        switch F(n).defIn
        case 'numel(STACK)'
            defInStr = 'number of elements in stack';
        case 'double(numel(CB_G)>1)'
            defInStr = '0 if clipboard currently has 0 or 1 levels, 1 otherwise';
        otherwise
            error('Unrecognized default number of inputs')
        end
    else
        defInStr = sprintf('%i', defIn);
    end
    
    % Special strings for altIn. Changes done here should also be done in genFunDefTableLatex.m and in MATL_spec.tex too.
    if isnan(altIn) && ~isempty(F(n).altIn) % F(n).altIn contains a string that couldn't be converted to a number
        switch F(n).altIn
        case 'numel(STACK)'
            altInStr = 'number of elements in stack';
        otherwise
            error('Unrecognized alternative number of inputs')
        end
    elseif isempty(F(n).altIn)
        altInStr = '';
    else
        altInStr = sprintf('%i', altIn);
    end

    % Format input spec
    if isempty(F(n).minIn) || isempty(F(n).maxIn)
        inFormatted{n} = [];
    elseif (minIn ~= maxIn) && isempty(altInStr)
        if isfinite(maxIn)
            inFormatted{n} = sprintf('%i--%i (%s)', minIn, maxIn, defInStr);
        else
            inFormatted{n} = sprintf('%i-- (%s)', minIn, defInStr);
        end
    elseif (minIn ~= maxIn) && ~isempty(altInStr)
        if isfinite(maxIn)
            inFormatted{n} = sprintf('%i--%i (%s / %s)', minIn, maxIn, defInStr, altInStr);
        else
            inFormatted{n} = sprintf('%i-- (%s / %s)', minIn, defInStr, altInStr);
        end
    elseif (minOut == maxOut) && ~isempty(altOutStr)
        inFormatted{n} = sprintf('%i (%s / %s)', maxIn, defInStr, altInStr);
    else
        if (maxIn ~= defIn) % || ~isempty(altInStr) % We removed this condition for the same reasons as for the output
            error('Incorrect specification of number of inputs')
        end
        inFormatted{n} = sprintf('%i', defIn);
    end

    % Special strings for defOut. Changes done here should also be done in genFunDefTableLatex.m and in MATL_spec.tex too.
    if (isnan(defOut) || defOut<0) && ~isempty(F(n).defOut) % F(n).defOut contains a string that couldn't be converted to a number, or a negative number
        switch F(n).defOut
        case {'numel(CB_H)' 'numel(CB_I)' 'numel(CB_J)' 'numel(CB_K)'}
            defOutStr = 'number of elements in clipboard';
        case 'numel(CB_L{in{1}})'
            defOutStr = 'number of elements in clipboard level';
        case '1+(in{1}<=numCbM)*(numel(CB_M{mod(in{1}-1,numCbM)+1})-1)'
            defOutStr = '1 or number of elements in clipboard level';
        case 'numel(in{1})'
            defOutStr = 'number of elements of first input';
        case 'prod(size(in{:}))' % Z}
            defOutStr = 'number of elements or subarrays that will be produced';
        case '1+(max(numel(CB_G),1)-1)*(numel(in)==0)'
            defOutStr = 'number of levels addressed according to input specification';
        case 'max(1,sum(ismember(cellfun(@num2str, in(3:end), ''uniformoutput'', false), {''start'' ''end'' ''tokenExtents'' ''match'' ''tokens'' ''split'' ''1'' ''2'' ''3'' ''5'' ''6'' ''7''})))'
            defOutStr = 'according to specified keywords';
        case 'numel(in)'
            defOutStr = 'number of inputs';
        case '-1'
            defOutStr = 'number of elements that will be produced';
        case '-2'
            defOutStr = 'number of subarrays that will be produced';
        otherwise
            error('Unrecognized default number of outputs')
        end
    else
        defOutStr = sprintf('%i', defOut);
    end
    
    % Special strings for altOut. Changes done here should also be done in genFunDefTableLatex.m and in MATL_spec.tex too.
    if isnan(altOut) && ~isempty(F(n).altOut) % F(n).altOut contains a string that couldn't be converted to a number
        switch F(n).altOut
        case {'[false true]' '[false,true]' '[false, true]'}
            altOutStr = '2nd'; % It should be specified '2nd of 2'. But it's longer. Up to now its always "x-th
            % up to the maximum number", so I don't specify
            case {'[false true false]' '[false,true,false]' '[false, true, false]'}
            altOutStr = '2nd';
        otherwise
            error('Unrecognized alternative number of outputs')
        end
    elseif isempty(F(n).altOut)
        altOutStr = '';
    else
        altOutStr = sprintf('%i', altOut);        
    end    
    
    % Format output spec
    if isempty(F(n).minOut) || isempty(F(n).maxOut)
        outFormatted{n} = [];
    elseif (minOut ~= maxOut) && isempty(altOutStr)
        if isfinite(maxOut)
            outFormatted{n} = sprintf('%i--%i (%s)', minOut, maxOut, defOutStr);
        else
            outFormatted{n} = sprintf('%i-- (%s)', minOut, defOutStr);
        end
    elseif (minOut ~= maxOut) && ~isempty(altOutStr)
        if isfinite(maxOut)
            outFormatted{n} = sprintf('%i--%i (%s / %s)', minOut, maxOut, defOutStr, altOutStr);
        else
            outFormatted{n} = sprintf('%i-- (%s / %s)', minOut, defOutStr, altOutStr);
        end
    elseif (minOut == maxOut) && ~isempty(altOutStr)
        outFormatted{n} = sprintf('%i (%s / %s)', maxOut, defOutStr, altOutStr);
    else
        if (maxOut ~= defOut) %|| ~isempty(altOutStr). % We remove the condition on altOutStr because there may be things like minOut==maxOut==defOut==2 and altOutStr = '[false true]'
            error('Incorrect specification of number of outputs')
        end
        outFormatted{n} = sprintf('%i', defOut);
    end
    
    % Flag depending of length of input spec plus output spec
    if numel(inFormatted{n})+numel(outFormatted{n}) <= N*1.1 % same line
        inOutTogether{n} = true;
    else % two separate lines
        inOutTogether{n} = false;
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
H.inOutTogether = inOutTogether;
H.sourcePlain = sourcePlain;
H.descrPlain = descrPlain;
save help H



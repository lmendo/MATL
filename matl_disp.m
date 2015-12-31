function matl_disp(S, F, indentBase, indentStep, indentCommentSymbol, indentCommentText, pOutFile, listing, commentSymbols, commentTexts, verbose)
%
% MATL display.
%
% Show parsed statements with indentation, and save to file.
%
% Luis Mendo

% Save in pOutFile. indentBase, indentCommentSymbol, indentCommentText not used
if verbose
    fprintf('  Writing to file ''%s''\n', pOutFile')
end
fid = fopen(pOutFile,'w');
if ~isempty(S)
    indentation = arrayfun(@(x) {blanks(x*indentStep)}, [S(:).nesting]).';
    d = strcat(indentation, {S(:).source}.'); % indentation and source
    d([S.implicit]) = []; % remove implicit source statements for parsed file
    for n = 1:numel(d)
        if ispc % Windows
            linebreak = '\r\n';
        elseif ismac % Mac
            linebreak = '\r';
        elseif isunix % Unix, Linux
            linebreak = '\n';
        else % others. Not sure what to use here
            linebreak = '\r\n';
        end
        fprintf(fid, ['%s' repmat(linebreak,1,n<numel(d))], d{n}); % avoid linebreak in last line
    end
end
fclose(fid);

% Display on command window
if listing && ~isempty(S)
    indentation = arrayfun(@(x) {blanks(x*indentStep+indentBase)}, [S(:).nesting]).';
    d = strcat(indentation, {S(:).source}.'); % indentation and source
    if commentTexts
        d([S.implicit]) = indentation([S.implicit]); % remove implicit source statements but keep comment texts
    else
        d([S.implicit]) = []; % remove implicit source statements for display without comment texts
    end
    d = char(d);
    if commentSymbols
        d = [d, repmat([blanks(indentCommentSymbol) '%'],size(d,1),1)];
    end
    if commentTexts % Changes done here should be done in `genHelp.m` too
        texts = cell(numel(S),1);
        Stype = {S.type};
        texts(ismember(Stype, {'literal.colonArray.numeric' 'literal.colonArray.char' 'literal.array'})) = {'array literal'};
        texts(ismember(Stype, {'literal.number'})) = {'number literal'};
        texts(ismember(Stype, {'literal.logicalRowArray'})) = {'logical row array literal'};
        texts(ismember(Stype, {'literal.cellArray'})) = {'cell array literal'};
        texts(ismember(Stype, {'literal.string'})) = {'string literal'};
        texts(strcmp(Stype, 'metaFunction.inSpec')) = {'input specification'};
        texts(strcmp(Stype, 'metaFunction.outSpec')) = {'output specification'};
        texts(strcmp(Stype, 'controlFlow.for')) = {'for'};
        texts(strcmp(Stype, 'controlFlow.doWhile')) = {'do...while'};
        texts(strcmp(Stype, 'controlFlow.while')) = {'while'};
        texts(strcmp(Stype, 'controlFlow.if')) = {'if'};
        texts(strcmp(Stype, 'controlFlow.else')) = {'else'};
        texts(strcmp(Stype, 'controlFlow.forValue')) = {'for loop variable'};
        texts(strcmp(Stype, 'controlFlow.doWhileIndex')) = {'do...while loop iteration index'};
        texts(strcmp(Stype, 'controlFlow.whileIndex')) = {'while loop iteration index'};
        texts(strcmp(Stype, 'controlFlow.end')) = {'end'};
        texts(strcmp(Stype, 'controlFlow.conditionalBreak')) = {'conditional break'};
        texts(strcmp(Stype, 'controlFlow.conditionalContinue')) = {'conditional continue'};
        ind = find(ismember(Stype, {'function'}));
        [val, indF] = ismember({S(ind).source}, {F.source}); % val equal to false indicates there's no comment (or perhaps no function)
        texts(ind(val)) = {F(indF(val)).comment};
        texts([S.implicit]) = strcat({'(implicit) '}, texts([S.implicit])); % indicate which statements are implicit
        d = strcat(d, {blanks(indentCommentText)}, texts(:));
    end
    if verbose
        disp('MATL program listing:')
    end
    disp(' ')
    disp(char(d))
    disp(' ')
end

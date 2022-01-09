function genFunDefTableLatex

p = path;
if exist('C:\Users\Luis\Dropbox\MATL', 'dir')
    baseFolder = 'C:\Users\Luis\Dropbox\MATL';
elseif exist('C:\Users\lmendo\Dropbox\MATL', 'dir')
    baseFolder = 'C:\Users\lmendo\Dropbox\MATL';
else
    error('Base folder not found')
end
addpath([baseFolder '\compiler'])

funTableFileName = [ baseFolder '\spec\funDefTable\funDefTable.tex' ];
funDefMatFileName = [ baseFolder '\compiler\funDef.mat' ];
funDefTxtFileName = [ baseFolder '\compiler\funDef.txt' ];

% Update funDef.mat, if needed; or load file
fDTxt = dir(funDefTxtFileName);
if ~isempty(fDTxt)
    fDTxt = datenum(fDTxt.date);
else
    fDTxt = -inf;
end
fDMat = dir(funDefMatFileName);
if ~isempty(fDMat)
    fDMat = datenum(fDMat.date);
else
    fDMat = -inf;
end
if fDMat < fDTxt % regeneration of `funDef.mat` required
    F = genFunDef(funDefTxtFileName, funDefMatFileName); % creates `F` struct array with unique function
    % definitions from funDefTxtFileName file, and saves it in funDefMatFileName file 
else % load `F` variable from funDefMatFileName directly
    load(funDefMatFileName, 'F') % loads F variable
end

lines = {};
notInterpreted = {};
for n = 1:numel(F)
    switch F(n).source
        case '#' % Special case, defined here
            lines{end+1} = '\matl+#+ & 1 & 0 & specify outputs for next function \\';
        case '$' % Special case, defined here
            lines{end+1} = '\matl+$+ & 1 & 0 & specify inputs for next function \\';
        case '&' % Special case, defined here
            lines{end+1} = '\matl+&+ & 0 & 0 & alternative input/output specification for next function \\';
        otherwise
            minInNum = str2double(F(n).minIn);
            maxInNum = str2double(F(n).maxIn);
            minOutNum = str2double(F(n).minOut);
            maxOutNum = str2double(F(n).maxOut);
            defInNum = str2double(F(n).defIn);
            defOutNum = str2double(F(n).defOut);
            defIn = F(n).defIn;
            defOut = F(n).defOut;
            altInNum = str2double(F(n).altIn);
            altOutNum = str2double(F(n).altOut);
            altIn = F(n).altIn;
            altOut = F(n).altOut;

            % Translate defIn if needed. Changes done here should be done in genHelp.m too.
            if isnan(defInNum) || defInNum<0 % NaN: the string didn't express a number. Negative: default
                % number of inputs unspecified. In either case: translate string into a description
                switch defIn
                    case 'double(numel(CB_G)>1)'%%%'G'
                        defIn = '$^\sqcup$';
                    case 'numel(STACK)'
                        defIn = '$^\ddagger$';
                    otherwise
                        notInterpreted{end+1} = F(n).source;
                end
            end
            
            % Translate altIn if needed. Changes done here should be done in genHelp.m too.
            if isnan(altInNum) && ~isempty(altIn)% The string was non-empty and didn't contain a number: translate string into a description
                switch altIn
                    case 'numel(STACK)'
                        altIn = '$^\ddagger$';
                    otherwise
                        notInterpreted{end+1} = F(n).source;
                end
            end
         
            % Translate defOut if needed. Changes done here should be done in genHelp.m too.
            if isnan(defOutNum) || defOutNum<0 % NaN: the string didn't express a number. Negative: default
                % number of outputs unspecified. In either case: translate string into a description
                switch defOut
                    case '1+(max(numel(CB_G),1)-1)*(numel(in)==0)'
                        defOut = '$^\sqcap$';
                    case {'numel(CB_H)' 'numel(CB_I)' 'numel(CB_J)' 'numel(CB_K)' 'numel(CB_L{in{1}})'}
                        defOut = '$^\dagger$';
                    case '1+(in{1}<=numCbM)*(numel(CB_M{mod(in{1}-1,numCbM)+1})-1)'
                        defOut = '$^\ast$';
                    case 'numel(in{1})'
                        defOut = '$^\triangle$';
                    case 'max(1,sum(ismember(cellfun(@num2str, in(3:end), ''uniformoutput'', false), {''start'' ''end'' ''tokenExtents'' ''match'' ''tokens'' ''split'' ''1'' ''2'' ''3'' ''5'' ''6'' ''7''})))'
                        defOut = '$^\Diamond$';
                    case 'numel(in)'
                        defOut = '$^\square$';
                    case '-1'
                        defOut = '$^\bigtriangledown$';
                    case '-2'
                        defOut = '$^\bigtriangledown$';
                    otherwise
                        notInterpreted{end+1} = F(n).source;
                end
            end
            
            % Translate altOut if needed. Changes done here should be done in genHelp.m too.
            if isnan(altOutNum) && ~isempty(altOut)% The string was non-empty and didn't contain a number: translate string into a description
                switch altOut
                    case {'[false true]' '[false,true]' '[false, true]'}
                        altOut = '2nd';
                    case {'[false true false]' '[false,true,false]' '[false, true, false]'}
                        altOut = '2nd';
                    case {'[false false true]' '[false,false,true]' '[false, false, true]'}
                        altOut = '3rd';
                    case {'[true false false true]' '[true,false,false,true]' '[true, false, false, true]'}
                        altOut = '1st and 4th';
                    case {'ndims(in{1})'}
                        altOut = '$^\times$';
                    otherwise
                        notInterpreted{end+1} = F(n).source;
                end
            end

            % Format input spec
            if (minInNum ~= maxInNum) && isempty(altIn)
                if isfinite(maxInNum)
                    substrIn = sprintf('%i--%i (%s)', minInNum, maxInNum, defIn);
                else
                    substrIn = sprintf('%i-- (%s)', minInNum, defIn);
                end
            elseif (minInNum ~= maxInNum) && ~isempty(altIn)
                if isfinite(maxInNum)
                    substrIn = sprintf('%i--%i (%s / %s)', minInNum, maxInNum, defIn, altIn);
                else
                    substrIn = sprintf('%i-- (%s / %s)', minInNum, defIn, altIn);
                end
            elseif (minInNum == maxInNum) && ~isempty(altIn)
                substrIn = sprintf('%i (%s / %s)', maxInNum, defIn, altIn);
            else
                if (maxInNum~=defInNum) % || ~isempty(altIn). % We remove this condition, for the same reasons as for the output
                    error('Incorrect specification of number of inputs')
                end
                substrIn = sprintf('%s', defIn);
            end
            
            % Format output spec
            if (minOutNum ~= maxOutNum) && isempty(altOut)
                if isfinite(maxOutNum)
                    substrOut = sprintf('%i--%i (%s)', minOutNum, maxOutNum, defOut);
                else
                    substrOut = sprintf('%i-- (%s)', minOutNum, defOut);
                end
            elseif (minOutNum ~= maxOutNum) && ~isempty(altOut)
                if isfinite(maxOutNum)
                    substrOut = sprintf('%i--%i (%s / %s)', minOutNum, maxOutNum, defOut, altOut);
                else
                    substrOut = sprintf('%i-- (%s / %s)', minOutNum, defOut, altOut);
                end
            elseif (minOutNum == maxOutNum) && ~isempty(altOut)
                substrOut = sprintf('%i (%s / %s)', maxOutNum, defOut, altOut);
            else
                if (maxOutNum~=defOutNum) %|| ~isempty(altOut). % We remove the condition on altOut because there may be things like minOutNum==maxOutNum==defOutNum==2 and altOut = '[false true]'
                    error('Incorrect specification of number of outputs')
                end
                substrOut = sprintf('%s', defOut);
            end
            
            if ~any(F(n).source=='+')
                lines{end+1} = sprintf('\\matl+%s+ & %s & %s & %s \\\\', F(n).source, substrIn, substrOut, F(n).description);
                %lines{end+1} = sprintf('\\matl+%s+ & %s & %s & %s \\newline %s \\\\[1mm]', F(n).source, substrIn, substrOut, F(n).comment, F(n).description);
            elseif ~any(F(n).source=='|')
                lines{end+1} = sprintf('\\matl|%s| & %s & %s & %s \\\\', F(n).source, substrIn, substrOut, F(n).description);
                %lines{end+1} = sprintf('\\matl|%s| & %s & %s & %s \\newline %s \\\\[1mm]', F(n).source, substrIn, substrOut, F(n).comment, F(n).description);
            else
                error('We need to use another delimiter for LaTeX command')
            end
    end
end

if ~isempty(notInterpreted)
    disp('In the following functions the default or alternative number of inputs or outputs could not be interpreted.')
    disp('Add one or more entries in the corresponding "switch" statements to cover this.')
    disp(char(notInterpreted(:)))
end

% Write file
fid = fopen(funTableFileName, 'w');
for n = 1:numel(lines)
    fwrite(fid, lines{n});
    fwrite(fid, [13 10]); % line break, Windows style
end
fclose(fid);

% Call converter
convert_matl(funTableFileName, false)

% Restore path
path(p);

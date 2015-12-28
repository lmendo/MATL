function matl_run(S, pOutFile, cOutFileNoExt, dbstopLines, isMatlab)
%
% MATL runner and debugger: runs MATL code that has been compiled into MATLAB code. Catches MATLAB
% errors and references them to the MATL statement that caused them.
%
% In debug mode, sets breakpoints at the beginning of the MATLAB code
% corresponding to each MATL statement, and opens the variable editor with
% the MATL stack, input and output specifications, and clipboards.
%
% Luis Mendo

if ~isempty(dbstopLines) % debug mode
    if isMatlab
        for line = dbstopLines
            eval([ 'dbstop in ' cOutFileNoExt ' at ' num2str(line) ])
        end
        openvar('STACK')
        openvar('S_IN'), openvar('S_OUT')
        openvar('CB_H'), openvar('CB_I'), openvar('CB_J'), openvar('CB_K'), openvar('CB_L')
        openvar('STACK') % This is to bring this variable to front
    else % Octave
        for line = dbstopLines
            dbstop(cOutFileNoExt, line);
        end
        % No `openvar` in Octave (4.0.0)
    end
else % non-debug mode
    if isMatlab
        if exist(cOutFileNoExt,'file')
            eval([ 'dbclear in ' cOutFileNoExt ]) % `eval`: I know, I know...
        end
    else % Octave
        if exist(cOutFileNoExt,'file')
            dbclear(cOutFileNoExt);
            delete([cOutFileNoExt '.m']) % Sometimes it looks like an old version of the file is run
            % instead of the new compiled one. So I'm deleting the file just in case
        end
    end
end

try
    % run(cOutFileNoExt) % This doesn't seem to worl in Octave (4.0.0)
    evalin('caller', [cOutFileNoExt ';']); 
catch ME
    h = find(strcmp({ME.stack.name},cOutFileNoExt),1); % first error that refers to cOutFileNoExt
    % This is necessary because the error may have been issued not by cOutFileNoExt directly, but
    % by a function called by cOutFileNoExt
    if ~isempty(ME.stack(h))
        k = ME.stack(h).line;
        n = find([S(:).compileLine]<=k, 1, 'last');
        fprintf(2, 'MATL run-time error: The following MATLAB error refers to <a href="matlab: opentoline(''%s'', %i)">statement number %i:  %s</a>\n', pOutFile, n, n, S(n).source);
        fprintf(2, '---\n');
    else
        error('MATL:runner:internal', 'MATL internal error while running compiled file. More information follows');
        fprintf(2, '%s\n', ME(1).message)
    end
    rethrow(ME)
end

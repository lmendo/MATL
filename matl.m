function matl(varargin)
%
% MATL main program.
% Matlab 2015b or newer. Also works in Octave. See
% specification document for compatibility considerations.
% Calls parser, compiler, runner depending on input options.
% Luis Mendo

indentBase = 4; % number of spaces for indentation level 0. Default value
indentStep = 2; % number of spaces to add for each indentation level. Default value
indentCommentSymbol = 6; % number of spaces before comment symbol. Default value
indentCommentText = 1; % number of spaces before actual comment. Default value
pOutFile = 'MATLp.txt'; % temporary file for parsed code
cOutFile = 'MATLc.m'; % temporary file for compiled code
 cOutFileNoExt = cOutFile(1:end-2); % same without extension. Needed to run file in old Matlab versions
 % cOutFileNoExt = regexprep(cOutFile, '\.m$', ''); % Old Octave versions
 % (before 3.8 apparently) don't recognize '\.'  as an escaped dot symbol
funDefMasterFile = 'funDef.txt'; % function definition master file
funDefMatFile = 'funDef.mat'; % function definition processed file
preLitMasterFile = 'preLit.txt'; % master file that defines predefined strings with (key, value) pairs
preLitMatFile = 'preLit.mat'; % processed file file that defines predefined strings with (key, value) pairs
helpFile = 'help.mat';
matlInputPrompt = ' > ';

version = ver;
indMainName = find(ismember({version.Name}, {'MATLAB','Octave'}));
isMatlab = strcmp(version(indMainName).Name, 'MATLAB'); % 1 if Matlab, 0 if Octave
verNum = version(indMainName).Version; % version number as a string
verNum = str2double(regexp(verNum, '\.', 'split')); % version number as a vector

if numel(varargin)==0
    options = 'r';
    inputNeeded = true;
elseif numel(varargin)==1 && ~isempty(varargin{1}) && varargin{1}(1)=='-' && numel(varargin{1})>1
    options = varargin{1}(2:end);
    inputNeeded = ~any(options=='h'); % true unless option is h
elseif numel(varargin)==1 && ~isempty(varargin{1}) && varargin{1}(1)=='-' && numel(varargin{1})==1
    options = 'r';
    inputNeeded = true;
elseif numel(varargin)==1
    options = 'r';
    s = varargin{1};
    inputNeeded = false;
elseif numel(varargin)==2 && varargin{1}(1)=='-'
    options = varargin{1}(2:end);
    s = varargin{2};
    inputNeeded = false;
elseif numel(varargin)==2 && varargin{1}(1)~='-'
    error('MATL:main', 'MATL error while processing options: two input strings have identified, but the first string does not begin with <strong>-</strong>')
else
    error('MATL:main', 'MATL error while processing options: the number of inputs cannot exceed 2')
end
if any(options=='r') && any(options=='d')
    error('MATL:main', 'MATL error while processing options: incompatible options <strong>r</strong> and <strong>d</strong>')
end
if any(options=='l') && any(options=='e')
    error('MATL:main', 'MATL error while processing options: incompatible options <strong>l</strong> and <strong>e</strong>')
end
if ~ismember(options,'plecsrdh')
    options = [options 'r'];
end
if any(options=='v')
    verbose = true;
else
    verbose = false;
end
if any(options=='h') && any(ismember(options, ['plecrdf' '0':'9' 'A':'Z']))
    error('MATL:main', 'MATL error while processing options: <strong>h</strong> is not compatible with specified options')
end
if any(options=='o')
    online = true; % saffe mode, for online compiler
else
    online = false;
end    
if ~all(ismember(options, ['plecrdfvho' '0':'9' 'A':'Z']))
    error('MATL:main', 'MATL error: unrecognized option')
end

numericOptions = options(ismember(options,['0':'9' 'A':'Z']));
numericOptions = base2dec(numericOptions(:), 36);
if numel(numericOptions)>=1
    indentBase = numericOptions(1);
end
if numel(numericOptions)>=2
    indentStep = numericOptions(2);
end
if numel(numericOptions)>=3
    indentCommentSymbol = numericOptions(3);
end
if numel(numericOptions)>=4
    indentCommentText = numericOptions(4);
end
if numel(numericOptions)>=5
    error('MATL:main', 'MATL error while processing options: too many numeric options')
end

genHelpNeeded = false;

% Update funDefMatFile, if needed; or load file
fDtxt = dir(funDefMasterFile);
if ~isempty(fDtxt)
    fDtxt = datenum(fDtxt.date);
else
    fDtxt = -inf;
end
fDmat = dir(funDefMatFile);
if ~isempty(fDmat)
    fDmat = datenum(fDmat.date);
else
    fDmat = -inf;
end
if fDmat < fDtxt % regeneration of funDefMatFile required
    if verbose
        fprintf('Regenerating function definitions from master file ''%s''\n', funDefMasterFile)
    end
    F = genFunDef(funDefMasterFile, funDefMatFile); % creates `F` struct array with unique function
    % definitions from funDefMasterFile, and saves it in funDefMatFile file 
    genHelpNeeded = true;
else % load funDef;atFile directly
    if verbose
        fprintf('Loading function definitions from file ''%s''\n', funDefMatFile)
    end
    load(funDefMatFile) % loads F variable
end
if verbose
    fprintf('  %i function definitions found\n', numel(F))
end

% Update preLitFile, if needed
fDtxt = dir(preLitMasterFile);
if ~isempty(fDtxt)
    fDtxt = datenum(fDtxt.date);
else
    fDtxt = -inf;
end
fDmat = dir(preLitMatFile);
if ~isempty(fDmat)
    fDmat = datenum(fDmat.date);
else
    fDmat = -inf;
end
if fDmat < fDtxt % regeneration of preLitFile required
    if verbose
        fprintf('Regenerating predefined literals from master file ''%s''\n', preLitMasterFile)
    end
    L = genPreLit(preLitMasterFile, preLitMatFile); % creates struct `L` with keys and values
    % from preLitMasterFile, and saves it in preLitFile. Returns number of keys.
    genHelpNeeded = true;
else
    if verbose
        fprintf('Loading predefined literals from file ''%s''\n', preLitMatFile)
    end
    load(preLitMatFile) % loads struct arrray `L`
end
if verbose
    fprintf( '  %i predefined literals found in %i functions\n', ...
        sum(cellfun(@(x) numel(x.key), struct2cell(L))), numel(fieldnames(L)) )
end

% Update help file, if needed
if genHelpNeeded
    if verbose
        fprintf('Regenerating help file \n')
    end
    H = genHelp(F, helpFile);
else
    if verbose
        fprintf('Loading help file ''%s''\n', helpFile)
    end
    load help
end
if verbose
    fprintf('  %i help entries found\n', numel(H.source))
end

% Get input, if needed
if inputNeeded
    if any(options=='f')
        if verbose
            disp('Input filename:')
        end
        fprintf(matlInputPrompt); % change prompt to show we are accepting MATL content
        s = input('','s');
    else
        s = {};
        done = false;
        if verbose
            disp('Input program. End with blank line:')
            disp(' ')
        end
        while ~done
            fprintf(matlInputPrompt); % change prompt to show we are accepting MATL content
            s{end+1} = input('','s');
            done = isempty(s{end});
        end
        % s = strjoin(s, '\n'); % `strjoin` doesn't exist in old versions
        s = sprintf('%s\n',s{:}); s = s(1:end-1);
    end
end

% Read file, if needed
if any(options=='f')
    fid = fopen(s,'r');
    s = fread(fid);
    fclose(fid);
    s = char(s.');
end

% Call help, if required, and quit
useTags = isMatlab && (verNum(1)>7 || (verNum(1)==7 && verNum(2)>=13));
if any(options=='h')
    if nargin>1
        matl_help(H, s, verbose, useTags)
    else
        matl_help(H, '', verbose, useTags)
    end
    return
end

% Call parser, if required
if any(ismember(options,'plecrdfv'))
    if verbose
        disp('Parsing program')
    end
    S = matl_parse(s, useTags);
    if verbose
        if numel(S)~=1
            fprintf('  %i statements parsed\n', numel(S))
        else
            fprintf('  1 statement parsed\n')
        end
    end
end

% Save parsed output, and display if required
if any(ismember(options,'le'))
    matl_disp(S, F, indentBase, indentStep, indentCommentSymbol, indentCommentText, pOutFile, true, any(options=='e')||numel(numericOptions)>=3, any(options=='e'), verbose);
    if ~verbose && any(ismember(options,'rd'))
        pause
    end
else
    matl_disp(S, F, indentBase, indentStep, indentCommentSymbol, indentCommentText, pOutFile, false, false, false, verbose);
end

% Compile parsed program, if required
if any(ismember(options,'csrd'))
    if verbose
        disp('Compiling program')
    end
    S = matl_compile(S, F, L, pOutFile, cOutFile, verbose, isMatlab, useTags, online);
    %if verbose
    %    disp('  Done.')
    %end
end

% Run compiled program, if required
if any(options=='r')
    if verbose
        str = 'Press any key to run program';
        disp(str)
        %disp('--') %disp(repmat('-',size(str)))
        pause
    end
    matl_run(S, pOutFile, cOutFileNoExt, [], isMatlab, useTags) % ...NoExt because a file name without extension is
    % needed in old Matlab versions   
end

% Run compiled program in debug mode, if required
if any(options=='d')
    if verbose
        disp('Press any key to run MATL program in debug mode')
        pause
    end
    matl_run(S, pOutFile, cOutFileNoExt, [S.compileLine], isMatlab, useTags) % ...NoExt because a file name without
    % extension is needed in old Matlab versions
end




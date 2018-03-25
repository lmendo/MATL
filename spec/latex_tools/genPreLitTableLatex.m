function genPreLitTableLatex

p = path;
if exist('C:\Users\Luis\Dropbox\MATL', 'dir')
    baseFolder = 'C:\Users\Luis\Dropbox\MATL';
elseif exist('C:\Users\lmendo\Dropbox\MATL', 'dir')
    baseFolder = 'C:\Users\lmendo\Dropbox\MATL';
else
    error('Base folder not found')
end
addpath([baseFolder '\compiler'])

preLitTableFileName = [ baseFolder '\spec\preLitTable\preLitTable.tex' ];
preLitMatFileName = [ baseFolder '\compiler\preLit.mat' ];
preLitTxtFileName = [ baseFolder '\compiler\preLit.txt' ];

% Update preLit.mat, if needed; or load file
pLTxt = dir(preLitTxtFileName);
if ~isempty(pLTxt)
    pLTxt = datenum(pLTxt.date);
else
    pLTxt = -inf;
end
pLMat = dir(preLitMatFileName);
if ~isempty(pLMat)
    pLMat = datenum(pLMat.date);
else
    pLMat = -inf;
end
if pLMat < pLTxt % regeneration of `L.mat` required
    L = genPreLit(preLitTxtFileName, preLitMatFileName); % creates `preLit` struct array 
    % definitions from funDefTxtFileName file, and saves it in funDefMatFileName file 
else % load `preLit` variable from funDefMatFileName directly
    load(preLitMatFileName) % loads L variable
end

fn = fieldnames(L);
for n = 1:numel(fn)
    lines = {};
    %lines{end+1} = '\begin{tabular}{|l|l||l|l||l|l|}';
    %lines{end+1} = '\begin{tabular}{|p{.03\textwidth}|p{.3\textwidth}||p{.03\textwidth}|p{.3\textwidth}||p{.03\textwidth}|p{.3\textwidth}|}';
    %lines{end+1} = '\begin{longtable}{|l|l||l|l||l|l|}';
    lines{end+1} = '\begin{longtable}{|p{.03\textwidth}|p{.29\textwidth}||p{.03\textwidth}|p{.29\textwidth}||p{.03\textwidth}|p{.29\textwidth}|}';
    %lines{end+1} = '\esptab';
    lines{end+1} = '\hline';
    lines{end+1} = sprintf('\\multicolumn{6}{|c|}{Function \\matl{%s}} \\\\ \\hline\\hline', fn{n});
    %lines{end+1} = '\matl{99} & \matl{''CollapseDelimiters''} & \matl{99} & \matl{''CollapseDelimiters''} & \matl{99} & \matl{''CollapseDelimiters''} \kill';
    keys = L.(fn{n}).key;
    vals = L.(fn{n}).val;
    for m = 1:numel(keys)
        r = mod(m,3);
        if r
            lines{end+1} = sprintf('\\matl|%s| & \\matl|%s| &', num2str(keys(m)), vals{m}); % this assumes "|" is not be used in literals
        else
            lines{end+1} = sprintf('\\matl|%s| & \\matl|%s| \\\\ \\hline', num2str(keys(m)), vals{m});
        end
    end
    if r==1
        lines{end+1} = sprintf('& & & \\\\ \\hline');
    elseif r==2
        lines{end+1} = sprintf('& \\\\ \\hline');
    end
    lines{end+1} = '\end{longtable}';
    %lines{end+1} = '\ ';
   
    % Write file
    [p, f, e] = fileparts(preLitTableFileName);
    fname = [p filesep f fn{n} e];
    fid = fopen(fname, 'w');
    for k = 1:numel(lines)
        fwrite(fid, lines{k});
        fwrite(fid, [13 10]); % line break, Windows style
    end
    fclose(fid);
    
    % Convert "\matl" contents:
    convert_matl(fname, false);
end

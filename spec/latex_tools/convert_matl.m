function convert_matl(fileName, keepOriginal)

% Converts \matl+...+ or \matl|...| into: \matl{...} with escaped characters

%disp(' ');
copyFileName = [fileName ' [not converted]'];
fid = fopen(fileName);
s = fread(fid);
fclose(fid);
s = char(s.');
ind = regexp(s, '(?<=\\matl).');
unique(s(ind)); % characters found after "\matl", as a check. I only used + and |
[ini, fin] = regexp(s, '\\matl([+|]).*?\1'); % all matching substrings
if isempty(ini)
    disp('Nothing needs to be converted. Converted file not written')
else
    disp([num2str(numel(fin)) ' substrings identified for conversion'])
    y = s(1:ini(1)-1); % output. Initiallize
    % \# \$ \% \& \textbackslash{} \textasciicircum {}\_ \{ \} \textasciitilde{}
    ini(end+1) = numel(s)+1;
    for n = 1:numel(fin)
        t = regexprep(s(ini(n)+6:fin(n)-1), '\\', '\\textbackslash '); % This has
        % to go first, so that it won't convert \ introduced to escape other
        % characters. No {} here, because they would get converted into \{\} later
        t = regexprep(t, '[#$%&_{}]', '\\$0');
        t = regexprep(t, '\^', '\\textasciicircum{}');
        t = regexprep(t, '~', '\\textasciitilde{}');
        %t = regexprep(s(ini(n)+6:fin(n)-1), {'[#$%&_{}]' '\' '^' '~'}, {'\\$0' '\textbackslash ' '\^{}' '\textasccitilde{}'});
        t = ['\matl{' t '}'];
        y = [y t s(fin(n)+1:ini(n+1)-1)];
    end
    if keepOriginal
        movefile(fileName, copyFileName);
    end
    fid = fopen(fileName, 'w');
    count = fwrite(fid, y);
    fclose(fid);
    if count==numel(y)
        disp('Converted file successfully written')
    else
        disp('Something went wrong when writing the file')
    end
end

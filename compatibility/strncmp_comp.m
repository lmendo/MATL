function y = strncmp(x1, x2, n)
% This repreoduces Matlab behaviour: if (strings) x1 and x2 are equal, or (cells) their contents
% are equal, Matlab gives 1 even if n is larger than the strings' length (Octave gives 0).
if ischar(x1) && ischar(x2)
    y = builtin('strncmp', x1, x2, n) || (strcmp(x1, x2) && n>numel(x1));
elseif ischar(x1) && ~ischar(x2)
    y = builtin('strncmp', x1, x2, n) | cellfun(@(s1,s2) strcmp(s1,s2) && (n>numel(s1)), repmat({x1}, size(x2)), x2);
elseif ~ischar(x1) && ischar(x2)
    y = builtin('strncmp', x1, x2, n) | cellfun(@(s1,s2) strcmp(s1,s2) && (n>numel(s1)), x1, repmat({x2}, size(x1)));
else % x1 and x2 are cells of the same size
    y = builtin('strncmp', x1, x2, n) | cellfun(@(s1,s2) strcmp(s1,s2) && (n>numel(s1)), x1, x2);
end
end
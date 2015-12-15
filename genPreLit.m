function L = genPreLit(masterFileName, fileName)

fid = fopen(masterFileName, 'r');
p = reshape(fread(fid,inf,'*char'),1,[]);
fclose(fid);
p = regexp(p, '[\r\n]+', 'split');
p = p(~cellfun(@isempty, p));
funNamesInd = [ find(cellfun(@(x) isempty(regexp(x, '\t', 'once')), p)) numel(p)+1];
for n = 1:numel(funNamesInd)-1
    foundKeys = [];
    for k = funNamesInd(n)+1:funNamesInd(n+1)-1
        kv = regexp(p{k}, '\t+', 'split');
        key = str2double(kv{1});
        assert(~any(foundKeys==key), 'MATL:compiler:internal', 'MATL internal error while reading predefind literal file: key values are not unique')
        val = kv{2};
        foundKeys(end+1) = key;
        c = numel(foundKeys);
        L.(p{funNamesInd(n)}).key(c) = key;
        L.(p{funNamesInd(n)}).val{c} = val;
    end
end

save(fileName, 'L')





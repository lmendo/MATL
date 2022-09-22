function BW2 = bwselect(BW1, C, R, N)
% bwselect in some versions of Octave's Image Package (for example 2.12.0) gives different results
% from those in Matlab. This fixes that. The approach used here is: find the connected components
% and select those that contain any of the input pixels
CC = bwconncomp(BW1, N);
PixelIdxList = CC.PixelIdxList;
clear CC
lin_ind = sub2ind(size(BW1), R(:), C(:));
BW2 = false(size(BW1));
for c = 1:numel(PixelIdxList)
    if any(ismember(lin_ind, PixelIdxList{c}))
        BW2(PixelIdxList{c}) = true;
    end
end
end

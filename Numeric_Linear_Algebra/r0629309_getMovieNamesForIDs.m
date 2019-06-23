function [movieNames] = r0629309_getMovieNamesForIDs(mIDs)
load('MovieLens_Subset.mat','movieLabel');
l = length(mIDs);
movieNames = cell(l,1);

for i = 1:1:l
    movieNames{i} = movieLabel{mIDs(i)};
end

end


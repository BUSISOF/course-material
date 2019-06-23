function [movieIDs] = r0629309_similarMovies( C, i, n )
    scores = C(1:end,i);
    [~,movieIDs] = sort(scores,'desc');
    movieIDs(n+1:end) = [];
end
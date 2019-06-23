function [ movieIDs, score ] = r0629309_predictedBestMovies(F,W)
    [m, ~] = size(F);
    [n, ~] = size(W);
    totals = sum((F((1:m)',:)*W'), 2);
    means = totals / n;
    [score,movieIDs] = sort(means,'desc');
end

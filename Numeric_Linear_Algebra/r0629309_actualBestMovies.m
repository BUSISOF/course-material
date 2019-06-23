function [ movieIDs, score ] = r0629309_actualBestMovies(R)
  [is,~,v] = find(R);
  [score,movieIDs] = sort(accumarray(is,v,[],@mean),'desc');
end
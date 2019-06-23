function [ movieIDs, score ] = r0629309_predictedBestMoviesForUser(R,F,W,j)
  
[m,~] = size(R);
[mID,uID,~] = find(R);
score = zeros(m,0);
rmID = mID(uID==j);

 for id = 1:1:m
    score(id) = dot(F(id,:),W(j,:));
 end
 
 % filter recommendations for already viewed/rated movies
  for i = 1:1:length(rmID)
   score(rmID(i)) = NaN;
  end

[score, movieIDs] = sort(score,'desc'); % sort with NaN values in front

amount2delete = sum(isnan(score)); % calculate truncation-amount
score(1:amount2delete) = [];
movieIDs(1:amount2delete) = [];

end

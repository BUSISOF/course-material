function [voteList] = r0629309_countVotes(M)
[m,~] = size(M);
%[mID,uID,scores] = find(M);
voteList = zeros(m,0);
for id = 1:1:m
    voteList(id) = sum(M(id,:)~=0);
    %voteList(id) = length(uID(mID == id));
end



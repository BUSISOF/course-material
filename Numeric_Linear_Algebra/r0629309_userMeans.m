function [ mu ] = r0629309_userMeans(A)
  [is,~,v] = find(A');
  mu = accumarray(is,v,[],@mean);
end


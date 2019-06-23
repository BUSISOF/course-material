function [ F, W ] = r0629309_constructModel( R, r, beta )
  if nargin < 3
    beta = 2; 
  end
  [m,n] = size(R);
  F = zeros(m,r);
  W = zeros(n,r);
  F(:,1) = 1;
  W(:,1) = r0629309_userMeans(R);
  for k = 2 : r
    R = R - r0629309_sparseModel(F(:,k-1),W(:,k-1),R);
    [U,S,V] = svds(R, 1);
    F(:,k) = beta*U*S;
    W(:,k) = V;
  end
end

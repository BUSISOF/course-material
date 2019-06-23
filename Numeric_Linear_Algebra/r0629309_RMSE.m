function [ err ] = r0629309_RMSE(A,B)
  err = norm(A-B,'fro')/sqrt(nnz(A-B));
end


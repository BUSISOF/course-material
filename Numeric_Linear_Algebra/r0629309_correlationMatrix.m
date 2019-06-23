function [C] = r0629309_correlationMatrix(F, W)
    [m,~] = size(W);
    R = F * W';
    U = sum(R, 2)/m;
    summ = sum((R - U).^2, 2);
    Sd = sqrt(summ/(m-1));  
    D = diag(Sd);
    V = U*ones(1,m);
    C = (inv(D)*(R-V))*(inv(D)*(R-V))';
    C = C/(m-1);
end


function [newW] = r0629309_addUser(F, W, i, s)
    U = F(i,:);
    uW = U \ s;
    newW = [W; uW'];
end


function [ X ] = r0629309_sparseModel(F, W, A)
    [is, js, ~] = find(A);
    vs = zeros(length(is), 1);
    
    parfor c = 1:length(is)
        vs(c) = F(is(c),:) * W(js(c), :)'; % in-place multiplication
    end
    
    X = sparse(is, js, vs); % Reconstruct sparse matrix
end


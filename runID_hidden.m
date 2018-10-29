function [A, B] = runID_hidden(barY, lambda)
    cvx_begin quiet
    % cvx_solver sedumi
    % cvx_solver sdpt3
    num = size(barY,1);
    variable A(num,num) complex 
    variable B(num,num) complex
    minimize (lambda*norm(A,1)+ norm_nuc(B))
    %                          W.^2-1=0;
                     subject to
                     A - B == barY                     
    cvx_end
end

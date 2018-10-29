function [Y_est, Y_diff] = runID(V, I, idx, nidx, Y, lambda)
% elastic net regression

[NODES,~] = size(V);

cvx_begin
%cvx_solver sedumi
%           cvx_solver sdpt3
          variable Y_est(NODES,NODES) complex symmetric
%           minimize    (square_pos(norm((Y_est*V-I),'fro')) + lambda*(alpha*norm(vec(Y_est),1) + (1-alpha)*(square_pos(norm(Y_est,'fro')))))
          minimize    (power(2,norm((Y_est*V-I),'fro')) + lambda*norm(vec(Y_est),1))
%          minimize    ( square_pos (norm((Y_est*V-I),'fro')))
%          minimize    (norm((Y_est*V-I),'fro'))
cvx_end

    Y_diff = Y_est - Y;
%     norm_diff = norm(Y_diff, 'fro');
end

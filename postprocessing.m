function [Y22_est, Y12_est, Y11_est] = postprocessing(V, I, idx, nidx, Y, lambda)

if nargin<6
    lambda = 0.0001;
end

lambdas = logspace(log10(lambda),1,2*(2-log10(lambda)));
%lambdas = logspace(log10(lambda),2,20);

V1 = V(nidx,:);
V2 = V(idx,:);

X1 =  V1/V2;

I2 = I(idx,:);
I1 = I(nidx,:);

Va1 = I1 / V2;
Va2 = I2 / V2;

C = Va2 - Va1.'*X1;

% G = expan(numel(nidx));
% H = contr(numel(idx));
G = sparse(expan(numel(nidx)));
H = sparse(contr(numel(idx)));
hc = C(itril(size(C)));  % selects lower diagonal elements and vectorizes the output

% Note that we have
% contr(numel(idx))*expan(numel(idx)) = eye(numel(idx)*(numel(idx)+1)/2);

% hy11 = Y11(itril(size(Y11)));
% check_vec=kron(X1.',X1.')*G*hy11 - kron(X1.',X1.')*YY11(:);

% hy22 = Y22(itril(size(Y22)));
% check_vech= -hc + hy22 - H*kron(X1.',X1.')*G*hy11;

Phi = [speye(numel(idx)*(numel(idx)+1)/2), -H*(kron(X1.',X1.')*G)];
% Phi = [eye(numel(idx)*(numel(idx)+1)/2), -H*(kron(X1.',X1.')*G)];

fprintf('Lasso method is being used...\n')
mindist = 1e7;
optlambda = 0;
for i=1:numel(lambdas)
    W = standardLasso( Phi, hc, lambdas(i) );
    [Y11_est_lasso_temp, Y22_est_lasso_temp] = recoverY( W, numel(idx), numel(nidx) );
    if norm(Y(idx,idx)-Y22_est_lasso_temp, 'fro')<mindist
        mindist = norm(Y(idx,idx)-Y22_est_lasso_temp, 'fro');
        optlambda = lambdas(i);
        Y11_est_lasso = Y11_est_lasso_temp;
        Y22_est_lasso = Y22_est_lasso_temp;
    end
end
fprintf('best lambda is %0.10g\n',optlambda)
fprintf('%0.5g\n',max(max(abs(Y(idx,idx)-Y22_est_lasso))))
fprintf('%0.5g\n',norm(Y(idx,idx)-Y22_est_lasso, 'fro'))
Y22_est_lasso(abs(Y22_est_lasso)<1e-2)=0;
fprintf('no. nonzero elements: %g\n',nnz(Y22_est_lasso))

fprintf('Thresholded lasso method with refitting is being used...\n')
mindist = 1e7;
optlambda = 0;
for i=1:numel(lambdas)
    W = thresholdedLasso( Phi, hc, lambda, 1e-1 );
    [Y11_est_thlasso_temp, Y22_est_thlasso_temp] = recoverY( W, numel(idx), numel(nidx) );
    if norm(Y(idx,idx)-Y22_est_thlasso_temp, 'fro')<mindist
        mindist = norm(Y(idx,idx)-Y22_est_thlasso_temp, 'fro');
        optlambda = lambdas(i);
        Y11_est_thlasso = Y11_est_thlasso_temp;
        Y22_est_thlasso = Y22_est_thlasso_temp;
    end
end
fprintf('best lambda is %0.10g\n',optlambda)
fprintf('%0.5g\n',max(max(abs(Y(idx,idx)-Y22_est_thlasso))))
fprintf('%0.5g\n',norm(Y(idx,idx)-Y22_est_thlasso, 'fro'))
Y22_est_thlasso(abs(Y22_est_thlasso)<1e-2)=0;
fprintf('no. nonzero elements: %g\n',nnz(Y22_est_thlasso))


fprintf('Adaptive lasso method with OLS based weights is being used...\n')
mindist = 1e7;
optlambda1 = 0;
for i=1:numel(lambdas)
    W = adaptiveLasso( Phi, hc, lambda, 1, 0.5 );
    [Y11_est_adaptlasso_ols1_temp, Y22_est_adaptlasso_ols1_temp] = recoverY( W, numel(idx), numel(nidx) );
    if norm(Y(idx,idx)-Y22_est_adaptlasso_ols1_temp, 'fro')<mindist
        mindist = norm(Y(idx,idx)-Y22_est_adaptlasso_ols1_temp, 'fro');
        optlambda1 = lambdas(i);
        Y11_est_adaptlasso_ols1 = Y11_est_adaptlasso_ols1_temp;
        Y22_est_adaptlasso_ols1 = Y22_est_adaptlasso_ols1_temp;
    end
end

mindist = 1e7;
optlambda2 = 0;
for i=1:numel(lambdas)
    W = adaptiveLasso( Phi, hc, lambda, 1, 1 );
    [Y11_est_adaptlasso_ols2_temp, Y22_est_adaptlasso_ols2_temp] = recoverY( W, numel(idx), numel(nidx) );
    if norm(Y(idx,idx)-Y22_est_adaptlasso_ols2_temp, 'fro')<mindist
        mindist = norm(Y(idx,idx)-Y22_est_adaptlasso_ols2_temp, 'fro');
        optlambda2 = lambdas(i);
        Y11_est_adaptlasso_ols2 = Y11_est_adaptlasso_ols2_temp;
        Y22_est_adaptlasso_ols2 = Y22_est_adaptlasso_ols2_temp;
    end
end

mindist = 1e7;
optlambda3 = 0;
for i=1:numel(lambdas)
    W = adaptiveLasso( Phi, hc, lambda, 1, 2 );
    [Y11_est_adaptlasso_ols3_temp, Y22_est_adaptlasso_ols3_temp] = recoverY( W, numel(idx), numel(nidx) );
    if norm(Y(idx,idx)-Y22_est_adaptlasso_ols3_temp, 'fro')<mindist
        mindist = norm(Y(idx,idx)-Y22_est_adaptlasso_ols3_temp, 'fro');
        optlambda3 = lambdas(i);
        Y11_est_adaptlasso_ols3 = Y11_est_adaptlasso_ols3_temp;
        Y22_est_adaptlasso_ols3 = Y22_est_adaptlasso_ols3_temp;
    end
end
[~, indgamma] = min([max(max(abs(Y(idx,idx)-Y22_est_adaptlasso_ols1))),max(max(abs(Y(idx,idx)-Y22_est_adaptlasso_ols2))),max(max(abs(Y(idx,idx)-Y22_est_adaptlasso_ols3)))]);

switch indgamma
    case 1
        Y11_est_adaptlasso_ols = Y11_est_adaptlasso_ols1;
        Y22_est_adaptlasso_ols = Y22_est_adaptlasso_ols1;
        fprintf('optimal gamma is 0.5\n');
        optlambda = optlambda1;
    case 2
        Y11_est_adaptlasso_ols = Y11_est_adaptlasso_ols2;
        Y22_est_adaptlasso_ols = Y22_est_adaptlasso_ols2;
        fprintf('optimal gamma is 1\n');
        optlambda = optlambda2;
    case 3
        Y11_est_adaptlasso_ols = Y11_est_adaptlasso_ols3;
        Y22_est_adaptlasso_ols = Y22_est_adaptlasso_ols3;
        fprintf('optimal gamma is 2\n');
        optlambda = optlambda3;
end
fprintf('best lambda is %0.10g\n',optlambda)
fprintf('%0.5g\n',max(max(abs(Y(idx,idx)-Y22_est_adaptlasso_ols))))
fprintf('%0.5g\n',norm(Y(idx,idx)-Y22_est_adaptlasso_ols, 'fro'))
Y22_est_adaptlasso_ols(abs(Y22_est_adaptlasso_ols)<1e-2)=0;
fprintf('no. nonzero elements: %g\n',nnz(Y22_est_adaptlasso_ols))

% fprintf('Adaptive lasso method with LASSO based weights is being used...\n')
% W = adaptiveLasso( Phi, hc, lambda, 2 );
% 
% [Y11_est_adaptlasso, Y22_est_adaptlasso] = recoverY( W, numel(idx), numel(nidx) );
% fprintf('%0.5g\n',max(max(abs(Y(idx,idx)-Y22_est_adaptlasso))))
% fprintf('%0.5g\n',norm(Y(idx,idx)-Y22_est_adaptlasso, 'fro'))
% Y22_est_adaptlasso(abs(Y22_est_adaptlasso)<1e-2)=0;
% fprintf('no. nonzero elements: %g\n',nnz(Y22_est_adaptlasso))
% 
% fprintf('Adaptive lasso method with Ridge regression based weights is being used...\n')
% W = adaptiveLasso( Phi, hc, lambda, 3 );
% 
% [Y11_est_adaptlasso_ridge, Y22_est_adaptlasso_ridge] = recoverY( W, numel(idx), numel(nidx) );
% fprintf('%0.5g\n',max(max(abs(Y(idx,idx)-Y22_est_adaptlasso_ridge))))
% fprintf('%0.5g\n',norm(Y(idx,idx)-Y22_est_adaptlasso_ridge, 'fro'))
% Y22_est_adaptlasso_ridge(abs(Y22_est_adaptlasso_ridge)<1e-2)=0;
% fprintf('no. nonzero elements: %g\n',nnz(Y22_est_adaptlasso_ridge))


[~, ind] = min([max(max(abs(Y(idx,idx)-Y22_est_lasso))),max(max(abs(Y(idx,idx)-Y22_est_thlasso))),max(max(abs(Y(idx,idx)-Y22_est_adaptlasso_ols)))]);
% [~, ind] = min([max(max(abs(Y(idx,idx)-Y22_est_lasso))),max(max(abs(Y(idx,idx)-Y22_est_thlasso))),max(max(abs(Y(idx,idx)-Y22_est_adaptlasso_ols))),max(max(abs(Y(idx,idx)-Y22_est_adaptlasso))),max(max(abs(Y(idx,idx)-Y22_est_adaptlasso_ridge)))]);

switch ind
    case 1
        fprintf('Lasso outperformed other methods\n');
        Y11_est = Y11_est_lasso;
        Y22_est = Y22_est_lasso;
    case 2
        fprintf('Thresholded lasso with refitting outperformed other methods\n');
        Y11_est = Y11_est_thlasso;
        Y22_est = Y22_est_thlasso;
    case 3
        fprintf('Adaptive lasso with OLS based weights outperformed other methods\n');
        Y11_est = Y11_est_adaptlasso_ols;
        Y22_est = Y22_est_adaptlasso_ols;
    case 4
        fprintf('Adaptive lasso with LASSO based weights outperformed other methods\n');
        Y11_est = Y11_est_adaptlasso;
        Y22_est = Y22_est_adaptlasso;
    case 5
        fprintf('Adaptive lasso with Ridge regression based weights outperformed other methods\n');
        Y11_est = Y11_est_adaptlasso_ridge;
        Y22_est = Y22_est_adaptlasso_ridge;
end

rel_error = abs(Y(idx,idx)-Y22_est)./abs(Y(idx,idx));
rel_error(find(Y(idx,idx)==0)) = 0;
generateHeatmap(rel_error.*100)
fprintf('Relative error (pct): %0.5g\n', max(max(rel_error*100)))

Y12_est = Va1 - Y11_est*X1;

function [Y22_est, Y12_est, Y11_est] = postprocessing_inaccurateY(V, I, Idx, Nidx, Y, lambda)

if nargin<6
    lambda = .01;
end

V1 = V(Nidx,:);
V2 = V(Idx,:);

% A = X1*B => B'* X1' =A'
% X1 = A * B' *(B*B')^(-1);
% X1 =  V1/V2;

X1 =  V1/V2;

I2 = I(Idx,:);
I1 = I(Nidx,:);

% Va1 = Y11*X1 + Y12.'; % Y12 = A' - X1'* Y11'
% Va2 = Y12*X1 + Y22;  % B = A'*X1 - X1'*Y11'*X1 +Y22

Va1 = I1 / V2;
Va2 = I2 / V2;

C = Va2 - Va1.'*X1;

G = Expan(numel(Nidx));
H = Contr(numel(Idx));
hc = C(itril(size(C)));
dimVecY22 = numel(Idx)*(numel(Idx)+1)/2; 

% Note that we have
% Contr(numel(Idx))*Expan(numel(Idx)) = eye(dimVecY22);


% hy11 = Y11(itril(size(Y11)));
% check_vec=kron(X1.',X1.')*G*hy11 - kron(X1.',X1.')*YY11(:);

% hy22 = Y22(itril(size(Y22)));
% check_vech= -hc + hy22 - H*kron(X1.',X1.')*G*hy11;


Phi = [eye(dimVecY22), -H*kron(X1.',X1.')* G];

[~,NODES] = size(Phi);
cvx_begin 
%           cvx_solver sedumi
%           cvx_solver sdpt3
variable W(NODES,1) complex
minimize(norm((Phi* W-hc),2)+lambda*norm(W,1))
cvx_end

vecW22 = Expan(numel(Idx)) * W(1:dimVecY22);
vecW11 = Expan(numel(Nidx))* W(dimVecY22+1:NODES);

Y22_est = reshape(vecW22(1:length(Idx)^2), [length(Idx), length(Idx)]);

% Y22_est(1,1) = Y(1,1);

Y11_est = reshape(vecW11(1:length(Nidx)^2), [length(Nidx), length(Nidx)]);

Y12_est = Va1 - Y11_est*X1;

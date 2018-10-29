function [ W ] = standardLasso( Phi, hc, lambda )
% Implementation of the lasso method

[~,NODES] = size(Phi);

re_phi = real(Phi);
im_phi = imag(Phi);
X = [re_phi -im_phi; im_phi re_phi];

re_y = real(hc);
im_y = imag(hc);
Y = [re_y; im_y];

% fit2 = cvglmnet(X,Y,[],[],[],5);
% W = cvglmnetCoef(fit2,'lambda_1se');
% W = W(2:end);

cvx_begin quiet
%cvx_begin
cvx_solver sdpt3
variable W(2*NODES,1)
minimize( square_pos( norm( X * W - Y , 2 ) ) + lambda * norm( W , 1 ) );

% elastic net
%minimize(power(2,norm((X* W-y),2))+lambda*norm(W,1)+gamma*power(2,norm(W,2)))

cvx_end

W = W(1:NODES) + 1j * W(NODES+1:2*NODES);

end


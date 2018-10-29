function [ W ] = thresholdedLasso( Phi, hc, lambda, threshold )
% Implementation of the lasso method

[~,NODES] = size(Phi);

re_phi = real(Phi);
im_phi = imag(Phi);
X = [re_phi -im_phi; im_phi re_phi];

re_y = real(hc);
im_y = imag(hc);
Y = [re_y; im_y];

cvx_begin quiet
%cvx_begin
cvx_solver sdpt3
variable B(2*NODES,1)
minimize( square_pos( norm( X * B - Y , 2 ) ) + lambda * norm( B , 1 ) );

% elastic net
%minimize(power(2,norm((X* W-y),2))+lambda*norm(W,1)+gamma*power(2,norm(W,2)))

cvx_end

B = B(1:NODES) + 1j * B(NODES+1:2*NODES);

% polishing

selector = ones(2*NODES,1);
for i = 1:NODES
    if abs(B(i))<=threshold
        selector(i)=0;
        selector(NODES+i)=0;
    end
end

cvx_begin quiet
%cvx_begin
cvx_solver sdpt3
variable W(2*NODES,1)
minimize( norm( X * ( selector .* W ) - Y , 2 ) );
cvx_end

for i = 1:length(W)
    if selector(i)==0
        W(i)=0;
    end
end

W = W(1:NODES) + 1j * W(NODES+1:2*NODES);

end


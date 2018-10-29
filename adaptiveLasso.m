function [ W ] = adaptiveLasso( Phi, hc, lambda, mode, gamma )
% Implementation of adaptive lasso method

if nargin<5
    gamma = 1;
end

[~,NODES] = size(Phi);

re_phi = real(Phi);
im_phi = imag(Phi);
X = [re_phi -im_phi; im_phi re_phi];

re_y = real(hc);
im_y = imag(hc);
Y = [re_y; im_y];

% first stage method
switch mode
    case 1  % OLS regression
        hw = Phi\hc;
%         hw = pinv(full(Phi))*hc;
    case 2  % LASSO regression
        cvx_begin quiet
        %cvx_begin
        cvx_solver sdpt3
        variable B(2*NODES,1)
        minimize( square_pos( norm( X * B - Y , 2 ) ) + lambda * norm( B , 1 ) );
        cvx_end
        hw = B(1:NODES) + 1j * B(NODES+1:2*NODES);
    case 3  % Ridge regression
        cvx_begin quiet
        %cvx_begin
        cvx_solver sdpt3
        variable B(2*NODES,1)
        minimize( square_pos( norm( X * B - Y , 2 ) ) + lambda * norm( B , 2 ) );
        cvx_end
        hw = B(1:NODES) + 1j * B(NODES+1:2*NODES);
end

selector = ones(2*length(hw),1);
for i = 1:length(hw)
    if abs(hw(i))==0
         selector(i)=0;
         selector(NODES+i)=0;
     end
 end

re_beta = 1./(power(abs(real(hw)),gamma)+1e-2);
im_beta = 1./(power(abs(imag(hw)),gamma)+1e-2);

beta = [re_beta; im_beta];

% first stage method: lasso

cvx_begin quiet
%cvx_begin
cvx_solver sdpt3
variable W(2*NODES,1)
minimize( square_pos( norm( X * ( selector .* W ) - Y , 2 ) ) + lambda * norm( beta .* W , 1 ) );
cvx_end

 for i = 1:length(selector)
     if selector(i)==0
         W(i)=0;
     end
 end

W = W(1:NODES) + 1j * W(NODES+1:2*NODES);

end

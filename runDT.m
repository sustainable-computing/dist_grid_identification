function [DeltaY, NewY, norm_diff] = runDT(V, I, OldY, lambda, iter_end)

% lambda banlance the weight of fitness and complexity
% iteration = 1
% here, I only implement a decentralized algorithm which is
% computationally efficient

[NODES,~] = size(V);

%   M = kron(eye(), V');

delta2 = 1e-4;
y_stack = zeros(2*NODES, NODES);
DeltaY = zeros(NODES, NODES);
I_diff = I - OldY*V;

for index = 1 : NODES
    %       fprintf('This is node %d \n', index);
    y = conj(I_diff(index,:))';
    phi = conj(V)';
    re_phi = real(phi);
    im_phi = imag(phi);
    re_y = real(y);
    im_y = imag(y);
    
    phi = [re_phi -im_phi; im_phi re_phi];
    y = [re_y; im_y];
    
    for iter=1:iter_end
        U=ones(2*NODES, iter_end);
        w_estimate=zeros(2*NODES, iter_end);
        cvx_begin quiet
        % cvx_solver sedumi
        % cvx_solver sdpt3
        
        % Real version
        variable W(2*NODES)
        minimize    (lambda*norm( U(:,iter).*W, 1 )+ norm((phi* W-y),2) )
        %                     subject to
        %                               ones(1,NODES) * W(1:NODES) == 0;
        %                               ones(1,NODES) * W(NODES+1: 2*NODES) == 0;
        
        cvx_end
        
        
        w_estimate(:,iter)=W;
        
    end
    
    y_stack(:,index) = w_estimate(:,end);
    DeltaY(:,index) = y_stack(1:NODES,index) + 1i * y_stack(NODES+1:2*NODES, index);
    
end

NewY = DeltaY + OldY;
norm_diff = norm(NewY, 'fro');

end

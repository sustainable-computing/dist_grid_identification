function [ Y11_est, Y22_est ] = recoverY( W, len_idx, len_nidx )

dimVecY22 = len_idx*(len_idx+1)/2; 

vecY22 = expan(len_idx) * W(1:dimVecY22);
vecY11 = expan(len_nidx)* W(dimVecY22+1:end);
Y22_est = reshape(vecY22(1:len_idx^2), [len_idx, len_idx]);
Y11_est = reshape(vecY11(1:len_nidx^2), [len_nidx, len_nidx]);

Y22_est(abs(Y22_est)<1e-2)=0;
Y11_est(abs(Y11_est)<1e-2)=0;

end
